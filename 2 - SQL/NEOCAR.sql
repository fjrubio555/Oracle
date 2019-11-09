SET TERMOUT OFF
SET ECHO OFF
-- Otorgamos al usario NEOCAR los privilegios del sistema (conexión, recursos, dba, y tablespaces ilimitado) y le asignamos la contraseña. 
GRANT CONNECT,RESOURCE,DBA,UNLIMITED TABLESPACE TO NEOCAR IDENTIFIED BY NEOCAR;
-- Modificamos el usuario NEOCAR le indicando cual va a ser su tablespaces por defecto y el temporal.
ALTER USER NEOCAR DEFAULT TABLESPACE USERS;
ALTER USER NEOCAR TEMPORARY TABLESPACE TEMP;
-- Conectamos el Usuario.
CONNECT NEOCAR/NEOCAR

--Borramos la tabla vehículos independientemente de la existencia de dependencias relacionales con otras tablas y/o restriciones.
DROP TABLE VEHICULOS CASCADE CONSTRAINTS;
-- 2.1 Creamos la tabla VEHICULOS con sus restriciones e insertamos sus valores.
CREATE TABLE VEHICULOS ( 
  Matricula     VARCHAR2(7)   CONSTRAINT PK_Vehiculos PRIMARY KEY,
  Marca         VARCHAR2(10)  CONSTRAINT Marca_NN NOT NULL,
  Modelo        VARCHAR2(10)  CONSTRAINT Modelo_NN NOT NULL,
  FechaCompra   DATE          CONSTRAINT FechaBuena CHECK (TO_CHAR(FechaCompra,'YYYY')>=2001),          
  PrecioDia     NUMBER(5,2)   CONSTRAINT PrecioPositivo CHECK (PrecioDia > 0)
);

--Borramos la tabla clientes independientemente de la existencia de dependencias relacionales con otras tablas y/o restriciones.
DROP TABLE CLIENTES CASCADE CONSTRAINTS;
-- Creamos la tabla CLIENTES con sus restriciones e insertamos sus valores.
CREATE TABLE CLIENTES (
  DNI               VARCHAR2(9)   CONSTRAINT PK_Clientes PRIMARY KEY,
  Nombre            VARCHAR2(30)  CONSTRAINT Nombre_NN NOT NULL,
  Nacionalidad      VARCHAR(30),
  FechaNacimiento   DATE,
  Dirección         VARCHAR2(50)
);

--Borramos la tabla alquileres independientemente de la existencia de dependencias relacionales con otras tablas y/o restriciones.
DROP TABLE ALQUILERES CASCADE CONSTRAINTS;
-- Creamos la tabla ALQUILERES con sus restriciones e insertamos sus valores.
CREATE TABLE ALQUILERES (
  Matricula     VARCHAR2(7)   CONSTRAINT FK_Vehiculos REFERENCES VEHICULOS,
  DNI           VARCHAR2(10)  CONSTRAINT FK_Clientes  REFERENCES CLIENTES,
  FechaHora     DATE,
  NumDias       NUMBER(2)     CONSTRAINT NumDias_NN NOT NULL,
  Kilometros    NUMBER(4)     DEFAULT 0,
  CONSTRAINT PK_Alquileres PRIMARY KEY(Matricula, DNI, FechaHora)
);

-- VEHICULOS (matricula, marca, modelo, fechacompra, preciopordia)

INSERT INTO VEHICULOS VALUES ('9226BKD','SEAT','LEON','08/06/05',70);
INSERT INTO VEHICULOS VALUES ('8226BKD','SEAT','LEON','08/06/05',70);
INSERT INTO VEHICULOS VALUES ('7226BKD','FORD','FOCUS','08/06/05',60);
INSERT INTO VEHICULOS VALUES ('6226BKD','AUDI','A3','08/06/05',170);
INSERT INTO VEHICULOS VALUES ('5226BKD','BMW','320d','08/06/05',170);
INSERT INTO VEHICULOS VALUES ('4226BKD','FORD','KA','08/06/05',40);
INSERT INTO VEHICULOS VALUES ('3226BKD','AUDI','A4','08/06/05',190);
INSERT INTO VEHICULOS VALUES ('2226BKD','PORSCHE','911','08/06/05',270);
INSERT INTO VEHICULOS VALUES ('1226BKD','PORSCHE','911','08/06/05',270);
INSERT INTO VEHICULOS VALUES ('0226BKD','AUDI','A8','08/06/05',370);

-- Cambiamos el tamaño de la columna modelo de la tabla ya que el siguiente registro es de tamaño superior.
ALTER TABLE VEHICULOS
MODIFY Modelo varchar2(11);

INSERT INTO VEHICULOS VALUES ('9225BKD','SEAT','IBIZA CUPRA','08/06/05',90);
INSERT INTO VEHICULOS VALUES ('8225BKD','FORD','KA','08/06/05',40);
INSERT INTO VEHICULOS VALUES ('7225BKD','BMW','120d','18/06/05',110);
INSERT INTO VEHICULOS VALUES ('6225BKD','BMW','Z8','08/06/06',270);
INSERT INTO VEHICULOS VALUES ('5225BKD','SEAT','Arosa','08/06/05',35);
INSERT INTO VEHICULOS VALUES ('4225BKD','PORSCHE','926','08/06/07',170);

-- Clientes (DNI,Nombre, Nacionalidad, FechaNacimiento, Direccion)

-- Cambiamos el tamaño de la columna DNI de la tabla ya que en los siguientes registros son de tamaño superior.

ALTER TABLE CLIENTES
MODIFY DNI varchar2(10);

INSERT INTO CLIENTES
VALUES ('28734882-L','HEINRICH VON HEIDERMANN','ALEMANA','21/02/71','C/ SIERPES, 21');
INSERT INTO CLIENTES
VALUES ('29734882-L','VAN MORRISON','IRLANDESA','23/02/55','C/ VALME, 21');
INSERT INTO CLIENTES
VALUES ('30734882-L','ER SEQUI','ESPAÑOLA','25/02/71','C/ PI, 21');
INSERT INTO CLIENTES
VALUES ('31734882-L','LA VANE','ESPAÑOLA','21/02/81','C/ SOL, 21');
INSERT INTO CLIENTES
VALUES ('32734882-L','JENNY FOWLER','ESTADOUNIDENSE','23/02/55','HILL ST, 21');
INSERT INTO CLIENTES
VALUES ('33734882-L','ZEN YU','CHINA','21/02/61','C/ BOTICA, 21');
INSERT INTO CLIENTES
VALUES ('34734882-L','TCHO TCHIN','CHINA','21/02/71','C/ MELLIZA, 21');
INSERT INTO CLIENTES
VALUES ('35734882-L','JOHNNIE WALKER','ESCOCESA','23/02/55','FIFTH AVENUE, 21');
INSERT INTO CLIENTES
VALUES ('36734882-L','DEBO HEREDIA','ESPAÑOLA','29/02/81','C/ CERRO BLANCO, 21');

-- Fecha Original erronea ese mes no tiene 29 días ya que ese año no es bisiesto.
INSERT INTO CLIENTES
VALUES ('36734882-L','DEBO HEREDIA','ESPAÑOLA','28/02/81','C/ CERRO BLANCO, 21');


-- Alquileres (matricula, dni, fechahora, numdias, kilometros)

-- Cambio el formato de las fechas porque me da un error a la hora de la conversión.
INSERT INTO ALQUILERES
VALUES ('9226BKD', '28734882-L',TO_DATE('04/04/07 09:30','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('9226BKD', '29734882-L',TO_DATE('04/03/07 11:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('6226BKD', '31734882-L',TO_DATE('04/07/07 12:15','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('8226BKD', '32734882-L',TO_DATE('04/07/07 10:12','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('7226BKD', '33734882-L',TO_DATE('04/08/07 12:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('6226BKD', '32734882-L',TO_DATE('04/08/07 14:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('5226BKD', '32734882-L',TO_DATE('04/08/07 18:15','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('5226BKD', '31734882-L',TO_DATE('04/08/07 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('5226BKD', '32734882-L',TO_DATE('04/08/07 10:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('5226BKD', '34734882-L',TO_DATE('04/08/07 10:00','DD/MM/YY HH24:MI'),7,9200);
INSERT INTO ALQUILERES
VALUES ('4226BKD', '34734882-L',TO_DATE('04/09/07 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('4226BKD', '34734882-L',TO_DATE('04/08/08 10:00','DD/MM/YY HH24:MI'),7,1200);
--INSERT INTO ALQUILERES
--VALUES ('4226BKD', '34734882-L',TO_DATE('04/09/07 10:00','DD/MM/YY HH24:MI'),7,1200); Anulada porque se repite.
INSERT INTO ALQUILERES
VALUES ('3226BKD', '34734882-L',TO_DATE('04/08/08 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('3226BKD', '33734882-L',TO_DATE('04/05/09 10:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('2226BKD', '35734882-L',TO_DATE('04/04/09 10:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('2226BKD', '35734882-L',TO_DATE('04/03/09 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('2226BKD', '35734882-L',TO_DATE('04/05/08 10:00','DD/MM/YY HH24:MI'),7,1200);
--INSERT INTO ALQUILERES
--VALUES ('2226BKD', '35734882-L',TO_DATE('04/04/09 10:00','DD/MM/YY HH24:MI'),7,1200); Anulada porque se repite
INSERT INTO ALQUILERES
VALUES ('1226BKD', '33734882-L',TO_DATE('04/03/08 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('1226BKD', '33734882-L',TO_DATE('04/05/06 10:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('0226BKD', '33734882-L',TO_DATE('04/04/07 10:00','DD/MM/YY HH24:MI'),7,1200);
INSERT INTO ALQUILERES
VALUES ('0226BKD', '33734882-L',TO_DATE('04/03/08 10:00','DD/MM/YY HH24:MI'),2,9999);
INSERT INTO ALQUILERES
VALUES ('0226BKD', '33734882-L',TO_DATE('04/05/09 10:00','DD/MM/YY HH24:MI'),7,1200);

/* 2.2  Insertar en la tabla alquileres la matricula del vehículo más nuevo de la tabla vehiculos, 
        el DNI del cliente que más audis ha alguilado, la fecha de hoy, y 10 días de alquiler.
*/

INSERT INTO ALQUILERES (Matricula, DNI, Fechahora, NumDias)
VALUES((SELECT Matricula 
        FROM VEHICULOS
        WHERE FechaCompra = (SELECT max(FechaCompra)
                             FROM VEHICULOS)),
        -- Selecciono la matricula de la tabla vehiculos cuya fecha de compra
        -- sea igual a la mayor.
       (SELECT DNI 
        FROM ALQUILERES
        WHERE Matricula IN (SELECT Matricula
                            FROM VEHICULOS
                            WHERE Marca='AUDI')
        GROUP BY dni
        HAVING count(*) = (SELECT max(count(*))
                           FROM ALQUILERES
                           WHERE Matricula IN (SELECT Matricula
                                              FROM VEHICULOS
                                              WHERE Marca='AUDI')
                          GROUP BY dni)),
        -- Selecciono el dni de la tabla alquileres donde las matriculas 
        -- de lo vehiculos alguilados sean audis agrupados por dni y donde
        -- la cantidad veces que se alquilado un coche (matricula) sea igual al 
        -- máximo de audis alquilados por un misma persona(dni).
	SYSDATE,
	10 );

-- 2.3 Añadir restrinciones.

-- 2.3.1. Último caracter una letra y penúltimo un "-". Tabla Clientes.

ALTER TABLE CLIENTES
ADD CONSTRAINT DNILetra CHECK(
          UPPER(SUBSTR(DNI,10,1))<='Z' AND UPPER(SUBSTR(DNI,10,1))>='A' 
          AND 
          SUBSTR(DNI,9,1)='-'
);

-- 2.3.2. Matriculas tiene cuatro número y le siguen tres letras mayúsculas.

ALTER TABLE VEHICULOS
ADD CONSTRAINT MatriculaCorrecta CHECK(
            SUBSTR(Matricula,1,4) >= '0000' AND SUBSTR(Matricula,1,4) <='9999' 
            AND 
            SUBSTR(Matricula,5,3) >= 'AAA'  AND SUBSTR(Matricula,5,3) <='ZZZ'
);

-- 2.3.3. Alquileres entre las 08:00 y 22:00 Horas.

ALTER TABLE ALQUILERES
ADD CONSTRAINT HoraAlquilerCorrecta CHECK(
            TO_NUMBER(TO_CHAR(FechaHora,'HH24'))>=8 
            AND 
            TO_NUMBER(TO_CHAR(FechaHora,'HH24'))<=22
);

-- 2.4 Vista: Coche y Clientes que hayan hecho más 50 kilometros.

CREATE OR REPLACE VIEW ALQUILER50
AS 
SELECT B.Matricula, A.Nombre, A.Dirección
FROM CLIENTES A, VEHICULOS B, ALQUILERES C 
WHERE A.DNI=C.DNI
AND B.Matricula=C.Matricula
AND FechaHora=(SELECT MAX(FechaHora)
	             FROM ALQUILERES C2
	             WHERE B.matricula=C2.matricula
	             AND C.Kilometros>50)
UNION
SELECT Matricula, NULL, NULL
FROM VEHICULOS
WHERE Matricula NOT IN (SELECT Matricula
                        FROM ALQUILERES)
ORDER BY Matricula;


-- 2.5 Añadir a la tabla Vehículos una nueva columna donde se almacen el 
-- total de kilometros recorridos por cada coche sacado este dato de la tabla alquileres.

ALTER TABLE VEHICULOS
ADD TotalKilometros NUMBER(10) DEFAULT 0;

UPDATE VEHICULOS A
SET TotalKilometros = (SELECT NVL(SUM(Kilometros),0)
		 FROM ALQUILERES B
		 WHERE A.matricula=B.matricula);

-- 2.6 Mostrar por modelos, la cantidad ingresada por alquileres. Inclusive
-- los que no se han alquilados

SELECT Marca, Modelo, NVL(SUM(NumDias*PrecioDia),0) as AlquilerTotal
FROM VEHICULOS A, ALQUILERES B
WHERE A.matricula= B.matricula(+)
GROUP BY Marca, Modelo
ORDER BY AlquilerTotal DESC;

-- 2.7. Mostrar lo que se han gastado nuestros clientes en alquieres a lo largo
-- del último año. Inclusive los que no se han gastado nada.

CREATE OR REPLACE VIEW ALQUILERANYO
AS SELECT *
FROM ALQUILERES
WHERE MONTHS_BETWEEN(SYSDATE, FechaHora)<12;

SELECT A.dni, A.nombre, NVL(SUM(NumDias*PrecioDia),0) as GASTO
FROM CLIENTES A, VEHICULOS B, ALQUILERES C
WHERE A.DNI=C.DNI AND B.Matricula=C.Matricula
GROUP BY A.dni, A.nombre
UNION
SELECT A.dni, A.nombre, 0
FROM CLIENTES A
WHERE DNI NOT IN (SELECT DNI
                  FROM ALQUILERANYO)
ORDER BY GASTO DESC;

-- 2.8 Crear Vista de la marca y modelo de los vehiculos que estan libres a partir
-- de mañana.

CREATE OR REPLACE VIEW VEHICULOSLIBRES
AS
SELECT Marca, Modelo, COUNT(*) AS Num_Vehiculos
FROM VEHICULOS
WHERE Matricula NOT IN (SELECT Matricula
                    FROM ALQUILERES
                    WHERE FechaHora + NumDias > (SYSDATE + 1))
GROUP BY Marca, Modelo;

-- 2.9 Vista: Matriculas de los coches con mas 1000 kilometros hechos por un mismo cliente.

CREATE OR REPLACE VIEW VEHICULOS_1000
AS
SELECT DISTINCT Matricula
FROM ALQUILERES A
GROUP BY DNI, Matricula
HAVING SUM(Kilometros)>1000;

-- 2.10 Borrar los vehiculos con más 50000 kilometros y con más de dos años de 
-- antiguedad.

DELETE FROM VEHICULOS
WHERE TOTALKILOMETROS > 50000 OR MONTHS_BETWEEN(SYSDATE, Fechacompra)>24;

-- 2.11 Crear una columna en la tabla vehiculos con los ingresos de cada coche

ALTER TABLE VEHICULOS
ADD INGRESOS NUMBER(10);

UPDATE VEHICULOS A
SET INGRESOS = (SELECT NVL((sum(NumDias) * PrecioDia),0)
	              FROM ALQUILERES B
	              WHERE A.Matricula=B.Matricula);
		 	
UPDATE VEHICULOS A
SET INGRESOS= INGRESOS + (SELECT NVL((SUM(NumDias) * 0.25 * PrecioDia),0)
                          FROM ALQUILERES B
                          WHERE A.Matricula=B.Matricula
                          AND (TO_CHAR(FechaHora,'MM')='07' 
                          OR TO_CHAR(FechaHora,'MM')='08'));

-- 2.12 Mostrar agrupado por nacionalidades la marcas más alquiladas por los
-- clientes de esa nacionalidad. Mostrar también por nacionalidad la duración
-- media de alquiler y el importe medio.

SELECT Nacionalidad, Marca, count(*) as NUMVEHICULOS
FROM CLIENTES A, VEHICULOS B, ALQUILERES C 
WHERE B.Matricula=C.Matricula
AND A.DNI=C.DNI
GROUP BY Nacionalidad, Marca
HAVING count(*) = (SELECT MAX(COUNT(*))
                   FROM CLIENTES D, VEHICULOS E, ALQUILERES F 
                   WHERE D.DNI=F.DNI
                   AND E.Matricula=F.Matricula
                   AND A.Nacionalidad = D.Nacionalidad
                   GROUP BY Nacionalidad, Marca);

SELECT Nacionalidad, ROUND(AVG(NumDias),2) AS DURACIONMEDIA, ROUND(AVG(NumDias * PrecioDia),2) as IMPORTEMEDIO
FROM CLIENTES A, VEHICULOS B, ALQUILERES C
WHERE A.dni=C.dni AND B.Matricula=C.Matricula
GROUP BY Nacionalidad;

-- 2.13 Los modelos menos alquilados durante el ultimo año su precio se baja un 20%.

UPDATE VEHICULOS
SET PrecioDia = PrecioDia - (0.2*PrecioDia)
WHERE Modelo IN (SELECT Modelo
                 FROM ALQUILERANYO A, VEHICULOS B
                 WHERE B.Matricula=A.Matricula(+)
                 GROUP BY Marca, Modelo
                 HAVING SUM(NVL(A.NumDias,0)) = (SELECT MIN(SUM(NVL(A2.NumDias,0)))
                                                 FROM ALQUILERANYO A2, VEHICULOS B2
                                                 WHERE B2.Matricula=A2.Matricula(+)
                                                 AND B.Marca=B2.Marca
                                                 GROUP BY Marca, Modelo));

SET TERMOUT ON
SET ECHO ON