-- Verifica se os elementos de um array são distintos entre si
-- A função retorna verdadeiro caso a cardinalidade do array original base com a sua seleção distinta.

CREATE OR REPLACE FUNCTION is_distinct (IN arr anyarray) RETURNS boolean
AS $$
    BEGIN
        RETURN cardinality(arr) = cardinality(
            ARRAY(SELECT DISTINCT * FROM unnest(arr)));
    END
$$ LANGUAGE plpgsql IMMUTABLE STABLE;

CREATE OR REPLACE FUNCTION fn_get_available_seats_by_offering
    (IN p_class_offering_id INTEGER)
RETURNS INTEGER AS $$
    DECLARE
        v_remaining_seats SMALLINT;
    BEGIN
        SELECT
            (co.total_seats_available - COUNT(ce.student_id)::INTEGER)
        INTO v_remaining_seats
        FROM ACADEMIC.CLASS_OFFERINGS co
            LEFT JOIN ACADEMIC.CLASS_ENROLLMENTS ce
                ON ce.class_offering_id = co.id
                AND ce.status = 'Enrolled'
        WHERE co.id = p_class_offering_id
        GROUP BY co.total_seats_available;

        RETURN COALESCE(v_remaining_seats, 0);
    END;
$$ LANGUAGE plpgsql STABLE;

