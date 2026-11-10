

-- -- Função para converter os dias da semana em inteiros
-- CREATE OR REPLACE FUNCTION ACADEMIC.days_to_intarray(days e_day_of_week[])
-- RETURNS integer[]
-- LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$
--     SELECT ARRAY(
--         SELECT array_position(
--             ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']::text[],
--             day::text
--         )
--         FROM unnest(days) AS day
--     )::integer[];
-- $$;
--
-- -- Função para converter os turnos em inteiros (Ajuste os textos conforme os seus valores reais de d_shifts)
-- CREATE OR REPLACE FUNCTION ACADEMIC.shifts_to_intarray(shifts e_shift[])
-- RETURNS integer[]
-- LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$
--     SELECT ARRAY(
--         SELECT array_position(
--             ARRAY['Morning', 'Afternoon', 'Evening']::text[],
--             shift::text
--         )
--         FROM unnest(shifts) AS shift
--     )::integer[];
-- $$;

-- To be implemented
CREATE OR REPLACE FUNCTION ACADEMIC.fn_trg_prevent_cyclic_relation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
    BEGIN
        RETURN NEW;
    END;
$$;

CREATE OR REPLACE FUNCTION fn_get_frequency_interval(
    IN frequency e_frequency,
    IN amount INTEGER DEFAULT 1
) RETURNS INTERVAL
LANGUAGE plpgsql
AS $$
    BEGIN
        RETURN
            CASE frequency::TEXT
                WHEN 'Daily'    THEN (amount || 'Day')      ::INTERVAL
                WHEN 'Weekly'   THEN (amount || 'Week')     ::INTERVAL
                WHEN 'Monthly'  THEN (amount || 'Month')    ::INTERVAL
                WHEN 'Yearly'   THEN (amount || 'Year')     ::INTERVAL
            END;
    END;
$$;

CREATE OR REPLACE PROCEDURE sp_record_session(IN schedule_reference_id INTEGER, IN date DATE)
AS $$
    BEGIN
        INSERT INTO ACADEMIC.SESSIONS (
            schedule_id,
            session_date
        ) VALUES (
            schedule_reference_id,
            date
        );
    END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ACADEMIC.fn_get_period_window (IN p_period_id INTEGER)
RETURNS TABLE (
    period_range DATERANGE,
    sequential_order INTEGER
)
AS $$
    BEGIN
        -- Brings recursively the entire period sequence from ACADEMIC.PERIODS
        -- which shares the same term type ('Semester', 'Trimester', 'Quarter', ...)
        RETURN QUERY
            WITH RECURSIVE PERIOD_CHAIN AS (
                SELECT
                    p_initial.id,
                    p_initial.term_type,
                    p_initial.period_range,
                    1 AS sequential_order
                FROM ACADEMIC.PERIODS p_initial
                    WHERE p_initial.id = p_period_id

                UNION ALL

                SELECT
                    p.id,
                    p.term_type,
                    p.period_range,
                    pc.sequential_order + 1
                FROM ACADEMIC.PERIODS p
                INNER JOIN PERIOD_CHAIN pc
                    ON p.predecessor_period_id = pc.id
            )
            SELECT
                pc.period_range,
                pc.sequential_order
            FROM PERIOD_CHAIN pc;
    END;
$$ LANGUAGE plpgsql;

SELECT ACADEMIC.fn_get_period_window(1);

-- Generate Sessions
-- Designed to automatically generate sessions following prior scheduled reservations,
-- this function materializes the exact date across the valid range provided, in default,
-- the system uses the valid range obtained from academic periods table.
--
-- Algorithm Description:
-- Retrieving the lower boundary from the valid range, the system will iterate on session_date according to frequency
-- until it reaches the upper boundary. Inside the while loop the current_day is assigned,
-- keeping the day of week parsed to integer using ISO standard conversion. On the other hand,
-- the variable v_days_of_week holds a set of integers that is intended to schedule.
-- In order, for each day number from v_days_of_week an offset is computed considering
-- the difference between v_day_number and current_day:
--
-- Offset equation: (([final] - [initial]) + 7) % 7
--
-- [initial]/v_current_day:
--      Initially it represents the day of the week number from lower boundary of valid range.
--      As the schedule_date is incremented, the v_current_day changes appropriately extracting its day of week number
--
-- [final]/v_day_number:
--      The v_day_number represents, in sequence, one of each v_days_of_week desire to be schedule (e.g, 'Mon', 'Tue') -> (2, 3).
--
-- In cases when the final is lower than initial, it means that the session_date offset lies on the next week,
-- so the difference it's outside the interval instead to be included. Thereby the result is added to a fixed value 7 (number of days in a week).
-- Therefor, the module operation filter either values outside the week as inside the week, such they have fit into seven days cycle.
--
-- At last, to synchronize the session_date following the day of week scheduled the offset is added to it

-- Future Implementations: Holiday validation
CREATE OR REPLACE FUNCTION ACADEMIC.fn_trg_aft_generate_sessions()
RETURNS TRIGGER
AS $$
    DECLARE
        v_valid_range DATERANGE := NEW.valid_range;
        --v_days_of_week SMALLINT[];
        v_current_day SMALLINT := 0;
        v_session_date DATE;
        v_offset_days SMALLINT := 0;
        v_total_rows SMALLINT := 0;
        v_day_number SMALLINT := 0;
    BEGIN
        RAISE NOTICE 'Generate sessions processes has triggered';

        IF (NEW.status NOT IN ('Draft', 'Under Review', 'Suspended', 'Discontinued')) THEN
            FOR v_valid_range IN (
                SELECT NEW.valid_range AS period_range, 1 AS sequential_order
                WHERE NEW.valid_range IS NOT NULL

                UNION ALL

                SELECT pw.period_range, pw.sequential_order
                    FROM CLASS_OFFERINGS co
                    CROSS JOIN LATERAL ACADEMIC.fn_get_period_window(co.academic_period_id) pw
                    WHERE co.id = NEW.class_offering_id
                      AND NEW.valid_range IS NULL
            ) LOOP
                -- Sets the session date based on beginning valid range
                v_session_date := LOWER(v_valid_range);
                -- Now, days of the week entry is an integer array and no longer needs to be parsed
                --v_days_of_week := ACADEMIC.days_to_intarray(NEW.days_of_week);

                WHILE v_session_date < UPPER(v_valid_range) LOOP
                    -- Extracts the day of week number from the last calculated session
                    v_current_day := EXTRACT(ISODOW FROM v_session_date);

                    IF (NOT NEW.frequency = 'Daily') THEN
                        FOREACH v_day_number IN ARRAY NEW.days_of_week LOOP
                            v_offset_days := ((v_day_number - v_current_day) + 7) % 7;
                            IF (v_session_date + v_offset_days) < UPPER(v_valid_range) THEN
                                CALL sp_record_session(NEW.id, (v_session_date + v_offset_days));
                                v_total_rows := v_total_rows + 1;
                            END IF;
                        END LOOP;
                    ELSE
                        CALL sp_record_session(NEW.id, v_session_date);
                        v_total_rows := v_total_rows + 1;
                    END IF;

                    v_session_date := v_session_date +
                        fn_get_frequency_interval(
                                NEW.frequency,
                                NEW.repeat_every
                        );
                END LOOP;
            END LOOP;
            RAISE NOTICE 'The operation completed successfully; % sessions inserted at table ACADEMIC.SESSIONS', v_total_rows;
        ELSEIF (tg_op = 'UPDATE' AND NEW.status = 'Discontinued' AND OLD.status IS DISTINCT FROM NEW.status) THEN
            DELETE FROM ACADEMIC.SESSIONS s
                WHERE schedule_id = NEW.id
                  AND s.session_date > CURRENT_DATE;

            RAISE NOTICE 'Future sessions for schedule % have been purged due to status change to %.', NEW.id, NEW.status;
        ELSE
            RAISE NOTICE 'The schedule was added or updated, but sessions were not generated due to status restriction (Current Status: %).', NEW.status;
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_automated_sessions_generator
    AFTER INSERT OR UPDATE OF status ON ACADEMIC.SCHEDULES
        FOR EACH ROW EXECUTE FUNCTION
            ACADEMIC.fn_trg_aft_generate_sessions();
