from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


# Import all models here so Alembic can detect them for autogenerate
from app.models.society import Society  # noqa: F401, E402
from app.models.user import User  # noqa: F401, E402
