USE GestionCitasMedicas;
GO

-- Insertar especialidades de prueba
INSERT INTO Especialidades (Nombre, Descripcion)
VALUES 
    ('Medicina General', 'Atención médica primaria y preventiva'),
    ('Cardiología', 'Especialidad en enfermedades del corazón'),
    ('Dermatología', 'Especialidad en enfermedades de la piel'),
    ('Pediatría', 'Atención médica para niños y adolescentes'),
    ('Oftalmología', 'Especialidad en enfermedades de los ojos');
GO

-- Insertar médicos de prueba
INSERT INTO Medicos (Nombre, Apellidos, EspecialidadID, Telefono, Email)
VALUES 
    ('Juan', 'Pérez', 1, '555-1234', 'juan.perez@clinica.com'),
    ('María', 'González', 2, '555-2345', 'maria.gonzalez@clinica.com'),
    ('Carlos', 'Rodríguez', 3, '555-3456', 'carlos.rodriguez@clinica.com'),
    ('Laura', 'Martínez', 4, '555-4567', 'laura.martinez@clinica.com'),
    ('Roberto', 'Fernández', 5, '555-5678', 'roberto.fernandez@clinica.com');
GO

-- Insertar pacientes de prueba
INSERT INTO Pacientes (Nombre, Apellidos, FechaNacimiento, Genero, Direccion, Telefono, Email)
VALUES 
    ('Ana', 'López', '1985-05-15', 'F', 'Calle Principal 123', '555-7890', 'ana.lopez@email.com'),
    ('Pedro', 'Gómez', '1978-10-20', 'M', 'Avenida Central 456', '555-8901', 'pedro.gomez@email.com'),
    ('Sofía', 'Ramírez', '1990-03-25', 'F', 'Boulevard Norte 789', '555-9012', 'sofia.ramirez@email.com'),
    ('Miguel', 'Torres', '1982-07-30', 'M', 'Calle Sur 321', '555-0123', 'miguel.torres@email.com'),
    ('Lucía', 'Díaz', '1995-12-05', 'F', 'Avenida Este 654', '555-1234', 'lucia.diaz@email.com');
GO

-- Insertar citas de prueba (fechas futuras para que sean relevantes)
DECLARE @FechaActual DATE = GETDATE();

INSERT INTO Citas (PacienteID, MedicoID, Fecha, Hora, Motivo, Estado)
VALUES 
    (1, 1, DATEADD(DAY, 1, @FechaActual), '09:00', 'Consulta general', 'Programada'),
    (2, 2, DATEADD(DAY, 1, @FechaActual), '10:30', 'Revisión cardíaca', 'Programada'),
    (3, 3, DATEADD(DAY, 2, @FechaActual), '14:00', 'Problema en la piel', 'Programada'),
    (4, 4, DATEADD(DAY, 3, @FechaActual), '16:30', 'Revisión pediátrica', 'Programada'),
    (5, 5, DATEADD(DAY, 4, @FechaActual), '11:00', 'Consulta oftalmológica', 'Programada');
GO

-- Insertar usuarios de prueba (la contraseña es 'password123' - en producción usar hash)
INSERT INTO Usuarios (Nombre, Email, Password, Rol, MedicoID)
VALUES 
    ('Admin Sistema', 'admin@clinica.com', 'password123', 'Admin', NULL),
    ('Juan Pérez', 'juan.perez@clinica.com', 'password123', 'Medico', 1),
    ('María González', 'maria.gonzalez@clinica.com', 'password123', 'Medico', 2),
    ('Recepcionista1', 'recepcion@clinica.com', 'password123', 'Recepcionista', NULL);
GO