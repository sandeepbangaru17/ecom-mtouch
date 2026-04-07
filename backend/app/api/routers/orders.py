from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.api.deps import get_current_admin, get_current_user
from app.db.session import get_db
from app.models.order import Order, OrderItem, OrderStatus
from app.models.product import Product
from app.models.user import User
from app.schemas.order import OrderCreate, OrderListResponse, OrderRead, OrderStatusUpdate

router = APIRouter()


@router.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
def create_order(
    payload: OrderCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> OrderRead:
    if payload.payment_method.lower() != "cod":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only Cash on Delivery is supported.",
        )

    product_ids = [item.product_id for item in payload.items]
    products = db.scalars(select(Product).where(Product.id.in_(product_ids))).all()
    product_map = {product.id: product for product in products}

    if len(product_map) != len(set(product_ids)):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="One or more selected products do not exist.",
        )

    total_amount = Decimal("0.00")
    order = Order(
        user_id=user.id,
        total_amount=Decimal("0.00"),
        status=OrderStatus.pending,
        shipping_address=payload.shipping_address.strip(),
        customer_name=payload.customer_name.strip(),
        customer_phone=payload.customer_phone.strip(),
    )
    db.add(order)
    db.flush()

    for item in payload.items:
        product = product_map[item.product_id]
        line_total = Decimal(product.price) * item.quantity
        total_amount += line_total
        db.add(
            OrderItem(
                order_id=order.id,
                product_id=product.id,
                quantity=item.quantity,
                unit_price=product.price,
            )
        )

    order.total_amount = total_amount
    db.commit()

    created_order = db.scalar(
        select(Order)
        .options(joinedload(Order.items).joinedload(OrderItem.product), joinedload(Order.user))
        .where(Order.id == order.id)
    )
    return OrderRead.model_validate(created_order)


@router.get("", response_model=OrderListResponse)
def list_user_orders(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
) -> OrderListResponse:
    orders = db.scalars(
        select(Order)
        .options(joinedload(Order.items).joinedload(OrderItem.product), joinedload(Order.user))
        .where(Order.user_id == user.id)
        .order_by(Order.created_at.desc())
    ).unique().all()
    return OrderListResponse(items=[OrderRead.model_validate(order) for order in orders])


@router.get("/admin/all", response_model=OrderListResponse)
def list_all_orders(
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> OrderListResponse:
    orders = db.scalars(
        select(Order)
        .options(joinedload(Order.items).joinedload(OrderItem.product), joinedload(Order.user))
        .order_by(Order.created_at.desc())
    ).unique().all()
    return OrderListResponse(items=[OrderRead.model_validate(order) for order in orders])


@router.get("/admin", response_model=OrderListResponse, include_in_schema=False)
def list_all_orders_alias(
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> OrderListResponse:
    return list_all_orders(db=db, _=_)


@router.put("/{order_id}/status", response_model=OrderRead)
def update_order_status(
    order_id: int,
    payload: OrderStatusUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> OrderRead:
    order = db.scalar(
        select(Order)
        .options(joinedload(Order.items).joinedload(OrderItem.product), joinedload(Order.user))
        .where(Order.id == order_id)
    )
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found.")

    order.status = payload.status
    db.commit()
    db.refresh(order)
    return OrderRead.model_validate(order)
