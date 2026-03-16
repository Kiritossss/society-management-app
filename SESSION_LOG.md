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

---

## Session 1 — Deferred Discussion: Society Registration UI

**Question raised:** "When will I be able to add a society from the app?"

**Current state:**
- Backend endpoint already exists: `POST /api/v1/auth/society/register` (built in Phase 2)
- Testable **right now** via Swagger at `http://localhost:8000/docs`
- No Flutter UI screen for society registration exists yet — master plan did not include one
- Data cannot be saved until PostgreSQL is running

**Two options discussed — decision deferred to next session:**

| Option | Description |
|--------|-------------|
| **A** | Keep it as-is — admin onboards society via Swagger, shares UUID with residents. Matches real SaaS behaviour. |
| **B** | Add a Society Registration screen to Flutter (outside original plan): Register Society → Get UUID → Register User → Login |

**To set up PostgreSQL (needed before any live data can be saved):**
```bash
brew install postgresql@16
brew services start postgresql@16
createdb society_db
cd backend && alembic upgrade head
```

**Action for next session:** Decide Option A or B, then continue to **Phase 5 — Visitor & Security Management**.

---

---

## Session 2 — 2026-03-15

### What We Did This Session

1. **Confirmed Phase 4 complete** — Complaint Management backend + Flutter UI is fully built.
2. **Added full setup guide to `claude_master_plan.txt`** — one-time PostgreSQL setup, `.env` creation, `alembic upgrade head`, server start command.
3. **Added full login walkthrough to `claude_master_plan.txt`** — step-by-step: create society via Swagger → get UUID → register user → login → authorize in Swagger → login from Flutter app.
4. **Added progress table** to master plan showing Phases 1–4 done, Phase 5 next.
5. Committed and pushed to GitHub.

### Files Modified This Session

| File | Action | Description |
|------|--------|-------------|
| `claude_master_plan.txt` | Modified | Added one-time setup guide, full login walkthrough, progress table, deferred decisions |

---

---

---

## Session 3 — 2026-03-15

### What We Did This Session

**Code Audit & Bug Fixes + Unit/Member Management (Full-Stack)**

Performed a full code audit across backend and frontend, fixed critical security bugs, and built the Unit + Member management system — the structural foundation for all future features.

---

### Part 1: Bug Fixes (from audit)

| # | Issue | Fix | File |
|---|-------|-----|------|
| 1 | Users could self-assign `admin` role at registration | Removed `role` from `UserRegister` schema; hardcoded `MEMBER` in `create_user()` | `schemas/user.py`, `crud/crud_user.py` |
| 2 | Pagination had no bounds (`limit=999999` allowed) | Added `Query(ge=0)` / `Query(ge=1, le=100)` | `endpoints/complaints.py` |
| 3 | `image_url` accepted any string (SSRF/XSS risk) | Added `field_validator` checking `http(s)://` prefix + 500 char limit | `schemas/complaint.py` |
| 4 | Flutter auth interceptor `void` + `async` mismatch | Changed `_AuthInterceptor` to extend `QueuedInterceptor` | `api_client.dart` |

---

### Part 2: Unit Model — Society Layout Structure

**New model: `Unit`** — flexible enough for any society layout (towers, blocks, row houses, or simple flat numbering).

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| society_id | UUID FK | Multi-tenant isolation |
| block_name | String | Nullable — "Tower A", "Block B" |
| floor_number | String | Nullable — "G", "1", "Mezzanine" |
| unit_number | String | Required — "301", "A-101", "House 5" |
| unit_type | String | Nullable — "1BHK", "2BHK", "Shop" |
| area_sqft | Float | Nullable — for future billing |
| is_occupied | Boolean | Default false, auto-updated on member assignment |

- Unique index: `(society_id, COALESCE(block_name, ''), COALESCE(floor_number, ''), unit_number)` — handles NULLs correctly
- `User.unit_id` FK added (nullable, `SET NULL` on delete) — links members to units
- `Society.units` relationship added

---

### Part 3: New Backend Endpoints

#### Unit Management (Admin-only)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/units/` | Create single unit |
| POST | `/api/v1/units/bulk` | Create up to 200 units at once |
| GET | `/api/v1/units/` | List units (paginated) |
| GET | `/api/v1/units/{id}` | Get unit detail |
| PATCH | `/api/v1/units/{id}` | Update unit metadata |
| DELETE | `/api/v1/units/{id}` | Delete (rejected if occupied) |

#### Member Management (Admin-only)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/members/` | Create user with role + unit assignment |
| GET | `/api/v1/members/` | List all society members |
| PATCH | `/api/v1/members/{id}/unit` | Assign/reassign unit |
| PATCH | `/api/v1/members/{id}/deactivate` | Deactivate member |

---

### Part 4: Frontend (Flutter)

- **`UnitModel`** — with `displayLabel` getter ("Tower A / Floor 3 / 301")
- **`UserModel`** — added `unitId` field
- **Unit feature** — service, provider, list screen (with delete), create screen
- **Member feature** — service, provider, add-member screen (with role dropdown + unit dropdown)
- **Dashboard** — admin-only tiles for "Manage Units" and "Manage Members"
- **Routes** — `/units`, `/units/new`, `/members/new`
- **`flutter analyze` — zero issues**

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/app/schemas/user.py` | Modified | Removed role from `UserRegister`; added `AdminCreateUser`, `AssignUnit` schemas; added `unit_id` to `UserResponse` |
| `backend/app/schemas/complaint.py` | Modified | Added `image_url` field validator |
| `backend/app/crud/crud_user.py` | Modified | Hardcoded MEMBER role; added `create_user_admin()`, `get_users()`, `assign_unit()`, `deactivate_user()` |
| `backend/app/api/v1/endpoints/complaints.py` | Modified | Added pagination bounds with `Query` validators |
| `backend/app/models/unit.py` | Created | `Unit` ORM model with COALESCE unique index |
| `backend/app/models/user.py` | Modified | Added `unit_id` FK and `unit` relationship |
| `backend/app/models/society.py` | Modified | Added `units` relationship |
| `backend/app/models/__init__.py` | Modified | Exported `Unit` |
| `backend/app/db/base.py` | Modified | Registered `Unit` for Alembic |
| `backend/app/schemas/unit.py` | Created | `UnitCreate`, `UnitUpdate`, `UnitResponse`, `UnitBulkCreate` |
| `backend/app/schemas/__init__.py` | Modified | Exported all new schemas |
| `backend/app/crud/crud_unit.py` | Created | Full CRUD for units (create, bulk, list, update, delete) |
| `backend/app/crud/__init__.py` | Modified | Exported all new CRUD functions |
| `backend/app/api/v1/endpoints/units.py` | Created | Admin-only unit management endpoints |
| `backend/app/api/v1/endpoints/members.py` | Created | Admin-only member management endpoints |
| `backend/app/api/v1/__init__.py` | Modified | Mounted `units` and `members` routers |
| `frontend/lib/core/network/api_client.dart` | Modified | Fixed `QueuedInterceptor` async bug |
| `frontend/lib/core/constants/api_constants.dart` | Modified | Added units + members endpoint paths |
| `frontend/lib/shared/models/user_model.dart` | Modified | Added `unitId` field |
| `frontend/lib/shared/models/unit_model.dart` | Created | `UnitModel` with `displayLabel` getter |
| `frontend/lib/features/units/services/unit_service.dart` | Created | Dio calls for unit CRUD |
| `frontend/lib/features/units/providers/unit_provider.dart` | Created | `UnitState` + `UnitNotifier` (Riverpod) |
| `frontend/lib/features/units/screens/units_list_screen.dart` | Created | Admin list view with delete |
| `frontend/lib/features/units/screens/create_unit_screen.dart` | Created | Create unit form |
| `frontend/lib/features/members/services/member_service.dart` | Created | Dio calls for member management |
| `frontend/lib/features/members/providers/member_provider.dart` | Created | `MemberState` + `MemberNotifier` (Riverpod) |
| `frontend/lib/features/members/screens/add_member_screen.dart` | Created | Add member form with role + unit dropdowns |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Modified | Added admin-only tiles for Units + Members |
| `frontend/lib/main.dart` | Modified | Added `/units`, `/units/new`, `/members/new` routes |

---

### Key Design Decisions

- **Unit model is flexible** — `block_name` and `floor_number` are nullable, so it works for towers, row houses, or simple flat numbering
- **COALESCE unique index** — prevents duplicate units even with NULL fields (PostgreSQL treats NULLs as distinct in normal unique constraints)
- **`unit_id` FK uses `SET NULL`** — if a unit is deleted, users become unassigned rather than deleted
- **`is_occupied` auto-managed** — set to true when admin assigns a member, set to false when last resident is removed
- **Admin-only member creation** — public registration still works but forces `MEMBER` role; admin endpoint allows setting any role + unit
- **Admin cannot deactivate themselves** — safeguard in the endpoint

---

### 🚀 Start of Next Session — Pick Up Here

**Before doing anything else:**

1. Start PostgreSQL:
   ```bash
   brew services start postgresql@16
   ```
2. Verify `.env` exists at `backend/.env` (see master plan Step 2 if not).
3. Run migrations (includes new `units` table + `user.unit_id` column):
   ```bash
   cd /Users/masum/Development/Society/backend
   alembic revision --autogenerate -m "add_units_table_and_user_unit_fk"
   alembic upgrade head
   ```
   **Note:** Review the generated migration to ensure the COALESCE unique index is correct. If autogenerate doesn't produce it, manually add:
   ```python
   op.execute("""
       CREATE UNIQUE INDEX uq_unit_identity
       ON units (society_id, COALESCE(block_name, ''), COALESCE(floor_number, ''), unit_number)
   """)
   ```
4. Start the backend server:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```
5. Test the new flow in Swagger:
   - Create society → login as admin → POST /units/ to configure layout → POST /members/ to add residents

**Then continue with:**
> **Phase 5 — Visitor & Security Management (Full-Stack)**

---

### Environment Notes

- Python version: 3.13.5
- Packages installed via `pip install -r requirements.txt --only-binary=:all:`
- No live PostgreSQL running yet — migration verified via `alembic upgrade --sql head` (offline SQL mode)
- IDE linter shows false-positive import errors (linter not pointed at the correct venv)
- To run the app: `uvicorn app.main:app --reload` from `backend/`
- To apply migrations: `alembic upgrade head` (requires running PostgreSQL)
- `flutter analyze` — zero issues

---

---

## Session 4 — 2026-03-15

### What We Did This Session

**Database Migration + Auth Bootstrap Fix + Role Clarification**

Applied all pending Alembic migrations, fixed critical first-admin bootstrap problem, and clarified the role system.

---

### Part 1: Database Migration (units table + user.unit_id)

- Fixed `.env` — `DATABASE_URL` was using `postgres:postgres` credentials but local PostgreSQL runs as `masum` (macOS Homebrew default). Changed to `postgresql://masum@localhost:5432/society_db`.
- Applied all 3 migrations in order:
  1. `55f848de971d` — create societies and users tables
  2. `fe54b529790e` — create complaints table
  3. `2f91e58ce8d9` — add units table + user.unit_id FK
- Fixed autogenerated migration: Alembic tried to drop `uq_users_society_email` unique constraint (the User model was missing `__table_args__`). Added the constraint declaration to the model and removed the erroneous `drop_constraint` from the migration.

### Part 2: First-Admin Bootstrap Fix

**Problem:** After Session 3's bug fix that removed `role` from `UserRegister`, every user created via `POST /auth/register` was hardcoded as `MEMBER`. This created a chicken-and-egg problem — no way to create an admin, and `/members/` requires admin access.

**Fix:** The first user registered in a society automatically becomes `ADMIN`. Subsequent users get `MEMBER`. This is checked via a simple count query in `create_user()`.

### Part 3: Role System Clarification

Confirmed the four roles match the intended permissions:

| Role | Who | Can Do |
|------|-----|--------|
| `ADMIN` | Society admin | Everything |
| `COMMITTEE` | Secretary, Chairman, Treasurer | Create members, manage complaints, create events. Also own units. |
| `MEMBER` | Regular house owner | File complaints, view own data |
| `SUPPORT_STAFF` | Security, cleaners | Log visitors, limited access |

No code changes needed — the existing role hierarchy in `dependencies.py` already handles this correctly.

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/.env` | Modified | Fixed DATABASE_URL to use local macOS user (`masum`) instead of `postgres:postgres` |
| `backend/app/crud/crud_user.py` | Modified | First user in society auto-becomes ADMIN (bootstrap fix) |
| `backend/app/models/user.py` | Modified | Added `__table_args__` with `UniqueConstraint("society_id", "email")` to keep Alembic in sync |
| `backend/migrations/versions/2f91e58ce8d9_add_units_table_and_user_unit_fk.py` | Created | Migration: creates `units` table, adds `unit_id` FK to users, COALESCE unique index |

---

### Verified End-to-End Flow

```
1. POST /auth/society/register → created "Test Society" → got UUID
2. POST /auth/register?society_id=UUID → first user → role = "admin" ✅
3. POST /auth/login → got JWT token ✅
4. POST /members/ with Bearer token → created member successfully ✅
```

---

### 🚀 Start of Next Session — Pick Up Here

**Before doing anything else:**

1. Start PostgreSQL:
   ```bash
   brew services start postgresql@16
   ```
2. Start the backend server:
   ```bash
   cd /Users/masum/Development/Society/backend
   uvicorn app.main:app --reload --port 8000
   ```
3. All migrations are applied. Database is ready.

**Then continue with:**
> **Phase 5 — Visitor & Security Management (Full-Stack)**

---

### Environment Notes

- PostgreSQL 16 installed via Homebrew, running on localhost:5432
- Database `society_db` created and all 3 migrations applied
- `.env` uses `postgresql://masum@localhost:5432/society_db` (no password, trust auth)
- Server verified: health check, society registration, user registration (auto-admin), login, member creation all working
- `flutter analyze` — zero issues
