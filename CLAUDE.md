<h1 align="center">Society Management App — Project Rules</h1>

<p align="center">
  <strong>Foundational rules, security principles, and development guidelines for every session.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Type-Multi--Tenant_SaaS-blue?style=flat-square" alt="SaaS">
  <img src="https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square" alt="FastAPI">
  <img src="https://img.shields.io/badge/Web-Next.js_16-000000?style=flat-square" alt="Next.js">
  <img src="https://img.shields.io/badge/Mobile-Flutter-02569B?style=flat-square" alt="Flutter">
  <img src="https://img.shields.io/badge/DB-PostgreSQL_16-4169E1?style=flat-square" alt="PostgreSQL">
</p>

---

## Session Checklist

**Do these every session. No exceptions.**

- [ ] Read `SESSION_LOG.md` — check where we left off and what's next
- [ ] Update `SESSION_LOG.md` — log every file created, modified, or deleted during the session
- [ ] Update `README.md` — keep it in sync with current phase progress
- [ ] Never commit credentials, `.env` files, or default secrets
- [ ] Never add bulk import features to the mobile app — web portal only
- [ ] Run `flutter analyze` (zero issues) and `npm run build` (zero errors) before finishing

---

## 1. Multi-Tenant Architecture & Data Isolation

- A society's data must be **completely isolated** from another society's data.
- Every tenant (Society) has a unique 5-letter `society_id` code.
- Every database query must filter by `society_id` — no cross-tenant data leakage.
- Implementation: Row-level filtering in all CRUD functions, enforced in the backend (not just frontend).

---

## 2. Role-Based Access Control (RBAC)

Actions are strictly governed by the user's role. The backend must enforce authorization via JWT payload.

| Role | Who | Permissions |
|------|-----|-------------|
| **Admin** | Society admin | Everything — system config, member management, all modules |
| **Committee** | Secretary, Chairman, Treasurer | Operational management, approvals, complaints, events. Also own units. |
| **Support Staff** | Security guards, cleaners, janitors | Log visitors, gate entry, maintenance tasks, limited access |
| **Member** | Regular residents | File complaints, view own data, payments, bookings, polling |

---

## 3. Security Protocols

<details>
<summary><strong>Database & Data Security</strong></summary>
<br>

- Encrypt sensitive PII (phone numbers, payment details) at rest and in transit
- HTTPS/TLS for all API traffic
- Passwords hashed with **bcrypt** (never stored in plain text)
- UUID primary keys on all tables (non-guessable)

</details>

<details>
<summary><strong>API Security (FastAPI)</strong></summary>
<br>

- **Rate limiting** via `slowapi` — default 60 req/min, configurable via `.env`
- **Short-lived JWT tokens** with `sub` (user UUID), `society_id`, and `role` in payload
- **Input sanitization** — Pydantic validation on all routes (prevents SQL injection, XSS)
- **Pagination bounds** — all list endpoints enforce `limit` with `Query(ge=1, le=100)`

</details>

<details>
<summary><strong>Auth Flow</strong></summary>
<br>

- **Invite-based registration** — admin adds members, system generates invite tokens
- Residents activate via invite token + set password (no self-registration)
- First user in a society auto-becomes ADMIN (bootstrap)
- `POST /auth/lookup` always returns 200 (prevents email enumeration)
- Unactivated users cannot login (`hashed_password = "!"` until activation)

</details>

---

## 4. Core Modules

Every society onboarded has access to these modules:

| Module | Status | Description |
|--------|:------:|-------------|
| Complaint Management | Done | Issue tracking with status updates, RBAC-filtered |
| Visitor & Security Management | Done | Gate logging, pre-approvals, check-in/out, walk-ins |
| Bulk Import (Excel/CSV) | Done | Units + members import via web portal |
| Notice Board | Next | Society-wide announcements |
| Facility Booking | Pending | Conflict-free amenity reservations |
| Polling & Voting | Pending | Democratic decision-making tools |
| Maintenance & Payments | Pending | Auto-generated bills, payment gateways |
| Push Notifications | Pending | SMS, WhatsApp, Firebase push |

---

## 5. Audit & Logging

- Every significant action creates an audit trail.
- High-risk activities (adding a resident, altering payments, gating a visitor) must log: **user**, **timestamp**, **action performed**.

---

## 6. New Feature Template

Before writing code for any new feature, verify this checklist:

- [ ] **Role Authorization**: Which roles have read / write / delete access?
- [ ] **Multi-Tenancy**: Does the model include `society_id`? Are all queries filtered?
- [ ] **Audit Requirement**: Does this feature need audit logging?
- [ ] **Notification Triggers**: Who gets notified when actions happen?

<details>
<summary><strong>Implementation Structure Template</strong></summary>
<br>

```
Feature Name: [Name]
Objective: [What it achieves]

1. RBAC:
   - Admin: [permissions]
   - Committee: [permissions]
   - Support Staff: [permissions]
   - Member: [permissions]

2. Database:
   - Tables: [e.g., polls, votes]
   - Constraint: WHERE society_id = current_user.society_id

3. API Endpoints:
   - POST /api/v1/feature_name — Create [Committee+]
   - GET  /api/v1/feature_name — List [Member+]

4. Security:
   - Input validation: [Pydantic rules]
   - Audit logging: [what gets logged]

5. Frontend:
   - Web portal: [pages/routes]
   - Mobile app: [screens/routes]
```

</details>

---

## 7. Architecture Overview

```
                    ┌─────────────────────┐
                    │   PostgreSQL 16      │
                    │   (society_db)       │
                    └─────────┬───────────┘
                              │
                    ┌─────────┴───────────┐
                    │   FastAPI Backend    │
                    │   (port 8000)        │
                    └─────────┬───────────┘
                              │
                 ┌────────────┼────────────┐
                 │                         │
      ┌──────────┴──────────┐   ┌─────────┴──────────┐
      │  Admin Web Portal   │   │   Flutter Mobile    │
      │  Next.js (port 3000)│   │   App               │
      │                     │   │                     │
      │  Users: Admin,      │   │  Users: Members,    │
      │  Committee          │   │  Support Staff      │
      └─────────────────────┘   └─────────────────────┘
```
