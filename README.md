# Society Management App

A multi-tenant SaaS platform for managing residential societies. Built with **FastAPI** (backend) and **Flutter** (frontend).

## Features

- **Complaint Management** — Issue tracking with status updates, comments/replies
- **Visitor & Security Management** — Gate logging, pre-approvals, check-in/out, walk-ins
- **Notice Board** — Society-wide announcements with image attachments
- **Bulk Import** — Excel/CSV import for units and members (web portal)
- **Admin Web Portal** — Next.js dashboard for admin/committee management
- **Facility Booking** — Conflict-free amenity reservations *(coming soon)*
- **Polling & Voting** — Democratic decision-making tools *(coming soon)*
- **Maintenance & Payments** — Auto-generated bills and payment integration *(coming soon)*

---

## Architecture

```
Society Management App
├── backend/          # FastAPI + PostgreSQL
│   ├── app/
│   │   ├── api/      # Route handlers & dependencies
│   │   ├── core/     # Config, security utilities
│   │   ├── crud/     # Database CRUD operations
│   │   ├── db/       # SQLAlchemy base & session
│   │   ├── models/   # ORM models
│   │   ├── schemas/  # Pydantic request/response schemas
│   │   └── main.py   # FastAPI app entry point
│   ├── migrations/   # Alembic migrations (9 total)
│   └── requirements.txt
├── web/              # Next.js admin web portal
│   └── src/
│       ├── app/      # App router pages
│       ├── components/ # Shared components
│       └── lib/      # API client, types, utils
└── frontend/         # Flutter mobile app
    └── lib/
        ├── core/     # Theme, constants, API client
        ├── features/ # Feature modules (auth, complaints, notices, visitors)
        └── shared/   # Shared models, widgets & utilities
```

---

## Core Principles (from `CLAUDE.md`)

| Rule | Implementation |
|------|---------------|
| Multi-tenant isolation | Every model has `society_id`; all queries scoped per tenant |
| Role-based access | JWT payload carries role; enforced on every endpoint |
| Secure passwords | bcrypt hashing via `passlib` |
| Input validation | Pydantic schemas on all routes |
| Rate limiting | SlowAPI — 60 req/min default |
| Audit logging | High-risk actions logged with user + timestamp |

### Roles

| Role | Access |
|------|--------|
| `admin` | Full system configuration |
| `committee` | Operational management, approvals |
| `support_staff` | Gate entry logging, maintenance tasks |
| `member` | Payments, complaints, bookings, polling |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend API | FastAPI |
| Database | PostgreSQL + SQLAlchemy 2.0 |
| Migrations | Alembic |
| Auth | OAuth2 JWT (`python-jose`) |
| Password hashing | bcrypt (`passlib`) |
| Rate limiting | SlowAPI |
| Mobile frontend | Flutter |
| State management | Riverpod |
| HTTP client | Dio |
| Notifications | Firebase Cloud Messaging |

---

## Getting Started

### Backend

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Copy and configure environment
cp .env.example .env   # edit DATABASE_URL, SECRET_KEY

# Apply database migrations
alembic upgrade head

# Run the development server
uvicorn app.main:app --reload
```

API docs available at `http://localhost:8000/docs` (DEBUG mode only).

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Development Progress

| Phase | Description | Status |
|-------|-------------|--------|
| 1–3 | Database, Auth, Multi-Tenancy, Flutter Foundation | ✅ Complete |
| 4 | Complaint Management (full-stack) | ✅ Complete |
| 4.5 | Unit Model, Member Management | ✅ Complete |
| 5–7 | Invite Auth, Admin Web Portal, Mobile Redesign | ✅ Complete |
| 8 | Visitor & Security Management | ✅ Complete |
| 8.5 | Bulk Excel/CSV Import (Web Portal) | ✅ Complete |
| 9A | Notice Board with Image Attachments | ✅ Complete |
| 9B | Complaint Comments / Replies | ✅ Complete |
| 9C–F | Profiles, Directory, Activity Feed, Search | ⏳ Next |
| 10 | Facility Booking & Polling | ⏳ Pending |
| 11 | Push Notifications, SMS & WhatsApp | ⏳ Pending |
| 12 | Maintenance & Payments | ⏳ Pending |
| 13 | Security Hardening & Production Readiness | ⏳ Pending |

See [SESSION_LOG.md](SESSION_LOG.md) for a detailed log of every development session.

---

## Environment Variables

Create a `.env` file in `backend/`:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/society_db
SECRET_KEY=your-long-random-secret-key
DEBUG=True
ACCESS_TOKEN_EXPIRE_MINUTES=30
RATE_LIMIT_PER_MINUTE=60
```
