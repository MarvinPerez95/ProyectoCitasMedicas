from app.utils.database import execute_stored_procedure, execute_query

class Medico:
    def __init__(self, id=None, nombre=None, apellidos=None, especialidad_id=None, 
                telefono=None, email=None, estado=True):
        self.id = id
        self.nombre = nombre
        self.apellidos = apellidos
        self.especialidad_id = especialidad_id
        self.telefono = telefono
        self.email = email
        self.estado = estado
        
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
        if self.id:
            # Actualizar médico existente
            return execute_stored_procedure('sp_ActualizarMedico', 
                                          [self.id, self.nombre, self.apellidos, 
                                           self.especialidad_id, self.telefono, 
                                           self.email, self.estado])
        else:
            # Crear nuevo médico
            result = execute_stored_procedure('sp_CrearMedico', 
                                           [self.nombre, self.apellidos, 
                                            self.especialidad_id, self.telefono, 
                                            self.email])
            if result:
                self.id = result[0]['MedicoID']
            return result

   #Agregado 
    @staticmethod
    def delete(medico_id):
        """Eliminar Medico"""   #Eliminacion logica
        result = execute_query('update Medicos set estado = 0 where MedicoID = ?', [medico_id])
        return result