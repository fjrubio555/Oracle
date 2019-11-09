SET TERMOUT OFF
SET ECHO OFF
-- Otorgamos al usario MODULO los privilegios del sistema (conexión, recursos, dba, y tablespaces ilimitado) y le asignamos la contraseña. 
GRANT CONNECT,RESOURCE,DBA,UNLIMITED TABLESPACE TO MODULO IDENTIFIED BY MODULO;
-- Modificamos el usuario MODULO le indicando cual va a ser su tablespaces por defecto y el temporal.
ALTER USER MODULO DEFAULT TABLESPACE USERS;
ALTER USER MODULO TEMPORARY TABLESPACE TEMP;
-- Conectamos el Usuario.
CONNECT MODULO/MODULO;
REM ******** TABLAS ALUMNOS, ASIGNATURAS, NOTAS: ***********

DROP TABLE ALUMNOS cascade constraints;

CREATE TABLE ALUMNOS
(
  DNI VARCHAR2(10) NOT NULL,
  APENOM VARCHAR2(30),
  DIREC VARCHAR2(30),
  POBLA  VARCHAR2(15),
  TELEF  VARCHAR2(10)  
) 

DROP TABLE ASIGNATURAS cascade constraints;

CREATE TABLE ASIGNATURAS
(
  COD NUMBER(2) NOT NULL,
  NOMBRE VARCHAR2(25)
) 

DROP TABLE NOTAS cascade constraints;

CREATE TABLE NOTAS
(
  DNI VARCHAR2(10) NOT NULL,
  COD NUMBER(2) NOT NULL,
  NOTA NUMBER(2)
) 

INSERT INTO ASIGNATURAS VALUES (1,'Prog. Leng. Estr.');
INSERT INTO ASIGNATURAS VALUES (2,'Sist. Informáticos');
INSERT INTO ASIGNATURAS VALUES (3,'Análisis');
INSERT INTO ASIGNATURAS VALUES (4,'FOL');
INSERT INTO ASIGNATURAS VALUES (5,'RET');
INSERT INTO ASIGNATURAS VALUES (6,'Entornos Gráficos');
INSERT INTO ASIGNATURAS VALUES (7,'Aplic. Entornos 4ªGen');

INSERT INTO ALUMNOS VALUES
('12344345','Alcalde García, Elena', 'C/Las Matas, 24','Madrid','917766545');
INSERT INTO ALUMNOS VALUES
('4448242','Cerrato Vela, Luis', 'C/Mina 28 - 3A', 'Madrid','916566545');
INSERT INTO ALUMNOS VALUES
('56882942','Díaz Fernández, María', 'C/Luis Vives 25', 'Móstoles','915577545');

INSERT INTO NOTAS VALUES('12344345', 1, 6);
INSERT INTO NOTAS VALUES('12344345', 2, 5);
INSERT INTO NOTAS VALUES('12344345', 3, 6);
INSERT INTO NOTAS VALUES('4448242', 4, 6);
INSERT INTO NOTAS VALUES('4448242', 5, 8);
INSERT INTO NOTAS VALUES('4448242', 6, 4);
INSERT INTO NOTAS VALUES('4448242', 7, 5);
INSERT INTO NOTAS VALUES('56882942', 4, 8);
INSERT INTO NOTAS VALUES('56882942', 5, 7);
INSERT INTO NOTAS VALUES('56882942', 6, 8);
INSERT INTO NOTAS VALUES('56882942', 7, 9);
COMMIT;
/* 3.1 Crear un procedimiento que introducciendo el nombre de uno de los módulos
muestre los alumnos que lo han cursoado y sus notal. Cantidad suspensos,
aprovados, notables y sobresalientes. Al final deben aparecer también 
el nombre y la nota de los alumnos con la nota más alta y más baja.
*/
CREATE OR REPLACE PROCEDURE Nombrar_Modulo (nombre_modulo ASIGNATURAS.NOMBRE%TYPE) IS
num_susp NUMBER:=0;
num_aprob NUMBER:=0;
num_not NUMBER:=0;
num_sob NUMBER:=0;
mejor_alum  ALUMNOS.APENOM%TYPE;
peor_alum   ALUMNOS.APENOM%TYPE;
mejor_nota NUMBER:=-1;
peor_nota   NUMBER:=11;
verificarnombre NUMBER:=0;
CURSOR cursornotas IS
          SELECT APENOM, NOTA
          FROM  ALUMNOS A, NOTAS B
          WHERE A.DNI = B.DNI
          AND B.COD = (SELECT COD 
                       FROM ASIGNATURAS
                       WHERE UPPER(NOMBRE) = UPPER(nombre_modulo));
notas cursornotas%ROWTYPE;
BEGIN
    SELECT COUNT(*) INTO verificarnombre
                FROM ASIGNATURAS
                WHERE UPPER(NOMBRE) = UPPER(nombre_modulo);
    IF verificarnombre > 0  THEN
        OPEN cursornotas;
        FETCH cursornotas INTO notas;
        WHILE cursornotas%FOUND LOOP
            MostrarAlumnos(notas.apenom, notas.nota);
            ContarNota(notas.nota, num_susp, num_aprob, num_not, num_sob);
            ComprobarMejor(notas.apenom, notas.nota, mejor_alum, mejor_nota);
            ComprobarPeor(notas.apenom, notas.nota, peor_alum, peor_nota);
            FETCH cursornotas INTO notas;
        END LOOP;
       CLOSE cursornotas;
       MostrarResultados(num_susp, num_aprob, num_not, num_sob, mejor_alum, mejor_nota, peor_alum, peor_nota);
    ELSE
      SYS.DBMS_OUTPUT.PUT_LINE('Nombre del módulo incorrecto.');
    END IF;
END Nombrar_Modulo;

CREATE OR REPLACE PROCEDURE MostrarAlumnos(nombre_alum ALUMNOS.APENOM%TYPE, nota_alum NOTAS.NOTA%TYPE) IS
BEGIN
  SYS.DBMS_OUTPUT.PUT_LINE('ALUMNO: ' || nombre_alum || '. NOTA: ' || nota_alum);

END  MostrarAlumnos;

CREATE OR REPLACE PROCEDURE ContarNota (nota_alum NOTAS.NOTA%type, susp_alum IN OUT NUMBER, aprob_alum IN OUT NUMBER, not_alum IN OUT NUMBER, sob_alum IN OUT NUMBER) IS
BEGIN
	IF nota_alum < 5 THEN
		susp_alum:=susp_alum+1;
	ELSIF nota_alum < 7 THEN
		aprob_alum:=aprob_alum+1;
	ELSIF nota_alum < 9 THEN
		not_alum:=not_alum+1;
	ELSE
		sob_alum:=sob_alum+1;
	END IF;
END  ContarNota;

CREATE OR REPLACE PROCEDURE ComprobarMejor (nombre_alum ALUMNOS.APENOM%TYPE, nota_alum  NOTAS.NOTA%TYPE, mejoralumn IN OUT ALUMNOS.APENOM%TYPE, mejornota IN OUT NOTAS.NOTA%TYPE)IS
BEGIN
	IF nota_alum > mejornota THEN
		mejornota:=nota_alum;
		mejoralumn:=nombre_alum;
	END IF;
END ComprobarMejor;

CREATE OR REPLACE PROCEDURE ComprobarPeor (nombre_alum ALUMNOS.APENOM%TYPE, nota_alum  NOTAS.NOTA%TYPE, peoralum IN OUT ALUMNOS.APENOM%TYPE, peornota IN OUT NOTAS.NOTA%TYPE) IS
BEGIN
	IF nota_alum < peornota THEN
		peornota:=nota_alum;
		peoralum:=nombre_alum;
	END IF;
END ComprobarPeor;

CREATE OR REPLACE PROCEDURE MostrarResultados(numsusp NUMBER, numaprob NUMBER, numnot NUMBER, numsob NUMBER, mejoralum VARCHAR2, mejornota NUMBER, peoralum VARCHAR2, peornota NUMBER)IS
BEGIN
	DBMS_OUTPUT.PUT_LINE('SUSPENSOS: ' || numsusp || '. APROBADOS: ' || numaprob || '. NOTABLES: ' || numnot || '. SOBRESALIENTES: ' || numsob || '. ALUMNO CON LA MEJOR NOTA: ' || mejoralum || ', NOTA: ' || mejornota || '. ALUMNO CON LA PEOR NOTA: ' || peoralum || ', NOTA: ' || peornota);
END MostrarResultados;

SET TERMOUT ON
SET ECHO ON
