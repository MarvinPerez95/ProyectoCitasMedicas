from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.doctor import Doctor

doctor_bp = Blueprint('doctores', __name__, url_prefix = '/')

"""Rutas de doctores frond"""
@doctor_bp.route('/', methods = ['GET'])
def inicioDoctores():
    return render_template("doctores/doctores.html")

@doctor_bp.route('/view', methods = ['GET'])
def inicioDoctoresView():
    return render_template("doctores/doc.html")

@doctor_bp.route('/agregarD/', methods = ['GET'])
def nuevo_doctor():
    return render_template("doctores/nuevo_doctor.html")

@doctor_bp.route('/actualizar/<int:id>', methods=['GET'])
def actualizar_doctor(id):
    doctor = Doctor.get_by_id(id)
    return render_template('/doctores/actualizar_doctor.html', doctor = doctor)

@doctor_bp.route('/eliminar/<int:id>', methods = ['DELETE'])
def eliminar_doctor(id):
    doctor = Doctor.get_all(id)
    return render_template("doctores/doctores.html", doctor = doctor)



"""Rutas CRUD de Doctores Back API (EmdPoints)"""
@doctor_bp.route('/d', methods =['GET'])
def get_doctores():
    try:
        doctor = Doctor.get_all()
        return jsonify(doctor), 200
    except Exception as e:
        return jsonify({"Error:": str(e)}),500
    
@doctor_bp.route('/', methods=['POST'])
def create_doctor():
    """Crea un nuevo doctor"""
    try:
        data = request.get_json()
        doctor = doctor(
            nombre=data.get('nombre'),
            apellidos=data.get('apellidos'),
            especialidad_id=data.get('especialidad_id'),
            telefono=data.get('telefono'),
            email=data.get('email'),
            estado=data.get('estado')
        )
        doctor.save()
        return jsonify({"message": "doctor agregado", "id": doctor.id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@doctor_bp.route('/p/<int:id>', methods=['POST'])
def update_doctor(id):
    """Actualiza un doctor existente"""
    try:
        data = request.form
        doctor = doctor(
            id=id,
            nombre=data.get('nombre'),
            apellidos=data.get('apellidos'),
            especialidad_id=data.get('especialidad_id'),
            telefono=data.get('telefono'),
            email=data.get('email'),
            estado=data.get('estado')
        )
        doctor.save()
        print (jsonify({"message": "Doctor actualizado"}), 200)
        return render_template("Doctores/doc.html")
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@doctor_bp.route('/d/<int:id>', methods=['DELETE'])
def get_delete(id):
    """Desactivar un doctor por su ID"""
    try:
        doctor = Doctor.get_by_id(id)

        if not doctor:
            return jsonify({"error": "Doctor no encontrado"}), 404

        desactivado = Doctor.delete(id)  # Envio del ID del doctor
        print(doctor)

        if desactivado:
            return jsonify({"error": "No se pudo desactivar al Doctor"}), 500
        else:
            return jsonify({"message": "Doctor desactivado correctamente"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500