# Hospital ER Triage & Resource Allocation System

## Student Information
- **Student Name:** Denyse Uwamwezi  
- **Student ID:** 27976

---

## Project Overview
This project implements a relational database and PL/SQL codebase to support an Emergency Room (ER) triage and resource allocation system. It models patients, triage levels, medical staff, beds, equipment, supplies, treatment sessions, medications, alerts, and audit logs to help an ER manage patient flow and critical resources safely and efficiently.

The solution is designed as a full database-backed application foundation: tables, constraints, sample data, stored procedures, functions, triggers, analytics queries, and business‑intelligence documentation.

---

## Problem Statement
Hospitals frequently struggle to balance high patient volumes with limited ER resources such as beds, staff, and equipment. Without good data and automation, it is hard to triage patients correctly, allocate resources fairly, enforce operating rules (like weekend restrictions), and provide managers with reliable performance metrics.

This project addresses that problem by building a structured ER triage and resource allocation database that captures all critical events (arrivals, treatments, alerts, and audits) and exposes them through PL/SQL logic and analytical queries.

---

## Key Objectives
- Design a normalized ER triage schema with 15+ related tables and constraints.
- Implement PL/SQL procedures and functions to manage patient check‑in, bed assignment, treatment sessions, and audit logging.
- Enforce business rules using triggers (for example, weekend/holiday restrictions on certain changes).
- Populate the database with realistic sample data for testing and analysis.
- Provide validation and analytics queries to measure performance (wait times, utilization, alerts, audit activity).
- Produce BI requirements, KPI definitions, and dashboard mockups for ER stakeholders.

---

## Quick Start Instructions

### Prerequisites
- Oracle Database XE 21c (or compatible Oracle database)
- Oracle SQL Developer (used to run all scripts)

### 1. Create Schema Objects
Run the scripts in order from SQL Developer using the `ER_triage` connection (user `DENYSE_ADMIN` or your schema):

1. Create tablespaces (if provided)  
2. Phase 5: table creation script (creates all core tables)  
3. Phase 5: data insertion script (loads sample data)  
4. Phase 6: package and procedure scripts (triage management logic)  
5. Phase 7: functions, triggers, and audit procedures

> Tip: Use the `F5` (Run Script) button so you see all `Table created`, `1 row inserted`, `Function created`, and `Trigger created` messages.

### 2. Validate Data & Objects
- Run the Phase 5 validation script to confirm row counts for all tables.  
- Run the trigger status query:
	```sql
	SELECT trigger_name, table_name, status
	FROM user_triggers
	ORDER BY trigger_name;
	```
- Run the audit log queries to verify that weekend tests and other actions are being recorded in `EMPLOYEE_ACTION_AUDIT`.

### 3. Run Analytics & BI Queries
- Open the analytics queries script and execute the sample queries that use window functions (`RANK`, `LAG`, etc.).  
- Use the results for screenshots and for the BI dashboards described in the documentation.

---

## Links to Documentation
All detailed documentation is under the `documentation/`, `database/documentation/`, `screenshots/`, and `business_intelligence/` folders in this repository:

- `documentation/architecture.md` – Overall system and database architecture.  
- `documentation/design_decisions.md` – Major design choices and trade‑offs.  
- `documentation/data_dictionary.md` – Full table and column data dictionary (Phase III deliverable).  
- `database/documentation/Phase2_Business_Process_Model.md` – Phase II BPMN diagram explanation (business process model).  
- `screenshots/README.md` – Screenshot checklist and how to capture evidence.  
- `business_intelligence/bi_requirements.md` – BI requirements, stakeholders, and reporting frequencies.  
- `business_intelligence/kpi_definitions.md` – Formal KPI definitions, formulas, and targets.  
- `business_intelligence/dashboards.md` – Dashboard mockups and supporting queries.

Use this `README.md` as the entry point for the marker to understand the project and quickly navigate to the rest of the documentation.

---

## Phase II: Business Process Modeling

[`Phase II: Business Process Model – Full Explanation`](database/documentation/Phase2_Business_Process_Model.md)

[`Phase II ER Triage BPMN`](screenshots/database_objects/HospitalER.jpg)

---

## Phase III: ER Diagram, Data Dictionary, and Assumptions

Phase III focuses on documenting the logical data model and design assumptions.

- **ER Diagram (logical/physical model):**  
  [`screenshots/database_objects/er_diagram.png`](screenshots/database_objects/er_diagram.png) – ER diagram image showing all tables and relationships (captured from SQL Developer / Data Modeler).

- **Data Dictionary:**  
  [`documentation/data_dictionary.md`](documentation/data_dictionary.md) – One‑page table listing every table, column, data type, constraints, and purpose. This satisfies the “data dictionary” part of the Phase III deliverable.

- **Design Assumptions & Notes:**  
  [`documentation/design_decisions.md`](documentation/design_decisions.md) – Key design decisions and assumptions (triage levels, bed allocation rules, audit strategy, weekend restrictions, etc.).

---

## Phase IV: Database Environment & Setup (GitHub Documentation)

Phase IV documents how to create and configure the Oracle environment for this project.

- **Database creation scripts:**  
	- [`database/scripts/phase4_create_pluggable_db.sql`](database/scripts/phase4_create_pluggable_db.sql) – creates the pluggable database and base environment for the ER triage schema.

- **Tablespace configuration:**  
	- Described in [`database/documentation/Phase4_Database_Creation.md`](database/documentation/Phase4_Database_Creation.md) as part of the environment setup.

- **Project structure overview:**  
	- [`database/documentation/Phase4_Database_Creation.md`](database/documentation/Phase4_Database_Creation.md) – narrative explanation of database creation steps and environment setup.  

- **Test diagrams to show database and tablespaces:**  
	- [`screenshots/test_results/1_show_db_test.png`](screenshots/test_results/1_show_db_test.png) – shows the created pluggable database.  
	- [`screenshots/test_results/2_show_tablespaces_test.png`](screenshots/test_results/2_show_tablespaces_test.png) – lists available tablespaces.  
	- [`screenshots/test_results/3_tablespaces_spaces_test.png`](screenshots/test_results/3_tablespaces_spaces_test.png) – shows free/used space per tablespace.

---

## Phase V: Table Creation, Data Insertion, and Validation

Phase V focuses on implementing the logical model physically in Oracle and loading sample data.

- [`database/documentation/Phase5_Table_Implementation.md`](database/documentation/Phase5_Table_Implementation.md)

- **CREATE scripts (table definitions):**  
	- [`database/scripts/phase5_create_tables.sql`](database/scripts/phase5_create_tables.sql) – creates all core ER tables (patients, triage levels, staff, beds, arrivals, treatment sessions, supplies, medications, alerts, audit tables, etc.).

- **INSERT scripts (sample data):**  
	- [`database/scripts/phase5_insert_data.sql`](database/scripts/phase5_insert_data.sql) – inserts realistic sample data for all tables so that procedures, triggers, and analytics can be tested.

- **Validation queries:**  
	- [`database/scripts/phase5_validation_queries.sql`](database/scripts/phase5_validation_queries.sql) – row‑count and consistency checks used to confirm that data was loaded correctly across all 15 tables.

- **Test result screenshots:**   
	- [`screenshots/test_results/validation`](screenshots/test_results/4_validation_data_test.png) – output of the validation queries showing row counts for each table.



