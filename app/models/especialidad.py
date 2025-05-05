from app.utils.database import execute_stored_procedure

class Especialidad:
    def __init__(self, id=None, nombre=None, descripcion=None):
        self.id = id
        self.nombre = nombre
        self.descripcion = descripcion
        
    @staticmethod
    def get_all():
        """Obtiene todas las especialidades"""
        return execute_stored_procedure('sp_ObtenerEspecialidades')
    
    @staticmethod
    def get_by_id(especialidad_id):
        """Obtiene una especialidad por su ID"""
        result = execute_stored_procedure('sp_ObtenerEspecialidadPorID', [especialidad_id])
        return result[0] if result else None
    
    def save(self):
        """Crea o actualiza una especialidad"""
        if self.id:
            # Actualizar especialidad existente
            return execute_stored_procedure('sp_ActualizarEspecialidad', 
                                          [self.id, self.nombre, self.descripcion])
        else:
            # Crear nueva especialidad
            result = execute_stored_procedure('sp_CrearEspecialidad', 
                                           [self.nombre, self.descripcion])
            if result:
                self.id = result[0]['EspecialidadID']
            return result
    
    @staticmethod
    def delete(especialidad_id):
        """Elimina una especialidad por su ID"""
        return execute_stored_procedure('sp_EliminarEspecialidad', [especialidad_id])



