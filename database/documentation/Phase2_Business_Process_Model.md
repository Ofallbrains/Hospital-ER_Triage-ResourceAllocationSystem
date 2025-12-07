# Phase II: Business Process Modeling – Hospital ER Triage

## 1. Business Process Scope

This business process models the end‑to‑end flow of a patient visiting the Emergency Room (ER), from arrival to final disposition. The focus is on **triage and resource allocation**, showing how clinical and administrative staff coordinate to prioritize patients, allocate limited ER resources (beds, staff, equipment), and capture data in the Management Information System (MIS).

The scope begins when a **patient arrives at the ER** and ends when the **case is closed in the MIS** after discharge, admission, or transfer. Activities outside the ER (e.g., inpatient ward care after admission) are out of scope.

## 2. Key Entities and Roles

- **Patient** – Arrives at the ER, waits, receives triage and treatment, and is eventually discharged, admitted, or transferred.
- **Registration Clerk** – Registers the patient, verifies basic information, and creates an initial electronic record.
- **Triage Nurse** – Performs triage assessment (vitals, symptoms, history) and assigns an Emergency Severity Index (ESI) level.
- **Bed Manager / Charge Nurse** – Manages bed availability and staff assignment; allocates resources based on triage priority.
- **ER Physician** – Examines the patient, orders diagnostic tests, interprets results, creates/updates the treatment plan, and decides disposition.
- **Support Services (Lab / Imaging)** – Perform diagnostic tests ordered by the physician.
- **MIS / Hospital Information System** – Stores patient records, triage data, orders, results, and billing information; provides reports and dashboards.

## 3. Swimlane BPMN Overview

The BPMN diagram uses **horizontal swimlanes** to clearly separate responsibilities:

- Lane 1: Patient  
- Lane 2: Registration  
- Lane 3: Triage Nurse  
- Lane 4: Bed Manager  
- Lane 5: ER Physician  
- Lane 6: Support Services  
- Lane 7: MIS System

This structure highlights **handoff points** between actors (e.g., from Registration to Triage Nurse, from Bed Manager to ER Physician) and clarifies who is responsible for each activity.

## 4. Logical Flow Description

1. **Arrival and Emergency Check**  
   The process starts when the **patient arrives at the ER** (Start Event). The Triage Nurse immediately evaluates whether the situation is **life‑threatening**. If yes, the patient is sent directly to the **trauma room** under the Bed Manager’s lane. If not, the patient proceeds to **Registration**.

2. **Registration**  
   The Registration Clerk performs **"Register patient"**, capturing demographics and creating a basic electronic record. Once registration is complete, the patient is sent to the **Triage Nurse** for detailed assessment.

3. **Triage Assessment and ESI Assignment**  
   The Triage Nurse conducts **"Triage assessments"** (vitals, symptoms, and brief history) and then **assigns an ESI level (1–5)**. A gateway labeled **"ESI level?"** branches the flow:
   - **ESI 1–2 (critical)** → patient goes directly to the **Immediate Treatment Area**.  
   - **ESI 3–5 (less critical)** → patient enters the **Waiting room queue**.

4. **Merge and Resource Allocation**  
   Regardless of whether the patient came from the Immediate Treatment Area or the Waiting Room, both paths **merge** and continue to **"Allocate resources (bed, staff, equipment)"** under the Bed Manager. This step ensures that limited ER resources are assigned according to priority and availability.

5. **Physician Examination and Diagnostics**  
   After resources are allocated, the patient is seen by the **ER Physician** in **"Physician examination"**. A **parallel gateway** then splits the process into two concurrent activities:
   - **Support Services** perform **lab and imaging tests**.  
   - The **ER Physician** **creates or updates the treatment plan**.

   A second parallel gateway **joins** these flows once results and the plan are ready, and the process continues to **"Administer treatment"**.

6. **Disposition Decision**  
   Following treatment, a gateway labeled **"Disposition?"** determines the final outcome:
   - **Discharge home** – patient is stable and can leave.  
   - **Admit to hospital ward** – patient needs ongoing inpatient care.  
   - **Transfer to other facility** – patient needs specialized services not available on‑site.

7. **Update Records and Close Case**  
   All disposition paths converge on the MIS System activity **"Update records and billing"**, where clinical notes, orders, results, and financial data are finalized. The process ends at the **"Case closed"** End Event.

## 5. MIS Relevance and Organizational Impact

- **MIS Functions**  
  - Captures triage data (ESI levels, arrival times, vitals) for every ER visit.  
  - Tracks bed occupancy, staff workload, and use of diagnostic services.  
  - Stores orders, test results, treatment plans, and disposition decisions.  
  - Integrates with billing to ensure accurate charges based on services provided.

- **Organizational Impact**  
  - **Operational efficiency**: Prioritizing patients via ESI and centralizing resource allocation reduces wait times and overcrowding.  
  - **Clinical quality**: Standardized triage and documented treatment flows improve patient safety and consistency of care.  
  - **Financial performance**: Better documentation improves billing accuracy and reduces revenue leakage.  
  - **Compliance and auditability**: Every major step (triage, orders, disposition) is time‑stamped and traceable.

- **Analytics Opportunities**  
  - Average **waiting time by ESI level**.  
  - **Bed utilization** and bottlenecks by time of day.  
  - Relationship between **triage priority and outcomes** (admission, transfer, return visits).  
  - **Cost per ER visit** and use of high‑cost diagnostics.

  ![ER Triage BPMN Diagram](screenshots/database_objects/HospitalER.jpg)

---
