CREATE DATABASE GestionCitasMedicas;
--drop database GestionCitasMedicas
USE GestionCitasMedicas;
GO

CREATE TABLE Pacientes (
	pacienteId INT IDENTITY (1,1) PRIMARY KEY,
	nombre VARCHAR (50) NOT NULL,
	apellidos VARCHAR (50) NOT NULL,
	FechaNacimiento DATE NULL,
	genero CHAR (1) NULL CHECK (Genero IN('M', 'F', 'O')),
	direccion VARCHAR (200) NOT NULL,
	telefono VARCHAR (20) NOT NULL,
	email VARCHAR (100) NOT NULL,
	fechaRegistro DATETIME DEFAULT GETDATE(),
	estado BIT DEFAULT 1
);

-- Crear tabla Especialidades
CREATE TABLE Especialidades (
    EspecialidadID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255) NULL
);

-- Crear tabla M�dicos
CREATE TABLE Medicos (
    MedicoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellidos VARCHAR(50) NOT NULL,
    EspecialidadID INT NOT NULL,
    Telefono VARCHAR(20) NULL,
    Email VARCHAR(100) NULL,
    Estado BIT DEFAULT 1,
    CONSTRAINT FK_Medicos_Especialidades FOREIGN KEY (EspecialidadID)
        REFERENCES Especialidades (EspecialidadID)
);

-- Crear tabla Citas
CREATE TABLE Citas (
    CitaID INT IDENTITY(1,1) PRIMARY KEY,
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Motivo VARCHAR(255) NULL,
    Estado VARCHAR(20) DEFAULT 'Programada' CHECK (Estado IN ('Programada', 'Completada', 'Cancelada')),
    Observaciones VARCHAR(500) NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Citas_Pacientes FOREIGN KEY (PacienteID)
        REFERENCES Pacientes (PacienteID),
    CONSTRAINT FK_Citas_Medicos FOREIGN KEY (MedicoID)
        REFERENCES Medicos (MedicoID)
);

-- Crear tabla Usuarios
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Rol VARCHAR(20) NOT NULL CHECK (Rol IN ('Admin', 'Medico', 'Recepcionista')),
    MedicoID INT NULL,
    Estado BIT DEFAULT 1,
    UltimoAcceso DATETIME NULL,
    CONSTRAINT FK_Usuarios_Medicos FOREIGN KEY (MedicoID)
        REFERENCES Medicos (MedicoID)
);

-- Crear �ndices para mejorar el rendimiento
CREATE INDEX IX_Medicos_Especialidad ON Medicos(EspecialidadID);
CREATE INDEX IX_Citas_Paciente ON Citas(PacienteID);
CREATE INDEX IX_Citas_Medico ON Citas(MedicoID);
CREATE INDEX IX_Citas_Fecha ON Citas(Fecha);
CREATE INDEX IX_Usuarios_Email ON Usuarios(Email);
GO

SELECT * FROM pacientes;

-- Primero, identificar el ID de la restricción actual
SELECT name 
FROM sys.check_constraints 
WHERE OBJECT_NAME(parent_object_id) = 'Usuarios' 
AND type = 'C' 
AND is_disabled = 0;

-- Modificar la restricción CHECK para incluir el rol 'Paciente *****'
ALTER TABLE Usuarios
DROP CONSTRAINT CK__Usuarios__Rol__5BE2A6F2; 


ALTER TABLE Usuarios
ADD CONSTRAINT CK_Usuarios_Rol 
CHECK (Rol IN ('Admin', 'Medico', 'Recepcionista', 'Paciente'));


-- Añadir columna PacienteID para relacionar usuarios con pacientes
ALTER TABLE Usuarios
ADD PacienteID INT NULL;


-- Crear la relación con la tabla Pacientes
ALTER TABLE Usuarios
ADD CONSTRAINT FK_Usuarios_Pacientes 
FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID);
