
/*
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
) m
ORDER BY FechaNacimiento;
*/


/*
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
*/

/*
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
*/




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


