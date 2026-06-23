# Laboratorio 13: Fragmentación Dinámica, Asignación y Consultas Distribuidas
## P1. Creación de particiones

Creamos la tabla AtencionMedica con la partición por el atributo 'Diagnostico'

``` postgres
CREATE TABLE AtencionMedica (
    DNI CHAR(8),
    CodMedico INTEGER NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Diagnostico VARCHAR(50) NOT NULL,
    Peso DECIMAL(5,2) NOT NULL,
    Talla DECIMAL(4,2) NOT NULL,
    PresionArterial VARCHAR(10) NOT NULL,
    Edad INTEGER NOT NULL CHECK (Edad >= 0),
    FechaAtencion DATE NOT NULL
) PARTITION BY LIST (Diagnostico);
```
![alt text](./img/image.png)

Creamos las particiones por los diferentes tipos de diagnósticos.

``` postgres
CREATE TABLE AtencionMedica_Diabetes                                                     
  PARTITION OF AtencionMedica                                                         
  FOR VALUES IN ('Diabetes');
                                                                              
CREATE TABLE AtencionMedica_Obesidad
    PARTITION OF AtencionMedica                                                          
    FOR VALUES IN ('Obesidad');                                                         

CREATE TABLE AtencionMedica_Cardiopatia                                                  
    PARTITION OF AtencionMedica
    FOR VALUES IN ('Cardiopatía');                                                        
                                                                            
CREATE TABLE AtencionMedica_Hipertension                                                
    PARTITION OF AtencionMedica
    FOR VALUES IN ('Hipertensión');                                                       
```                                     
![alt text](./img/image1.png)

Llenamos la tabla con 60k registros sinteticos:

``` postgres
INSERT INTO AtencionMedica
  (DNI, CodMedico, Ciudad, Diagnostico, Peso, Talla, PresionArterial, Edad, FechaAtencion)                                                                            
SELECT
  LPAD(((random() * 49999)::int + 1)::text, 8, '0')                     AS DNI,         
  (random() * 199 + 1)::int                                             AS CodMedico,   
  (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',                         
		 'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa','Juliaca',                  
		 'Ica','Ayacucho','Huaraz','Tumbes','Moquegua','Chimbote'])                     
	  [ (random() * 17 + 1)::int ]                                      AS Ciudad,      
  (ARRAY['Diabetes','Obesidad','Cardiopatía','Hipertensión'])                           
	  [ (random() * 3 + 1)::int ]                                       AS Diagnostico, 
  (random() * 60 + 40)::numeric(5,2)                                    AS Peso,                                                                       
  (random() * 0.60 + 1.40)::numeric(4,2)                                AS Talla,                                                            
  ((random() * 60 + 90)::int) || '/' || ((random() * 40 + 60)::int)     AS PresionArterial,                                                   
  (random() * 95)::int                                                  AS Edad,
  DATE '2024-01-01' + ((random() * 730)::int)                           AS FechaAtencion                                                                         
FROM generate_series(1, 60000);                             
```     
![alt text](./img/image2.png)

Verificamos:

![alt text](./img/image3.png)


## P2

## P3

## P4.  Algoritmos distribuidos localmente

Primero creamos la tabla Pacientes, con la partition por range de 'CiudadOrigen':

``` postgres
CREATE TABLE Pacientes (
    DNI CHAR(8),
    Nombre VARCHAR(50) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M', 'F')),
    CiudadOrigen VARCHAR(50) NOT NULL,
    PRIMARY KEY (DNI, CiudadOrigen)
) PARTITION BY RANGE (CiudadOrigen);
```
![alt text](./img/image4.png)

Creamos las particiones por rango del vector ["H", "P"]

``` postgres
CREATE TABLE Pacientes_F1 PARTITION OF Pacientes                                          
    FOR VALUES FROM (MINVALUE) TO ('H');

CREATE TABLE Pacientes_F2 PARTITION OF Pacientes                                          
    FOR VALUES FROM ('H') TO ('P');
                                                                            
CREATE TABLE Pacientes_F3 PARTITION OF Pacientes                                          
    FOR VALUES FROM ('P') TO (MAXVALUE);       
```
![alt text](./img/image5.png)

El enunciado dice DNI CHAR(8) PRIMARY KEY, pero PostgreSQL exige que toda PK/UNIQUE en una tabla particionada incluya las columnas de partición. Por eso uso PRIMARY KEY (DNI, CiudadOrigen).

Ahora poblamos la tabla con registros sinteticos: 

``` postgres
INSERT INTO Pacientes (DNI, Nombre, Apellidos, FechaNacimiento, Sexo, CiudadOrigen)
SELECT                                                                                    
    LPAD(g::text, 8, '0')                                          AS DNI,
    (ARRAY['Juan','Maria','Carlos','Ana','Luis','Sofia','Pedro',                          
            'Lucia','Diego','Camila','Jorge','Valeria','Andres',
            'Daniela','Miguel','Fernanda','Ricardo','Patricia',                            
            'Roberto','Gabriela'])[(random()*19+1)::int]            AS Nombre,
    (ARRAY['Garcia','Rodriguez','Lopez','Martinez','Perez',                               
            'Gonzalez','Sanchez','Ramirez','Torres','Flores',                              
            'Rivera','Vargas','Castillo','Romero','Morales',                               
            'Ortiz','Gutierrez','Chavez','Mendoza','Aguilar'])                             
        [(random()*19+1)::int]                                     AS Apellidos,
    DATE '1940-01-01' + ((random()*30000)::int)                    AS FechaNacimiento,    
    (ARRAY['M','F'])[(random()*1+1)::int]                          AS Sexo,
    (ARRAY['Lima','Callao','Arequipa','Cusco','Trujillo','Piura',                         
            'Chiclayo','Iquitos','Huancayo','Tacna','Pucallpa',
            'Juliaca','Ica','Ayacucho','Huaraz','Tumbes',                                  
            'Moquegua','Chimbote'])[(random()*17+1)::int]           AS CiudadOrigen        
FROM generate_series(1, 60000) g;     
```
![alt text](./img/image6.png)

### Q1. SELECT * FROM Pacientes ORDER BY FechaNacimiento
``` postgres  
-- R1: filas de Pacientes_F1 ordenadas localmente por FechaNacimiento       
CREATE TEMP TABLE r1 ON COMMIT DROP AS
SELECT * FROM Pacientes_F1 ORDER BY FechaNacimiento;                                      
                                                                              
-- R2: filas de Pacientes_F2 ordenadas localmente
CREATE TEMP TABLE r2 ON COMMIT DROP AS                                                    
SELECT * FROM Pacientes_F2 ORDER BY FechaNacimiento;                                      

-- R3: filas de Pacientes_F3 ordenadas localment                           
CREATE TEMP TABLE r3 ON COMMIT DROP AS
SELECT * FROM Pacientes_F3 ORDER BY FechaNacimiento;                                      
                                                                   
-- Merge de R1, R2, R3 en el master        
EXPLAIN ANALYZE                                                                           
SELECT * FROM (
	SELECT * FROM r1
	UNION ALL SELECT * FROM r2
	UNION ALL SELECT * FROM r3
) m                                                                            
ORDER BY FechaNacimiento;  
```

![alt text](./img/image10.png)

### Q2. SELECT DISTINCT CiudadOrigen FROM Pacientes
``` postgres
-- R1: ciudades distintas en F1 < 'H'
CREATE TEMP TABLE r1 ON COMMIT DROP AS                                                    
SELECT DISTINCT CiudadOrigen FROM Pacientes_F1;                                           

-- R2: ciudades distintas en F2 'H'<..< 'P'                                             
CREATE TEMP TABLE r2 ON COMMIT DROP AS
SELECT DISTINCT CiudadOrigen FROM Pacientes_F2;                                           
																						
-- R3: ciudades distintas en F3 'P'>
CREATE TEMP TABLE r3 ON COMMIT DROP AS                                                    
SELECT DISTINCT CiudadOrigen FROM Pacientes_F3;                                           

-- Union All  
EXPLAIN ANALYZE 
SELECT CiudadOrigen FROM r1                                                               
UNION ALL SELECT CiudadOrigen FROM r2                                                     
UNION ALL SELECT CiudadOrigen FROM r3;
```
![alt text](./img/image7.png)

### Q3. SELECT Diagnostico, AVG(Edad) AS PromEdad FROM AtencionMedica GROUP BY Diagnostico
``` postgres
-- R1: prom. edad para Diabetes (sitio: F1) → 1 fila                                      
CREATE TEMP TABLE r1 ON COMMIT DROP AS
SELECT Diagnostico, AVG(Edad) AS PromEdad                                                 
FROM AtencionMedica_Diabetes GROUP BY Diagnostico;
																						
-- R2: prom. edad para Obesidad (sitio: F2) → 1 fila
CREATE TEMP TABLE r2 ON COMMIT DROP AS                                                    
SELECT Diagnostico, AVG(Edad) AS PromEdad                                                 
FROM AtencionMedica_Obesidad GROUP BY Diagnostico;
																						
-- R3: prom. edad para Cardiopatía 
CREATE TEMP TABLE r3 ON COMMIT DROP AS                                                    
SELECT Diagnostico, AVG(Edad) AS PromEdad                                                 
FROM AtencionMedica_Cardiopatia GROUP BY Diagnostico;
																						
-- R4: prom. edad para Hipertensión
CREATE TEMP TABLE r4 ON COMMIT DROP AS                                                    
SELECT Diagnostico, AVG(Edad) AS PromEdad                                                 
FROM AtencionMedica_Hipertension GROUP BY Diagnostico;
																						
-- UNION ALL (los grupos no se solapan entre fragmentos).                                  
EXPLAIN ANALYZE                                                                           
SELECT * FROM r1                                                                          
UNION ALL SELECT * FROM r2                                                                
UNION ALL SELECT * FROM r3
UNION ALL SELECT * FROM r4;   
```
![alt text](./img/image8.png)

### Q4. SELECT * FROM Pacientes NATURAL JOIN AtencionMedica
``` postgres
-- Proyecció local de DNI en cada fragmento de AtencionMedica.                     
CREATE TEMP TABLE dni_a1 ON COMMIT DROP AS SELECT DISTINCT DNI FROM                       
AtencionMedica_Diabetes;                                                                  
CREATE TEMP TABLE dni_a2 ON COMMIT DROP AS SELECT DISTINCT DNI FROM                       
AtencionMedica_Obesidad;                                                                  
CREATE TEMP TABLE dni_a3 ON COMMIT DROP AS SELECT DISTINCT DNI FROM
AtencionMedica_Cardiopatia;                                                               
CREATE TEMP TABLE dni_a4 ON COMMIT DROP AS SELECT DISTINCT DNI FROM
AtencionMedica_Hipertension;                                                              
			  
-- Unión de DNIs a enviar al lado de Pacientes                                    
CREATE TEMP TABLE dni_atencion ON COMMIT DROP AS
SELECT DNI FROM dni_a1                                                                    
UNION SELECT DNI FROM dni_a2
UNION SELECT DNI FROM dni_a3                                                              
UNION SELECT DNI FROM dni_a4;
																						
-- Semi-join local en cada fragmento de Pacientes                                 
CREATE TEMP TABLE p_filt_1 ON COMMIT DROP AS                                              
SELECT p.* FROM Pacientes_F1 p WHERE p.DNI IN (SELECT DNI FROM dni_atencion);
																						
CREATE TEMP TABLE p_filt_2 ON COMMIT DROP AS                                              
SELECT p.* FROM Pacientes_F2 p WHERE p.DNI IN (SELECT DNI FROM dni_atencion);             
																						
CREATE TEMP TABLE p_filt_3 ON COMMIT DROP AS
SELECT p.* FROM Pacientes_F3 p WHERE p.DNI IN (SELECT DNI FROM dni_atencion);             
																						
-- Unión deL lado izquierdo del join ya reducido                         
CREATE TEMP TABLE p_reduced ON COMMIT DROP AS                                             
SELECT * FROM p_filt_1                                                                    
UNION ALL SELECT * FROM p_filt_2
UNION ALL SELECT * FROM p_filt_3;                                                         

-- Join final en el coordinador con AtencionMedica completa                                                         
EXPLAIN ANALYZE 
SELECT * FROM p_reduced NATURAL JOIN AtencionMedica;      
```
![alt text](./img/image9.png)

## Explicación de Resultados                                                                   

  ### Q1 — `SELECT * FROM Pacientes ORDER BY FechaNacimiento`                               
   
  **Plan**:                                                                 
  - `Append` recorre las tres temp tables locales (`r1`, `r2`, `r3`) ya ordenadas en sus respectivos fragmentos: **19 245 + 22 910 + 17 845 = 60 000 filas**.
  - En el coordinador se aplica un `Sort` final con **`Sort Method: external merge`** (`Disk: 2864 kB`), reflejando el k-way merge clásico del algoritmo distribuido.                            
  - **Execution Time = 14.18 ms**.                            
                                                                                            
  Observación: el desbalance entre fragmentos (F2 tiene más filas porque concentra Lima, Ica, Iquitos, Juliaca, Huancayo, etc.) es esperado por la fragmentación lexicográfica.
                                                                                            
  ### Q2 — `SELECT DISTINCT CiudadOrigen FROM Pacientes`
                                                                                            
  **Plan**:
  - `Append` sobre `r1` (6 filas), `r2` (7 filas), `r3` (5 filas) = **18 ciudades distintas**.                                                                              
  - `Seq Scan` simple en cada temp table; no requiere re-deduplicación porque la fragmentación por `CiudadOrigen` garantiza que cada ciudad vive en un único fragmento, entonces solo basta `UNION ALL`.                                                                                     
  - **Execution Time = 0.012 ms**.
                                                                                            
  Esta consulta evidencia la mejor optimización posible: el atributo del `DISTINCT` coincide con la clave de partición, así que **no hay solapamiento entre fragmentos** y el coordinador solo concatena resultados parciales pequeños.                                                  
                  
  ### Q3 — `SELECT Diagnostico, AVG(Edad) GROUP BY Diagnostico`                             
                                                                                            
  **Plan**:
  - `Append` sobre `r1`, `r2`, `r3`, `r4`, cada una con **exactamente 1 fila** = **4 filas finales**.                                                                                
  - Cada `Seq Scan` opera sobre un fragmento que contiene **un único valor de `Diagnostico`**, el `AVG(Edad)` local ya es la respuesta final para ese grupo.
  - **Execution Time = 0.011 ms**.                                                          
                                                                                            
  Aquí se aprovecha que `GROUP BY` coincide con la clave de partición, no se necesita re-agregar. Si la columna del `GROUP BY` no fuera la de partición, habría que mover `SUM(Edad)` y `COUNT(*)` al coordinador y calcular `AVG = SUM_total / COUNT_total`.
                                                                                            
  ### Q4 — `SELECT * FROM Pacientes NATURAL JOIN AtencionMedica`
                                                                                            
  **Plan**:
  - La clave del join (`DNI`) no coincide con ninguna clave de partición de las dos tablas, 
  por lo que se requiere el **semi-join** implementado en la query:                              
    1. Proyección local `πDNI` en cada uno de los 4 fragmentos de `AtencionMedica`                                                                            
    2. Unión deduplicada -> `dni_atencion` (DNIs únicos enviados al lado de Pacientes).
    3. Semi-join local en cada fragmento de `Pacientes`, filtra los pacientes que tienen al menos una atención registrada.                                             
    4. Unión del lado izquierdo reducido (`p_reduced`) y join final contra `AtencionMedica`.
  - El semi-join reduce el tráfico al coordinador: en lugar de enviar tuplas completas de Pacientes, primero se filtra por la lista de DNIs presentes en atenciones.                         
                                                                                            
  Comparado con un `NATURAL JOIN` ingenuo sobre las tablas particionadas completas, el 
  algoritmo distribuido evidencia claramente las 4 fases (proyección, envío, semi-join, join final) y demuestra el principio de "mover poco dato, no relaciones enteras".
                                                                                            
  ---             
                                                                                            
  ### Conclusiones

  - **Q2 y Q3** son los casos óptimos: la clave de la operación (DISTINCT / GROUP BY) 
  coincide con la clave de partición.
  - **Q1** requiere merge porque ningún fragmento conoce el orden global, pero al menos cada
    fragmento entrega sus filas ya ordenadas (sort paralelo).                               
  - **Q4** es el caso más caro porque la clave del join (`DNI`) no está alineada con ninguna
    fragmentación, justificando la optimización por semi-join.                              
  - Los tiempos de Q2 y Q3 son sub-milisegundo porque las temp tables intermedias son       
  diminutas (18 y 4 filas respectivamente).