from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.api.deps import get_current_admin
from app.db.session import get_db
from app.models.product import Product
from app.models.user import User
from app.schemas.product import ProductCreate, ProductListResponse, ProductRead, ProductUpdate

router = APIRouter()


@router.get("", response_model=ProductListResponse)
def list_products(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=10, ge=1, le=100),
    search: str | None = Query(default=None),
    db: Session = Depends(get_db),
) -> ProductListResponse:
    filters = []
    if search:
        term = f"%{search.strip()}%"
        filters.append(
            or_(
                Product.name.ilike(term),
                Product.description.ilike(term),
            )
        )

    query = select(Product).order_by(Product.created_at.desc())
    count_query = select(func.count(Product.id))
    if filters:
        for item in filters:
            query = query.where(item)
            count_query = count_query.where(item)

    total = db.scalar(count_query) or 0
    items = db.scalars(
        query.offset((page - 1) * page_size).limit(page_size)
    ).all()
    return ProductListResponse(
        items=[ProductRead.model_validate(item) for item in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{product_id}", response_model=ProductRead)
def get_product(product_id: int, db: Session = Depends(get_db)) -> ProductRead:
    product = db.get(Product, product_id)
    if product is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found.")
    return ProductRead.model_validate(product)


@router.post("", response_model=ProductRead, status_code=status.HTTP_201_CREATED)
def create_product(
    payload: ProductCreate,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> ProductRead:
    product = Product(**payload.model_dump())
    db.add(product)
    db.commit()
    db.refresh(product)
    return ProductRead.model_validate(product)


@router.put("/{product_id}", response_model=ProductRead)
def update_product(
    product_id: int,
    payload: ProductUpdate,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> ProductRead:
    product = db.get(Product, product_id)
    if product is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found.")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(product, field, value)

    db.commit()
    db.refresh(product)
    return ProductRead.model_validate(product)


@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_admin),
) -> None:
    product = db.get(Product, product_id)
    if product is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found.")
    db.delete(product)
    db.commit()
