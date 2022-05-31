/*
DROP DATABASE IF EXISTS  NOSARCO;
CREATE DATABASE NOSARCO;
*/
USE raia64mmpqm1hqos;

DROP TABLE IF EXISTS EMPLEADO;
CREATE TABLE EMPLEADO(
    type_user int,
    nombre varchar(50),
    apellido_paterno varchar(50),
    apellido_materno varchar(50),
    psw varchar(50)
);

DROP TABLE IF EXISTS VENTA_CAJAS;
CREATE TABLE VENTA_CAJAS(
	folio int primary key,
	caja int,
    num_empleado int,
    venta decimal(10,2),
    turno varchar(10),
    fecha date,
    FOREIGN KEY (num_empleado) REFERENCES EMPLEADO(num_empleado) 
);

DROP TABLE IF EXISTS BITACORA_ENTRADA;
CREATE TABLE BITACORA_ENTRADA(
	num_empleado int,
    hora timestamp,
    FOREIGN KEY (num_empleado) REFERENCES EMPLEADO(num_empleado) 
); 

DROP TABLE IF EXISTS HORARIO;
CREATE TABLE HORARIO(
    semana varchar(20) primary key,
    horario json
); 

/*		PROCEDURE DE USUARIOS		*/
drop procedure if exists sp_addUser;
delimiter **
create procedure sp_addUser(xnumEmp int, xnom varchar(50), xaPat varchar(50), xaMat varchar(50), xpsw varchar(50), xtype int)
begin 
declare msj varchar(50);
declare existencia int;
	set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp);
    if( existencia = 0) then
		insert into EMPLEADO(num_empleado, nombre, apellido_paterno, apellido_materno, psw, type_user)
        values(xnumEmp, xnom, xaPat, xaMat, xpsw, xtype);
        set msj = "Usuario agregado";
	else	
		set msj = "Error";
    end if;
select msj as Resultado;
end; **
delimiter ;
-- CALL sp_addUser(2, 'Fulanito', 'Fulanito', 'Fulanito', 'root', 1);

drop procedure if exists sp_deleteUser;
delimiter **
create procedure sp_deleteUser(xnumEmp int )
begin 
declare msj varchar(50);
declare existencia int;
	set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp);
	if(existencia = 0)then 
		set msj = "No hay Usuario";
	end if;
    delete from EMPLEADO where num_empleado = xnumEmp;
end; **
delimiter ;
-- CALL sp_deleteUser(2);

drop procedure if exists sp_updateUser;
delimiter **
create procedure sp_updateUser(xnumEmp int, xnom varchar(50), xaPat varchar(50), xaMat varchar(50), xpsw varchar(50), xtype int)
begin 
declare msj varchar(50);
	update EMPLEADO set nombre = xnom, apellido_paterno = xaPat, apellido_materno = xaMat, psw = xpsw, type_user = xtype where xnumEmp = num_empleado; 
	set msj = "Usuario actualizado";
    select msj as Resultado;
end; **
delimiter ;
-- CALL sp_updateUser(12345,'Sandy', 'Cespedes', 'Guerrero', '12345', 1);

drop procedure if exists sp_login;
delimiter **
create procedure sp_login(xnumEmp varchar(50), xpsw varchar(50))
begin
declare msj varchar(50);
declare existencia int;
    set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp and psw = xpsw);
    if( existencia = 0 )then
        set msj = "NO INICIAR";
	else	
		set msj = (select num_empleado from EMPLEADO where  num_empleado = xnumEmp and psw = xpsw);
    end if;
select msj as num_empleado, CAST(type_user AS UNSIGNED) AS type_user from EMPLEADO where num_empleado = xnumEmp and psw = xpsw;
end; **
delimiter ;
-- CALL sp_login(1, 'root');
/*		FIN PROCEDURE DE USUARIOS		*/

/*		PROCEDURE DE ENTRADA		*/
drop procedure if exists sp_checkIn;
delimiter **
create procedure sp_checkIn(xnumEmp int )
begin 
declare msj varchar(50);
declare existencia int;
    set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp);
    if( existencia = 0 )then
        set msj = "ERROR";
	else	
		insert into BITACORA_ENTRADA(num_empleado, hora) values (1, now());
		select * from BITACORA_ENTRADA;
        set msj = "Entrada registrada";
    end if;
select msj as Resultado;
end; **
delimiter ;
-- CALL sp_checkIn(1);


/*		PROCEDURE DE VENTAS		*/
drop procedure if exists sp_registrar_venta;
delimiter **
create procedure sp_registrar_venta(xnumEmp int, xcaja int, xventa decimal(10,2), xturno varchar(10), xfecha date)
begin 
declare folio int;
	set folio = ((select count(*) from VENTA_CAJAS)+1);
	insert into VENTA_CAJAS(folio, num_empleado, caja, venta, turno, fecha)
    values(folio, xnumEmp, xcaja, xventa, xturno, xfecha);
end; **
delimiter ;
CALL sp_registrar_venta(12345, 1, 10500.50, 'Matutino', '2022-05-02');

drop procedure if exists sp_editar_venta;
delimiter **
create procedure sp_editar_venta(xnumEmp int, xcaja int, xventa decimal(10,2), xturno varchar(10), xfecha date, xfolio int)
begin 
	UPDATE VENTA_CAJAS set caja = xcaja, num_empleado = xnumEmp, venta = xventa, turno = xturno, fecha = xfecha where folio = xfolio;
end; **
delimiter ;
CALL sp_editar_venta(12345, 1, 10500.50, 'Matutino', '2022-05-02', 1);

drop procedure if exists sp_borrar_venta;
delimiter **
create procedure sp_borrar_venta(xfolio int )
begin 
declare msj varchar(50);
declare existencia int;
	set existencia = (select count(*) from VENTA_CAJAS where folio = xfolio);
	if(existencia = 0)then 
		set msj = "ERROR";
	end if;
    delete from VENTA_CAJAS where folio = xfolio;
end; **
delimiter ;
CALL sp_borrar_venta(2);

DROP VIEW IF EXISTS VENTAS;
CREATE VIEW VENTAS AS
    SELECT caja, concat(EMPLEADO.nombre, ' ', EMPLEADO.apellido_paterno, ' ', EMPLEADO.apellido_materno) as nombre, venta, turno, fecha, EMPLEADO.num_empleado, folio
    FROM VENTA_CAJAS
	INNER JOIN EMPLEADO ON VENTA_CAJAS.num_empleado = EMPLEADO.num_empleado;

SELECT num_empleado, concat(EMPLEADO.nombre, ' ', EMPLEADO.apellido_paterno, ' ', EMPLEADO.apellido_materno) as nombre from EMPLEADO;

DROP PROCEDURE IF EXISTS sp_horario;
delimiter **
CREATE PROCEDURE sp_horario(in xsemana varchar(10))
begin
declare existencia int;
	set existencia = (SELECT count(*) FROM HORARIO WHERE semana = xsemana);
    if (existencia = 0) then
		INSERT INTO HORARIO VALUES(xsemana, '{"horario":[[[],[],[],[],[],[]],[[],[],[],[],[],[]],[[],[],[],[],[],[]],[[],[],[],[],[],[]],[[],[],[],[],[],[]],[[],[],[],[],[],[]],[[],[],[],[],[],[]]]}');
	end if;
end; **
delimiter ;
call sp_horario('2022-22');

DROP PROCEDURE IF EXISTS sp_updateHorario;
delimiter **
CREATE PROCEDURE sp_updateHorario(in xsemana varchar(10), in xhorario json)
begin
	update HORARIO set horario = xhorario WHERE semana = xsemana;
end; **
delimiter ;
call sp_updateHorario('2022-2', '{"horario": [[[{"num_empleado": "1", "name_empleado": "Empleado Cespedes Guerrero"}, {"num_empleado": "123", "name_empleado": "prueba Paterno Materno"}], [], [], [], [], []], [[], [], [], [], [], []], [[], [], [], [], [], []], [[], [], [], [], [], []], [[], [], [], [], [], []], [[], [], [], [], [], []], [[], [], [], [], [], []]]}');
