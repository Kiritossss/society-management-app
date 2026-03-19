import uuid
from datetime import datetime, timezone

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.models.visitor import VisitorLog, VisitStatus
from app.schemas.visitor import VisitorLogEntry, VisitorPreApprove


def create_pre_approval(
    db: Session,
    society_id: str,
    resident_id: uuid.UUID,
    unit_id: uuid.UUID | None,
    data: VisitorPreApprove,
) -> VisitorLog:
    """Resident pre-approves a visitor before they arrive."""
    visitor = VisitorLog(
        society_id=society_id,
        unit_id=unit_id,
        resident_id=resident_id,
        visitor_name=data.visitor_name,
        visitor_phone=data.visitor_phone,
        visitor_count=data.visitor_count,
        purpose=data.purpose,
        vehicle_number=data.vehicle_number,
        expected_at=data.expected_at,
        notes=data.notes,
        status=VisitStatus.PRE_APPROVED,
        pre_approved_by_id=resident_id,
    )
    db.add(visitor)
    db.commit()
    db.refresh(visitor)
    return visitor


def create_log_entry(
    db: Session,
    society_id: str,
    staff_id: uuid.UUID,
    data: VisitorLogEntry,
) -> VisitorLog:
    """Support staff logs a visitor arrival.

    If a resident is specified, status is PENDING (awaiting resident approval).
    If no resident (walk-in: cab, delivery, etc.), status is CHECKED_IN directly.
    """
    is_walk_in = data.resident_id is None and data.unit_id is None
    visitor = VisitorLog(
        society_id=society_id,
        unit_id=data.unit_id,
        resident_id=data.resident_id,
        visitor_name=data.visitor_name,
        visitor_phone=data.visitor_phone,
        visitor_count=data.visitor_count,
        purpose=data.purpose,
        vehicle_number=data.vehicle_number,
        notes=data.notes,
        status=VisitStatus.CHECKED_IN if is_walk_in else VisitStatus.PENDING,
        checked_in_by_id=staff_id,
        checked_in_at=datetime.now(timezone.utc),
    )
    db.add(visitor)
    db.commit()
    db.refresh(visitor)
    return visitor


def get_visitor_log_by_id(
    db: Session, society_id: str, visitor_id: uuid.UUID
) -> VisitorLog | None:
    return (
        db.query(VisitorLog)
        .filter(VisitorLog.society_id == society_id, VisitorLog.id == visitor_id)
        .first()
    )


def get_visitor_logs(
    db: Session,
    society_id: str,
    resident_id: uuid.UUID | None = None,
    status_filter: VisitStatus | None = None,
    skip: int = 0,
    limit: int = 50,
) -> list[VisitorLog]:
    """List visitor logs. If resident_id is provided, filter to that resident's visitors only."""
    query = db.query(VisitorLog).filter(VisitorLog.society_id == society_id)

    if resident_id:
        query = query.filter(
            or_(
                VisitorLog.resident_id == resident_id,
                VisitorLog.pre_approved_by_id == resident_id,
            )
        )

    if status_filter:
        query = query.filter(VisitorLog.status == status_filter)

    return query.order_by(VisitorLog.created_at.desc()).offset(skip).limit(limit).all()


def get_pending_for_resident(
    db: Session, society_id: str, resident_id: uuid.UUID
) -> list[VisitorLog]:
    """Get visitors waiting for this resident's approval."""
    return (
        db.query(VisitorLog)
        .filter(
            VisitorLog.society_id == society_id,
            VisitorLog.resident_id == resident_id,
            VisitorLog.status == VisitStatus.PENDING,
        )
        .order_by(VisitorLog.created_at.desc())
        .all()
    )


def get_active_pre_approvals(
    db: Session, society_id: str
) -> list[VisitorLog]:
    """Get all pre-approved visitors that haven't checked in yet (for support staff)."""
    return (
        db.query(VisitorLog)
        .filter(
            VisitorLog.society_id == society_id,
            VisitorLog.status == VisitStatus.PRE_APPROVED,
        )
        .order_by(VisitorLog.expected_at.asc().nulls_last(), VisitorLog.created_at.desc())
        .all()
    )


def approve_visitor(db: Session, visitor: VisitorLog) -> VisitorLog:
    visitor.status = VisitStatus.APPROVED
    db.commit()
    db.refresh(visitor)
    return visitor


def deny_visitor(db: Session, visitor: VisitorLog) -> VisitorLog:
    visitor.status = VisitStatus.DENIED
    db.commit()
    db.refresh(visitor)
    return visitor


def check_in_visitor(
    db: Session, visitor: VisitorLog, staff_id: uuid.UUID
) -> VisitorLog:
    """Support staff checks in a pre-approved or approved visitor."""
    visitor.status = VisitStatus.CHECKED_IN
    visitor.checked_in_by_id = staff_id
    visitor.checked_in_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(visitor)
    return visitor


def delete_visitor(db: Session, visitor: VisitorLog) -> None:
    db.delete(visitor)
    db.commit()


def check_out_visitor(db: Session, visitor: VisitorLog) -> VisitorLog:
    visitor.status = VisitStatus.CHECKED_OUT
    visitor.checked_out_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(visitor)
    return visitor
