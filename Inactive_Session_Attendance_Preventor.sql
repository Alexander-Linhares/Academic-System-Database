CREATE OR REPLACE FUNCTION fn_trg_bfr_prevent_attendance_in_non_active_sessions ()
RETURNS TRIGGER AS $$
    DECLARE
        v_schedule_status ACADEMIC.e_session_status;
        v_session_status ACADEMIC.e_session_status;
    BEGIN
        SELECT se.status, sc.status
            INTO v_session_status, v_schedule_status
        FROM ACADEMIC.SESSIONS se
            INNER JOIN ACADEMIC.SCHEDULES sc ON sc.id = se.schedule_id
        WHERE se.id = NEW.session_id;

        IF (v_schedule_status IS DISTINCT FROM 'Active') THEN
            RAISE EXCEPTION 'Attendance record rejected: Parent schedule status is not Active (Current status: %).',
                COALESCE(v_schedule_status:text, 'Not Found / Invalid');
        END IF;

        IF (v_session_status IN ('Scheduled', 'Canceled', 'Rescheduled', 'Substituted')) THEN
            RAISE EXCEPTION 'Attendance record rejected: Session % is currently marked as "%".',
                NEW.session_id, v_session_status;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inactive_session_attendance_preventor
    BEFORE INSERT ON ACADEMIC.ATTENDANCE_RECORDS
        FOR EACH ROW EXECUTE FUNCTION fn_trg_bfr_prevent_attendance_in_non_active_sessions()