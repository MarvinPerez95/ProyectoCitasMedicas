
from app.utils.database import execute_stored_procedure, execute_query
class login:
    def __init__(self, id=None, Nombre = None, Apellidos= None, Email = None, Clave = None):
        self.id = id
        self.nombre = Nombre
        self.apellido = Apellidos
        self.clave = Clave
        self.email = Email
        
    @staticmethod
    def getUsuarioClave(Email,Clave):
        """Obtener un paciente por ID"""
        result = execute_stored_procedure('sp_ValidarUsuario', [Email],[Clave])
        return result['Autenticado'] if result else None