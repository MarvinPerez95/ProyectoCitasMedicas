from flask import Blueprint

#Importacion de los blueprints definidos en los archivos
from .main import mainpage_bp
from .especialidades import especialidades_bp
from .medicos import medicos_bp
from .pacientes import pacientes_bp
#from .citas import citas_db


def init_blueprints(app):
    app.register_blueprint(mainpage_bp)
    app.register_blueprint(especialidades_bp)
    app.register_blueprint(medicos_bp)
    app.register_blueprint(pacientes_bp)
#    app.register_blueprint(citas_bp)
