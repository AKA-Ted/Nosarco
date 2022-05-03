from multiprocessing import connection
from typing import final
from flask import Flask, render_template, request, redirect, url_for, flash, session
import pymysql
import os

app = Flask(__name__)

app.secret_key = os.getenv("SECRET_KEY")
app.config.from_object(__name__)

app.secret_key = "flash message"

#MySQL
def getConnection():
    connection = pymysql.connect(host='bv2rebwf6zzsv341.cbetxkdyhwsb.us-east-1.rds.amazonaws.com',
            user='rzh1cxyhp1eiwu5g',
            password='dlz55fjlmcun57qn',
            db='raia64mmpqm1hqos')
    return connection

#ENRUTAMIENTO
@app.route('/', methods = ['POST', 'GET'])
def Login():
    if request.method == "GET":
        if 'usuario' in session:
            return redirect(url_for('Index'))
        else:
            return render_template('login.html')

    elif request.method == "POST":
        num_empleado = request.form['num_empleado']
        password = request.form['password']

        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_login(\"{num_empleado}\",\"{password}\")") 
        data = cursor.fetchall()
        connection.close()

        try:
            if (data[0][0]) != 0 :
                session['num_empleado'] = data[0][0]
                session['is_admin'] = True if data[0][1] else False
                session['nom_empleado'] = data[0][2]
                return redirect(url_for('Index'))
            else:
                flash('Credenciales incorrectas')
                return redirect(url_for('Login'))
        except:
            flash('Error')
            return redirect(url_for('Login')) 


@app.route('/logout', methods = ['GET'])
def Logout():
    if request.method == "GET":
        session.pop('num_empleado', None)
        session.pop('is_admin', None)
        return redirect(url_for('Login'))


@app.route('/index', methods = ['POST', 'GET'])
def Index():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    return render_template('index.html', user = session)


@app.route('/ventas' , methods = ['POST', 'GET'])
def Ventas():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    connection = getConnection()
    cursor = connection.cursor() 
    cursor.execute(F"SELECT * FROM VENTAS;") 
    ventas = cursor.fetchall()
    connection.close()

    return render_template('ventas.html', user = session, ventas = ventas)

@app.route('/ventasColaboradores' , methods = ['POST', 'GET'])
def VentasColaboradores():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    num_empleado = session['num_empleado']

    connection = getConnection()
    cursor = connection.cursor() 
    cursor.execute(F"SELECT * FROM VENTAS WHERE num_empleado = \"{num_empleado}\";") 
    ventas = cursor.fetchall()
    connection.close()

    return render_template('ventas.html', user = session, ventas = ventas)


@app.route('/reportes' , methods = ['POST', 'GET'])
def Reportes():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    connection = getConnection()
    cursor = connection.cursor() 
    cursor.execute(F"SELECT * FROM VENTAS;") 
    ventas = cursor.fetchall()
    connection.close()

    return render_template('reportes.html', user = session, ventas = ventas)


@app.route('/colaboradores' , methods = ['POST', 'GET'])
def Colaboradores():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    connection = getConnection()
    cursor = connection.cursor() 
    cursor.execute(F"SELECT * FROM EMPLEADO;") 
    colaboradores = cursor.fetchall()
    connection.close()

    return render_template('colaboradores.html', user = session, colaboradores = colaboradores)


@app.route('/ajustes' , methods = ['POST', 'GET'])
def Ajustes():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    num_empleado = session['num_empleado']

    connection = getConnection()
    cursor = connection.cursor() 
    cursor.execute(F"SELECT * FROM EMPLEADO WHERE num_empleado = \"{num_empleado}\";") 
    colaborador = cursor.fetchall()
    connection.close()

    return render_template('ajustes.html', user = session, colaborador = colaborador)


@app.route('/agregarColaborador' , methods = ['POST', 'GET'])
def agregarColaborador():
    if request.method == "POST":
        num_empleado = request.form['num_empleado']
        nombre = request.form['nombre']
        apellido_paterno = request.form['apellido_paterno']
        apellido_materno = request.form['apellido_materno']
        tipo_usuario = request.form['tipo_usuario']
        password = '12345'
        
        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_addUser(\"{num_empleado}\", \"{nombre}\", \"{apellido_paterno}\", \"{apellido_materno}\", \"{password}\", \"{tipo_usuario}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Colaboradores'))


@app.route('/eliminarColaborador' , methods = ['POST', 'GET'])
def eliminarColaborador():
    if request.method == "POST":
        num_empleado = request.form['num_empleado']

        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_deleteUser(\"{num_empleado}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Colaboradores'))


@app.route('/editarColaborador' , methods = ['POST', 'GET'])
def editarColaborador():
    if request.method == "POST":
        num_empleado = request.form['num_empleado']
        nombre = request.form['nombre']
        apellido_paterno = request.form['apellido_paterno']
        apellido_materno = request.form['apellido_materno']
        tipo_usuario = request.form['tipo_usuario']
        password = request.form['password']
        
        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_updateUser(\"{num_empleado}\", \"{nombre}\", \"{apellido_paterno}\", \"{apellido_materno}\", \"{password}\", \"{tipo_usuario}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Colaboradores'))


@app.route('/editar' , methods = ['POST', 'GET'])
def editar():
    if request.method == "POST":
        num_empleado = request.form['num_empleado']
        nombre = request.form['nombre']
        apellido_paterno = request.form['apellido_paterno']
        apellido_materno = request.form['apellido_materno']
        tipo_usuario = request.form['tipo_usuario']
        password = request.form['password']
        
        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_updateUser(\"{num_empleado}\", \"{nombre}\", \"{apellido_paterno}\", \"{apellido_materno}\", \"{password}\", \"{tipo_usuario}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Ajustes'))


@app.route('/agregarVenta' , methods = ['POST', 'GET'])
def agregarVenta():
    if request.method == "POST":
        caja = request.form['caja']
        num_empleado = request.form['num_empleado']
        venta = request.form['venta']
        turno = request.form['turno']
        fecha = request.form['fecha']
        
        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_registrar_venta(\"{num_empleado}\", \"{caja}\", \"{venta}\", \"{turno}\", \"{fecha}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Ventas'))


@app.route('/editarVenta' , methods = ['POST', 'GET'])
def editarVenta():
    if request.method == "POST":
        caja = request.form['caja']
        num_empleado = request.form['num_empleado']
        venta = request.form['venta']
        turno = request.form['turno']
        fecha = request.form['fecha']
        folio = request.form['folio']

        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_editar_venta(\"{num_empleado}\", \"{caja}\", \"{venta}\", \"{turno}\", \"{fecha}\", \"{folio}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Ventas'))


@app.route('/eliminarVenta' , methods = ['POST', 'GET'])
def eliminarVenta():
    if request.method == "POST":
        folio = request.form['folio']

        connection = getConnection()
        cursor = connection.cursor() 
        cursor.execute(F"CALL sp_borrar_venta(\"{folio}\");") 
        connection.commit()
        connection.close()

        return redirect(url_for('Ventas'))


#MODO DEBUG ACTIVADO
if __name__ == "__main__":
    app.run(debug = True)