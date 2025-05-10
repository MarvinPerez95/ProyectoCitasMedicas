from app.utils.database import execute_stored_procedure, execute_query
class Paciente:
    def __init__(self, id=None, Nombre = None, Apellidos= None, FechaNacimiento = None, 
                 Genero = None, Direccion = None, Telefono = None, Email = None,
                 fechaRegistro = None, Estado = None ):
        self.id = id
        self.nombre = Nombre
        self.apellido = Apellidos
        self.fechaNacimiento = FechaNacimiento
        self.genero = Genero
        self.direccion = Direccion
        self.telefono = Telefono
        self.email = Email
        self.fechaRegistro = fechaRegistro
        self.estado = Estado
    
    @staticmethod
    def get_all():
        """Obtener todos los Pacientes"""
        return execute_stored_procedure('sp_ObtenerPacientes')
    
    @staticmethod
    def get_by_id(paciente_id):
        """Obtener un paciente por ID"""
        result = execute_stored_procedure('sp_ObtenerPacientePorID', [paciente_id])
        return result[0] if result else None

    def save(self):
        """Crear o actualizar un paciente"""
        if self.id is None: #Crear
            result = execute_stored_procedure('sp_CrearPaciente',
                                            [self.nombre, self.apellido,self.fechaNacimiento,
                                            self.genero, self.direccion, self.telefono,
                                            self.email])
            if result:
                self.id = result[0]['PacienteID']
            return result
        elif (self):
            return execute_stored_procedure('sp_ActualizarPaciente',
                                            [self.id, self.nombre, self.apellido,self.fechaNacimiento,
                                            self.genero, self.direccion, self.telefono, self.email, self.estado ])

    #Agregado
    @classmethod
    def delete(cls,id):
        """Eliminar Paciente""" # Eliminacion logica
        paciente = execute_stored_procedure('sp_EliminarPaciente',[id])
        if not paciente:
            return False
        paciente['Estado'] = False
        return paciente
    