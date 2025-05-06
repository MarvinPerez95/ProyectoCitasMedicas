from flask import Blueprint, request, jsonify
from app.models.paciente import Paciente

pacientes_dp = Blueprint('pacientes', __name__)

@pacientes_dp.route('/pacientes', methods =['GET'])
def get_pacientes():
    """Obtener todos los Pacientes """
    try:
        paciente = Paciente.get_all()
        return jsonify(paciente), 200
    except Exception as e:
        return jsonify({"Error": str(e)}), 500
    
@pacientes_dp.route('/pacientes/<int:id>')
def get_paciente(id):
    """Obtener Paciente por ID"""
    try:
        paciente = Paciente.get_by_id(id)
        if paciente:
            return jsonify(paciente), 200
        return jsonify({"message": "Paciente no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@pacientes_dp.route('/', methods= ['POST'])
def create_Paciente():
    """Agregar un nuevo Paciente"""
    try:
        data = request.get_json()
        paciente = Paciente(
            nombre= data.get('nombre'),
            apellidos = data.get('apellidos'),
            fechaNacimiento = data.get('fechaNacimiento'),
            genero = data.get('genero'),
            direccion = data.get('direccion'),
            telefono = data.get('telefono'),
            email = data.get('email')
        )
        paciente.save()
        return jsonify({"message": "Paciente agregado", "id": paciente.id}), 2001
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@pacientes_dp.route('/<int:id>', methods=['PUT'])
def update_paciente(id):
    """Actualiza un Paciente existente"""
    try:
        data = request.get_json()
        paciente = Paciente(
            id=id,
            nombre= data.get('nombre'),
            apellidos = data.get('apellidos'),
            fechaNacimiento = data.get('fechaNacimiento'),
            genero = data.get('genero'),
            direccion = data.get('direccion'),
            telefono = data.get('telefono'),
            email = data.get('email'),
            estado= data.get('estado')
        )
        paciente.save()
        return jsonify({"message": "Paciente actualizado"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@pacientes_dp.route('/<int:id>', methods=['SET'])
def get_delete(id):
    """Desactivar un Paciente por su ID"""
    try:
        paciente = Paciente.delete(id)
        if paciente:
            return jsonify({"Message: Paciente desactivado"},paciente), 200
        return jsonify({"message": "Paciente no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500