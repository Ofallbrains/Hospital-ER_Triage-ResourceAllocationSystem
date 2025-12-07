# Phase V: Table Implementation & Data Insertion

## 1. Objective

Build the physical Oracle database structure for the Hospital ER Triage and Resource Allocation System and populate it with realistic test data to support validation and analysis.

---

## 2. Scripts Overview

- `phase5_create_tables.sql`  
  - Creates all tables derived from the logical ERD.  
  - Enforces primary keys, foreign keys, and CHECK / UNIQUE constraints.  
  - Assigns tables to `er_data_tbs` and indexes to `er_index_tbs`.

- `phase5_insert_data.sql`  
  - Inserts realistic sample data across main tables (patients, staff, arrivals, treatment sessions, meds, supplies, alerts).  
  - Includes edge cases such as patients without email, arrivals with no bed yet, and a "LeftWithoutBeingSeen" outcome.

- `phase5_validation_queries.sql`  
  - Contains SELECT, JOIN, GROUP BY, and subquery examples used to verify referential integrity and business rules.

All scripts assume connection as `DENYSE_ADMIN` in the PDB `mon_12345_denyse_ertriage_db`.

---

## 3. How to Run the Scripts

1. Connect to the PDB as the application admin user:

```sql
sqlplus DENYSE_ADMIN/Denyse@localhost:1521/mon_12345_denyse_ertriage_db
```

2. Create tables and constraints:

```sql
@c:/Users/Denyse/Documents/Mine/Hospital-ER_Triage-ResourceAllocationSystem/phase5_create_tables.sql
```

3. Insert sample data:

```sql
@c:/Users/Denyse/Documents/Mine/Hospital-ER_Triage-ResourceAllocationSystem/phase5_insert_data.sql
```

4. Run validation and testing queries:

```sql
@c:/Users/Denyse/Documents/Mine/Hospital-ER_Triage-ResourceAllocationSystem/phase5_validation_queries.sql
```

You can also copy individual queries from `phase5_validation_queries.sql` into SQL*Plus or SQL Developer and run them interactively.

---

## 4. Mapping to Requirements

### 4.1 Table Creation

- **All entities converted to tables:** `patients`, `triage_levels`, `medical_staffs`, `shifts`, `er_beds`, `medical_equipments`, `er_arrivals`, `er_meds`, `treatment_sessions`, `medications_administered`, `supplies`, `supply_inventory`, `critical_alerts`.  
- **Oracle data types used correctly:** `NUMBER`, `VARCHAR2`, and `DATE` chosen based on attribute semantics.  
- **PKs and FKs enforced:** Each table has a `PRIMARY KEY`; foreign keys reflect the ERD relationships.  
- **Indexes created appropriately:** Indexes are created on key foreign key columns and common search columns (e.g., patient last name, triage level, session IDs).  
- **Constraints set:** NOT NULL, UNIQUE, CHECK (e.g., gender, role, status, severity), and default values (e.g., `created_at`, status flags).

### 4.2 Data Insertion

- **Realistic rows:** Patients, staff, beds, medicines, supplies, arrivals, sessions, meds administered, inventory, and alerts resemble real ER usage.  
- **Edge cases and nulls:** Includes patients without email, arrivals with no bed or doctor yet, and an arrival with status `LeftWithoutBeingSeen`.  
- **Demographic mix:** Different ages, genders, and cities represented.  
- **Business rules validation:** Insert statements use subqueries to respect FK relationships (no orphan records).

### 4.3 Data Integrity Verification

- **SELECT queries:** Basic SELECTs from major tables confirm rows loaded.  
- **Constraints:** Attempted invalid inserts (commented) would violate CHECK/FK rules if executed.  
- **Foreign keys:** Joins between arrivals, patients, staff, triage levels, and sessions show consistent relationships.  
- **Completeness:** Query for "arrivals without treatment sessions" highlights gaps such as patients who left without being seen.

### 4.4 Testing Queries

- **Basic retrieval:** `SELECT *` from core tables.  
- **Joins:** Multi-table joins to show triage details, medications given, and outcomes.  
- **Aggregations:** `GROUP BY` queries for arrivals by triage level and average length of stay by disposition.  
- **Subqueries:** Identify patients who received specific medications (e.g., Morphine).

These artifacts together complete Phase V: physical table implementation, data loading, and validation in Oracle.
