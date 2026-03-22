<h1 align="center">Society Management App — Session Log</h1>

<p align="center">
  <strong>Full development history across all sessions. Updated whenever files are added, modified, or removed.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square" alt="FastAPI">
  <img src="https://img.shields.io/badge/Web-Next.js_16-000000?style=flat-square" alt="Next.js">
  <img src="https://img.shields.io/badge/Mobile-Flutter-02569B?style=flat-square" alt="Flutter">
  <img src="https://img.shields.io/badge/DB-PostgreSQL_16-4169E1?style=flat-square" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Phase-9B_of_13-blueviolet?style=flat-square" alt="Progress">
</p>

---

## Phase Progress

| Phase | Description | Session | Status |
|:-----:|-------------|:-------:|:------:|
| 1 | Database & Core Setup | 1 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 2 | Authentication & Multi-Tenancy | 1 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 3 | Flutter App Foundation | 1 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 4 | Complaint Management (Full-Stack) | 1 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 4.5 | Unit Model, Member Management, Bug Fixes | 3–4 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 5 | Invite-Based Auth System | 5 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 6 | Admin Web Portal (Next.js) | 5 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 7 | Flutter Mobile Redesign (Invite Auth) | 5 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 8 | Visitor & Security Management | 6 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 8.5 | Bulk Excel/CSV Import (Web Portal) | 7 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| — | Bug Fixes & Delete Features | 8 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 9A | Notice Board / Announcements | 9 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 9A+ | Notice Images + Mobile Management | 10 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 9B | Complaint Comments / Replies | 11 | ![done](https://img.shields.io/badge/-Done-success?style=flat-square) |
| 9C–F | Profiles, Directory, Activity Feed, Search | — | ![next](https://img.shields.io/badge/-Next-blue?style=flat-square) |
| 10 | Facility Booking & Polling | — | ![pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) |
| 11 | Push Notifications, SMS & WhatsApp | — | ![pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) |
| 12 | Maintenance & Payments | — | ![pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) |
| 13 | Security Hardening & Production Readiness | — | ![pending](https://img.shields.io/badge/-Pending-lightgrey?style=flat-square) |

---

## Session Index

<details>
<summary><strong>Session 1 — 2026-03-14</strong> &nbsp; <em>Phases 1–4 (Foundation → Complaints)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 1: Database & Core Setup](#phase-completed-phase-1--database--core-setup-backend) | Models, migrations, FastAPI bootstrap |
| [Phase 2: Auth & Multi-Tenancy](#session-1-continued--phase-2-authentication--multi-tenancy) | JWT, RBAC, login/register endpoints |
| [Bug Fix: Circular Import](#bug-fix-circular-import-discovered-during-startup-check) | `db/base.py` → `db/base_class.py` split |
| [Phase 3: Flutter App Foundation](#session-1-continued--phase-3-flutter-app-foundation) | Theme, networking, auth screens |
| [Phase 4: Complaint Management](#session-1-continued--phase-4-complaint-management-full-stack) | Complaint model, API, Flutter UI |
| [Deferred: Society Registration UI](#session-1--deferred-discussion-society-registration-ui) | Option A vs B discussion |

</details>

<details>
<summary><strong>Session 2 — 2026-03-15</strong> &nbsp; <em>Master Plan Updates</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Master Plan Updates](#session-2--2026-03-15) | Setup guide, login walkthrough, progress table |

</details>

<details>
<summary><strong>Session 3 — 2026-03-15</strong> &nbsp; <em>Phase 4.5 (Audit + Units + Members)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Part 1: Bug Fixes (audit)](#part-1-bug-fixes-from-audit) | Role escalation, pagination, SSRF, async interceptor |
| [Part 2: Unit Model](#part-2-unit-model--society-layout-structure) | Flexible block/floor/unit with COALESCE index |
| [Part 3: Backend Endpoints](#part-3-new-backend-endpoints) | Unit CRUD + member management APIs |
| [Part 4: Frontend (Flutter)](#part-4-frontend-flutter) | Unit & member screens, dashboard tiles |

</details>

<details>
<summary><strong>Session 4 — 2026-03-15</strong> &nbsp; <em>Migration + Bootstrap Fix</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Part 1: Database Migration](#part-1-database-migration-units-table--userunit_id) | `.env` fix, 3 migrations applied |
| [Part 2: First-Admin Bootstrap Fix](#part-2-first-admin-bootstrap-fix) | First user auto-becomes ADMIN |
| [Part 3: Role System Clarification](#part-3-role-system-clarification) | Admin / committee / member / support_staff permissions |

</details>

<details>
<summary><strong>Session 5 — 2026-03-18</strong> &nbsp; <em>Phases 5–7 (Redesign + Invite Auth + Web Portal + Mobile)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Part 1: Society ID → 5-Letter Code](#part-1-society-id--uuid--5-letter-code) | UUID replaced with short codes |
| [Part 2: Architecture Redesign](#part-2-architecture-redesign-decision) | Split into web portal + mobile app |
| [Part 3: Auth Flow Redesign](#part-3-auth-flow-redesign-decision) | Invite-based registration |
| [Part 4: Master Plan Updated](#part-4-master-plan-updated) | Restructured phases |
| [Part 5: Phase 5 — Invite Auth](#part-5-phase-5-built--invite-based-auth-system) | Invite tokens, activation, email lookup |
| [Part 6: Phase 6 — Admin Web Portal](#part-6-phase-6-built--admin-web-portal-nextjs) | Next.js 16, all admin pages |
| [Phase 7: Flutter Mobile Redesign](#phase-7-complete--flutter-mobile-redesign-invite-based-auth) | Activate screen, removed self-registration |

</details>

<details>
<summary><strong>Session 6 — 2026-03-18</strong> &nbsp; <em>Phase 8 (Visitor & Security Management)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 8: Visitor & Security Management](#phase-8-complete--visitor--security-management-full-stack) | Visitor model, web + mobile UI, gate dashboard |

</details>

<details>
<summary><strong>Session 7 — 2026-03-19</strong> &nbsp; <em>Phase 8.5 (Bulk Import)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 8.5: Bulk Excel/CSV Import](#phase-85-complete--bulk-excelcsv-import-backend--web-portal) | Upload endpoints, web import panels, templates |

</details>

<details>
<summary><strong>Session 8 — 2026-03-19</strong> &nbsp; <em>Bug Fixes + Delete Features + Plan Restructure</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Bug 1: Complaints Not Posting from Mobile](#bug-1-complaints-not-posting-from-mobile-app) | Async interceptor return type |
| [Bug 2: Visitor Check-Out Not Visible](#bug-2-visitor-check-out-not-visible-on-staff-dashboard) | Added "Checked Out" tab |
| [Bug 3: Dashboard Not Showing Complaints](#bug-3-dashboard-not-showing-complaints--admin-cant-update-complaint-status) | `society_id` type mismatch |
| [Bug 4: Images in Complaints](#bug-4-images-in-complaints--deferred) | Deferred |
| [Bug 5: Walk-In Visitors Not Showing](#bug-5-walk-in-visitors-cab-delivery-not-showing-on-staff-dashboard) | Auto-check-in walk-ins |
| [Bug 6: Dashboard Showing All Zeros](#bug-6-dashboard-showing-all-zeros) | Limit cap + resilient `Promise.all` |
| [Feature: Delete Buttons](#feature-delete-buttons-for-visitors-and-complaints) | Delete visitors + complaints (web + mobile) |
| [Feature: Committee Complaints on Mobile](#feature-committee-complaint-management-on-mobile-app) | Status dropdown + delete for committee |
| [Master Plan Restructured](#master-plan-restructured) | Reordered phases 9–13 |

</details>

<details>
<summary><strong>Session 9 — 2026-03-22</strong> &nbsp; <em>Phase 9A (Notice Board) + Housekeeping</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 9A: Notice Board](#phase-9a-complete--notice-board--announcements-full-stack) | Notice model, API, web portal pages, mobile screen |
| [Housekeeping](#part-4-housekeeping) | `rules.md` → `CLAUDE.md`, restyled SESSION_LOG + CLAUDE.md |
| [Login Bug Fix](#login-bug-fix-passlib--bcrypt-500-incompatibility) | Replaced passlib with direct bcrypt (Python 3.13 fix) |

</details>

<details>
<summary><strong>Session 10 — 2026-03-22</strong> &nbsp; <em>Phase 9A+ (Notice Images + Mobile Notice Management)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 9A+: Notice Images + Mobile Management](#phase-9a-enhancement--notice-images--mobile-notice-management) | Image upload, committee create/delete on mobile, image display |

</details>

<details>
<summary><strong>Session 11 — 2026-03-22</strong> &nbsp; <em>Phase 9B (Complaint Comments / Replies)</em></summary>
<br>

| Section | What Changed |
|---------|-------------|
| [Phase 9B: Complaint Comments](#phase-9b-complete--complaint-comments--replies) | Comment model, API endpoints, web portal comment thread, Flutter detail screen with comments |

</details>

---

## Session 1 — 2026-03-14

### Phase Completed: Phase 1 — Database & Core Setup (Backend)

**Objective:** Establish the FastAPI backend foundation and PostgreSQL database layer.

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `CLAUDE.md` | Read | Core rules & security principles governing the entire app (renamed from `rules.md`) |
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
- **`society_id` FK on every `User`** — enforces multi-tenant data isolation per `CLAUDE.md`
- **`UNIQUE(society_id, email)`** — same email can join different societies (not globally unique)
- **`UserRole` enum** maps directly to `CLAUDE.md` roles: `admin`, `committee`, `support_staff`, `member`
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

---

---

## Session 5 — 2026-03-18

### What We Did This Session

**Society ID Shortening + Architecture & Auth Flow Redesign**

Two major changes this session: replaced the long UUID society IDs with short 5-letter codes, and redesigned the overall product architecture and auth flow based on real-world SaaS patterns.

---

### Part 1: Society ID — UUID → 5-Letter Code

**Problem:** Society IDs were UUIDs like `a1b2c3d4-e5f6-7890-abcd-ef1234567890` — too long and unwieldy for users to type or share.

**Fix:** Society ID is now a random 5-uppercase-letter code (e.g. `MKQWZ`), generated on society registration with a uniqueness check.

**Files changed (backend):**

| File | Action | Description |
|------|--------|-------------|
| `backend/app/models/society.py` | Modified | `id` column: `UUID` → `String(5)` |
| `backend/app/models/user.py` | Modified | `society_id` FK: `UUID` → `String(5)` |
| `backend/app/models/unit.py` | Modified | `society_id` FK: `UUID` → `String(5)` |
| `backend/app/models/complaint.py` | Modified | `society_id` FK: `UUID` → `String(5)` |
| `backend/app/schemas/society.py` | Modified | `SocietyResponse.id`: `uuid.UUID` → `str` |
| `backend/app/schemas/user.py` | Modified | `UserResponse.society_id`: `uuid.UUID` → `str` |
| `backend/app/schemas/unit.py` | Modified | `UnitResponse.society_id`: `uuid.UUID` → `str` |
| `backend/app/crud/crud_society.py` | Modified | Added `_generate_society_code()` — random 5-letter code with DB uniqueness check. Changed type hints. |
| `backend/app/crud/crud_user.py` | Modified | All `society_id: uuid.UUID` → `society_id: str` |
| `backend/app/crud/crud_unit.py` | Modified | All `society_id: uuid.UUID` → `society_id: str` |
| `backend/app/crud/crud_complaint.py` | Modified | All `society_id: uuid.UUID` → `society_id: str` |
| `backend/app/api/v1/endpoints/auth.py` | Modified | `society_id` query param now validated as `^[A-Z]{5}$` via `Query()` |
| `backend/app/api/dependencies.py` | Modified | Removed `uuid.UUID(society_id)` cast — society_id is now a plain string |
| `backend/migrations/versions/3c7a1f9e0b44_society_id_to_5char_code.py` | Created | Migration: truncates all data, alters `societies.id` and all FK columns from UUID to VARCHAR(5) |

**Note:** Migration truncated all existing test data. Re-register test societies after applying.

---

### Part 2: Architecture Redesign Decision

**Problem:** The current setup has one Flutter app for everyone (admin + resident), and a confusing public self-registration flow where residents need to know the society code.

**Decision:** Split into two frontends:

| Frontend | Users | Purpose |
|----------|-------|---------|
| **Admin Web Portal** (React/Next.js) | Admin, Committee | Society setup, unit management, member invites, complaint oversight, billing, reports |
| **Mobile App** (Flutter) | Residents, Support Staff | Activate via invite, file complaints, approve visitors, pay bills, book amenities |

**Reasoning:**
- Admin does heavy setup tasks (bulk units, member management) — better on desktop/web
- Residents do quick daily tasks — better on mobile
- This is the proven model used by Mygate, NoBroker Society, ADDA

---

### Part 3: Auth Flow Redesign Decision

**Old flow (confusing):**
```
Register society → share UUID → anyone self-registers → first user = admin
```

**New flow (invite-based, to be implemented in Phase 5):**
```
1. Admin registers society → gets 5-letter code
2. Admin logs into web portal
3. Admin adds members → system generates invite token per member
4. Resident receives invite (SMS/WhatsApp/email)
5. Resident opens mobile app → enters invite token → sets password → activated
6. Resident logs in with email + password (no society code needed)
```

**Key principle:** Residents never need to know the society code. Admin controls who joins.

---

### Part 4: Master Plan Updated

Restructured `claude_master_plan.txt` with:
- New architecture overview (two frontends, one backend)
- Updated auth flow documentation
- Updated setup guide (5-letter society code, correct DATABASE_URL)
- Reorganised remaining phases:
  - Phase 5: Auth Redesign (invite-based registration) — **NEXT**
  - Phase 6: Admin Web Portal (React/Next.js)
  - Phase 7: Mobile App Redesign (invite activation)
  - Phase 8: Visitor & Security Management
  - Phase 9: Maintenance & Payments
  - Phase 10: Facility Booking & Polling
  - Phase 11: Push Notifications

---

---

### Part 5: Phase 5 Built — Invite-Based Auth System

Replaced public self-registration with admin-controlled invite flow.

#### New Auth Flow:
```
1. POST /auth/society/register → admin gets 5-letter code (unchanged)
2. POST /auth/register → bootstrap-only: first user becomes ADMIN (unchanged)
3. POST /members/ → admin creates member → gets invite_token in response (NEW)
4. POST /auth/activate → resident sends invite_token + password → activated + JWT (NEW)
5. POST /auth/lookup → resident sends email → gets list of societies they belong to (NEW)
6. POST /members/{id}/reinvite → admin regenerates expired invite token (NEW)
```

#### Multi-Society User Support:
A person can belong to multiple societies with the same email. The lookup endpoint returns all societies for that email. Mobile app uses this to show a society picker when there are multiple matches.

#### Model Changes:
- `users.is_activated` — Boolean, default True (self-registered admin = true, admin-created member = false)
- `users.invite_token` — unique, URL-safe 22-char string, set on member creation, cleared on activation
- `users.invite_expires_at` — 7 days from creation, checked during activation

#### Key Design Decisions:
- **`hashed_password = "!"`** for unactivated users — can never match a bcrypt hash, so login always fails until activation
- **`is_activated` checked in `authenticate_user()`** — unactivated users can't login even if they guess a password
- **Invite tokens expire after 7 days** — admin can regenerate via `/members/{id}/reinvite`
- **`POST /auth/lookup` always returns 200** — even for unknown emails (returns empty list), to avoid email enumeration
- **`AdminCreateUser` no longer takes `password`** — admin sets name, email, role, unit only; resident sets their own password during activation

#### Files Created / Modified:

| File | Action | Description |
|------|--------|-------------|
| `backend/app/models/user.py` | Modified | Added `is_activated`, `invite_token`, `invite_expires_at` columns |
| `backend/app/schemas/user.py` | Modified | Added `ActivateAccount`, `EmailLookup`, `MemberInviteResponse`, `SocietyLookupItem`, `SocietyLookupResponse`; removed `password` from `AdminCreateUser`; added `is_activated` to `UserResponse` |
| `backend/app/schemas/__init__.py` | Modified | Exported new schemas |
| `backend/app/crud/crud_user.py` | Modified | Added `get_user_by_invite_token()`, `get_societies_for_email()`, `activate_user()`, `regenerate_invite_token()`; updated `create_user_admin()` to generate invite token instead of requiring password; `authenticate_user()` now checks `is_activated` |
| `backend/app/crud/__init__.py` | Modified | Exported new CRUD functions |
| `backend/app/api/v1/endpoints/auth.py` | Modified | Added `POST /auth/activate` and `POST /auth/lookup`; updated docstrings |
| `backend/app/api/v1/endpoints/members.py` | Modified | `POST /members/` now returns `MemberInviteResponse` with invite token; added `POST /members/{id}/reinvite` |
| `backend/migrations/versions/5d8e2a1f7c03_add_invite_fields_to_users.py` | Created | Adds `is_activated`, `invite_token`, `invite_expires_at` to users table |

---

---

### Part 6: Phase 6 Built — Admin Web Portal (Next.js)

Built the full admin web portal using Next.js 16 + Tailwind CSS 4 + App Router.

**Tech Stack:** Next.js 16.2.0, React 19, TypeScript, Tailwind CSS v4

#### Project Structure:
```
web/
  src/
    lib/
      types.ts          — shared TypeScript interfaces
      api.ts            — fetch wrapper with JWT auth for all backend endpoints
      auth-context.tsx   — React context for login/logout/auth state
    components/
      sidebar.tsx        — navigation sidebar (Dashboard, Units, Members, Complaints)
      auth-guard.tsx     — redirect to /login if not authenticated
    app/
      layout.tsx         — root layout with AuthProvider
      page.tsx           — redirects to /dashboard or /login
      login/page.tsx     — admin login (society code + email + password)
      (admin)/
        layout.tsx       — shared sidebar layout for all admin pages
        dashboard/page.tsx  — stats cards (units, members, complaints)
        units/page.tsx      — table view with delete
        units/new/page.tsx  — bulk unit creation form (add rows dynamically)
        members/page.tsx    — table with role badges, invite status, reinvite/deactivate
        members/new/page.tsx — create member form → shows invite token on success
        complaints/page.tsx  — card list with status filters + status dropdown to update
```

#### Pages Built:
| Page | Route | Features |
|------|-------|----------|
| Login | `/login` | Society code (5-letter), email, password |
| Dashboard | `/dashboard` | Stat cards: total units, occupied, members, open complaints |
| Units | `/units` | Table with block/floor/unit/type/area/status, delete button |
| Add Units | `/units/new` | Dynamic row form, bulk create support |
| Members | `/members` | Table with role badges, activation status, reinvite & deactivate actions |
| Add Member | `/members/new` | Form with role dropdown + unit dropdown → shows invite token |
| Complaints | `/complaints` | Card list with category/status badges, filter tabs, status update dropdown |

#### Key Design Decisions:
- **Route group `(admin)/`** — all authenticated pages share the sidebar layout
- **JWT stored in localStorage** — simple for dev; production should use httpOnly cookies
- **API client** — thin fetch wrapper in `api.ts`, auto-attaches Bearer token
- **AuthGuard component** — redirects to `/login` if no token found
- **`npm run build` — zero errors**

#### Files Created:

| File | Description |
|------|-------------|
| `web/` (entire directory) | Next.js 16 project with TypeScript + Tailwind v4 |
| `web/src/lib/types.ts` | TypeScript interfaces for all backend models |
| `web/src/lib/api.ts` | API client with all backend endpoint calls |
| `web/src/lib/auth-context.tsx` | React auth context (login, logout, persist to localStorage) |
| `web/src/components/sidebar.tsx` | Sidebar navigation with SVG icons |
| `web/src/components/auth-guard.tsx` | Auth redirect guard |
| `web/src/app/layout.tsx` | Root layout with AuthProvider |
| `web/src/app/page.tsx` | Root redirect |
| `web/src/app/login/page.tsx` | Admin login page |
| `web/src/app/(admin)/layout.tsx` | Shared sidebar layout |
| `web/src/app/(admin)/dashboard/page.tsx` | Dashboard stats |
| `web/src/app/(admin)/units/page.tsx` | Units table |
| `web/src/app/(admin)/units/new/page.tsx` | Bulk unit creation form |
| `web/src/app/(admin)/members/page.tsx` | Members table with actions |
| `web/src/app/(admin)/members/new/page.tsx` | Add member form |
| `web/src/app/(admin)/complaints/page.tsx` | Complaints list with filters |

---

### Phase 7 Complete — Flutter Mobile Redesign (Invite-Based Auth)

Finished the remaining Phase 7 work: activate screen, removed self-registration, cleaned up dashboard and routes.

#### What was completed (Session 5 — earlier):
- `frontend/lib/core/constants/api_constants.dart` — updated: removed `societyRegister`/`userRegister`, added `activate`/`lookup` endpoints
- `frontend/lib/shared/models/user_model.dart` — updated: added `isActivated` field
- `frontend/lib/features/auth/services/auth_service.dart` — rewritten: added `lookupSocieties()`, `activate()`, removed `register()`
- `frontend/lib/features/auth/providers/auth_provider.dart` — rewritten: added `lookupSocieties()`, `activate()`, removed `register()`
- `frontend/lib/features/auth/screens/login_screen.dart` — rewritten: 3-step flow (email → society picker → password)

#### What was completed (Session 6):

| File | Action | Description |
|------|--------|-------------|
| `frontend/lib/features/auth/screens/activate_screen.dart` | Created | Email + invite token + set password + confirm → auto-login on success |
| `frontend/lib/features/auth/screens/register_screen.dart` | Deleted | Self-registration removed — residents activate via invite only |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Modified | Admin/committee see management tiles (Units, Members, Events placeholder); updated coming-soon phase numbers (8, 9, 10) |
| `frontend/lib/main.dart` | Modified | Removed `/register` route; added `/activate` route; restored `/units`, `/units/new`, `/members/new` routes for admin/committee mobile access |
| `backend/app/schemas/user.py` | Modified | Added `email` field to `ActivateAccount` schema |
| `backend/app/api/v1/endpoints/auth.py` | Modified | Activate endpoint now verifies email matches the invite token's user |
| `frontend/lib/features/auth/services/auth_service.dart` | Modified | `activate()` now sends email along with token and password |
| `frontend/lib/features/auth/providers/auth_provider.dart` | Modified | `activate()` now requires email parameter |

#### Key Design Decisions:
- **Activate screen collects email** — user enters their email during activation so they know their login credentials; backend verifies email matches the invite token for security
- **Admin/committee management on mobile** — Units and Members tiles shown for admin/committee roles; "Events & Scheduling" tile added as coming-soon placeholder
- **Routes restored** — `/units`, `/units/new`, `/members/new` added back for admin/committee mobile use
- **`flutter analyze` — zero issues**

---

### 🚀 Start of Next Session — Pick Up Here

**Phase 7 is COMPLETE. All phases through 7 are done.**

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
3. Start the admin web portal:
   ```bash
   cd /Users/masum/Development/Society/web
   npm run dev
   ```
   Opens at http://localhost:3000
4. All 5 migrations are applied. Database is ready but empty.

**Then continue with:**
> **Phase 9 — Maintenance & Payments (Full-Stack)**

---

### Environment Notes

- PostgreSQL 16 installed via Homebrew, running on localhost:5432
- Database `society_db` — all 6 migrations applied, data empty (need to re-register test data)
- `.env` uses `postgresql://masum@localhost:5432/society_db` (no password, trust auth)
- Society IDs are now 5-letter uppercase codes (e.g. `MKQWZ`)
- Backend: `uvicorn app.main:app --reload --port 8000` from `backend/`
- Web portal: `npm run dev` from `web/` → http://localhost:3000
- `npm run build` — zero errors
- `flutter analyze` — zero issues

---

---

## Session 6 (continued) — 2026-03-18

### Phase 8 Complete — Visitor & Security Management (Full-Stack)

Built the complete visitor management system across backend, web portal, and mobile app.

---

### Part 1: Backend — VisitorLog Model & API

#### Database Model: `visitor_logs`

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| society_id | String(5) FK | Multi-tenant isolation |
| unit_id | UUID FK | Which unit the visitor is visiting (nullable) |
| resident_id | UUID FK | Which resident (nullable) |
| visitor_name | String(200) | Required |
| visitor_phone | String(20) | Nullable |
| visitor_count | Integer | Default 1 |
| purpose | Enum | guest, delivery, cab, service, other |
| vehicle_number | String(20) | Nullable |
| notes | Text | Nullable |
| status | Enum | pre_approved, pending, approved, denied, checked_in, checked_out |
| pre_approved_by_id | UUID FK | Nullable — resident who pre-approved |
| checked_in_by_id | UUID FK | Nullable — staff who checked in |
| expected_at | DateTime | Nullable — when visitor is expected |
| checked_in_at | DateTime | Nullable |
| checked_out_at | DateTime | Nullable |
| created_at, updated_at | DateTime | Auto-managed |

#### API Endpoints

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| POST | `/api/v1/visitors/pre-approve` | Any authenticated | Resident pre-approves a visitor |
| POST | `/api/v1/visitors/log-entry` | Support Staff+ | Staff logs visitor arrival (PENDING status) |
| GET | `/api/v1/visitors/` | Any authenticated | List visitors (RBAC: member sees own, staff/admin sees all) |
| GET | `/api/v1/visitors/pending` | Any authenticated | Get visitors pending this resident's approval |
| GET | `/api/v1/visitors/pre-approved` | Support Staff+ | All active pre-approvals |
| GET | `/api/v1/visitors/{id}` | Any authenticated | Get single visitor detail |
| PATCH | `/api/v1/visitors/{id}/approve` | Any authenticated | Resident approves pending visitor |
| PATCH | `/api/v1/visitors/{id}/deny` | Any authenticated | Resident denies pending visitor |
| PATCH | `/api/v1/visitors/{id}/check-in` | Support Staff+ | Check in pre-approved/approved visitor |
| PATCH | `/api/v1/visitors/{id}/check-out` | Support Staff+ | Log visitor departure |

#### Visitor Flow:
```
1. Resident pre-approves visitor → status: PRE_APPROVED
2. Visitor arrives → staff checks in → status: CHECKED_IN
3. Visitor leaves → staff checks out → status: CHECKED_OUT

OR (walk-in without pre-approval):
1. Visitor arrives → staff logs entry → status: PENDING
2. Resident approves → status: APPROVED → staff checks in → CHECKED_IN
   OR Resident denies → status: DENIED
```

---

### Part 2: Admin Web Portal

| Page | Route | Features |
|------|-------|----------|
| Dashboard | `/dashboard` | Added "Visitors Inside" and "Pending Approvals" stat cards |
| Visitors | `/visitors` | Full table with status/purpose badges, filter tabs, check-in/check-out actions |
| Sidebar | — | Added "Visitors" nav item with shield icon |

---

### Part 3: Flutter Mobile App

**Screens built:**

| Screen | Route | For | Features |
|--------|-------|-----|----------|
| Visitors List | `/visitors` | Resident | View all visitors with status badges, pull-to-refresh, pending notification badge |
| Pre-approve | `/visitors/pre-approve` | Resident | Form: name, phone, purpose, count, vehicle, notes |
| Pending Approvals | `/visitors/pending` | Resident | Approve/deny visitor cards |
| Gate Dashboard | `/visitors/gate` | Support Staff | Tabbed view: "Inside" + "Pre-approved" with check-in/check-out buttons |
| Log Entry | `/visitors/log-entry` | Support Staff | Form to log walk-in visitor arrival |

**Dashboard updated:**
- **Residents/Admin/Committee** → "Visitors" tile (links to visitors list)
- **Support Staff** → "Gate Dashboard" tile (links to gate dashboard)

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/app/models/visitor.py` | Created | `VisitorLog` model, `VisitPurpose` + `VisitStatus` enums |
| `backend/app/models/__init__.py` | Modified | Exported `VisitorLog`, `VisitPurpose`, `VisitStatus` |
| `backend/app/db/base.py` | Modified | Registered `VisitorLog` for Alembic |
| `backend/migrations/versions/2bf19aeb2704_create_visitor_logs_table.py` | Created | Migration: creates `visitor_logs` table with indexes |
| `backend/app/schemas/visitor.py` | Created | `VisitorPreApprove`, `VisitorLogEntry`, `VisitorStatusUpdate`, `VisitorResponse` |
| `backend/app/schemas/__init__.py` | Modified | Exported visitor schemas |
| `backend/app/crud/crud_visitor.py` | Created | Full CRUD: create, list, approve, deny, check-in, check-out |
| `backend/app/crud/__init__.py` | Modified | Exported visitor CRUD functions |
| `backend/app/api/v1/endpoints/visitors.py` | Created | 10 endpoints for full visitor lifecycle |
| `backend/app/api/v1/__init__.py` | Modified | Mounted visitors router |
| `web/src/lib/types.ts` | Modified | Added `VisitorLog`, `VisitPurpose`, `VisitStatus` interfaces |
| `web/src/lib/api.ts` | Modified | Added visitor API methods |
| `web/src/components/sidebar.tsx` | Modified | Added "Visitors" nav item |
| `web/src/app/(admin)/visitors/page.tsx` | Created | Visitor log table with filters + actions |
| `web/src/app/(admin)/dashboard/page.tsx` | Modified | Added visitor stat cards |
| `frontend/lib/core/constants/api_constants.dart` | Modified | Added visitor endpoint paths |
| `frontend/lib/shared/models/visitor_model.dart` | Created | `VisitorModel` with status helpers |
| `frontend/lib/features/visitors/services/visitor_service.dart` | Created | Dio calls for all visitor endpoints |
| `frontend/lib/features/visitors/providers/visitor_provider.dart` | Created | `VisitorState` + `VisitorNotifier` (Riverpod) |
| `frontend/lib/features/visitors/screens/visitors_list_screen.dart` | Created | Visitor list with status badges + pending badge |
| `frontend/lib/features/visitors/screens/pre_approve_screen.dart` | Created | Pre-approve form |
| `frontend/lib/features/visitors/screens/pending_approvals_screen.dart` | Created | Approve/deny pending visitors |
| `frontend/lib/features/visitors/screens/staff_dashboard_screen.dart` | Created | Gate dashboard: Inside + Pre-approved tabs |
| `frontend/lib/features/visitors/screens/log_entry_screen.dart` | Created | Staff log entry form |
| `frontend/lib/main.dart` | Modified | Added 5 visitor routes |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Modified | Visitor tile live; support staff gets Gate Dashboard tile |

---

### Key Design Decisions

- **RBAC on list endpoint**: Members see only their own visitors; staff/admin/committee see all
- **Status machine**: `pre_approved → checked_in → checked_out` or `pending → approved → checked_in → checked_out`
- **Support staff gate dashboard**: Tabbed view optimized for quick check-in/check-out at the gate
- **Residents never need to interact with support staff flow** — they pre-approve and the system handles the rest
- **`flutter analyze` — zero issues**
- **`npm run build` — zero errors**

---

---

## Session 7 — 2026-03-19

### Phase 8.5 Complete — Bulk Excel/CSV Import (Backend + Web Portal)

Built bulk import for units and members via Excel (.xlsx) or CSV file upload. Web portal only — mobile import was intentionally excluded (bulk spreadsheet import is a desktop task, not mobile).

---

### Part 1: Backend — Import Endpoints

#### New Endpoints

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| POST | `/api/v1/units/import` | Admin | Upload .xlsx/.csv → bulk create units (max 500 rows) |
| GET | `/api/v1/units/import/template` | Public | Download CSV template with sample rows |
| POST | `/api/v1/members/import` | Admin | Upload .xlsx/.csv → bulk create members with invite tokens (max 500 rows) |
| GET | `/api/v1/members/import/template` | Public | Download CSV template with sample rows |

#### Unit Import Columns
- `unit_number` (required), `block_name`, `floor_number`, `unit_type`, `area_sqft`

#### Member Import Columns
- `full_name`, `email` (required), `role` (default: member), `unit_number` (matches existing unit)

#### Key Design Decisions
- **Row-level error handling** — each row validated individually; valid rows are created, invalid rows reported with specific error messages
- **No all-or-nothing transaction** — partial imports succeed with error report (better UX for large files)
- **Duplicate detection** — unit imports catch unique constraint violations; member imports check email uniqueness before creating
- **Unit matching for members** — pre-loads all society units into a map, matches by `unit_number` (with optional `block_name|unit_number` compound key)
- **File format validation** — only `.xlsx` and `.csv` accepted; rejects other formats with clear error
- **`openpyxl`** added to `requirements.txt` for Excel parsing

---

### Part 2: Admin Web Portal

#### Units Page (`/units`)
- New "Import from File" button (outline style, next to "+ Add Units")
- Expandable import panel: file picker (.xlsx/.csv), "Upload & Import" button, "Download template" link
- Result display: green panel on success, yellow panel with row-level errors listed

#### Members Page (`/members`)
- Same "Import from File" button and expandable panel
- Result display includes a table of created members with their invite tokens + copy buttons
- Row-level errors shown below the success table

#### API Client (`api.ts`)
- Added `uploadFile<T>()` helper for multipart form-data uploads (separate from JSON `request()`)
- Added `api.importUnits(file)` and `api.importMembers(file)` methods

---

### Part 3: Decision — No Mobile Import

User decided bulk Excel/CSV import should only be on the web portal — not on mobile. Reasoning: admins do bulk data entry on desktop, not from a phone. Mobile admin features (units, members) remain for individual add/edit only.

---

### Part 4: Bug Fix — Excel Cell Type Handling

Initial import had parsing bugs: openpyxl returns raw Python types (int, float, None) from cells, not strings. This caused `'int' object has no attribute` errors.

**Fix:** Added `_cell_to_str()` helper that safely converts any cell value to a stripped string. All rows are now pre-processed through this before field-level parsing. Empty rows at the end of spreadsheets are automatically skipped.

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `backend/requirements.txt` | Modified | Added `openpyxl>=3.1.0` |
| `backend/app/api/v1/endpoints/units.py` | Modified | Added `POST /import`, `GET /import/template` endpoints; fixed cell type handling |
| `backend/app/api/v1/endpoints/members.py` | Modified | Added `POST /import`, `GET /import/template` endpoints; fixed cell type handling |
| `web/src/lib/api.ts` | Modified | Added `uploadFile()` helper, `importUnits()`, `importMembers()` methods |
| `web/src/app/(admin)/units/page.tsx` | Modified | Added import panel with file picker, results display |
| `web/src/app/(admin)/members/page.tsx` | Modified | Added import panel with file picker, invite token table |
| `claude_master_plan.txt` | Modified | Updated Phase 8.5 done; removed mobile import section |

---

### Planned Enhancement: Auto-Send Invite Tokens via SMS/WhatsApp

**Deferred to Phase 11 (Push Notifications).**

Idea: when admin bulk-imports members, invite tokens should be auto-sent to each member's phone via WhatsApp or SMS (Twilio). Requires adding `phone_number` to User model and member import. This avoids manually sharing tokens one by one.

---

## Session 5 — 2026-03-19

### Bug Fixes — Pre-Phase 9

Fixed four bugs reported by user before starting Phase 9 work.

---

### Bug 1: Complaints Not Posting from Mobile App

**Root Cause:** Two issues compounding:

1. **Auth interceptor race condition** — `_AuthInterceptor.onRequest()` was declared `async` with a `void` return type. The caller couldn't await it, so requests were sent before the auth token was read from secure storage. Result: 401 Unauthorized on every protected endpoint.
2. **Complaint schema type mismatch** (see Bug 3 below) — even if auth succeeded, the response would fail serialization.

**Fix:** Changed return type from `void` to `Future<void>` in the interceptor's `onRequest` method.

**File:** `frontend/lib/core/network/api_client.dart` (line 47)

---

### Bug 2: Visitor Check-Out Not Visible on Staff Dashboard

**Root Cause:** The backend check-out endpoint worked correctly (`PATCH /api/v1/visitors/{id}/check-out`), and the Flutter service/provider code called it properly. However, the staff dashboard only had two tabs: "Inside" (checked_in) and "Pre-approved". After a visitor was checked out, their status changed to `checked_out` and they disappeared from both tabs — no visual confirmation.

**Fix:**
- Added `isCheckedOut` getter to `VisitorModel`
- Added a third "Checked Out" tab to the staff dashboard showing exited visitors with their departure time

**Files:**
| File | Change |
|------|--------|
| `frontend/lib/shared/models/visitor_model.dart` | Added `isCheckedOut` getter |
| `frontend/lib/features/visitors/screens/staff_dashboard_screen.dart` | Added third tab, `_buildCheckedOutList()` method, `_formatTime()` helper |

---

### Bug 3: Dashboard Not Showing Complaints + Admin Can't Update Complaint Status

**Root Cause:** `ComplaintResponse` schema defined `society_id` as `uuid.UUID`, but the actual model stores it as `String(5)` (the 5-letter society code). Pydantic failed to serialize the response on every complaint endpoint — listing, creating, and status updates all returned 500 errors.

**Fix:** Changed `society_id: uuid.UUID` to `society_id: str` in the response schema.

**File:** `backend/app/schemas/complaint.py` (line 52)

---

### Bug 4: Images in Complaints — Deferred

User acknowledged image upload can be addressed later. No changes made.

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `frontend/lib/core/network/api_client.dart` | Modified | Fixed async interceptor: `void` → `Future<void>` return type |
| `frontend/lib/shared/models/visitor_model.dart` | Modified | Added `isCheckedOut` getter |
| `frontend/lib/features/visitors/screens/staff_dashboard_screen.dart` | Modified | Added "Checked Out" tab with exit time display |
| `backend/app/schemas/complaint.py` | Modified | Fixed `society_id` type: `uuid.UUID` → `str` |

---

### Bug 5: Walk-In Visitors (Cab, Delivery) Not Showing on Staff Dashboard

**Root Cause:** `create_log_entry()` always set status to `PENDING`, even for walk-in visitors with no `resident_id`. Since there's no resident to approve them, they were stuck in `PENDING` forever — invisible on the "Inside" tab, impossible to check out.

This also caused the admin dashboard's "Visitors Inside" counter to stay at 0.

**Fix (2 parts):**

1. **Auto-check-in walk-ins** — In `create_log_entry()`, if no `resident_id` and no `unit_id` are provided (walk-in visitor), status is set to `CHECKED_IN` directly. Visitors assigned to a specific resident still go to `PENDING` for approval.
2. **Allow staff to check in PENDING visitors** — The check-in endpoint now also accepts `PENDING` status (previously only `PRE_APPROVED` and `APPROVED`). This lets staff force-check-in a visitor whose resident hasn't responded.

**Files:**
| File | Change |
|------|--------|
| `backend/app/crud/crud_visitor.py` | `create_log_entry()` — walk-in → `CHECKED_IN`, resident-assigned → `PENDING` |
| `backend/app/api/v1/endpoints/visitors.py` | Check-in endpoint now allows `PENDING` status |

---

### Bug 6: Dashboard Showing All Zeros

**Root Cause:** Dashboard called `api.getVisitors(0, 200)` but the backend visitors endpoint caps `limit` at `le=100`. The `limit=200` caused a 422 validation error. Since all 4 API calls were in a `Promise.all`, one failure killed all stats — everything showed 0.

**Fix (2 parts):**
1. Changed `limit` from 200 to 100 for the visitors call
2. Made each API call individually resilient with `.catch(() => [])` so one failure doesn't zero out everything

**File:** `web/src/app/(admin)/dashboard/page.tsx`

---

### Feature: Delete Buttons for Visitors and Complaints

Added ability to delete finished visitor records and resolved/closed complaints to prevent log buildup.

**Backend:**
- `DELETE /api/v1/complaints/{id}` — Committee/Admin only
- `DELETE /api/v1/visitors/{id}` — Support staff/Admin only

**Admin Web Portal:**
- Complaints page: "Delete" button appears on resolved/closed complaints
- Visitors page: "Delete" button appears on checked-out/denied visitors

**Mobile (Staff Dashboard):**
- "Delete" button on each checked-out visitor card

**Files:**
| File | Change |
|------|--------|
| `backend/app/crud/crud_complaint.py` | Added `delete_complaint()` |
| `backend/app/api/v1/endpoints/complaints.py` | Added `DELETE /{id}` endpoint |
| `backend/app/crud/crud_visitor.py` | Added `delete_visitor()` |
| `backend/app/api/v1/endpoints/visitors.py` | Added `DELETE /{id}` endpoint |
| `web/src/lib/api.ts` | Added `deleteVisitor()`, `deleteComplaint()` methods |
| `web/src/app/(admin)/visitors/page.tsx` | Delete button on checked-out/denied visitors |
| `web/src/app/(admin)/complaints/page.tsx` | Delete button on resolved/closed complaints |
| `web/src/app/(admin)/dashboard/page.tsx` | Fixed limit=200 → 100, resilient Promise.all |
| `frontend/lib/features/visitors/services/visitor_service.dart` | Added `deleteVisitor()` |
| `frontend/lib/features/visitors/providers/visitor_provider.dart` | Added `deleteVisitor()` |
| `frontend/lib/features/visitors/screens/staff_dashboard_screen.dart` | Delete button on checked-out tab |

---

### Feature: Committee Complaint Management on Mobile App

Committee members and admins can now manage complaints directly from the Flutter mobile app — status updates and deletion, same as the web portal.

**Changes:**
- Complaint cards show a status dropdown and delete button for committee/admin users
- Regular members still see read-only complaint cards (no change)
- Delete shows a confirmation dialog; only available on resolved/closed complaints
- Role detection via `authProvider.token?.user.role`

**Files:**
| File | Change |
|------|--------|
| `frontend/lib/features/complaints/services/complaint_service.dart` | Added `deleteComplaint()` method |
| `frontend/lib/features/complaints/providers/complaint_provider.dart` | Added `deleteComplaint()` notifier method |
| `frontend/lib/features/complaints/screens/complaints_list_screen.dart` | Added `_isCommittee()` helper, status dropdown + delete button on complaint cards for committee/admin |

---

### Master Plan Restructured

Reordered remaining phases based on user priority. Maintenance & Payments moved to last feature phase (before security). Added Phase 9 with 6 quality-of-life features. Security hardening is now Phase 13 (final).

**New Phase Order:**
| Phase | Description | Status |
|-------|-------------|--------|
| 9 | Quality of Life — Notice Board, Comments, Profiles, Directory, Search | Next |
| 10 | Facility Booking & Polling | Pending |
| 11 | Push Notifications, SMS & WhatsApp | Pending |
| 12 | Maintenance & Payments | Pending (last feature phase) |
| 13 | Security Hardening & Production Readiness | Pending (final) |

**Files Modified:**
| File | Change |
|------|--------|
| `claude_master_plan.txt` | Restructured phases 9-13, added Phase 9 sub-features (9A-9F), moved Payments to Phase 12, added Phase 13 security details |

---

---

---

## Session 9 — 2026-03-22

### Phase 9A Complete — Notice Board / Announcements (Full-Stack)

Built the notice board feature end-to-end — backend model/API, admin web portal, and Flutter mobile app.

Also renamed `rules.md` → `CLAUDE.md` and restyled both `CLAUDE.md` and `SESSION_LOG.md` with polished formatting (centered headers, badges, collapsible index, phase status table).

---

### Part 1: Backend — Notice Model & API

#### Database Model: `notices`

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| society_id | String(5) FK | Multi-tenant isolation |
| posted_by_id | UUID FK | Who posted the notice |
| title | String(255) | Required |
| body | Text | Required |
| priority | Enum | normal, important, urgent |
| is_pinned | Boolean | Default false — pinned notices show first |
| created_at | DateTime | Auto-managed |
| updated_at | DateTime | Auto-managed |

#### API Endpoints

| Method | Path | Access | Description |
|--------|------|--------|-------------|
| POST | `/api/v1/notices/` | Committee/Admin | Post a new notice |
| GET | `/api/v1/notices/` | Any authenticated | List notices (pinned first, then newest) |
| GET | `/api/v1/notices/{id}` | Any authenticated | Get single notice |
| PATCH | `/api/v1/notices/{id}` | Committee/Admin | Edit notice (title, body, priority, pin) |
| DELETE | `/api/v1/notices/{id}` | Committee/Admin | Delete a notice |

---

### Part 2: Admin Web Portal

| Page | Route | Features |
|------|-------|----------|
| Notice Board | `/notices` | Card list with priority badges, pin/unpin, priority dropdown, delete, filter tabs (all/pinned/normal/important/urgent) |
| Post Notice | `/notices/new` | Form: title, body, priority dropdown, pin checkbox |
| Dashboard | `/dashboard` | Added "Active Notices" stat card |
| Sidebar | — | Added "Notices" nav item with megaphone icon |

---

### Part 3: Flutter Mobile App

| Screen | Route | Features |
|--------|-------|----------|
| Notice Board | `/notices` | List with priority badges, pin indicators, tap to view full notice in bottom sheet, pull-to-refresh |
| Dashboard | `/dashboard` | Added "Notice Board" tile for all users |

---

### Part 4: Housekeeping

- Renamed `rules.md` → `CLAUDE.md` (auto-read by Claude Code every session)
- Restyled `CLAUDE.md` with centered header, badges, collapsible sections, architecture diagram
- Added session checklist to `CLAUDE.md`
- Restyled `SESSION_LOG.md` with phase status table and collapsible session index
- Updated all references (`SESSION_LOG.md`, `claude_master_plan.txt`, `README.md`) from `rules.md` → `CLAUDE.md`

---

### Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `rules.md` → `CLAUDE.md` | Renamed + Restyled | Project rules with badges, collapsible sections, session checklist |
| `SESSION_LOG.md` | Modified | Added phase status table + collapsible session index at top |
| `README.md` | Modified | Updated reference from `rules.md` to `CLAUDE.md` |
| `claude_master_plan.txt` | Modified | Updated reference from `rules.md` to `CLAUDE.md` |
| `backend/app/models/notice.py` | Created | `Notice` model, `NoticePriority` enum |
| `backend/app/schemas/notice.py` | Created | `NoticeCreate`, `NoticeUpdate`, `NoticeResponse` |
| `backend/app/crud/crud_notice.py` | Created | Full CRUD: create, list, get, update, delete |
| `backend/app/api/v1/endpoints/notices.py` | Created | 5 endpoints for notice lifecycle |
| `backend/app/models/__init__.py` | Modified | Exported `Notice`, `NoticePriority` |
| `backend/app/db/base.py` | Modified | Registered `Notice` for Alembic |
| `backend/app/schemas/__init__.py` | Modified | Exported notice schemas |
| `backend/app/crud/__init__.py` | Modified | Exported notice CRUD functions |
| `backend/app/api/v1/__init__.py` | Modified | Mounted notices router |
| `backend/migrations/versions/a8eea61c74a2_create_notices_table.py` | Created | Migration: creates `notices` table with indexes |
| `web/src/lib/types.ts` | Modified | Added `Notice`, `NoticePriority` interfaces |
| `web/src/lib/api.ts` | Modified | Added `getNotices`, `createNotice`, `updateNotice`, `deleteNotice` |
| `web/src/components/sidebar.tsx` | Modified | Added "Notices" nav item with megaphone icon |
| `web/src/app/(admin)/notices/page.tsx` | Created | Notice board list with filters, pin, priority, delete |
| `web/src/app/(admin)/notices/new/page.tsx` | Created | Post notice form |
| `web/src/app/(admin)/dashboard/page.tsx` | Modified | Added "Active Notices" stat card |
| `frontend/lib/shared/models/notice_model.dart` | Created | `NoticeModel`, `NoticePriority` |
| `frontend/lib/features/notices/services/notice_service.dart` | Created | Dio calls for notice endpoints |
| `frontend/lib/features/notices/providers/notice_provider.dart` | Created | `NoticeState` + `NoticeNotifier` (Riverpod) |
| `frontend/lib/features/notices/screens/notices_list_screen.dart` | Created | Notice list with bottom sheet detail view |
| `frontend/lib/core/constants/api_constants.dart` | Modified | Added notices endpoint path |
| `frontend/lib/main.dart` | Modified | Added `/notices` route |
| `frontend/lib/shared/screens/dashboard_placeholder_screen.dart` | Modified | Added "Notice Board" tile, updated phase numbers |

---

### Key Design Decisions

- **No draft/archive status** — kept it simple: notices are either posted or deleted. Pin + priority covers the use cases.
- **Pinned notices sort first** — `ORDER BY is_pinned DESC, created_at DESC` in CRUD query
- **All users see notices** — committee/admin post, everyone reads
- **Bottom sheet detail view on mobile** — tap a notice card to read the full content without navigating away
- **`flutter analyze` — zero issues**
- **`npm run build` — zero errors**

---

### Login Bug Fix: passlib + bcrypt 5.0.0 Incompatibility

**Problem:** `passlib` tries to access `bcrypt.__about__.__version__` which was removed in bcrypt 5.0.0 on Python 3.13. This caused `ValueError` / `AttributeError` on every login attempt.

**Fix:** Replaced `passlib.context.CryptContext` with direct `bcrypt.hashpw()` and `bcrypt.checkpw()` calls. Existing `$2b$12$` password hashes are fully compatible with both libraries.

| File | Action | Description |
|------|--------|-------------|
| `backend/app/core/security.py` | Modified | Replaced passlib with direct bcrypt for `hash_password()` and `verify_password()` |

---

---

## Session 10 — 2026-03-22

### Phase 9A Enhancement — Notice Images + Mobile Notice Management

**Objective:** Allow committee members to create/manage notices from the mobile app and add optional image attachments to notices across all platforms.

---

### Files Created / Modified

**Backend:**

| File | Action | Description |
|------|--------|-------------|
| `backend/app/models/notice.py` | Modified | Added `image_url` nullable column (String 500) |
| `backend/app/schemas/notice.py` | Modified | Added `image_url` to `NoticeCreate`, `NoticeUpdate`, `NoticeResponse` |
| `backend/app/crud/crud_notice.py` | Modified | Pass `image_url` through in `create_notice()` |
| `backend/app/api/v1/endpoints/notices.py` | Modified | Added `POST /notices/upload-image` endpoint, image cleanup on delete |
| `backend/app/core/config.py` | Modified | Added `UPLOAD_DIR` and `MAX_IMAGE_SIZE_MB` settings |
| `backend/app/main.py` | Modified | Mounted `/uploads` static file serving via `StaticFiles` |
| `backend/requirements.txt` | Modified | Added `Pillow>=10.0.0` |
| `backend/migrations/versions/c109897754d0_add_image_url_to_notices.py` | Created | 8th migration: adds `image_url` column to notices |

**Web Portal:**

| File | Action | Description |
|------|--------|-------------|
| `web/src/lib/types.ts` | Modified | Added `image_url` to `Notice` interface |
| `web/src/lib/api.ts` | Modified | Added `uploadNoticeImage()`, `image_url` in create/update |
| `web/src/app/(admin)/notices/new/page.tsx` | Modified | Image picker with preview, upload-then-create flow |
| `web/src/app/(admin)/notices/page.tsx` | Modified | Display notice images in list view |

**Mobile (Flutter):**

| File | Action | Description |
|------|--------|-------------|
| `frontend/lib/shared/models/notice_model.dart` | Modified | Added `imageUrl` field |
| `frontend/lib/features/notices/services/notice_service.dart` | Modified | Added `createNotice()`, `updateNotice()`, `uploadImage()` methods |
| `frontend/lib/features/notices/providers/notice_provider.dart` | Modified | Added `createNotice()`, `updateNotice()` with image upload support |
| `frontend/lib/features/notices/screens/notices_list_screen.dart` | Modified | FAB for committee/admin, image thumbnails, delete action in detail sheet |
| `frontend/lib/features/notices/screens/create_notice_screen.dart` | Created | Full create form: title, body, image picker, priority segments, pin toggle |
| `frontend/lib/main.dart` | Modified | Added `/notices/new` route + import |
| `frontend/pubspec.yaml` | Modified | Added `image_picker: ^1.1.2` dependency |

**Other:**

| File | Action | Description |
|------|--------|-------------|
| `.gitignore` | Modified | Added `backend/uploads/` to ignore user-generated content |

---

### Key Design Decisions

- **Separate upload endpoint** — `POST /notices/upload-image` returns a URL; create/update endpoints accept `image_url` as a string. Keeps JSON endpoints backward-compatible.
- **Server-side file storage** — Images saved to `backend/uploads/notices/` with UUID filenames, served via FastAPI `StaticFiles`.
- **Image validation** — JPEG, PNG, WebP only; max 5MB; configurable via `MAX_IMAGE_SIZE_MB` env var.
- **Mobile committee/admin actions** — FAB (+) button and delete action only visible when `role == 'admin' || role == 'committee'`.
- **Image picker quality** — Compressed to 85% quality, max 1920×1920 on mobile to reduce upload size.
- **`flutter analyze` — zero issues**
- **`npm run build` — zero errors**

---

---

## Session 11 — 2026-03-22

### Phase 9B Complete — Complaint Comments / Replies

**Objective:** Add threaded comment/reply functionality to complaints across backend, web portal, and mobile app.

---

### RBAC for Comments

| Role | View Comments | Add Comment | Delete Own | Delete Any |
|------|:---:|:---:|:---:|:---:|
| **Admin** | All complaints | Any complaint | Yes | Yes |
| **Committee** | All complaints | Any complaint | Yes | Yes |
| **Support Staff** | Own complaints | Own complaints | Yes | No |
| **Member** | Own complaints | Own complaints | Yes | No |

---

### Files Created

| File | Description |
|------|-------------|
| `backend/app/models/complaint_comment.py` | `ComplaintComment` SQLAlchemy model (UUID PK, society_id FK, complaint_id FK, user_id FK, body, created_at) |
| `backend/app/schemas/complaint_comment.py` | `CommentCreate` + `CommentResponse` Pydantic schemas (includes `user_name` from relationship) |
| `backend/app/crud/crud_complaint_comment.py` | CRUD: `create_comment`, `get_comments`, `get_comment_by_id`, `delete_comment` |
| `backend/migrations/versions/cae8afabb4b8_create_complaint_comments_table.py` | Migration #9: creates `complaint_comments` table with indexes |
| `frontend/lib/shared/models/complaint_comment_model.dart` | Flutter comment model with `fromJson` |
| `frontend/lib/features/complaints/screens/complaint_detail_screen.dart` | Full complaint detail screen with comment thread, input bar, delete support |

### Files Modified

| File | Changes |
|------|---------|
| `backend/app/models/__init__.py` | Registered `ComplaintComment` model |
| `backend/app/api/v1/endpoints/complaints.py` | Added 3 comment endpoints: `GET/POST /{id}/comments`, `DELETE /{id}/comments/{cid}`. Removed inline `UserRole` import (now at top). |
| `web/src/lib/types.ts` | Added `ComplaintComment` interface |
| `web/src/lib/api.ts` | Added `getComplaintComments`, `addComplaintComment`, `deleteComplaintComment` methods |
| `web/src/app/(admin)/complaints/page.tsx` | Added expandable `CommentThread` component per complaint card (load, post, delete comments) |
| `frontend/lib/features/complaints/services/complaint_service.dart` | Added `getComments`, `addComment`, `deleteComment` methods |
| `frontend/lib/features/complaints/providers/complaint_provider.dart` | Added `CommentState`, `CommentNotifier`, `commentProvider` (family provider keyed by complaint ID) |
| `frontend/lib/features/complaints/screens/complaints_list_screen.dart` | Made complaint cards tappable → navigates to `ComplaintDetailScreen` |

### API Endpoints Added

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/api/v1/complaints/{id}/comments` | Any (RBAC-filtered) | List comments on a complaint |
| `POST` | `/api/v1/complaints/{id}/comments` | Any (RBAC-filtered) | Add comment (body: `{ "body": "..." }`) |
| `DELETE` | `/api/v1/complaints/{id}/comments/{cid}` | Owner or Committee+ | Delete a comment |

### Bug Fix: Complaint Visibility

**Problem:** Members could only see their own complaints — other members' complaints were hidden. This defeats the purpose of transparency in a society.

**Fix:** Removed the `raised_by_id` filter for members in `get_complaints()` CRUD and removed the 403 access-denied check in `get_complaint()` and comment endpoints. Now all members can see all complaints in their society, view details, and comment on any complaint.

**Files changed:**
- `backend/app/crud/crud_complaint.py` — removed `requesting_user_id` / `requesting_user_role` params and member-only filter
- `backend/app/api/v1/endpoints/complaints.py` — removed member 403 checks from `get_complaint`, `list_comments`, `add_comment`

**Permissions that remain restricted:**
- Status updates → committee/admin only
- Deleting complaints → committee/admin only
- Deleting comments → comment owner or committee/admin

### Verification

- **`flutter analyze` — zero issues**
- **`npm run build` — zero errors**

---

### Start of Next Session — Pick Up Here

**Phase 9B (Complaint Comments) is complete. Continue with Phase 9C–F or Phase 10.**

**Before doing anything else:**

1. Start PostgreSQL:
   ```bash
   brew services start postgresql@16
   ```
2. Run migrations (9 total):
   ```bash
   cd /Users/masum/Development/Society/backend
   alembic upgrade head
   ```
3. Start the backend server:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```
4. Start the admin web portal:
   ```bash
   cd /Users/masum/Development/Society/web
   npm run dev
   ```

**Then continue with:**
> **Phase 9C–F — Profiles, Directory, Activity Feed, Search**
> or **Phase 10 — Facility Booking & Polling**

---

### Environment Notes

- PostgreSQL 16 via Homebrew, localhost:5432
- Database `society_db` — 9 migrations applied
- Society IDs: 5-letter uppercase codes (e.g. `MKQWZ`)
- Backend: `uvicorn app.main:app --reload --port 8000`
- Web portal: `npm run dev` from `web/` → http://localhost:3000
- Flutter: `flutter run` from `frontend/`
- `npm run build` — zero errors
- `flutter analyze` — zero issues
