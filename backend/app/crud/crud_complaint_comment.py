import uuid

from sqlalchemy.orm import Session

from app.models.complaint_comment import ComplaintComment
from app.schemas.complaint_comment import CommentCreate


def create_comment(
    db: Session,
    society_id: str,
    complaint_id: uuid.UUID,
    user_id: uuid.UUID,
    data: CommentCreate,
) -> ComplaintComment:
    comment = ComplaintComment(
        society_id=society_id,
        complaint_id=complaint_id,
        user_id=user_id,
        body=data.body,
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return comment


def get_comments(
    db: Session,
    society_id: str,
    complaint_id: uuid.UUID,
    skip: int = 0,
    limit: int = 100,
) -> list[ComplaintComment]:
    return (
        db.query(ComplaintComment)
        .filter(
            ComplaintComment.society_id == society_id,
            ComplaintComment.complaint_id == complaint_id,
        )
        .order_by(ComplaintComment.created_at.asc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def delete_comment(db: Session, comment: ComplaintComment) -> None:
    db.delete(comment)
    db.commit()


def get_comment_by_id(
    db: Session, society_id: str, comment_id: uuid.UUID
) -> ComplaintComment | None:
    return (
        db.query(ComplaintComment)
        .filter(
            ComplaintComment.society_id == society_id,
            ComplaintComment.id == comment_id,
        )
        .first()
    )
