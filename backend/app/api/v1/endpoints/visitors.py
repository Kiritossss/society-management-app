import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.dependencies import require_member, require_support_staff
from app.crud.crud_visitor import (
    approve_visitor,
    check_in_visitor,
    check_out_visitor,
    create_log_entry,
    create_pre_approval,
    deny_visitor,
    get_active_pre_approvals,
    get_pending_for_resident,
    get_visitor_log_by_id,
    get_visitor_logs,
)
from app.db.session import get_db
from app.models.user import User, UserRole
from app.models.visitor import VisitStatus
from app.schemas.visitor import VisitorLogEntry, VisitorPreApprove, VisitorResponse

router = APIRouter(prefix="/visitors", tags=["Visitors"])


@router.post("/pre-approve", response_model=VisitorResponse, status_code=status.HTTP_201_CREATED)
def pre_approve_visitor(
    data: VisitorPreApprove,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """Resident pre-approves a visitor before they arrive."""
    return create_pre_approval(
        db,
        society_id=current_user.society_id,
        resident_id=current_user.id,
        unit_id=current_user.unit_id,
        data=data,
    )


@router.post("/log-entry", response_model=VisitorResponse, status_code=status.HTTP_201_CREATED)
def log_visitor_entry(
    data: VisitorLogEntry,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_support_staff),
):
    """Support staff logs a visitor arrival. Creates a PENDING entry for resident approval."""
    return create_log_entry(
        db,
        society_id=current_user.society_id,
        staff_id=current_user.id,
        data=data,
    )


@router.get("/", response_model=list[VisitorResponse])
def list_visitors(
    status_filter: VisitStatus | None = Query(None, alias="status"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """
    List visitor logs.
    - Members see only their own visitors.
    - Admin/Committee/Support Staff see all visitors in the society.
    """
    resident_id = None
    if current_user.role == UserRole.MEMBER:
        resident_id = current_user.id

    return get_visitor_logs(
        db,
        society_id=current_user.society_id,
        resident_id=resident_id,
        status_filter=status_filter,
        skip=skip,
        limit=limit,
    )


@router.get("/pending", response_model=list[VisitorResponse])
def list_pending_approvals(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """Get visitors waiting for the current resident's approval."""
    return get_pending_for_resident(db, current_user.society_id, current_user.id)


@router.get("/pre-approved", response_model=list[VisitorResponse])
def list_pre_approved(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_support_staff),
):
    """Support staff: see all active pre-approvals that haven't been checked in yet."""
    return get_active_pre_approvals(db, current_user.society_id)


@router.get("/{visitor_id}", response_model=VisitorResponse)
def get_visitor(
    visitor_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """Get a single visitor log entry."""
    visitor = get_visitor_log_by_id(db, current_user.society_id, visitor_id)
    if not visitor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Visitor log not found")

    # Members can only see their own visitors
    if current_user.role == UserRole.MEMBER and visitor.resident_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    return visitor


@router.patch("/{visitor_id}/approve", response_model=VisitorResponse)
def approve(
    visitor_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """Resident approves a pending visitor."""
    visitor = get_visitor_log_by_id(db, current_user.society_id, visitor_id)
    if not visitor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Visitor log not found")

    if visitor.resident_id != current_user.id and current_user.role == UserRole.MEMBER:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your visitor")

    if visitor.status != VisitStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Cannot approve — current status is {visitor.status.value}",
        )

    return approve_visitor(db, visitor)


@router.patch("/{visitor_id}/deny", response_model=VisitorResponse)
def deny(
    visitor_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_member),
):
    """Resident denies a pending visitor."""
    visitor = get_visitor_log_by_id(db, current_user.society_id, visitor_id)
    if not visitor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Visitor log not found")

    if visitor.resident_id != current_user.id and current_user.role == UserRole.MEMBER:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your visitor")

    if visitor.status != VisitStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Cannot deny — current status is {visitor.status.value}",
        )

    return deny_visitor(db, visitor)


@router.patch("/{visitor_id}/check-in", response_model=VisitorResponse)
def check_in(
    visitor_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_support_staff),
):
    """Support staff checks in a pre-approved or approved visitor."""
    visitor = get_visitor_log_by_id(db, current_user.society_id, visitor_id)
    if not visitor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Visitor log not found")

    allowed = {VisitStatus.PRE_APPROVED, VisitStatus.APPROVED}
    if visitor.status not in allowed:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Cannot check in — current status is {visitor.status.value}",
        )

    return check_in_visitor(db, visitor, current_user.id)


@router.patch("/{visitor_id}/check-out", response_model=VisitorResponse)
def check_out(
    visitor_id: uuid.UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_support_staff),
):
    """Support staff logs visitor departure."""
    visitor = get_visitor_log_by_id(db, current_user.society_id, visitor_id)
    if not visitor:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Visitor log not found")

    if visitor.status != VisitStatus.CHECKED_IN:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Cannot check out — current status is {visitor.status.value}",
        )

    return check_out_visitor(db, visitor)
