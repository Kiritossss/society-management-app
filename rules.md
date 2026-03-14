# Society Management App Fundamentals & Core Rules

Welcome to the foundational documentation for the Society Management App. This guide establishes the essential rules and security principles guiding the development of the application. Since this is a public SaaS product that will be sold to multiple societies, security, multi-tenancy, and data isolation are critical.

## 1. Multi-Tenant Architecture & Data Isolation
- **Rule**: A society's data must be completely isolated from another society's data.
- **Implementation**: The database must utilize a robust multi-tenant strategy. Every tenant (Society) will have a unique `society_id`. Every major database query must logically separate incoming requests based on the user's `society_id` to ensure no cross-contamination of data (e.g., Row-Level Security).

## 2. Strong Role-Based Access Control (RBAC)
- **Rule**: Actions across the app are strictly governed by the user's assigned role.
- **Roles**:
  - **Admin**: System configuration and highest-level society management.
  - **Secretary / Committee**: Operational management, approvals, and resolving notices/complaints.
  - **Support Staff (Watchmen, Cleaners, Janitors, Snow Walkers)**: Restricted access; capabilities primarily focus on logging gate entries (visitors), maintenance tasks, and issue reporting.
  - **Normal Members**: Standard resident features (payments, complaints, bookings, polling).
- **Implementation**: The backend must enforce strict endpoint authorization based on the JWT payload role.

## 3. Comprehensive Security Protocols
- **Database & Data Security**:
  - Encrypt sensitive resident information (e.g., PII like phone numbers, payment details) at rest and in transit (HTTPS/TLS for all API traffic).
  - Use secure credential storage routines (bcrypt or Argon2) for passwords.
- **API Security (FastAPI)**:
  - Implement Rate Limiting to mitigate DDoS and brute-force attacks.
  - Use short-lived OAuth2 JWT tokens with comprehensive validation.
  - Apply input sanitization and Pydantic validation across all routes to prevent SQL Injection and XSS.

## 4. Core Features Availability
Every society onboarded strictly follows these modules:
- **Complaint Management**: Issue tracking with status updates.
- **Visitor & Security Management**: Gatekeepers securely log and verify visitor entry.
- **Maintenance & Payments**: Auto-generation of bills and secure online payment gateways.
- **Facility Booking**: Conflict-free amenity reservations.
- **Polling & Voting**: Democratic decision-making tools for society members.

## 5. Audit & Logging
- **Rule**: Every significant action within the app creates an audit trail.
- **Implementation**: High-risk activities (adding a resident, altering payment records, gating a visitor) must generate a log indicating the user, timestamp, and the action performed for accountability.

## 6. Standard Process for Adding New Features
To ensure consistency, security, and scalability as the app grows, every new feature proposal or implementation must follow this standard checklist and template.

### A. New Feature Analysis Checklist
Before writing code for a new feature, verify the following:
- [ ] **Role Authorization Profile**: Which specific roles (Admin, Committee, Support Staff, Member) have read, write, or delete permissions for this feature?
- [ ] **Multi-Tenancy Check**: Does the database model strictly include `society_id`?
- [ ] **Audit Requirement**: Does this feature perform high-risk actions that need to be logged in the audit trail?
- [ ] **Notification Triggers**: Who needs to be notified when actions happen within this feature (e.g., Push Notification via Firebase)?

### B. Implementation Template
When documenting or planning a new feature, use this structure:

#### Feature Name: [Name]
**Objective**: [Brief description of what the feature achieves]

**1. Access Control (RBAC):**
- **Admin**: [What they can do]
- **Committee**: [What they can do]
- **Support Staff**: [What they can do]
- **Normal Member**: [What they can do]

**2. Database & Multi-Tenancy:**
- **Tables Needed**: [e.g., `polls`, `votes`]
- **Isolation Constraint**: Must enforce `WHERE society_id = current_user.society_id` on all queries.

**3. API Endpoints (FastAPI):**
- `POST /api/v1/feature_name` - Create [Requires: Committee Role]
- `GET /api/v1/feature_name` - List [Requires: Member Role]

**4. Security & Audit:**
- **Input Validation**: [List strict Pydantic rules, e.g., max length, positive integers]
- **Audit Logging**: [e.g., Log when a Committee member deletes an item]

**5. Frontend Integration (Flutter):**
- **UI State**: [How the app handles loading/error states for this feature]
- **Navigation Route**: [e.g., `/feature_dashboard`]
