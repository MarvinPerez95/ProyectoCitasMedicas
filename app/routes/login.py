"""from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from routes.login import Login

login_bp = Blueprint('/', __name__, url_prefix = '/')

@login_bp.route('/', methods = ['GET'])
def inicioPacientes():  #Ruta principal
#    paciente = Login.getUsuarioClave(email,clave)
    return render_template("Login/paciente.html",paciente = paciente)


@login_bp.route('/', methods = ['GET'])
def ValidarInicio():  #Ruta principal
#    paciente = Login.getUsuarioClave(email,clave)
    return render_template("Login/paciente.html",paciente = paciente)"""