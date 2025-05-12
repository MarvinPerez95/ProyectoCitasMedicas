from app.utils.database import execute_stored_procedure, execute_query

class Doctor:
    def __init__(self, id=None, Nombre=None, Apellidos=None, EspecialidadID =None, Especialidad=None, 
                Telefono=None, Email=None, Estado=True):
        self.id = id
        self.nombre = Nombre
        self.apellidos = Apellidos
        self.especialidad = Especialidad
        self.especialidadID = EspecialidadID
        self.telefono = Telefono
        self.email = Email
        self.estado = Estado
        
    @staticmethod
    def get_all():
        """Obtiene todos los médicos"""
        return execute_stored_procedure('sp_ObtenerMedicos')
    
    @staticmethod
    def get_by_id(medico_id):
        """Obtiene un médico por su ID"""
        result = execute_stored_procedure('sp_ObtenerMedicoPorID', [medico_id])
        return result[0] if result else None
    
    def save(self):
        """Crea o actualiza un médico"""
        if self.id is None: 
            # Crear nuevo médico
            result = execute_stored_procedure('sp_CrearMedico', 
                                           [self.nombre, self.apellidos, 
                                            self.especialidadID, self.telefono, 
                                            self.email])
            if result:
                self.id = result[0]['MedicoID']
            return result
        else:
            # Actualizar médico existente
            return execute_stored_procedure('sp_ActualizarMedico', 
                                          [self.id, self.nombre, self.apellidos, 
                                           self.especialidadID, self.telefono, 
                                           self.email, self.estado])


   #Agregado 
    @classmethod
    def delete(cls,id):
        """Eliminar Medico""" # Eliminacion logica
        medico = execute_stored_procedure('sp_EliminarMedico',[id])
        if not medico:
            return False
        medico['Estado'] = False
        return medico