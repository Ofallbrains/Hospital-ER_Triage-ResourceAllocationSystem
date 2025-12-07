# Phase III: Logical Model Design – Hospital ER Triage System

## 1. Objective

Design a detailed logical data model (minimum 3NF) to support the Emergency Room (ER) triage and resource allocation processes modeled in Phase II.

---

## 2. Entity–Relationship Model Overview

The logical model is centered around ER visits and treatment events, with supporting reference data for triage levels, staff, beds, equipment, medications, supplies, and alerts.

### 2.1 Core Entities

- **PATIENTS** – Stores demographic and contact information for each patient.
- **ER_ARRIVALS** – Represents a single ER visit/arrival for a patient, including vitals and triage results.
- **TRIAGE_LEVELS** – Lookup for Emergency Severity Index (ESI) levels with priority and maximum wait time.
- **MEDICAL_STAFFS** – Doctors, nurses, triage nurses and other ER staff.
- **SHIFTS** – Defines staff shifts (date and start/end times).
- **ER_BEDS** – Each physical bed in the ER with zone, type and occupancy status.
- **MEDICAL_EQUIPMENTS** – ER equipment (monitors, ventilators, etc.) with status and maintenance information.
- **TREATMENT_SESSIONS** – A treatment episode during an ER visit for a specific patient, performed by staff and using a bed.
- **ER_MEDS** – Master list of medications available in the ER.
- **MEDICATIONS_ADMINISTERED** – Individual medication doses given during treatment sessions.
- **SUPPLIES** – Suppliers/vendors that provide inventory.
- **SUPPLY_INVENTORY** – Current stock of supplies and their quantities.
- **CRITICAL_ALERTS** – Alerts raised for high-risk patients/visits (e.g., code blue, sepsis alert).

### 2.2 Key Relationships and Cardinalities

- **PATIENTS (1) → (N) ER_ARRIVALS**  
  One patient can have many ER arrivals over time; each arrival belongs to exactly one patient.

- **TRIAGE_LEVELS (1) → (N) ER_ARRIVALS**  
  Each ER arrival is assigned exactly one triage level (ESI 1–5).

- **PATIENTS (1) → (N) TREATMENT_SESSIONS**  
  A patient may have multiple treatment sessions during or across visits.

- **ER_ARRIVALS (1) → (N) TREATMENT_SESSIONS**  
  A single ER arrival can include several treatment sessions (e.g., before and after tests).

- **ER_BEDS (1) → (N) TREATMENT_SESSIONS**  
  A bed can be used in many treatment sessions over time; each session uses one bed.

- **MEDICAL_STAFFS (1) → (N) TREATMENT_SESSIONS**  
  Staff act as doctor and/or nurse for many treatment sessions.

- **SHIFTS (1) → (N) MEDICAL_STAFFS**  
  Each staff member is assigned to a shift; many staff can share the same shift.

- **ER_MEDS (1) → (N) MEDICATIONS_ADMINISTERED**  
  A medication can be administered many times; each administration refers to one medication.

- **TREATMENT_SESSIONS (1) → (N) MEDICATIONS_ADMINISTERED**  
  Each treatment session may involve multiple medication administrations.

- **SUPPLIES (1) → (N) SUPPLY_INVENTORY**  
  Each supplier can provide many inventory items.

- **PATIENTS (1) → (N) CRITICAL_ALERTS**  
  A patient may have multiple alerts associated with different visits.

- **ER_ARRIVALS (1) → (N) CRITICAL_ALERTS**  
  Each alert is tied to a specific ER arrival.

- **MEDICAL_STAFFS (1) → (N) CRITICAL_ALERTS**  
  Staff acknowledge and resolve multiple alerts over time.

The ER diagram visually represents these entities, attributes, primary keys (PKs), foreign keys (FKs), and 1–to–many relationships.

---

## 3. Normalization (1NF, 2NF, 3NF)

### 3.1 First Normal Form (1NF)

The design satisfies 1NF because:

- Every table has a **primary key** that uniquely identifies each row.
- All attributes hold **atomic values** (no repeating groups or multi-valued columns).
- Repeating information is represented by separate rows in child tables.

**Example:**  
Multiple medications given to a patient are not stored in one row as `drug1, drug2, drug3`. Instead, each dose is recorded as a separate row in **MEDICATIONS_ADMINISTERED** with its own `med_admin_id`, referencing a single **TREATMENT_SESSION** and one **ER_MED**.

### 3.2 Second Normal Form (2NF)

The design satisfies 2NF because:

- All primary keys are **single-column surrogate keys** (e.g., `patient_id`, `arrival_id`, `session_id`), so there are no composite primary keys.
- Every non-key attribute in a table depends on the **whole primary key**, not on part of a key.

**Example:**  
In **ER_ARRIVALS**, attributes such as `chief_complaint`, `triage_score`, and `status` all depend solely on `arrival_id`. There is no attribute that depends only on a subset of a composite key, so partial dependencies are eliminated.

### 3.3 Third Normal Form (3NF)

The design satisfies 3NF because:

- Non-key attributes do **not depend on other non-key attributes**; they depend only on the primary key.
- Reference/lookup information is moved into separate tables and referenced via foreign keys.

**Examples:**

- Triage descriptions (`level_name`, `priority_score`, `max_wait_time_minutes`, `color_code`) are stored once in **TRIAGE_LEVELS** and referenced from **ER_ARRIVALS** using `triage_level_id`. This avoids repeating descriptive triage details in every arrival row.
- Supplier contact details (`supplier_name`, `contact_phone`, `contact_email`, `address`) are stored in **SUPPLIES** and not repeated in **SUPPLY_INVENTORY**. The inventory table only stores `supplier_id` as an FK.

By separating lookup entities and eliminating derived and transitive attributes, the schema avoids update, insertion and deletion anomalies, and thus meets 3NF.

### 3.4 Normalization Justification

The schema intentionally decomposes the ER triage domain into focused tables: **PATIENTS** for demographics, **ER_ARRIVALS** for individual visits, **TREATMENT_SESSIONS** for clinical episodes, **MEDICATIONS_ADMINISTERED** for many medication events, and separate lookup tables (**TRIAGE_LEVELS**, **ER_MEDS**, **SUPPLIES**) for relatively static reference data. Relationships are enforced via foreign keys instead of repeating descriptive attributes. This reduces redundancy, improves data integrity, and supports efficient querying across patients, visits, staff, beds, medications, and alerts.

---

## 4. Data Dictionary (Summary)

Below is a concise data dictionary for the main tables. Data types are expressed generically (can be mapped to Oracle types such as `NUMBER`, `VARCHAR2`, `DATE`, etc.).

### 4.1 PATIENTS

| Column                  | Type        | Key | Nullable | Description                          |
|-------------------------|------------|-----|----------|--------------------------------------|
| patient_id              | INTEGER    | PK  | NO       | Unique identifier for a patient      |
| national_id             | VARCHAR    |    | YES      | Government/national ID               |
| first_name              | VARCHAR    |    | NO       | Patient first name                   |
| last_name               | VARCHAR    |    | NO       | Patient last name                    |
| date_of_birth           | DATE       |    | NO       | Date of birth                        |
| gender                  | VARCHAR    |    | YES      | Gender                               |
| blood_type              | VARCHAR    |    | YES      | ABO/Rh blood group                   |
| medical_history         | VARCHAR    |    | YES      | Summary medical history              |
| allergies               | VARCHAR    |    | YES      | Known allergies                      |
| insurance_info          | VARCHAR    |    | YES      | Insurance / payer details            |
| emergency_contact_phone | VARCHAR    |    | YES      | Emergency contact phone              |

### 4.2 ER_ARRIVALS

| Column             | Type     | Key | Nullable | Description                                   |
|--------------------|----------|-----|----------|-----------------------------------------------|
| arrival_id         | INTEGER  | PK  | NO       | Unique identifier for an ER arrival           |
| patient_id         | INTEGER  | FK  | NO       | References `PATIENTS.patient_id`              |
| arrival_time       | DATE/TIMESTAMP | NO | NO   | Date/time patient arrives at ER               |
| chief_complaint    | VARCHAR  |     | NO       | Main reason for visit                         |
| heart_rate         | NUMBER   |     | YES      | Heart rate at triage                          |
| blood_pressure     | VARCHAR  |     | YES      | Blood pressure reading                        |
| oxygen_saturation  | NUMBER   |     | YES      | O2 saturation                                 |
| temperature        | NUMBER   |     | YES      | Body temperature                              |
| pain_level         | NUMBER   |     | YES      | Pain score (e.g., 0–10)                       |
| consciousness_level| VARCHAR  |     | YES      | Level of consciousness                        |
| triage_score       | NUMBER   |     | YES      | Calculated triage score                       |
| triage_level_id    | INTEGER  | FK  | NO       | References `TRIAGE_LEVELS.triage_level_id`    |
| status             | VARCHAR  |     | NO       | Current status (waiting, in treatment, closed)|

### 4.3 TRIAGE_LEVELS

| Column               | Type    | Key | Nullable | Description                         |
|----------------------|---------|-----|----------|-------------------------------------|
| triage_level_id      | INTEGER | PK  | NO       | ESI level identifier (1–5)         |
| level_name           | VARCHAR |     | NO       | Name (Critical/Emergent/etc.)      |
| priority_score       | NUMBER  |     | NO       | Numeric priority score             |
| max_wait_time_minutes| NUMBER  |     | NO       | Max recommended wait time in mins  |
| color_code           | VARCHAR |     | YES      | Color code used in dashboards      |

### 4.4 MEDICAL_STAFFS

| Column              | Type    | Key | Nullable | Description                             |
|---------------------|---------|-----|----------|-----------------------------------------|
| staff_id            | INTEGER | PK  | NO       | Unique staff identifier                 |
| first_name          | VARCHAR |     | NO       | Staff first name                        |
| last_name           | VARCHAR |     | NO       | Staff last name                         |
| role                | VARCHAR |     | NO       | Role (Doctor, Nurse, Triage Nurse, etc.)|
| specialization      | VARCHAR |     | YES      | Specialty (Emergency, Cardiology, etc.) |
| shift_id            | INTEGER | FK  | YES      | References `SHIFTS.shift_id`            |
| current_patient_load| NUMBER  |     | YES      | Number of patients currently assigned   |
| max_capacity        | NUMBER  |     | YES      | Maximum patients staff can safely handle|
| availability_status | VARCHAR |     | YES      | Available, Busy, Off-duty, etc.        |

### 4.5 SHIFTS

| Column     | Type    | Key | Nullable | Description                    |
|------------|---------|-----|----------|--------------------------------|
| shift_id   | INTEGER | PK  | NO       | Unique shift identifier        |
| shift_date | DATE    |     | NO       | Calendar date of the shift     |
| start_time | TIME    |     | NO       | Shift start time               |
| end_time   | TIME    |     | NO       | Shift end time                 |

### 4.6 ER_BEDS

| Column            | Type    | Key | Nullable | Description                                   |
|-------------------|---------|-----|----------|-----------------------------------------------|
| bed_id            | INTEGER | PK  | NO       | Unique bed identifier                         |
| zone              | VARCHAR |     | NO       | ER zone (Trauma, Cardiac, General, etc.)     |
| bed_type          | VARCHAR |     | YES      | Type (Isolation, Pediatric, etc.)            |
| occupancy_status  | VARCHAR |     | NO       | Free, Occupied, Cleaning, Out of service     |
| current_patient_id| INTEGER | FK  | YES      | Current occupant, references `PATIENTS`      |
| last_cleaned      | DATE    |     | YES      | Date of last cleaning                         |

### 4.7 TREATMENT_SESSIONS

| Column       | Type     | Key | Nullable | Description                                      |
|--------------|----------|-----|----------|--------------------------------------------------|
| session_id   | INTEGER  | PK  | NO       | Unique identifier for a treatment session        |
| arrival_id   | INTEGER  | FK  | NO       | References `ER_ARRIVALS.arrival_id`             |
| patient_id   | INTEGER  | FK  | NO       | References `PATIENTS.patient_id`                |
| doctor_id    | INTEGER  | FK  | YES      | Physician in charge, references `MEDICAL_STAFFS`|
| nurse_id     | INTEGER  | FK  | YES      | Primary nurse, references `MEDICAL_STAFFS`      |
| bed_id       | INTEGER  | FK  | YES      | Bed used, references `ER_BEDS.bed_id`           |
| start_time   | DATE/TIMESTAMP | | NO   | Session start time                              |
| end_time     | DATE/TIMESTAMP | | YES  | Session end time                                |
| treatment_type| VARCHAR |     | YES      | Type of treatment (evaluation, procedure, etc.) |
| diagnosis    | VARCHAR  |     | YES      | Working/final diagnosis                          |
| status       | VARCHAR  |     | NO       | Active, completed, cancelled                     |

### 4.8 ER_MEDS

| Column       | Type    | Key | Nullable | Description                       |
|--------------|---------|-----|----------|-----------------------------------|
| er_med_id    | INTEGER | PK  | NO       | Unique medication identifier      |
| generic_name | VARCHAR |     | NO       | Generic drug name                 |
| brand_name   | VARCHAR |     | YES      | Brand name                        |
| dosage_form  | VARCHAR |     | YES      | Form (tablet, IV, injection, etc.)|
| strength     | VARCHAR |     | YES      | Strength (e.g., 500mg)            |

### 4.9 MEDICATIONS_ADMINISTERED

| Column         | Type     | Key | Nullable | Description                                     |
|----------------|----------|-----|----------|-------------------------------------------------|
| med_admin_id   | INTEGER  | PK  | NO       | Unique ID for this administration event         |
| session_id     | INTEGER  | FK  | NO       | References `TREATMENT_SESSIONS.session_id`      |
| er_med_id      | INTEGER  | FK  | NO       | References `ER_MEDS.er_med_id`                  |
| dosage         | VARCHAR  |     | NO       | Dose administered (e.g., 1 tablet, 5mg/kg)      |
| route          | VARCHAR  |     | YES      | Route (IV, oral, IM, etc.)                      |
| time_administered| DATE/TIMESTAMP | | NO   | Date/time of administration                     |
| administered_by| INTEGER  | FK  | YES      | Staff member, references `MEDICAL_STAFFS`       |
| patient_response| VARCHAR |     | YES      | Notes on patient response / adverse reactions   |

### 4.10 SUPPLIES

| Column       | Type    | Key | Nullable | Description                   |
|--------------|---------|-----|----------|-------------------------------|
| supplier_id  | INTEGER | PK  | NO       | Unique supplier identifier    |
| supplier_name| VARCHAR |     | NO       | Supplier/company name         |
| contact_phone| VARCHAR |     | YES      | Phone number                  |
| contact_email| VARCHAR |     | YES      | Email address                 |
| address      | VARCHAR |     | YES      | Mailing/physical address      |

### 4.11 SUPPLY_INVENTORY

| Column            | Type    | Key | Nullable | Description                                    |
|-------------------|---------|-----|----------|-----------------------------------------------|
| item_id           | INTEGER | PK  | NO       | Unique inventory item identifier              |
| item_name         | VARCHAR |     | NO       | Name/description of the item                  |
| category          | VARCHAR |     | YES      | Category (PPE, medication, equipment, etc.)   |
| quantity_available| NUMBER  |     | NO       | Current on-hand quantity                      |
| reorder_level     | NUMBER  |     | YES      | Threshold to trigger reorder                  |
| expiry_date       | DATE    |     | YES      | Expiration date if applicable                 |
| location          | VARCHAR |     | YES      | Storage location                              |
| supplier_id       | INTEGER | FK  | YES      | References `SUPPLIES.supplier_id`             |

### 4.12 CRITICAL_ALERTS

| Column        | Type     | Key | Nullable | Description                                      |
|---------------|----------|-----|----------|--------------------------------------------------|
| alert_id      | INTEGER  | PK  | NO       | Unique alert identifier                          |
| patient_id    | INTEGER  | FK  | NO       | References `PATIENTS.patient_id`                |
| arrival_id    | INTEGER  | FK  | NO       | References `ER_ARRIVALS.arrival_id`            |
| alert_type    | VARCHAR  |     | NO       | Type (Code Blue, Sepsis Alert, etc.)           |
| severity      | VARCHAR  |     | NO       | Severity level                                   |
| triggered_time| DATE/TIMESTAMP | | NO   | Time alert was raised                            |
| acknowledged_by| INTEGER | FK  | YES      | Staff who acknowledged, references `MEDICAL_STAFFS` |
| resolution_time| DATE/TIMESTAMP | | YES  | Time alert was resolved                          |
| status        | VARCHAR  |     | NO       | Open, In progress, Resolved                      |

---

## 5. Assumptions and Constraints

- Each ER arrival is associated with exactly one patient and one triage level.
- ESI triage levels are predefined and limited (1–5) in **TRIAGE_LEVELS**.
- A patient can have at most one current bed assignment in **ER_BEDS.current_patient_id**.
- Staff availability and workload are tracked through **MEDICAL_STAFFS** and **SHIFTS** but detailed scheduling rules are handled at the application level.
- Medication and supply master data are maintained centrally and referenced via IDs to prevent duplication.
- All date/time fields use a consistent timezone and format as per hospital standards.

This logical model, together with the ER diagram and BPMN process from Phase II, provides a normalized, MIS-ready foundation for implementing the Hospital ER Triage and Resource Allocation system in Oracle.

---

## 6. BI Considerations

- **Fact vs. dimension tables**:  
  - Fact-like/event tables include **ER_ARRIVALS**, **TREATMENT_SESSIONS**, **MEDICATIONS_ADMINISTERED**, **CRITICAL_ALERTS**, and **SUPPLY_INVENTORY**.  
  - Dimension-like tables include **PATIENTS**, **TRIAGE_LEVELS**, **MEDICAL_STAFFS**, **SHIFTS**, **ER_BEDS**, **MEDICAL_EQUIPMENTS**, **ER_MEDS**, and **SUPPLIES**. These provide descriptive context for analytics.

- **Slowly changing dimensions**:  
  Attributes that change slowly over time (e.g., patient address/insurance, staff role or specialization, supplier contact details) are stored in dimension tables. The OLTP model keeps only the **current** values, while a future data warehouse could implement SCD strategies (such as history tables or effective date ranges) without changing this core schema.

- **Aggregation levels**:  
  The fact tables support aggregation at multiple levels, such as: average wait time by triage level and day (**ER_ARRIVALS** + **TRIAGE_LEVELS**), bed utilization by zone and shift (**TREATMENT_SESSIONS** + **ER_BEDS** + **SHIFTS**), and medication usage by drug and month (**MEDICATIONS_ADMINISTERED** + **ER_MEDS**).

- **Audit trails**:  
  Core tables already include key timestamps (`arrival_time`, `start_time`, `end_time`, `time_administered`, `triggered_time`, `resolution_time`) that support operational auditing. Additional standard audit columns such as `created_at`, `created_by`, `updated_at`, and `updated_by` can be added consistently across transactional tables to provide full history for compliance and BI traceability.

![ER Logical Model](ERD.jpg)