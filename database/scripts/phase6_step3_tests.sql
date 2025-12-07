SET SERVEROUTPUT ON;

DECLARE v_new_arrival_id NUMBER;
BEGIN 
    pkg_er_triage_mgmt.proc_register_arrival(p_patient_national_id => 'ID1001', p_arrival_mode => 'Walk-in', p_triage_level_code => 3, p_bed_code => 'ER-BED-01', p_physician_staff_number => 'DR001', p_new_arrival_id => v_new_arrival_id);
    DBMS_OUTPUT.PUT_LINE('Test 1: New arrival_id = ' || v_new_arrival_id);
    COMMIT;
END;
/

BEGIN 
    pkg_er_triage_mgmt.proc_update_arrival_status(p_arrival_id => 1, p_new_status => 'InTreatment');
    DBMS_OUTPUT.PUT_LINE('Test 2: Status updated to InTreatment');
    COMMIT;
END;
/

BEGIN 
    pkg_er_triage_mgmt.proc_discharge_patient(p_arrival_id => 1, p_diagnosis => 'Minor laceration', p_disposition => 'Home');
    DBMS_OUTPUT.PUT_LINE('Test 3: Patient discharged');
    COMMIT;
END;
/

BEGIN 
    pkg_er_triage_mgmt.proc_flag_long_waits(p_threshold_minutes => 30);
    DBMS_OUTPUT.PUT_LINE('Test 4: Long waits flagged');
    COMMIT;
END;
/

DECLARE v_wait_mins NUMBER; v_triage_name VARCHAR2(100); v_visit_count NUMBER;
BEGIN 
    v_wait_mins := pkg_er_triage_mgmt.fn_calc_wait_minutes(1);
    v_triage_name := pkg_er_triage_mgmt.fn_get_triage_name(3);
    v_visit_count := pkg_er_triage_mgmt.fn_patient_visit_count(1);
    DBMS_OUTPUT.PUT_LINE('Test 5: Wait=' || v_wait_mins || ' mins, Triage=' || v_triage_name || ', Visits=' || v_visit_count);
END;
/

SELECT * FROM er_audit_log ORDER BY audit_time DESC;
SELECT * FROM er_error_log ORDER BY log_time DESC;

SELECT arrival_id, patient_id, arrival_datetime, status, RANK() OVER (ORDER BY arrival_datetime) AS wait_rank FROM er_arrivals WHERE status IN ('Waiting', 'InTreatment') ORDER BY wait_rank;

SELECT arrival_id, patient_id, arrival_datetime, LAG(arrival_datetime, 1) OVER (ORDER BY arrival_datetime) AS prev_arrival_time, ROUND((arrival_datetime - LAG(arrival_datetime, 1) OVER (ORDER BY arrival_datetime)) * 24 * 60, 1) AS minutes_since_prev FROM er_arrivals ORDER BY arrival_datetime DESC FETCH FIRST 10 ROWS ONLY;