# Society Management App

A multi-tenant SaaS platform for managing residential societies. Built with **FastAPI** (backend) and **Flutter** (frontend).

## Features

- **Complaint Management** — Issue tracking with status updates
- **Visitor & Security Management** — Gatekeepers log and verify visitor entry
- **Maintenance & Payments** — Auto-generated bills and online payment integration
- **Facility Booking** — Conflict-free amenity reservations
- **Polling & Voting** — Democratic decision-making tools for residents

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
│   ├── migrations/   # Alembic migrations
│   └── requirements.txt
└── frontend/         # Flutter mobile app
    └── lib/
        ├── core/     # Theme, constants, API client
        ├── features/ # Feature modules (auth, complaints, etc.)
        └── shared/   # Shared widgets & utilities
```

---

## Core Principles (from `rules.md`)

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
| 1 | Database & Core Setup (models, Alembic) | ✅ Complete |
| 2 | Authentication & Multi-Tenancy (JWT, RBAC) | ✅ Complete |
| 3 | Flutter App Foundation | ✅ Complete |
| 4 | Complaint Management (full-stack) | ✅ Complete |
| 5 | Visitor & Security Management (full-stack) | ⏳ Pending |
| 6 | Maintenance & Payments (full-stack) | ⏳ Pending |
| 7 | Push Notifications (Firebase FCM) | ⏳ Pending |

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
