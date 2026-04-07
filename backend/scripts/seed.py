import sys
from pathlib import Path
from decimal import Decimal

from sqlalchemy import select

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.core.security import get_password_hash
from app.db.base import Base
from app.db.session import SessionLocal, engine
from app.models.product import Product
from app.models.user import User


def seed() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        admin = db.scalar(select(User).where(User.email == "admin@shopflow.com"))
        if admin is None:
            admin = User(
                name="ShopFlow Admin",
                email="admin@shopflow.com",
                password_hash=get_password_hash("admin123"),
                is_admin=True,
            )
            db.add(admin)

        demo_products = [
            {
                "name": "Classic White Sneakers",
                "description": "Comfortable everyday sneakers with a clean minimalist profile.",
                "price": Decimal("2499.00"),
                "image_url": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80",
            },
            {
                "name": "Urban Canvas Backpack",
                "description": "A durable backpack with padded sleeves for work and college use.",
                "price": Decimal("1899.00"),
                "image_url": "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=900&q=80",
            },
            {
                "name": "Smart Casual Watch",
                "description": "Slim dial watch designed for daily wear and quick outfit pairing.",
                "price": Decimal("3299.00"),
                "image_url": "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=900&q=80",
            },
        ]

        existing_names = {
            name for (name,) in db.execute(select(Product.name)).all()
        }
        for item in demo_products:
            if item["name"] not in existing_names:
                db.add(Product(**item))

        db.commit()
        print("Seed complete.")
        print("Admin: admin@shopflow.com / admin123")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
