--alexander_alcantara-exercicio_16-universidade_logico:


CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS intarray;

CREATE TABLE TEMPLATES.PLAIN_AUDIT (
    created_at      d_insertion_audit NOT NULL,
    last_update_at  d_insertion_audit NOT NULL
);

CREATE TABLE TEMPLATES.PUBLIC_TABLE (
    public_id UUID NOT NULL
        DEFAULT gen_random_uuid(),

    CONSTRAINT uq_public_table_public_id
        UNIQUE (public_id)
);

CREATE TABLE IF NOT EXISTS CORE.STATES (
    code        SMALLINT    NOT NULL,
    name        d_str100    NOT NULL,
    acronym     CHAR(2)     NOT NULL,

    CONSTRAINT pk_states_code PRIMARY KEY (code)
);

CREATE TABLE IF NOT EXISTS CORE.MUNICIPALITIES (
    code            INTEGER     NOT NULL,
    state_code      SMALLINT,
    name            d_str100    NOT NULL,

    CONSTRAINT pk_municipalities_id PRIMARY KEY (code),

    CONSTRAINT fk_states_code
        FOREIGN KEY (state_code) REFERENCES CORE.STATES (code)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CORE.ADDRESSES (
    id                  INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    street              d_str150            NOT NULL,
    neighborhood        d_str200            NOT NULL,
    residence_number    SMALLINT            NOT NULL,
    postal_code         d_str_digits_only   NOT NULL,
    complement          d_str50             NOT NULL
        DEFAULT 'Not Informed',
    city_code           INTEGER             NOT NULL,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_address_id PRIMARY KEY (id),

    CONSTRAINT uq_address_postal_code UNIQUE (postal_code),

    CONSTRAINT chk_address_postal_code_len
        CHECK (LENGTH(postal_code) = 8),

    CONSTRAINT fk_address_municipality_code FOREIGN KEY
        (city_code) REFERENCES CORE.MUNICIPALITIES (code)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CORE.PERSONS (
    id              INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    public_id       UUID                NOT NULL
        DEFAULT gen_random_uuid(),
    first_name      d_str100            NOT NULL,
    last_name       d_str200            NOT NULL,
    preferred_name  d_str50             NULL,
    national_id     d_str_digits_only   NOT NULL,
    tax_id          d_str_digits_only   NOT NULL,
    date_of_birth   DATE                NOT NULL,
    nationality     d_str150            NOT NULL,
    gender          CORE.e_gender       NOT NULL,
    legal_sex       CORE.e_legal_sex    NOT NULL,
    address_id      INTEGER             NOT NULL,
    profession      d_str100            NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_persons_id PRIMARY KEY (id),

    CONSTRAINT uq_persons_public_id UNIQUE (public_id),

    CONSTRAINT fk_persons_address_id
        FOREIGN KEY (address_id) REFERENCES CORE.ADDRESSES
        ON DELETE RESTRICT,

    CONSTRAINT uq_persons_tax_id
        UNIQUE (tax_id),

    CONSTRAINT uq_persons_national_id
        UNIQUE (national_id),

    CONSTRAINT chk_persons_national_id_len
        CHECK(LENGTH(national_id) = 7),

    CONSTRAINT chk_persons_tax_id_len
        CHECK(LENGTH(tax_id) = 11)
);

CREATE TABLE IF NOT EXISTS CORE.EMAILS (
    id              INTEGER                 GENERATED
        ALWAYS AS IDENTITY,
    person_id       INTEGER                 NOT NULL,
    email           TEXT                    NOT NULL,
    email_type      CORE.e_contact_type     NOT NULL,

    CONSTRAINT pk_emails_id PRIMARY KEY (id),

    CONSTRAINT uq_emails_email UNIQUE (email),

    CONSTRAINT fk_emails_id FOREIGN KEY (person_id)
        REFERENCES CORE.PERSONS (id)
);

CREATE TABLE IF NOT EXISTS CORE.PHONES (
    id          INTEGER                  GENERATED
        ALWAYS AS IDENTITY,
    number      d_phone_number           NOT NULL,
    contact_type  CORE.e_contact_type    NOT NULL,
    person_id   INTEGER                  NOT NULL,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_phone PRIMARY KEY (id),

    CONSTRAINT fk_persons_person_id
        FOREIGN KEY (person_id) REFERENCES CORE.PERSONS
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CORE.CERTIFICATIONS (
    id                          INTEGER     GENERATED
        ALWAYS AS IDENTITY,
    person_id                   INTEGER     NOT NULL,
    name                        d_str150    NOT NULL,
    start_date                  DATE        NOT NULL,
    end_date                    DATE        NOT NULL,
    total_workload              SMALLINT    NOT NULL,
    institution_name            d_str150    NOT NULL,
    experience_description      TEXT        NULL,

    delivery_mode       ACADEMIC.e_delivery_mode         NOT NULL,
    educational_level   ACADEMIC.e_educational_level     NOT NULL,
    qualification_tier  ACADEMIC.e_qualification_tier    NOT NULL,
    institution_type    CORE.e_institution_type          NOT NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_certifications_id PRIMARY KEY (id),

    CONSTRAINT fk_qualifications_person_id
        FOREIGN KEY (person_id) REFERENCES CORE.PERSONS (id)
        ON DELETE CASCADE,

    CONSTRAINT chk_certifications_dates
        CHECK (end_date >= start_date),

    CONSTRAINT chk_certifications_workload
        CHECK (total_workload >= 30)
);

CREATE TABLE IF NOT EXISTS CORE.DISABILITIES (
    id          INTEGER                 GENERATED
        ALWAYS AS IDENTITY,
    -- (The CID) e.g., "F84.0" (Childhood Autism), "H54.0" (Blindness).
    icd_code    CHAR(5)                 NOT NULL,
    name        d_str200                NOT NULL,
    category    CORE.e_disability_category   NOT NULL,
    is_active   BOOLEAN                 NOT NULL
        DEFAULT TRUE,

    CONSTRAINT pk_disabilities PRIMARY KEY (id),
    CONSTRAINT uq_disabilities_icd_code UNIQUE (icd_code)
);

CREATE TABLE IF NOT EXISTS CORE.PERSON_DISABILITIES (
    person_id               INTEGER     NOT NULL,
    disability_id           INTEGER     NOT NULL,
    document_ref            d_str50     NULL,
    notes                   d_str400    NULL,
    is_permanent            BOOLEAN     NOT NULL
        DEFAULT TRUE,

    CONSTRAINT pk_person_disabilities_composed
        PRIMARY KEY (person_id, disability_id),

    CONSTRAINT fk_person_disabilities_person_id
        FOREIGN KEY (person_id) REFERENCES CORE.PERSONS (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_person_disabilities_disability_id
        FOREIGN KEY (disability_id) REFERENCES CORE.DISABILITIES (id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CORE.DEPENDENT_GUARDIANS (
    guardian_id     INTEGER             NOT NULL,
    dependent_id    INTEGER             NOT NULL,
    familiar_bond   CORE.e_familiar_bond     NOT NULL,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_dependent_guardians_id
        PRIMARY KEY (dependent_id, guardian_id),

    CONSTRAINT fk_persons_guardian_id
        FOREIGN KEY (guardian_id) REFERENCES CORE.PERSONS
        ON DELETE RESTRICT,

    CONSTRAINT fk_persons_dependent_id
        FOREIGN KEY (dependent_id) REFERENCES CORE.PERSONS
        ON DELETE RESTRICT,

    CONSTRAINT chk_dependent_guardians_auto_ref_not_allowed
        CHECK (dependent_id <> guardian_id)
);

CREATE TABLE IF NOT EXISTS CORE.EMPLOYEES (
    id                      INTEGER                     NOT NULL,
    admission_on            DATE                        NOT NULL,
    registration_number     BIGINT UNIQUE               NOT NULL,
    status                  CORE.e_employee_status      NOT NULL,
    job_title               CORE.e_job_title            NOT NULL,
    weekly_hours            SMALLINT                    NOT NULL,
    salary                  DECIMAL(10,2)               NOT NULL,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_employee PRIMARY KEY (id),

    CONSTRAINT fk_persons_employee_id
        FOREIGN KEY (id) REFERENCES CORE.PERSONS
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CORE.STAFFS (
    id                  INTEGER                      NOT NULL,
    qualification_level CORE.e_staff_qualification_level   NOT NULL,

    CONSTRAINT pk_staff_id PRIMARY KEY (id),

    CONSTRAINT fk_employees_staff_id
        FOREIGN KEY (id) REFERENCES CORE.EMPLOYEES
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CORE.DEPARTMENTS (
    id          INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    name        d_str100            NOT NULL,
    ramal       d_str_digits_only   NULL,
    staff_id    INTEGER             NOT NULL,

    CONSTRAINT pk_departments_id PRIMARY KEY (id),

    CONSTRAINT fk_staffs_staff_id
        FOREIGN KEY (staff_id) REFERENCES CORE.STAFFS (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_departments_ramal_len
        CHECK (LENGTH(ramal) = 4)
);


--==============================================================================================================
-- ACADEMIC_PERIODS
-- Academic Periods are designed to establish a period lifecycle reference
-- allowing it to synchronize table records that may require a time existence validation.
-- The academic_year is a derived from lower bound of period_range working as a straightforward way to retrieve
-- the year without dealing with complex datarage manipulation.
--
-- The primary key comprises:
-- - term_type - The period division like semester, trimester or quarter
-- - sequential_number - The number of period sequence
-- - period_range - The duration range embraces the total time a period lasts for
--
-- Additional columns:
-- - total_week - This is an automatic generated column that specifies the total week amount calculated from
-- period range, and it is stored at the moment when it is inserted, so it can be retrieved without recalculation.
-- this field is very important to credit hours conversion that depends on academic period term type
--
-- Business Rules:
-- 1. A new insertion can not be overlapping another existent period range, unless it is from different term_types
-- 2. By default, the system assumes that if the insertion is the continuity of another academic period, the
-- lower bound must be greater than or equal to the previous one.
-- 3. The earliest date that the lower bound of the period range can take is after 2000-01-15, allowing
-- the administrative team to migrate old data.
-- 4. Academic Periods must be related with its subsequence part, but they do not refer itself
-- ================================================================================================================
CREATE TABLE IF NOT EXISTS ACADEMIC.PERIODS (
    id                      INTEGER         GENERATED
        ALWAYS AS IDENTITY,
    public_id               UUID            NOT NULL
        DEFAULT gen_random_uuid(),
    term_type               ACADEMIC.e_term_type     NOT NULL,
    sequence_order          INTEGER         NOT NULL,
    period_range            DATERANGE       NOT NULL,
    predecessor_period_id   INTEGER         NULL,
    -- the default is virtual, that is, the value is recalculated always the data is obtained
    academic_year           SMALLINT        GENERATED
        ALWAYS AS (
            EXTRACT(YEAR FROM lower(period_range))::SMALLINT
        )                                   STORED,
    total_week              SMALLINT        GENERATED
        ALWAYS AS (
            (upper(period_range) - lower(period_range))::SMALLINT / 7
        )                                   STORED,

    LIKE TEMPLATES.PLAIN_AUDIT,

    -- Surrogate key
    CONSTRAINT pk_periods_id PRIMARY KEY (id),

    -- Natural key. Ex: Semester, 2025.1
    CONSTRAINT uq_periods_natural_key UNIQUE
        (term_type, academic_year, sequence_order),

    -- Corresponde ao par para auto-relacionamento da tabela academic periods. Garante com que o term_type
    -- referenciado seja igual ao o da coluna de referência. Ou seja, uma linha do tipo
    -- trimestre não pode referenciar outra linha do tipo semestre.
    CONSTRAINT uq_periods_term_type_id
        UNIQUE (id, term_type),

    CONSTRAINT uq_periods_public_id
        UNIQUE (public_id),

    -- Na documentação do postgres - DDL/Constraints/foreign keys - diz que uma foreign key é uma coluna
    -- especificada, ou um grupo de colunas que necessitam corresponder com algum valor existente na tabela
    -- de referência. Para que a foreign key seja validada a tabela referenciada deve possuir o conjunto
    -- de valores que se pretende corresponder. O tipo match simple de ligação permite com que qualquer
    -- coluna de foreign key seja nula, de modo que, se a coluna for nula, o match não é executado.
    CONSTRAINT fk_periods_predecessor
        FOREIGN KEY (predecessor_period_id, term_type)
        REFERENCES ACADEMIC.PERIODS (id, term_type)
        -- MATCH FULL bloqueia a operação caso apenas uma coluna referenciada seja nula.
        -- Apenas permite referencias nulas se todas as colunas referenciadas forem nulas.
        MATCH SIMPLE
        -- A exclusão de um registro pai é evitada tanto em cascata quanto por meio de uma transação (no action)
        ON DELETE RESTRICT,

    -- This check constraint prevents self-referencing
    CONSTRAINT chk_periods_no_self_reference
        CHECK (id <> predecessor_period_id),

    CONSTRAINT chk_academic_periods_sequence_order CHECK (
        (term_type = 'Semester'     AND sequence_order BETWEEN 1 AND 2) OR
        (term_type = 'Trimester'    AND sequence_order BETWEEN 1 AND 3) OR
        (term_type = 'Quarter'      AND sequence_order BETWEEN 1 AND 4) OR
        (term_type = 'Annual'       AND sequence_order = 1)
    ),

    CONSTRAINT chk_term_type_week CHECK (
        CASE
            WHEN term_type = 'Quarter' THEN
                total_week BETWEEN 8 AND 12
            WHEN term_type = 'Trimester' THEN
                total_week BETWEEN 10 AND 14
            WHEN term_type = 'Semester' THEN
                total_week BETWEEN 14 AND 26
            WHEN term_type = 'Annual' THEN
                total_week BETWEEN 40 AND 52
        END
    ),

    -- Ao inserir um novo registro, essa constraint comparará se para o conjunto das colunas especificadas
    -- existe alguma outra linha com os mesmos valores, e então impedirá a operação se o retorno da comparação
    -- for TRUE. É similar ao um Unique constraint, porém permite adicionar operadores de sobreposição (e
    -- o operador deve garantir que é comutativo: A = B <=> B = A), necessitando também adicionar a extensão
    -- do Btree-gist. Ou seja, se houver um term_type igual ao que se tenta inserir enquanto o period_range
    -- é sobreposto a operação falha. A cláusula Where também pode ser especificada ao final da constraint
    -- para delimitar um subconjunto onde essa regra valerá.
    CONSTRAINT excl_periods_no_overlap
        EXCLUDE USING gist (
            term_type    WITH =,
            period_range WITH &&
        ),

    CONSTRAINT chk_periods_earliest_date
        CHECK (lower(period_range) >= '2000-01-15'::DATE)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.STUDENTS (
    id                  INTEGER                         NOT NULL,
    admission_method    ACADEMIC.e_admission_method     NOT NULL,
    quota_category      ACADEMIC.e_quota_category       NOT NULL,

    CONSTRAINT c_pk_students_id PRIMARY KEY (id),

    CONSTRAINT c_fk_persons_student_id
        FOREIGN KEY (id) REFERENCES CORE.PERSONS
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ACADEMIC.TEACHERS (
    id                  INTEGER                         NOT NULL,
    faculty_category    ACADEMIC.e_faculty_category     NOT NULL,
    expertise_area      d_str200                        NOT NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_teachers_id PRIMARY KEY (id),

    CONSTRAINT fk_teachers_id
        FOREIGN KEY (id) REFERENCES CORE.EMPLOYEES
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ACADEMIC.PROGRAMS (
    id                      INTEGER                          GENERATED
        ALWAYS AS IDENTITY,
    public_id               UUID                             NOT NULL
        DEFAULT gen_random_uuid(),
    code                    VARCHAR(15)                      NOT NULL,
    description             d_str400                         NOT NULL,
    name                    d_str150                         NOT NULL,
    total_workload          SMALLINT                         NOT NULL,
    complementary_hours     SMALLINT                         NOT NULL,
    default_shift           d_shifts                         NOT NULL,
    pedagogical_project     TEXT                             NOT NULL,
    accreditation_score     DECIMAL(3,2)                     NULL,
    department_id           INTEGER                          NOT NULL,
    coordinator_id          INTEGER                          NULL,
    status                  ACADEMIC.e_program_status        NOT NULL,

    delivery_mode           ACADEMIC.e_delivery_mode         NOT NULL,
    educational_level       ACADEMIC.e_educational_level     NOT NULL,
    qualification_tier      ACADEMIC.e_qualification_tier    NOT NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,

	CONSTRAINT pk_programs_id PRIMARY KEY (id),

    CONSTRAINT uq_programs_public_id UNIQUE (public_id),

    CONSTRAINT uq_programs_code UNIQUE (code),

    CONSTRAINT fk_programs_department_id
        FOREIGN KEY (department_id) REFERENCES CORE.DEPARTMENTS
        ON DELETE RESTRICT,

    CONSTRAINT fk_programs_coordinator_id
        FOREIGN KEY (coordinator_id) REFERENCES ACADEMIC.TEACHERS
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ACADEMIC.COURSES (
    id                      INTEGER                 GENERATED
        ALWAYS AS IDENTITY,
    public_id               UUID                    NOT NULL
        DEFAULT gen_random_uuid(),
    code                    TEXT                    NOT NULL,
    name                    d_str150                NOT NULL,
    syllabus                JSONB                   NOT NULL
        DEFAULT '{
          "course_objectives": {
            "general_objective": "",
            "specific_objectives": []
          },
          "content_modules": [],
          "grading_system": {
            "evaluation_methods": [],
            "passing_criteria": ""
          },
          "bibliography": {
            "basic_references": [],
            "complementary_references": []
          }
    }'::jsonb,
    total_credit_hours      SMALLINT                NOT NULL,
    expected_sessions       SMALLINT                NOT NULL,
    delivery_mode           ACADEMIC.e_delivery_mode         NOT NULL,
    subscription_fee        DECIMAL(5,2)            NOT NULL,
    status                  ACADEMIC
        .e_lifecycle_status                         NOT NULL
        DEFAULT 'Draft',

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_courses_id PRIMARY KEY (id),

    CONSTRAINT uq_courses_public_id UNIQUE (public_id),

    CONSTRAINT uq_courses_code UNIQUE (code),

    CONSTRAINT c_chk_credit_hours
        CHECK (total_credit_hours > 0)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.PRE_REQUISITES (
    course_id INTEGER NOT NULL,
    requisite_id INTEGER NOT NULL,
    effective_period DATERANGE NOT NULL,
    priority_order SMALLINT NOT NULL DEFAULT 0,
    CONSTRAINT pk_pre_requisites_id PRIMARY KEY (course_id, requisite_id),

    -- On Insert Warning: This table requires a function trigger to prevent transitive insertions
    -- Request Description:
    -- On Delete Warning: Although when referenced data are deleted from courses it only delete the first reference, but sub-references remains existing
    -- Request Description:

    CONSTRAINT fk_pre_requisites_course_id
        FOREIGN KEY (course_id) REFERENCES ACADEMIC.COURSES (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pre_requisites_requisite_id
        FOREIGN KEY (requisite_id) REFERENCES ACADEMIC.COURSES (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_pre_requisites_auto_ref_unabled
        CHECK (requisite_id <> course_id)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.CURRICULUM_OFFERINGS (
    id                  BIGINT      GENERATED
        ALWAYS AS IDENTITY,
    public_id           UUID        NOT NULL
        DEFAULT gen_random_uuid(),
    program_id          INTEGER     NOT NULL,
    version_code        CHAR(3)     NOT NULL,

    start_period_id     INTEGER     NOT NULL,
    end_period_id       INTEGER     NULL,
    status              ACADEMIC
        .e_lifecycle_status         NOT NULL
        DEFAULT 'Draft',

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_curriculum_offerings_id PRIMARY KEY (id),

    CONSTRAINT uq_curriculum_offerings_public_id UNIQUE (public_id),

    CONSTRAINT uq_curriculum_offerings_code
        UNIQUE (program_id, version_code),

    CONSTRAINT fk_curriculum_offerings_program_id
        FOREIGN KEY (program_id) REFERENCES ACADEMIC.PROGRAMS
        ON DELETE RESTRICT,

    CONSTRAINT fk_curriculum_offerings_start_period_id
        FOREIGN KEY (start_period_id) REFERENCES ACADEMIC.PERIODS
        ON DELETE RESTRICT,

    CONSTRAINT fk_curriculum_offerings_end_period_id
        FOREIGN KEY (start_period_id) REFERENCES ACADEMIC.PERIODS
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ACADEMIC.CURRICULUM_COURSES (

    curriculum_offering_id  INTEGER     NOT NULL,
    course_id               INTEGER     NOT NULL,
    academic_term_number    SMALLINT    NOT NULL,
    is_mandatory            BOOLEAN     NOT NULL
        DEFAULT TRUE,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_curriculum_courses
        PRIMARY KEY (course_id, curriculum_offering_id),

    CONSTRAINT fk_curriculum_courses_offering
        FOREIGN KEY (curriculum_offering_id)
        REFERENCES ACADEMIC.CURRICULUM_OFFERINGS (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_curriculum_courses_course
        FOREIGN KEY (course_id) REFERENCES ACADEMIC.COURSES (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_curriculum_courses_term_num
        CHECK (academic_term_number > 0)
);

-- =============================================================================
-- Table: COURSE_ASSIGNMENTS
-- Business Rule:
-- Prevents active or inactive teacher assignment schedule overlaps.
-- - 'ACTIVE': Teacher is assigned and currently teaching the course.
-- - 'INACTIVE': Assignment ended naturally (COMPLETED) or was inactivated by administrative/schedule reasons.
-- - 'CANCELLED': Record created by mistake (e.g., incorrect dates). Canceling a record frees the validity period for re-assignment.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ACADEMIC.COURSES_ASSIGNMENTS (
    id                  INTEGER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id           INTEGER          NOT NULL,
    teacher_id          INTEGER          NOT NULL,
    validity_period     DATERANGE        NOT NULL,
    status              ACADEMIC
        .e_course_assignment_status      NOT NULL
        DEFAULT 'Active',
    inactive_reason     ACADEMIC
        .e_inactive_reason               NULL,

    CONSTRAINT fk_course_assignments_course_id
        FOREIGN KEY (course_id) REFERENCES ACADEMIC.COURSES (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_course_assignments_teacher_id
        FOREIGN KEY (teacher_id) REFERENCES ACADEMIC.TEACHERS (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_course_assignments_inactive_reason_consistency CHECK (
        (status = 'Inactive' AND inactive_reason IS NOT NULL) OR
        (status != 'Inactive' AND inactive_reason IS NULL)
    ),

    CONSTRAINT ex_avoid_overlaps_active_schedule_assignments
        EXCLUDE USING gist (
            teacher_id WITH =,
            course_id WITH =,
            validity_period WITH &&
        ) WHERE (status = 'Canceled')
);

CREATE INDEX idx_course_assignment_course_id    ON ACADEMIC.COURSES_ASSIGNMENTS (course_id);
CREATE INDEX idx_course_assignment_teacher_id   ON ACADEMIC.COURSES_ASSIGNMENTS (teacher_id);

CREATE TABLE IF NOT EXISTS ACADEMIC.CLASS_SECTIONS (
    id                  INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    code                VARCHAR(5)          NOT NULL,
    academic_period_id  INTEGER             NOT NULL,

    LIKE TEMPLATE_PLAIN_AUDIT,

    CONSTRAINT pk_class_sections_id PRIMARY KEY (id),

    CONSTRAINT uq_class_section_period_code UNIQUE
        (academic_period_id, code),

    CONSTRAINT fk_course_enrollments_period_range
        FOREIGN KEY (academic_period_id)
        REFERENCES ACADEMIC.PERIODS (id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ACADEMIC.SECTION_ASSIGNMENTS(
    section_id INTEGER NOT NULL,
    assignment_id INTEGER NOT NULL,

    CONSTRAINT fk_section_assignments_section_id
        FOREIGN KEY (section_id)
        REFERENCES ACADEMIC.CLASS_SECTIONS (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_section_assignments_assignment_id
        FOREIGN KEY (assignment_id)
        REFERENCES ACADEMIC.COURSES_ASSIGNMENTS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ACADEMIC.CLASSROOMS (
    id                  INTEGER                     GENERATED
        ALWAYS AS IDENTITY,
    block               CHAR(1)                     NOT NULL,
    code                VARCHAR(6)                  NOT NULL,
    amenity_tags        d_classroom_amenities       DEFAULT '{}',
    capacity_override   SMALLINT                    NOT NULL,

    CONSTRAINT pk_classroom_id PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.CURRICULUM_ENROLLMENTS (
    code_number                 BIGINT          GENERATED
        ALWAYS AS IDENTITY,
    subscription_timestamp      TIMESTAMPTZ     NOT NULL,
    status                      ACADEMIC
        .e_curriculum_enrollment_status
        DEFAULT 'Active'                        NOT NULL,
    curriculum_offering_id      INTEGER         NOT NULL,
    student_id                  INTEGER         NOT NULL,
    term_type                   ACADEMIC.e_term_type     NOT NULL,
    sequence_order              INTEGER         NOT NULL,
    academic_year               SMALLINT        NOT NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,
    LIKE TEMPLATES.PUBLIC_TABLE INCLUDING ALL,

    CONSTRAINT pk_course_enrollments_number PRIMARY KEY(code_number),

    CONSTRAINT uq_course_enrollments_unique
     UNIQUE (student_id, curriculum_offering_id, term_type,
        sequence_order, academic_year, code_number),

    CONSTRAINT fk_course_enrollments_curriculum_offering
        FOREIGN KEY (curriculum_offering_id) REFERENCES ACADEMIC.CURRICULUM_OFFERINGS
        ON DELETE RESTRICT,

    CONSTRAINT fk_course_enrollments_student_id
        FOREIGN KEY (student_id) REFERENCES ACADEMIC.STUDENTS (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_course_enrollments_academic_period
        FOREIGN KEY (term_type, sequence_order, academic_year)
        REFERENCES ACADEMIC.PERIODS (term_type, sequence_order, academic_year)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =============================================================================
-- Table: COURSE_ENROLLMENTS
-- Students can re-enroll in cases when they have been reproved,
-- or perhaps they'd like to remake it again or even if any troubles occurred with it.
-- Otherwise, it is disallowed for the same class_section.
-- This happens because class sections which has a yearly period as high school programs does,
-- are always renewed based on academic period changes.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ACADEMIC.COURSE_ENROLLMENTS (
    course_id           INTEGER             NOT NULL,
    student_id          INTEGER             NOT NULL,
    class_section_id    INTEGER             NOT NULL,
    status              ACADEMIC
        .e_course_enrollment_status             NOT NULL
        DEFAULT 'Enrolled',
    signature_date      d_insertion_audit   NULL,

    CONSTRAINT pk_matricula_curso PRIMARY KEY
        (student_id, course_id, class_section_id),

    CONSTRAINT fk_course_enrollments_course_id
        FOREIGN KEY (course_id) REFERENCES ACADEMIC.COURSES
        ON DELETE RESTRICT,

    CONSTRAINT fk_course_enrollments_student_id
        FOREIGN KEY (student_id) REFERENCES ACADEMIC.STUDENTS
        ON DELETE RESTRICT,

    CONSTRAINT fk_course_enrollments_class_section_id
        FOREIGN KEY (class_section_id) REFERENCES ACADEMIC.CLASS_SECTIONS
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ACADEMIC.ACTIVITY_TYPES (
    id              INTEGER     GENERATED
        ALWAYS AS IDENTITY,
    name            d_str200    NOT NULL,
    description     d_str400    NOT NULL,
    min_grade       SMALLINT    NOT NULL,
    max_grade       SMALLINT    NOT NULL,

    LIKE TEMPLATES.PLAIN_AUDIT,

    CONSTRAINT pk_activity_type PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.ACTIVITIES (
    id                  INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    is_graded           BOOLEAN             NOT NULL
        DEFAULT FALSE,
    attachment_urls     d_document          NOT NULL,
    activity_type_id    INTEGER             NOT NULL,

    CONSTRAINT pk_activities_id PRIMARY KEY (id),

    CONSTRAINT fk_activities_activity_type_id
        FOREIGN KEY (activity_type_id) REFERENCES ACADEMIC.ACTIVITY_TYPES (id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ACADEMIC.APPLICATIONS (
    activity_id         INTEGER             NOT NULL,
    class_section_id    INTEGER             NOT NULL,
    status              ACADEMIC.e_application_status   NOT NULL,
    expiration_range    TSTZRANGE           NOT NULL,

    CONSTRAINT pk_applications_id
        PRIMARY KEY (activity_id, class_section_id),

    CONSTRAINT fk_applications_activity_id
        FOREIGN KEY (activity_id) REFERENCES ACADEMIC.ACTIVITIES (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_applications_class_section_id
        FOREIGN KEY (class_section_id) REFERENCES ACADEMIC.CLASS_SECTIONS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ACADEMIC.UPLOADS (
    id                      INTEGER             GENERATED
        ALWAYS AS IDENTITY,
    activity_id             INTEGER             NOT NULL,
    class_section_id        INTEGER             NOT NULL,
    submitted_documents     d_document          NOT NULL,
    uploaded_at             TIMESTAMPTZ         NOT NULL
        DEFAULT CURRENT_TIMESTAMP,
    received_grade          DECIMAL(4,2)        NULL,
    general_remark          d_str400            NULL,
    owner_id                INTEGER             NOT NULL,
    status                  ACADEMIC.e_upload_status     NOT NULL,

    CONSTRAINT pk_uploads_id       PRIMARY KEY (id),

    CONSTRAINT fk_uploads_application_id
        FOREIGN KEY                      (activity_id, class_section_id)
        REFERENCES ACADEMIC.APPLICATIONS (activity_id, class_section_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_uploads_owner_id
        FOREIGN KEY (owner_id) REFERENCES ACADEMIC.STUDENTS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ACADEMIC.UPLOAD_PARTICIPANTS (
    student_id      INTEGER     NOT NULL,
    upload_id       INTEGER     NOT NULL,

    CONSTRAINT pk_submissions_id PRIMARY KEY
        (student_id, upload_id),

    CONSTRAINT fk_submissions_student_id
        FOREIGN KEY (student_id) REFERENCES ACADEMIC.STUDENTS (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_submissions_upload_id
        FOREIGN KEY (upload_id) REFERENCES ACADEMIC.UPLOADS (id)
        ON DELETE CASCADE
);

--===============================================================================
-- SCHEDULES
--
-- Business Rules:
-- 1. A classroom may only be booked if the days of the week, the shifts and the valid range
-- do not overlap an existent schedule regardless of the class section. Although the class section is not
-- considered in this clause, it's important to specify which schedule arrangements are related to it.
-- 2. The system assumes the valid range based on class section's academic period valid date by default,
-- So it also must be responsible for importing the valid range automatically before the schedule insertion.
-- Assim que uma agenda for definida o sistema deve criar automaticamente todas as datas dentro do periodo valid_range.
--
CREATE TABLE IF NOT EXISTS ACADEMIC.SCHEDULES (
    id                  INTEGER          GENERATED
        ALWAYS AS IDENTITY,
    class_section_id    INTEGER          NOT NULL,
    classroom_id        INTEGER          NULL,
    shifts              d_shifts         NOT NULL,
    days_of_week        d_days_of_week   NULL,
    frequency           e_frequency      NOT NULL
        DEFAULT 'Daily',
    repeat_every        SMALLINT         NOT NULL
        DEFAULT 1,
    valid_range         DATERANGE        NULL,
    time_slot_limit     SMALLINT         NOT NULL,
    status              ACADEMIC
        .e_lifecycle_status              NOT NULL
        DEFAULT 'Draft',

    CONSTRAINT pk_schedules_id PRIMARY KEY (id),

    CONSTRAINT fk_schedules_classroom_id
        FOREIGN KEY (classroom_id)
        REFERENCES ACADEMIC.CLASSROOMS (id)
        ON DELETE SET NULL,

    CONSTRAINT fk_schedules_class_section_id
        FOREIGN KEY (class_section_id)
        REFERENCES ACADEMIC.CLASS_SECTIONS (id)
        ON DELETE RESTRICT,

    CONSTRAINT excl_schedules_without_overlaps
        EXCLUDE USING gist (
            classroom_id                                        WITH =,
            ACADEMIC.days_to_intarray(days_of_week)     WITH &&,
            ACADEMIC.shifts_to_intarray(shifts)        WITH &&,
            valid_range                                        WITH &&
        )
);

CREATE TABLE IF NOT EXISTS ACADEMIC.LESSONS (
    id              INTEGER                      GENERATED
        ALWAYS AS IDENTITY,
    title           d_str100                     NOT NULL,
    description     d_str400                     NOT NULL,
    delivery_mode   ACADEMIC.e_delivery_mode     NOT NULL,
    lesson_type     ACADEMIC.e_lesson_type       NOT NULL,

    LIKE TEMPLATES.PUBLIC_TABLE INCLUDING ALL,

    CONSTRAINT pk_lessons_id PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS ACADEMIC.SESSIONS (
    id                      BIGINT                      GENERATED
        ALWAYS AS IDENTITY,
    schedule_id             INTEGER                      NOT NULL,
    session_date            DATE                         NOT NULL,
    status                  ACADEMIC.e_session_status    NOT NULL
        DEFAULT 'Scheduled',

    CONSTRAINT pk_sessions_id PRIMARY KEY (id),

    CONSTRAINT uq_sessions_natural_key UNIQUE
        (schedule_id, session_date),

    CONSTRAINT fk_sessions_schedule_id
        FOREIGN KEY (schedule_id) REFERENCES ACADEMIC.SCHEDULES (id)
        ON DELETE CASCADE
);

CREATE INDEX idx_sessions_schedule_id ON ACADEMIC.SESSIONS (schedule_id);

CREATE TABLE IF NOT EXISTS ACADEMIC.ATTENDANCE_RECORDS (
    student_id          INTEGER     NOT NULL,
    booking_id          INTEGER     NOT NULL,
    is_present          BOOLEAN     NOT NULL
        DEFAULT FALSE,
    check_in_time       TIME        NULL,
    check_out_time      TIME        NULL,

    CONSTRAINT pk_attendance  PRIMARY KEY
        (student_id, booking_id),

    CONSTRAINT fk_attendance_records_student_id
        FOREIGN KEY (student_id) REFERENCES ACADEMIC.STUDENTS (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_attendance_records_booking_id
        FOREIGN KEY (booking_id) REFERENCES ACADEMIC.SESSIONS (id)
        ON DELETE CASCADE,

    CONSTRAINT chk_attendance_check_times
        CHECK (
            check_out_time   IS NULL OR
            check_in_time    IS NULL OR
            check_out_time >= check_in_time
        )
);


-- CREATE TABLE IF NOT EXISTS SALES.BUNDLES (
--     id,
--     title,
--     description,
--     max_discount_applies,
--     available_instalments,
--     valid_range
-- );
--
-- CREATE TABLE IF NOT EXISTS SALES.BUNDLE_ITEMS (
--
-- );
--
-- CREATE TABLE IF NOT EXISTS SALES.CURRICULUM_ITEM (
--
-- );
--
-- CREATE TABLE IF NOT EXISTS SALES.COURSE_ITEM ();
--
-- CREATE TABLE IF NOT EXISTS SALES.PRODUCT_ITEM ();
--
-- CREATE TABLE IF NOT EXISTS ACCOUNTING.INVOICES (
--     public_id,
--     purchase_id,
--     instalment_number,
--     status,
--     due_amount,
--     due_date
-- );
--
-- CREATE TABLE IF NOT EXISTS ACCOUNTING.PURCHASES (
--     id,
--     person_id,
--     program_enrollment,
--     bundle_id,
--     purchased_at,
--     total_amount
-- );
--
-- CREATE TABLE IF NOT EXISTS SECURITY.USERS (
--     person_id,
--     permission_id,
--     hash_password,
--     settings -- jsonb
-- );
--
-- CREATE TABLE IF NOT EXISTS SECURITY.USERS (
--
-- );
--
-- CREATE TABLE IF NOT EXISTS SECURITY.PERMISSIONS (
--     id,
--     type,
--     grant_rules
-- );