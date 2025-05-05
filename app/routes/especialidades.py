from flask import Blueprint, request, jsonify
from app.models.especialidad import Especialidad

bp = Blueprint('especialidades', __name__)

@bp.route('/', methods=['GET'])
def get_especialidades():
    """Obtiene todas las especialidades"""
    try:
        especialidades = Especialidad.get_all()
        return jsonify(especialidades), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@bp.route('/<int:id>', methods=['GET'])
def get_especialidad(id):
    """Obtiene una especialidad por su ID"""
    try:
        especialidad = Especialidad.get_by_id(id)
        if especialidad:
            return jsonify(especialidad), 200
        return jsonify({"message": "Especialidad no encontrada"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@bp.route('/', methods=['POST'])
def create_especialidad():
    """Crea una nueva especialidad"""
    try:
        data = request.get_json()
        especialidad = Especialidad(
            nombre=data.get('nombre'),
            descripcion=data.get('descripcion')
        )
        #result = especialidad.save()
        especialidad.save()
        return jsonify({"message": "Especialidad creada", "id": especialidad.id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@bp.route('/<int:id>', methods=['PUT'])
def update_especialidad(id):
    """Actualiza una especialidad existente"""
    try:
        data = request.get_json()
        especialidad = Especialidad(
            id=id,
            nombre=data.get('nombre'),
            descripcion=data.get('descripcion')
        )
        #result = especialidad.save()
        especialidad.save()
        return jsonify({"message": "Especialidad actualizada"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@bp.route('/<int:id>', methods=['DELETE'])
def delete_especialidad(id):
    """Elimina una especialidad"""
    try:
        #result = Especialidad.delete(id)
        Especialidad.delete(id)
        return jsonify({"message": "Especialidad eliminada"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500