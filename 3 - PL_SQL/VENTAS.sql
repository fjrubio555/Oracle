set serveroutput on 
SET TERMOUT OFF
SET ECHO OFF
-- Otorgamos al usario NEOCAR los privilegios del sistema (conexión, recursos, dba, y tablespaces ilimitado) y le asignamos la contraseña. 
GRANT CONNECT,RESOURCE,DBA,UNLIMITED TABLESPACE TO VENTAS IDENTIFIED BY VENTAS;
-- Modificamos el usuario NEOCAR le indicando cual va a ser su tablespaces por defecto y el temporal.
ALTER USER VENTAS DEFAULT TABLESPACE USERS;
ALTER USER VENTAS TEMPORARY TABLESPACE TEMP;

CONNECT VENTAS/VENTAS;

DROP TABLE productos CASCADE CONSTRAINTS;

CREATE TABLE productos
(
	CodProducto 	VARCHAR2(10) CONSTRAINT p_cod_no_nulo NOT NULL,
	Nombre    	VARCHAR2(20) CONSTRAINT p_nom_no_nulo NOT NULL,
	LineaProducto	VARCHAR2(10),
	PrecioUnitario	NUMBER(6),
	Stock 		NUMBER(5),
	PRIMARY KEY (CodProducto)
);

DROP TABLE ventas CASCADE CONSTRAINTS;

CREATE TABLE ventas
(
	CodVenta  		VARCHAR2(10) CONSTRAINT cod_no_nula NOT NULL,
	CodProducto 		VARCHAR2(10) CONSTRAINT pro_no_nulo NOT NULL,
	FechaVenta 		DATE,
	UnidadesVendidas	NUMBER(3),
	PRIMARY KEY (CodVenta)
);

INSERT INTO productos VALUES ('1','Procesador P133', 'Proc',15000,20);
INSERT INTO productos VALUES ('2','Placa base VX',   'PB',  18000,15);
INSERT INTO productos VALUES ('3','Simm EDO 16Mb',   'Memo', 7000,30);
INSERT INTO productos VALUES ('4','Disco SCSI 4Gb',  'Disc',38000, 5);
INSERT INTO productos VALUES ('5','Procesador K6-2', 'Proc',18500,10);
INSERT INTO productos VALUES ('6','Disco IDE 2.5Gb', 'Disc',20000,25);
INSERT INTO productos VALUES ('7','Procesador MMX',  'Proc',15000, 5);
INSERT INTO productos VALUES ('8','Placa Base Atlas','PB',  12000, 3);
INSERT INTO productos VALUES ('9','DIMM SDRAM 32Mb', 'Memo',17000,12);
 
INSERT INTO ventas VALUES('V1', '2', '22/09/97',2);
INSERT INTO ventas VALUES('V2', '4', '22/09/97',1);
INSERT INTO ventas VALUES('V3', '6', '23/09/97',3);
INSERT INTO ventas VALUES('V4', '5', '26/09/97',5);
INSERT INTO ventas VALUES('V5', '9', '28/09/97',3);
INSERT INTO ventas VALUES('V6', '4', '28/09/97',1);
INSERT INTO ventas VALUES('V7', '6', '02/10/97',2);
INSERT INTO ventas VALUES('V8', '6', '02/10/97',1);
INSERT INTO ventas VALUES('V9', '2', '04/10/97',4);
INSERT INTO ventas VALUES('V10','9', '04/10/97',4);
INSERT INTO ventas VALUES('V11','6', '05/10/97',2);
INSERT INTO ventas VALUES('V12','7', '07/10/97',1);
INSERT INTO ventas VALUES('V13','4', '10/10/97',3);
INSERT INTO ventas VALUES('V14','4', '16/10/97',2);
INSERT INTO ventas VALUES('V15','3', '18/10/97',3);
INSERT INTO ventas VALUES('V16','4', '18/10/97',5);
INSERT INTO ventas VALUES('V17','6', '22/10/97',2);
INSERT INTO ventas VALUES('V18','6', '02/11/97',2);
INSERT INTO ventas VALUES('V19','2', '04/11/97',3);
INSERT INTO ventas VALUES('V20','9', '04/12/97',3);

-- 3.2. A) Crear un procedimiento que actualice el stock de la tabla prodcutos
-- a partir de la tabla ventas. El procedimiento debe avisar si alguna de
-- tablas esta vacia y si el stock es negativo en algun producto debe detenerse.

CREATE OR REPLACE PROCEDURE Act_Stock is
  num_productos NUMBER:=0;
  num_ventas  NUMBER:=0;
  CURSOR cursorVentas IS SELECT CODPRODUCTO, SUM(UNIDADESVENDIDAS) CANTIDAD
                         FROM VENTAS 
                         GROUP BY CODPRODUCTO;
  ventasAct cursorVentas%ROWTYPE;
BEGIN
   SELECT COUNT(*) INTO num_productos
   FROM PRODUCTOS;
   SELECT COUNT(*) INTO num_ventas
   FROM VENTAS;   
   IF ((num_productos>0) AND (num_ventas>0)) THEN
      OPEN cursorVentas;
      FETCH cursorVentas INTO ventasAct;
      WHILE cursorVentas%FOUND LOOP
        ActualizarStock(ventasAct.CODPRODUCTO, ventasAct.CANTIDAD);
        FETCH cursorVentas INTO ventasAct;
      END LOOP;
      CLOSE cursorVentas;
   ELSIF ((num_productos=0) AND (num_ventas=0)) THEN
      DBMS_OUTPUT.PUT_LINE('Las Tablas Productos y Ventas estan vacías.');
      
   ELSIF (num_productos=0) THEN
      DBMS_OUTPUT.PUT_LINE('La Tabla Productos esta vacía.');
      
   ELSE
      DBMS_OUTPUT.PUT_LINE('La Tabla ventas esta vacía.');
   END IF;
END Act_Stock;

CREATE OR REPLACE PROCEDURE ActualizarStock(codprod PRODUCTOS.CODPRODUCTO%TYPE, cant NUMBER) IS
    stock_actu     NUMBER:=0;
    stock_anterior NUMBER:=0;
    stock_negativo EXCEPTION;
    nombreprod PRODUCTOS.NOMBRE%TYPE;
BEGIN
    SELECT STOCK, NOMBRE
    INTO stock_anterior, nombreprod
    FROM PRODUCTOS
    WHERE CODPRODUCTO = codprod;
    stock_actu:= stock_anterior - cant;
    IF (stock_actu <0) THEN
      RAISE stock_negativo;
    END IF;
    UPDATE PRODUCTOS 
    SET STOCK = stock_actu
    WHERE CODPRODUCTO=codprod;
    DBMS_OUTPUT.PUT_LINE('Producto Actualizado.');
EXCEPTION
    WHEN stock_negativo THEN
        DBMS_OUTPUT.PUT_LINE('Stock negativo en producto ' || codprod || '.' || nombreprod );
    WHEN OTHERS THEN
        NULL;        
END ActualizarStock;


-- b) Crear un procedimiento que muestre las ventas.

CREATE OR REPLACE PROCEDURE ListadoVentas IS
  importeTotal NUMBER:=0;
  totalVentas NUMBER:=0;
  CURSOR CursorVentas IS SELECT A.CodProducto, MIN(B.Nombre) Nombre, MIN(B.LINEAPRODUCTO) LineaProducto
                      FROM VENTAS A INNER JOIN PRODUCTOS B ON A.CodProducto = B.CodProducto
                      GROUP BY A.CodProducto
                      ORDER BY A.CodProducto;   
  ventasTotales CursorVentas%ROWTYPE;
BEGIN
  OPEN CursorVentas;
  FETCH CursorVentas INTO ventasTotales;
  WHILE CursorVentas%FOUND LOOP
    ImporteTotal:=0;
    DBMS_OUTPUT.PUT_LINE(ventasTotales.LineaProducto || ': ' || ventasTotales.Nombre);
    MostrarLinea(ventasTotales.CodProducto, importeTotal);
    DBMS_OUTPUT.PUT_LINE('Importe Total de ' || ventasTotales.Nombre || ': ' || TO_CHAR(importeTotal,'FM999G999L'));
    totalVentas:= totalVentas + importeTotal;
    DBMS_OUTPUT.PUT_LINE(CHR(13));
    FETCH CursorVentas INTO ventasTotales;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Total de Ventas: ' || TO_CHAR(totalVentas,'FM999G999G999L'));
END ListadoVentas;

CREATE OR REPLACE PROCEDURE MostrarLinea (numProd PRODUCTOS.CODPRODUCTO%TYPE, importeT IN OUT NUMBER) IS
    indice NUMBER:=0;
    CURSOR CursorLineaVentas IS SELECT A.CodVenta, A.UnidadesVendidas Cantidad, (A.UnidadesVendidas*B.PrecioUnitario) Importe 
                        FROM VENTAS A INNER JOIN PRODUCTOS B ON A.CodProducto = B.CodProducto AND A.CodProducto=numProd
                        ORDER BY A.FechaVenta;
    linea CursorLineaVentas%ROWTYPE;
BEGIN
  OPEN CursorLineaVentas;
  FETCH CursorLineaVentas INTO linea;
  WHILE CursorLineaVentas%FOUND LOOP
    indice:= indice+1;
    DBMS_OUTPUT.PUT_LINE(CHR(9) || indice || '. ' || linea.CodVenta || CHR(9) || linea.Cantidad || CHR(9) || TO_CHAR(linea.Importe,'FM999G999L'));
    importeT := importeT + linea.Importe;
    FETCH CursorLineaVentas INTO linea;
  END LOOP;
END MostrarLinea;


-- 3.3.1 Crear un procedimiento que muestre los usuarios que tienen asigando un determinado rol.

CREATE OR REPLACE PROCEDURE Mostrar_Usuarios_ConRol (rol USER_ROLE_PRIVS.GRANTED_ROLE%TYPE) IS
  CURSOR cursorRol IS SELECT username Nombre 
                      FROM user_role_privs
                      WHERE UPPER(granted_role) = TRIM(UPPER(rol));
  tiporol cursorRol%ROWTYPE;
  contarRol NUMBER;
BEGIN
  SELECT COUNT(*) INTO contarRol
  FROM user_role_privs
  WHERE UPPER(granted_role) = TRIM(UPPER(rol));
  IF (contarRol>0) THEN
      OPEN cursorRol;
      FETCH cursorRol INTO tipoRol;
      DBMS_OUTPUT.PUT_LINE('LISTADO DE USUARIOS CON ROL ' || UPPER(rol));
      DBMS_OUTPUT.PUT_LINE(LPAD('-', 28 + LENGTH(rol),'-'));
      DBMS_OUTPUT.PUT_LINE(CHR(13));
      WHILE cursorRol%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(tipoRol.Nombre);
        FETCH cursorRol INTO tipoRol;
      END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Rol no válido.');
  END IF;
END Mostrar_Usuarios_ConRol;

-- 3.3.2 Crea un procedimiento que muestre los privilegios de un determinado rol.

CREATE OR REPLACE PROCEDURE Mostrar_Privi_ConRol (rol ROLE_SYS_PRIVS.PRIVILEGE%TYPE) IS
  CURSOR cursorRol IS SELECT privilege Privilegio 
                      FROM role_sys_privs
                      WHERE UPPER(role) = UPPER(TRIM(rol));
  tiporol cursorRol%ROWTYPE;
  contarRol NUMBER;
BEGIN
  SELECT COUNT(*) INTO contarRol
  FROM role_sys_privs
  WHERE UPPER(role) = UPPER(TRIM(rol));
  IF (contarRol>0) THEN
      OPEN cursorRol;
      FETCH cursorRol INTO tipoRol;
      DBMS_OUTPUT.PUT_LINE('LISTADO DE LOS PRIVILEGIOS DEL ROL ' || UPPER(rol));
      DBMS_OUTPUT.PUT_LINE(LPAD('-', 35 + LENGTH(rol),'-'));
      DBMS_OUTPUT.PUT_LINE(CHR(13));
      WHILE cursorRol%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(tipoRol.Privilegio);
        FETCH cursorRol INTO tipoRol;
      END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Rol no válido.');
  END IF;
END Mostrar_Privi_ConRol;

/* 3.5.1. - Realiza un trigger que cada vez que se inserten o modifiquen los datos 
de una venta, actualice de forma automática la columna stock de la tabla 
productos y compruebe si el stock pasa a estar por debajo del umbral de pedido.
Si se da este caso, debe insertarse un registro en la tabla Ordenes de Pedido de 
forma que se pidan las unidades necesarias para restablecer el stock al triple 
del valor señalado en el umbral de pedido. */

DROP TABLE ordenespedido CASCADE CONSTRAINTS;

CREATE TABLE ordenespedido
(
	CodPedido 	NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
	CodProducto VARCHAR2(10) CONSTRAINT ped_codprod_no_nulo NOT NULL,
  NumUnidades NUMBER(6),
  Servido NUMBER(1) DEFAULT 0  CONSTRAINT ped_servido NOT NULL,
	PRIMARY KEY (CodPedido)
);

CREATE OR REPLACE TRIGGER RealizarOrdenPedido
AFTER INSERT OR UPDATE ON ventas
FOR EACH ROW
DECLARE
  stockUmbral CONSTANT NUMBER(2) := 2; -- Estipulo que este es el umbral para todos mis productos.
  stockActu   PRODUCTOS.STOCK%TYPE:= 0;
  cont NUMBER :=0;
BEGIN
  SELECT COUNT(*) INTO cont
  FROM PRODUCTOS
  WHERE CODPRODUCTO = :NEW.CodProducto;
  IF (cont>0) THEN
    SELECT Stock INTO stockActu
    FROM PRODUCTOS
    WHERE CodProducto = :NEW.CodProducto;
    stockActu := stockActu - :NEW.UnidadesVendidas;
    IF (stockActu<0) THEN
      stockActu:=0;
    END IF;
    ActualizarStock(:NEW.CodProducto,:NEW.UnidadesVendidas);
    IF (stockActu<stockUmbral) THEN
        INSERT INTO ordenespedido 
        (CodProducto,NumUnidades)
        VALUES
        (:NEW.CodProducto,stockUmbral*3);
        DBMS_OUTPUT.PUT_LINE('Insertada Orden de Pedido.');
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Producto no válido.');
  END IF;
END;


/*3.5.2. - Realiza un trigger que en el momento en que una orden de pedido se 
marque como servida se actualizara el stock del producto corrrespondiente.*/

CREATE OR REPLACE TRIGGER ActuProdPedido
AFTER INSERT OR UPDATE ON ordenespedido
FOR EACH ROW
BEGIN
    IF (:NEW.Servido=1) THEN
        UPDATE productos SET Stock = Stock + :NEW.NumUnidades
        WHERE CodProducto=:NEW.CodProducto;
        DBMS_OUTPUT.PUT_LINE('Producto Servido.');
    END IF;
END;

/*3.5.3. - El trigger envía un correo electrónico a la dirección del proveedor 
correspondiente, registrada en la tabla Proveedores.*/

DROP TABLE Proveedor cascade constraints;

CREATE TABLE Proveedor
(
  CODPROVEEDOR VARCHAR2(10) CONSTRAINT prov_codp_no_nulo NOT NULL,
  APENOM       VARCHAR2(30),
  DNI          VARCHAR2(10) CONSTRAINT prov_DNI_no_nulo NOT NULL,
  EMAIL        VARCHAR2(20),
  DIREC        VARCHAR2(30),
  POBLA        VARCHAR2(15),
  TELEF        VARCHAR2(10), 
  PRIMARY KEY (CODPROVEEDOR)
)

CREATE OR REPLACE PROCEDURE ENVIAREMAIL(
   EMAIL IN VARCHAR2, 
   ASUNTO    IN VARCHAR2, 
   MENSAJE   IN VARCHAR2, 
   HOST      IN VARCHAR2
) 
IS 
  mailhost     VARCHAR2(30) := ltrim(rtrim(HOST)); 
  mail_conn    utl_smtp.connection;  
  mesg VARCHAR2( 1000 ); 
BEGIN 
  mail_conn := utl_smtp.open_connection(mailhost, 25); 
  mesg:= 'Fecha: ' || TO_CHAR( SYSDATE, 'DD MON YY HH24:MI:SS' ) || CHR( 13 ) || CHR( 10 ) || 
         'Asunto: '|| ASUNTO || CHR( 13 ) || CHR( 10 ) || 
         'Para: '|| EMAIL || CHR( 13 ) || CHR( 10 ) || 
         '' || CHR( 13 ) || CHR( 10 ) || MENSAJE; 
 
  utl_smtp.helo(mail_conn, mailhost);   
  utl_smtp.rcpt(mail_conn, EMAIL); 
  utl_smtp.data(mail_conn, mesg);   
  utl_smtp.quit(mail_conn);  
  DBMS_OUTPUT.PUT_LINE('Email Enviado.');
END; 

CREATE OR REPLACE TRIGGER envioProveedor
AFTER INSERT OR UPDATE OF EMAIL ON Proveedor
FOR EACH ROW
BEGIN
    IF (LENGTH(:NEW.EMAIL)>0) THEN
      ENVIAREMAIL (:NEW.EMAIL, 'Envio Pedido', 'Pedido envidado, espero recibirlo lo más pronto posible.', 'mail.gmail.com');
    END IF;
END;

SET TERMOUT ON
SET ECHO ON