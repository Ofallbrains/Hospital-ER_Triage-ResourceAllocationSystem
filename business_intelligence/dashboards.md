# Dashboard Mockups & Designs
## ER Triage and Resource Allocation System

---

## Dashboard 1: Executive Summary (KPI Dashboard)

### Purpose
Provide high-level overview of ER performance for directors, administrators, and executives to make strategic decisions.

### Target Users
- ER Director
- Hospital Administrators
- Executive Leadership
- Board of Directors (monthly reviews)

### Refresh Rate
- Real-time KPI cards update every 5 minutes
- Trend charts update hourly
- Historical comparisons update nightly

---

### Layout Mockup

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  ER EXECUTIVE DASHBOARD                                    [Filters: Today] │
│  Last Updated: Dec 07, 2025 14:35                         [Week] [Month]    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │ PATIENTS TODAY  │  │  BED OCCUPANCY  │  │ AVG WAIT TIME   │            │
│  │                 │  │                 │  │                 │            │
│  │      187        │  │      82%        │  │    28 mins      │            │
│  │   ▲ +12 vs Avg  │  │   ▼ -3% Target │  │  ▲ +5m Target   │            │
│  │   ✓ On Track    │  │   ✓ Optimal    │  │  ⚠ Warning      │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  STAFF ON DUTY  │  │ WAIT COMPLIANCE │  │  LENGTH OF STAY │            │
│  │                 │  │                 │  │                 │            │
│  │       24        │  │      94%        │  │    142 mins     │            │
│  │   8 Nurses      │  │   ▲ +2% Target │  │  ▼ -8m Avg      │            │
│  │   16 Physicians │  │   ✓ Excellent  │  │  ✓ Good         │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  PATIENT THROUGHPUT TREND (Last 7 Days)                                    │
│                                                                             │
│  250│     █                                                                 │
│  200│   █ █ █     █                                                         │
│  150│ █ █ █ █ █ █ █                                                         │
│  100│ █ █ █ █ █ █ █                                                         │
│   50│ █ █ █ █ █ █ █                                                         │
│    0└─────────────────────────────────────────────────────────             │
│      Mon Tue Wed Thu Fri Sat Sun                                           │
│                                                                             │
│      Target: 175/day   Avg: 189/day   Today: 187                           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  WAIT TIME BY TRIAGE LEVEL                                                 │
│                                                                             │
│  Level 1 (Resuscitative):  ████░░░░░░░  0 min    ✓ Target: 0 min          │
│  Level 2 (Emergent):       ████████░░░ 12 min    ✓ Target: 15 min         │
│  Level 3 (Urgent):         ████████████ 35 min   ⚠ Target: 30 min         │
│  Level 4 (Semi-Urgent):    ██████████░░ 52 min   ✓ Target: 60 min         │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  TOP 5 PERFORMANCE HIGHLIGHTS                   ALERTS & ACTIONS           │
│                                                                             │
│  1. ✓ 100% Critical Alert Response < 5 min      • 3 beds in cleaning       │
│  2. ✓ Zero supply stock-outs this week          • Level 3 wait time high   │
│  3. ✓ Staff utilization optimal (72%)           • Equipment 12 maintenance │
│  4. ⚠ Level 3 wait time above target            • Staffing adjustment rec. │
│  5. ✓ Weekend compliance 98%                    • Supply reorder needed    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Data Sources & Queries

**KPI Cards:**
```sql
-- Patients Today
SELECT COUNT(*) as total_patients,
       COUNT(*) - (SELECT COUNT(*) FROM er_arrivals WHERE DATE(arrival_datetime) = CURRENT_DATE - 1) as vs_avg
FROM er_arrivals
WHERE DATE(arrival_datetime) = CURRENT_DATE;

-- Bed Occupancy
SELECT ROUND((COUNT(CASE WHEN status = 'OCCUPIED' THEN 1 END) / COUNT(*)) * 100, 0) as occupancy_pct
FROM er_beds;

-- Average Wait Time
SELECT ROUND(AVG(EXTRACT(EPOCH FROM (ts.start_time - ea.arrival_datetime)) / 60), 0) as avg_wait_mins
FROM er_arrivals ea
JOIN treatment_sessions ts ON ea.arrival_id = ts.arrival_id
WHERE DATE(ea.arrival_datetime) = CURRENT_DATE;
```

**Throughput Trend:**
```sql
SELECT DATE(arrival_datetime) as date,
       COUNT(*) as patient_count
FROM er_arrivals
WHERE arrival_datetime >= CURRENT_DATE - 6
GROUP BY DATE(arrival_datetime)
ORDER BY date;
```

---

## Dashboard 2: Audit & Compliance Dashboard

### Purpose
Monitor database audit logs, weekend restrictions, data quality, and system compliance for IT administrators and compliance officers.

### Target Users
- IT Administrator
- Database Administrator
- Compliance Officer
- Quality Assurance Team

### Refresh Rate
- Audit log entries: Real-time (auto-refresh every 30 seconds)
- Compliance metrics: Hourly updates
- Violation alerts: Immediate notifications

---

### Layout Mockup

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  AUDIT & COMPLIANCE DASHBOARD                        Date: Dec 07, 2025    │
│  Database: mon_27976_denyse_ertriage_db              User: DENYSE_ADMIN    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  AUDIT ENTRIES  │  │  WEEKEND BLOCKS │  │  DATA QUALITY   │            │
│  │     TODAY       │  │   THIS WEEK     │  │     SCORE       │            │
│  │                 │  │                 │  │                 │            │
│  │      1,247      │  │       38        │  │      98.7%      │            │
│  │   ▲ +124 vs Avg │  │   ✓ 100% Block │  │   ✓ Excellent   │            │
│  │   ✓ All Logged  │  │   0 Violations │  │   ▼ +0.3%       │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │  SYSTEM UPTIME  │  │ ACTIVE SESSIONS │  │  ERROR LOGS     │            │
│  │   THIS MONTH    │  │   CURRENT       │  │     TODAY       │            │
│  │                 │  │                 │  │                 │            │
│  │     99.8%       │  │        4        │  │        0        │            │
│  │   ✓ Above SLA   │  │   Normal Load   │  │   ✓ No Errors   │            │
│  │   0.1hr Down    │  │   Peak: 12      │  │   Last: 3d ago  │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  AUDIT LOG ACTIVITY (Last 24 Hours)                                        │
│                                                                             │
│  By Action Type:                         By Table:                         │
│    INSERT:  487 (39%)  ████████░░        ER_ARRIVALS:       312           │
│    UPDATE:  623 (50%)  ██████████        TREATMENT_SESSIONS: 289           │
│    DELETE:   89 ( 7%)  ██░░░░░░░░        MEDICATIONS_ADMIN:  201           │
│    SELECT:   48 ( 4%)  █░░░░░░░░░        MEDICAL_STAFFS:     156           │
│                                           OTHER:              289           │
│                                                                             │
│  By Status:                              By User:                          │
│    ALLOWED: 1,189 (95%)  ████████████    DENYSE_ADMIN:       847           │
│    BLOCKED:    58 ( 5%)  █░░░░░░░░░░     SYSTEM:             245           │
│                                           TRIAGE_USER:        155           │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  WEEKEND RESTRICTION COMPLIANCE (Last 30 Days)                             │
│                                                                             │
│  Total Weekend Actions Attempted:  152                                     │
│  Actions Blocked:                  148  (97.4%)  ✓ Above Target            │
│  Actions Allowed (Emergency):        4  (2.6%)   Justified                 │
│                                                                             │
│  Blocked Actions by Table:                                                 │
│    MEDICAL_STAFFS:  42 (28%)  ████████████░░░░░░░░░░░░░░░░░                │
│    ER_BEDS:         38 (26%)  █████████░░░░░░░░░░░░░░░░░░░░                │
│    PATIENTS:        68 (46%)  ████████████████░░░░░░░░░░░░                 │
│                                                                             │
│  Emergency Overrides (Justified):                                          │
│    Dec 03, 10:45 AM - Critical patient INSERT - Approved by Dr. Smith      │
│    Dec 04, 03:20 PM - Equipment UPDATE - Emergency repair logged           │
│    Dec 06, 08:15 AM - Staff INSERT - Holiday on-call coverage              │
│    Dec 07, 11:30 AM - Bed UPDATE - Critical capacity adjustment            │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  RECENT AUDIT LOG ENTRIES (Live Feed)                    [Refresh: 30s]    │
│                                                                             │
│  Time     │ User          │ Table            │ Action │ Status  │ Details  │
│  ─────────┼───────────────┼──────────────────┼────────┼─────────┼───────── │
│  14:35:12 │ DENYSE_ADMIN  │ ER_ARRIVALS      │ INSERT │ ALLOWED │ ID: 1234 │
│  14:34:58 │ DENYSE_ADMIN  │ TREATMENT_SESS   │ UPDATE │ ALLOWED │ ID: 5678 │
│  14:34:45 │ TRIAGE_USER   │ ER_BEDS          │ UPDATE │ ALLOWED │ ID: 12   │
│  14:33:22 │ DENYSE_ADMIN  │ MEDICATIONS_ADM  │ INSERT │ ALLOWED │ ID: 9012 │
│  14:32:10 │ SYSTEM        │ CRITICAL_ALERTS  │ INSERT │ ALLOWED │ Auto-gen │
│  14:31:45 │ DENYSE_ADMIN  │ MEDICAL_STAFFS   │ DELETE │ BLOCKED │ Weekend  │
│  14:30:33 │ DENYSE_ADMIN  │ ER_ARRIVALS      │ INSERT │ ALLOWED │ ID: 1233 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  DATA QUALITY CHECKS                                                       │
│                                                                             │
│  Table              │ Total Rows │ Null Critical │ Invalid Data │ Score    │
│  ───────────────────┼────────────┼───────────────┼──────────────┼───────── │
│  ER_ARRIVALS        │    2,847   │      3 (0.1%) │     0 (0%)   │  99.9%   │
│  TREATMENT_SESSIONS │    2,654   │      5 (0.2%) │     1 (0%)   │  99.8%   │
│  PATIENTS           │   18,492   │     28 (0.2%) │     2 (0%)   │  99.8%   │
│  MEDICAL_STAFFS     │      145   │      0 (0%)   │     0 (0%)   │ 100.0%   │
│  ER_BEDS            │       48   │      0 (0%)   │     0 (0%)   │ 100.0%   │
│                                                                             │
│  Overall Data Quality Score: 98.7%  ✓ Above Target (98%)                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Data Sources & Queries

**Audit Entries Today:**
```sql
SELECT COUNT(*) as total_audit_entries
FROM employee_action_audit
WHERE DATE(audit_time) = CURRENT_DATE;
```

**Weekend Blocks This Week:**
```sql
SELECT COUNT(*) as blocked_actions
FROM employee_action_audit
WHERE action_status = 'BLOCKED'
  AND EXTRACT(DOW FROM audit_time) IN (0, 6)
  AND audit_time >= DATE_TRUNC('week', CURRENT_DATE);
```

**Audit Log Activity:**
```sql
-- By Action Type
SELECT action_type, COUNT(*) as count,
       ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 1) as percentage
FROM employee_action_audit
WHERE audit_time >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY action_type;

-- By Status
SELECT action_status, COUNT(*) as count
FROM employee_action_audit
WHERE audit_time >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY action_status;
```

**Recent Audit Entries (Live Feed):**
```sql
SELECT TO_CHAR(audit_time, 'HH24:MI:SS') as time,
       performed_by as user,
       table_name,
       action_type as action,
       action_status as status,
       'ID: ' || COALESCE(record_id::TEXT, 'N/A') as details
FROM employee_action_audit
ORDER BY audit_time DESC
FETCH FIRST 10 ROWS ONLY;
```

---

## Dashboard 3: Performance & Resource Usage Dashboard

### Purpose
Monitor operational performance, resource utilization, and identify bottlenecks for shift supervisors and clinical managers.

### Target Users
- Shift Supervisors
- Clinical Manager
- Resource Allocation Team
- ER Director

### Refresh Rate
- Real-time metrics update every 1 minute
- Resource usage charts update every 5 minutes
- Trend analysis updates hourly

---

### Layout Mockup

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PERFORMANCE & RESOURCE DASHBOARD                    Time: 14:35 (Sunday)  │
│  Current Shift: Day Shift (7 AM - 3 PM)              Staff on Duty: 24     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  REAL-TIME BED STATUS                              STAFF UTILIZATION        │
│                                                                             │
│  ┌─────────────────────────────────────┐          ┌──────────────────────┐ │
│  │ Total Beds: 48                      │          │ Nurses:      72%     │ │
│  │                                     │          │ ████████░░░░         │ │
│  │ Occupied:   39  (81%)  ████████░░   │          │                      │ │
│  │ Available:   6  (13%)  ██░░░░░░░░   │          │ Physicians:  68%     │ │
│  │ Cleaning:    3  ( 6%)  █░░░░░░░░░   │          │ ███████░░░░░         │ │
│  │                                     │          │                      │ │
│  │ Status Indicators:                  │          │ Overall:     70%     │ │
│  │   🟢 Optimal (70-85%)               │          │ ███████░░░░░         │ │
│  │   🟡 High    (86-95%)               │          │ ✓ Within Target      │ │
│  │   🔴 Critical (96-100%)             │          └──────────────────────┘ │
│  └─────────────────────────────────────┘                                   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  PATIENT QUEUE BY TRIAGE LEVEL                                             │
│                                                                             │
│  Level 1 (Resuscitative):  0 patients   ░░░░░░░░░░  ✓ All treated         │
│  Level 2 (Emergent):       2 patients   ██░░░░░░░░  ⚠ 12 min wait         │
│  Level 3 (Urgent):         8 patients   ████████░░  ⚠ 35 min wait         │
│  Level 4 (Semi-Urgent):    5 patients   █████░░░░░  ✓ 52 min wait         │
│                                                                             │
│  Total Waiting: 15 patients             Avg Wait: 33 minutes               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  EQUIPMENT STATUS                                  SUPPLY LEVELS            │
│                                                                             │
│  Equipment ID │ Type        │ Status    │         Supply Item    │ Level   │
│  ─────────────┼─────────────┼───────────┤         ──────────────┼───────  │
│  EQ-001       │ Ventilator  │ Available │         Gauze Pads     │  87%    │
│  EQ-002       │ Ventilator  │ In Use    │         IV Bags        │  92%    │
│  EQ-003       │ Ventilator  │ Available │         Syringes       │  78%    │
│  EQ-012       │ Defibrillator│ Maint.   │         Gloves         │  45% ⚠  │
│  EQ-018       │ X-Ray       │ Available │         Medications    │  95%    │
│  EQ-024       │ ECG Monitor │ In Use    │         Sutures        │  88%    │
│                                                                             │
│  Total Equipment: 48                             Low Stock Alerts: 1       │
│  Available:       35 (73%)                       Reorder Needed:  Gloves   │
│  In Use:          11 (23%)                                                 │
│  Maintenance:      2 ( 4%)                                                 │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  RESOURCE BOTTLENECK ANALYSIS (This Week)                                  │
│                                                                             │
│  Resource Type     │ Delay Incidents │ Avg Delay │ Peak Time    │ Action  │
│  ──────────────────┼─────────────────┼───────────┼──────────────┼─────────│
│  Bed Assignment    │       12        │  28 mins  │ 2-4 PM       │ ⚠ High  │
│  Physician Avail.  │        8        │  15 mins  │ 10 AM-12 PM  │ Monitor │
│  Equipment Wait    │        3        │   8 mins  │ 8-10 AM      │ ✓ Low   │
│  Supply Shortage   │        0        │   0 mins  │ N/A          │ ✓ None  │
│                                                                             │
│  Recommendation: Consider adding 2 beds during 2-4 PM peak period          │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  STAFF-TO-PATIENT RATIO (Current)                                          │
│                                                                             │
│  Nurses:     8 nurses / 39 patients  =  4.9:1  ✓ Within target (4:1-6:1)  │
│  Physicians: 16 physicians / 39 patients = 2.4:1  ✓ Excellent (<6:1)      │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  HOURLY PATIENT FLOW (Today)                                               │
│                                                                             │
│  30│                   █                                                    │
│  25│     █       █     █                                                    │
│  20│   █ █     █ █ █   █                                                    │
│  15│ █ █ █   █ █ █ █ █ █ █                                                  │
│  10│ █ █ █ █ █ █ █ █ █ █ █ █                                                │
│   5│ █ █ █ █ █ █ █ █ █ █ █ █ █                                              │
│   0└─────────────────────────────────────────────────────                  │
│    12 1  2  3  4  5  6  7  8  9  10 11 12 1  2  3  4  5  6  7  8  9  10 11│
│    AM                  Noon                  PM                            │
│                                                                             │
│    Peak Hour: 2-3 PM (28 patients)    Lowest: 4-5 AM (2 patients)          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Data Sources & Queries

**Bed Status:**
```sql
SELECT status, COUNT(*) as count,
       ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 0) as percentage
FROM er_beds
GROUP BY status;
```

**Staff Utilization:**
```sql
WITH active_treatments AS (
  SELECT physician_id, COUNT(*) as active_patients
  FROM treatment_sessions
  WHERE end_time IS NULL
  GROUP BY physician_id
),
total_staff AS (
  SELECT COUNT(*) as total_physicians
  FROM medical_staffs
  WHERE staff_id IN (SELECT staff_id FROM shifts WHERE shift_date = CURRENT_DATE)
)
SELECT ROUND((COUNT(active_patients) * 100.0 / total_physicians), 0) as utilization_pct
FROM active_treatments
CROSS JOIN total_staff;
```

**Patient Queue:**
```sql
SELECT tl.level_name,
       COUNT(ea.arrival_id) as waiting_patients,
       ROUND(AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - ea.arrival_datetime)) / 60), 0) as avg_wait_mins
FROM er_arrivals ea
JOIN triage_levels tl ON ea.triage_level_id = tl.triage_level_id
WHERE ea.status = 'WAITING'
GROUP BY tl.level_name, tl.triage_level_id
ORDER BY tl.triage_level_id;
```

**Resource Bottleneck Analysis:**
```sql
SELECT 'Bed Assignment' as resource_type,
       COUNT(*) as delay_incidents,
       ROUND(AVG(delay_minutes), 0) as avg_delay
FROM (
  SELECT EXTRACT(EPOCH FROM (bed_assigned_time - arrival_datetime)) / 60 as delay_minutes
  FROM er_arrivals
  WHERE bed_assigned_time - arrival_datetime > INTERVAL '20 minutes'
    AND arrival_datetime >= CURRENT_DATE - 6
) delays;
```

---

## Dashboard Implementation Notes

### Technology Recommendations
1. **Oracle APEX** - Native Oracle, low-code dashboard builder, free with Oracle XE
2. **Tableau / Power BI** - Connect via Oracle JDBC driver for rich visualizations
3. **Grafana** - Open-source, real-time monitoring, supports Oracle datasource
4. **Excel Pivot Tables** - Simple manual dashboards for initial implementation
5. **Custom Web App** - HTML/CSS/JavaScript with Oracle REST APIs

### Color Coding Standards
- **Green (✓):** On target, excellent performance
- **Yellow (⚠):** Warning, approaching threshold
- **Red (🔴):** Critical, immediate action required
- **Gray (░):** Inactive, not applicable

### Auto-Refresh Rates
- **Real-time dashboards:** 30 seconds - 1 minute (operational, audit)
- **Performance dashboards:** 5 minutes (resource usage, bed status)
- **Executive dashboards:** 5-15 minutes (KPIs, trends)
- **Historical reports:** Hourly or daily batch updates

### Export Capabilities
All dashboards should support:
- **PDF Export** - For reports and presentations
- **Excel Export** - For further analysis
- **CSV Export** - For data integration
- **Email Scheduling** - Automated daily/weekly reports
- **Screenshot/Print** - For documentation and compliance

---

## Additional Dashboard Ideas (Optional)

### 4. Triage Dashboard
- Current triage queue by level
- Triage nurse performance (accuracy, speed)
- Real-time bed and staff availability
- Target wait time countdown timers

### 5. Medication Dashboard
- Medication administration schedule
- Missed/delayed medications
- Inventory levels by medication type
- Adverse reaction alerts

### 6. Critical Alerts Dashboard
- Active critical alerts (real-time)
- Alert resolution times
- Alert history and trends
- Escalation procedures

