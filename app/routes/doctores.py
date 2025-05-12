from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.doctor import Doctor
from app.models.especialidad import Especialidad

doctor_bp = Blueprint('doctores', __name__, url_prefix = '/')

"""Rutas de doctores frond"""
@doctor_bp.route('/', methods = ['GET'])
def inicioDoctores(): #ruta principal
    return render_template("doctores/doctores.html")

@doctor_bp.route('/view', methods = ['GET'])
def inicioDoctoresView(): #Lista de Docotores
    return render_template("doctores/doc.html")

@doctor_bp.route('/agregarD/', methods = ['GET'])
def nuevo_doctor(): #Creacion de Doctor
    especialidad = Especialidad.get_all()
    return render_template("doctores/nuevo_doctor.html", especialidad = especialidad)

@doctor_bp.route('/actualizarD/<int:id>', methods=['GET'])
def actualizar_doctor(id): #Actualizacion de Doctor
    doctor = Doctor.get_by_id(id)
    especialidades = Especialidad.get_all()
    return render_template('/doctores/actualizar_doctor.html', doctor = doctor, especialidades = especialidades)

@doctor_bp.route('/eliminar/<int:id>', methods = ['DELETE'])
def eliminar_doctor(id): #Desactivar Docotor
    doctor = Doctor.get_all(id)
    return render_template("doctores/doctores.html", doctor = doctor)



"""Rutas CRUD de Doctores Back API (EmdPoints)"""
@doctor_bp.route('/d', methods =['GET'])
def get_doctores():     #Obtener todos los Docotores
    try:
        doctor = Doctor.get_all()
        return jsonify(doctor), 200
    except Exception as e:
        return jsonify({"Error:": str(e)}),500
    
@doctor_bp.route('/', methods=['POST'])
def create_doctor():    #Crear nuevo Doctor
    try:
        data = request.form
        doctor = Doctor(
            Nombre=data.get('nombre'),
            Apellidos=data.get('apellidos'),
            EspecialidadID=data.get('especialidad'),
            Telefono=data.get('telefono'),
            Email=data.get('email'),
            Estado=data.get('estado')
        )
        doctor.save()
        return redirect(url_for('doctores.inicioDoctoresView'))
        #return jsonify({"message": "Doctor agregado", "id": doctor.id}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@doctor_bp.route('/d/<int:id>', methods=['POST'])
def update_doctor(id):  #Actualizar un Docotor
    try:
        data = request.form
        doctor = Doctor(
            id=id,
            Nombre=data.get('nombre'),
            Apellidos=data.get('apellidos'),
            EspecialidadID=data.get('especialidad'),
            Telefono=data.get('telefono'),
            Email=data.get('email'),
            Estado=data.get('estado')
        )
        doctor.save()
        return redirect(url_for('doctores.inicioDoctoresView'))
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@doctor_bp.route('/d/<int:id>', methods=['DELETE'])
def get_delete(id):     #Desactivar un Docotr
    try:
        doctor = Doctor.get_by_id(id)

        if not doctor:
            return jsonify({"error": "Doctor no encontrado"}), 404

        desactivado = Doctor.delete(id)  # Envio del ID del doctor
        print(desactivado)

        if desactivado:
            return jsonify({"error": "No se pudo desactivar al Doctor"}), 500
        else:
            return jsonify({"message": "Doctor desactivado correctamente"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500