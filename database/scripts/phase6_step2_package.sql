-- Phase VI Step 2: Create Package
-- Run this after step 1
CREATE
OR REPLACE PACKAGE pkg_er_triage_mgmt AS e_invalid_status EXCEPTION;

e_missing_reference EXCEPTION;

PROCEDURE proc_register_arrival(
    p_patient_national_id IN VARCHAR2,
    p_arrival_mode IN VARCHAR2,
    p_triage_level_code IN NUMBER,
    p_bed_code IN VARCHAR2,
    p_physician_staff_number IN VARCHAR2,
    p_new_arrival_id OUT NUMBER
);

PROCEDURE proc_update_arrival_status(p_arrival_id IN NUMBER, p_new_status IN VARCHAR2);

PROCEDURE proc_discharge_patient(
    p_arrival_id IN NUMBER,
    p_diagnosis IN VARCHAR2,
    p_disposition IN VARCHAR2
);

PROCEDURE proc_flag_long_waits(p_threshold_minutes IN NUMBER);

FUNCTION fn_calc_wait_minutes(p_arrival_id IN NUMBER) RETURN NUMBER;

FUNCTION fn_is_valid_status(p_status IN VARCHAR2) RETURN CHAR;

FUNCTION fn_get_triage_name(p_level_code IN NUMBER) RETURN VARCHAR2;

FUNCTION fn_patient_visit_count(p_patient_id IN NUMBER) RETURN NUMBER;

END pkg_er_triage_mgmt;
/

CREATE OR REPLACE PACKAGE BODY pkg_er_triage_mgmt AS 
PROCEDURE log_error(
    p_proc_name IN VARCHAR2,
    p_error_code IN NUMBER,
    p_error_msg IN VARCHAR2,
    p_extra IN VARCHAR2 := NULL
) IS BEGIN
INSERT INTO
    er_error_log(
        procedure_name,
        error_code,
        error_message,
        extra_info
    )
VALUES
(p_proc_name, p_error_code, p_error_msg, p_extra);

EXCEPTION
WHEN OTHERS THEN NULL;

END log_error;

FUNCTION fn_is_valid_status(p_status IN VARCHAR2) RETURN CHAR IS BEGIN IF UPPER(p_status) IN(
    'WAITING',
    'INTREATMENT',
    'DISCHARGED',
    'ADMITTED',
    'LEFTWITHOUTBEINGSEEN',
    'DECEASED'
) THEN RETURN 'Y';

ELSE RETURN 'N';

END IF;

END fn_is_valid_status;

FUNCTION fn_get_triage_name(p_level_code IN NUMBER) RETURN VARCHAR2 IS v_name triage_levels.level_name % TYPE;

BEGIN
SELECT
    level_name INTO v_name
FROM
    triage_levels
WHERE
    level_code = p_level_code;

RETURN v_name;

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN NULL;

END fn_get_triage_name;

FUNCTION fn_patient_visit_count(p_patient_id IN NUMBER) RETURN NUMBER IS v_cnt NUMBER;

BEGIN
SELECT
    COUNT(*) INTO v_cnt
FROM
    er_arrivals
WHERE
    patient_id = p_patient_id;

RETURN v_cnt;

END fn_patient_visit_count;

FUNCTION fn_calc_wait_minutes(p_arrival_id IN NUMBER) RETURN NUMBER IS v_arrival_time er_arrivals.arrival_datetime % TYPE;

v_start_time DATE;

BEGIN
SELECT
    arrival_datetime INTO v_arrival_time
FROM
    er_arrivals
WHERE
    arrival_id = p_arrival_id;

BEGIN
SELECT
    MIN(start_time) INTO v_start_time
FROM
    treatment_sessions
WHERE
    arrival_id = p_arrival_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN v_start_time := SYSDATE;

END;

RETURN ROUND((v_start_time - v_arrival_time) * 24 * 60, 1);

EXCEPTION
WHEN NO_DATA_FOUND THEN RETURN NULL;

END fn_calc_wait_minutes;

PROCEDURE proc_register_arrival(
    p_patient_national_id IN VARCHAR2,
    p_arrival_mode IN VARCHAR2,
    p_triage_level_code IN NUMBER,
    p_bed_code IN VARCHAR2,
    p_physician_staff_number IN VARCHAR2,
    p_new_arrival_id OUT NUMBER
) IS v_patient_id patients.patient_id % TYPE;

v_triage_id triage_levels.triage_level_id % TYPE;

v_bed_id er_beds.bed_id % TYPE;

v_physician_id medical_staffs.staff_id % TYPE;

BEGIN
SELECT
    patient_id INTO v_patient_id
FROM
    patients
WHERE
    national_id = p_patient_national_id;

SELECT
    triage_level_id INTO v_triage_id
FROM
    triage_levels
WHERE
    level_code = p_triage_level_code;

SELECT
    bed_id INTO v_bed_id
FROM
    er_beds
WHERE
    bed_code = p_bed_code;

SELECT
    staff_id INTO v_physician_id
FROM
    medical_staffs
WHERE
    staff_number = p_physician_staff_number;

INSERT INTO
    er_arrivals(
        patient_id,
        arrival_datetime,
        arrival_mode,
        triage_level_id,
        triage_nurse_id,
        bed_id,
        physician_id,
        status
    )
VALUES
(
        v_patient_id,
        SYSDATE,
        p_arrival_mode,
        v_triage_id,
        NULL,
        v_bed_id,
        v_physician_id,
        'Waiting'
    ) RETURNING arrival_id INTO p_new_arrival_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN log_error(
    'proc_register_arrival',
    SQLCODE,
    SQLERRM,
    'Missing reference'
);

RAISE e_missing_reference;

WHEN OTHERS THEN log_error('proc_register_arrival', SQLCODE, SQLERRM);

RAISE;

END proc_register_arrival;

PROCEDURE proc_update_arrival_status(p_arrival_id IN NUMBER, p_new_status IN VARCHAR2) IS v_old_status er_arrivals.status % TYPE;

BEGIN IF fn_is_valid_status(p_new_status) = 'N' THEN RAISE e_invalid_status;

END IF;

SELECT
    status INTO v_old_status
FROM
    er_arrivals
WHERE
    arrival_id = p_arrival_id 
FOR UPDATE;

UPDATE
    er_arrivals
SET
    status = p_new_status
WHERE
    arrival_id = p_arrival_id;

INSERT INTO
    er_audit_log(
        action,
        arrival_id,
        old_status,
        new_status,
        user_name
    )
VALUES
(
        'STATUS_UPDATE',
        p_arrival_id,
        v_old_status,
        p_new_status,
        USER
    );

EXCEPTION
WHEN e_invalid_status THEN log_error(
    'proc_update_arrival_status',
    -20001,
    'Invalid status: ' || p_new_status
);

RAISE;

WHEN NO_DATA_FOUND THEN log_error(
    'proc_update_arrival_status',
    SQLCODE,
    'Arrival not found'
);

RAISE;

WHEN OTHERS THEN log_error('proc_update_arrival_status', SQLCODE, SQLERRM);

RAISE;

END proc_update_arrival_status;

PROCEDURE proc_discharge_patient(
    p_arrival_id IN NUMBER,
    p_diagnosis IN VARCHAR2,
    p_disposition IN VARCHAR2
) 
IS 
    v_session_id treatment_sessions.session_id%TYPE;
BEGIN
INSERT INTO
    treatment_sessions(
        arrival_id,
        start_time,
        end_time,
        primary_diagnosis,
        disposition,
        physician_id
    )
SELECT
    a.arrival_id,
    NVL(
        (
            SELECT
                MIN(start_time)
            FROM
                treatment_sessions ts
            WHERE
                ts.arrival_id = a.arrival_id
        ),
        a.arrival_datetime
    ),
    SYSDATE,
    p_diagnosis,
    p_disposition,
    a.physician_id
FROM
    er_arrivals a
WHERE
    a.arrival_id = p_arrival_id
RETURNING session_id INTO v_session_id;

UPDATE
    er_arrivals
SET
    status = 'Discharged'
WHERE
    arrival_id = p_arrival_id;

INSERT INTO
    er_audit_log(
        action,
        arrival_id,
        session_id,
        old_status,
        new_status,
        user_name,
        details
    )
VALUES
(
        'DISCHARGE',
        p_arrival_id,
        v_session_id,
        'InTreatment',
        'Discharged',
        USER,
        p_diagnosis
    );

EXCEPTION
WHEN NO_DATA_FOUND THEN log_error(
    'proc_discharge_patient',
    SQLCODE,
    'Arrival not found'
);

RAISE;

WHEN OTHERS THEN log_error('proc_discharge_patient', SQLCODE, SQLERRM);

RAISE;

END proc_discharge_patient;

PROCEDURE proc_flag_long_waits(p_threshold_minutes IN NUMBER) IS CURSOR c_long_waits IS
SELECT
    a.arrival_id,
    fn_calc_wait_minutes(a.arrival_id) AS wait_mins
FROM
    er_arrivals a;

v_rec c_long_waits % ROWTYPE;

BEGIN OPEN c_long_waits;

LOOP FETCH c_long_waits INTO v_rec;

EXIT
WHEN c_long_waits % NOTFOUND;

IF v_rec.wait_mins IS NOT NULL
AND v_rec.wait_mins > p_threshold_minutes THEN
INSERT INTO
    er_audit_log(action, arrival_id, details, user_name)
VALUES
(
        'LONG_WAIT',
        v_rec.arrival_id,
        'Wait time minutes = ' || v_rec.wait_mins,
        USER
    );

END IF;

END LOOP;

CLOSE c_long_waits;

EXCEPTION
WHEN OTHERS THEN log_error(
    'proc_flag_long_waits',
    SQLCODE,
    SQLERRM,
    'Threshold=' || p_threshold_minutes
);

RAISE;

END proc_flag_long_waits;

END pkg_er_triage_mgmt;

/