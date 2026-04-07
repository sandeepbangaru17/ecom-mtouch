from datetime import datetime, timedelta, timezone

from jose import jwt
from passlib.context import CryptContext

from app.core.config import settings

ALGORITHM = "HS256"
password_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def get_password_hash(password: str) -> str:
    return password_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return password_context.verify(plain_password, hashed_password)


def create_access_token(data: dict[str, str | bool]) -> str:
    expires_delta = timedelta(minutes=settings.access_token_expire_minutes)
    to_encode = data.copy()
    to_encode["exp"] = datetime.now(timezone.utc) + expires_delta
    return jwt.encode(to_encode, settings.secret_key, algorithm=ALGORITHM)


def decode_access_token(token: str) -> dict[str, str | bool]:
    return jwt.decode(token, settings.secret_key, algorithms=[ALGORITHM])
