from flask import Blueprint

#Importacion de los blueprints definidos en los archivos
from .main import mainpage_dp
from .especialidades import especialidades_dp
from .medicos import medicos_dp
from .pacientes import pacientes_dp
#from .citas import citas_db


def init_blueprints(app):
    app.register_blueprint(mainpage_dp)
    app.register_blueprint(especialidades_dp)
    app.register_blueprint(medicos_dp)
    app.register_blueprint(pacientes_dp)
#    app.register_blueprint(citas_bp)
