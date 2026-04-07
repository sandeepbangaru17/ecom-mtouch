from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, UploadFile, status

from app.api.deps import get_current_admin
from app.core.config import settings
from app.models.user import User

router = APIRouter()


@router.post("/image", status_code=status.HTTP_201_CREATED)
def upload_product_image(
    file: UploadFile = File(...),
    _: User = Depends(get_current_admin),
) -> dict[str, str]:
    upload_dir = Path(settings.upload_dir)
    upload_dir.mkdir(parents=True, exist_ok=True)

    extension = Path(file.filename or "").suffix or ".jpg"
    filename = f"{uuid4().hex}{extension}"
    destination = upload_dir / filename
    destination.write_bytes(file.file.read())

    return {
        "image_url": f"{settings.base_url}/static/uploads/{filename}",
    }
