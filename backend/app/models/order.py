import enum
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.user import Base


class OrderStatus(str, enum.Enum):
    pending = "Pending"
    confirmed = "Confirmed"
    delivered = "Delivered"


class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    total_amount: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    status: Mapped[OrderStatus] = mapped_column(
        Enum(OrderStatus),
        default=OrderStatus.pending,
        nullable=False,
    )
    shipping_address: Mapped[str] = mapped_column(Text, nullable=False)
    customer_name: Mapped[str] = mapped_column(String(120), nullable=False)
    customer_phone: Mapped[str] = mapped_column(String(20), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), nullable=False, index=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False, index=True)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    unit_price: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")
