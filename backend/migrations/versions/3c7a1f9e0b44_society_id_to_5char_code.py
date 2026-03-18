"""society_id_to_5char_code

Revision ID: 3c7a1f9e0b44
Revises: 2f91e58ce8d9
Create Date: 2026-03-18

Changes societies.id (and all FK references) from UUID to VARCHAR(5).
IMPORTANT: This migration truncates all data — re-run your test setup after applying.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers
revision = "3c7a1f9e0b44"
down_revision = "2f91e58ce8d9"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Clear all data first — existing UUIDs can't be converted to 5-char codes
    op.execute("TRUNCATE TABLE complaints, units, users, societies RESTART IDENTITY CASCADE")

    # Drop FK constraints on tables that reference societies.id
    op.drop_constraint("users_society_id_fkey", "users", type_="foreignkey")
    op.drop_constraint("units_society_id_fkey", "units", type_="foreignkey")
    op.drop_constraint("complaints_society_id_fkey", "complaints", type_="foreignkey")

    # Change societies.id to VARCHAR(5)
    op.alter_column(
        "societies", "id",
        existing_type=postgresql.UUID(as_uuid=True),
        type_=sa.String(5),
        existing_nullable=False,
    )

    # Change society_id FK columns to VARCHAR(5)
    op.alter_column(
        "users", "society_id",
        existing_type=postgresql.UUID(as_uuid=True),
        type_=sa.String(5),
        existing_nullable=False,
    )
    op.alter_column(
        "units", "society_id",
        existing_type=postgresql.UUID(as_uuid=True),
        type_=sa.String(5),
        existing_nullable=False,
    )
    op.alter_column(
        "complaints", "society_id",
        existing_type=postgresql.UUID(as_uuid=True),
        type_=sa.String(5),
        existing_nullable=False,
    )

    # Recreate FK constraints
    op.create_foreign_key(
        "users_society_id_fkey", "users", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "units_society_id_fkey", "units", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "complaints_society_id_fkey", "complaints", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )


def downgrade() -> None:
    op.drop_constraint("users_society_id_fkey", "users", type_="foreignkey")
    op.drop_constraint("units_society_id_fkey", "units", type_="foreignkey")
    op.drop_constraint("complaints_society_id_fkey", "complaints", type_="foreignkey")

    op.execute("TRUNCATE TABLE complaints, units, users, societies RESTART IDENTITY CASCADE")

    op.alter_column(
        "societies", "id",
        existing_type=sa.String(5),
        type_=postgresql.UUID(as_uuid=True),
        existing_nullable=False,
        postgresql_using="gen_random_uuid()",
    )
    op.alter_column(
        "users", "society_id",
        existing_type=sa.String(5),
        type_=postgresql.UUID(as_uuid=True),
        existing_nullable=False,
        postgresql_using="gen_random_uuid()",
    )
    op.alter_column(
        "units", "society_id",
        existing_type=sa.String(5),
        type_=postgresql.UUID(as_uuid=True),
        existing_nullable=False,
        postgresql_using="gen_random_uuid()",
    )
    op.alter_column(
        "complaints", "society_id",
        existing_type=sa.String(5),
        type_=postgresql.UUID(as_uuid=True),
        existing_nullable=False,
        postgresql_using="gen_random_uuid()",
    )

    op.create_foreign_key(
        "users_society_id_fkey", "users", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "units_society_id_fkey", "units", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )
    op.create_foreign_key(
        "complaints_society_id_fkey", "complaints", "societies", ["society_id"], ["id"], ondelete="CASCADE"
    )
