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

---

## Session 1 (continued) — Phase 2: Authentication & Multi-Tenancy

**Objective:** Build secure login and role-based access control.

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/app/core/security.py` | Created | `hash_password`, `verify_password` (bcrypt), `create_access_token`, `decode_access_token` (JWT via `python-jose`) |
| `backend/app/schemas/society.py` | Created | `SocietyCreate`, `SocietyResponse` Pydantic schemas |
| `backend/app/schemas/user.py` | Created | `UserRegister` (with password strength + name validators), `UserLogin`, `UserResponse`, `TokenResponse` |
| `backend/app/schemas/__init__.py` | Created | Re-exports all schemas |
| `backend/app/crud/crud_user.py` | Created | `get_user_by_email`, `get_user_by_id`, `create_user`, `authenticate_user` — all scoped by `society_id` |
| `backend/app/crud/crud_society.py` | Created | `get_society_by_email`, `get_society_by_id`, `create_society` |
| `backend/app/crud/__init__.py` | Created | Re-exports all CRUD functions |
| `backend/app/api/dependencies.py` | Created | `get_current_user` (JWT decode + DB lookup), `require_roles()` factory, pre-built guards: `require_admin`, `require_committee`, `require_support_staff`, `require_member` |
| `backend/app/api/v1/__init__.py` | Created | `api_router` aggregating all v1 sub-routers |
| `backend/app/api/v1/endpoints/auth.py` | Created | `POST /api/v1/auth/society/register`, `POST /api/v1/auth/register`, `POST /api/v1/auth/login` |
| `backend/app/main.py` | Modified | Mounted `api_router` onto the FastAPI app |

### Key Design Decisions

- **JWT payload** carries `sub` (user UUID), `society_id`, and `role` — all three extracted and validated in `get_current_user`
- **All CRUD queries filter by `society_id`** — no cross-tenant data leakage possible
- **`require_roles()` is a factory** returning a FastAPI dependency; roles are additive (admin inherits all lower permissions)
- **Society registration is separate** from user registration — a society must exist before users can join it
- **Email uniqueness is per-society**, not global (`UNIQUE(society_id, email)`) — consistent with the migration constraint

### API Endpoints (Phase 2)

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| `POST` | `/api/v1/auth/society/register` | Public | Onboard a new society |
| `POST` | `/api/v1/auth/register?society_id=...` | Public | Register a user within a society |
| `POST` | `/api/v1/auth/login?society_id=...` | Public | Login — returns JWT token |

---

### Bug Fix: Circular Import (discovered during startup check)

| File | Action | Description |
|------|--------|-------------|
| `backend/app/db/base_class.py` | Created | Contains only `DeclarativeBase` — the single source of `Base` for all models |
| `backend/app/db/base.py` | Modified | Now only used by Alembic: imports `Base` from `base_class` + all models |
| `backend/app/models/society.py` | Modified | Changed `Base` import to `app.db.base_class` |
| `backend/app/models/user.py` | Modified | Changed `Base` import to `app.db.base_class` |

**Root cause:** `db/base.py` imported models, models imported `Base` from `db/base.py` → circular import at startup.

**Fix:** `Base` class lives in `db/base_class.py`; models import from there. `db/base.py` is Alembic-only.

Server verified running: `GET /health` returns `{"status": "ok"}`. Swagger docs accessible at `http://localhost:8000/docs`.

---

---

## Session 1 (continued) — Phase 3: Flutter App Foundation

**Objective:** Setup the mobile app shell — theme, networking, auth screens.

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `frontend/pubspec.yaml` | Created | Dependencies: flutter_riverpod, go_router, dio, flutter_secure_storage, shared_preferences |
| `frontend/lib/core/theme/app_colors.dart` | Created | Full color palette — primary, accent, semantic, role badge colors |
| `frontend/lib/core/theme/app_theme.dart` | Created | Material 3 `ThemeData` — AppBar, inputs, buttons, cards |
| `frontend/lib/core/constants/api_constants.dart` | Created | Base URL, versioned API endpoint paths, timeouts |
| `frontend/lib/core/constants/app_constants.dart` | Created | App name, secure storage key names |
| `frontend/lib/core/network/api_client.dart` | Created | Singleton Dio instance; `_AuthInterceptor` auto-attaches JWT `Bearer` header |
| `frontend/lib/shared/models/user_model.dart` | Created | `UserModel` with `fromJson` / `toJson` |
| `frontend/lib/shared/models/auth_token_model.dart` | Created | `AuthTokenModel` wrapping `UserModel` + token string |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Created | Post-login landing screen showing user name + role badge |
| `frontend/lib/features/auth/services/auth_service.dart` | Created | `login`, `register`, `logout`, `isLoggedIn` — persists session to secure storage |
| `frontend/lib/features/auth/providers/auth_provider.dart` | Created | `AuthState` + `AuthNotifier` (Riverpod `StateNotifier`); auto-checks saved session on startup |
| `frontend/lib/features/auth/screens/login_screen.dart` | Created | Login UI — society ID, email, password fields; error snackbar; navigate to register |
| `frontend/lib/features/auth/screens/register_screen.dart` | Created | Register UI — society ID, name, email, password + confirm; auto-login on success |
| `frontend/lib/main.dart` | Created | `ProviderScope` root, GoRouter with auth redirect guards, routes: `/login`, `/register`, `/dashboard` |

### Key Design Decisions

- **JWT stored in `flutter_secure_storage`** (encrypted keychain/keystore) — not SharedPreferences
- **`society_id` persisted to secure storage** so it's auto-attached to all subsequent API calls
- **GoRouter redirect guards** — unauthenticated users bounce to `/login`; authenticated users bypass auth routes
- **`AuthNotifier` checks saved token on startup** — seamless auto-login if token exists
- **`flutter analyze` passes with zero issues** after fixing deprecated `withOpacity` → `withValues(alpha:)`

---

## Session 1 (continued) — Phase 4: Complaint Management (Full-Stack)

**Objective:** Build complaint tracking end-to-end — backend model, API, and Flutter UI.

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/app/models/complaint.py` | Created | `Complaint` ORM model; `ComplaintCategory` enum (maintenance/noise/cleanliness/security/other); `ComplaintStatus` enum (open/in_progress/resolved/closed) |
| `backend/app/db/base.py` | Modified | Registered `Complaint` model for Alembic autogenerate |
| `backend/migrations/versions/fe54b529790e_create_complaints_table.py` | Created | Migration: creates `complaints` table with FKs to `societies` and `users` |
| `backend/app/schemas/complaint.py` | Created | `ComplaintCreate` (with validators), `ComplaintStatusUpdate`, `ComplaintResponse` |
| `backend/app/crud/crud_complaint.py` | Created | `create_complaint`, `get_complaints` (RBAC-aware), `get_complaint_by_id`, `update_complaint_status` |
| `backend/app/api/v1/endpoints/complaints.py` | Created | `POST /complaints/`, `GET /complaints/`, `GET /complaints/{id}`, `PATCH /complaints/{id}/status` |
| `backend/app/api/v1/__init__.py` | Modified | Mounted `complaints.router` |
| `frontend/lib/shared/models/complaint_model.dart` | Created | `ComplaintModel`, `ComplaintCategory`, `ComplaintStatus` constants |
| `frontend/lib/features/complaints/services/complaint_service.dart` | Created | Dio calls: list, get, create, update status |
| `frontend/lib/features/complaints/providers/complaint_provider.dart` | Created | `ComplaintState` + `ComplaintNotifier` (Riverpod); load, create, update status |
| `frontend/lib/features/complaints/screens/complaints_list_screen.dart` | Created | List view with status badges, category chips, pull-to-refresh, empty state |
| `frontend/lib/features/complaints/screens/create_complaint_screen.dart` | Created | Create form: category dropdown, title, description, image URL stub |
| `frontend/lib/main.dart` | Modified | Added `/complaints` and `/complaints/new` routes |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Modified | Full module grid — Complaints tile is live; others shown as locked (coming soon) |

### Key Design Decisions

- **RBAC on list endpoint**: `Member` sees only own complaints; `Committee`/`Admin` see all — enforced in CRUD, not just frontend
- **Member access guard on detail endpoint**: `403` if member tries to access another user's complaint by ID
- **`resolved_at` timestamp** set automatically when status → `resolved`
- **Image URL stub** included in create form — full upload integration planned for later phase
- **`flutter analyze` — zero issues**

### API Endpoints (Phase 4)

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| `POST` | `/api/v1/complaints/` | Any authenticated | Raise a new complaint |
| `GET` | `/api/v1/complaints/` | Any authenticated | List complaints (RBAC-filtered) |
| `GET` | `/api/v1/complaints/{id}` | Any authenticated | Get complaint detail |
| `PATCH` | `/api/v1/complaints/{id}/status` | Committee / Admin | Update status |

### Next Phase: Phase 5 — Visitor & Security Management (Full-Stack)

---

### Environment Notes

- Python version: 3.13.5
- Packages installed via `pip install -r requirements.txt --only-binary=:all:`
- No live PostgreSQL running yet — migration verified via `alembic upgrade --sql head` (offline SQL mode)
- IDE linter shows false-positive import errors (linter not pointed at the correct venv)
- To run the app: `uvicorn app.main:app --reload` from `backend/`
- To apply migrations: `alembic upgrade head` (requires running PostgreSQL)
