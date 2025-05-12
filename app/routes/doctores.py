from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.doctor import Doctor

doctor_bp = Blueprint('doctores', __name__, url_prefix = '/')
"""Rutas de doctores frond"""
@doctor_bp.route('/', methods = ['GET'])
def iniciodoctores():
    return render_template("doctores/doctores.html")


@doctor_bp.route('/', methods=['GET'])
def get_doctores():
    """Obtiene todos los doctores"""
    try:
        doctores = doctores.get_all()
        return jsonify(doctores), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@doctor_bp.route('/<int:id>', methods=['GET'])
def get_doctor(id):
    """Obtiene un doctor por su ID"""
    try:
        doctor = doctor.get_by_id(id)
        if doctor:
            return jsonify(doctor), 200
        return jsonify({"message": "doctor no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

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

@doctor_bp.route('/<int:id>', methods=['PUT'])
def update_doctor(id):
    """Actualiza un doctor existente"""
    try:
        data = request.get_json()
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
        return jsonify({"message": "doctor actualizado"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@doctor_bp.route('/<int:id>', methods=['SET'])
def get_delete(id):
    """Desactivar un doctor por su ID"""
    try:
        doctor = doctor.delete(id)
        if doctor:
            return jsonify({"Message: doctor desactivado"},doctor), 200
        return jsonify({"message": "doctor no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500