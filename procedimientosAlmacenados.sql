USE GestionCitasMedicas;
GO

-- ===========================
-- PROCEDIMIENTOS PARA ESPECIALIDADES
-- ===========================

-- Crear una nueva especialidad
CREATE PROCEDURE sp_CrearEspecialidad
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Especialidades (Nombre, Descripcion)
    VALUES (@Nombre, @Descripcion);
    
    SELECT SCOPE_IDENTITY() AS EspecialidadID;
END;
GO

-- Obtener todas las especialidades
CREATE PROCEDURE sp_ObtenerEspecialidades
AS
BEGIN
    SELECT EspecialidadID, Nombre, Descripcion
    FROM Especialidades
    ORDER BY Nombre;
END;
GO

-- Obtener una especialidad por ID
CREATE PROCEDURE sp_ObtenerEspecialidadPorID
    @EspecialidadID INT
AS
BEGIN
    SELECT EspecialidadID, Nombre, Descripcion
    FROM Especialidades
    WHERE EspecialidadID = @EspecialidadID;
END;
GO

-- Actualizar especialidad
CREATE PROCEDURE sp_ActualizarEspecialidad
    @EspecialidadID INT,
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL
AS
BEGIN
    UPDATE Especialidades
    SET Nombre = @Nombre,
        Descripcion = @Descripcion
    WHERE EspecialidadID = @EspecialidadID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO

-- Eliminar especialidad
CREATE PROCEDURE sp_EliminarEspecialidad
    @EspecialidadID INT
AS
BEGIN
    -- Primero verificamos que no haya m�dicos asociados
    IF EXISTS (SELECT 1 FROM Medicos WHERE EspecialidadID = @EspecialidadID)
    BEGIN
        RAISERROR('No se puede eliminar la especialidad porque existen médicos asociados', 16, 1);
        RETURN;
    END
    
    DELETE FROM Especialidades
    WHERE EspecialidadID = @EspecialidadID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO


-- ===========================
-- PROCEDIMIENTOS PARA MÉDICOS
-- ===========================


-- Crear un nuevo m�dico con validaciones
CREATE OR ALTER PROCEDURE sp_CrearMedico
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @EspecialidadID INT,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
	@Estado bit
AS
BEGIN
    -- Validar nombre y apellidos
    IF LEN(@Nombre) < 2 OR LEN(@Apellidos) < 2
    BEGIN
        RAISERROR('El nombre y apellidos deben tener al menos 2 caracteres', 16, 1);
        RETURN;
    END
    
    -- Validar que la especialidad exista
    IF NOT EXISTS (SELECT 1 FROM Especialidades WHERE EspecialidadID = @EspecialidadID)
    BEGIN
        RAISERROR('La especialidad no existe', 16, 1);
        RETURN;
    END
    
    -- Validar formato de email
    IF @Email IS NOT NULL AND 
       (@Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0)
    BEGIN
        RAISERROR('Formato de email no v�lido', 16, 1);
        RETURN;
    END
    
    -- Validar si ya existe un m�dico con ese email
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Medicos WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un m�dico registrado con ese email', 16, 1);
        RETURN;
    END
    
    -- Validar formato b�sico de tel�fono
    IF @Telefono IS NOT NULL AND 
       (LEN(@Telefono) < 8 OR @Telefono LIKE '%[^0-9+-]%')
    BEGIN
        RAISERROR('Formato de tel�fono no v�lido', 16, 1);
        RETURN;
    END
    
    -- Si pasa todas las validaciones, insertar el m�dico
    INSERT INTO Medicos (Nombre, Apellidos, EspecialidadID, Telefono, Email, Estado)
    VALUES (@Nombre, @Apellidos, @EspecialidadID, @Telefono, @Email, @Estado);
    
    SELECT SCOPE_IDENTITY() AS MedicoID;
END;
GO


-- Obtener todos los m�dicos
CREATE or alter PROCEDURE sp_ObtenerMedicos
AS
BEGIN
    SELECT m.MedicoID, m.Nombre, m.Apellidos, 
           e.Nombre AS Especialidad,
           m.Telefono, m.Email, m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    ORDER BY m.Apellidos, m.Nombre;
END;
GO


-- Obtener un m�dico por ID
CREATE or alter PROCEDURE sp_ObtenerMedicoPorID
    @MedicoID INT
AS
BEGIN
    SELECT m.MedicoID, m.Nombre, m.Apellidos, 
           e.EspecialidadID, e.Nombre AS Especialidad,
           m.Telefono, m.Email, m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    WHERE m.MedicoID = @MedicoID;
END;
GO


-- Actualizar m�dico
CREATE or alter PROCEDURE sp_ActualizarMedico
    @MedicoID INT,
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @EspecialidadID INT,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @Estado BIT 
AS
BEGIN
    UPDATE Medicos
    SET Nombre = @Nombre,
        Apellidos = @Apellidos,
        EspecialidadID = @EspecialidadID,
        Telefono = @Telefono,
        Email = @Email,
        Estado = @Estado
    WHERE MedicoID = @MedicoID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO

-- Eliminar (logico) un m�dico
CREATE or alter PROCEDURE sp_EliminarMedico
	@MedicoID INT
AS
BEGIN
-- En lugar de eliminar f�sicamente, actualizamos el estado a inactivo
		UPDATE Medicos
		SET Estado = 0
		WHERE MedicoID = @MedicoID;

		SELECT 'Medico marcado como inactivo' AS Mensaje;

		SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO

-- ===========================
-- PROCEDIMIENTOS PARA PACIENTES
-- ===========================

-- Crear un nuevo paciente con validaciones
CREATE OR ALTER PROCEDURE sp_CrearPaciente
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @FechaNacimiento DATE = NULL,
    @Genero CHAR(1) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL
AS
BEGIN
    -- Validar nombre y apellidos
    IF LEN(@Nombre) < 2 OR LEN(@Apellidos) < 2
    BEGIN
        RAISERROR('El nombre y apellidos deben tener al menos 2 caracteres', 16, 1);
        RETURN;
    END
    
    -- Validar g�nero
    IF @Genero IS NOT NULL AND @Genero NOT IN ('M', 'F', 'O')
    BEGIN
        RAISERROR('G�nero no v�lido. Los valores permitidos son: M, F, O', 16, 1);
        RETURN;
    END
    
    -- Validar fecha de nacimiento
    IF @FechaNacimiento IS NOT NULL AND @FechaNacimiento > GETDATE()
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser posterior a hoy', 16, 1);
        RETURN;
    END
    
    -- Validar formato de email si no es NULL
    IF @Email IS NOT NULL AND 
       (@Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0)
    BEGIN
        RAISERROR('Formato de email no v�lido', 16, 1);
        RETURN;
    END
    
    -- Validar si ya existe un paciente con ese email
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Pacientes WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un paciente registrado con ese email', 16, 1);
        RETURN;
    END
    
    -- Validar formato b�sico de tel�fono
    IF @Telefono IS NOT NULL AND 
       (LEN(@Telefono) < 8 OR @Telefono LIKE '%[^0-9+-]%')
    BEGIN
        RAISERROR('Formato de tel�fono no v�lido', 16, 1);
        RETURN;
    END
    
    -- Si pasa todas las validaciones, insertar el paciente
    INSERT INTO Pacientes (Nombre, Apellidos, FechaNacimiento, Genero, Direccion, Telefono, Email, FechaRegistro, Estado)
    VALUES (@Nombre, @Apellidos, @FechaNacimiento, @Genero, @Direccion, @Telefono, @Email, GETDATE(), 1);
    
    SELECT SCOPE_IDENTITY() AS PacienteID;
END;
GO
select * from Pacientes
go 
-- Obtener todos los pacientes
CREATE or alter PROCEDURE sp_ObtenerPacientes
AS
BEGIN
    SELECT PacienteID, Nombre, Apellidos, FechaNacimiento, 
           Genero, Direccion, Telefono, Email, FechaRegistro, Estado
    FROM Pacientes
    ORDER BY Apellidos, Nombre;
END;
GO


-- Obtener un paciente por ID
CREATE PROCEDURE sp_ObtenerPacientePorID
    @PacienteID INT
AS
BEGIN
    SELECT PacienteID, Nombre, Apellidos, FechaNacimiento, 
           Genero, Direccion, Telefono, Email, FechaRegistro, Estado
    FROM Pacientes
    WHERE PacienteID = @PacienteID;
END;
GO


-- Actualizar paciente con validaciones
CREATE OR ALTER PROCEDURE sp_ActualizarPaciente
    @PacienteID INT,
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @FechaNacimiento DATE = NULL,
    @Genero CHAR(1) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @Estado BIT
AS
BEGIN
    -- Validar que el paciente exista
    IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE PacienteID = @PacienteID)
    BEGIN
        RAISERROR('El paciente no existe', 16, 1);
        RETURN;
    END
    
    -- Validar nombre y apellidos
    IF LEN(@Nombre) < 2 OR LEN(@Apellidos) < 2
    BEGIN
        RAISERROR('El nombre y apellidos deben tener al menos 2 caracteres', 16, 1);
        RETURN;
    END
    
    -- Validar g�nero
    IF @Genero IS NOT NULL AND @Genero NOT IN ('M', 'F', 'O')
    BEGIN
        RAISERROR('G�nero no v�lido. Los valores permitidos son: M, F, O', 16, 1);
        RETURN;
    END
    
    -- Validar fecha de nacimiento
    IF @FechaNacimiento IS NOT NULL AND @FechaNacimiento > GETDATE()
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser posterior a hoy', 16, 1);
        RETURN;
    END
    
    -- Validar formato de email si no es NULL
    IF @Email IS NOT NULL AND 
       (@Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0)
    BEGIN
        RAISERROR('Formato de email no válido', 16, 1);
        RETURN;
    END
    
    -- Validar si ya existe otro paciente con ese email
    IF @Email IS NOT NULL AND 
       EXISTS (SELECT 1 FROM Pacientes WHERE Email = @Email AND PacienteID != @PacienteID)
    BEGIN
        RAISERROR('Ya existe otro paciente registrado con ese email', 16, 1);
        RETURN;
    END
    
    -- Validar formato b�sico de tel�fono
    IF @Telefono IS NOT NULL AND 
       (LEN(@Telefono) < 8 OR @Telefono LIKE '%[^0-9+-]%')
    BEGIN
        RAISERROR('Formato de teléfono no válido', 16, 1);
        RETURN;
    END
    
    -- Si pasa todas las validaciones, actualizar el paciente
    UPDATE Pacientes
    SET Nombre = @Nombre,
        Apellidos = @Apellidos,
        FechaNacimiento = @FechaNacimiento,
        Genero = @Genero,
        Direccion = @Direccion,
        Telefono = @Telefono,
        Email = @Email,
        Estado = @Estado
    WHERE PacienteID = @PacienteID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO


-- Eliminar un Paciente
CREATE or alter PROCEDURE sp_EliminarPaciente
	@PacienteID INT
AS
BEGIN

	-- Verificar si el paciente tiene citas
--	IF EXISTS (SELECT 1 FROM Citas WHERE PacienteID = @PacienteID)
--	BEGIN
		-- En lugar de eliminar f�sicamente, actualizamos el estado a inactivo
		UPDATE Pacientes
		SET Estado = 0
		WHERE PacienteID = @PacienteID;

		SELECT 'Paciente marcado como inactivo debido a citas existentes' AS Mensaje;
--	END
--	ELSE
--	BEGIN
		-- Si no tiene citas, se puede eliminar físicamente
--		DELETE FROM Pacientes
--		WHERE PacienteID = @PacienteID;

		SELECT @@ROWCOUNT AS FilasAfectadas;
--	END
END;
GO




-- ===========================
-- PROCEDIMIENTOS PARA CITAS
-- ===========================

-- Crear una nueva cita
-- Crear una nueva cita con validaciones mejoradas
CREATE OR ALTER PROCEDURE sp_CrearCita
    @PacienteID INT,
    @MedicoID INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(255) = NULL,
	@observaciones varchar(255) = Null
AS
BEGIN
    -- Validar que el paciente exista y est� activo
    IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE PacienteID = @PacienteID AND Estado = 1)
    BEGIN
        RAISERROR('El paciente no existe o está inactivo', 16, 1);
        RETURN;
    END
    
    -- Validar que el m�dico exista y est� activo
    IF NOT EXISTS (SELECT 1 FROM Medicos WHERE MedicoID = @MedicoID AND Estado = 1)
    BEGIN
        RAISERROR('El médico no existe o está inactivo', 16, 1);
        RETURN;
    END
    
    -- Validar que la fecha no sea anterior a hoy
    IF @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('No se pueden crear citas en fechas pasadas', 16, 1);
        RETURN;
    END
    
    -- Validar que no sea un horario fuera de horas laborales (8:00 - 18:00)
    IF @Hora < '08:00:00' OR @Hora > '18:00:00'
    BEGIN
        RAISERROR('Las citas deben programarse entre las 8:00 y las 18:00', 16, 1);
        RETURN;
    END
    
    -- Verificar que no haya otra cita para el mismo m�dico en la misma fecha/hora
    IF EXISTS (
        SELECT 1 
        FROM Citas 
        WHERE MedicoID = @MedicoID 
          AND Fecha = @Fecha 
          AND Hora = @Hora
          AND Estado != 'Cancelada'
    )
    BEGIN
        RAISERROR('El m�dico ya tiene una cita programada en este horario', 16, 1);
        RETURN;
    END
    
    -- Si pasó todas las validaciones, crear la cita
    INSERT INTO Citas (PacienteID, MedicoID, Fecha, Hora, Motivo, Observaciones, Estado, FechaCreacion)
    VALUES (@PacienteID, @MedicoID, @Fecha, @Hora, @Motivo, @observaciones, 'Programada', GETDATE());
    
    SELECT SCOPE_IDENTITY() AS CitaID;
END;
GO


-- Obtener todas las citas
CREATE PROCEDURE sp_ObtenerCitas
AS
BEGIN
    SELECT c.CitaID, c.PacienteID, p.Nombre + ' ' + p.Apellidos AS NombrePaciente,
           c.MedicoID, m.Nombre + ' ' + m.Apellidos AS NombreMedico,
           e.Nombre AS Especialidad, c.Fecha, c.Hora, c.Motivo,
           c.Estado, c.Observaciones, c.FechaCreacion
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteID = p.PacienteID
    INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    ORDER BY c.Fecha DESC, c.Hora;
END;
GO

-- Obtener citas por m�dico ******
CREATE PROCEDURE sp_ObtenerCitasPorMedico
    @MedicoID INT
AS
BEGIN
    SELECT c.CitaID, c.PacienteID, p.Nombre + ' ' + p.Apellidos AS NombrePaciente,
           c.MedicoID, m.Nombre + ' ' + m.Apellidos AS NombreMedico,
           e.Nombre AS Especialidad, c.Fecha, c.Hora, c.Motivo,
           c.Estado, c.Observaciones, c.FechaCreacion
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteID = p.PacienteID
    INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    WHERE c.MedicoID = @MedicoID
    ORDER BY c.Fecha DESC, c.Hora;
END;
GO

-- Obtener citas por paciente ******
CREATE or alter PROCEDURE sp_ObtenerCitasPorPaciente
	@PacienteID INT
AS
BEGIN
	SELECT c.CitaID, c.PacienteID, p.Nombre + ' ' + p.Apellidos AS NombrePaciente,
		   c.MedicoID, m.Nombre + ' ' + m.Apellidos AS NombreMedico,
		   c.Estado, c.Observaciones, c.FechaCreacion
	FROM Citas c
	INNER JOIN Pacientes p ON c.PacienteID = p.PacienteID
	INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
	INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
	WHERE c.PacienteID = @PacienteID
	ORDER BY c.Fecha DESC, c.Hora;
END;
GO

-- Obtener citas por Cita ID******
CREATE or alter PROCEDURE sp_ObtenerCitasPorCitaID
	@citaID INT
AS
BEGIN
	SELECT c.CitaID, c.PacienteID, p.Nombre + ' ' + p.Apellidos AS NombrePaciente,
		   c.MedicoID, m.Nombre + ' ' + m.Apellidos AS NombreMedico,
		   c.Fecha, c.Hora, c.Motivo,
		   c.Estado, c.Observaciones, c.FechaCreacion
	FROM Citas c
	INNER JOIN Pacientes p ON c.PacienteID = p.PacienteID
	INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
	INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
	WHERE c.CitaID = @citaID
	ORDER BY c.Fecha DESC, c.Hora;
END;
GO

-- Actualizar estado de cita
CREATE PROCEDURE sp_ActualizarEstadoCita
    @CitaID INT,
    @Estado VARCHAR(20),
    @Observaciones VARCHAR(500) = NULL
AS
BEGIN
    IF @Estado NOT IN ('Programada', 'Completada', 'Cancelada')
    BEGIN
        RAISERROR('Estado no v�lido. Los valores permitidos son: Programada, Completada, Cancelada', 16, 1);
        RETURN;
    END
    
    UPDATE Citas
    SET Estado = @Estado,
        Observaciones = @Observaciones
    WHERE CitaID = @CitaID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO

-- Actualizar Cita Completa
CREATE or alter PROCEDURE sp_ActualizarCita
	@CitaID INT,
	@PacienteID INT,
	@MedicoID INT,
	@Fecha DATE,
	@Hora TIME,
	@Motivo VARCHAR (200),
	@Estado VARCHAR (20),
	@Observaciones VARCHAR (500)

AS
BEGIN
	-- Verificar que no haya conflicto de horario para el nuevo m�dico
	IF EXISTS (
		SELECT 1
		FROM Citas
		WHERE MedicoID = @MedicoID
			AND Fecha = @Fecha
			AND Hora = @Hora
			AND CitaID != @CitaID -- Excluir la cita actual
			AND Estado != 'Cancelada'
	)

	BEGIN 
		RAISERROR ('El médico ya tiene una cita programada en este horario', 16,1);
		RETURN;
	END

	UPDATE Citas
	SET PacienteID = @PacienteID,
		MedicoID = @MedicoID,
		Fecha = @Fecha,
		Hora = @Hora,
		Motivo = @Motivo,
		Estado = @Estado,
		Observaciones = @Observaciones
	WHERE CitaID = @CitaID;

	SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO


-- Eliminar Cita
CREATE  or alter PROCEDURE sp_EliminarCita
	@CitaID INT
AS
BEGIN
	-- En lugar de elinnar físicamente, actualizamos a cancelada
	if exists (select 1 from citas where CitaID = @CitaID and Estado = 'Cancelada')
	begin
		RAISERROR('El m�dico ya tiene una cita programada en este horario', 16, 1);
        RETURN;
	end

	UPDATE citas
	SET Estado = 'Cancelada',
		Observaciones = CONCAT (ISNULL(Observaciones, ''),
								' | Cancelada en: ',
								CONVERT (VARCHAR , GETDATE(),120))
	WHERE CitaID = @CitaID;

	SELECT @@ROWCOUNT AS FilasAfectadas;
	return 'Cita Cancelada con exito'
END;
GO

-- IMPLEMENTACI�N DE PROCEDIMIENTOS DE AUTENTICACI�N

-- Autenticaci�n de Usuarios
-- Validar credenciales de usuario
CREATE or alter PROCEDURE sp_ValidarUsuario
    @Email VARCHAR(100),
    @Password VARCHAR(255)
AS
BEGIN
    DECLARE @UsuarioID INT;
    DECLARE @Rol VARCHAR(20);
    DECLARE @Nombre VARCHAR(100);
    DECLARE @Estado BIT;

    -- Buscar usuario por email
    SELECT @UsuarioID = UsuarioID, 
           @Nombre = Nombre, 
           @Rol = Rol, 
           @Estado = Estado
    FROM Usuarios
    WHERE Email = @Email AND Password = @Password;
    
    -- Verificar si se encontr� el usuario y est� activo
    IF @UsuarioID IS NULL
    BEGIN
        -- Credenciales incorrectas o usuario no existe
        SELECT 0 AS Autenticado, 'Credenciales inv�lidas' AS Mensaje;
        RETURN 0;
    END
    
    IF @Estado = 0
    BEGIN
        -- Usuario existe pero está inactivo
        SELECT 0 AS Autenticado, 'Usuario inactivo. Contacte al administrador.' AS Mensaje;
        RETURN 1;
    END
    
    -- Usuario autenticado correctamente, actualizar último acceso
    UPDATE Usuarios
    SET UltimoAcceso = GETDATE()
    WHERE UsuarioID = @UsuarioID;
    
    -- Devolver información del usuario (sin la contraseña)
    SELECT 
        1 AS Autenticado,
        'Autenticaci�n exitosa' AS Mensaje,
        @UsuarioID AS UsuarioID,
        @Nombre AS Nombre,
        @Rol AS Rol,
        m.MedicoID,
        m.EspecialidadID
    FROM Usuarios u
    LEFT JOIN Medicos m ON u.MedicoID = m.MedicoID
    WHERE u.UsuarioID = @UsuarioID;
END;
GO


-- Cambiar contrase�a de usuario
CREATE PROCEDURE sp_CambiarPassword
    @UsuarioID INT,
    @PasswordActual VARCHAR(255),
    @PasswordNueva VARCHAR(255)
AS
BEGIN
    -- Verificar que el usuario exista y que la contrase�a actual sea correcta
    IF NOT EXISTS (SELECT 1 FROM Usuarios 
                   WHERE UsuarioID = @UsuarioID 
                   AND Password = @PasswordActual)
    BEGIN
        SELECT 0 AS Exito, 'Contrase�a actual incorrecta' AS Mensaje;
        RETURN;
    END
    
    -- Validar que la nueva contrase�a cumpla requisitos de seguridad
    IF LEN(@PasswordNueva) < 8
    BEGIN
        SELECT 0 AS Exito, 'La nueva contrase�a debe tener al menos 8 caracteres' AS Mensaje;
        RETURN;
    END
    
    -- Actualizar la contrase�a
    UPDATE Usuarios
    SET Password = @PasswordNueva
    WHERE UsuarioID = @UsuarioID;
    
    SELECT 1 AS Exito, 'Contrase�a actualizada correctamente' AS Mensaje;
END;
GO


-- Reestablecer contrase�a (solo para administradores)
CREATE PROCEDURE sp_ReestablecerPassword
    @UsuarioID INT,
    @NuevaPassword VARCHAR(255),
    @AdminUsuarioID INT
AS
BEGIN
    -- Verificar que quien ejecuta sea administrador
    DECLARE @EsAdmin BIT = 0;
    
    SELECT @EsAdmin = 1
    FROM Usuarios
    WHERE UsuarioID = @AdminUsuarioID AND Rol = 'Admin';
    
    IF @EsAdmin = 0
    BEGIN
        SELECT 0 AS Exito, 'Solo los administradores pueden reestablecer contrase�as' AS Mensaje;
        RETURN;
    END
    
    -- Verificar que el usuario a modificar exista
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE UsuarioID = @UsuarioID)
    BEGIN
        SELECT 0 AS Exito, 'El usuario no existe' AS Mensaje;
        RETURN;
    END
    
    -- Actualizar la contrase�a
    UPDATE Usuarios
    SET Password = @NuevaPassword
    WHERE UsuarioID = @UsuarioID;
    
    SELECT 1 AS Exito, 'Contrase�a reestablecida correctamente' AS Mensaje;
END;
GO


-- Crear nuevo usuario
CREATE PROCEDURE sp_CrearUsuario
    @Nombre VARCHAR(50),
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @Rol VARCHAR(20),
    @MedicoID INT = NULL,
    @CreadorUsuarioID INT  -- ID del usuario que crea este nuevo usuario
AS
BEGIN
    -- Verificar si el creador tiene permisos de administrador (solo admin puede crear usuarios)
    DECLARE @EsAdmin BIT = 0;
    
    SELECT @EsAdmin = 1
    FROM Usuarios
    WHERE UsuarioID = @CreadorUsuarioID AND Rol = 'Admin';
    
    IF @EsAdmin = 0
    BEGIN
        SELECT 0 AS Exito, 'Solo los administradores pueden crear usuarios' AS Mensaje;
        RETURN;
    END
    
    -- Validar rol
    IF @Rol NOT IN ('Admin', 'Medico', 'Recepcionista')
    BEGIN
        SELECT 0 AS Exito, 'Rol no válido. Los roles permitidos son: Admin, Medico, Recepcionista' AS Mensaje;
        RETURN;
    END
    
    -- Validar formato de email
    IF @Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0
    BEGIN
        SELECT 0 AS Exito, 'Formato de email no vaálido' AS Mensaje;
        RETURN;
    END
    
    -- Verificar que el email no est� ya registrado
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Email = @Email)
    BEGIN
        SELECT 0 AS Exito, 'El email ya está registrado' AS Mensaje;
        RETURN;
    END
    
    -- Validar que la contraseña cumpla requisitos m�nimos
    IF LEN(@Password) < 8
    BEGIN
        SELECT 0 AS Exito, 'La contraseña debe tener al menos 8 caracteres' AS Mensaje;
        RETURN;
    END
    
    -- Si el rol es médico, verificar que MedicoID no sea NULL y exista
    IF @Rol = 'Medico' AND (@MedicoID IS NULL OR NOT EXISTS (SELECT 1 FROM Medicos WHERE MedicoID = @MedicoID))
    BEGIN
        SELECT 0 AS Exito, 'Para un usuario médico, debe proporcionar un ID de m�dico v�lido' AS Mensaje;
        RETURN;
    END
    
    -- Si el rol no es m�dico, MedicoID debe ser NULL
    IF @Rol != 'Medico' AND @MedicoID IS NOT NULL
    BEGIN
        SELECT 0 AS Exito, 'MedicoID solo debe especificarse para usuarios con rol de Médico' AS Mensaje;
        RETURN;
    END
    
    -- Insertar el nuevo usuario
    INSERT INTO Usuarios (Nombre, Email, Password, Rol, MedicoID, Estado)
    VALUES (@Nombre, @Email, @Password, @Rol, @MedicoID, 1);
    
    DECLARE @NuevoUsuarioID INT = SCOPE_IDENTITY();
    
    SELECT 1 AS Exito, 'Usuario creado correctamente' AS Mensaje, @NuevoUsuarioID AS UsuarioID;
END;
GO


---------------------------
-----|||||		PROCEMIENDOS ALMACENADOS PARA REGISTRAR UN PACIENTE COMO USUARIO EN EL SISTEMAS					||


-- Procedimiento para registrar un paciente con usuario en el sistema
CREATE OR ALTER PROCEDURE sp_RegistrarPacienteUsuario
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @FechaNacimiento DATE = NULL,
    @Genero CHAR(1) = NULL,
    @Direccion VARCHAR(200) = NULL,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @Password VARCHAR(255) = NULL
AS
BEGIN
    -- Validar datos básicos
    IF LEN(@Nombre) < 2 OR LEN(@Apellidos) < 2
    BEGIN
        RAISERROR('El nombre y apellidos deben tener al menos 2 caracteres', 16, 1);
        RETURN;
    END
    
    -- Validar género
    IF @Genero IS NOT NULL AND @Genero NOT IN ('M', 'F', 'O')
    BEGIN
        RAISERROR('Género no válido. Los valores permitidos son: M, F, O', 16, 1);
        RETURN;
    END
    
    -- Validar fecha de nacimiento
    IF @FechaNacimiento IS NOT NULL AND @FechaNacimiento > GETDATE()
    BEGIN
        RAISERROR('La fecha de nacimiento no puede ser posterior a hoy', 16, 1);
        RETURN;
    END
    
    -- Validar email
    IF @Email IS NULL OR @Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0
    BEGIN
        RAISERROR('El email es obligatorio y debe tener un formato válido', 16, 1);
        RETURN;
    END
    
    -- Verificar que el email no exista en pacientes ni usuarios
    IF EXISTS (SELECT 1 FROM Pacientes WHERE Email = @Email) OR 
       EXISTS (SELECT 1 FROM Usuarios WHERE Email = @Email)
    BEGIN
        RAISERROR('El email ya está registrado en el sistema', 16, 1);
        RETURN;
    END
    
    -- Validar contraseña
    IF @Password IS NULL OR LEN(@Password) < 8
    BEGIN
        RAISERROR('La contraseña es obligatoria y debe tener al menos 8 caracteres', 16, 1);
        RETURN;
    END
    
    -- Iniciar transacción para asegurar que ambas operaciones se completen o ninguna
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Insertar el paciente
        INSERT INTO Pacientes (Nombre, Apellidos, FechaNacimiento, Genero, Direccion, 
                              Telefono, Email, FechaRegistro, Estado)
        VALUES (@Nombre, @Apellidos, @FechaNacimiento, @Genero, @Direccion, 
               @Telefono, @Email, GETDATE(), 1);
        
        DECLARE @PacienteID INT = SCOPE_IDENTITY();
        
        -- Insertar el usuario
        INSERT INTO Usuarios (Nombre, Email, Password, Rol, PacienteID, Estado)
        VALUES (@Nombre + ' ' + @Apellidos, @Email, @Password, 'Paciente', @PacienteID, 1);
        
        DECLARE @UsuarioID INT = SCOPE_IDENTITY();
        
        -- Confirmar transacción
        COMMIT TRANSACTION;
        
        -- Devolver resultado
        SELECT 1 AS Exito, 'Paciente registrado correctamente' AS Mensaje, 
               @PacienteID AS PacienteID, @UsuarioID AS UsuarioID;
    END TRY
    BEGIN CATCH
        -- Revertir transacción en caso de error
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;
GO

-- Procedimiento para obtener citas de un paciente específico
CREATE OR ALTER PROCEDURE sp_ObtenerCitasPaciente
    @PacienteID INT
AS
BEGIN
    SELECT c.CitaID, c.Fecha, c.Hora, c.Motivo, c.Estado, c.Observaciones,
           m.MedicoID, m.Nombre + ' ' + m.Apellidos AS NombreMedico,
           e.EspecialidadID, e.Nombre AS Especialidad
    FROM Citas c
    INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    WHERE c.PacienteID = @PacienteID
    ORDER BY c.Fecha DESC, c.Hora;
END;
GO

-- Procedimiento para que un paciente pueda solicitar una cita
CREATE OR ALTER PROCEDURE sp_SolicitarCitaPaciente
    @PacienteID INT,
    @MedicoID INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(255) = NULL
AS
BEGIN
    -- Validar que el paciente exista y esté activo
    IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE PacienteID = @PacienteID AND Estado = 1)
    BEGIN
        RAISERROR('El paciente no existe o está inactivo', 16, 1);
        RETURN;
    END
    
    -- Validar que el médico exista y esté activo
    IF NOT EXISTS (SELECT 1 FROM Medicos WHERE MedicoID = @MedicoID AND Estado = 1)
    BEGIN
        RAISERROR('El médico no existe o está inactivo', 16, 1);
        RETURN;
    END
    
    -- Validar que la fecha no sea anterior a hoy
    IF @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('No se pueden crear citas en fechas pasadas', 16, 1);
        RETURN;
    END
    
    -- Validar que la fecha no sea más de 60 días en el futuro
    IF @Fecha > DATEADD(DAY, 60, GETDATE())
    BEGIN
        RAISERROR('No se pueden programar citas con más de 60 días de anticipación', 16, 1);
        RETURN;
    END
    
    -- Validar que no sea un horario fuera de horas laborales (ajusta según horario de la clínica)
    IF @Hora < '08:00:00' OR @Hora > '18:00:00'
    BEGIN
        RAISERROR('Las citas deben programarse entre las 8:00 y las 18:00', 16, 1);
        RETURN;
    END
    
    -- Verificar que no haya otra cita para el mismo médico en la misma fecha/hora
    IF EXISTS (
        SELECT 1 
        FROM Citas 
        WHERE MedicoID = @MedicoID 
          AND Fecha = @Fecha 
          AND Hora = @Hora
          AND Estado != 'Cancelada'
    )
    BEGIN
        RAISERROR('El médico ya tiene una cita programada en este horario', 16, 1);
        RETURN;
    END
    
    -- Verificar que el paciente no tenga otra cita a la misma hora
    IF EXISTS (
        SELECT 1 
        FROM Citas 
        WHERE PacienteID = @PacienteID 
          AND Fecha = @Fecha 
          AND Hora = @Hora
          AND Estado != 'Cancelada'
    )
    BEGIN
        RAISERROR('Usted ya tiene una cita programada en este horario', 16, 1);
        RETURN;
    END
    
    -- Si pasó todas las validaciones, crear la cita
    INSERT INTO Citas (PacienteID, MedicoID, Fecha, Hora, Motivo, Estado, FechaCreacion)
    VALUES (@PacienteID, @MedicoID, @Fecha, @Hora, @Motivo, 'Programada', GETDATE());
    
    DECLARE @CitaID INT = SCOPE_IDENTITY();
    
    SELECT @CitaID AS CitaID;
END;
GO

--REPROGRAMAR CITAS MÉDICOS

CREATE OR ALTER PROCEDURE sp_ReprogramarCitaMedico
    @CitaID INT,
    @MedicoID INT, -- Para verificar que el médico tiene permiso para modificar esta cita
    @NuevaFecha DATE,
    @NuevaHora TIME,
    @Motivo VARCHAR(255) = NULL
AS
BEGIN
    -- Verificar que la cita exista y pertenezca al médico
    IF NOT EXISTS (SELECT 1 FROM Citas WHERE CitaID = @CitaID AND MedicoID = @MedicoID)
    BEGIN
        RAISERROR('La cita no existe o no pertenece a este médico', 16, 1);
        RETURN;
    END
    
    -- Verificar que la cita no esté ya completada o cancelada
    DECLARE @EstadoActual VARCHAR(20);
    SELECT @EstadoActual = Estado FROM Citas WHERE CitaID = @CitaID;
    
    IF @EstadoActual != 'Programada'
    BEGIN
        RAISERROR('Solo se pueden reprogramar citas en estado "Programada"', 16, 1);
        RETURN;
    END
    
    -- Validar que la nueva fecha no sea anterior a hoy
    IF @NuevaFecha < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('No se pueden programar citas en fechas pasadas', 16, 1);
        RETURN;
    END
    
    -- Validar que no sea un horario fuera de horas laborales
    IF @NuevaHora < '08:00:00' OR @NuevaHora > '18:00:00'
    BEGIN
        RAISERROR('Las citas deben programarse entre las 8:00 y las 18:00', 16, 1);
        RETURN;
    END
    
    -- Verificar que no haya otra cita para el mismo médico en la misma fecha/hora
    IF EXISTS (
        SELECT 1 
        FROM Citas 
        WHERE MedicoID = @MedicoID 
          AND Fecha = @NuevaFecha 
          AND Hora = @NuevaHora
          AND CitaID != @CitaID
          AND Estado != 'Cancelada'
    )
    BEGIN
        RAISERROR('Ya tiene una cita programada en este horario', 16, 1);
        RETURN;
    END
    
    -- Si pasó todas las validaciones, actualizar la cita
    UPDATE Citas
    SET Fecha = @NuevaFecha,
        Hora = @NuevaHora,
        Motivo = ISNULL(@Motivo, Motivo),
        Observaciones = CONCAT(ISNULL(Observaciones, ''), 
                             ' | Reprogramada el: ', CONVERT(VARCHAR, GETDATE(), 120),
                             ' - De: ', Fecha, ' ', Hora, 
                             ' A: ', @NuevaFecha, ' ', @NuevaHora)
    WHERE CitaID = @CitaID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO