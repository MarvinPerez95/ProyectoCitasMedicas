import os
from dotenv import load_dotenv
# Cargar variables de entorno
load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'clave-secreta-por-defecto'
    DB_SERVER = os.environ.get('DESKTOP-MIF1BOH')
    DB_NAME = os.environ.get('GestionCitasMedicas')
    DB_USER = os.environ.get('dbAdmin')
    DB_PASSWORD = os.environ.get('dbAdmin')
    SQLALCHEMY_DATABASE_URI = f'mssql+pyodbc://{DB_USER}:{DB_PASSWORD}@{DB_SERVER}/{DB_NAME}?driver=ODBC+Driver+17+for+SQL+Server'