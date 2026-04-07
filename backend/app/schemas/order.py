from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.order import OrderStatus
from app.schemas.product import ProductRead
from app.schemas.user import UserRead


class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(ge=1, le=20)


class OrderCreate(BaseModel):
    items: list[OrderItemCreate]
    shipping_address: str = Field(min_length=10, max_length=500)
    customer_name: str = Field(min_length=2, max_length=120)
    customer_phone: str = Field(min_length=8, max_length=20)
    payment_method: str = "cod"


class OrderItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    product_id: int
    quantity: int
    unit_price: Decimal
    product: ProductRead


class OrderRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    total_amount: Decimal
    status: OrderStatus
    shipping_address: str
    customer_name: str
    customer_phone: str
    created_at: datetime
    user: UserRead
    items: list[OrderItemRead]


class OrderListResponse(BaseModel):
    items: list[OrderRead]


class OrderStatusUpdate(BaseModel):
    status: OrderStatus
