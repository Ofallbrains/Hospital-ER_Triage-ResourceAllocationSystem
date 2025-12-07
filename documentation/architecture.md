# System Architecture
---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Database Architecture](#database-architecture)
3. [Physical Architecture](#physical-architecture)
4. [Logical Architecture](#logical-architecture)
5. [PL/SQL Components](#plsql-components)
6. [Security Architecture](#security-architecture)
7. [Integration Points](#integration-points)

---

## Architecture Overview

### System Purpose
The Hospital ER Triage & Resource Allocation System provides a comprehensive database solution for managing emergency room operations including patient triage, resource allocation, staff scheduling, and comprehensive auditing.

### Architecture Style
- **Type:** Three-tier database-centric architecture
- **Database:** Oracle 21c Pluggable Database (PDB)
- **Access Layer:** SQL*Plus, SQL Developer, future APEX interface
- **Business Logic:** PL/SQL packages, procedures, functions, and triggers
- **Data Layer:** Normalized relational schema with 15 tables

### Key Architectural Principles
1. **Separation of Concerns:** Data, logic, and presentation layers
2. **Data Integrity:** Comprehensive constraints and validation
3. **Audit Trail:** Autonomous transaction logging
4. **Scalability:** Tablespace separation and index optimization
5. **Security:** Role-based access control and trigger restrictions

---

## Database Architecture

### Container Database (CDB) Structure

```
Oracle XE 21c
├── CDB$ROOT (Container Database)
│   ├── PDB$SEED (Template PDB)
│   └── mon_27976_denyse_ertriage_db (Application PDB)
│       ├── DENYSE_ADMIN (Schema Owner)
│       ├── Tablespaces
│       │   ├── ER_DATA_TBS (Tables & Data)
│       │   └── ER_INDEX_TBS (Indexes)
│       ├── Tables (15)
│       ├── Indexes (25+)
│       ├── Sequences (15 IDENTITY columns)
│       ├── Constraints (50+)
│       ├── PL/SQL Package (1)
│       ├── Procedures (5)
│       ├── Functions (6)
│       └── Triggers (3)
```

### Pluggable Database (PDB) Configuration

**PDB Name:** `mon_27976_denyse_ertriage_db`

**Connection String:**
```
localhost:1521/mon_27976_denyse_ertriage_db
```

**Admin User:** `DENYSE_ADMIN`

**Privileges:**
- CREATE SESSION
- CREATE TABLE, VIEW, SEQUENCE
- CREATE PROCEDURE, FUNCTION, TRIGGER
- UNLIMITED quota on ER_DATA_TBS and ER_INDEX_TBS

---

## Physical Architecture

### Tablespace Design

#### 1. ER_DATA_TBS (Data Tablespace)
**Purpose:** Store all table data  
**Datafile:** `er_data_01.dbf`  
**Initial Size:** 100 MB  
**Autoextend:** ON (10 MB increments)  
**Max Size:** UNLIMITED  
**Management:** LOCAL, AUTO

**Contains:**
- All 15 application tables
- Table segments and partitions
- LOB segments (if any)

#### 2. ER_INDEX_TBS (Index Tablespace)
**Purpose:** Store all indexes separately  
**Datafile:** `er_index_01.dbf`  
**Initial Size:** 50 MB  
**Autoextend:** ON (5 MB increments)  
**Max Size:** UNLIMITED  
**Management:** LOCAL, AUTO

**Contains:**
- Primary key indexes
- Foreign key indexes
- Unique constraint indexes
- Business key indexes

**Benefits of Separation:**
- Independent I/O optimization
- Simplified backup and recovery
- Better performance monitoring
- Reduced contention

### Storage Architecture Diagram

```
┌─────────────────────────────────────────┐
│     Oracle Database XE 21c (CDB)        │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  mon_27976_denyse_ertriage_db    │ │
│  │         (PDB)                     │ │
│  ├───────────────────────────────────┤ │
│  │                                   │ │
│  │  ┌──────────────┐ ┌────────────┐ │ │
│  │  │ ER_DATA_TBS  │ │ER_INDEX_TBS│ │ │
│  │  ├──────────────┤ ├────────────┤ │ │
│  │  │   Tables     │ │  Indexes   │ │ │
│  │  │   (15)       │ │  (25+)     │ │ │
│  │  └──────────────┘ └────────────┘ │ │
│  │                                   │ │
│  │  ┌───────────────────────────┐   │ │
│  │  │   PL/SQL Objects          │   │ │
│  │  ├───────────────────────────┤   │ │
│  │  │ • Package (1)             │   │ │
│  │  │ • Procedures (5)          │   │ │
│  │  │ • Functions (6)           │   │ │
│  │  │ • Triggers (3)            │   │ │
│  │  └───────────────────────────┘   │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Logical Architecture

### Entity Relationship Model

#### Core Entity Groups

**1. Patient Management**
- PATIENTS (demographics)
- ER_ARRIVALS (visits)
- TREATMENT_SESSIONS (treatments)
- CRITICAL_ALERTS (escalations)

**2. Resource Management**
- ER_BEDS (bed inventory)
- MEDICAL_EQUIPMENTS (equipment)
- SUPPLIES (supply catalog)
- SUPPLY_INVENTORY (stock levels)
- ER_MEDS (medications)

**3. Staff Management**
- MEDICAL_STAFFS (employees)
- SHIFTS (schedules)

**4. Configuration & Audit**
- TRIAGE_LEVELS (severity levels)
- PUBLIC_HOLIDAYS (calendar)
- EMPLOYEE_ACTION_AUDIT (audit trail)

### Relationship Cardinalities

```
PATIENTS (1) ──< (M) ER_ARRIVALS
ER_ARRIVALS (1) ──< (M) TREATMENT_SESSIONS
ER_ARRIVALS (1) ──< (M) CRITICAL_ALERTS
MEDICAL_STAFFS (1) ──< (M) SHIFTS
MEDICAL_STAFFS (1) ──< (M) TREATMENT_SESSIONS
TRIAGE_LEVELS (1) ──< (M) ER_ARRIVALS
ER_BEDS (1) ──< (M) ER_ARRIVALS
ER_BEDS (1) ──< (M) TREATMENT_SESSIONS
SUPPLIES (1) ──< (M) SUPPLY_INVENTORY
PATIENTS (1) ──< (M) MEDICATIONS_ADMINISTERED
MEDICAL_STAFFS (1) ──< (M) MEDICATIONS_ADMINISTERED
ER_MEDS (1) ──< (M) MEDICATIONS_ADMINISTERED
```

### Data Flow Diagram

```
┌──────────────┐
│   Patient    │ Arrives
│   Arrival    │──────────┐
└──────────────┘          │
                          ↓
                  ┌───────────────┐
                  │  Triage       │
                  │  Assessment   │
                  └───────┬───────┘
                          │
                ┌─────────┴─────────┐
                │                   │
            Critical?             Assign
                │               Priority
                ↓                   ↓
        ┌──────────────┐    ┌──────────────┐
        │ Create Alert │    │ Assign Bed   │
        └──────────────┘    └──────┬───────┘
                                   │
                                   ↓
                          ┌─────────────────┐
                          │ Treatment       │
                          │ Session         │
                          └────────┬────────┘
                                   │
                                   ↓
                          ┌─────────────────┐
                          │ Discharge/      │
                          │ Disposition     │
                          └─────────────────┘
```

---

## PL/SQL Components

### Package: PKG_ER_TRIAGE_MGMT

**Purpose:** Centralized business logic for ER operations

**Structure:**
```
PKG_ER_TRIAGE_MGMT
├── Package Specification (Public Interface)
│   ├── Procedures
│   │   ├── proc_register_arrival
│   │   ├── proc_update_arrival_status
│   │   ├── proc_discharge_patient
│   │   └── proc_flag_long_waits
│   └── Functions
│       ├── fn_calc_wait_minutes
│       ├── fn_is_valid_status
│       ├── fn_get_triage_name
│       └── fn_patient_visit_count
└── Package Body (Implementation)
    ├── Private Variables
    ├── Exception Declarations
    ├── Explicit Cursors
    └── Implementation Code
```

**Features:**
- Exception handling with custom exceptions
- Explicit cursor for multi-row processing
- Window functions (RANK, LAG)
- Audit logging integration

### Standalone Functions

**1. fn_is_weekday(DATE) RETURNS BOOLEAN**
- Checks if date is Monday-Friday
- Used by triggers for business rule enforcement

**2. fn_is_holiday(DATE) RETURNS BOOLEAN**
- Checks if date exists in PUBLIC_HOLIDAYS
- Used by triggers for holiday restrictions

### Standalone Procedures

**proc_log_employee_action(...)**
- Autonomous transaction logging
- Persists audit records even on ROLLBACK
- PRAGMA AUTONOMOUS_TRANSACTION

### Trigger Architecture

```
┌──────────────────────────────────────────┐
│         Trigger Layer                    │
├──────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  Simple Row-Level Triggers         │ │
│  ├────────────────────────────────────┤ │
│  │  • trg_medical_staffs_restrict     │ │
│  │  • trg_er_beds_restrict            │ │
│  ├────────────────────────────────────┤ │
│  │  Timing: BEFORE INSERT/UPDATE/DEL  │ │
│  │  Logic: Check weekday/holiday      │ │
│  │  Action: RAISE_APPLICATION_ERROR   │ │
│  │  Logging: proc_log_employee_action │ │
│  └────────────────────────────────────┘ │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  Compound Trigger                  │ │
│  ├────────────────────────────────────┤ │
│  │  • trg_patients_compound           │ │
│  ├────────────────────────────────────┤ │
│  │  Sections:                         │ │
│  │    - BEFORE STATEMENT              │ │
│  │    - BEFORE EACH ROW               │ │
│  │    - AFTER STATEMENT               │ │
│  ├────────────────────────────────────┤ │
│  │  Shared Variables Across Sections  │ │
│  │  Statement-level Restriction Check │ │
│  └────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

---

## Security Architecture

### Authentication & Authorization

**User Management:**
```
DENYSE_ADMIN (Schema Owner)
├── System Privileges
│   ├── CREATE SESSION
│   ├── CREATE TABLE
│   ├── CREATE VIEW
│   ├── CREATE SEQUENCE
│   ├── CREATE PROCEDURE
│   ├── CREATE TRIGGER
│   └── CREATE SYNONYM
├── Object Privileges
│   ├── UNLIMITED QUOTA on ER_DATA_TBS
│   ├── UNLIMITED QUOTA on ER_INDEX_TBS
│   └── EXECUTE on DBMS packages
└── Role
    └── RESOURCE
```

### Business Rule Enforcement

**Trigger-Based Access Control:**
- **Restricted Days:** Monday through Friday (weekdays)
- **Holiday Restrictions:** Dates in PUBLIC_HOLIDAYS table
- **Allowed Operations:** SELECT (always), DML on weekends only
- **Protected Tables:** MEDICAL_STAFFS, ER_BEDS, PATIENTS

**Error Handling:**
- Custom error codes: -20001 (weekday), -20002 (holiday)
- Descriptive error messages
- Automatic audit logging

### Audit Trail Architecture

```
┌────────────────────────────────────────────┐
│        DML Attempt                         │
└─────────────────┬──────────────────────────┘
                  │
                  ↓
        ┌─────────────────────┐
        │   Trigger Fired     │
        └──────────┬──────────┘
                   │
        ┌──────────┴───────────┐
        │                      │
    Weekday?              Holiday?
        │                      │
    ┌───┴───┐            ┌────┴────┐
    YES    NO             YES      NO
     │      │              │        │
     ↓      │              ↓        │
  ┌──────┐  │          ┌──────┐    │
  │ DENY │  │          │ DENY │    │
  └──┬───┘  │          └──┬───┘    │
     │      │             │         │
     └──────┴─────────────┴─────────┘
                   │
                   ↓
        ┌──────────────────────┐
        │ proc_log_employee_   │
        │   action()           │
        │ (Autonomous Txn)     │
        └──────────┬───────────┘
                   │
                   ↓
        ┌──────────────────────┐
        │ EMPLOYEE_ACTION_     │
        │   AUDIT              │
        │ (Permanent Record)   │
        └──────────────────────┘
```

---

## Integration Points

### Current Integrations
1. **SQL Developer:** Primary development and administration interface
2. **SQL*Plus:** Command-line access for scripting
3. **JDBC/ODBC:** Standard database connectivity protocols

### Future Integration Opportunities
1. **Oracle APEX:** Web-based ER dashboard and forms
2. **Hospital Information System (HIS):** Patient data synchronization
3. **Laboratory Systems:** Test result integration
4. **Pharmacy Systems:** Medication dispensing
5. **Radiology Systems:** Imaging orders and results
6. **Billing Systems:** Charge capture and billing
7. **Electronic Health Records (EHR):** Patient medical history
8. **Mobile Applications:** Staff scheduling and notifications

### API Design Considerations

**Proposed REST API Layer:**
```
/api/v1/
├── patients/
│   ├── GET /patients
│   ├── POST /patients
│   ├── GET /patients/{id}
│   └── PUT /patients/{id}
├── arrivals/
│   ├── GET /arrivals
│   ├── POST /arrivals
│   ├── GET /arrivals/{id}
│   └── PUT /arrivals/{id}/status
├── beds/
│   ├── GET /beds
│   ├── GET /beds/available
│   └── PUT /beds/{id}/status
├── staff/
│   ├── GET /staff
│   └── GET /staff/{id}/schedule
└── audit/
    ├── GET /audit/logs
    └── GET /audit/statistics
```

---

## Performance Considerations

### Indexing Strategy
- **Primary Keys:** Automatic B-tree indexes on all PKs
- **Foreign Keys:** Explicit indexes on all FK columns
- **Business Keys:** Unique indexes on natural keys
- **Query Optimization:** Analyze query patterns and add covering indexes

### Query Optimization
- **Window Functions:** Efficient ranking and gap analysis
- **Partitioning (Future):** Range partition ER_ARRIVALS by arrival_datetime
- **Materialized Views (Future):** Pre-aggregate statistics
- **Result Caching:** Oracle result cache for reference data

### Monitoring Strategy
- **AWR Reports:** Weekly performance analysis
- **SQL Trace:** Identify slow queries
- **Tablespace Monitoring:** Track growth and fragmentation
- **Index Usage:** Identify unused indexes

---

## Scalability Architecture

### Horizontal Scalability
- **Read Replicas:** Oracle Active Data Guard (future)
- **Sharding:** Partition by hospital location (multi-site)

### Vertical Scalability
- **Memory:** Increase SGA/PGA for larger workloads
- **Storage:** Add datafiles to tablespaces
- **CPU:** Oracle automatically leverages multi-core

### High Availability
- **Backup Strategy:** RMAN daily full backups
- **Recovery:** Point-in-time recovery capability
- **Failover:** Oracle Data Guard (future)

---

## Deployment Architecture

### Development Environment
- **Database:** Oracle XE 21c on Windows
- **Tools:** SQL Developer, SQL*Plus
- **Version Control:** GitHub repository

### Production Considerations (Future)
- **Database:** Oracle Standard/Enterprise Edition
- **OS:** Linux (RHEL/Oracle Linux)
- **Storage:** SAN/NAS with RAID configuration
- **Backup:** RMAN to network storage
- **Monitoring:** Oracle Enterprise Manager (OEM)

---

## Architecture Evolution

### Current State (Phase I-VII Complete)
- ✅ Database and tablespace creation
- ✅ Schema design and implementation
- ✅ PL/SQL packages, procedures, functions
- ✅ Triggers and business rules
- ✅ Comprehensive auditing
- ✅ Sample data and testing

### Future Enhancements
- 🔄 Oracle APEX web interface
- 🔄 RESTful API layer
- 🔄 Real-time dashboards
- 🔄 Mobile application
- 🔄 Integration with external systems
- 🔄 Advanced analytics and reporting
- 🔄 Machine learning for predictive analytics


