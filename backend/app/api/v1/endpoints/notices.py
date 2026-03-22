import os
import uuid
from pathlib import Path
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_committee
from app.core.config import settings
from app.crud.crud_notice import (
    create_notice,
    delete_notice,
    get_notice_by_id,
    get_notices,
    update_notice,
)
from app.db.session import get_db
from app.models.user import User
from app.schemas.notice import NoticeCreate, NoticeResponse, NoticeUpdate

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_BYTES = settings.MAX_IMAGE_SIZE_MB * 1024 * 1024

router = APIRouter(prefix="/notices", tags=["Notices"])


@router.post("/", response_model=NoticeResponse, status_code=status.HTTP_201_CREATED)
def create_new_notice(
    data: NoticeCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can post notices."""
    return create_notice(
        db,
        society_id=current_user.society_id,
        posted_by_id=current_user.id,
        data=data,
    )


@router.get("/", response_model=list[NoticeResponse])
def list_notices(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=100),
):
    """All authenticated members can list notices."""
    return get_notices(
        db,
        society_id=current_user.society_id,
        skip=skip,
        limit=limit,
    )


@router.get("/{notice_id}", response_model=NoticeResponse)
def get_notice(
    notice_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Any authenticated member can view a notice."""
    notice = get_notice_by_id(db, current_user.society_id, notice_id)
    if not notice:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notice not found")
    return notice


@router.patch("/{notice_id}", response_model=NoticeResponse)
def edit_notice(
    notice_id: uuid.UUID,
    data: NoticeUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can edit a notice."""
    notice = get_notice_by_id(db, current_user.society_id, notice_id)
    if not notice:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notice not found")
    return update_notice(db, notice, data)


@router.delete("/{notice_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_notice(
    notice_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can delete a notice."""
    notice = get_notice_by_id(db, current_user.society_id, notice_id)
    if not notice:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notice not found")
    # Delete associated image file if present
    if notice.image_url:
        image_path = Path(settings.UPLOAD_DIR) / "notices" / os.path.basename(notice.image_url)
        image_path.unlink(missing_ok=True)
    delete_notice(db, notice)


@router.post("/upload-image")
def upload_notice_image(
    file: UploadFile,
    current_user: Annotated[User, Depends(require_committee)],
):
    """Upload an image for a notice. Returns the URL to use in notice creation."""
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only JPEG, PNG, and WebP images are allowed",
        )

    contents = file.read()
    if len(contents) > MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Image must be under {settings.MAX_IMAGE_SIZE_MB}MB",
        )

    ext = file.filename.rsplit(".", 1)[-1].lower() if file.filename and "." in file.filename else "jpg"
    if ext not in ("jpg", "jpeg", "png", "webp"):
        ext = "jpg"
    filename = f"{uuid.uuid4().hex}.{ext}"

    upload_dir = Path(settings.UPLOAD_DIR) / "notices"
    upload_dir.mkdir(parents=True, exist_ok=True)

    filepath = upload_dir / filename
    filepath.write_bytes(contents)

    return {"image_url": f"/uploads/notices/{filename}"}
