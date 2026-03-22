import uuid
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, require_committee
from app.crud.crud_complaint import (
    create_complaint,
    delete_complaint,
    get_complaint_by_id,
    get_complaints,
    update_complaint_status,
)
from app.crud.crud_complaint_comment import (
    create_comment,
    delete_comment,
    get_comment_by_id,
    get_comments,
)
from app.db.session import get_db
from app.models.user import User, UserRole
from app.schemas.complaint import ComplaintCreate, ComplaintResponse, ComplaintStatusUpdate
from app.schemas.complaint_comment import CommentCreate, CommentResponse

router = APIRouter(prefix="/complaints", tags=["Complaints"])


@router.post("/", response_model=ComplaintResponse, status_code=status.HTTP_201_CREATED)
def raise_complaint(
    data: ComplaintCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Any authenticated member can raise a complaint."""
    return create_complaint(
        db,
        society_id=current_user.society_id,
        raised_by_id=current_user.id,
        data=data,
    )


@router.get("/", response_model=list[ComplaintResponse])
def list_complaints(
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=100),
):
    """All society members can view all complaints — transparency by design."""
    return get_complaints(
        db,
        society_id=current_user.society_id,
        skip=skip,
        limit=limit,
    )


@router.get("/{complaint_id}", response_model=ComplaintResponse)
def get_complaint(
    complaint_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    return complaint


@router.patch("/{complaint_id}/status", response_model=ComplaintResponse)
def update_status(
    complaint_id: uuid.UUID,
    data: ComplaintStatusUpdate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can update complaint status."""
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    return update_complaint_status(db, complaint, data)


@router.delete("/{complaint_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_complaint(
    complaint_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(require_committee)],
):
    """Only Committee/Admin can delete a complaint."""
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    delete_complaint(db, complaint)


# ── Comment Endpoints ─────────────────────────────────────────────────────────


def _comment_to_response(comment) -> CommentResponse:
    """Build CommentResponse with user_name from the relationship."""
    return CommentResponse(
        id=comment.id,
        complaint_id=comment.complaint_id,
        user_id=comment.user_id,
        user_name=comment.user.full_name,
        body=comment.body,
        created_at=comment.created_at,
    )


@router.get("/{complaint_id}/comments", response_model=list[CommentResponse])
def list_comments(
    complaint_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=100, ge=1, le=100),
):
    """List comments on a complaint. Any society member can view."""
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")

    comments = get_comments(db, current_user.society_id, complaint_id, skip, limit)
    return [_comment_to_response(c) for c in comments]


@router.post(
    "/{complaint_id}/comments",
    response_model=CommentResponse,
    status_code=status.HTTP_201_CREATED,
)
def add_comment(
    complaint_id: uuid.UUID,
    data: CommentCreate,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Add a comment to a complaint. Any society member can comment."""
    complaint = get_complaint_by_id(db, current_user.society_id, complaint_id)
    if not complaint:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")

    comment = create_comment(
        db,
        society_id=current_user.society_id,
        complaint_id=complaint_id,
        user_id=current_user.id,
        data=data,
    )
    return _comment_to_response(comment)


@router.delete(
    "/{complaint_id}/comments/{comment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def remove_comment(
    complaint_id: uuid.UUID,
    comment_id: uuid.UUID,
    db: Annotated[Session, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """Delete a comment. Admin/Committee can delete any; others can delete their own."""
    comment = get_comment_by_id(db, current_user.society_id, comment_id)
    if not comment or comment.complaint_id != complaint_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Comment not found")

    is_manager = current_user.role in (UserRole.ADMIN, UserRole.COMMITTEE)
    if not is_manager and comment.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    delete_comment(db, comment)
