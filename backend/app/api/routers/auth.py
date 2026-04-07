from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from app.schemas.user import UserRead
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
)

router = APIRouter()


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest, db: Session = Depends(get_db)) -> TokenResponse:
    existing_user = db.scalar(select(User).where(User.email == payload.email.lower()))
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email is already registered.",
        )

    user = User(
        name=payload.name.strip(),
        email=payload.email.lower(),
        password_hash=get_password_hash(payload.password),
        is_admin=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token({"sub": str(user.id), "is_admin": user.is_admin})
    return TokenResponse(access_token=token, user=UserRead.model_validate(user))


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    user = db.scalar(select(User).where(User.email == payload.email.lower()))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    token = create_access_token({"sub": str(user.id), "is_admin": user.is_admin})
    return TokenResponse(access_token=token, user=UserRead.model_validate(user))
