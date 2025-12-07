-- Analytics Queries with Window Functions
-- Purpose: Advanced analytics using window functions, aggregations, and statistical analysis

-- ============================================
-- 1. WAIT TIME ANALYSIS WITH RANK()
-- ============================================
-- Rank patients by wait time
SELECT 
    ea.arrival_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    t.triage_name,
    ea.arrival_datetime,
    RANK() OVER (ORDER BY ea.arrival_datetime) AS wait_rank,
    DENSE_RANK() OVER (ORDER BY ea.arrival_datetime) AS dense_wait_rank,
    ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2) AS wait_minutes
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
WHERE ea.arrival_status = 'Waiting'
ORDER BY ea.arrival_datetime;

-- Rank patients by wait time within each triage level
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    t.triage_name,
    ea.arrival_datetime,
    RANK() OVER (PARTITION BY t.triage_name ORDER BY ea.arrival_datetime) AS rank_in_triage,
    ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2) AS wait_minutes
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
WHERE ea.arrival_status = 'Waiting'
ORDER BY t.priority_order, ea.arrival_datetime;

-- ============================================
-- 2. TIME GAP ANALYSIS WITH LAG()
-- ============================================
-- Calculate time gaps between consecutive arrivals
SELECT 
    arrival_id,
    arrival_datetime,
    LAG(arrival_datetime) OVER (ORDER BY arrival_datetime) AS previous_arrival,
    ROUND((arrival_datetime - LAG(arrival_datetime) OVER (ORDER BY arrival_datetime)) * 24 * 60, 2) AS gap_minutes,
    CASE 
        WHEN ROUND((arrival_datetime - LAG(arrival_datetime) OVER (ORDER BY arrival_datetime)) * 24 * 60, 2) > 120 
        THEN 'Long Gap'
        WHEN ROUND((arrival_datetime - LAG(arrival_datetime) OVER (ORDER BY arrival_datetime)) * 24 * 60, 2) > 60 
        THEN 'Medium Gap'
        ELSE 'Short Gap'
    END AS gap_category
FROM er_arrivals
ORDER BY arrival_datetime DESC
FETCH FIRST 20 ROWS ONLY;

-- Time gaps by triage level
SELECT 
    t.triage_name,
    ea.arrival_datetime,
    LAG(ea.arrival_datetime) OVER (PARTITION BY t.triage_name ORDER BY ea.arrival_datetime) AS prev_arrival_same_triage,
    ROUND((ea.arrival_datetime - LAG(ea.arrival_datetime) OVER (PARTITION BY t.triage_name ORDER BY ea.arrival_datetime)) * 24 * 60, 2) AS gap_minutes
FROM er_arrivals ea
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
ORDER BY t.triage_name, ea.arrival_datetime DESC;

-- ============================================
-- 3. CUMULATIVE STATISTICS WITH SUM() OVER
-- ============================================
-- Running total of arrivals by day
SELECT 
    TRUNC(arrival_datetime) AS arrival_date,
    COUNT(*) AS daily_arrivals,
    SUM(COUNT(*)) OVER (ORDER BY TRUNC(arrival_datetime)) AS cumulative_arrivals,
    ROUND(AVG(COUNT(*)) OVER (ORDER BY TRUNC(arrival_datetime) ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7day_avg
FROM er_arrivals
GROUP BY TRUNC(arrival_datetime)
ORDER BY arrival_date DESC;

-- ============================================
-- 4. MOVING AVERAGES
-- ============================================
-- 7-day moving average of daily arrivals
SELECT 
    arrival_date,
    daily_count,
    ROUND(AVG(daily_count) OVER (ORDER BY arrival_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7day,
    ROUND(AVG(daily_count) OVER (ORDER BY arrival_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS moving_avg_30day
FROM (
    SELECT 
        TRUNC(arrival_datetime) AS arrival_date,
        COUNT(*) AS daily_count
    FROM er_arrivals
    GROUP BY TRUNC(arrival_datetime)
)
ORDER BY arrival_date DESC;

-- ============================================
-- 5. ROW_NUMBER FOR PAGINATION
-- ============================================
-- Paginated patient list with row numbers
SELECT 
    row_num,
    patient_id,
    first_name,
    last_name,
    gender,
    age
FROM (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY last_name, first_name) AS row_num,
        patient_id,
        first_name,
        last_name,
        gender,
        TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) AS age
    FROM patients
)
WHERE row_num BETWEEN 1 AND 10;  -- First page (rows 1-10)

-- ============================================
-- 6. FIRST_VALUE AND LAST_VALUE
-- ============================================
-- Compare each patient's wait time to longest and shortest waits
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2) AS wait_minutes,
    FIRST_VALUE(ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2)) 
        OVER (ORDER BY ea.arrival_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS longest_wait,
    LAST_VALUE(ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2)) 
        OVER (ORDER BY ea.arrival_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS shortest_wait
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
WHERE ea.arrival_status = 'Waiting'
ORDER BY ea.arrival_datetime;

-- ============================================
-- 7. PATIENT VISIT FREQUENCY ANALYSIS
-- ============================================
-- Patient visit count with ranking
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    COUNT(*) AS visit_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS frequency_rank,
    ROUND(AVG(COUNT(*)) OVER (), 2) AS avg_visits_per_patient
FROM patients p
JOIN er_arrivals ea ON p.patient_id = ea.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY visit_count DESC;

-- ============================================
-- 8. TRIAGE LEVEL DISTRIBUTION ANALYSIS
-- ============================================
-- Visit distribution by triage level with percentages
SELECT 
    t.triage_name,
    COUNT(*) AS visit_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG((SYSDATE - ea.arrival_datetime) * 24 * 60), 2) AS avg_wait_minutes,
    MIN(ea.arrival_datetime) AS first_arrival,
    MAX(ea.arrival_datetime) AS last_arrival
FROM er_arrivals ea
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
GROUP BY t.triage_name, t.priority_order
ORDER BY t.priority_order;

-- ============================================
-- 9. STAFF WORKLOAD ANALYSIS
-- ============================================
-- Treatment sessions per staff with rankings
SELECT 
    ms.staff_number,
    ms.first_name || ' ' || ms.last_name AS staff_name,
    ms.role,
    COUNT(ts.session_id) AS treatment_count,
    RANK() OVER (PARTITION BY ms.role ORDER BY COUNT(ts.session_id) DESC) AS rank_in_role,
    ROUND(AVG(COUNT(ts.session_id)) OVER (PARTITION BY ms.role), 2) AS avg_for_role
FROM medical_staffs ms
LEFT JOIN treatment_sessions ts ON ms.staff_id = ts.staff_id
WHERE ms.active_flag = 'Y'
GROUP BY ms.staff_id, ms.staff_number, ms.first_name, ms.last_name, ms.role
ORDER BY ms.role, treatment_count DESC;

-- ============================================
-- 10. BED UTILIZATION TRENDS
-- ============================================
-- Bed status distribution with percentages
SELECT 
    status,
    COUNT(*) AS bed_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS status_rank
FROM er_beds
GROUP BY status
ORDER BY bed_count DESC;

-- ============================================
-- 11. PEAK HOURS ANALYSIS
-- ============================================
-- Arrivals by hour of day with rankings
SELECT 
    hour_of_day,
    arrival_count,
    RANK() OVER (ORDER BY arrival_count DESC) AS busy_rank,
    ROUND(arrival_count * 100.0 / SUM(arrival_count) OVER (), 2) AS percentage_of_total,
    ROUND(AVG(arrival_count) OVER (), 2) AS daily_avg
FROM (
    SELECT 
        TO_CHAR(arrival_datetime, 'HH24') AS hour_of_day,
        COUNT(*) AS arrival_count
    FROM er_arrivals
    GROUP BY TO_CHAR(arrival_datetime, 'HH24')
)
ORDER BY hour_of_day;

-- ============================================
-- 12. DAY OF WEEK PATTERNS
-- ============================================
-- Arrival patterns by day of week
SELECT 
    day_name,
    day_num,
    arrival_count,
    RANK() OVER (ORDER BY arrival_count DESC) AS busiest_day_rank,
    ROUND(arrival_count * 100.0 / SUM(arrival_count) OVER (), 2) AS percentage
FROM (
    SELECT 
        TO_CHAR(arrival_datetime, 'DAY') AS day_name,
        TO_CHAR(arrival_datetime, 'D') AS day_num,
        COUNT(*) AS arrival_count
    FROM er_arrivals
    GROUP BY TO_CHAR(arrival_datetime, 'DAY'), TO_CHAR(arrival_datetime, 'D')
)
ORDER BY day_num;

-- ============================================
-- 13. TREATMENT DURATION ANALYSIS
-- ============================================
-- Average treatment duration by triage level
SELECT 
    t.triage_name,
    COUNT(ts.session_id) AS session_count,
    ROUND(AVG(CASE 
        WHEN ts.treatment_end IS NOT NULL 
        THEN (ts.treatment_end - ts.treatment_start) * 24 * 60 
    END), 2) AS avg_duration_minutes,
    MIN(CASE 
        WHEN ts.treatment_end IS NOT NULL 
        THEN (ts.treatment_end - ts.treatment_start) * 24 * 60 
    END) AS min_duration_minutes,
    MAX(CASE 
        WHEN ts.treatment_end IS NOT NULL 
        THEN (ts.treatment_end - ts.treatment_start) * 24 * 60 
    END) AS max_duration_minutes
FROM treatment_sessions ts
JOIN er_arrivals ea ON ts.arrival_id = ea.arrival_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
WHERE ts.treatment_end IS NOT NULL
GROUP BY t.triage_name, t.priority_order
ORDER BY t.priority_order;

-- ============================================
-- 14. NTILE FOR QUARTILE ANALYSIS
-- ============================================
-- Divide patients into wait time quartiles
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2) AS wait_minutes,
    NTILE(4) OVER (ORDER BY ea.arrival_datetime) AS wait_quartile,
    CASE NTILE(4) OVER (ORDER BY ea.arrival_datetime)
        WHEN 1 THEN 'Q1 - Longest Wait'
        WHEN 2 THEN 'Q2 - Long Wait'
        WHEN 3 THEN 'Q3 - Medium Wait'
        WHEN 4 THEN 'Q4 - Shortest Wait'
    END AS quartile_description
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
WHERE ea.arrival_status = 'Waiting'
ORDER BY ea.arrival_datetime;

-- ============================================
-- 15. COMPREHENSIVE PERFORMANCE DASHBOARD
-- ============================================
-- Key performance indicators with window functions
SELECT 
    'Total Arrivals Today' AS metric,
    TO_CHAR(COUNT(*)) AS current_value,
    TO_CHAR(LAG(COUNT(*)) OVER (ORDER BY TRUNC(arrival_datetime))) AS previous_value,
    TO_CHAR(ROUND((COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY TRUNC(arrival_datetime))) * 100.0 / 
        NULLIF(LAG(COUNT(*)) OVER (ORDER BY TRUNC(arrival_datetime)), 0), 2)) || '%' AS change_pct
FROM er_arrivals
WHERE TRUNC(arrival_datetime) >= TRUNC(SYSDATE) - 1
GROUP BY TRUNC(arrival_datetime)
ORDER BY TRUNC(arrival_datetime) DESC
FETCH FIRST 1 ROW ONLY;
