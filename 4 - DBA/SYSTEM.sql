-- 4. DBA
/*Tu empresa tiene una base de datos a la que acceden (aparte de tí, que eres el
DBA) tres usuarios de dos departamentos: Alberto y Gustavo del Departamento de 
Personal y Angelita del Departamento de Ventas.*/

/* 4.1 -  El Departamento de Personal trabaja con un tablespace que incluye dos 
ficheros en dos discos diferentes, ambos tamaño inicial 1G, autoextensibles pero
no deben llegar a ocupar más de 200 Gigabytes. El Departamento de Ventas tiene 
un tablespace con un fichero de 200M. Los objetos creados en el tablespace 
tendrán por defecto una extensión inicial de 500K, la siguiente de 600K y 
la tercera ha de tener 750K. El número máximo de extensiones de un objeto serán 
20, salvo que se especifique lo contrario. Una vez creado, modifícalo para 
añadirle otro fichero de 200 M. */

CREATE TABLESPACE PERSONAL
DATAFILE 'C:\app\fran\oradata\orcl\personal01.dbf' SIZE 1G AUTOEXTEND ON MAXSIZE 200G,
         'G:\oradata\orcl\personal02.dbf'          SIZE 1G AUTOEXTEND ON MAXSIZE 200G;

CREATE TABLESPACE VENTAS
DATAFILE 'C:\app\fran\oradata\orcl\venta.dbf' SIZE 200M
DEFAULT STORAGE
(
	INITIAL 	500K
	NEXT		600K
	PCTINCREASE 	25 --  tanto porcierto que se incrementa la siguiente extensión
	MAXEXTENTS	20
);

ALTER TABLESPACE VENTAS
ADD DATAFILE 'C:\app\fran\oradata\orcl\venta02.dbf' SIZE 200M;


/*4.2 - Todos los usuarios tienen definido el tablespace por defecto más
conveniente. 
Tú eres el DBA. 
Alberto tiene permiso para crear tablas y vistas en
cualquier esquema de usuario y dispondrá de espacio para ello en ambos 
tablespaces.
Gustavo puede consultar todas las tablas de los demás usuarios y también la vista
DBA_TABLESPACES, teniendo derecho a pasar ese privilegio a otros usuarios si así
lo desea. En cambio, no podrá crear objetos en el tablespace de Ventas ni en el 
tablespace SYSTEM.
Angelita puede crear tablas y consultas en su esquema y también puede crear 
usuarios y darles y quitarles permisos. También puede insertar o modificar 
registros en la tabla Prueba del usuario Alberto.*/

CREATE USER FRAN
IDENTIFIED BY FRAN;
GRANT DBA TO FRAN;

CREATE USER ALBERTO
IDENTIFIED BY ALBERTO
DEFAULT TABLESPACE PERSONAL
QUOTA 250M ON PERSONAL
QUOTA 200M ON VENTAS;

GRANT CONNECT TO ALBERTO;
GRANT CREATE ANY TABLE TO ALBERTO; -- Permito la creacion de tabla en cualquier esquema aparte del suyo.
GRANT CREATE ANY VIEW TO ALBERTO;

CREATE TABLE ALBERTO.Prueba 
(
  Id NUMBER(2),
  Desc VARCHAR2(50),
  PRIMARY KEY (Id)
);

CREATE USER GUSTAVO
IDENTIFIED BY GUSTAVO
DEFAULT TABLESPACE PERSONAL
QUOTA 250M ON PERSONAL;

GRANT CONNECT TO GUSTAVO;
GRANT CREATE TABLE TO GUSTAVO;
GRANT SELECT ANY TABLE TO GUSTAVO; -- Le permito buscar en cualquier tabla independiente del esquema
GRANT SELECT ON SYS.DBA_TABLESPACES TO GUSTAVO WITH GRANT OPTION; -- Puede otogar este privilegio a otros

CREATE USER ANGELITA
IDENTIFIED BY ANGELITA
DEFAULT TABLESPACE VENTAS
QUOTA 200M ON VENTAS;

GRANT CONNECT TO ANGELITA;
GRANT CREATE TABLE TO ANGELITA;
GRANT CREATE VIEW TO ANGELITA;
GRANT CREATE USER TO ANGELITA; -- Le permito crear usuarios.
GRANT GRANT ANY PRIVILEGE TO ANGELITA; -- Le permito dar y quitar privilegios
GRANT INSERT, UPDATE ON ALBERTO.Prueba TO ANGELITA; -- Le permito  añadir y actualizar la tabla Pruebas de Alberto.

/* 4.3 - Crea una tabla llamada VentasGrandesClientes con una columna 
tipo NUMBER(4) en el esquema de Alberto, pero en el tablespace Ventas, 
especificando que inicialmente ocupe 500K. Después le das permiso a 
Gustavo para ver los datos. Gustavo puede pasar ese privilegio a otros usuarios. 
El usuario Alberto crea una secuencia llamada NumVenta e inserta tres registros 
en la tabla con los valores 5, 3 y 1 empleando la secuencia creada.
*/

CREATE TABLE ALBERTO.VentasGrandesClientes
(
	Valor	NUMBER(4)
)
STORAGE
(
	INITIAL	500K
)TABLESPACE VENTAS;

GRANT SELECT ON ALBERTO.VentasGrandesClientes TO GUSTAVO WITH GRANT OPTION;

GRANT CREATE SEQUENCE TO ALBERTO;

CREATE SEQUENCE ALBERTO.NumVenta
START WITH 5
INCREMENT BY -2
MAXVALUE 5;

INSERT INTO ALBERTO.VentasGrandesClientes VALUES (ALBERTO.NumVenta.NEXTVAL);
INSERT INTO ALBERTO.VentasGrandesClientes VALUES (ALBERTO.NumVenta.NEXTVAL);
INSERT INTO ALBERTO.VentasGrandesClientes VALUES (ALBERTO.NumVenta.NEXTVAL);


/*4.4 - Es necesario cambiar el perfil a Angelita para que su contraseña sea más
segura. Toma las medidas necesarias y explícalas una a una. */

ALTER SYSTEM SET RESOURCE_LIMIT=TRUE; --Nos permite habilitar perfiles

CREATE PROFILE ANGELITA_CONTRA LIMIT  -- Creación del Perfil
IDLE_TIME 15                   -- Limitamos a 15 minutos la inactividad.
FAILED_LOGIN_ATTEMPTS 3        -- Intentos de incios de sesion a 3.
PASSWORD_LIFE_TIME 30          -- 30 días de duración de la contraseña.
PASSWORD_REUSE_TIME UNLIMITED  -- Sin limitación el reuso de la contraseña.
PASSWORD_LOCK_TIME 15          -- 15 días de duración del bloqueo.
PASSWORD_GRACE_TIME 1          -- Solo le damos un día de cortesía antes del bloqueo de usuario.
PASSWORD_VERIFY_FUNCTION FuncionContraseñaBuena; --Función para comprobar que la contraseña es correcta.

ALTER USER ANGELITA PROFILE ANGELITA_CONTRA; -- Le asignamos 

/* 4.5 - Escribe la consulta necesaria para ver de cuanto espacio libre 
dispone cada usuario en cada tablespace sobre el que tiene una cuota que le 
restringe su uso. */

desc DBA_TS_QUOTAS;

SELECT TABLESPACE_NAME, USERNAME, ROUND((MAX_BYTES - BYTES)/102/1024,2) "MEGASBYTES LIBRES"
FROM DBA_TS_QUOTAS
WHERE MAX_BYTES!=-1;

/* 4.6 - Escribe la consulta necesaria para ver todos  los privilegios 
(de sistema y sobre objetos concretos) de los usuarios que tienen como tablespace
por defecto USERS, le hayan sido concedidos directamente o a través de un rol. 
*/

DESC DBA_SYS_PRIVS;
DESC DBA_USERS;
DESC DBA_ROLE_PRIVS;
DESC DBA_TAB_PRIVS;

SELECT * FROM DBA_SYS_PRIVS;
SELECT * FROM DBA_USERS;
SELECT * FROM DBA_ROLE_PRIVS;
SELECT * FROM DBA_TAB_PRIVS;

SELECT GRANTEE, PRIVILEGE, NULL OBJETO
FROM DBA_SYS_PRIVS
WHERE GRANTEE IN (SELECT USERNAME
                  FROM DBA_USERS
                  WHERE DEFAULT_TABLESPACE='USERS')
OR GRANTEE IN    (SELECT GRANTED_ROLE
                  FROM DBA_ROLE_PRIVS
                  WHERE GRANTEE IN (SELECT USERNAME
                                    FROM DBA_USERS
                                    WHERE DEFAULT_TABLESPACE='USERS'))
UNION 
SELECT GRANTEE, PRIVILEGE, OWNER || '.' || TABLE_NAME OBJETO
FROM DBA_TAB_PRIVS
WHERE GRANTEE IN (SELECT USERNAME
                  FROM DBA_USERS
                  WHERE DEFAULT_TABLESPACE='USERS')
OR GRANTEE IN    (SELECT GRANTED_ROLE
                  FROM DBA_ROLE_PRIVS
                  WHERE GRANTEE IN (SELECT USERNAME
                                    FROM DBA_USERS
                                    WHERE DEFAULT_TABLESPACE='USERS'))
ORDER BY GRANTEE;
      


/* 4.7 - Escribe una consulta que te permita saber la ubicación y el tamaño de 
los ficheros de datos asociados a los tablespaces que se han asignado por
defecto al menos a tres usuarios. */

DESC DBA_USERS;
DESC DBA_DATA_FILES;

SELECT TABLESPACE_NAME, FILE_NAME, ROUND(BYTES/1024/1024,2) "TAMAÑO MB"
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME IN (SELECT DEFAULT_TABLESPACE
                          FROM DBA_USERS
                          GROUP BY DEFAULT_TABLESPACE
                          HAVING COUNT(*)>3);

/* 4.8 - Realiza una SELECT cuya salida pueda emplearse como script para dar el
mismo perfil de Angelita a los usuarios que tienen como tablespace por defecto 
el del Departamento de Ventas. */

SELECT 'ALTER USER ' || A.USERNAME || ' PROFILE ' || B.PROFILE || ';'
FROM DBA_USERS A, DBA_USERS B
WHERE A.DEFAULT_TABLESPACE='VENTAS' AND B.USERNAME='ANGELITA';









