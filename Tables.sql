--alexander_alcantara-exercicio_16-universidade_logico:

CREATE TABLE TEMPLATE_AUDIT_TRAIL (
    created_at d_insertion_audit,
    updated_at d_insertion_audit,
    created_by_id INTEGER,
    updated_by_id INTEGER
);

CREATE TABLE IF NOT EXISTS STATES (
    code SMALLINT NOT NULL,
    name d_str100 NOT NULL,
    acronym CHAR(2) NOT NULL,
    CONSTRAINT pk_states_code PRIMARY KEY (code)
);

CREATE TABLE IF NOT EXISTS MUNICIPALITIES (
    code INTEGER UNIQUE NOT NULL,
    state_code SMALLINT,
    name d_str100 NOT NULL,
    CONSTRAINT pk_municipalities_id PRIMARY KEY (code),
    CONSTRAINT fk_states_code
        FOREIGN KEY (state_code)
        REFERENCES STATES (code)
        ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS ACADEMIC_PERIODS (
    public_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),

    term_type e_term_type NOT NULL,
    sequencial_number INTEGER NOT NULL,
    academic_year d_current_year NOT NULL,

    period_range DATERANGE NOT NULL,

    CONSTRAINT pk_academic_periods_id PRIMARY KEY
        (term_type, sequencial_number, academic_year)
);

CREATE TABLE IF NOT EXISTS CERTIFICATIONS (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name d_str150 NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_workload SMALLINT NOT NULL,
    institution_name d_str150 NOT NULL,

    delivery_mode e_delivery_mode NOT NULL,
    degree_type e_degree_type NOT NULL,
    qualification_tier e_qualification_tier NOT NULL,

    LIKE TEMPLATE_AUDIT_TRAIL
);

CREATE TABLE IF NOT EXISTS ADDRESSES (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    street d_str150 NOT NULL,
    neighborhood d_str200 NOT NULL,
    residence_number SMALLINT NOT NULL,
    postal_code d_numeric_str UNIQUE NOT NULL,
    complement d_str50 NOT NULL DEFAULT 'Not informed',
    LIKE TEMPLATE_AUDIT_TRAIL,
    CONSTRAINT c_pk_address PRIMARY KEY (id),
    CONSTRAINT c_chk_postal_code_max_length CHECK (LENGTH(postal_code) = 8)
);

CREATE TABLE IF NOT EXISTS PERSONS (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    public_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    first_name d_str100 NOT NULL,
    last_name d_str200 NOT NULL,
    preferred_name d_str50,
    national_id d_numeric_str UNIQUE NOT NULL,
    tax_id d_numeric_str UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality d_str150 NOT NULL,
    gender e_gender NOT NULL,
    legal_sex e_legal_sex NOT NULL,
    address_id INTEGER NOT NULL,
    profession d_str100,
    LIKE TEMPLATE_AUDIT_TRAIL,
    CONSTRAINT c_pk_person PRIMARY KEY (id),
    CONSTRAINT c_fk_persons_address_id
        FOREIGN KEY (address_id)
        REFERENCES ADDRESSES (id)
        ON DELETE RESTRICT,
    CONSTRAINT c_chk_persons_national_id_len CHECK(LENGTH(national_id) = 7),
    CONSTRAINT c_chk_persons_tax_id_len CHECK(LENGTH(tax_id) = 11)
);

CREATE TABLE IF NOT EXISTS EMAILS

CREATE TABLE IF NOT EXISTS PHONES (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    number d_phone_number NOT NULL,
    person_id INTEGER NOT NULL,
    LIKE TEMPLATE_AUDIT_TRAIL,
    CONSTRAINT c_pk_phone PRIMARY KEY (id),
    CONSTRAINT c_fk_persons_person_id
        FOREIGN KEY (person_id)
        REFERENCES PERSONS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS EMPLOYEES (
    id INTEGER NOT NULL,
    admission_on DATE NOT NULL,
    registration_number BIGINT UNIQUE NOT NULL,
    status e_employee_status NOT NULL,
    job_title e_job_title NOT NULL,
    weekly_hours SMALLINT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    LIKE TEMPLATE_AUDIT_TRAIL,
    CONSTRAINT c_pk_employee PRIMARY KEY (id),
    CONSTRAINT c_fk_persons_employee_id
        FOREIGN KEY (id)
        REFERENCES PERSONS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS STAFFS (
    id INTEGER NOT NULL,
    classification_type e_classification_type NOT NULL,
    CONSTRAINT pk_staff_id
        PRIMARY KEY (id),
    CONSTRAINT fk_employees_staff_id
        FOREIGN KEY (id)
        REFERENCES EMPLOYEES (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DEPARTMENTS (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    name d_str100 NOT NULL,
    ramal d_numeric_string,
    staff_id INTEGER NOT NULL,
    CONSTRAINT c_pk_departments_id PRIMARY KEY (id),
    CONSTRAINT c_fk_staffs_staff_id
        FOREIGN KEY (staff_id)
        REFERENCES STAFFS (id)
        ON DELETE RESTRICT,
    CONSTRAINT c_chk_departments_ramal_len
        CHECK (LENGTH(ramal) = 4)
);

CREATE TABLE IF NOT EXISTS STUDENTS (
    id INTEGER NOT NULL,
    admission_method e_admission_method NOT NULL,
    quota_category e_quota_category NOT NULL,
    CONSTRAINT c_pk_students_id PRIMARY KEY (id),
    CONSTRAINT c_fk_persons_student_id
        FOREIGN KEY (id)
        REFERENCES PERSONS (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS DISABILITIES (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    icd_code CHAR(5) NOT NULL UNIQUE, -- (The CID) e.g., "F84.0" (Childhood Autism), "H54.0" (Blindness).
    name d_str200 NOT NULL,
    category e_disability_category NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS STUDENT_DISABILITIES (
    student_id INTEGER NOT NULL,
    disability_id INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS DEPENDENT_GUARDIANS (
    guardian_id INTEGER NOT NULL,
    dependent_id INTEGER NOT NULL,
    familiar_bond e_familiar_bond NOT NULL,

    LIKE TEMPLATE_AUDIT_TRAIL,

    CONSTRAINT c_pk_guardian_dependent_id
        PRIMARY KEY (guardian_id, dependent_id),
    CONSTRAINT c_fk_persons_guardian_id
        FOREIGN KEY (guardian_id)
        REFERENCES PERSONS (id)
        ON DELETE RESTRICT,
    CONSTRAINT c_fk_persons_dependent_id
        FOREIGN KEY (dependent_id)
        REFERENCES PERSONS (id)
        ON DELETE RESTRICT,
    CONSTRAINT c_chk_dependent_cannot_be_the_own_guardian
        CHECK (dependent_id <> guardian_id)
);

CREATE TABLE IF NOT EXISTS TEACHERS (
    id INTEGER NOT NULL,
    faculty_category e_faculty_category NOT NULL,
    expertise_area d_str200 NOT NULL,

    LIKE TEMPLATE_AUDIT_TRAIL,

    CONSTRAINT pk_teachers_id PRIMARY KEY (id),
    CONSTRAINT fk_teachers_id
        FOREIGN KEY (id)
        REFERENCES EMPLOYEES (id)
        ON DELETE CASCADE
);

--verificar no csv
CREATE TABLE IF NOT EXISTS PROGRAMS (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    public_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    code VARCHAR(15) UNIQUE NOT NULL,
    name d_str150 NOT NULL,
    description d_str400 NOT NULL,
    total_workload SMALLINT NOT NULL,
    complementary_hours SMALLINT NOT NULL,
    default_shift d_shifts NOT NULL,
    pedagogical_project TEXT NOT NULL,
    accreditation_score DECIMAL(3,2),
    department_id INTEGER NOT NULL,
    coordinator_id INTEGER,
    status e_program_status NOT NULL,

    delivery_mode e_delivery_mode NOT NULL,
    degree_type e_degree_type NOT NULL,
    qualification_tier e_qualification_tier NOT NULL,

    LIKE TEMPLATE_AUDIT_TRAIL,

	CONSTRAINT pk_programs_id PRIMARY KEY (id),
    CONSTRAINT fk_programs_department_id
        FOREIGN KEY (department_id)
        REFERENCES DEPARTMENTS (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_programs_coordinator_id
        FOREIGN KEY (coordinator_id)
        REFERENCES TEACHERS (id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS COURSES (
    id INTEGER GENERATED ALWAYS AS IDENTITY,
    public_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,
    name d_str150 NOT NULL,
    syllabus JSONB NOT NULL DEFAULT '{
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
    total_credit_hours SMALLINT NOT NULL, -- Usually used to quantify hours as a credit, 1 credit corresponds to 3 hours per week
    expected_sessions SMALLINT NOT NULL,
    delivery_mode e_delivery_mode NOT NULL,
    available_period e_available_period NOT NULL,
    is_elective BOOLEAN NOT NULL DEFAULT FALSE,
    subscription_fee DECIMAL(5,2) NOT NULL,
    status e_course_status NOT NULL,
    program_id INTEGER NOT NULL,

    LIKE TEMPLATE_AUDIT_TRAIL,

    CONSTRAINT pk_courses_id PRIMARY KEY (id),
    CONSTRAINT fk_courses_program_id
        FOREIGN KEY (program_id)
        REFERENCES PROGRAMS (id)
        ON DELETE RESTRICT,
    CONSTRAINT c_chk_credit_hours CHECK (total_credit_hours > 0)
);

CREATE TABLE IF NOT EXISTS CLASS_SECTIONS (
    turma_id INTEGER GENERATED ALWAYS AS IDENTITY,
    codigo BIGINT UNIQUE NOT NULL,

    CONSTRAINT pk_turma PRIMARY KEY (turma_id)
);

CREATE TABLE IF NOT EXISTS ACTIVITY_TYPES (
    tipo_atividade_id INTEGER GENERATED ALWAYS AS IDENTITY,
    tipo d_str200r,
    criado_em d_auditoria_de_insercao,
    atualizado_em d_auditoria_de_insercao,
    nota_minima SMALLINT NOT NULL, --criar um domínio pra isso aqui
    nota_maxima SMALLINT NOT NULL,
    CONSTRAINT c_pk_tipo_atividade PRIMARY KEY (tipo_atividade_id)
);

CREATE TABLE IF NOT EXISTS ACTIVITIES (
    atividade_id INTEGER GENERATED ALWAYS AS IDENTITY,
    datahora_inicio d_auditoria_de_insercao,
    datahora_fim TIMESTAMPTZ NOT NULL,
    is_avaliativa BOOLEAN NOT NULL DEFAULT FALSE,
    documento_url TEXT NOT NULL,
    tipo_atividade_id INTEGER NOT NULL,
    CONSTRAINT c_pk_atividade PRIMARY KEY (atividade_id),
    CONSTRAINT c_atividade_deve_possuir_um_tipo
        FOREIGN KEY (tipo_atividade_id)
        REFERENCES TIPOS_ATIVIDADES (tipo_atividade_id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS COURSE_ENROLLMENTS (
    numero_matricula BIGINT GENERATED ALWAYS AS IDENTITY,
    data_matricula DATE NOT NULL,
    status_conclusao e_status_conclusao_disciplina NOT NULL,
    ano_cursado d_ano_atual_com_cadastro_default NOT NULL,
    semestre_cursado SMALLINT NOT NULL,
    media_final DECIMAL DEFAULT NULL,
    disciplina_id INTEGER NOT NULL,
    aluno_id INTEGER NOT NULL,
    CONSTRAINT c_pk_matricula_disciplina PRIMARY KEY(numero_matricula),
    CONSTRAINT c_fk_matricula_da_disciplina_deve_conter_uma_disciplina_associada
        FOREIGN KEY (disciplina_id)
        REFERENCES DISCIPLINAS (disciplina_id)
        ON DELETE RESTRICT, -- Não permitirá apagar a disciplina se houver alguma matrícula disciplina
    CONSTRAINT c_fk_matricula_da_disciplina_deve_conter_um_aluno_associado
        FOREIGN KEY (aluno_id)
        REFERENCES ALUNOS (aluno_id)
        ON DELETE CASCADE --Se o aluno for deletado da tabela todas as suas matrículas em disciplinas também serão
);

CREATE TABLE IF NOT EXISTS CLASSROOMS (
    sala_id INTEGER GENERATED ALWAYS AS IDENTITY,
    bloco CHAR(1) NOT NULL,
    codigo_sala VARCHAR(6) UNIQUE NOT NULL,
    refrigerada BOOLEAN NOT NULL DEFAULT FALSE,
    numero_patrimonio TEXT UNIQUE NOT NULL,
    capacidade SMALLINT NOT NULL,
    CONSTRAINT c_pk_sala PRIMARY KEY (sala_id)
);

-- Esta tabela não faz diferença possuir uma PRIMARY KEY, pois a estrutura é de grafos e não de dependência exclusiva.
CREATE TABLE IF NOT EXISTS PRE_REQUISITES (
    disciplina_id INTEGER NOT NULL,
    pre_requisito_id INTEGER NOT NULL,
    data_inicio_vigencia DATE NOT NULL,
    data_fim_vigencia DATE NOT NULL,
    ordem_prioridade SMALLINT NOT NULL DEFAULT 0,
    CONSTRAINT c_fk_diciplina_origem
        FOREIGN KEY (disciplina_id)
        REFERENCES DISCIPLINAS (disciplina_id)
        ON DELETE CASCADE, --Se o nó de origem é apagado todos atrelados a ele tbm são
    CONSTRAINT c_fk_pre_requisito
        FOREIGN KEY (pre_requisito_id)
        REFERENCES DISCIPLINAS (disciplina_id)
        ON DELETE RESTRICT --um elemento do nó refernciado aqui não pode ser apagado na tabela de origem
);

CREATE TABLE IF NOT EXISTS COURSE_ASSIGNMENTS (
    alocacao_docente_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disciplina_id INTEGER NOT NULL, -- Todo professor na alocação precisa estar associado a uma disciplina
    professor_id INTEGER NOT NULL,
    turma_id INTEGER, -- O professor pode não ter sido escalado para nenhuma turma ainda
    ano_semestre VARCHAR(6) NOT NULL, -- Ex: 2026/1
    is_ativo BOOLEAN DEFAULT TRUE,
    UNIQUE (disciplina_id, professor_id, turma_id),
    CONSTRAINT c_fk_aloc_disc
        FOREIGN KEY (disciplina_id)
        REFERENCES DISCIPLINAS (disciplina_id)
        ON DELETE CASCADE,
    CONSTRAINT c_fk_aloc_prof
        FOREIGN KEY (professor_id)
        REFERENCES PROFESSORES (professor_id)
        ON DELETE RESTRICT,
    CONSTRAINT c_fk_aloc_turma
        FOREIGN KEY (turma_id)
        REFERENCES TURMAS (turma_id)
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS ACTIVITY_APPLICATIONS (
    atividade_id INTEGER NOT NULL,
    turma_id INTEGER, -- O professor pode fazer o upload de uma atividade sem imediatamente especificar a turma, facilitando o planejamento.
    status_atividade e_status_atividade NOT NULL,
    CONSTRAINT c_pk_cadastro_atividades
        PRIMARY KEY (atividade_id, turma_id), -- surrogate key, garante que cada registro seja único de forma lógica.
    CONSTRAINT c_fk_cad_atv_base
        FOREIGN KEY (atividade_id)
        REFERENCES ATIVIDADES (atividade_id)
        ON DELETE RESTRICT,
    CONSTRAINT c_fk_cad_atv_turma
        FOREIGN KEY (turma_id)
        REFERENCES TURMAS (turma_id)
        ON DELETE SET NULL
);

-- 4. MATRICULA_TURMA
CREATE TABLE IF NOT EXISTS COURSE_CLASS_SECTIONS (
    aluno_id INTEGER NOT NULL,
    turma_id INTEGER NOT NULL,
    CONSTRAINT c_pk_aluno_turma
        PRIMARY KEY (turma_id, aluno_id),
    CONSTRAINT c_fk_aluno_deve_estar_vinculado_a_uma_turma
        FOREIGN KEY (aluno_id)
        REFERENCES ALUNOS (aluno_id)
        ON DELETE CASCADE, -- Quando um aluno for apagado, todo o histórico de turmas é apagado em cascata
    CONSTRAINT c_fk_turma_deve_ser_associada_a_tabela_de_juncao
        FOREIGN KEY (turma_id)
        REFERENCES TURMAS (turma_id)
        ON DELETE CASCADE -- Se a turma for deletada, todos os registros de alunos deve ser apagado também
);

CREATE TABLE IF NOT EXISTS ENTREGAS (
    numero_entrega INTEGER GENERATED BY DEFAULT AS IDENTITY,
    atividade_id INTEGER NOT NULL,
    aluno_id INTEGER NOT NULL,
    turma_id INTEGER NOT NULL,
    nota DECIMAL(4,2),
    uri_arquivo TEXT,
    datahora_entrega d_auditoria_de_insercao,
    CONSTRAINT c_pk_entregas
        PRIMARY KEY (numero_entrega, aluno_id, turma_id, atividade_id),
    CONSTRAINT c_fk_entregas_aluno
        FOREIGN KEY (aluno_id, turma_id)
        REFERENCES ALUNOS_TURMAS (aluno_id, turma_id)
        ON DELETE CASCADE,
    CONSTRAINT c_fk_unique_cadastro_atividades
        FOREIGN KEY (turma_id, atividade_id)
        REFERENCES CADASTRO_ATIVIDADES (turma_id, atividade_id)
        ON DELETE RESTRICT
);

-- Trigger 1, Ao inserir algum dado, é preciso verificar se o dados sala_id, alocacao_docente_id, periodo_ocupacao e dia_semana não se repetem igualmente, portanto, distintos entre si.

CREATE TABLE IF NOT EXISTS GRADE_HORARIA (
    grade_horaria_id INTEGER GENERATED ALWAYS AS IDENTITY,
    sala_id INTEGER NOT NULL,
    alocacao_docente_id INTEGER,
    -- O professor pode ainda não ter reservado a sala, mas a grade pode ser montada antes
    -- Ou então a sala pode ser reservada para outro fim, sem estar associada ao professor. Por enquanto esse design funciona.
    periodo_ocupacao d_periodo_r,
    dia_da_semana d_dia_da_semana_r,
    frequencia e_frequencia NOT NULL,
    finalidade e_finalidade_ocupacao_sala NOT NULL DEFAULT 'Letivo',
    total_horas_ocupacao SMALLINT,
    CONSTRAINT c_sk_grade_horaria PRIMARY KEY (grade_horaria_id),
    CONSTRAINT c_fk_o_registro_deve_possuir_uma_sala
        FOREIGN KEY (sala_id)
        REFERENCES SALAS_DE_AULA (sala_id)
        ON DELETE RESTRICT,
    CONSTRAINT c_fk_o_registro_deve_possuir_um_requerente
        FOREIGN KEY (alocacao_docente_id)
        REFERENCES ALOCACAO_DOCENTES (alocacao_docente_id)
        ON DELETE SET NULL
);

-- 6. ESPECIALIZACOES
CREATE TABLE IF NOT EXISTS QUALIFICATIONS (
    especializacao_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descricao_experiencia TEXT,
    capacitacao_id INTEGER NOT NULL,
    pessoa_id INTEGER NOT NULL,
    CONSTRAINT c_fk_capacitacoes
        FOREIGN KEY (capacitacao_id)
        REFERENCES CAPACITACOES (capacitacao_id)
        ON DELETE RESTRICT,
    CONSTRAINT c_fk_pessoas
        FOREIGN KEY (pessoa_id)
        REFERENCES PESSOAS (pessoa_id)
        ON DELETE CASCADE
);

-- 7. MATRICULA_CURSO
CREATE TABLE IF NOT EXISTS PROGRAM_ENROLLMENTS (
    enrollment_number BIGINT UNIQUE NOT NULL,
    program_id INTEGER NOT NULL,
    student_id INTEGER NOT NULL,


    status_matricula e_status_matricula NOT NULL DEFAULT 'Ativo',
    datahora_matricula d_auditoria_de_insercao,
    CONSTRAINT c_pk_matricula_curso PRIMARY KEY (curso_id, aluno_id),
    CONSTRAINT c_fk_curso_id
        FOREIGN KEY (curso_id)
        REFERENCES CURSOS (curso_id),
    CONSTRAINT c_fk_aluno_id
        FOREIGN KEY (aluno_id)
        REFERENCES ALUNOS (aluno_id)
);

CREATE TABLE IF NOT EXISTS LESSONS (
    aula_id INTEGER GENERATED ALWAYS AS IDENTITY,
    numero_aula INTEGER GENERATED BY DEFAULT AS IDENTITY,
    professor_id INTEGER NOT NULL,
    turma_id INTEGER NOT NULL,
    disciplina_id INTEGER NOT NULL,
    CONSTRAINT c_pk_aula_id PRIMARY KEY (aula_id),
    CONSTRAINT c_unique_aula_deve_ser_unica UNIQUE (
        numero_aula, professor_id, turma_id, disciplina_id),
    CONSTRAINT c_fk_unique_alocacao_doscentes
        FOREIGN KEY (professor_id, turma_id, disciplina_id)
        REFERENCES ALOCACAO_DOCENTES (professor_id, turma_id, disciplina_id)
);

CREATE TABLE IF NOT EXISTS CLASS_ATTENDANCE (
    student_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    is_present BOOLEAN NOT NULL DEFAULT TRUE,
    check_in_time TIME,
    check_out_time TIME,
    CONSTRAINT pk_attendance  PRIMARY KEY (student_id, lesson_id),
    CONSTRAINT c_fk_aluno_id
        FOREIGN KEY (aluno_id)
        REFERENCES ALUNOS (aluno_id)
        ON DELETE CASCADE,
    CONSTRAINT c_fk_aula_id
        FOREIGN KEY (aula_id)
        REFERENCES AULAS (aula_id)
        ON DELETE CASCADE
);