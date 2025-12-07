CREATE OR REPLACE FUNCTION fn_is_holiday(p_check_date IN DATE) RETURN BOOLEAN IS v_count NUMBER; BEGIN SELECT COUNT(*) INTO v_count FROM public_holidays WHERE holiday_date = TRUNC(p_check_date); RETURN v_count > 0; END fn_is_holiday;
/

CREATE OR REPLACE FUNCTION fn_is_weekday(p_check_date IN DATE) RETURN BOOLEAN IS v_day_name VARCHAR2(10); BEGIN v_day_name := TO_CHAR(p_check_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH'); RETURN v_day_name IN ('MON', 'TUE', 'WED', 'THU', 'FRI'); END fn_is_weekday;
/

CREATE OR REPLACE PROCEDURE proc_log_employee_action(p_action_type IN VARCHAR2, p_table_name IN VARCHAR2, p_status IN VARCHAR2, p_error_msg IN VARCHAR2 DEFAULT NULL) IS PRAGMA AUTONOMOUS_TRANSACTION; BEGIN INSERT INTO employee_action_audit(username, action_type, table_name, action_status, error_message, session_info) VALUES(USER, p_action_type, p_table_name, p_status, p_error_msg, 'SID:' || SYS_CONTEXT('USERENV', 'SID') || ' HOST:' || SYS_CONTEXT('USERENV', 'HOST')); COMMIT; END proc_log_employee_action;
/

CREATE OR REPLACE TRIGGER trg_medical_staffs_restrict BEFORE INSERT OR UPDATE OR DELETE ON medical_staffs FOR EACH ROW DECLARE v_operation VARCHAR2(20); v_error_msg VARCHAR2(500); BEGIN v_operation := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' WHEN DELETING THEN 'DELETE' END; IF fn_is_weekday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on weekdays (Monday-Friday)'; proc_log_employee_action(v_operation, 'MEDICAL_STAFFS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20001, v_error_msg); END IF; IF fn_is_holiday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on public holidays'; proc_log_employee_action(v_operation, 'MEDICAL_STAFFS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20002, v_error_msg); END IF; proc_log_employee_action(v_operation, 'MEDICAL_STAFFS', 'ALLOWED', NULL); END;
/

CREATE OR REPLACE TRIGGER trg_er_beds_restrict BEFORE INSERT OR UPDATE OR DELETE ON er_beds FOR EACH ROW DECLARE v_operation VARCHAR2(20); v_error_msg VARCHAR2(500); BEGIN v_operation := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' WHEN DELETING THEN 'DELETE' END; IF fn_is_weekday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on weekdays (Monday-Friday)'; proc_log_employee_action(v_operation, 'ER_BEDS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20001, v_error_msg); END IF; IF fn_is_holiday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on public holidays'; proc_log_employee_action(v_operation, 'ER_BEDS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20002, v_error_msg); END IF; proc_log_employee_action(v_operation, 'ER_BEDS', 'ALLOWED', NULL); END;
/

CREATE OR REPLACE TRIGGER trg_patients_compound FOR INSERT OR UPDATE OR DELETE ON patients COMPOUND TRIGGER v_operation VARCHAR2(20); v_error_msg VARCHAR2(500); BEFORE STATEMENT IS BEGIN v_operation := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' WHEN DELETING THEN 'DELETE' END; IF fn_is_weekday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on weekdays (Monday-Friday)'; proc_log_employee_action(v_operation, 'PATIENTS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20001, v_error_msg); END IF; IF fn_is_holiday(SYSDATE) THEN v_error_msg := 'Operation denied: Cannot ' || v_operation || ' on public holidays'; proc_log_employee_action(v_operation, 'PATIENTS', 'DENIED', v_error_msg); RAISE_APPLICATION_ERROR(-20002, v_error_msg); END IF; END BEFORE STATEMENT; BEFORE EACH ROW IS BEGIN NULL; END BEFORE EACH ROW; AFTER STATEMENT IS BEGIN proc_log_employee_action(v_operation, 'PATIENTS', 'ALLOWED', NULL); END AFTER STATEMENT; END trg_patients_compound;
/

SELECT 'Functions and triggers created' AS status FROM dual;

SELECT trigger_name, status FROM user_triggers WHERE table_name IN ('MEDICAL_STAFFS', 'ER_BEDS', 'PATIENTS') ORDER BY trigger_name;
