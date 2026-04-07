from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.api.deps import get_current_admin
from app.db.session import get_db
from app.models.order import Order, OrderItem
from app.models.user import User
from app.schemas.order import OrderListResponse, OrderRead

router = APIRouter()


@router.get("/orders", response_model=OrderListResponse)
def list_admin_orders(
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> OrderListResponse:
    orders = db.scalars(
        select(Order)
        .options(joinedload(Order.items).joinedload(OrderItem.product), joinedload(Order.user))
        .order_by(Order.created_at.desc())
    ).unique().all()
    return OrderListResponse(items=[OrderRead.model_validate(order) for order in orders])
