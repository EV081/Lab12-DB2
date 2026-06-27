-- worker1: tablas y datos
-- docker exec -i pg_worker1 psql -U postgres

CREATE TABLE IF NOT EXISTS AtencionMedica_Obesidad (
    DNI              CHAR(8),
    CodMedico        INTEGER      NOT NULL,
    Ciudad           VARCHAR(50)  NOT NULL,
    Diagnostico      VARCHAR(50)  NOT NULL,
    Peso             DECIMAL(5,2) NOT NULL,
    Talla            DECIMAL(4,2) NOT NULL,
    PresionArterial  VARCHAR(10)  NOT NULL,
    Edad             INTEGER      NOT NULL CHECK (Edad >= 0),
    FechaAtencion    DATE         NOT NULL
);

CREATE TABLE IF NOT EXISTS AtencionMedica_Cardiopatia
    (LIKE AtencionMedica_Obesidad INCLUDING ALL);

INSERT INTO AtencionMedica_Obesidad
    (DNI, CodMedico, Ciudad, Diagnostico, Peso, Talla, PresionArterial, Edad, FechaAtencion)
SELECT
    LPAD(((random()*49999)::int+1)::text, 8, '0'),
    (random()*199+1)::int,
    (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',
           'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa','Juliaca',
           'Ica','Ayacucho','Huaraz','Tumbes','Moquegua','Chimbote'])[(random()*17+1)::int],
    'Obesidad',
    (random()*60+40)::numeric(5,2),
    (random()*0.60+1.40)::numeric(4,2),
    ((random()*60+90)::int)||'/'||((random()*40+60)::int),
    (random()*95)::int,
    DATE '2024-01-01' + ((random()*730)::int)
FROM generate_series(1, 15000);

INSERT INTO AtencionMedica_Cardiopatia
    (DNI, CodMedico, Ciudad, Diagnostico, Peso, Talla, PresionArterial, Edad, FechaAtencion)
SELECT
    LPAD(((random()*49999)::int+1)::text, 8, '0'),
    (random()*199+1)::int,
    (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',
           'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa','Juliaca',
           'Ica','Ayacucho','Huaraz','Tumbes','Moquegua','Chimbote'])[(random()*17+1)::int],
    'Cardiopatía',
    (random()*60+40)::numeric(5,2),
    (random()*0.60+1.40)::numeric(4,2),
    ((random()*60+90)::int)||'/'||((random()*40+60)::int),
    (random()*95)::int,
    DATE '2024-01-01' + ((random()*730)::int)
FROM generate_series(1, 15000);

CREATE TABLE IF NOT EXISTS Pacientes_F2 (
    DNI              CHAR(8),
    Nombre           VARCHAR(50)  NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    FechaNacimiento  DATE         NOT NULL,
    Sexo             CHAR(1)      NOT NULL CHECK (Sexo IN ('M','F')),
    CiudadOrigen     VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DNI, CiudadOrigen)
);

INSERT INTO Pacientes_F2 (DNI, Nombre, Apellidos, FechaNacimiento, Sexo, CiudadOrigen)
SELECT
    LPAD(g::text, 8, '0'),
    (ARRAY['Juan','Maria','Carlos','Ana','Luis','Sofia','Pedro','Lucia',
           'Diego','Camila','Jorge','Valeria','Andres','Daniela','Miguel',
           'Fernanda','Ricardo','Patricia','Roberto','Gabriela'])[(random()*19+1)::int],
    (ARRAY['Garcia','Rodriguez','Lopez','Martinez','Perez','Gonzalez',
           'Sanchez','Ramirez','Torres','Flores','Rivera','Vargas',
           'Castillo','Romero','Morales','Ortiz','Gutierrez','Chavez',
           'Mendoza','Aguilar'])[(random()*19+1)::int],
    DATE '1940-01-01' + ((random()*30000)::int),
    (ARRAY['M','F'])[(random()*1+1)::int],
    (ARRAY['Huancayo','Huaraz','Ica','Iquitos','Juliaca','Lima','Moquegua'])[(random()*6+1)::int]
FROM generate_series(20001, 40000) g;


-- worker2: tablas y datos
-- docker exec -i pg_worker2 psql -U postgres

CREATE TABLE IF NOT EXISTS AtencionMedica_Hipertension (
    DNI              CHAR(8),
    CodMedico        INTEGER      NOT NULL,
    Ciudad           VARCHAR(50)  NOT NULL,
    Diagnostico      VARCHAR(50)  NOT NULL,
    Peso             DECIMAL(5,2) NOT NULL,
    Talla            DECIMAL(4,2) NOT NULL,
    PresionArterial  VARCHAR(10)  NOT NULL,
    Edad             INTEGER      NOT NULL CHECK (Edad >= 0),
    FechaAtencion    DATE         NOT NULL
);

INSERT INTO AtencionMedica_Hipertension
    (DNI, CodMedico, Ciudad, Diagnostico, Peso, Talla, PresionArterial, Edad, FechaAtencion)
SELECT
    LPAD(((random()*49999)::int+1)::text, 8, '0'),
    (random()*199+1)::int,
    (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',
           'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa','Juliaca',
           'Ica','Ayacucho','Huaraz','Tumbes','Moquegua','Chimbote'])[(random()*17+1)::int],
    'Hipertensión',
    (random()*60+40)::numeric(5,2),
    (random()*0.60+1.40)::numeric(4,2),
    ((random()*60+90)::int)||'/'||((random()*40+60)::int),
    (random()*95)::int,
    DATE '2024-01-01' + ((random()*730)::int)
FROM generate_series(1, 15000);

CREATE TABLE IF NOT EXISTS Pacientes_F3 (
    DNI              CHAR(8),
    Nombre           VARCHAR(50)  NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    FechaNacimiento  DATE         NOT NULL,
    Sexo             CHAR(1)      NOT NULL CHECK (Sexo IN ('M','F')),
    CiudadOrigen     VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DNI, CiudadOrigen)
);

INSERT INTO Pacientes_F3 (DNI, Nombre, Apellidos, FechaNacimiento, Sexo, CiudadOrigen)
SELECT
    LPAD(g::text, 8, '0'),
    (ARRAY['Juan','Maria','Carlos','Ana','Luis','Sofia','Pedro','Lucia',
           'Diego','Camila','Jorge','Valeria','Andres','Daniela','Miguel',
           'Fernanda','Ricardo','Patricia','Roberto','Gabriela'])[(random()*19+1)::int],
    (ARRAY['Garcia','Rodriguez','Lopez','Martinez','Perez','Gonzalez',
           'Sanchez','Ramirez','Torres','Flores','Rivera','Vargas',
           'Castillo','Romero','Morales','Ortiz','Gutierrez','Chavez',
           'Mendoza','Aguilar'])[(random()*19+1)::int],
    DATE '1940-01-01' + ((random()*30000)::int),
    (ARRAY['M','F'])[(random()*1+1)::int],
    (ARRAY['Piura','Pucallpa','Tacna','Trujillo','Tumbes'])[(random()*4+1)::int]
FROM generate_series(40001, 60000) g;


-- master: tablas locales + fdw + foreign tables
-- docker exec -i pg_master psql -U postgres

CREATE TABLE IF NOT EXISTS AtencionMedica_Diabetes (
    DNI              CHAR(8),
    CodMedico        INTEGER      NOT NULL,
    Ciudad           VARCHAR(50)  NOT NULL,
    Diagnostico      VARCHAR(50)  NOT NULL,
    Peso             DECIMAL(5,2) NOT NULL,
    Talla            DECIMAL(4,2) NOT NULL,
    PresionArterial  VARCHAR(10)  NOT NULL,
    Edad             INTEGER      NOT NULL CHECK (Edad >= 0),
    FechaAtencion    DATE         NOT NULL
);

INSERT INTO AtencionMedica_Diabetes
    (DNI, CodMedico, Ciudad, Diagnostico, Peso, Talla, PresionArterial, Edad, FechaAtencion)
SELECT
    LPAD(((random()*49999)::int+1)::text, 8, '0'),
    (random()*199+1)::int,
    (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',
           'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa','Juliaca',
           'Ica','Ayacucho','Huaraz','Tumbes','Moquegua','Chimbote'])[(random()*17+1)::int],
    'Diabetes',
    (random()*60+40)::numeric(5,2),
    (random()*0.60+1.40)::numeric(4,2),
    ((random()*60+90)::int)||'/'||((random()*40+60)::int),
    (random()*95)::int,
    DATE '2024-01-01' + ((random()*730)::int)
FROM generate_series(1, 15000);

CREATE TABLE IF NOT EXISTS Pacientes_F1 (
    DNI              CHAR(8),
    Nombre           VARCHAR(50)  NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    FechaNacimiento  DATE         NOT NULL,
    Sexo             CHAR(1)      NOT NULL CHECK (Sexo IN ('M','F')),
    CiudadOrigen     VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DNI, CiudadOrigen)
);

INSERT INTO Pacientes_F1 (DNI, Nombre, Apellidos, FechaNacimiento, Sexo, CiudadOrigen)
SELECT
    LPAD(g::text, 8, '0'),
    (ARRAY['Juan','Maria','Carlos','Ana','Luis','Sofia','Pedro','Lucia',
           'Diego','Camila','Jorge','Valeria','Andres','Daniela','Miguel',
           'Fernanda','Ricardo','Patricia','Roberto','Gabriela'])[(random()*19+1)::int],
    (ARRAY['Garcia','Rodriguez','Lopez','Martinez','Perez','Gonzalez',
           'Sanchez','Ramirez','Torres','Flores','Rivera','Vargas',
           'Castillo','Romero','Morales','Ortiz','Gutierrez','Chavez',
           'Mendoza','Aguilar'])[(random()*19+1)::int],
    DATE '1940-01-01' + ((random()*30000)::int),
    (ARRAY['M','F'])[(random()*1+1)::int],
    (ARRAY['Arequipa','Ayacucho','Callao','Chiclayo','Chimbote','Cusco'])[(random()*5+1)::int]
FROM generate_series(1, 20000) g;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER IF NOT EXISTS worker1
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'pg_worker1', port '5432', dbname 'postgres');

CREATE SERVER IF NOT EXISTS worker2
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'pg_worker2', port '5432', dbname 'postgres');

CREATE USER MAPPING IF NOT EXISTS FOR postgres SERVER worker1
    OPTIONS (user 'postgres', password 'pass');

CREATE USER MAPPING IF NOT EXISTS FOR postgres SERVER worker2
    OPTIONS (user 'postgres', password 'pass');

CREATE FOREIGN TABLE IF NOT EXISTS AtencionMedica_Obesidad_fdw (
    DNI CHAR(8), CodMedico INTEGER, Ciudad VARCHAR(50),
    Diagnostico VARCHAR(50), Peso DECIMAL(5,2), Talla DECIMAL(4,2),
    PresionArterial VARCHAR(10), Edad INTEGER, FechaAtencion DATE
) SERVER worker1 OPTIONS (table_name 'atencionmedica_obesidad');

CREATE FOREIGN TABLE IF NOT EXISTS AtencionMedica_Cardiopatia_fdw (
    DNI CHAR(8), CodMedico INTEGER, Ciudad VARCHAR(50),
    Diagnostico VARCHAR(50), Peso DECIMAL(5,2), Talla DECIMAL(4,2),
    PresionArterial VARCHAR(10), Edad INTEGER, FechaAtencion DATE
) SERVER worker1 OPTIONS (table_name 'atencionmedica_cardiopatia');

CREATE FOREIGN TABLE IF NOT EXISTS AtencionMedica_Hipertension_fdw (
    DNI CHAR(8), CodMedico INTEGER, Ciudad VARCHAR(50),
    Diagnostico VARCHAR(50), Peso DECIMAL(5,2), Talla DECIMAL(4,2),
    PresionArterial VARCHAR(10), Edad INTEGER, FechaAtencion DATE
) SERVER worker2 OPTIONS (table_name 'atencionmedica_hipertension');

CREATE FOREIGN TABLE IF NOT EXISTS Pacientes_F2_fdw (
    DNI CHAR(8), Nombre VARCHAR(50), Apellidos VARCHAR(100),
    FechaNacimiento DATE, Sexo CHAR(1), CiudadOrigen VARCHAR(50)
) SERVER worker1 OPTIONS (table_name 'pacientes_f2');

CREATE FOREIGN TABLE IF NOT EXISTS Pacientes_F3_fdw (
    DNI CHAR(8), Nombre VARCHAR(50), Apellidos VARCHAR(100),
    FechaNacimiento DATE, Sexo CHAR(1), CiudadOrigen VARCHAR(50)
) SERVER worker2 OPTIONS (table_name 'pacientes_f3');


-- queries (master)

-- Q1
BEGIN;
CREATE TEMP TABLE r1 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F1 ORDER BY FechaNacimiento;
CREATE TEMP TABLE r2 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F2_fdw ORDER BY FechaNacimiento;
CREATE TEMP TABLE r3 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F3_fdw ORDER BY FechaNacimiento;
EXPLAIN ANALYZE
SELECT * FROM (
    SELECT * FROM r1
    UNION ALL SELECT * FROM r2
    UNION ALL SELECT * FROM r3
) m ORDER BY FechaNacimiento;
COMMIT;


-- Q2
BEGIN;
CREATE TEMP TABLE r1 ON COMMIT DROP AS
    SELECT DISTINCT CiudadOrigen FROM Pacientes_F1;
CREATE TEMP TABLE r2 ON COMMIT DROP AS
    SELECT DISTINCT CiudadOrigen FROM Pacientes_F2_fdw;
CREATE TEMP TABLE r3 ON COMMIT DROP AS
    SELECT DISTINCT CiudadOrigen FROM Pacientes_F3_fdw;
EXPLAIN ANALYZE
SELECT CiudadOrigen FROM r1
UNION ALL SELECT CiudadOrigen FROM r2
UNION ALL SELECT CiudadOrigen FROM r3;
COMMIT;


-- Q3
BEGIN;
CREATE TEMP TABLE r1 ON COMMIT DROP AS
    SELECT Diagnostico, AVG(Edad) AS PromEdad
    FROM AtencionMedica_Diabetes GROUP BY Diagnostico;
CREATE TEMP TABLE r2 ON COMMIT DROP AS
    SELECT Diagnostico, AVG(Edad) AS PromEdad
    FROM AtencionMedica_Obesidad_fdw GROUP BY Diagnostico;
CREATE TEMP TABLE r3 ON COMMIT DROP AS
    SELECT Diagnostico, AVG(Edad) AS PromEdad
    FROM AtencionMedica_Cardiopatia_fdw GROUP BY Diagnostico;
CREATE TEMP TABLE r4 ON COMMIT DROP AS
    SELECT Diagnostico, AVG(Edad) AS PromEdad
    FROM AtencionMedica_Hipertension_fdw GROUP BY Diagnostico;
EXPLAIN ANALYZE
SELECT * FROM r1
UNION ALL SELECT * FROM r2
UNION ALL SELECT * FROM r3
UNION ALL SELECT * FROM r4;
COMMIT;


-- Q4
BEGIN;
CREATE TEMP TABLE dni_a1 ON COMMIT DROP AS
    SELECT DISTINCT DNI FROM AtencionMedica_Diabetes;
CREATE TEMP TABLE dni_a2 ON COMMIT DROP AS
    SELECT DISTINCT DNI FROM AtencionMedica_Obesidad_fdw;
CREATE TEMP TABLE dni_a3 ON COMMIT DROP AS
    SELECT DISTINCT DNI FROM AtencionMedica_Cardiopatia_fdw;
CREATE TEMP TABLE dni_a4 ON COMMIT DROP AS
    SELECT DISTINCT DNI FROM AtencionMedica_Hipertension_fdw;
CREATE TEMP TABLE dni_atencion ON COMMIT DROP AS
    SELECT DNI FROM dni_a1
    UNION SELECT DNI FROM dni_a2
    UNION SELECT DNI FROM dni_a3
    UNION SELECT DNI FROM dni_a4;
CREATE TEMP TABLE p_filt_1 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F1
    WHERE DNI IN (SELECT DNI FROM dni_atencion);
CREATE TEMP TABLE p_filt_2 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F2_fdw
    WHERE DNI IN (SELECT DNI FROM dni_atencion);
CREATE TEMP TABLE p_filt_3 ON COMMIT DROP AS
    SELECT * FROM Pacientes_F3_fdw
    WHERE DNI IN (SELECT DNI FROM dni_atencion);
CREATE TEMP TABLE p_reduced ON COMMIT DROP AS
    SELECT * FROM p_filt_1
    UNION ALL SELECT * FROM p_filt_2
    UNION ALL SELECT * FROM p_filt_3;
CREATE TEMP TABLE atencion_completa ON COMMIT DROP AS
    SELECT * FROM AtencionMedica_Diabetes
    UNION ALL SELECT * FROM AtencionMedica_Obesidad_fdw
    UNION ALL SELECT * FROM AtencionMedica_Cardiopatia_fdw
    UNION ALL SELECT * FROM AtencionMedica_Hipertension_fdw;
EXPLAIN ANALYZE
SELECT * FROM p_reduced JOIN atencion_completa USING (DNI);
COMMIT;
