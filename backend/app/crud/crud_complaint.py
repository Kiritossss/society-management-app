import uuid
from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.complaint import Complaint, ComplaintStatus
from app.models.user import UserRole
from app.schemas.complaint import ComplaintCreate, ComplaintStatusUpdate


def create_complaint(
    db: Session,
    society_id: str,
    raised_by_id: uuid.UUID,
    data: ComplaintCreate,
) -> Complaint:
    complaint = Complaint(
        society_id=society_id,
        raised_by_id=raised_by_id,
        title=data.title,
        description=data.description,
        category=data.category,
        image_url=data.image_url,
    )
    db.add(complaint)
    db.commit()
    db.refresh(complaint)
    return complaint


def get_complaints(
    db: Session,
    society_id: str,
    requesting_user_id: uuid.UUID,
    requesting_user_role: UserRole,
    skip: int = 0,
    limit: int = 50,
) -> list[Complaint]:
    """Committee/Admin see all complaints; members see only their own."""
    query = db.query(Complaint).filter(Complaint.society_id == society_id)

    if requesting_user_role == UserRole.MEMBER:
        query = query.filter(Complaint.raised_by_id == requesting_user_id)

    return (
        query.order_by(Complaint.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


def get_complaint_by_id(
    db: Session, society_id: str, complaint_id: uuid.UUID
) -> Complaint | None:
    return (
        db.query(Complaint)
        .filter(
            Complaint.society_id == society_id,
            Complaint.id == complaint_id,
        )
        .first()
    )


def delete_complaint(db: Session, complaint: Complaint) -> None:
    db.delete(complaint)
    db.commit()


def update_complaint_status(
    db: Session,
    complaint: Complaint,
    data: ComplaintStatusUpdate,
) -> Complaint:
    complaint.status = data.status
    if data.status == ComplaintStatus.RESOLVED:
        complaint.resolved_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(complaint)
    return complaint
