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
    
    from app.routes.doctores import doctor_bp as doctor_bp
    app.register_blueprint(doctor_bp, url_prefix='/doctores')

    from app.routes.pacientes import pacientes_bp as pacientes_bp
    app.register_blueprint(pacientes_bp, url_prefix='/pacientes')

    from app.routes.citas import citas_bp as citas_bp
    app.register_blueprint(citas_bp, url_prefix='/citas')
    
    return app