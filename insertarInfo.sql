USE GestionCitasMedicas;
GO

-- Insertar especialidades de prueba
INSERT INTO Especialidades (Nombre, Descripcion)
VALUES 
    ('Medicina General', 'Atenci�n m�dica primaria y preventiva'),
    ('Cardiolog�a', 'Especialidad en enfermedades del coraz�n'),
    ('Dermatolog�a', 'Especialidad en enfermedades de la piel'),
    ('Pediatr�a', 'Atenci�n m�dica para ni�os y adolescentes'),
    ('Oftalmolog�a', 'Especialidad en enfermedades de los ojos');
GO

-- Insertar m�dicos de prueba
INSERT INTO Medicos (Nombre, Apellidos, EspecialidadID, Telefono, Email)
VALUES 
    ('Juan', 'P�rez', 1, '555-1234', 'juan.perez@clinica.com'),
    ('Mar�a', 'Gonz�lez', 2, '555-2345', 'maria.gonzalez@clinica.com'),
    ('Carlos', 'Rodr�guez', 3, '555-3456', 'carlos.rodriguez@clinica.com'),
    ('Laura', 'Mart�nez', 4, '555-4567', 'laura.martinez@clinica.com'),
    ('Roberto', 'Fern�ndez', 5, '555-5678', 'roberto.fernandez@clinica.com');
GO

-- Insertar pacientes de prueba
INSERT INTO Pacientes (Nombre, Apellidos, FechaNacimiento, Genero, Direccion, Telefono, Email)
VALUES 
    ('Ana', 'L�pez', '1985-05-15', 'F', 'Calle Principal 123', '555-7890', 'ana.lopez@email.com'),
    ('Pedro', 'G�mez', '1978-10-20', 'M', 'Avenida Central 456', '555-8901', 'pedro.gomez@email.com'),
    ('Sof�a', 'Ram�rez', '1990-03-25', 'F', 'Boulevard Norte 789', '555-9012', 'sofia.ramirez@email.com'),
    ('Miguel', 'Torres', '1982-07-30', 'M', 'Calle Sur 321', '555-0123', 'miguel.torres@email.com'),
    ('Luc�a', 'D�az', '1995-12-05', 'F', 'Avenida Este 654', '555-1234', 'lucia.diaz@email.com');
GO

-- Insertar citas de prueba (fechas futuras para que sean relevantes)
DECLARE @FechaActual DATE = GETDATE();

INSERT INTO Citas (PacienteID, MedicoID, Fecha, Hora, Motivo, Estado)
VALUES 
    (1, 1, DATEADD(DAY, 1, @FechaActual), '09:00', 'Consulta general', 'Programada'),
    (2, 2, DATEADD(DAY, 1, @FechaActual), '10:30', 'Revisi�n card�aca', 'Programada'),
    (3, 3, DATEADD(DAY, 2, @FechaActual), '14:00', 'Problema en la piel', 'Programada'),
    (4, 4, DATEADD(DAY, 3, @FechaActual), '16:30', 'Revisi�n pedi�trica', 'Programada'),
    (5, 5, DATEADD(DAY, 4, @FechaActual), '11:00', 'Consulta oftalmol�gica', 'Programada');
GO

-- Insertar usuarios de prueba (la contrase�a es 'password123' - en producci�n usar hash)
INSERT INTO Usuarios (Nombre, Email, Password, Rol, MedicoID)
VALUES 
    ('Admin Sistema', 'admin@clinica.com', 'password123', 'Admin', NULL),
    ('Juan P�rez', 'juan.perez@clinica.com', 'password123', 'Medico', 1),
    ('Mar�a Gonz�lez', 'maria.gonzalez@clinica.com', 'password123', 'Medico', 2),
    ('Recepcionista1', 'recepcion@clinica.com', 'password123', 'Recepcionista', NULL);
GO