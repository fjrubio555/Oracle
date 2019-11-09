set serveroutput on 
SET TERMOUT OFF
SET ECHO OFF

-- 3.4. Crear una función que reciba el número del departamento y devuelva
-- el nombre del mismo y el número de empleados.

CREATE OR REPLACE TYPE contaemple AS OBJECT -- uso object porque no me deja usar record.
(
NUMD NUMBER(4), 
NOMBRED VARCHAR2(14)
);

CREATE OR REPLACE FUNCTION DEPARTAMENTO (NUMDEP IN NUMBER) 
RETURN contaemple
IS
   veri_dept NUMBER:=0;
   v_contaemple contaemple;
BEGIN
    v_contaemple:=contaemple(NULL,NULL);
    SELECT COUNT(*) INTO veri_dept
    FROM EMP A INNER JOIN DEPT B ON A.DEPTNO = B.DEPTNO AND A.DEPTNO=NUMDEP;
    IF (veri_dept>0) THEN
        SELECT COUNT(*), MIN(B.DNAME)
        INTO v_contaemple.NUMD, v_contaemple.NOMBRED
        FROM EMP A INNER JOIN DEPT B ON A.DEPTNO = B.DEPTNO AND A.DEPTNO=NUMDEP
        GROUP BY A.DEPTNO;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Número de Departamento no válido.');
    END IF;
    RETURN v_contaemple;
END DEPARTAMENTO;

DECLARE
    v_contaemple2 contaemple;
BEGIN
    v_contaemple2:=DEPARTAMENTO(10);
    IF (v_contaemple2.NOMBRED IS NOT NULL AND v_contaemple2.NUMD IS NOT NULL) THEN
        DBMS_OUTPUT.PUT_LINE('Departamento: ' || v_contaemple2.NOMBRED ||' Núm Empleados: ' || v_contaemple2.NUMD); 
    END IF;
END;

/*3.6 Trigger: Realizar un trigger que mantenga actualizada la columna CosteSalarial, 
con la suma de los salarios y comisiones de los empleados de dichos departamentos 
reflejando cualquier cambio que se produzca en la tabla empleados.*/

ALTER TABLE DEPT ADD CosteSalarial NUMBER(8,2) NULL;

CREATE OR REPLACE TRIGGER T_CosteSalarial
AFTER INSERT OR UPDATE OF SAL,COMM OR DELETE ON EMP
FOR EACH ROW
DECLARE 
  salarioTotal NUMBER(8,2):=0;
  departamento NUMBER(2,0):= :NEW.DEPTNO;
BEGIN
  IF DELETING THEN
    departamento:= :OLD.DEPTNO;
    salarioTotal:=-1 *(NVL(:OLD.SAL,0)+ NVL(:OLD.COMM,0));
    
  ELSIF UPDATING THEN
     salarioTotal:= (NVL(:NEW.SAL,0) - NVL(:OLD.SAL,0)) + (NVL(:NEW.COMM,0) - NVL(:OLD.COMM,0));
  ELSE
     salarioTotal:= NVL(:NEW.SAL,0) + NVL(:NEW.COMM,0);
  END IF;
  CalcularSalarios(:NEW.DEPTNO, salarioTotal);
END;

CREATE OR REPLACE PROCEDURE CalcularSalarios (numdept DEPT.DEPTNO%TYPE, salario DEPT.COSTESALARIAL%TYPE)
IS
  contardept NUMBER;
BEGIN
    UPDATE DEPT
    SET CosteSalarial = NVL(CosteSalarial,0)+ salario
    WHERE DEPTNO=numdept;
END CalcularSalarios;


--3.7 Trigger: Que incremente un 5% el salario de un empleado si cambia la localidad del departamento donde trabaja

-- Si a un empleado lo cambio de departamento y este esta en otra localidad.
CREATE OR REPLACE TRIGGER AumentoSalario5
AFTER UPDATE OF DEPTNO ON EMP
FOR EACH ROW
DECLARE
  nuevaloc DEPT.LOC%TYPE;
  viejaloc DEPT.LOC%TYPE;
BEGIN
  SELECT LOC INTO viejaloc
  FROM DEPT
  WHERE DEPTNO=:OLD.DEPTNO;
  SELECT LOC INTO nuevaloc
  FROM DEPT
  WHERE DEPTNO=:NEW.DEPTNO;
  IF nuevaloc!=viejaloc THEN
    UPDATE EMP SET SAL=SAL*1.05
    WHERE EMPNO=:NEW.EMPNO; 
  END IF;
END AumentoSalario5;

-- Si traslado un departamento a otra localidad.

CREATE OR REPLACE TRIGGER AumentoSalario5_2
AFTER UPDATE OF LOC ON DEPT
FOR EACH ROW
BEGIN
  UPDATE EMP SET SAL=SAL*1.05
  WHERE DEPTNO=:OLD.DEPTNO;
END AumentoSalario5_2;

/* 3.8  Trigger: Realiza un trigger que registre en la base de datos los intentos 
de modificar, actualizar o borrar datos en las filas de la tabla EMP 
correspondientes al presidente y a los jefes de departamento, especificando 
el usuario, la fecha y la operacion intentada.*/

DROP TABLE empregistro CASCADE CONSTRAINTS;

CREATE TABLE empregistro
(
   usuario VARCHAR2(30),
   fecha  DATE,
   operacion VARCHAR2(20)

);

CREATE OR REPLACE TRIGGER EmpRegistrar
AFTER INSERT OR UPDATE OR DELETE ON EMP
FOR EACH ROW
DECLARE
  oper VARCHAR(20);
BEGIN
  IF (:OLD.JOB='PRESIDENT' OR :OLD.JOB='MANAGER' OR :NEW.JOB='PRESIDENT' OR :NEW.JOB='MANAGER') THEN
    IF INSERTING THEN 
      oper:='INSERTAR';
    END IF;
    IF UPDATING THEN 
      oper:='ACTUALIZAR';
    END IF;
    IF DELETING THEN 
      oper:='BORRAR';
    END IF;
    INSERT INTO empregistro VALUES (USER,TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MM:SS'),oper);
  END IF;
END;

/* 3.9 Realizar un trigger que impida que un departamento tenga más de 5 empleados
o menos de dos.*/

CREATE OR REPLACE TRIGGER ComprobarEmpleados
BEFORE INSERT OR UPDATE OF DEPTNO OR DELETE ON EMP
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  depart EMP.DEPTNO%TYPE := :NEW.DEPTNO;
  numemp EMP.EMPNO%TYPE := 0;
BEGIN
  IF DELETING THEN 
    depart := :OLD.DEPTNO; 
  END IF;
  SELECT COUNT(*) INTO numemp
  FROM EMP
  WHERE DEPTNO = depart
  GROUP BY DEPTNO;
  IF (numemp>0) THEN
    IF (numemp=5) THEN --Supongo que no hay más de 5 empleados por departamentos.
        RAISE_APPLICATION_ERROR(-20201, 'No puede haber más de 5 empleados en un departamento');
    ELSIF ((numemp>=2) AND DELETING) THEN
        RAISE_APPLICATION_ERROR(-20201, 'No puede haber menos de 2 empleados en un departamento');
  
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Departamento sin empleados');
  END IF;
END;

SET TERMOUT ON
SET ECHO ON



