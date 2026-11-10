/*
    Business Rules
    - The student can only enroll in a class offering if he complies with:
        -- His curriculum enrollment is under the status 'Active' (He's homologated)
        -- The class offering belongs to his current active curriculum map
        -- The class offering has a valid/active faculty assignment status ('Active')
*/
CREATE OR REPLACE FUNCTION fn_trg_bfr_prevent_offering_mismatch ()
RETURNS TRIGGER AS $$
    DECLARE
        v_curriculum_enrollment_status ACADEMIC.e_curriculum_enrollment_status;
        v_class_offering_assignment_status ACADEMIC.e_course_assignment_status;
    BEGIN
        SELECT
            ce.status,
            co.assignment_status
        INTO
            v_curriculum_enrollment_status,
            v_class_offering_assignment_status
        FROM
            ACADEMIC.CLASS_OFFERINGS co
        INNER JOIN
            ACADEMIC.CURRICULUM_OFFERINGS cm ON
                cm.id = co.curriculum_offering_id
        INNER JOIN
            ACADEMIC.CURRICULUM_ENROLLMENTS ce ON
                ce.curriculum_offering_id = co.curriculum_offering_id
                    AND ce.student_id = NEW.student_id
        WHERE co.id = NEW.class_offering_id;


    IF NOT FOUND THEN
        RAISE EXCEPTION 'Class enrollment not executed: The findings did not match any corresponding active curriculum in the student repository for the offered class attempted (Offering ID: %)', NEW.class_offering_id;
    END IF;

    IF v_curriculum_enrollment_status IS DISTINCT FROM 'Active' THEN
        RAISE EXCEPTION 'Class enrollment denied: Student % has no active curriculum enrollment comprising the course offered (Status %)', NEW.student_id, v_curriculum_enrollment_status;
    END IF;

    IF v_class_offering_assignment_status IS DISTINCT FROM 'Active' THEN
        RAISE EXCEPTION 'Class enrollment rejected: Faculty group not defined or not available yet for Class Offering %.', NEW.class_offering_id;
    END IF;

    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

-- limita a atualização apenas à mudança do id da classe
CREATE TRIGGER trg_curriculum_offering_mismatch_preventor
    BEFORE INSERT OR UPDATE OF class_offering_id ON ACADEMIC.CLASS_ENROLLMENTS
        FOR EACH ROW EXECUTE FUNCTION fn_trg_bfr_prevent_offering_mismatch()