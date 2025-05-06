from flask import Flask
from config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Registrar blueprints
    from app.routes.main import mainpage_dp as mainpage_bp
    app.register_blueprint(mainpage_bp, url_prefix = '/')

    from app.routes.especialidades import especialidades_dp as especialidades_bp
    app.register_blueprint(especialidades_bp, url_prefix='/api/especialidades')
    
    from app.routes.medicos import medicos_dp as medicos_bp
    app.register_blueprint(medicos_bp, url_prefix='/api/medicos')

    from app.routes.pacientes import pacientes_dp as pacientes_db
    app.register_blueprint(pacientes_db, url_prefix='/app/pacientes')

#    from app.routes.citas import citas_dp as citas_dp
#    app.register_blueprint(citas_dp, url_prefix='/app/citas')
    
    return app