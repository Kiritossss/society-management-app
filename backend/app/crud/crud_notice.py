import uuid

from sqlalchemy.orm import Session

from app.models.notice import Notice
from app.schemas.notice import NoticeCreate, NoticeUpdate


def create_notice(
    db: Session,
    society_id: str,
    posted_by_id: uuid.UUID,
    data: NoticeCreate,
) -> Notice:
    notice = Notice(
        society_id=society_id,
        posted_by_id=posted_by_id,
        title=data.title,
        body=data.body,
        priority=data.priority,
        is_pinned=data.is_pinned,
        image_url=data.image_url,
    )
    db.add(notice)
    db.commit()
    db.refresh(notice)
    return notice


def get_notices(
    db: Session,
    society_id: str,
    skip: int = 0,
    limit: int = 50,
) -> list[Notice]:
    """Returns notices ordered by pinned first, then newest first."""
    return (
        db.query(Notice)
        .filter(Notice.society_id == society_id)
        .order_by(Notice.is_pinned.desc(), Notice.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def get_notice_by_id(
    db: Session, society_id: str, notice_id: uuid.UUID
) -> Notice | None:
    return (
        db.query(Notice)
        .filter(
            Notice.society_id == society_id,
            Notice.id == notice_id,
        )
        .first()
    )


def update_notice(
    db: Session,
    notice: Notice,
    data: NoticeUpdate,
) -> Notice:
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(notice, field, value)
    db.commit()
    db.refresh(notice)
    return notice


def delete_notice(db: Session, notice: Notice) -> None:
    db.delete(notice)
    db.commit()
