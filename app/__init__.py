from flask import Flask
from config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Registrar blueprints
    from app.routes.main import mainpage_bp as mainpage_bp
    app.register_blueprint(mainpage_bp, url_prefix = '/')

    from app.routes.especialidades import especialidades_bp as especialidades_bp
    app.register_blueprint(especialidades_bp, url_prefix='/especialidades')
    
    from app.routes.medicos import medicos_bp as medicos_bp
    app.register_blueprint(medicos_bp, url_prefix='/medicos')

    from app.routes.pacientes import pacientes_bp as pacientes_bp
    app.register_blueprint(pacientes_bp, url_prefix='/pacientes')

#    from app.routes.citas import citas_dp as citas_dp
#    app.register_blueprint(citas_dp, url_prefix='/app/citas')
    
    return app