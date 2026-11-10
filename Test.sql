SELECT * FROM ACADEMIC.SCHEDULES;

-- ----------------------------- INSERINDO DADOS DE USUARIO ----------------------------

SELECT * FROM CORE.STATES;
SELECT * FROM CORE.MUNICIPALITIES;
SELECT * FROM CORE.STREETS;
SELECT * FROM CORE.ADDRESSES;
SELECT * FROM CORE.PERSONS;

-- =============================================================================
-- 1. ESTADOS E MUNICÍPIOS DE TESTE
-- =============================================================================
INSERT INTO CORE.STATES (code, name, acronym) VALUES
    (42, 'Santa Catarina', 'SC'),
    (41, 'Paraná', 'PR'),
    (35, 'São Paulo', 'SP');

INSERT INTO CORE.MUNICIPALITIES (code, state_code, name) VALUES
    (4203204, 42, 'Camboriú'),
    (4202008, 42, 'Balneário Camboriú'),
    (4208203, 42, 'Itajaí'),
    (4106902, 41, 'Curitiba'),
    (3550308, 35, 'São Paulo');

-- =============================================================================
-- 2. LOGRADOUROS (CORE.STREETS)
-- =============================================================================
INSERT INTO CORE.STREETS (street, neighborhood, city_code, postal_code) VALUES
    ('Rio Formoso', 'Rio Pequeno', 4203204, '88343427'),         -- id: 1
    ('Rua Tarumã', 'Taboleiro', 4203204, '88348000'),            -- id: 2
    ('Avenida Santa Catarina', 'Centro', 4203204, '88340000'),   -- id: 3
    ('Avenida Brasil', 'Centro', 4202008, '88330001'),           -- id: 4
    ('Rua 1500', 'Centro', 4202008, '88330520'),                -- id: 5
    ('Rua Delfim de Pádua Peixoto', 'Praia Brava', 4208203, '88306820'), -- id: 6
    ('Rua XV de Novembro', 'Centro', 4106902, '80020000'),       -- id: 7
    ('Avenida Paulista', 'Bela Vista', 3550308, '01310100');     -- id: 8

-- =============================================================================
-- 3. UNIDADES DE ENDEREÇO (CORE.ADDRESSES)
-- =============================================================================
INSERT INTO CORE.ADDRESSES (street_id, residence_number, complement) VALUES
    (1, 287, 'Sobrado'),          -- id: 1 (Casa do Alex e Família)
    (1, 322, 'Apt. nº203'),       -- id: 2
    (2, 105, 'Casa'),             -- id: 3 (Casa Família Frozza)
    (2, 105, 'Edícula'),          -- id: 4
    (3, 50, 'Apt. 101'),          -- id: 5 (Família Oliveira)
    (3, 50, 'Apt. 102'),          -- id: 6
    (4, 1200, 'Apt. 504'),        -- id: 7 (Família Santos)
    (4, 1200, 'Apt. 801'),        -- id: 8
    (5, 450, 'Sobrado A'),        -- id: 9
    (6, 88, 'Apt. 12'),           -- id: 10
    (7, 300, 'Apt. 41'),          -- id: 11
    (8, 1500, 'Conjunto 82');     -- id: 12

-- =============================================================================
-- 4. CADASTRO DE PESSOAS (CORE.PERSONS - 100 REGISTROS)
-- =============================================================================
INSERT INTO CORE.PERSONS
    (first_name, last_name, preferred_name, national_id, tax_id, date_of_birth, nationality, gender, legal_sex, address_id, profession)
VALUES
    -- 1 a 5: Casa 1 (Família Linhares - Camboriú)
    ('Alexander', 'Alcantara Linhares', 'Alex', '7487202', '12048756930', '2005-06-09', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Intern'), -- Filho / Aluno BSI
    ('Juliana', 'Alcantara', 'N/I', '4892301', '89230149920', '1978-04-12', 'Brazilian', 'Cisgender Woman', 'Female', 1, 'Accountant'), -- Mãe
    ('Roberto', 'Linhares', 'N/I', '3920194', '49201948911', '1975-11-23', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Civil Engineer'), -- Pai
    ('Sophia', 'Alcantara Linhares', 'Soso', '8921049', '91049284900', '2010-09-15', 'Brazilian', 'Cisgender Woman', 'Female', 1, 'Student'), -- Filha
    ('Lucas', 'Alcantara Linhares', 'N/I', '9049281', '04928401922', '2012-01-30', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Student'), -- Filho

    -- 6 a 9: Casa 3 (Família Frozza - Camboriú)
    ('Angelo', 'Frozza Ramos', 'Prof. Frozza', '6848934', '00439234544', '1976-05-18', 'Brazilian', 'Cisgender Man', 'Male', 3, 'Database Professor'), -- Professor / Pai
    ('Mariana', 'Ramos Frozza', 'N/I', '5839201', '78392019488', '1979-08-22', 'Brazilian', 'Cisgender Woman', 'Female', 3, 'Pedagogue'), -- Mãe
    ('Gabriel', 'Ramos Frozza', 'N/I', '8392019', '83920194833', '2004-11-05', 'Brazilian', 'Cisgender Man', 'Male', 3, 'Student'), -- Filho
    ('Beatriz', 'Ramos Frozza', 'Bia', '9301928', '93019284944', '2008-03-14', 'Brazilian', 'Cisgender Woman', 'Female', 3, 'Student'), -- Filha

    -- 10 a 13: Endereço 5 (Família Oliveira - Camboriú)
    ('Carlos', 'Eduardo Oliveira', 'Cadu', '2938401', '19283049588', '1968-12-01', 'Brazilian', 'Cisgender Man', 'Male', 5, 'Systems Analyst'), -- Pai / Professor
    ('Fernanda', 'Lima Oliveira', 'N/I', '3849201', '28394019277', '1971-07-19', 'Brazilian', 'Cisgender Woman', 'Female', 5, 'Administrator'), -- Mãe
    ('Henrique', 'Lima Oliveira', 'N/I', '7483920', '38492019466', '2003-02-10', 'Brazilian', 'Cisgender Man', 'Male', 5, 'Developer'), -- Filho / Aluno
    ('Larissa', 'Lima Oliveira', 'N/I', '8492019', '48392019455', '2006-06-25', 'Brazilian', 'Cisgender Woman', 'Female', 5, 'Student'), -- Filha

    -- 14 a 17: Endereço 7 (Família Santos - Balneário Camboriú)
    ('Marcelo', 'Augusto Santos', 'N/I', '1928374', '58493029144', '1972-01-15', 'Brazilian', 'Cisgender Man', 'Male', 7, 'Lawyer'), -- Pai
    ('Camila', 'Pereira Santos', 'N/I', '2837491', '68594039233', '1975-09-08', 'Brazilian', 'Cisgender Woman', 'Female', 7, 'Architect'), -- Mãe
    ('Enzo', 'Pereira Santos', 'N/I', '7384920', '78695049322', '2005-04-18', 'Brazilian', 'Cisgender Man', 'Male', 7, 'Student'), -- Filho / Aluno BSI
    ('Valentina', 'Pereira Santos', 'N/I', '8394029', '88796059411', '2009-12-03', 'Brazilian', 'Cisgender Woman', 'Female', 7, 'Student'), -- Filha

    -- 18 a 22: Alunos e Professores Variados (Itajaí / BC / Camboriú)
    ('Gustavo', 'Ferreira Costa', 'Guga', '5940392', '98897069500', '1985-03-30', 'Brazilian', 'Cisgender Man', 'Male', 2, 'Software Architect'), -- Professor
    ('Aline', 'Mendes Rocha', 'N/I', '6950403', '09998079699', '1990-10-12', 'Brazilian', 'Cisgender Woman', 'Female', 4, 'UX Designer'), -- Professora
    ('Bruno', 'Carvalho Silva', 'N/I', '7960514', '10099089788', '2002-05-20', 'Brazilian', 'Cisgender Man', 'Male', 6, 'Data Analyst'), -- Aluno
    ('Carla', 'Dias Martins', 'N/I', '8970625', '21100199877', '2003-08-14', 'Brazilian', 'Cisgender Woman', 'Female', 8, 'Student'), -- Aluna BSI
    ('Diego', 'Barbosa Lima', 'N/I', '9980736', '32211209966', '2001-11-28', 'Brazilian', 'Cisgender Man', 'Male', 9, 'DevOps Engineer'), -- Aluno

    -- 23 a 30: Alunos e Técnicos
    ('Eduardo', 'Gomes Ribeiro', 'N/I', '1091827', '43322310055', '2004-01-08', 'Brazilian', 'Cisgender Man', 'Male', 10, 'Student'), -- Aluno
    ('Flávia', 'Nascimento Melo', 'N/I', '2102938', '54433421144', '1998-07-22', 'Brazilian', 'Cisgender Woman', 'Female', 11, 'Administrative Assistant'), -- Staff
    ('Guilherme', 'Araújo Teixeira', 'Gui', '3214049', '65544532233', '1995-09-17', 'Brazilian', 'Cisgender Man', 'Male', 12, 'IT Support'), -- Staff
    ('Helena', 'Cardoso Correia', 'N/I', '4325150', '76655643322', '2002-12-05', 'Brazilian', 'Cisgender Woman', 'Female', 2, 'Student'), -- Aluna
    ('Igor', 'Cavalcanti Moreira', 'N/I', '5436261', '87766754411', '2000-04-19', 'Brazilian', 'Cisgender Man', 'Male', 4, 'Frontend Developer'), -- Aluno
    ('Isabela', 'Freitas Avelar', 'N/I', '6547372', '98877865500', '2003-03-31', 'Brazilian', 'Cisgender Woman', 'Female', 6, 'Student'), -- Aluna
    ('João', 'Pedro Marques', 'JP', '7658483', '09988976699', '2004-08-11', 'Brazilian', 'Cisgender Man', 'Male', 8, 'Student'), -- Aluno
    ('Júlia', 'Kuhn Ramos', 'N/I', '8769594', '11099087788', '2005-02-14', 'Brazilian', 'Cisgender Woman', 'Female', 10, 'Student'), -- Aluna

    -- 31 a 40: Professores e Pesquisadores
    ('Klaus', 'Schneider', 'N/I', '9870605', '22100198877', '1965-06-20', 'German', 'Cisgender Man', 'Male', 12, 'Full Professor'), -- Professor Titular
    ('Laura', 'Fonseca Viana', 'N/I', '1981716', '33211209966', '1982-01-25', 'Brazilian', 'Cisgender Woman', 'Female', 1, 'Researcher'), -- Professora
    ('Leonardo', 'Borges Monteiro', 'Leo', '2092827', '44322310055', '1988-09-09', 'Brazilian', 'Cisgender Man', 'Male', 3, 'Data Scientist'), -- Professor
    ('Letícia', 'Duarte Siqueira', 'N/I', '3103938', '55433421144', '2001-05-16', 'Brazilian', 'Cisgender Woman', 'Female', 5, 'Student'), -- Aluna
    ('Luiz', 'Felipe Castro', 'N/I', '4214049', '66544532233', '2002-10-02', 'Brazilian', 'Cisgender Man', 'Male', 7, 'Student'), -- Aluno
    ('Manuela', 'Resende Guimarães', 'N/I', '5325150', '77655643322', '2004-07-07', 'Brazilian', 'Cisgender Woman', 'Female', 9, 'Student'), -- Aluna
    ('Mateus', 'Pires Maciel', 'N/I', '6436261', '88766754411', '2003-11-21', 'Brazilian', 'Cisgender Man', 'Male', 11, 'Student'), -- Aluno
    ('Natalia', 'Farias Nogueira', 'N/I', '7547372', '99877865500', '1993-04-03', 'Brazilian', 'Cisgender Woman', 'Female', 2, 'Lab Technician'), -- Staff
    ('Otávio', 'Augusto Aguiar', 'N/I', '8658483', '00988976699', '1979-12-18', 'Brazilian', 'Cisgender Man', 'Male', 4, 'Network Administrator'), -- Staff
    ('Patricia', 'Valente Peixoto', 'N/I', '9769594', '12099087788', '1984-08-29', 'Brazilian', 'Cisgender Woman', 'Female', 6, 'Professor'), -- Professora

    -- 41 a 55: Diversos Perfis Acadêmicos
    ('Pedro', 'Henrique Antunes', 'Pedrinho', '1070605', '23100198877', '2005-01-11', 'Brazilian', 'Cisgender Man', 'Male', 8, 'Student'), -- Aluno
    ('Rafael', 'Medeiros Souza', 'N/I', '2181716', '34211209966', '2002-09-04', 'Brazilian', 'Cisgender Man', 'Male', 10, 'Student'), -- Aluno
    ('Rebeca', 'Tavares Franco', 'N/I', '3292827', '45322310055', '2004-03-19', 'Brazilian', 'Cisgender Woman', 'Female', 12, 'Student'), -- Aluna
    ('Rodrigo', 'Chaves Lacerda', 'N/I', '4403938', '56433421144', '1999-06-30', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Backend Developer'), -- Aluno
    ('Sabrina', 'Mendonça Paiva', 'N/I', '5514049', '67544532233', '2003-12-15', 'Brazilian', 'Cisgender Woman', 'Female', 3, 'Student'), -- Aluna
    ('Samuel', 'Xavier Hollanda', 'N/I', '6625150', '78655643322', '2000-02-27', 'Brazilian', 'Cisgender Man', 'Male', 5, 'QA Engineer'), -- Aluno
    ('Tânia', 'Regina Camargo', 'N/I', '7736261', '89766754411', '1973-10-08', 'Brazilian', 'Cisgender Woman', 'Female', 7, 'Librarian'), -- Staff
    ('Thiago', 'Albuquerque Maia', 'N/I', '8847372', '90877865500', '2001-08-24', 'Brazilian', 'Cisgender Man', 'Male', 9, 'Student'), -- Aluno
    ('Vanessa', 'Gimenez Prado', 'N/I', '9958483', '01988976699', '1996-05-17', 'Argentinian', 'Cisgender Woman', 'Female', 11, 'Designer'), -- Aluna
    ('Vinicius', 'Brito Sales', 'Vini', '1069594', '13099087788', '2004-10-09', 'Brazilian', 'Cisgender Man', 'Male', 2, 'Student'), -- Aluno
    ('Yasmin', 'Cunha Assis', 'N/I', '2170605', '24100198877', '2005-05-02', 'Brazilian', 'Cisgender Woman', 'Female', 4, 'Student'), -- Aluna
    ('Yuri', 'Orlovsky', 'N/I', '3281716', '35211209966', '1997-11-13', 'Ukrainian', 'Cisgender Man', 'Male', 6, 'Research Assistant'), -- Aluno
    ('Zulmira', 'Bastos Freitas', 'N/I', '4392827', '46322310055', '1958-04-20', 'Brazilian', 'Cisgender Woman', 'Female', 8, 'Retired Teacher'), -- Aposentada
    ('Arthur', 'Pendelton', 'N/I', '5503938', '57433421144', '1994-01-05', 'American', 'Cisgender Man', 'Male', 10, 'English Lecturer'), -- Professor Extrangeiro
    ('Bianca', 'Vanderlei Ramos', 'N/I', '6614049', '68544532233', '2003-09-18', 'Brazilian', 'Cisgender Woman', 'Female', 12, 'Student'), -- Aluna

    -- 56 a 70: Famílias Secundárias e Mais Alunos
    ('Caio', 'Cesar Marinho', 'N/I', '7725150', '79655643322', '2002-04-14', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Student'), -- Aluno
    ('Daniela', 'Sampaio Luz', 'N/I', '8836261', '90766754411', '1991-07-29', 'Brazilian', 'Cisgender Woman', 'Female', 3, 'Secretary'), -- Staff
    ('Erick', 'Davidson', 'N/I', '9947372', '01877865500', '2001-03-03', 'Canadian', 'Cisgender Man', 'Male', 5, 'Exchange Student'), -- Intercambista
    ('Fabiana', 'Guerra Falcão', 'N/I', '1058483', '12988976699', '1987-09-21', 'Brazilian', 'Cisgender Woman', 'Female', 7, 'Coordinator'), -- Coordenadora
    ('Gabriel', 'Vargas Junqueira', 'N/I', '2169594', '24099087788', '2005-12-11', 'Brazilian', 'Cisgender Man', 'Male', 9, 'Student'), -- Aluno
    ('Giovanna', 'Lins Meireles', 'Gio', '3270605', '35100198877', '2004-06-06', 'Brazilian', 'Cisgender Woman', 'Female', 11, 'Student'), -- Aluna
    ('Heitor', 'Nogueira Porto', 'N/I', '4381716', '46211209966', '1977-02-17', 'Brazilian', 'Cisgender Man', 'Male', 2, 'Professor'), -- Professor
    ('Ingrid', 'Hoffmann', 'N/I', '5492827', '57322310055', '2000-08-30', 'German', 'Cisgender Woman', 'Female', 4, 'Student'), -- Aluna
    ('Jair', 'Bolsonaro Filho', 'N/I', '6603938', '68433421144', '1989-10-25', 'Brazilian', 'Cisgender Man', 'Male', 6, 'Administrative Officer'), -- Staff
    ('Karen', 'Ferreira Schmidt', 'N/I', '7714049', '79544532233', '1995-01-19', 'Brazilian', 'Cisgender Woman', 'Female', 8, 'Biologist'), -- Pesquisadora
    ('Leandro', 'Moraes Sarmento', 'N/I', '8825150', '90655643322', '2003-05-12', 'Brazilian', 'Cisgender Man', 'Male', 10, 'Student'), -- Aluno
    ('Mirella', 'Passos Cordeiro', 'N/I', '9936261', '01766754411', '2004-11-27', 'Brazilian', 'Cisgender Woman', 'Female', 12, 'Student'), -- Aluna
    ('Nicolas', 'Ferreira', 'N/I', '1047372', '12877865500', '2002-07-04', 'Brazilian', 'Cisgender Man', 'Male', 1, 'Student'), -- Aluno
    ('Olívia', 'Sampaio', 'N/I', '2158483', '23988976699', '2005-03-23', 'Brazilian', 'Cisgender Woman', 'Female', 3, 'Student'), -- Aluna
    ('Pablo', 'Escobar Gaviria', 'N/I', '3269594', '35099087788', '1999-09-01', 'Colombian', 'Cisgender Man', 'Male', 5, 'Student'), -- Aluno

    -- 71 a 85: Grupo de TI e Monitoria
    ('Quirino', 'Bastos', 'N/I', '4370605', '46100198877', '1981-05-15', 'Brazilian', 'Cisgender Man', 'Male', 7, 'Database Administrator'), -- DBA Staff
    ('Renata', 'Silveira', 'N/I', '5481716', '57211209966', '1986-11-08', 'Brazilian', 'Cisgender Woman', 'Female', 9, 'System Analyst'), -- Staff
    ('Sergio', 'Ramos', 'N/I', '6592827', '68322310055', '2001-02-14', 'Spanish', 'Cisgender Man', 'Male', 11, 'Student'), -- Aluno
    ('Tatiana', 'Maslany', 'N/I', '7703938', '79433421144', '1993-08-20', 'Canadian', 'Cisgender Woman', 'Female', 2, 'Actress / Student'), -- Aluna
    ('Ubirajara', 'Silva', 'N/I', '8814049', '90544532233', '1969-12-31', 'Brazilian', 'Cisgender Man', 'Male', 4, 'Janitor'), -- Staff
    ('Valéria', 'Almeida', 'N/I', '9925150', '01655643322', '1980-04-10', 'Brazilian', 'Cisgender Woman', 'Female', 6, 'Accountant'), -- Staff
    ('Wagner', 'Moura', 'N/I', '1036261', '12766754411', '1976-06-27', 'Brazilian', 'Cisgender Man', 'Male', 8, 'Drama Teacher'), -- Professor
    ('Ximena', 'Navarrete', 'N/I', '2147372', '23877865500', '1998-02-22', 'Mexican', 'Cisgender Woman', 'Female', 10, 'Student'), -- Aluna
    ('Yago', 'Dornelles', 'N/I', '3258483', '34988976699', '2003-10-05', 'Brazilian', 'Cisgender Man', 'Male', 12, 'Student'), -- Aluno
    ('Zayn', 'Malik', 'N/I', '4369594', '46099087788', '1993-01-12', 'British', 'Cisgender Man', 'Male', 1, 'Musician'), -- Aluno
    ('Alan', 'Turing', 'N/I', '5470605', '57100198877', '1980-06-23', 'British', 'Cisgender Man', 'Male', 3, 'Computer Scientist'), -- Professor
    ('Ada', 'Lovelace', 'N/I', '6581716', '68211209966', '1985-12-10', 'British', 'Cisgender Woman', 'Female', 5, 'Mathematician'), -- Professora
    ('Linus', 'Torvalds', 'N/I', '7692827', '79322310055', '1969-12-28', 'Finnish', 'Cisgender Man', 'Male', 7, 'Kernel Developer'), -- Professor
    ('Grace', 'Hopper', 'N/I', '8803938', '90433421144', '1975-12-09', 'American', 'Cisgender Woman', 'Female', 9, 'Compiler Pioneer'), -- Professora
    ('Dennis', 'Ritchie', 'N/I', '9914049', '01544532233', '1971-09-09', 'American', 'Cisgender Man', 'Male', 11, 'C Creator'), -- Professor

    -- 86 a 100: Último Lote de Alunos e Funcionários
    ('Margaret', 'Hamilton', 'N/I', '1025150', '12655643322', '1978-08-17', 'American', 'Cisgender Woman', 'Female', 2, 'Software Engineer'), -- Professora
    ('Ken', 'Thompson', 'N/I', '2136261', '23766754411', '1973-02-04', 'American', 'Cisgender Man', 'Male', 4, 'Unix Co-Creator'), -- Professor
    ('Tim', 'Berners-Lee', 'N/I', '3247372', '34877865500', '1975-06-08', 'British', 'Cisgender Man', 'Male', 6, 'WWW Inventor'), -- Professor
    ('Guido', 'van Rossum', 'N/I', '4358483', '45988976699', '1976-01-31', 'Dutch', 'Cisgender Man', 'Male', 8, 'Python Creator'), -- Professor
    ('James', 'Gosling', 'N/I', '5469594', '57099087788', '1975-05-19', 'Canadian', 'Cisgender Man', 'Male', 10, 'Java Creator'), -- Professor
    ('Bjarne', 'Stroustrup', 'N/I', '6570605', '68100198877', '1970-12-30', 'Danish', 'Cisgender Man', 'Male', 12, 'C++ Creator'), -- Professor
    ('Donald', 'Knuth', 'N/I', '7681716', '79211209966', '1968-01-10', 'American', 'Cisgender Man', 'Male', 1, 'Algorithmic Master'), -- Professor
    ('Barbara', 'Liskov', 'N/I', '8792827', '90322310055', '1978-11-07', 'American', 'Cisgender Woman', 'Female', 3, 'CS Professor'), -- Professora
    ('Leslie', 'Lamport', 'N/I', '9903938', '01433421144', '1971-02-07', 'American', 'Cisgender Man', 'Male', 5, 'Distributed Systems Specialist'), -- Professor
    ('Edger', 'Dijkstra', 'N/I', '1014049', '12544532233', '1970-05-11', 'Dutch', 'Cisgender Man', 'Male', 7, 'Graph Theorist'), -- Professor
    ('Claude', 'Shannon', 'N/I', '2125150', '23655643322', '1966-04-30', 'American', 'Cisgender Man', 'Male', 9, 'Information Theory Father'), -- Professor
    ('John', 'von Neumann', 'N/I', '3236261', '34766754411', '1963-12-28', 'Hungarian', 'Cisgender Man', 'Male', 11, 'Polymath'), -- Professor
    ('Richard', 'Stallman', 'RMS', '4347372', '45877865500', '1973-03-16', 'American', 'Cisgender Man', 'Male', 2, 'FSF Founder'), -- Professor
    ('Steve', 'Wozniak', 'Woz', '5458483', '56988976699', '1970-08-11', 'American', 'Cisgender Man', 'Male', 4, 'Hardware Engineer'), -- Professor
    ('Satoshi', 'Nakamoto', 'N/I', '6569594', '68099087788', '1975-04-05', 'Japanese', 'Cisgender Man', 'Male', 6, 'Cryptographer'); -- Professor

-- =============================================================================
-- 5. RELAÇÕES FAMILIARES (CORE.DEPENDENT_GUARDIANS)
-- =============================================================================
INSERT INTO CORE.DEPENDENT_GUARDIANS (guardian_id, dependent_id, familiar_bond) VALUES
    -- Família Linhares (Pai Roberto id:3 e Mãe Juliana id:2 -> Aluno Alex id:1)
    (3, 1, 'Father'),
    (2, 1, 'Mother'),
    (3, 4, 'Father'), -- Sophia
    (2, 4, 'Mother'),
    (3, 5, 'Father'), -- Lucas
    (2, 5, 'Mother'),

    -- Família Frozza (Angelo id:6 e Mariana id:7 -> Gabriel id:8 e Beatriz id:9)
    (6, 8, 'Father'),
    (7, 8, 'Mother'),
    (6, 9, 'Father'),
    (7, 9, 'Mother'),

    -- Família Oliveira (Carlos id:10 e Fernanda id:11 -> Henrique id:12 e Larissa id:13)
    (10, 12, 'Father'),
    (11, 12, 'Mother'),
    (10, 13, 'Father'),
    (11, 13, 'Mother'),

    -- Família Santos (Marcelo id:14 e Camila id:15 -> Enzo id:16 e Valentina id:17)
    (14, 16, 'Father'),
    (15, 16, 'Mother'),
    (14, 17, 'Father'),
    (15, 17, 'Mother');

-- ---------------------------- INSERINDO CURSOS ---------------------------------------

INSERT INTO ACADEMIC.PROGRAMS (
    code,
    description,
    name,
    total_workload,
    complementary_hours,
    pedagogical_project,
    accreditation_score,
    department_id,
    coordinator_id,
    status,
    educational_level,
    qualification_tier) VALUES



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
    ('Semester', 2, '[2026-08-03,2026-12-06)', 3);


UPDATE ACADEMIC.PERIODS SET predecessor_period_id = 1 WHERE id = 4;

-- ------------------------------ INSERINDO UMA TURMA ------------------------------------

SELECT * FROM ACADEMIC.CLASS_OFFERINGS;

INSERT INTO ACADEMIC.CLASS_OFFERINGS (code, academic_period_id) VALUES
    ('BSI25', 1);

INSERT INTO ACADEMIC.CLASS_OFFERINGS (code, academic_period_id) VALUES
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


