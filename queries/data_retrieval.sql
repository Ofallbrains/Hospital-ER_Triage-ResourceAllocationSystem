-- Data Retrieval Queries

-- ============================================
-- 1. TRIAGE LEVELS
-- ============================================
-- Get all triage levels with priority ordering
SELECT 
    triage_level_id,
    triage_name,
    priority_order,
    avg_wait_minutes
FROM triage_levels 
ORDER BY priority_order;

-- ============================================
-- 2. PATIENT INFORMATION
-- ============================================
-- Get all active patients with demographics
SELECT 
    patient_id,
    national_id,
    first_name,
    last_name,
    gender,
    TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) AS age,
    phone_number,
    city
FROM patients 
ORDER BY last_name, first_name;

-- Get patients by gender distribution
SELECT 
    gender,
    COUNT(*) AS patient_count
FROM patients
GROUP BY gender
ORDER BY patient_count DESC;

-- ============================================
-- 3. MEDICAL STAFF
-- ============================================
-- Get all active medical staff
SELECT 
    staff_number,
    first_name,
    last_name,
    role,
    department,
    phone_number,
    email
FROM medical_staffs
WHERE active_flag = 'Y'
ORDER BY role, last_name;

-- Staff count by role
SELECT 
    role,
    COUNT(*) AS staff_count
FROM medical_staffs
WHERE active_flag = 'Y'
GROUP BY role
ORDER BY staff_count DESC;

-- ============================================
-- 4. ER BEDS
-- ============================================
-- Get all ER beds with current status
SELECT 
    bed_code,
    location_zone,
    is_isolation,
    status
FROM er_beds
ORDER BY location_zone, bed_code;

-- Available beds by zone
SELECT 
    location_zone,
    COUNT(*) AS available_beds
FROM er_beds
WHERE status = 'Available'
GROUP BY location_zone
ORDER BY location_zone;

-- Bed status summary
SELECT 
    status,
    COUNT(*) AS bed_count
FROM er_beds
GROUP BY status
ORDER BY bed_count DESC;

-- ============================================
-- 5. PATIENT ARRIVALS
-- ============================================
-- Current patient arrivals with triage information
SELECT 
    ea.arrival_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.national_id,
    t.triage_name,
    ea.arrival_datetime,
    ea.chief_complaint,
    ea.arrival_status,
    b.bed_code
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
LEFT JOIN er_beds b ON ea.assigned_bed_id = b.bed_id
ORDER BY ea.arrival_datetime DESC;

-- Patients currently waiting
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    t.triage_name,
    ea.arrival_datetime,
    ROUND((SYSDATE - ea.arrival_datetime) * 24 * 60, 2) AS wait_minutes,
    ea.chief_complaint
FROM er_arrivals ea
JOIN patients p ON ea.patient_id = p.patient_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
WHERE ea.arrival_status = 'Waiting'
ORDER BY t.priority_order, ea.arrival_datetime;

-- Arrivals by status
SELECT 
    arrival_status,
    COUNT(*) AS patient_count
FROM er_arrivals
GROUP BY arrival_status
ORDER BY patient_count DESC;

-- ============================================
-- 6. TREATMENT SESSIONS
-- ============================================
-- Active treatment sessions
SELECT 
    ts.session_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    ms.first_name || ' ' || ms.last_name AS staff_name,
    ms.role,
    ts.treatment_start,
    ts.treatment_status,
    b.bed_code
FROM treatment_sessions ts
JOIN er_arrivals ea ON ts.arrival_id = ea.arrival_id
JOIN patients p ON ea.patient_id = p.patient_id
JOIN medical_staffs ms ON ts.staff_id = ms.staff_id
LEFT JOIN er_beds b ON ts.bed_id = b.bed_id
WHERE ts.treatment_status = 'In Progress'
ORDER BY ts.treatment_start DESC;

-- ============================================
-- 7. MEDICAL EQUIPMENT
-- ============================================
-- Available medical equipment
SELECT 
    equipment_code,
    name,
    status,
    location
FROM medical_equipments
WHERE status = 'Available'
ORDER BY name;

-- Equipment status summary
SELECT 
    status,
    COUNT(*) AS equipment_count
FROM medical_equipments
GROUP BY status
ORDER BY equipment_count DESC;

-- ============================================
-- 8. SUPPLIES INVENTORY
-- ============================================
-- Current supply inventory levels
SELECT 
    s.supply_name,
    s.category,
    si.quantity_in_stock,
    si.reorder_level,
    CASE 
        WHEN si.quantity_in_stock <= si.reorder_level THEN 'LOW STOCK'
        ELSE 'OK'
    END AS stock_status
FROM supply_inventory si
JOIN supplies s ON si.supply_id = s.supply_id
ORDER BY 
    CASE WHEN si.quantity_in_stock <= si.reorder_level THEN 1 ELSE 2 END,
    s.supply_name;

-- Supplies needing reorder
SELECT 
    s.supply_name,
    s.unit_of_measure,
    si.quantity_in_stock,
    si.reorder_level,
    (si.reorder_level - si.quantity_in_stock) AS shortage
FROM supply_inventory si
JOIN supplies s ON si.supply_id = s.supply_id
WHERE si.quantity_in_stock <= si.reorder_level
ORDER BY (si.reorder_level - si.quantity_in_stock) DESC;

-- ============================================
-- 9. CRITICAL ALERTS
-- ============================================
-- Active critical alerts
SELECT 
    ca.alert_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    t.triage_name,
    ca.alert_type,
    ca.alert_datetime,
    ca.is_resolved,
    ms.first_name || ' ' || ms.last_name AS assigned_to
FROM critical_alerts ca
JOIN er_arrivals ea ON ca.arrival_id = ea.arrival_id
JOIN patients p ON ea.patient_id = p.patient_id
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
LEFT JOIN medical_staffs ms ON ca.assigned_staff_id = ms.staff_id
WHERE ca.is_resolved = 'N'
ORDER BY ca.alert_datetime DESC;

-- ============================================
-- 10. STAFF SHIFTS
-- ============================================
-- Current and upcoming shifts
SELECT 
    ms.staff_number,
    ms.first_name || ' ' || ms.last_name AS staff_name,
    ms.role,
    s.shift_start,
    s.shift_end,
    ROUND((s.shift_end - s.shift_start) * 24, 2) AS shift_hours
FROM shifts s
JOIN medical_staffs ms ON s.staff_id = ms.staff_id
WHERE s.shift_start >= TRUNC(SYSDATE)
ORDER BY s.shift_start, ms.last_name;

-- ============================================
-- 11. MEDICATIONS ADMINISTERED
-- ============================================
-- Recent medication administrations
SELECT 
    p.first_name || ' ' || p.last_name AS patient_name,
    m.medication_name,
    ma.dosage,
    ma.administration_datetime,
    ms.first_name || ' ' || ms.last_name AS administered_by
FROM medications_administered ma
JOIN patients p ON ma.patient_id = p.patient_id
JOIN er_meds m ON ma.medication_id = m.medication_id
JOIN medical_staffs ms ON ma.staff_id = ms.staff_id
ORDER BY ma.administration_datetime DESC
FETCH FIRST 20 ROWS ONLY;

-- ============================================
-- 12. COMPREHENSIVE ER DASHBOARD
-- ============================================
-- Complete ER status overview
SELECT 
    'Total Patients Today' AS metric,
    TO_CHAR(COUNT(*)) AS value
FROM er_arrivals
WHERE TRUNC(arrival_datetime) = TRUNC(SYSDATE)
UNION ALL
SELECT 
    'Patients Waiting',
    TO_CHAR(COUNT(*))
FROM er_arrivals
WHERE arrival_status = 'Waiting'
UNION ALL
SELECT 
    'Patients In Treatment',
    TO_CHAR(COUNT(*))
FROM er_arrivals
WHERE arrival_status = 'In Treatment'
UNION ALL
SELECT 
    'Available Beds',
    TO_CHAR(COUNT(*))
FROM er_beds
WHERE status = 'Available'
UNION ALL
SELECT 
    'Critical Patients',
    TO_CHAR(COUNT(*))
FROM er_arrivals ea
JOIN triage_levels t ON ea.triage_level_id = t.triage_level_id
WHERE t.triage_name = 'Critical'
  AND ea.arrival_status IN ('Waiting', 'In Treatment')
UNION ALL
SELECT 
    'Active Staff On Duty',
    TO_CHAR(COUNT(DISTINCT s.staff_id))
FROM shifts s
WHERE SYSDATE BETWEEN s.shift_start AND s.shift_end;
