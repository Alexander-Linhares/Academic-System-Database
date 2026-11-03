SELECT * FROM ACADEMIC.SCHEDULES;

-- ----------------------------- INSERINDO AS CLASSROOMS -------------------------------

SELECT * FROM ACADEMIC.CLASSROOMS;

INSERT INTO ACADEMIC.CLASSROOMS (block, code, capacity_override) VALUES
    ('F', 'AUD-CENTRAL', 267);

INSERT INTO ACADEMIC.CLASSROOMS (block, code, capacity_override) VALUES
    ('B', 'LABSOFT-01', 45);

INSERT INTO ACADEMIC.CLASSROOMS (block, code, capacity_override, amenity_tags) VALUES
    ('B', 'LABSOFT-02', 45, '{Air Conditioning, Projector}');

SELECT * FROM ACADEMIC.CLASSROOMS;

DELETE FROM ACADEMIC.PERIODS WHERE id = 2;
-- ------------------------------- INSERINDO UM ACADEMIC PERIOD ---------------------------

SELECT * FROM ACADEMIC.PERIODS;

INSERT INTO ACADEMIC.PERIODS (term_type, sequence_order, period_range) VALUES
    ('Semester', 1, '[2025-01-18,2025-06-29)');

INSERT INTO ACADEMIC.PERIODS (term_type, sequence_order, period_range, predecessor_period_id) VALUES
    ('Semester', 2, '[2025-08-03,2025-12-06)', 1);

INSERT INTO ACADEMIC.PERIODS (term_type, sequence_order, period_range) VALUES
    ('Semester', 1, '[2026-01-18,2026-06-29)');

INSERT INTO ACADEMIC.PERIODS (term_type, sequence_order, period_range, predecessor_period_id) VALUES
    ('Semester', 2, '[2026-08-03,2026-12-06)', 7);


UPDATE ACADEMIC.PERIODS SET predecessor_period_id = 1 WHERE id = 4;

-- ------------------------------ INSERINDO UMA TURMA ------------------------------------

SELECT * FROM ACADEMIC.CLASS_SECTIONS;

INSERT INTO ACADEMIC.CLASS_SECTIONS (code, academic_period_id) VALUES
    ('BSI25', 1);

INSERT INTO ACADEMIC.CLASS_SECTIONS (code, academic_period_id) VALUES
    ('TSI25', 1);

-- ----------------------------- INSERINDO OS AGENDAMENTOS DAS TURMAS -----------------------

SELECT * FROM ACADEMIC.SCHEDULES;

INSERT INTO ACADEMIC.SCHEDULES (
    class_section_id,
    classroom_id,
    shifts,
    days_of_week,
    frequency,
    repeat_every,
    time_slot_limit
) VALUES
      (1, 2, '{Morning}', '{Monday}', 'Weekly', 2, 3);

INSERT INTO ACADEMIC.SCHEDULES (
    class_section_id,
    classroom_id,
    shifts,
    days_of_week,
    frequency,
    repeat_every,
    time_slot_limit
) VALUES
      (1, 2, '{Morning, Afternoon}', '{Thursday}', 'Daily', 2, 2);

SELECT
    id,
    schedule_id,
    session_date,
    TO_CHAR(session_date, 'TMDy') AS dia_da_semana, -- Retorna o nome do dia (ex: Tuesday / Terça-feira)
    status
FROM ACADEMIC.SESSIONS
WHERE schedule_id = 5 -- Substitua pelo ID do seu teste
ORDER BY session_date ASC;

SELECT * FROM ACADEMIC.SESSIONS;

INSERT INTO ACADEMIC.SESSIONS (schedule_id, session_date) VALUES (5, '2025-01-21');

SELECT * FROM ACADEMIC.PERIODS;


