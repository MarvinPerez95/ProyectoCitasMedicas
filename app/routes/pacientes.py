from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.paciente import Paciente

pacientes_bp = Blueprint('pacientes', __name__, url_prefix = '/')

@pacientes_bp.route('/', methods = ['GET'])
def inicioPacientes():
    return render_template("Pacientes/paciente.html")


@pacientes_bp.route('/view', methods = ['GET'])
def inicioPacientesView():
    return render_template("Pacientes/paci.html")

@pacientes_bp.route('/view/nuevo', methods = ['GET'])
def nuevo_paciente():
    return render_template("Pacientes/nuevo_paciente.html")


@pacientes_bp.route('/p', methods =['GET'])
def get_pacientes():
    """Obtener todos los Pacientes """
    try:
        paciente = Paciente.get_all()
        return jsonify(paciente), 200
    except Exception as e:
        return jsonify({"Error": str(e)}), 500
    
@pacientes_bp.route('/<int:id>')
def get_paciente(id):
    """Obtener Paciente por ID"""
    try:
        paciente = Paciente.get_by_id(id)
        if paciente:
            return jsonify(paciente), 200
        return jsonify({"message": "Paciente no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@pacientes_bp.route('/', methods= ['POST'])
def create_Paciente():
    """Agregar un nuevo Paciente"""
    try:
        #data = request.get_json()
        data = request.form
        paciente = Paciente(
            Nombre= data.get('nombre'),
            Apellidos = data.get('apellidos'),
            FechaNacimiento = data.get('fechaNacimiento'),
            Genero = data.get('genero'),
            Direccion = data.get('direccion'),
            Telefono = data.get('telefono'),
            Email = data.get('email')
        )
        paciente.save()
        return jsonify({"message": "Paciente agregado", "id": paciente.id}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@pacientes_bp.route('/<int:id>', methods=['PUT'])
def update_paciente(id):
    """Actualiza un Paciente existente"""
    try:
        data = request.get_json()
        paciente = Paciente(
            id=id,
            Nombre= data.get('nombre'),
            Apellidos = data.get('apellidos'),
            FechaNacimiento = data.get('fechaNacimiento'),
            Genero = data.get('genero'),
            Direccion = data.get('direccion'),
            Telefono = data.get('telefono'),
            Email = data.get('email'),
            estado= data.get('estado')
        )
        paciente.save()
        return jsonify({"message": "Paciente actualizado"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@pacientes_bp.route('/<int:id>', methods=['SET'])
def get_delete(id):
    """Desactivar un Paciente por su ID"""
    try:
        paciente = Paciente.delete(id)
        if paciente:
            return jsonify({"Message: Paciente desactivado"},paciente), 200
        return jsonify({"message": "Paciente no encontrado"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500