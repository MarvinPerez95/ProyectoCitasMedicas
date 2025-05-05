from flask import Flask
from config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Registrar blueprints
    from app.routes.especialidades import bp as especialidades_bp
    app.register_blueprint(especialidades_bp, url_prefix='/api/especialidades')
    
    from app.routes.medicos import bp as medicos_bp
    app.register_blueprint(medicos_bp, url_prefix='/api/medicos')

    from app.routes.pacientes import db as pacientes_db
    app.register_blueprint(pacientes_db, url_prefix='/app/pacientes')
    
    return app