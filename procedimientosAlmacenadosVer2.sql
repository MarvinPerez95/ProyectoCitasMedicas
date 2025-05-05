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
    -- Primero verificamos que no haya médicos asociados
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

-- Crear un nuevo médico
-- Crear un nuevo médico con validaciones
CREATE OR ALTER PROCEDURE sp_CrearMedico
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @EspecialidadID INT,
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
        RAISERROR('Formato de email no válido', 16, 1);
        RETURN;
    END
    
    -- Validar si ya existe un médico con ese email
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Medicos WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un médico registrado con ese email', 16, 1);
        RETURN;
    END
    
    -- Validar formato básico de teléfono
    IF @Telefono IS NOT NULL AND 
       (LEN(@Telefono) < 8 OR @Telefono LIKE '%[^0-9+-]%')
    BEGIN
        RAISERROR('Formato de teléfono no válido', 16, 1);
        RETURN;
    END
    
    -- Si pasa todas las validaciones, insertar el médico
    INSERT INTO Medicos (Nombre, Apellidos, EspecialidadID, Telefono, Email, Estado)
    VALUES (@Nombre, @Apellidos, @EspecialidadID, @Telefono, @Email, 1);
    
    SELECT SCOPE_IDENTITY() AS MedicoID;
END;
GO


-- Obtener todos los médicos
CREATE PROCEDURE sp_ObtenerMedicos
AS
BEGIN
    SELECT m.MedicoID, m.Nombre, m.Apellidos, 
           m.EspecialidadID, e.Nombre AS Especialidad,
           m.Telefono, m.Email, m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    ORDER BY m.Apellidos, m.Nombre;
END;
GO


-- Obtener un médico por ID
CREATE PROCEDURE sp_ObtenerMedicoPorID
    @MedicoID INT
AS
BEGIN
    SELECT m.MedicoID, m.Nombre, m.Apellidos, 
           m.EspecialidadID, e.Nombre AS Especialidad,
           m.Telefono, m.Email, m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
    WHERE m.MedicoID = @MedicoID;
END;
GO


-- Actualizar médico
CREATE PROCEDURE sp_ActualizarMedico
    @MedicoID INT,
    @Nombre VARCHAR(50),
    @Apellidos VARCHAR(50),
    @EspecialidadID INT,
    @Telefono VARCHAR(20) = NULL,
    @Email VARCHAR(100) = NULL,
    @Estado BIT = 1
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



-- ===========================
-- PROCEDIMIENTOS PARA PACIENTES
-- ===========================

-- Crear un nuevo paciente
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
    
    -- Validar formato de email si no es NULL
    IF @Email IS NOT NULL AND 
       (@Email NOT LIKE '%_@__%.__%' OR CHARINDEX(' ', @Email) > 0)
    BEGIN
        RAISERROR('Formato de email no válido', 16, 1);
        RETURN;
    END
    
    -- Validar si ya existe un paciente con ese email
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM Pacientes WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un paciente registrado con ese email', 16, 1);
        RETURN;
    END
    
    -- Validar formato básico de teléfono
    IF @Telefono IS NOT NULL AND 
       (LEN(@Telefono) < 8 OR @Telefono LIKE '%[^0-9+-]%')
    BEGIN
        RAISERROR('Formato de teléfono no válido', 16, 1);
        RETURN;
    END
    
    -- Si pasa todas las validaciones, insertar el paciente
    INSERT INTO Pacientes (Nombre, Apellidos, edad, Genero, Direccion, Telefono, Email, FechaRegistro, Estado)
    VALUES (@Nombre, @Apellidos, @FechaNacimiento, @Genero, @Direccion, @Telefono, @Email, GETDATE(), 1);
    
    SELECT SCOPE_IDENTITY() AS PacienteID;
END;
GO


-- Obtener todos los pacientes
CREATE PROCEDURE sp_ObtenerPacientes
AS
BEGIN
    SELECT PacienteID, Nombre, Apellidos, edad, 
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
    SELECT PacienteID, Nombre, Apellidos, edad, 
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
    @Estado BIT = 1
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
    
    -- Validar formato básico de teléfono
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
        edad = @FechaNacimiento,  -- Nota: deberías cambiar 'edad' por 'FechaNacimiento'
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
CREATE PROCEDURE sp_EliminarPaciente
	@PacienteID INT
AS
BEGIN

	-- Verificar si el paciente tiene citas
	IF EXISTS (SELECT 1 FROM Citas WHERE PacienteID = @PacienteID)
	BEGIN
		-- En lugar de eliminar físicamente, actualizamos el estado a inactivo
		UPDATE Pacientes
		SET Estado = 0
		WHERE PacienteID = @PacienteID;

		SELECT 'Paciente marcado como inactivo debido a citas existentes' AS Mensaje;
	END
	ELSE
	BEGIN
		-- Si no tiene citas, se puede eliminar físicamente
		DELETE FROM Pacientes
		WHERE PacienteID = @PacienteID;

		SELECT @@ROWCOUNT AS FilasAfectadas;
	END
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
    
    -- Validar que no sea un horario fuera de horas laborales (8:00 - 18:00)
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
    
    -- Si pasó todas las validaciones, crear la cita
    INSERT INTO Citas (PacienteID, MedicoID, Fecha, Hora, Motivo, Estado, FechaCreacion)
    VALUES (@PacienteID, @MedicoID, @Fecha, @Hora, @Motivo, 'Programada', GETDATE());
    
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

-- Obtener citas por médico
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

-- Actualizar estado de cita
CREATE PROCEDURE sp_ActualizarEstadoCita
    @CitaID INT,
    @Estado VARCHAR(20),
    @Observaciones VARCHAR(500) = NULL
AS
BEGIN
    IF @Estado NOT IN ('Programada', 'Completada', 'Cancelada')
    BEGIN
        RAISERROR('Estado no válido. Los valores permitidos son: Programada, Completada, Cancelada', 16, 1);
        RETURN;
    END
    
    UPDATE Citas
    SET Estado = @Estado,
        Observaciones = @Observaciones
    WHERE CitaID = @CitaID;
    
    SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO

-- Obtener citas por paciente
CREATE PROCEDURE sp_ObtenerCitasPorPaciente
	@PacienteID INT
AS
BEGIN
	SELECT c.CitaID, c.PacienteID, p.Nombre + '' + p.Apellidos AS NombrePaciente,
		   c.MedicoID, m.Nombre + '' + m.Apellidos AS NombreMedico,
		   c.Estado, c.Observaciones, c.FechaCreacion
	FROM Citas c
	INNER JOIN Pacientes p ON c.PacienteID = p.PacienteID
	INNER JOIN Medicos m ON c.MedicoID = m.MedicoID
	INNER JOIN Especialidades e ON m.EspecialidadID = e.EspecialidadID
	WHERE c.PacienteID = @PacienteID
	ORDER BY c.Fecha DESC, c.Hora;
END;
GO


-- Actualizar Cita Completa
CREATE PROCEDURE sp_ActualizarCita
	@CitaID INT,
	@PacienteID INT,
	@MedicoID INT,
	@Fecha DATE,
	@Hora TIME,
	@Motivo VARCHAR (200) = NULL,
	@Estado VARCHAR (20) = 'Programada',
	@Observaciones VARCHAR (500) = NULL

AS
BEGIN

	-- Verificar que no haya conflicto de horario para el nuevo médico
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
CREATE PROCEDURE sp_EliminarCita
	@CitaID INT
AS
BEGIN
	-- En lugar de elinnar físicamente, actualizamos a cancelada
	UPDATE citas
	SET Estado = 'Cancelada',
		Observaciones = CONCAT (ISNULL(Observaciones, ''),
								' | Cancelada en: ',
								CONVERT (VARCHAR , GETDATE(),120))
	WHERE CitaID = @CitaID;

	SELECT @@ROWCOUNT AS FilasAfectadas;
END;
GO


-- IMPLEMENTACIÓN DE PROCEDIMIENTOS DE AUTENTICACIÓN

-- Autenticación de Usuarios
-- Validar credenciales de usuario
CREATE PROCEDURE sp_ValidarUsuario
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
    
    -- Verificar si se encontró el usuario y está activo
    IF @UsuarioID IS NULL
    BEGIN
        -- Credenciales incorrectas o usuario no existe
        SELECT 0 AS Autenticado, 'Credenciales inválidas' AS Mensaje;
        RETURN;
    END
    
    IF @Estado = 0
    BEGIN
        -- Usuario existe pero está inactivo
        SELECT 0 AS Autenticado, 'Usuario inactivo. Contacte al administrador.' AS Mensaje;
        RETURN;
    END
    
    -- Usuario autenticado correctamente, actualizar último acceso
    UPDATE Usuarios
    SET UltimoAcceso = GETDATE()
    WHERE UsuarioID = @UsuarioID;
    
    -- Devolver información del usuario (sin la contraseña)
    SELECT 
        1 AS Autenticado,
        'Autenticación exitosa' AS Mensaje,
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


-- Cambiar contraseña de usuario
CREATE PROCEDURE sp_CambiarPassword
    @UsuarioID INT,
    @PasswordActual VARCHAR(255),
    @PasswordNueva VARCHAR(255)
AS
BEGIN
    -- Verificar que el usuario exista y que la contraseña actual sea correcta
    IF NOT EXISTS (SELECT 1 FROM Usuarios 
                   WHERE UsuarioID = @UsuarioID 
                   AND Password = @PasswordActual)
    BEGIN
        SELECT 0 AS Exito, 'Contraseña actual incorrecta' AS Mensaje;
        RETURN;
    END
    
    -- Validar que la nueva contraseña cumpla requisitos de seguridad
    IF LEN(@PasswordNueva) < 8
    BEGIN
        SELECT 0 AS Exito, 'La nueva contraseña debe tener al menos 8 caracteres' AS Mensaje;
        RETURN;
    END
    
    -- Actualizar la contraseña
    UPDATE Usuarios
    SET Password = @PasswordNueva
    WHERE UsuarioID = @UsuarioID;
    
    SELECT 1 AS Exito, 'Contraseña actualizada correctamente' AS Mensaje;
END;
GO


-- Reestablecer contraseña (solo para administradores)
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
        SELECT 0 AS Exito, 'Solo los administradores pueden reestablecer contraseñas' AS Mensaje;
        RETURN;
    END
    
    -- Verificar que el usuario a modificar exista
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE UsuarioID = @UsuarioID)
    BEGIN
        SELECT 0 AS Exito, 'El usuario no existe' AS Mensaje;
        RETURN;
    END
    
    -- Actualizar la contraseña
    UPDATE Usuarios
    SET Password = @NuevaPassword
    WHERE UsuarioID = @UsuarioID;
    
    SELECT 1 AS Exito, 'Contraseña reestablecida correctamente' AS Mensaje;
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
        SELECT 0 AS Exito, 'Formato de email no válido' AS Mensaje;
        RETURN;
    END
    
    -- Verificar que el email no esté ya registrado
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Email = @Email)
    BEGIN
        SELECT 0 AS Exito, 'El email ya está registrado' AS Mensaje;
        RETURN;
    END
    
    -- Validar que la contraseña cumpla requisitos mínimos
    IF LEN(@Password) < 8
    BEGIN
        SELECT 0 AS Exito, 'La contraseña debe tener al menos 8 caracteres' AS Mensaje;
        RETURN;
    END
    
    -- Si el rol es médico, verificar que MedicoID no sea NULL y exista
    IF @Rol = 'Medico' AND (@MedicoID IS NULL OR NOT EXISTS (SELECT 1 FROM Medicos WHERE MedicoID = @MedicoID))
    BEGIN
        SELECT 0 AS Exito, 'Para un usuario médico, debe proporcionar un ID de médico válido' AS Mensaje;
        RETURN;
    END
    
    -- Si el rol no es médico, MedicoID debe ser NULL
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
