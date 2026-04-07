from fastapi import APIRouter

from app.api.routers import admin, auth, orders, products, uploads

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(products.router, prefix="/products", tags=["products"])
api_router.include_router(orders.router, prefix="/orders", tags=["orders"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(uploads.router, prefix="/uploads", tags=["uploads"])
