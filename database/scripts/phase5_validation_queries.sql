-- Phase V: Data Integrity Verification & Testing Queries

-- 1. Basic retrieval
SELECT * FROM patients;
SELECT * FROM er_arrivals;
SELECT * FROM treatment_sessions;
SELECT * FROM medications_administered;

-- 2. Joins: arrivals with patients and triage level
SELECT a.arrival_id,
       p.first_name || ' ' || p.last_name AS patient_name,
       tl.level_code,
       tl.level_name,
       a.arrival_datetime,
       a.status
FROM er_arrivals a
JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN triage_levels tl ON a.triage_level_id = tl.triage_level_id
ORDER BY a.arrival_datetime DESC;

-- 3. Aggregations (GROUP BY): count arrivals by triage level
SELECT tl.level_code,
       tl.level_name,
       COUNT(*) AS arrival_count
FROM er_arrivals a
JOIN triage_levels tl ON a.triage_level_id = tl.triage_level_id
GROUP BY tl.level_code, tl.level_name
ORDER BY tl.level_code;

-- 4. Aggregations: average length of stay (hours) by disposition
SELECT ts.disposition,
       ROUND(AVG((NVL(ts.end_time, SYSDATE) - ts.start_time) * 24), 2) AS avg_los_hours
FROM treatment_sessions ts
GROUP BY ts.disposition;

-- 5. Subquery: patients who received opioids (Morphine)
SELECT p.patient_id,
       p.first_name,
       p.last_name
FROM patients p
WHERE p.patient_id IN (
  SELECT a.patient_id
  FROM er_arrivals a
  JOIN treatment_sessions ts ON a.arrival_id = ts.arrival_id
  JOIN medications_administered ma ON ts.session_id = ma.session_id
  JOIN er_meds m ON ma.med_id = m.med_id
  WHERE m.generic_name = 'Morphine'
);

-- 6. Data completeness check: arrivals without treatment sessions
SELECT a.arrival_id,
       p.first_name || ' ' || p.last_name AS patient_name,
       a.status
FROM er_arrivals a
JOIN patients p ON a.patient_id = p.patient_id
WHERE NOT EXISTS (
  SELECT 1 FROM treatment_sessions ts WHERE ts.arrival_id = a.arrival_id
);

