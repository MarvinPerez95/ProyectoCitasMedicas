from flask import Blueprint, request, jsonify, url_for, redirect, render_template
from app.models.paciente import Paciente

pacientes_bp = Blueprint('pacientes', __name__, url_prefix = '/')

"""Rutas de Pacientes frond"""
@pacientes_bp.route('/', methods = ['GET'])
def inicioPacientes():  #Ruta principal
    return render_template("Pacientes/paciente.html")


@pacientes_bp.route('/view', methods = ['GET'])
def inicioPacientesView():  #Lista de Pacientes
    return render_template("Pacientes/paci.html")

@pacientes_bp.route('/view/nuevo', methods = ['GET'])
def nuevo_paciente():   #Creacion de paciente
    return render_template("Pacientes/nuevo_paciente.html")

@pacientes_bp.route('/view/actualizar/<int:id>', methods = ['GET'])
def editar_paciente(id):    #Actualizacion de Paciente
    paciente = Paciente.get_by_id(id)
    return render_template("Pacientes/actualizar_paciente.html", paciente = paciente)

@pacientes_bp.route('/view/delete/<int:id>', methods = ['DELETE'])
def desactivar_paciente(id):    #Eliminacion Logica de paciente
    paciente = Paciente.get_by_id(id)
    #print(paciente)
    return render_template("Pacientes/paci.html", paciente = paciente)



"""Rutas de pacientes back API *EndPoints*"""
@pacientes_bp.route('/p', methods =['GET'])
def get_pacientes():    #Obtener todos los Pacientes
    try:
        paciente = Paciente.get_all()
        return jsonify(paciente), 200
    except Exception as e:
        return jsonify({"Error": str(e)}), 500
    
@pacientes_bp.route('/', methods= ['POST'])
def create_Paciente():  #Agregar un nuevo Paciente
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

@pacientes_bp.route('/p/<int:id>', methods=['POST'])
def update_paciente(id):    #Actualiza un Paciente existente
    try:
        #data = request.get_json()
        data = request.form
        paciente = Paciente(
            id=id,
            Nombre= data.get('nombre'),
            Apellidos = data.get('apellidos'),
            FechaNacimiento = data.get('fechaNacimiento'),
            Genero = data.get('genero'),
            Direccion = data.get('direccion'),
            Telefono = data.get('telefono'),
            Email = data.get('email'),
            Estado= data.get('estado')
        )
        paciente.save()
        #return jsonify({"message": "Paciente actualizado"}), 200
        return render_template("Pacientes/paci.html")
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@pacientes_bp.route('/p/<int:id>', methods=['DELETE'])
def get_delete(id):     #Desactivar un Paciente por su ID
    try:
        paciente = Paciente.get_by_id(id)

        if not paciente:
            return jsonify({"error": "Paciente no encontrado"}), 404

        desactivado = Paciente.delete(id)  # Solo pasa el ID, como se espera

        if desactivado:
            return jsonify({"error": "No se pudo desactivar el paciente"}), 500
        else:
            return jsonify({"message": "Paciente desactivado correctamente"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
 
