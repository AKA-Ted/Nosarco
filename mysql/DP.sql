/*
DROP DATABASE IF EXISTS  NOSARCO;
CREATE DATABASE NOSARCO;
*/
USE raia64mmpqm1hqos;

DROP TABLE IF EXISTS EMPLEADO;
CREATE TABLE EMPLEADO(
	num_empleado int primary key,
    type_user int,
    nombre varchar(50),
    apellido_paterno varchar(50),
    apellido_materno varchar(50),
    psw varchar(50)
);

DROP TABLE IF EXISTS HORARIO;
CREATE TABLE HORARIO(
	num_empleado int,
    entrada timestamp,
    FOREIGN KEY (num_empleado) REFERENCES EMPLEADO(num_empleado) 
);

DROP TABLE IF EXISTS VENTA_CAJAS;
CREATE TABLE VENTA_CAJAS(
	caja int,
    num_empleado int,
    venta decimal(10,2),
    turno varchar(1),
    FOREIGN KEY (num_empleado) REFERENCES EMPLEADO(num_empleado) 
);

DROP TABLE IF EXISTS BITACORA_ENTRADA;
CREATE TABLE BITACORA_ENTRADA(
	num_empleado int,
    hora timestamp,
    FOREIGN KEY (num_empleado) REFERENCES EMPLEADO(num_empleado) 
); 

/*		PROCEDURE DE USUARIOS		*/
drop procedure if exists sp_addUser;
delimiter **
create procedure sp_addUser(xnumEmp int, xnom varchar(50), xaPat varchar(50), xaMat varchar(50), xpsw varchar(50), xtype int)
begin 
declare msj varchar(50);
declare existencia int;
declare xnumEmp int;
	set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp);
    if( existencia = 0) then
		set xnumEmp = (select ifnull(max(xnumEmp),0) from EMPLEADO)+1;
		insert into EMPLEADO(num_empleado, nombre, apellido_paterno, apellido_materno, psw, type_user)
        values(xnumEmp, xnom, xaPat, xaMat, xpsw, xtype);
        set msj = "Usuario agregado";
	else	
		set msj = "Error";
    end if;
select msj as Resultado;
end; **
delimiter ;
 CALL sp_addUser(1, 'Fulanito', 'Fulanito', 'Fulanito', 'root', 1);

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
 CALL sp_deleteUser(1);

drop procedure if exists sp_updateUser;
delimiter **
create procedure sp_updateUser(xnom varchar(50), xaPat varchar(50), xaMat varchar(50), xpsw varchar(50), xtype int)
begin 
declare msj varchar(50);
	update EMPLEADO set nombre = xnom, apellido_paterno = xaPat, apellido_materno = xaMat, psw = xpsw, type_user = xtype; 
	set msj = "Usuario actualizado";
    select msj as Resultado;
end; **
delimiter ;
-- CALL sp_updateUser('Fulanito', 'Apellidoprueba', 'Fulanito', 'root', 1);

drop procedure if exists sp_login;
delimiter **
create procedure sp_login(xnumEmp varchar(50), xpsw varchar(50))
begin
declare xnum_empleado int;
declare xtype_user int;
declare xnombre varchar(50);
declare existencia int;
    set existencia = (select count(*) from EMPLEADO where num_empleado = xnumEmp and psw = xpsw);
    if( existencia = 0 )then
        set xnum_empleado = 0;
        set xtype_user = 0;
        set xnombre = 'Error';
	else	
		set xnum_empleado = (select num_empleado from EMPLEADO where  num_empleado = xnumEmp and psw = xpsw);
		set xtype_user = (select type_user from EMPLEADO where num_empleado = xnumEmp and psw = xpsw);
        set xnombre = (SELECT CONCAT(nombre, ' ', apellido_paterno, ' ', apellido_materno) from EMPLEADO where num_empleado = xnumEmp and psw = xpsw);
    end if;
select xnum_empleado as num_empleado, xtype_user as type_user, xnombre as nom_empleado;
end; **
delimiter ;
CALL sp_login(1, 'root');
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
 CALL sp_checkIn(1);
 SELECT * FROM BITACORA_ENTRADA;

/*		PROCEDURE DE VENTAS		*/



