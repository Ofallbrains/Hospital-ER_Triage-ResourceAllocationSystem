-- Phase V: Data Insertion – Sample and Pattern Data

-- TRIAGE_LEVELS (5-level ESI)
INSERT INTO triage_levels (level_code, level_name, description, target_wait_mins) VALUES (1, 'Resuscitation', 'Immediate life-saving intervention required', 0);
INSERT INTO triage_levels (level_code, level_name, description, target_wait_mins) VALUES (2, 'Emergent', 'High risk, severe pain or distress', 10);
INSERT INTO triage_levels (level_code, level_name, description, target_wait_mins) VALUES (3, 'Urgent', 'Stable but requires multiple resources', 30);
INSERT INTO triage_levels (level_code, level_name, description, target_wait_mins) VALUES (4, 'Less Urgent', 'Stable, one resource expected', 60);
INSERT INTO triage_levels (level_code, level_name, description, target_wait_mins) VALUES (5, 'Non-Urgent', 'Minor issues, no resources expected', 120);

-- MEDICAL_STAFFS (triage nurses, physicians, bed manager, support)
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('TN001', 'Grace', 'Nurse', 'Triage Nurse', 'ER', '555-1001', 'grace.nurse@hospital.org');
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('TN002', 'Alex', 'Moyo', 'Triage Nurse', 'ER', '555-1002', 'alex.moyo@hospital.org');
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('DR001', 'Samuel', 'Kariuki', 'ER Physician', 'ER', '555-2001', 'samuel.kariuki@hospital.org');
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('DR002', 'Linda', 'Chen', 'ER Physician', 'ER', '555-2002', 'linda.chen@hospital.org');
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('BM001', 'Peter', 'Otieno', 'Bed Manager', 'ER', '555-3001', 'peter.otieno@hospital.org');
INSERT INTO medical_staffs (staff_number, first_name, last_name, role, department, phone_number, email)
VALUES ('SS001', 'Mary', 'Khan', 'Support Staff', 'Radiology', '555-4001', 'mary.khan@hospital.org');

-- ER_BEDS
INSERT INTO er_beds (bed_code, location_zone, is_isolation, status) VALUES ('ER-BED-01', 'Zone A', 'N', 'Available');
INSERT INTO er_beds (bed_code, location_zone, is_isolation, status) VALUES ('ER-BED-02', 'Zone A', 'Y', 'Available');
INSERT INTO er_beds (bed_code, location_zone, is_isolation, status) VALUES ('ER-BED-03', 'Zone B', 'N', 'Available');

-- MEDICAL_EQUIPMENTS
INSERT INTO medical_equipments (equipment_code, name, status, location_zone)
VALUES ('DEFIB-01', 'Defibrillator', 'Available', 'Resus');
INSERT INTO medical_equipments (equipment_code, name, status, location_zone)
VALUES ('VENT-01', 'Ventilator', 'Available', 'Resus');
INSERT INTO medical_equipments (equipment_code, name, status, location_zone)
VALUES ('MON-01', 'Cardiac Monitor', 'Available', 'Zone A');

-- ER_MEDS
INSERT INTO er_meds (med_code, generic_name, route, default_dose_mg) VALUES ('MORPH-10', 'Morphine', 'IV', 10);
INSERT INTO er_meds (med_code, generic_name, route, default_dose_mg) VALUES ('PARA-1000', 'Paracetamol', 'PO', 1000);
INSERT INTO er_meds (med_code, generic_name, route, default_dose_mg) VALUES ('ASA-300', 'Aspirin', 'PO', 300);

-- SUPPLIES
INSERT INTO supplies (supply_code, name, unit_of_measure) VALUES ('IV-CAN-18G', 'IV Cannula 18G', 'piece');
INSERT INTO supplies (supply_code, name, unit_of_measure) VALUES ('N95-MASK', 'N95 Mask', 'piece');
INSERT INTO supplies (supply_code, name, unit_of_measure) VALUES ('SYR-10ML', 'Syringe 10ml', 'piece');

-- SUPPLY_INVENTORY
INSERT INTO supply_inventory (supply_id, location_zone, quantity_on_hand, reorder_level)
SELECT supply_id, 'Main Store', 500, 100 FROM supplies WHERE supply_code = 'IV-CAN-18G';
INSERT INTO supply_inventory (supply_id, location_zone, quantity_on_hand, reorder_level)
SELECT supply_id, 'Main Store', 300, 80 FROM supplies WHERE supply_code = 'N95-MASK';
INSERT INTO supply_inventory (supply_id, location_zone, quantity_on_hand, reorder_level)
SELECT supply_id, 'Zone A', 200, 50 FROM supplies WHERE supply_code = 'SYR-10ML';

-- PATIENTS (mix of ages, genders, some null emails, edge cases)
INSERT INTO patients (national_id, first_name, last_name, date_of_birth, gender, phone_number, email, city, state_province, postal_code)
VALUES ('ID1001', 'John', 'Kamau', DATE '1985-03-15', 'Male', '0711-000001', 'john.kamau@example.com', 'Nairobi', 'Nairobi', '00100');
INSERT INTO patients (national_id, first_name, last_name, date_of_birth, gender, phone_number, email, city, state_province, postal_code)
VALUES ('ID1002', 'Sarah', 'Mutiso', DATE '1992-07-21', 'Female', '0722-000002', NULL, 'Nakuru', 'Nakuru', '20100');
INSERT INTO patients (national_id, first_name, last_name, date_of_birth, gender, phone_number, email, city, state_province, postal_code)
VALUES ('ID1003', 'David', 'Otieno', DATE '1970-11-02', 'Male', '0733-000003', 'd.otieno@example.com', 'Kisumu', 'Kisumu', '40100');
INSERT INTO patients (national_id, first_name, last_name, date_of_birth, gender, phone_number, email, city, state_province, postal_code)
VALUES ('ID1004', 'Amina', 'Hassan', DATE '2008-01-05', 'Female', '0744-000004', 'amina.guardian@example.com', 'Mombasa', 'Mombasa', '80100');
INSERT INTO patients (national_id, first_name, last_name, date_of_birth, gender, phone_number, email, city, state_province, postal_code)
VALUES ('ID1005', 'Michael', 'Ouma', DATE '1960-09-30', 'Male', '0755-000005', NULL, 'Eldoret', 'Uasin Gishu', '30100');

-- ER_ARRIVALS (linking to patients, nurses, beds, triage levels)
INSERT INTO er_arrivals (patient_id, arrival_datetime, arrival_mode, triage_level_id, triage_nurse_id, bed_id, physician_id, status)
VALUES (
  (SELECT patient_id FROM patients WHERE national_id = 'ID1001'),
  SYSDATE - (1/24),
  'Ambulance',
  (SELECT triage_level_id FROM triage_levels WHERE level_code = 1),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN001'),
  (SELECT bed_id FROM er_beds WHERE bed_code = 'ER-BED-01'),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR001'),
  'InTreatment'
);

INSERT INTO er_arrivals (patient_id, arrival_datetime, arrival_mode, triage_level_id, triage_nurse_id, bed_id, physician_id, status)
VALUES (
  (SELECT patient_id FROM patients WHERE national_id = 'ID1002'),
  SYSDATE - (2/24),
  'Walk-in',
  (SELECT triage_level_id FROM triage_levels WHERE level_code = 3),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN002'),
  (SELECT bed_id FROM er_beds WHERE bed_code = 'ER-BED-02'),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR001'),
  'InTreatment'
);

INSERT INTO er_arrivals (patient_id, arrival_datetime, arrival_mode, triage_level_id, triage_nurse_id, bed_id, physician_id, status)
VALUES (
  (SELECT patient_id FROM patients WHERE national_id = 'ID1003'),
  SYSDATE - (5/24),
  'Walk-in',
  (SELECT triage_level_id FROM triage_levels WHERE level_code = 2),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN001'),
  (SELECT bed_id FROM er_beds WHERE bed_code = 'ER-BED-03'),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR002'),
  'Discharged'
);

INSERT INTO er_arrivals (patient_id, arrival_datetime, arrival_mode, triage_level_id, triage_nurse_id, bed_id, physician_id, status)
VALUES (
  (SELECT patient_id FROM patients WHERE national_id = 'ID1004'),
  SYSDATE - (3/24),
  'Ambulance',
  (SELECT triage_level_id FROM triage_levels WHERE level_code = 2),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN002'),
  NULL,
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR002'),
  'Waiting'
);

-- Edge case: patient left without being seen
INSERT INTO er_arrivals (patient_id, arrival_datetime, arrival_mode, triage_level_id, triage_nurse_id, bed_id, physician_id, status)
VALUES (
  (SELECT patient_id FROM patients WHERE national_id = 'ID1005'),
  SYSDATE - (8/24),
  'Walk-in',
  (SELECT triage_level_id FROM triage_levels WHERE level_code = 4),
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN001'),
  NULL,
  NULL,
  'LeftWithoutBeingSeen'
);

-- TREATMENT_SESSIONS
INSERT INTO treatment_sessions (arrival_id, start_time, end_time, primary_diagnosis, disposition, physician_id)
VALUES (
  (SELECT arrival_id FROM er_arrivals a JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1001'),
  SYSDATE - (1/24),
  SYSDATE,
  'Acute Myocardial Infarction',
  'Admitted',
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR001')
);

INSERT INTO treatment_sessions (arrival_id, start_time, end_time, primary_diagnosis, disposition, physician_id)
VALUES (
  (SELECT arrival_id FROM er_arrivals a JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1002'),
  SYSDATE - (2/24),
  SYSDATE - (1/24),
  'Migraine',
  'Discharged',
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR001')
);

INSERT INTO treatment_sessions (arrival_id, start_time, end_time, primary_diagnosis, disposition, physician_id)
VALUES (
  (SELECT arrival_id FROM er_arrivals a JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1003'),
  SYSDATE - (5/24),
  SYSDATE - (4/24),
  'Asthma Exacerbation',
  'Discharged',
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR002')
);

-- MEDICATIONS_ADMINISTERED
INSERT INTO medications_administered (session_id, med_id, administered_time, dose_mg, administered_by)
VALUES (
  (SELECT session_id FROM treatment_sessions ts JOIN er_arrivals a ON ts.arrival_id = a.arrival_id JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1001'),
  (SELECT med_id FROM er_meds WHERE med_code = 'MORPH-10'),
  SYSDATE - (50/1440),
  10,
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN001')
);

INSERT INTO medications_administered (session_id, med_id, administered_time, dose_mg, administered_by)
VALUES (
  (SELECT session_id FROM treatment_sessions ts JOIN er_arrivals a ON ts.arrival_id = a.arrival_id JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1002'),
  (SELECT med_id FROM er_meds WHERE med_code = 'PARA-1000'),
  SYSDATE - (80/1440),
  1000,
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'TN002')
);

-- CRITICAL_ALERTS
INSERT INTO critical_alerts (arrival_id, created_time, alert_type, severity, message, acknowledged_by, acknowledged_time)
VALUES (
  (SELECT arrival_id FROM er_arrivals a JOIN patients p ON a.patient_id = p.patient_id WHERE p.national_id = 'ID1001'),
  SYSDATE - (55/1440),
  'Cardiac Arrest',
  'Critical',
  'Patient required immediate resuscitation on arrival.',
  (SELECT staff_id FROM medical_staffs WHERE staff_number = 'DR001'),
  SYSDATE - (50/1440)
);

COMMIT;
