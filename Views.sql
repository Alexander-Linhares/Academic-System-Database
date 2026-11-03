CREATE OR REPLACE VIEW ACADEMIC.V_SCHEDULES AS
    SELECT
        id,
        class_section_id,
        classroom_id,
        shifts,
        days_of_week,
        frequency,
        frequency_type,

        valid_range,
        time_slot_limit,
        status
    FROM ACADEMIC.SCHEDULES