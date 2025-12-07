-- Phase VII: Comprehensive Audit Queries

-- ============================================
-- 1. RECENT AUDIT ENTRIES
-- ============================================
-- View most recent audit log entries with full details
SELECT 
    audit_time,
    username,
    action_type,
    table_name,
    action_status,
    SUBSTR(error_message, 1, 70) AS error_message,
    session_info
FROM employee_action_audit
ORDER BY audit_time DESC
FETCH FIRST 20 ROWS ONLY;

-- ============================================
-- 2. ACTION STATISTICS
-- ============================================
-- Count of allowed vs denied operations by action type
SELECT 
    action_type,
    action_status,
    COUNT(*) AS attempt_count
FROM employee_action_audit
GROUP BY action_type, action_status
ORDER BY action_type, action_status;

-- ============================================
-- 3. USER ACTIVITY TRACKING
-- ============================================
-- Audit trail summary by database user
SELECT 
    username,
    COUNT(*) AS total_attempts,
    SUM(CASE WHEN action_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed_count,
    SUM(CASE WHEN action_status = 'DENIED' THEN 1 ELSE 0 END) AS denied_count,
    ROUND(SUM(CASE WHEN action_status = 'ALLOWED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM employee_action_audit
GROUP BY username
ORDER BY total_attempts DESC;

-- ============================================
-- 4. TABLE MODIFICATION HISTORY
-- ============================================
-- Operations performed on each protected table
SELECT 
    table_name,
    action_type,
    COUNT(*) AS occurrence_count,
    MIN(audit_time) AS first_attempt,
    MAX(audit_time) AS last_attempt
FROM employee_action_audit
GROUP BY table_name, action_type
ORDER BY table_name, action_type;

-- ============================================
-- 5. FAILED OPERATION ANALYSIS
-- ============================================
-- All denied operations with error details
SELECT 
    audit_time,
    username,
    action_type,
    table_name,
    error_message
FROM employee_action_audit
WHERE action_status = 'DENIED'
ORDER BY audit_time DESC;

-- ============================================
-- 6. TIME-BASED AUDIT ANALYSIS
-- ============================================
-- Operations by hour of day (identify peak activity times)
SELECT 
    TO_CHAR(audit_time, 'HH24') AS hour_of_day,
    action_status,
    COUNT(*) AS operation_count
FROM employee_action_audit
GROUP BY TO_CHAR(audit_time, 'HH24'), action_status
ORDER BY hour_of_day, action_status;

-- Operations by day of week
SELECT 
    TO_CHAR(audit_time, 'DAY') AS day_of_week,
    action_status,
    COUNT(*) AS operation_count
FROM employee_action_audit
GROUP BY TO_CHAR(audit_time, 'DAY'), action_status
ORDER BY 
    CASE TO_CHAR(audit_time, 'D')
        WHEN '1' THEN 7  -- Sunday
        WHEN '2' THEN 1  -- Monday
        WHEN '3' THEN 2  -- Tuesday
        WHEN '4' THEN 3  -- Wednesday
        WHEN '5' THEN 4  -- Thursday
        WHEN '6' THEN 5  -- Friday
        WHEN '7' THEN 6  -- Saturday
    END,
    action_status;

-- ============================================
-- 7. SESSION INFORMATION QUERY
-- ============================================
-- Detailed session information from audit log
SELECT 
    audit_time,
    username,
    action_type || ' ' || table_name AS operation,
    action_status,
    session_info
FROM employee_action_audit
ORDER BY audit_time DESC
FETCH FIRST 10 ROWS ONLY;

-- ============================================
-- 8. AUDIT LOG GROWTH ANALYSIS
-- ============================================
-- Track audit table growth over time
SELECT 
    TRUNC(audit_time) AS audit_date,
    COUNT(*) AS daily_operations,
    SUM(CASE WHEN action_status = 'ALLOWED' THEN 1 ELSE 0 END) AS allowed,
    SUM(CASE WHEN action_status = 'DENIED' THEN 1 ELSE 0 END) AS denied
FROM employee_action_audit
GROUP BY TRUNC(audit_time)
ORDER BY audit_date DESC;

-- ============================================
-- 9. ERROR MESSAGE ANALYSIS
-- ============================================
-- Common error patterns from denied operations
SELECT 
    SUBSTR(error_message, 1, 100) AS error_pattern,
    COUNT(*) AS occurrence_count
FROM employee_action_audit
WHERE action_status = 'DENIED'
GROUP BY SUBSTR(error_message, 1, 100)
ORDER BY occurrence_count DESC;

-- ============================================
-- 10. COMPLETE AUDIT TRAIL REPORT
-- ============================================
-- Comprehensive audit report with all details
SELECT 
    audit_id,
    TO_CHAR(audit_time, 'YYYY-MM-DD HH24:MI:SS') AS timestamp,
    username,
    action_type,
    table_name,
    action_status,
    CASE 
        WHEN error_message IS NULL THEN 'Success'
        ELSE SUBSTR(error_message, 1, 50)
    END AS result,
    session_info
FROM employee_action_audit
ORDER BY audit_time DESC;

-- ============================================
-- 11. AUDIT TABLE STATISTICS
-- ============================================
-- Overall audit table statistics
SELECT 
    COUNT(*) AS total_audit_records,
    COUNT(DISTINCT username) AS unique_users,
    COUNT(DISTINCT table_name) AS tables_accessed,
    MIN(audit_time) AS earliest_record,
    MAX(audit_time) AS latest_record,
    ROUND((MAX(audit_time) - MIN(audit_time)), 2) AS days_of_data
FROM employee_action_audit;

-- ============================================
-- 12. WEEKEND vs WEEKDAY OPERATIONS
-- ============================================
-- Compare weekend vs weekday operation patterns
SELECT 
    CASE 
        WHEN TO_CHAR(audit_time, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS period_type,
    action_status,
    COUNT(*) AS operation_count
FROM employee_action_audit
GROUP BY 
    CASE 
        WHEN TO_CHAR(audit_time, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') 
        THEN 'Weekend'
        ELSE 'Weekday'
    END,
    action_status
ORDER BY period_type, action_status;

-- ============================================
-- 13. RECENT ACTIVITY BY TABLE
-- ============================================
-- Last activity timestamp for each protected table
SELECT 
    table_name,
    MAX(audit_time) AS last_activity,
    COUNT(*) AS total_operations,
    SUM(CASE WHEN action_status = 'ALLOWED' THEN 1 ELSE 0 END) AS successful_ops
FROM employee_action_audit
GROUP BY table_name
ORDER BY last_activity DESC;

-- ============================================
-- 14. USER SESSION ANALYSIS
-- ============================================
-- Analyze user sessions and their activities
SELECT 
    username,
    session_info,
    COUNT(DISTINCT audit_id) AS operations_in_session,
    MIN(audit_time) AS session_start,
    MAX(audit_time) AS session_end,
    ROUND((MAX(audit_time) - MIN(audit_time)) * 24 * 60, 2) AS session_duration_minutes
FROM employee_action_audit
GROUP BY username, session_info
ORDER BY session_start DESC;

-- ============================================
-- 15. AUDIT TRAIL EXPORT (CSV-friendly format)
-- ============================================
-- Export-ready format for external analysis tools
SELECT 
    audit_id || ',' ||
    TO_CHAR(audit_time, 'YYYY-MM-DD HH24:MI:SS') || ',' ||
    username || ',' ||
    action_type || ',' ||
    table_name || ',' ||
    action_status || ',' ||
    REPLACE(REPLACE(error_message, ',', ';'), CHR(10), ' ') || ',' ||
    session_info AS csv_export
FROM employee_action_audit
ORDER BY audit_time DESC;
