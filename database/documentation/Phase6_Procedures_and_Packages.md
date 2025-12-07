# Phase VI: PL/SQL Procedures and Package – ER Triage Management

## 1. Phase Scope and Objectives

Phase VI focuses on implementing the core ER triage business logic in PL/SQL. The goal is to move beyond pure table design and data loading (Phase V) and encapsulate key workflows inside stored procedures and a reusable package.

**Objectives:**
- Implement PL/SQL procedures to handle common ER workflows (check‑in, bed assignment, treatment start, discharge).
- Centralize shared logic in a package (`PKG_ER_TRIAGE_MGMT`) for easier reuse and maintenance.
- Add basic error logging and auditing hooks so failures and important actions are captured in dedicated tables.
- Provide test scripts that demonstrate successful execution of these procedures.

Deliverable: **GitHub submission (PL/SQL scripts + test results)**.

---

## 2. Main PL/SQL Components

### 2.1 Package: `PKG_ER_TRIAGE_MGMT`

The main PL/SQL package groups together ER triage management procedures.

**Specification file:**
- `database/scripts/phase6_step2_package.sql` (contains the package specification and body).

**Intended responsibilities:**
- Standardize how new ER arrivals are registered.
- Assign or reassign beds based on triage priority and availability.
- Start and complete treatment sessions while updating related tables.
- Record key actions in audit/error tables when enabled.

> Note: Even if the package body is not fully used in later phases, including it in GitHub shows the design intent and PL/SQL skills for the capstone.

---

### 2.2 Supporting Tables

Phase VI procedures rely on the core Phase V tables and two additional helper tables:

- `ER_ERROR_LOG` – captures PL/SQL exceptions with procedure name, error code, message, and timestamp.  
- `ER_AUDIT_LOG` – generic audit table for recording actions taken by the procedures (e.g., bed assignment, discharge).

These are created in `database/scripts/phase6_step1_audit_tables.sql`.

---

### 2.3 Example Procedures (Conceptual)

The package is designed to support procedures such as:

- `proc_register_arrival` – inserts a new record into `ER_ARRIVALS`, validates triage level and patient, and logs any errors.
- `proc_assign_bed` – finds an available bed, updates `ER_BEDS` and `ER_ARRIVALS`, and writes an audit entry.
- `proc_start_treatment` – opens a new row in `TREATMENT_SESSIONS` and associates it with the arrival.
- `proc_discharge_patient` – closes the treatment session, updates arrival status, and records a discharge action.

Even if some procedures are simplified for the assignment, the structure matches real ER workflows.

---

## 3. Phase VI Scripts

The following scripts are part of the Phase VI deliverable:

- [`database/scripts/phase6_step1_audit_tables.sql`](../scripts/phase6_step1_audit_tables.sql) – creates `ER_ERROR_LOG` and `ER_AUDIT_LOG` tables used by PL/SQL code.
- [`database/scripts/phase6_step2_package.sql`](../scripts/phase6_step2_package.sql) – package specification/body for `PKG_ER_TRIAGE_MGMT` and related procedures.
- [`database/scripts/phase6_step3_tests.sql`](../scripts/phase6_step3_tests.sql) – test script that exercises key procedures (e.g., registering an arrival, assigning a bed, starting treatment).

All scripts are intended to be run in order using the `ER_triage` connection.

---

## 4. Test Results and How to Run

### 4.1 Running the Scripts

In Oracle SQL Developer, connect as the project user (e.g., `DENYSE_ADMIN`) and run:

1. `phase6_step1_audit_tables.sql` – creates logging/audit tables (`Table created` messages).
2. `phase6_step2_package.sql` – compiles the `PKG_ER_TRIAGE_MGMT` package (`Package created` / `Package body created` messages).
3. `phase6_step3_tests.sql` – executes the test block and prints output in `DBMS_OUTPUT` / Script Output.

### 4.2 Captured Test Evidence (Screenshots)

The following screenshots under `screenshots/test_results/` correspond to Phase VI:

- `phase6_package_creation.png` – output of running the package script (package created messages).
- `phase6_procedure_tests.png` – output of running the test script, showing procedure calls and any success messages.

These screenshots demonstrate that the PL/SQL scripts compile and can be executed successfully in the target environment.

---

## 5. Role of Phase VI in the Overall Project

- **Bridges design and execution:** Turns the static ER schema into an executable set of workflows that mirror real ER operations.
- **Prepares for triggers/auditing (Phase VII):** The audit and error tables created here are then used by triggers and audit logic in the next phase.
- **Supports BI and analytics:** By standardizing how arrivals, treatments, and discharges are handled, Phase VI ensures consistent data for KPIs such as wait times, bed utilization, and treatment outcomes.

Phase VI, together with Phases V and VII, completes the technical backbone of the ER Triage & Resource Allocation System.
