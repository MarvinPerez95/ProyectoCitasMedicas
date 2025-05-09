from flask import Blueprint, request, jsonify
from app.models.medico import Medico

medicos_bp = Blueprint('medicos', __name__)

@medicos_bp.route('/', methods=['GET'])
def get_medicos():
    """Obtiene todos los Medicos"""
    try:
        medicos = Medico.get_all()
        return jsonify(medicos), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@medicos_bp.route('/<int:id>', methods=['GET'])
def get_medico(id):
    """Obtiene un medico por su ID"""
    try:
        medico = Medico.get_by_id(id)
        if medico:
            return jsonify(medico), 200
        return jsonify({"message": "Medico no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@medicos_bp.route('/', methods=['POST'])
def create_medico():
    """Crea un nuevo Medico"""
    try:
        data = request.get_json()
        medico = Medico(
            nombre=data.get('nombre'),
            apellidos=data.get('apellidos'),
            especialidad_id=data.get('especialidad_id'),
            telefono=data.get('telefono'),
            email=data.get('email'),
            estado=data.get('estado')
        )
        medico.save()
        return jsonify({"message": "Medico agregado", "id": medico.id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@medicos_bp.route('/<int:id>', methods=['PUT'])
def update_medico(id):
    """Actualiza un Medico existente"""
    try:
        data = request.get_json()
        medico = Medico(
            id=id,
            nombre=data.get('nombre'),
            apellidos=data.get('apellidos'),
            especialidad_id=data.get('especialidad_id'),
            telefono=data.get('telefono'),
            email=data.get('email'),
            estado=data.get('estado')
        )
        medico.save()
        return jsonify({"message": "Medico actualizado"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@medicos_bp.route('/<int:id>', methods=['SET'])
def get_delete(id):
    """Desactivar un medico por su ID"""
    try:
        medico = Medico.delete(id)
        if medico:
            return jsonify({"Message: Medico desactivado"},medico), 200
        return jsonify({"message": "Medico no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500