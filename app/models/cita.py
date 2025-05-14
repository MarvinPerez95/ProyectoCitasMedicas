from app.utils.database import execute_stored_procedure

class Cita:
    def __init__(self, id=None, PacienteID=None, MedicoID=None, Fecha =None, Hora = None,
                Motivo=None, Estado=None, Observaciones=None, FechaCreacion = None):
        self.id = id
        self.pacienteId = PacienteID
        self.medicoID = MedicoID
        self.fecha = Fecha
        self.hora = Hora
        self.motivo = Motivo
        self.estado = Estado
        self.observaciones = Observaciones
        self.fechaCreacion = FechaCreacion
        
    @staticmethod
    def get_all():
        """Obtiene todas las Citas"""
        return execute_stored_procedure('sp_ObtenerCitas')
    
    @staticmethod
    def get_by_Doctorid(medicoID):
        """Obtiene un médico por su ID"""
        result = execute_stored_procedure('sp_ObtenerMedicoPorID', [medicoID])
        return result[0] if result else None
    
    @staticmethod
    def get_by_Pacienteid(pacienteId):
        """Obtiene un médico por su ID"""
        result = execute_stored_procedure('sp_ObtenerMedicoPorID', [pacienteId])
        return result[0] if result else None
    
    @staticmethod
    def get_by_Citaid(citaID):
        """Obtiene un médico por su ID"""
        result = execute_stored_procedure('sp_ObtenerCitasPorCitaID', [citaID])
        return result[0] if result else None
    
    def save(self):
        """Crea o actualiza una Cita"""
        if self.id is None: 
            # Crear nueva cita
            result = execute_stored_procedure('sp_CrearCita', 
                                           [self.pacienteId, self.medicoID, 
                                            self.fecha, self.hora, 
                                            self.motivo, self.observaciones])
            if result:
                self.id = result[0]['CitaID']
            return result
        else:
            # Actualizar médico existente
            return execute_stored_procedure('sp_ActualizarCita', 
                                          [self.id, self.pacienteId, self.medicoID, 
                                           self.fecha, self.hora, 
                                           self.motivo, self.estado,self.observaciones])

    def actualizarEstadoCita(self):
        result = execute_stored_procedure('sp_ActualizarEstadoCita',
                                          [self.id, self.estado, self.observaciones])
        return result


   #Agregado 
    @classmethod
    def delete(cls,id):
        """Eliminar Medico""" # Eliminacion logica
        cita = execute_stored_procedure('sp_EliminarCita',[id])
        if not cita:
            return False
        return cita['Estado']
        