SET SERVEROUTPUT ON;

BEGIN DBMS_OUTPUT.PUT_LINE('=== Test 1: INSERT on weekend ==='); INSERT INTO medical_staffs(staff_number, first_name, last_name, role, phone_number, email) VALUES('TEST001', 'Test', 'Doctor', 'ER Physician', '555-0001', 'test@hospital.com'); DBMS_OUTPUT.PUT_LINE('Result: ALLOWED'); ROLLBACK; EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Result: DENIED - ' || SQLERRM); ROLLBACK; END;
/

SELECT audit_time, username, action_type, table_name, action_status, SUBSTR(error_message,1,60) AS error_msg FROM employee_action_audit ORDER BY audit_time DESC FETCH FIRST 1 ROW ONLY;

BEGIN DBMS_OUTPUT.PUT_LINE('=== Test 4: UPDATE on weekend ==='); UPDATE er_beds SET status = 'Cleaning' WHERE bed_code = 'ER-BED-01'; DBMS_OUTPUT.PUT_LINE('Result: ALLOWED'); ROLLBACK; EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Result: DENIED - ' || SQLERRM); ROLLBACK; END;
/

BEGIN DBMS_OUTPUT.PUT_LINE('=== Test 5: INSERT new staff on weekend ==='); INSERT INTO medical_staffs(staff_number, first_name, last_name, role, phone_number, email) VALUES('TEST999', 'Weekend', 'Staff', 'Triage Nurse', '555-9999', 'weekend@hospital.com'); DBMS_OUTPUT.PUT_LINE('Result: ALLOWED'); ROLLBACK; EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Result: DENIED - ' || SQLERRM); ROLLBACK; END;
/

BEGIN DBMS_OUTPUT.PUT_LINE('=== Test 6: Bulk INSERT on weekend (compound trigger) ==='); INSERT INTO patients(national_id, first_name, last_name, date_of_birth, gender, phone_number, address_line1) SELECT 'TEST' || ROWNUM, 'Bulk', 'Test' || ROWNUM, DATE '1980-01-01', 'Male', '555-0000', 'Test Address' FROM dual CONNECT BY LEVEL <= 3; DBMS_OUTPUT.PUT_LINE('Result: ALLOWED'); ROLLBACK; EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Result: DENIED - ' || SQLERRM); ROLLBACK; END;
/

SELECT audit_time, username, action_type, table_name, action_status, SUBSTR(error_message, 1, 70) AS error_message FROM employee_action_audit ORDER BY audit_time DESC;

SELECT holiday_date, holiday_name, TO_CHAR(holiday_date, 'DAY') AS day_of_week FROM public_holidays ORDER BY holiday_date;

SELECT action_type, action_status, COUNT(*) AS attempt_count FROM employee_action_audit GROUP BY action_type, action_status ORDER BY action_type, action_status;

SELECT trigger_name, table_name, triggering_event, status FROM user_triggers WHERE table_name IN ('MEDICAL_STAFFS', 'ER_BEDS', 'PATIENTS') ORDER BY table_name, trigger_name;