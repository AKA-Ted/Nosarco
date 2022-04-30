from typing import final
from flask import Flask, render_template, request, redirect, url_for, flash, session
from flaskext.mysql import MySQL
import pymysql
import os

app = Flask(__name__)

app.secret_key = os.getenv("SECRET_KEY")
app.config.from_object(__name__)

app.secret_key = "flash message"

#MySQL
con = pymysql.connect(host='bv2rebwf6zzsv341.cbetxkdyhwsb.us-east-1.rds.amazonaws.com',
        user='rzh1cxyhp1eiwu5g',
        password='dlz55fjlmcun57qn',
        db='raia64mmpqm1hqos')
mysql = MySQL()
mysql.init_app(app)

#ENRUTAMIENTO
@app.route('/', methods = ['POST', 'GET'])
def Login():
    if request.method == "GET":
        if 'usuario' in session:
            return redirect(url_for('Index'))
        else:
            return render_template('login.html')

    elif request.method == "POST":
        try:
            num_empleado = request.form['num_empleado']
            password = request.form['password']

            with con.cursor() as cursor:
                cursor.execute(F"CALL sp_login(\"{num_empleado}\",\"{password}\")") 
                data = cursor.fetchall()
                con.commit()
                con.close()

                if data[0][0] != 'NO INICIAR' :
                    session['num_empleado'] = data[0][0]
                    session['is_admin'] = True if (data[0][1] == 0) else False
                    return redirect(url_for('Index'))
                else:
                    flash("Datos incorrectos")
                    return redirect(url_for('Login'))
        except:
            flash('Error')
            return redirect(url_for('Login')) 


@app.route('/logout', methods = ['GET'])
def Logout():
    if request.method == "GET":
        session.pop('num_empleado', None)
        session.pop('id_usuario', None)
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

    return render_template('ventas.html')

@app.route('/reportes' , methods = ['POST', 'GET'])
def Reportes():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    return render_template('reportes.html')

@app.route('/colaboradores' , methods = ['POST', 'GET'])
def Colaboradores():
    if 'num_empleado' not in session:
        return redirect(url_for('Login'))

    return render_template('colaboradores.html')

#MODO DEBUG ACTIVADO
if __name__ == "__main__":
    app.run(debug = True)