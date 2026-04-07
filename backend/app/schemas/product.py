from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class ProductBase(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    description: str = Field(min_length=10, max_length=2000)
    price: Decimal = Field(gt=0)
    image_url: str = Field(min_length=4, max_length=500)


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    description: str | None = Field(default=None, min_length=10, max_length=2000)
    price: Decimal | None = Field(default=None, gt=0)
    image_url: str | None = Field(default=None, min_length=4, max_length=500)


class ProductRead(ProductBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime


class ProductListResponse(BaseModel):
    items: list[ProductRead]
    total: int
    page: int
    page_size: int
