CREATE OR REPLACE VIEW v_available_classes AS
    SELECT
        ROUND(
            (COUNT(ce.student_id)::NUMERIC/NULLIF(co.total_available_seats, 0))*100,
            2
        ) AS occupation_percentage
    FROM ACADEMIC.CLASS_OFFERINGS co
        LEFT JOIN ACADEMIC.CLASS_ENROLLMENTS ce
            ON ce.class_offering_id = co.id
            AND ce.status = 'Enrolled'
    GROUP BY co.id, co.total_available_seats;

SELECT * FROM v_available_classes;