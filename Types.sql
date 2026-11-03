--CREATE DATABASE IF NOT EXISTS SistemaAcademico;

--------------------------------- EXCLUIR EM CASCATA ----------------------------

--------------------------------------------------------------------------------
-- SCRIPT DE LIMPEZA (DROP IN CASCADE)
--------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS SECURITY      CASCADE;
DROP SCHEMA IF EXISTS TEMPLATES     CASCADE;
DROP SCHEMA IF EXISTS CORE          CASCADE;
DROP SCHEMA IF EXISTS ACADEMIC      CASCADE;
DROP SCHEMA IF EXISTS SALES         CASCADE;
DROP SCHEMA IF EXISTS ACCOUNTING    CASCADE ;

-- 1. TIPOS BASE, TEMPORAIS E INFRAESTRUTURA
DROP TYPE IF EXISTS e_term_type                                     CASCADE;
DROP TYPE IF EXISTS e_day_of_week                                   CASCADE;
DROP TYPE IF EXISTS e_shift                                         CASCADE;
DROP TYPE IF EXISTS e_frequency                                     CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_term_type                            CASCADE;
DROP TYPE IF EXISTS e_document_type                                 CASCADE;

-- 2. DOMÍNIO CORE: PESSOAS, CONTATOS E FAMÍLIA
DROP TYPE IF EXISTS CORE.e_legal_sex                                CASCADE;
DROP TYPE IF EXISTS CORE.e_gender                                   CASCADE;
DROP TYPE IF EXISTS CORE.e_contact_type                             CASCADE;
DROP TYPE IF EXISTS CORE.e_disability_category                      CASCADE;
DROP TYPE IF EXISTS CORE.e_familiar_bond                            CASCADE;
DROP TYPE IF EXISTS CORE.e_guardian_type                            CASCADE;

-- 3. DOMÍNIO CORE: ORGANIZACIONAL E RH
DROP TYPE IF EXISTS CORE.e_institution_type                         CASCADE;
DROP TYPE IF EXISTS CORE.e_job_title                                CASCADE;
DROP TYPE IF EXISTS CORE.e_employee_status                          CASCADE;
DROP TYPE IF EXISTS CORE.e_staff_qualification_level                CASCADE;

-- 4. DOMÍNIO ACADÊMICO: OFERTA, PROGRAMAS E GOVERNAÇA
DROP TYPE IF EXISTS ACADEMIC.e_educational_level                    CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_qualification_tier                   CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_delivery_mode                        CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_program_status                       CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_lifecycle_status                     CASCADE; -- Aplicado em Programs, Curricula e Courses

-- 5. DOMÍNIO ACADÊMICO: INGRESSO, PROCESSO SELETIVO E ALUNOS
DROP TYPE IF EXISTS ACADEMIC.e_admission_method                     CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_quota_category                       CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_application_status                   CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_curriculum_enrollment_status         CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_course_enrollment_status             CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_inactive_reason                      CASCADE;

-- 6. DOMÍNIO ACADÊMICO: CORPO DOCENTE, SALAS E AULAS
DROP TYPE IF EXISTS ACADEMIC.e_faculty_category                     CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_course_assignment_status             CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_classroom_amenities                  CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_lesson_type                          CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_session_status                       CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_activity_status                      CASCADE;
DROP TYPE IF EXISTS ACADEMIC.e_upload_status                        CASCADE;

-- 7. DOMÍNIOS PERSONALIZADOS (DOMAINS)
DROP DOMAIN IF EXISTS d_str_digits_only                             CASCADE;
DROP DOMAIN IF EXISTS d_document                                    CASCADE;
DROP DOMAIN IF EXISTS d_phone_number                                CASCADE;
DROP DOMAIN IF EXISTS d_days_of_week                                CASCADE;
DROP DOMAIN IF EXISTS d_insertion_audit                             CASCADE;
DROP DOMAIN IF EXISTS d_classroom_amenities                         CASCADE;

DROP DOMAIN IF EXISTS d_str50                          CASCADE;
DROP DOMAIN IF EXISTS d_str100                         CASCADE;
DROP DOMAIN IF EXISTS d_str150                         CASCADE;
DROP DOMAIN IF EXISTS d_str200                         CASCADE;
DROP DOMAIN IF EXISTS d_str400                         CASCADE;


CREATE SCHEMA SECURITY;
CREATE SCHEMA TEMPLATES;
CREATE SCHEMA CORE;
CREATE SCHEMA ACADEMIC;
CREATE SCHEMA SALES;
CREATE SCHEMA ACCOUNTING;

-- ---------------------------- CRIAÇÃO DE TIPOS E DOMÍNIOS ----------------------------

-- Classificação e Nível de Qualificação do Corpo Técnico-Administrativo (Staff)
-- 1. Nível Fundamental Operacional / Auxiliar (Cargos em extinção ou de apoio básico)
-- 2. Nível Fundamental Intermediário (Apoio operacional e de infraestrutura)
-- 3. Nível Médio / Técnico Inicial (Assistentes administrativos e operacionais)
-- 4. Nível Técnico / Médio Especializado (Técnicos de laboratório, TI e administrativos)
-- 5. Nível Superior / Especialista (Analistas, psicólogos, assistentes sociais e gestores)
CREATE TYPE CORE.e_staff_qualification_level AS ENUM (
    'Auxiliary Operational',       -- Antiga Classe A / B
    'Intermediate Support',        -- Antiga Classe C
    'Technical Administrative',   -- Antiga Classe D
    'Higher Professional'         -- Antiga Classe E
);

-- Tipo de Contato / Finalidade do Canal de Comunicação
-- 1. Pessoal (Telefone/E-mail pessoal do indivíduo)
-- 2. Profissional / Comercial (Contato de trabalho ou negócios)
-- 3. Educacional / Acadêmico (E-mail institucional da IES ou escola anterior)
-- 4. Emergência (Contato prioritário para recados ou urgências médicas)
-- 5. Financeiro (Destinado a cobranças, notas fiscais e boletos)
-- 6. Responsável Legal (Contato direto dos pais ou tutores)
-- 7. Outro (Outras finalidades específicas)
CREATE TYPE CORE.e_contact_type AS ENUM (
    'Personal',
    'Commercial',
    'Educational',
    'Emergency',
    'Financial',
    'Other'
);

-- Papel jurídico / Financeiro do responsável
-- 1. Responsável Legal (Designado por tutela/curatela)
-- 2. Procurador (Pessoa com procuração/Power of Attorney)
-- 3. Responsável Financeiro (Quem assina o contrato/paga as mensalidades)
CREATE TYPE CORE.e_guardian_type AS ENUM (
    'Legal Guardian',
    'Attorney in Fact',
    'Financial Sponsor'
);

-- Grau de parentêsco / Vínculo familiar
CREATE TYPE CORE.e_familiar_bond AS ENUM (
    'Brother',
    'Sister',
    'Father',
    'Mother',
    'Grandfather',
    'GrandMother',
    'Aunt',
    'Uncle',
    'Cousin',
    'Other'
);

CREATE TYPE CORE.e_legal_sex AS ENUM (
    'Male',
    'Female',
    'Other',
    'Prefer Not To Say'
);

CREATE TYPE CORE.e_gender AS ENUM (
    'Cisgender Man',
    'Cisgender Woman',
    'Transgender Man',
    'Transgender Woman',
    'Non Binary',
    'Agender',
    'Genderqueer',
    'Other',
    'Prefer Not To Say'
);

CREATE TYPE ACADEMIC.e_delivery_mode AS ENUM (
    'in-person',
    'Online',
    'Hybrid'
);

CREATE TYPE CORE.e_employee_status AS ENUM (
    'Active',
    'Canceled',
    'Pending'
);

-- Cargos e Funções de uma Instituição de Ensino Privada
-- 1. Presidente / Mantenedor
-- 2. Reitor / Diretor Geral
-- 3. Vice-Reitor / Vice-Diretor
-- 4. Pró-Reitor Acadêmico / Diretor Acadêmico
-- 5. Pró-Reitor Administrativo / Diretor Financeiro
-- 6. Coordenador de Curso
-- 7. Coordenador Pedagógico
-- 8. Professor Titular / Docente
-- 9. Professor Substituto / Adjunto
-- 10. Tutor / Monitor
-- 11. Secretário Acadêmico
-- 12. Assistente Acadêmico / Módulo Escolar
-- 13. Bibliotecário
-- 14. Assistente de Biblioteca
-- 15. Gerente de Recursos Humanos
-- 16. Analista Financeiro / Tesouraria
-- 17. Consultor de Admissões / Comercial
-- 18. Analista de Marketing
-- 19. Administrador de Redes / Suporte TI
-- 20. Desenvolvedor de Software
-- 21. Inspetor de Alunos / Monitor de Pátio
-- 22. Orientador Educacional / Psicopedagogo
-- 23. Assistente de Serviços Gerais
-- 24. Encarregado de Manutenção
-- 25. Agente de Segurança / Portaria
CREATE TYPE CORE.e_job_title AS ENUM (
    'President',
    'Rector',
    'Vice Rector',
    'Academic Dean',
    'Administrative Dean',
    'Course Coordinator',
    'Pedagogical Coordinator',
    'Professor',
    'Adjunct Professor',
    'Tutor',
    'Academic Secretary',
    'Academic Assistant',
    'Librarian',
    'Library Assistant',
    'HR Manager',
    'Financial Analyst',
    'Admissions Officer',
    'Marketing Analyst',
    'IT Support Specialist',
    'Software Developer',
    'Student Inspector',
    'Educational Counselor',
    'General Services Assistant',
    'Maintenance Supervisor',
    'Security Officer'
);

CREATE TYPE ACADEMIC.e_faculty_category AS ENUM (
    'Tenured',    -- Professor de carreira (EBTT)
    'Substitute', -- Contrato temporário
    'Visiting',  -- Pesquisador convidado
    'Temporary'
);

-- Categoria / Tipo de Deficiência ou Necessidade Especial
-- 1. Deficiência Visual (Cegueira ou baixa visão)
-- 2. Deficiência Auditiva (Surdez ou hipoacusia)
-- 3. Deficiência Física / Motora
-- 4. Deficiência Intelectual
-- 5. Deficiência Múltipla (Associação de duas ou mais deficiências)
-- 6. Transtorno do Espectro Autista (TEA)
-- 7. Altas Habilidades / Superdotação
-- 8. Surdocegueira
-- 9. Outras Condições / Necessidades Específicas
CREATE TYPE CORE.e_disability_category AS ENUM (
    'Visual',
    'Hearing',
    'Physical',
    'Intellectual',
    'Multiple',
    'Autism Spectrum',
    'Giftedness',
    'Deafblindness',
    'Other'
);

-- Nível Educacional
-- Define o contexto amplo de ensino obtido, não pode ser nulo
-- 1. Ensino médio
-- 2. Ensino Técnico / Profissionalizante
-- 3. Graduação Superior
-- 4. Pós-graduação (Lato e Stricto Sensu)
-- 5. Cursos Livres / Extensão / Treinos
CREATE TYPE ACADEMIC.e_educational_level AS ENUM (
    'High School',
    'Technical',
    'Undergraduate',
    'Postgraduate',
    'Extension'
);

-- Titulação / Modalidade Específica
-- 1. Bacharelado
-- 2. Licenciatura
-- 3. Tecnólogo
-- 4.
-- 5. Pós-graduação / especialização Lato Senso
CREATE TYPE ACADEMIC.e_qualification_tier AS ENUM (
    'Bachelor',
    'Licentiate',
    'Technologist',
    'Professional Improvement',
    'Specialization',
    'Master',
    'Doctorate',
    'MBA'
);

-- Status dos cursos
-- 1. O curso está ativo e pode ser adicionado em novas matrizes curriculares
-- 2. O curso está em descontinuação e não pode mais ser adicionado em matrizes curriculares
-- 3. Após todos os estudantes de um curso descontinuado concluir a graduação o curso é encerrado e
-- continua armazenado como past-program-record ppr
CREATE TYPE ACADEMIC.e_program_status AS ENUM (
    'Active',
    'Phase Out',
    'Closed'
);

-- Status Operacional e Regulatório do Componente Curricular / Disciplina
-- 1. Rascunho / Em Construção (Criado pelo docente ou coordenação)
-- 2. Em Análise / Tramitação (Em avaliação pelo Núcleo Docente Estruturante / Conselho)
-- 3. Aprovada (Validada pelo conselho acadêmico, pronta para entrar em matrizes)
-- 4. Ativa (Liberada para oferta ativa em turmas do período letivo)
-- 5. Suspensa (Oferta paralisada temporariamente)
-- 6. Descontinuada / Extinta (Fora de uso, mantida apenas para registro histórico)
CREATE TYPE ACADEMIC.e_lifecycle_status AS ENUM (
    'Draft',
    'Under Review',
    'Approved',
    'Active',
    'Suspended',
    'Discontinued'
);

 -- O Aluno é efetivamente matriculado, porém, as aulas ainda não começaram
 -- O Aluno está ativamente cursando as aulas
 -- Passou com nota e frequência
 -- Não atingiu a média
 -- Trancamento formal no prazo
 -- Matrícula anulada por algum motivo administrativo
 -- Dispensado / Aproveitamento de estudos
CREATE TYPE ACADEMIC.e_course_enrollment_status AS ENUM (
    'Enrolled',
    'In-Progress',
    'Approved',
    'Failed',
    'Withdraw',
    'Canceled',
    'Exempted'
);

-- Situacao do Aluno no Curso / Programa
-- 1. Ativo / Regularmente Matriculado
-- 2. Trancado (Suspensao temporal dos estudos)
-- 3. Formado / Graduado / Concluido
-- 4. Desistente / Evadido
-- 5. Transferido (Para outra IES ou outro curso)
-- 6. Jubilado / Desligado por Decisao Administrativa
CREATE TYPE ACADEMIC.e_curriculum_enrollment_status AS ENUM (
    'Active',
    'Suspended',
    'Graduated',
    'Dropped Out',
    'Transferred',
    'Dismissed'
);

CREATE TYPE ACADEMIC.e_activity_status AS ENUM (
    'Draft',
    'Submitted'
);

CREATE TYPE ACADEMIC.e_application_status AS ENUM (
    'Open',
    'Reopened',
    'Deferred',
    'Canceled',
    'Expired'
    'Closed',
    'Archived'
);

CREATE TYPE ACADEMIC.e_upload_status AS ENUM (
    'Graded'
    'In-Grading',
    'Pending',
    'Rejected'
);

CREATE TYPE ACADEMIC.e_classroom_amenities AS ENUM (
    'Air Conditioning',     -- Ar-condicionado
    'Projector',            -- Projetor / Datashow
    'Smartboard',           -- Lousa digital / Quadro interativo
    'Audio System',         -- Sistema de som ambiente / Microfone
    'Computers',            -- Laboratório com computadores para alunos
    'Accessibility Ramp',   -- Acesso por rampa
    'Elevator Access',      -- Acesso por elevador
    'Braille Signage',      -- Sinalização em Braille
    'High Speed Wifi',      -- Wi-Fi dedicado de alta velocidade
    'Video Conference'      -- Equipamento para transmissão / Aulas híbridas
);

CREATE TYPE e_shift AS ENUM (
    'Morning',
    'Afternoon',
    'Evening'
);

CREATE TYPE e_day_of_week AS ENUM (
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
);

CREATE TYPE e_frequency AS ENUM (
    'Unique',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
);

CREATE TYPE CORE.e_institution_type AS ENUM (
    'Public Federal',
    'Public State',
    'Public Municipal',
    'Private',
    'Community Philanthropic'
);

CREATE TYPE ACADEMIC.e_admission_method AS ENUM (
    'Traditional Entrance Exam',  -- Vestibular Tradicional / Exame de Seleção
    'National Exam SISU',         -- SiSU / Nota do ENEM
    'External Transfer',          -- Transferência Externa (de outra IES)
    'Internal Transfer',          -- Transferência Interna (troca de curso)
    'Graduate Return',            -- Portador de Diploma / Retorno de Graduado
    'Judicial Order',             -- Liminar / Decisão Judicial
    'Agreement Exchange'          -- Convênio Internacional / Intercâmbio
);

CREATE TYPE ACADEMIC.e_quota_category AS ENUM (
    'AC',           -- Ampla Concorrência
    'PPI',          -- Pretos, Pardos, Indígenas e Quilombolas
    'PCD',          -- Pessoas com Deficiência
    'LOW INCOME',   -- Cota de Renda (Inferior ao limite legal)
    'PPI PCD',      -- Combinado: PPI + PCD
    'SOCIAL'        -- Outras ações afirmativas / Políticas locais
);

-- =============================================================================
-- Domain Enum Types for Course Assignments
-- =============================================================================
CREATE TYPE ACADEMIC.e_course_assignment_status AS ENUM (
    'Active',
    'Inactive',
    'Canceled'
);

-- Successful completion of assignment validity period
-- Early termination due to teacher replacement
-- Termination caused by PPC/curriculum updates
-- Manual inactivation by administrative decision
CREATE TYPE ACADEMIC.e_inactive_reason AS ENUM (
    'Completed',
    'Teacher Substitution',
    'Curriculum Change',
    'Administrative'
);

CREATE TYPE ACADEMIC.e_term_type AS ENUM (
    'Semester',
    'Trimester',
    'Quarter',
    'Annual'
);

-- Tipo/Modalidade da Aula
-- 1. Aula Teórica / Expositiva
-- 2. Aula Prática (Laboratório/Campo)
-- 3. Mista (Teoria + Prática na mesma sessão)
-- 4. Apresentação de Trabalhos / Seminários
-- 5. Avaliação / Prova presencial ou online
-- 6. Tutoria / Monitoria / Acompanhamento
-- 7. Trabalho de Campo / Visita Técnica
-- 8. Estágio / Prática Supervisionada
-- 9. Defesa de TCC / Banca Examinadora
CREATE TYPE ACADEMIC.e_lesson_type AS ENUM (
    'Theoretical',
    'Practical',
    'Theoretical Practical',
    'Seminar',
    'Assessment',
    'Tutoring',
    'Field Work',
    'Internship',
    'Defense'
);

-- Estado do Diário / Execução da Sessão de Aula
-- 1. Agendada no calendário (aguardando a data/hora)
-- 2. Em andamento (professor abriu a chamada/diário)
-- 3. Realizada (frequência e conteúdo ministrado lançados)
-- 4. Cancelada (feriado, imprevisto, falta justificada)
-- 5. Reagendada para outra data/horário
-- 6. Ministrada por um professor substituto
CREATE TYPE ACADEMIC.e_session_status AS ENUM (
    'Scheduled',
    'In Progress',
    'Completed',
    'Canceled',
    'Rescheduled',
    'Substituted'
);

CREATE TYPE CORE.e_document_type AS ENUM (
    'National Id',
    'Tax id',
    'Birth Certificate',
    'High School Diploma',
    'Address Proof',
    'Activity',
    'Other'
);

CREATE DOMAIN d_document AS JSONB DEFAULT '[]'::jsonb
    CONSTRAINT chk_document_urls_is_array
        CHECK (jsonb_typeof(VALUE) = 'array')
    CONSTRAINT chk_document_urls_structure
        CHECK (
            NOT jsonb_path_exists(VALUE, '$[*] ? (!exists(@.url) || !exists(@.type))')
        );

CREATE DOMAIN d_str_digits_only AS VARCHAR
    CONSTRAINT chk_apenas_numeros CHECK (VALUE ~ '^[0-9]+$');

-- Tamanho máximo do número de telefone com base na norma internacional ITU-T E.164.
-- A norma estabelece o limite global em 15 dígitos numéricos, composto pela soma de:
-- 1. Código do País / DDI (1 a 3 dígitos)
-- 2. Código de Área / Região / DDD (1 a 4 dígitos)
-- 3. Número do Assinante / Linha (6 a 9 dígitos)
-- O formato armazena apenas caracteres numéricos puros (sanitizados), garantindo
-- compatibilidade com APIs de integração (Twilio, WhatsApp) e validação internacional.
CREATE DOMAIN d_phone_number AS d_str_digits_only
    CONSTRAINT chk_phone_number_limit CHECK(
        LENGTH(VALUE) >= 7 AND
        LENGTH(VALUE) <= 15);

CREATE DOMAIN d_insertion_audit AS TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP;

CREATE DOMAIN d_days_of_week AS e_day_of_week[]
    CONSTRAINT chk_day_of_week_is_valid
        CHECK ((cardinality(VALUE) BETWEEN 1 AND 7) AND is_distinct(VALUE));

CREATE DOMAIN d_shifts AS e_shift[]
    CONSTRAINT chk_shifts_is_valid
        CHECK ((cardinality(VALUE) BETWEEN 1 AND 3) AND is_distinct(VALUE));

CREATE DOMAIN d_classroom_amenities AS ACADEMIC.e_classroom_amenities[]
    CONSTRAINT chk_amenities_is_distinct CHECK (is_distinct(VALUE));

-- Campos de texto
-- str = string; 50 indica quantidade de caracteres; r = required
CREATE DOMAIN d_str50  AS VARCHAR(50);
CREATE DOMAIN d_str100 AS VARCHAR(100);
CREATE DOMAIN d_str150 AS VARCHAR(150);
CREATE DOMAIN d_str200 AS VARCHAR(200);
CREATE DOMAIN d_str400 AS VARCHAR(400);