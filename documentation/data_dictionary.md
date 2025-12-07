# Data Dictionary
---

## Data Dictionary Format

| Table | Column | Type | Constraints | Purpose |
|-------|--------|------|-------------|---------|
| TRIAGE_LEVELS | triage_level_id | NUMBER | PK, NOT NULL | Unique identifier for triage level |
| TRIAGE_LEVELS | triage_name | VARCHAR2(20) | NOT NULL, UNIQUE | Name of triage level (Critical, Urgent, Semi-Urgent, Non-Urgent) |
| TRIAGE_LEVELS | priority_order | NUMBER | NOT NULL, CHECK (1-4) | Priority ranking (1=highest, 4=lowest) |
| TRIAGE_LEVELS | avg_wait_minutes | NUMBER | | Average expected wait time in minutes |
| PATIENTS | patient_id | NUMBER | PK, NOT NULL | Unique patient identifier |
| PATIENTS | national_id | VARCHAR2(20) | NOT NULL, UNIQUE | National identification number |
| PATIENTS | first_name | VARCHAR2(50) | NOT NULL | Patient's first name |
| PATIENTS | last_name | VARCHAR2(50) | NOT NULL | Patient's last name |
| PATIENTS | date_of_birth | DATE | NOT NULL | Patient's date of birth |
| PATIENTS | gender | VARCHAR2(10) | CHECK (Male/Female/Other) | Patient's gender |
| PATIENTS | phone_number | VARCHAR2(20) | | Contact phone number |
| PATIENTS | email | VARCHAR2(100) | | Email address |
| PATIENTS | address_line1 | VARCHAR2(100) | | Primary address line |
| PATIENTS | city | VARCHAR2(50) | | City of residence |
| PATIENTS | created_date | DATE | DEFAULT SYSDATE | Record creation timestamp |
| MEDICAL_STAFFS | staff_id | NUMBER | PK, NOT NULL | Unique staff identifier |
| MEDICAL_STAFFS | staff_number | VARCHAR2(20) | NOT NULL, UNIQUE | Employee staff number |
| MEDICAL_STAFFS | first_name | VARCHAR2(50) | NOT NULL | Staff member's first name |
| MEDICAL_STAFFS | last_name | VARCHAR2(50) | NOT NULL | Staff member's last name |
| MEDICAL_STAFFS | role | VARCHAR2(30) | NOT NULL, CHECK | Staff role (Triage Nurse, ER Physician, Bed Manager, Support Staff) |
| MEDICAL_STAFFS | department | VARCHAR2(50) | | Department assignment |
| MEDICAL_STAFFS | phone_number | VARCHAR2(20) | | Contact phone number |
| MEDICAL_STAFFS | email | VARCHAR2(100) | | Email address |
| MEDICAL_STAFFS | active_flag | CHAR(1) | DEFAULT 'Y', CHECK (Y/N) | Active employment status |
| SHIFTS | shift_id | NUMBER | PK, NOT NULL | Unique shift identifier |
| SHIFTS | staff_id | NUMBER | NOT NULL, FK | Reference to medical_staffs table |
| SHIFTS | shift_start | DATE | NOT NULL | Shift start date/time |
| SHIFTS | shift_end | DATE | NOT NULL | Shift end date/time |
| ER_BEDS | bed_id | NUMBER | PK, NOT NULL | Unique bed identifier |
| ER_BEDS | bed_code | VARCHAR2(20) | NOT NULL, UNIQUE | Bed identification code (e.g., ER-BED-01) |
| ER_BEDS | location_zone | VARCHAR2(30) | NOT NULL | Physical location zone in ER |
| ER_BEDS | is_isolation | CHAR(1) | DEFAULT 'N', CHECK (Y/N) | Isolation capability flag |
| ER_BEDS | status | VARCHAR2(20) | DEFAULT 'Available', CHECK | Current bed status (Available, Occupied, Cleaning, OutOfService) |
| MEDICAL_EQUIPMENTS | equipment_id | NUMBER | PK, NOT NULL | Unique equipment identifier |
| MEDICAL_EQUIPMENTS | equipment_code | VARCHAR2(30) | NOT NULL, UNIQUE | Equipment identification code |
| MEDICAL_EQUIPMENTS | name | VARCHAR2(100) | NOT NULL | Equipment name/description |
| MEDICAL_EQUIPMENTS | status | VARCHAR2(20) | DEFAULT 'Available', CHECK | Current equipment status (Available, InUse, Maintenance, OutOfService) |
| MEDICAL_EQUIPMENTS | location | VARCHAR2(50) | | Physical storage location |
| SUPPLIES | supply_id | NUMBER | PK, NOT NULL | Unique supply identifier |
| SUPPLIES | supply_name | VARCHAR2(100) | NOT NULL | Supply item name |
| SUPPLIES | category | VARCHAR2(50) | | Supply category classification |
| SUPPLIES | unit_of_measure | VARCHAR2(20) | | Unit for quantity tracking (each, box, liter) |
| SUPPLY_INVENTORY | inventory_id | NUMBER | PK, NOT NULL | Unique inventory record identifier |
| SUPPLY_INVENTORY | supply_id | NUMBER | NOT NULL, FK | Reference to supplies table |
| SUPPLY_INVENTORY | quantity_in_stock | NUMBER | DEFAULT 0 | Current quantity available |
| SUPPLY_INVENTORY | reorder_level | NUMBER | | Minimum quantity before reorder |
| SUPPLY_INVENTORY | last_updated | DATE | DEFAULT SYSDATE | Last inventory update timestamp |
| MEDICATIONS_ADMINISTERED | administration_id | NUMBER | PK, NOT NULL | Unique administration record identifier |
| MEDICATIONS_ADMINISTERED | patient_id | NUMBER | NOT NULL, FK | Reference to patients table |
| MEDICATIONS_ADMINISTERED | medication_id | NUMBER | NOT NULL, FK | Reference to er_meds table |
| MEDICATIONS_ADMINISTERED | staff_id | NUMBER | NOT NULL, FK | Reference to medical_staffs table |
| MEDICATIONS_ADMINISTERED | dosage | VARCHAR2(50) | | Dosage amount and unit |
| MEDICATIONS_ADMINISTERED | administration_datetime | DATE | DEFAULT SYSDATE | Date/time medication was administered |
| ER_ARRIVALS | arrival_id | NUMBER | PK, NOT NULL | Unique arrival identifier |
| ER_ARRIVALS | patient_id | NUMBER | NOT NULL, FK | Reference to patients table |
| ER_ARRIVALS | triage_level_id | NUMBER | NOT NULL, FK | Reference to triage_levels table |
| ER_ARRIVALS | arrival_datetime | DATE | DEFAULT SYSDATE, NOT NULL | Arrival timestamp |
| ER_ARRIVALS | chief_complaint | VARCHAR2(200) | | Primary reason for visit |
| ER_ARRIVALS | arrival_status | VARCHAR2(20) | DEFAULT 'Waiting', CHECK | Current patient status (Waiting, In Treatment, Discharged, Left AMA) |
| ER_ARRIVALS | assigned_bed_id | NUMBER | FK | Reference to er_beds table |
| TREATMENT_SESSIONS | session_id | NUMBER | PK, NOT NULL | Unique session identifier |
| TREATMENT_SESSIONS | arrival_id | NUMBER | NOT NULL, FK | Reference to er_arrivals table |
| TREATMENT_SESSIONS | staff_id | NUMBER | NOT NULL, FK | Reference to medical_staffs table |
| TREATMENT_SESSIONS | bed_id | NUMBER | FK | Reference to er_beds table |
| TREATMENT_SESSIONS | treatment_start | DATE | DEFAULT SYSDATE | Session start timestamp |
| TREATMENT_SESSIONS | treatment_end | DATE | | Session end timestamp |
| TREATMENT_SESSIONS | treatment_status | VARCHAR2(20) | CHECK | Current session status |
| TREATMENT_SESSIONS | notes | VARCHAR2(500) | | Treatment notes |
| CRITICAL_ALERTS | alert_id | NUMBER | PK, NOT NULL | Unique alert identifier |
| CRITICAL_ALERTS | arrival_id | NUMBER | NOT NULL, FK | Reference to er_arrivals table |
| CRITICAL_ALERTS | alert_type | VARCHAR2(50) | NOT NULL | Type of critical alert |
| CRITICAL_ALERTS | alert_datetime | DATE | DEFAULT SYSDATE | Alert creation timestamp |
| CRITICAL_ALERTS | is_resolved | CHAR(1) | DEFAULT 'N', CHECK (Y/N) | Resolution status flag |
| CRITICAL_ALERTS | assigned_staff_id | NUMBER | FK | Reference to medical_staffs table |
| ER_MEDS | medication_id | NUMBER | PK, NOT NULL | Unique medication identifier |
| ER_MEDS | medication_name | VARCHAR2(100) | NOT NULL | Medication name |
| ER_MEDS | category | VARCHAR2(50) | | Medication category |
| PUBLIC_HOLIDAYS | holiday_id | NUMBER | PK, NOT NULL | Unique holiday identifier |
| PUBLIC_HOLIDAYS | holiday_date | DATE | NOT NULL, UNIQUE | Date of public holiday |
| PUBLIC_HOLIDAYS | holiday_name | VARCHAR2(100) | NOT NULL | Holiday name/description |
| PUBLIC_HOLIDAYS | created_date | DATE | DEFAULT SYSDATE | Record creation timestamp |
| EMPLOYEE_ACTION_AUDIT | audit_id | NUMBER | PK, NOT NULL | Unique audit record identifier |
| EMPLOYEE_ACTION_AUDIT | audit_time | DATE | DEFAULT SYSDATE, NOT NULL | Timestamp of action attempt |
| EMPLOYEE_ACTION_AUDIT | username | VARCHAR2(100) | NOT NULL | Database user who performed action |
| EMPLOYEE_ACTION_AUDIT | action_type | VARCHAR2(20) | NOT NULL | Type of DML operation (INSERT/UPDATE/DELETE) |
| EMPLOYEE_ACTION_AUDIT | table_name | VARCHAR2(100) | NOT NULL | Target table name |
| EMPLOYEE_ACTION_AUDIT | action_status | VARCHAR2(20) | NOT NULL | Result status (ALLOWED/DENIED) |
| EMPLOYEE_ACTION_AUDIT | error_message | VARCHAR2(4000) | | Error details if DENIED |
| EMPLOYEE_ACTION_AUDIT | session_info | VARCHAR2(500) | | Session ID and host information |

---

## Additional Documentation

### Procedures with Parameters

**Package:** PKG_ER_TRIAGE_MGMT

1. **proc_check_in_patient**
   - Parameters: p_national_id, p_triage_level_id, p_chief_complaint, p_arrival_id (OUT)
   - Purpose: Register patient arrival in ER

2. **proc_assign_bed**
   - Parameters: p_arrival_id, p_bed_id
   - Purpose: Assign available bed to patient

3. **proc_start_treatment**
   - Parameters: p_arrival_id, p_staff_id, p_bed_id, p_session_id (OUT)
   - Purpose: Begin treatment session

4. **proc_flag_long_waits**
   - Parameters: p_wait_threshold (default 60 minutes)
   - Purpose: Generate alerts for patients waiting too long

5. **proc_discharge_patient**
   - Parameters: p_arrival_id, p_session_id
   - Purpose: Complete patient discharge process

**Standalone Procedures:**

6. **proc_log_employee_action**
   - Parameters: p_username, p_action_type, p_table_name, p_action_status, p_error_message, p_session_info
   - Purpose: Log DML operations to audit trail with autonomous transaction

---

### Functions with Return Types

1. **fn_is_weekday(p_check_date DATE) RETURN BOOLEAN**
   - Returns TRUE if date is Monday-Friday, FALSE otherwise

2. **fn_is_holiday(p_check_date DATE) RETURN BOOLEAN**
   - Returns TRUE if date exists in PUBLIC_HOLIDAYS table

3. **fn_get_wait_time_minutes(p_arrival_id NUMBER) RETURN NUMBER**
   - Returns wait time in minutes for given arrival

4. **fn_is_valid_status(p_status VARCHAR2) RETURN BOOLEAN**
   - Validates status values against allowed values

5. **fn_get_available_beds(p_isolation_required CHAR) RETURN NUMBER**
   - Returns count of available beds, optionally filtered by isolation requirement

6. **fn_calculate_age(p_date_of_birth DATE) RETURN NUMBER**
   - Calculates patient age in years from date of birth

---

### Triggers with Logic Explanation

1. **trg_medical_staffs_restrict**
   - Type: BEFORE INSERT OR UPDATE OR DELETE, FOR EACH ROW
   - Logic: Checks if current date is weekday using fn_is_weekday() and fn_is_holiday(), raises error if true, logs attempt to audit trail
   - Purpose: Prevent DML on MEDICAL_STAFFS during weekdays/holidays

2. **trg_er_beds_restrict**
   - Type: BEFORE INSERT OR UPDATE OR DELETE, FOR EACH ROW
   - Logic: Checks if current date is weekday using fn_is_weekday() and fn_is_holiday(), raises error if true, logs attempt to audit trail
   - Purpose: Prevent DML on ER_BEDS during weekdays/holidays

3. **trg_patients_compound**
   - Type: COMPOUND TRIGGER (BEFORE STATEMENT, BEFORE EACH ROW, AFTER STATEMENT)
   - Logic: Statement-level weekday check, row-level processing, statement-level audit logging using shared variables
   - Purpose: Prevent DML on PATIENTS during weekdays/holidays with compound trigger demonstration

---

### Analytics Queries (Window Functions & Aggregations)

**Available in:** `queries/analytics_queries.sql`

1. Patient arrival rankings by triage priority
2. Wait time gap analysis using LAG()
3. Cumulative patient counts by day
4. Staff workload ranking using RANK()
5. Treatment duration percentiles using NTILE()
6. Moving averages for daily arrivals
7. First/last arrivals per day using FIRST_VALUE()/LAST_VALUE()
8. Running totals with window frames
9. Partition-based aggregations
10. Time-series analysis with window functions

---

## Naming Conventions

- **Tables:** Uppercase with underscores (SNAKE_CASE), plural nouns
- **Columns:** Lowercase with underscores (snake_case)
- **Primary Keys:** tablename_id (e.g., patient_id)
- **Foreign Keys:** referenced_table_id (e.g., patient_id in ER_ARRIVALS)
- **Constraints:** pk_tablename, fk_table_reference, uq_table_column, ck_table_column
- **Indexes:** idx_table_column, pk_tablename, uq_table_column
- **Flags:** suffix _flag (e.g., active_flag, is_isolation)
- **Timestamps:** suffix _datetime or _date (e.g., arrival_datetime)

---

