# Society Management App — Session Log

This file tracks everything done across all development sessions. Update it at the start and end of every session, and whenever files are added, modified, or removed.

---

## Session 1 — 2026-03-14

### Phase Completed: Phase 1 — Database & Core Setup (Backend)

**Objective:** Establish the FastAPI backend foundation and PostgreSQL database layer.

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `rules.md` | Read | Core rules & security principles governing the entire app |
| `claude_master_plan.txt` | Read | 7-phase development plan |
| `backend/requirements.txt` | Created | All Python dependencies (FastAPI, SQLAlchemy, Alembic, JWT, bcrypt, slowapi) |
| `backend/app/core/config.py` | Created | Pydantic `Settings` class — reads from `.env`: DB URL, JWT secret, rate limit |
| `backend/app/db/base.py` | Created | SQLAlchemy `DeclarativeBase`; imports all models for Alembic autogenerate |
| `backend/app/db/session.py` | Created | `create_engine`, `SessionLocal`, `get_db()` FastAPI dependency |
| `backend/app/models/society.py` | Created | `Society` ORM model (UUID PK, name, address, contact_email, is_active, timestamps) |
| `backend/app/models/user.py` | Created | `User` ORM model + `UserRole` enum (admin/committee/support_staff/member) |
| `backend/app/models/__init__.py` | Created | Re-exports `Society`, `User`, `UserRole` |
| `backend/app/main.py` | Created | FastAPI app with CORS middleware, SlowAPI rate limiting, `/health` endpoint |
| `backend/alembic.ini` | Created | Alembic config pointing to `migrations/` folder |
| `backend/migrations/env.py` | Created | Alembic env — reads DB URL from app settings, targets `Base.metadata` |
| `backend/migrations/versions/55f848de971d_create_societies_and_users.py` | Created | First migration: creates `societies` and `users` tables with all constraints |

---

### Key Design Decisions

- **UUID primary keys** on all tables (non-guessable, secure)
- **`society_id` FK on every `User`** — enforces multi-tenant data isolation per `rules.md`
- **`UNIQUE(society_id, email)`** — same email can join different societies (not globally unique)
- **`UserRole` enum** maps directly to `rules.md` roles: `admin`, `committee`, `support_staff`, `member`
- **Rate limiting** via `slowapi` — default 60 req/min, configurable via `.env`
- **`alembic upgrade --sql head`** verified — clean DDL output, migration is correct
- **`CASCADE` delete** on `users.society_id` — deleting a society removes all its users

---

### Phase 2 — Next Session: Authentication & Multi-Tenancy

**Planned work:**
1. Pydantic schemas for `User` and `Society` (create, login, response) → `backend/app/schemas/`
2. Auth dependency → `backend/app/api/dependencies.py` (JWT verify + role check + `society_id` extraction)
3. Auth endpoints → `backend/app/api/v1/endpoints/auth.py` (register, login, refresh)
4. `backend/app/core/security.py` (password hashing with bcrypt, JWT encode/decode)

---

### Environment Notes

- Python version: 3.13.5
- Packages installed via `pip install -r requirements.txt --only-binary=:all:`
- No live PostgreSQL running yet — migration verified via `alembic upgrade --sql head` (offline SQL mode)
- IDE linter shows false-positive import errors (linter not pointed at the correct venv)
- To run the app: `uvicorn app.main:app --reload` from `backend/`
- To apply migrations: `alembic upgrade head` (requires running PostgreSQL)
