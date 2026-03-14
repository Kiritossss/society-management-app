import uuid

from sqlalchemy.orm import Session

from app.models.society import Society
from app.schemas.society import SocietyCreate


def get_society_by_email(db: Session, contact_email: str) -> Society | None:
    return db.query(Society).filter(Society.contact_email == contact_email).first()


def get_society_by_id(db: Session, society_id: uuid.UUID) -> Society | None:
    return db.query(Society).filter(Society.id == society_id).first()


def create_society(db: Session, data: SocietyCreate) -> Society:
    society = Society(
        name=data.name,
        address=data.address,
        contact_email=data.contact_email,
    )
    db.add(society)
    db.commit()
    db.refresh(society)
    return society
