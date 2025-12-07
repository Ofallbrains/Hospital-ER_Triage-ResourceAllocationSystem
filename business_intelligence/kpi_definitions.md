# Key Performance Indicator (KPI) Definitions
## ER Triage and Resource Allocation System

---

## 1. Operational Efficiency KPIs

### 1.1 Average Wait Time by Triage Level

**Definition:** The average time elapsed between patient arrival and treatment start, segmented by triage level.

**Formula:**
```sql
AVG(EXTRACT(HOUR FROM (ts.start_time - ea.arrival_datetime)) * 60 + 
    EXTRACT(MINUTE FROM (ts.start_time - ea.arrival_datetime)))
FROM er_arrivals ea
JOIN treatment_sessions ts ON ea.arrival_id = ts.arrival_id
WHERE ea.triage_level_id = [LEVEL]
```

**Unit:** Minutes  
**Target:**
- Triage Level 1 (Resuscitative): ≤ 0 minutes (immediate)
- Triage Level 2 (Emergent): ≤ 15 minutes
- Triage Level 3 (Urgent): ≤ 30 minutes
- Triage Level 4 (Semi-Urgent): ≤ 60 minutes

**Business Impact:**  
Measures adherence to clinical triage protocols. High wait times indicate resource constraints or inefficient patient flow.

**Reporting Frequency:** Real-time dashboard, hourly updates  
**Owner:** Clinical Manager

---

### 1.2 Bed Occupancy Rate

**Definition:** The percentage of ER beds currently occupied by patients versus total available beds.

**Formula:**
```sql
(COUNT(bed_id WHERE status = 'OCCUPIED') / COUNT(bed_id)) * 100
FROM er_beds
```

**Unit:** Percentage (%)  
**Target:** 70-85% (optimal range)
- Below 70%: Underutilization, potential staffing inefficiency
- Above 85%: Overcrowding risk, patient flow delays

**Business Impact:**  
Indicates capacity management effectiveness. Helps predict when additional capacity is needed.

**Reporting Frequency:** Real-time dashboard, hourly summary  
**Owner:** Shift Supervisor

---

### 1.3 Staff Utilization Rate

**Definition:** The percentage of staff time spent actively treating patients versus scheduled work hours.

**Formula:**
```sql
(SUM(treatment_session_duration) / SUM(scheduled_shift_hours)) * 100
FROM treatment_sessions ts
JOIN medical_staffs ms ON ts.physician_id = ms.staff_id
WHERE date BETWEEN [START] AND [END]
```

**Unit:** Percentage (%)  
**Target:** 65-75% (accounts for breaks, documentation, prep time)

**Business Impact:**  
Identifies overstaffing (low utilization) or burnout risk (high utilization). Supports scheduling optimization.

**Reporting Frequency:** Daily summary, weekly trend analysis  
**Owner:** ER Director

---

### 1.4 Patient Throughput

**Definition:** The number of patients treated and discharged per time period.

**Formula:**
```sql
COUNT(DISTINCT arrival_id)
FROM er_arrivals
WHERE status = 'DISCHARGED'
  AND DATE(arrival_datetime) = [DATE]
```

**Unit:** Patients per hour/day/week  
**Target:** 
- Peak hours (8 AM - 6 PM): 8-12 patients/hour
- Off-peak hours: 4-6 patients/hour
- Daily: 150-200 patients

**Business Impact:**  
Measures overall operational efficiency. Low throughput indicates bottlenecks or capacity issues.

**Reporting Frequency:** Hourly, daily, weekly trends  
**Owner:** Clinical Manager

---

### 1.5 Average Length of Stay (ALOS)

**Definition:** Average time a patient spends in the ER from arrival to discharge.

**Formula:**
```sql
AVG(EXTRACT(HOUR FROM (ts.end_time - ea.arrival_datetime)) * 60 + 
    EXTRACT(MINUTE FROM (ts.end_time - ea.arrival_datetime)))
FROM er_arrivals ea
JOIN treatment_sessions ts ON ea.arrival_id = ts.arrival_id
WHERE ts.disposition = 'DISCHARGED'
```

**Unit:** Minutes  
**Target:** 
- Triage 1-2: 120-180 minutes
- Triage 3-4: 90-150 minutes

**Business Impact:**  
Reflects efficiency of treatment process. High ALOS causes bed shortages and waiting room congestion.

**Reporting Frequency:** Daily summary, weekly trends  
**Owner:** ER Director

---

## 2. Quality of Care KPIs

### 2.1 Triage Accuracy Rate

**Definition:** Percentage of patients triaged correctly based on clinical review of outcomes.

**Formula:**
```sql
(COUNT(arrival_id WHERE triage_validated = 'CORRECT') / COUNT(arrival_id)) * 100
FROM er_arrivals
WHERE triage_review_completed = 'YES'
```

**Unit:** Percentage (%)  
**Target:** ≥ 95%

**Business Impact:**  
Ensures patient safety through proper prioritization. Under-triage delays critical care; over-triage misallocates resources.

**Reporting Frequency:** Weekly quality review, monthly compliance report  
**Owner:** Quality Assurance Team

---

### 2.2 Target Wait Time Compliance

**Definition:** Percentage of patients seen within target wait time for their triage level.

**Formula:**
```sql
(COUNT(arrival_id WHERE actual_wait <= target_wait) / COUNT(arrival_id)) * 100
FROM er_arrivals ea
JOIN triage_levels tl ON ea.triage_level_id = tl.triage_level_id
JOIN treatment_sessions ts ON ea.arrival_id = ts.arrival_id
```

**Unit:** Percentage (%)  
**Target:** ≥ 90% compliance overall
- Level 1: 100% (immediate)
- Level 2: ≥ 95%
- Level 3: ≥ 90%
- Level 4: ≥ 85%

**Business Impact:**  
Key clinical quality metric. Non-compliance risks patient deterioration and regulatory violations.

**Reporting Frequency:** Hourly monitoring, daily compliance report  
**Owner:** Clinical Manager

---

### 2.3 Critical Alert Response Time

**Definition:** Time elapsed between critical alert generation and alert resolution.

**Formula:**
```sql
AVG(EXTRACT(MINUTE FROM (resolved_at - generated_at)))
FROM critical_alerts
WHERE severity_level = 'CRITICAL'
```

**Unit:** Minutes  
**Target:** ≤ 5 minutes for critical alerts

**Business Impact:**  
Measures emergency response effectiveness. Delayed response can result in adverse patient outcomes.

**Reporting Frequency:** Real-time monitoring, daily summary  
**Owner:** Clinical Manager

---

### 2.4 Treatment Completion Rate

**Definition:** Percentage of treatment sessions completed successfully versus started.

**Formula:**
```sql
(COUNT(session_id WHERE disposition IN ('DISCHARGED', 'ADMITTED')) / 
 COUNT(session_id)) * 100
FROM treatment_sessions
```

**Unit:** Percentage (%)  
**Target:** ≥ 98%

**Business Impact:**  
Incomplete treatments may indicate workflow issues, patient walkouts, or system errors.

**Reporting Frequency:** Daily summary, weekly trend  
**Owner:** Quality Assurance Team

---

### 2.5 Medication Administration Timeliness

**Definition:** Percentage of medications administered within scheduled time window (±15 minutes).

**Formula:**
```sql
(COUNT(med_id WHERE ABS(scheduled_time - actual_time) <= 15) / 
 COUNT(med_id)) * 100
FROM medications_administered
```

**Unit:** Percentage (%)  
**Target:** ≥ 95%

**Business Impact:**  
Ensures medication effectiveness and patient safety. Delays can affect treatment outcomes.

**Reporting Frequency:** Shift summary, daily report  
**Owner:** Pharmacy Coordinator / Clinical Manager

---

## 3. Resource Management KPIs

### 3.1 Equipment Availability Rate

**Definition:** Percentage of medical equipment that is operational and available for use.

**Formula:**
```sql
(COUNT(equipment_id WHERE status = 'AVAILABLE') / COUNT(equipment_id)) * 100
FROM medical_equipments
```

**Unit:** Percentage (%)  
**Target:** ≥ 95%

**Business Impact:**  
Equipment shortages delay treatments and reduce quality of care. Tracks maintenance effectiveness.

**Reporting Frequency:** Real-time dashboard, daily summary  
**Owner:** Equipment Manager

---

### 3.2 Supply Stock-Out Rate

**Definition:** Frequency of critical supply items reaching zero inventory.

**Formula:**
```sql
COUNT(DISTINCT supply_id)
FROM supply_inventory
WHERE quantity_on_hand = 0 
  AND supply_id IN (SELECT supply_id FROM supplies WHERE critical = 'YES')
  AND DATE = [DATE]
```

**Unit:** Number of stock-outs per week  
**Target:** 0 stock-outs for critical supplies

**Business Impact:**  
Stock-outs can halt treatments and compromise patient care. Indicates procurement issues.

**Reporting Frequency:** Daily monitoring, weekly summary  
**Owner:** Supply Chain Manager

---

### 3.3 Staff-to-Patient Ratio

**Definition:** Number of active patients per staff member during a shift.

**Formula:**
```sql
COUNT(DISTINCT ea.patient_id) / COUNT(DISTINCT ms.staff_id)
FROM er_arrivals ea
JOIN medical_staffs ms ON ms.staff_id IN (ea.triage_nurse_id, ea.physician_id)
WHERE ea.status = 'IN_TREATMENT'
  AND ms.staff_id IN (SELECT staff_id FROM shifts WHERE shift_date = CURRENT_DATE)
```

**Unit:** Ratio (patients : staff)  
**Target:** 
- Nurses: 4:1 to 6:1
- Physicians: 6:1 to 8:1

**Business Impact:**  
High ratios indicate understaffing, leading to burnout and quality issues. Low ratios suggest inefficiency.

**Reporting Frequency:** Real-time dashboard, shift summary  
**Owner:** Shift Supervisor

---

### 3.4 Critical Resource Bottlenecks

**Definition:** Resources causing the longest wait times or treatment delays.

**Formula:**
```sql
SELECT resource_type, COUNT(*) as delay_count, AVG(delay_minutes)
FROM (
  SELECT 'BED' as resource_type, 
         EXTRACT(MINUTE FROM (bed_assigned_time - arrival_time)) as delay_minutes
  FROM er_arrivals
  WHERE bed_assigned_time - arrival_time > INTERVAL '30' MINUTE
)
GROUP BY resource_type
ORDER BY delay_count DESC
```

**Unit:** Delay incidents per week  
**Target:** < 10 incidents per resource type per week

**Business Impact:**  
Identifies where to invest resources (more beds, staff, equipment) for maximum impact.

**Reporting Frequency:** Weekly analysis, monthly strategic review  
**Owner:** ER Director

---

### 3.5 Weekend vs. Weekday Resource Usage

**Definition:** Comparison of resource utilization between weekends and weekdays.

**Formula:**
```sql
SELECT 
  CASE WHEN EXTRACT(DOW FROM arrival_datetime) IN (0,6) THEN 'WEEKEND' ELSE 'WEEKDAY' END as day_type,
  AVG(bed_occupancy) as avg_beds,
  AVG(staff_count) as avg_staff,
  COUNT(arrival_id) as patient_count
FROM er_arrivals
GROUP BY day_type
```

**Unit:** Percentage difference  
**Target:** Identify 15-25% lower volume on weekends (typical pattern)

**Business Impact:**  
Supports staffing schedule optimization and weekend scheduling decisions. Validates weekend restriction policies.

**Reporting Frequency:** Weekly comparison, monthly trend  
**Owner:** ER Director

---

## 4. Audit & Compliance KPIs

### 4.1 Audit Trail Completeness

**Definition:** Percentage of database actions that are successfully logged in audit tables.

**Formula:**
```sql
(COUNT(audit_id) / [EXPECTED_ACTION_COUNT]) * 100
FROM employee_action_audit
WHERE audit_date = [DATE]
```

**Unit:** Percentage (%)  
**Target:** 100% (all actions logged)

**Business Impact:**  
Ensures regulatory compliance and supports incident investigation. Gaps indicate system failures.

**Reporting Frequency:** Daily automated check, monthly compliance report  
**Owner:** IT Administrator / Compliance Officer

---

### 4.2 Weekend Restriction Compliance

**Definition:** Percentage of non-emergency database actions correctly blocked on weekends/holidays.

**Formula:**
```sql
(COUNT(audit_id WHERE action_status = 'BLOCKED') / 
 COUNT(audit_id WHERE action_type IN ('INSERT', 'UPDATE', 'DELETE'))) * 100
FROM employee_action_audit
WHERE EXTRACT(DOW FROM audit_time) IN (0,6) 
  OR audit_time::DATE IN (SELECT holiday_date FROM public_holidays)
```

**Unit:** Percentage (%)  
**Target:** ≥ 95% (with justified exceptions for emergencies)

**Business Impact:**  
Protects data integrity during reduced IT support hours. Demonstrates policy enforcement.

**Reporting Frequency:** Weekly summary, monthly compliance report  
**Owner:** IT Administrator

---

### 4.3 Data Quality Score

**Definition:** Percentage of database records that meet completeness and accuracy standards.

**Formula:**
```sql
(COUNT(*) - COUNT(CASE WHEN critical_field IS NULL THEN 1 END)) / COUNT(*) * 100
FROM [TABLE]
WHERE created_date >= [START_DATE]
```

**Unit:** Percentage (%)  
**Target:** ≥ 98% for critical fields

**Business Impact:**  
Poor data quality undermines BI insights and clinical decision-making. Indicates training needs.

**Reporting Frequency:** Weekly data quality check, monthly report  
**Owner:** Data Quality Team / IT Administrator

---

### 4.4 System Uptime

**Definition:** Percentage of time the database and application are available and operational.

**Formula:**
```sql
((TOTAL_HOURS - DOWNTIME_HOURS) / TOTAL_HOURS) * 100
FROM system_availability_log
WHERE month = [MONTH]
```

**Unit:** Percentage (%)  
**Target:** ≥ 99.5% (maximum 3.6 hours downtime per month)

**Business Impact:**  
System downtime halts ER operations and patient care. Critical for 24/7 healthcare environment.

**Reporting Frequency:** Real-time monitoring, daily uptime report, monthly SLA review  
**Owner:** IT Administrator

---

## 5. KPI Summary Table

| KPI | Unit | Target | Frequency | Owner | Priority |
|-----|------|--------|-----------|-------|----------|
| Avg Wait Time by Triage Level | Minutes | 0-60 (by level) | Hourly | Clinical Manager | HIGH |
| Bed Occupancy Rate | % | 70-85% | Real-time | Shift Supervisor | HIGH |
| Staff Utilization Rate | % | 65-75% | Daily | ER Director | MEDIUM |
| Patient Throughput | Patients/hour | 4-12 | Hourly | Clinical Manager | HIGH |
| Average Length of Stay | Minutes | 90-180 | Daily | ER Director | MEDIUM |
| Triage Accuracy Rate | % | ≥ 95% | Weekly | Quality Assurance | HIGH |
| Target Wait Time Compliance | % | ≥ 90% | Hourly | Clinical Manager | HIGH |
| Critical Alert Response Time | Minutes | ≤ 5 | Real-time | Clinical Manager | HIGH |
| Treatment Completion Rate | % | ≥ 98% | Daily | Quality Assurance | MEDIUM |
| Medication Timeliness | % | ≥ 95% | Shift | Pharmacy Coordinator | MEDIUM |
| Equipment Availability Rate | % | ≥ 95% | Real-time | Equipment Manager | MEDIUM |
| Supply Stock-Out Rate | Count/week | 0 | Daily | Supply Chain Manager | HIGH |
| Staff-to-Patient Ratio | Ratio | 4:1 to 8:1 | Real-time | Shift Supervisor | HIGH |
| Critical Resource Bottlenecks | Count/week | < 10 | Weekly | ER Director | MEDIUM |
| Weekend vs Weekday Usage | % difference | 15-25% | Weekly | ER Director | LOW |
| Audit Trail Completeness | % | 100% | Daily | IT Administrator | HIGH |
| Weekend Restriction Compliance | % | ≥ 95% | Weekly | IT Administrator | MEDIUM |
| Data Quality Score | % | ≥ 98% | Weekly | Data Quality Team | MEDIUM |
| System Uptime | % | ≥ 99.5% | Real-time | IT Administrator | HIGH |

---

## 6. KPI Dashboards Mapping

| Dashboard | KPIs Displayed |
|-----------|----------------|
| **Executive Summary** | Patient Throughput, ALOS, Bed Occupancy, Staff Utilization, Target Wait Time Compliance |
| **Operational Dashboard** | Bed Occupancy, Staff-to-Patient Ratio, Avg Wait Time, Equipment Availability, Active Alerts |
| **Quality Dashboard** | Triage Accuracy, Wait Time Compliance, Treatment Completion, Medication Timeliness |
| **Resource Dashboard** | Equipment Availability, Supply Stock-Outs, Staff Utilization, Resource Bottlenecks |
| **Audit Dashboard** | Audit Trail Completeness, Weekend Restrictions, Data Quality, System Uptime |
| **Performance Dashboard** | Patient Throughput trends, ALOS trends, Weekend vs Weekday comparison |

