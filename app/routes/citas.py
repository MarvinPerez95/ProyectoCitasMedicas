from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.cita import Cita
from app.models.doctor import Doctor
from app.models.especialidad import Especialidad
from app.models.paciente import Paciente

citas_bp = Blueprint('citas', __name__, url_prefix = '/')

"""Rutas de citas frond"""
@citas_bp.route('/', methods = ['GET'])
def iniciocitas(): #ruta principal
    especialidad = Especialidad.get_all()
    return render_template("citas/cita.html", especialidad= especialidad)

@citas_bp.route('/view', methods = ['GET'])
def iniciocitasView(): #Lista de Citas
    return render_template("citas/cita.html")

@citas_bp.route('/agregarC/', methods = ['GET'])
def nueva_cita(): #Creacion de Cita
    paciente = Paciente.get_all()
    doctor = Doctor.get_all()
    return render_template("citas/nueva_cita.html", paciente = paciente, doctor = doctor)

@citas_bp.route('/actualizarC/<int:id>', methods=['GET'])
def actualizar_cita(id): #Actualizacion de Cita
    cita = Cita.get_by_Citaid(id)
    doctor = Doctor.get_all()
    paciente = Paciente.get_all()
    return render_template('/citas/actualizar_cita.html',cita = cita, doctor = doctor, paciente = paciente)

@citas_bp.route('/eliminarC/<int:id>', methods = ['DELETE'])
def eliminar_cita(id): #Desactivar Cita
    cita = Cita.get_all(id)
    return render_template("citas/citas.html", cita = cita)



"""Rutas CRUD de citas Back API (EmdPoints)"""
@citas_bp.route('/c', methods =['GET'])
def get_citas():     #Obtener todos los Citas
    try:
        citas = Cita.get_all()
        data = []

        for c in citas:
            data.append({
                "CitaID": c['CitaID'],
                "NombrePaciente": c['NombrePaciente'],
                "NombreMedico": c['NombreMedico'],
                "Especialidad": c['Especialidad'],
                "Fecha": c['Fecha'].strftime('%Y-%m-%d') if c['Fecha'] else "",
                "Hora": c['Hora'].strftime('%H:%M') if c['Hora'] else "",
                "Motivo": c['Motivo'],
                "Estado": c['Estado'],
                "Observaciones": c['Observaciones'],
                "FechaCreacion": c['FechaCreacion'].strftime('%Y-%m-%d') if c['FechaCreacion'] else ""
            })

        return jsonify(data), 200
        #return jsonify(citas), 200
    except Exception as e:
        return jsonify({"Error:": str(e)}),500
    
@citas_bp.route('/', methods=['POST'])
def create_cita():    #Crear nueva Cita
    try:
        data = request.form
        cita = Cita(
            PacienteID=data.get('pacienteID'),
            MedicoID=data.get('MedicoID'),
            Fecha=data.get('fecha'),
            Hora=data.get('hora'),
            Motivo=data.get('motivo'),
            Observaciones=data.get('observaciones')
        )
        print (cita.pacienteId, cita.medicoID)
        cita.save()
        return redirect(url_for('citas.iniciocitasView'))
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@citas_bp.route('/c/<int:id>', methods=['POST'])
def update_cita(id):  #Actualizar un Cita
    try:
        data = request.form
        cita = Cita(
            id=id,
            PacienteID=data.get('pacienteID'),
            MedicoID=data.get('MedicoID'),
            Fecha=data.get('fecha'),
            Hora=data.get('hora'),
            Motivo=data.get('motivo'),
            Estado=data.get('estado'),
            Observaciones=data.get('observaciones')
        )
        cita.save()
        return redirect(url_for('citas.iniciocitasView'))
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@citas_bp.route('/c/<int:id>', methods=['DELETE'])
def get_delete(id):     #Desactivar una cita
    try:
        cita = Cita.delete(id)

        if not cita:
            return jsonify({"error": "cita no encontrado"}), 404

        if cita:
            return jsonify({"message": "Cita cancelada correctamente"}), 200
        else:
            return jsonify({"error": "No fue posible cancelar la Cita"}), 500
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500