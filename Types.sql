--CREATE DATABASE IF NOT EXISTS SistemaAcademico;

--------------------------------- EXCLUIR EM CASCATA ----------------------------

DROP TYPE IF EXISTS e_legal_sex                         CASCADE;
DROP TYPE IF EXISTS e_modality                          CASCADE;
DROP TYPE IF EXISTS e_semestre_disponivel               CASCADE;
DROP TYPE IF EXISTS e_status_matricula_funcionario      CASCADE;
DROP TYPE IF EXISTS e_cargo_funcionario                 CASCADE;
DROP TYPE IF EXISTS e_categoria_docente                 CASCADE;
DROP TYPE IF EXISTS e_nivel_classificacao               CASCADE;
DROP TYPE IF EXISTS e_status_lotacao                    CASCADE;
DROP TYPE IF EXISTS e_nivel_academico                   CASCADE;
DROP TYPE IF EXISTS e_grau_especializacao               CASCADE;
DROP TYPE IF EXISTS e_status_conclusao_disciplina       CASCADE;
DROP TYPE IF EXISTS e_status_atividade                  CASCADE;
DROP TYPE IF EXISTS e_periodo                           CASCADE;
DROP TYPE IF EXISTS e_dia_semana                        CASCADE;
DROP TYPE IF EXISTS e_status_matricula                  CASCADE;
DROP TYPE IF EXISTS e_tipo_deficiencia                  CASCADE;
DROP TYPE IF EXISTS e_frequencia                        CASCADE;
DROP TYPE IF EXISTS e_finalidade_ocupacao_sala          CASCADE;
DROP TYPE IF EXISTS e_tipo_responsavel_legal            CASCADE;
DROP TYPE IF EXISTS e_meio_de_ingresso                  CASCADE;

DROP DOMAIN IF EXISTS d_telefone                      CASCADE;
DROP DOMAIN IF EXISTS d_string_numerica              CASCADE;
DROP DOMAIN IF EXISTS d_auditoria_de_insercao           CASCADE;
DROP DOMAIN IF EXISTS d_ano_atual_com_cadastro_default  CASCADE;
DROP DOMAIN IF EXISTS d_str50r                          CASCADE;
DROP DOMAIN IF EXISTS d_str100                        CASCADE;
DROP DOMAIN IF EXISTS d_str150                        CASCADE;
DROP DOMAIN IF EXISTS d_str200                         CASCADE;
DROP DOMAIN IF EXISTS d_str400                         CASCADE;
DROP DOMAIN IF EXISTS d_dia_da_semana                 CASCADE;
DROP DOMAIN IF EXISTS d_periodo                       CASCADE;

-- ---------------------------- CRIAÇÃO DE TIPOS E DOMÍNIOS ----------------------------



CREATE TYPE e_tipo_responsavel_legal AS ENUM (
    'Father',
    'Mother',
    'Responsável Legal',
    'Procurador',
    'Responsável Financeiro'
);

CREATE TYPE e_legal_sex AS ENUM (
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
);

CREATE TYPE e_delivery_mode AS ENUM (
    'in-person',
    'Online',
    'Hybrid'
);

CREATE TYPE e_semestre_disponivel AS ENUM (
    'Primeiro',
    'Segundo',
    'Terceiro'
);

CREATE TYPE e_status_matricula_funcionario AS ENUM (
    'Ativo',
    'Cancelado',
    'Pendente'
);

CREATE TYPE e_cargo_funcionario AS ENUM (
    'Professor',
    'Técnico Administrativo',
    'Coordenador',
    'Pedagogo'
); --Futuramente deve evoluir para uma tabela dedicada para comportar diversos cargos e remuneração

CREATE TYPE e_categoria_docente AS ENUM (
    'Efetivo',    -- Professor de carreira (EBTT)
    'Substituto', -- Contrato temporário
    'Visitante',  -- Pesquisador convidado
    'Temporário'
);

CREATE TYPE e_nivel_classificacao AS ENUM (
    'A', 'B', 'C', -- Níveis auxiliares (quase em extinção)
    'D',           -- Nível Médio/Técnico (ex: Assistente em Administração)
    'E'            -- Nível Superior (ex: Psicólogo, Assistente Social, Analista de TI)
);

CREATE TYPE e_status_lotacao AS ENUM (
    'Ativo',         -- O funcionário está trabalhando normalmente no departamento
    'Afastado',      -- Afastamento temporário (médico, capacitação, licença-prêmio)
    'Cedido',        -- Pertence ao departamento, mas está emprestado para outro setor/órgão
    'Permutado',     -- Trocou de lugar temporariamente com outro servidor
    'Desligado'      -- Não faz mais parte daquele departamento (foi transferido ou saiu da instituição)
);

CREATE TYPE degree_type AS ENUM (
    'High School',
    'Technician',
    'Graduation',
    'Pós-Graduação',
    'Extension'
);

CREATE TYPE e_grau_especializacao AS ENUM (
    'Bacharelado',
    'Licenciatura',
    'Tecnologia',
    'Aperfeiçoamento',
    'Especialização', -- (Lato Sensu)
    'Mestrado',       -- (Stricto Sensu)
    'Doutorado',
    'MBA'
);

CREATE TYPE e_status_conclusao_disciplina AS ENUM (
    'Cursando',            -- Aluno está assistindo as aulas
    'Aprovado',            -- Passou com nota e frequência
    'Reprovado',           -- Não atingiu a média
    'Reprovado por Falta', -- Frequência abaixo de 75% (clássico do IFC)
    'Trancado',            -- Trancou a disciplina no prazo legal
    'Cancelado'            -- Matrícula anulada por algum motivo administrativo
);

CREATE TYPE e_status_atividade AS ENUM (
    'Aberta',
    'Em Correção',
    'Corrigida',
    'Encerrada'
);

CREATE TYPE e_shift AS ENUM (
    'Matutino',
    'Vespertino',
    'Noturno'
);

CREATE TYPE e_dia_da_semana AS ENUM (
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado'
);
-- Reutilizando o e_status_matricula_funcionario ou criando um novo:
CREATE TYPE e_status_matricula AS ENUM (
    'Ativo',
    'Trancado',
    'Concluído',
    'Cancelado'
);

CREATE TYPE e_frequencia AS ENUM (
    'Único',
    'Diário',
    'Semanal',
    'Mensal',
    'Anual'
);

CREATE TYPE e_finalidade_ocupacao_sala AS ENUM (
    'Reunião',
    'Evento',
    'Letivo',
    'Manutenção'
);

CREATE TYPE e_meio_de_ingresso AS ENUM (
    'Ampla Concorrência (AC)',--: Alunos que entraram sem nenhuma reserva de vagas.
    'Escola Pública - Geral (L1 / L5)',--: Alunos que cursaram o ensino médio/fundamental integralmente em escola pública, divididos por faixa de renda.
    'Escola Pública - PPI (L2 / L6)',--: Reserva para pretos, pardos ou indígenas.
    'Escola Pública - PCD (L9 / L13)',--: Reserva para pessoas com deficiência.
    'Exame de Seleção / Vestibular Tradicional', --: O processo regular.
    'SISU / Nota do ENEM', --: Se a instituição usar a base nacional.
    'Transferência Externa / Retorno de Graduado'
);

CREATE DOMAIN d_string_numerica_r AS VARCHAR NOT NULL
    CONSTRAINT c_chk_apenas_numeros CHECK (VALUE ~ '^[0-9]+$');

CREATE DOMAIN d_telefone_r AS d_string_numerica_r
    CONSTRAINT c_chk_esta_no_intervalo CHECK (LENGTH(VALUE) = 10);

CREATE DOMAIN d_insertion_audit AS TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP;

CREATE DOMAIN d_current_year AS SMALLINT
    DEFAULT (EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT);

CREATE DOMAIN d_dia_da_semana_r AS e_dia_da_semana[] NOT NULL
    CONSTRAINT c_chk_eh_dia_da_semana_valido
        CHECK (cardinality(VALUE) <= 5 AND is_distinct(VALUE));

CREATE DOMAIN d_shifts AS e_shift[]
    CONSTRAINT c_chk_shifts_is_valid
        CHECK (cardinality(VALUE) <= 3 AND is_distinct(VALUE));

-- Campos de texto
-- str = string; 50 indica quantidade de caracteres; r = required
CREATE DOMAIN d_str50  AS VARCHAR(50);
CREATE DOMAIN d_str100 AS VARCHAR(100);
CREATE DOMAIN d_str150 AS VARCHAR(150);
CREATE DOMAIN d_str200 AS VARCHAR(200);
CREATE DOMAIN d_str400 AS VARCHAR(400);