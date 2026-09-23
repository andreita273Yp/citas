-- ============================================================
-- Base de datos: citas_medicas
-- Motor: MySQL / InnoDB
-- Modelo normalizado hasta 3FN
-- ============================================================

CREATE DATABASE IF NOT EXISTS citas_medicas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE citas_medicas;

-- ============================================================
-- CATÁLOGOS
-- ============================================================

CREATE TABLE regimen (
    id_regimen INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_regimen_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE rol (
    id_rol INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE especialidad (
    id_especialidad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_especialidad_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE modalidad_cita (
    id_modalidad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    descripcion VARCHAR(100) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_modalidad_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE estado_cita (
    id_estado_cita INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    descripcion VARCHAR(100) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT uq_estado_cita_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

-- ============================================================
-- ENTIDADES PRINCIPALES
-- ============================================================

CREATE TABLE eps (
    id_eps INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_regimen INT UNSIGNED NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    sigla VARCHAR(20) NOT NULL,
    nit VARCHAR(20) NULL,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(100) NULL,
    direccion VARCHAR(150) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uq_eps_nombre UNIQUE (nombre),
    CONSTRAINT uq_eps_sigla UNIQUE (sigla),
    CONSTRAINT uq_eps_nit UNIQUE (nit),

    CONSTRAINT fk_eps_regimen
        FOREIGN KEY (id_regimen)
        REFERENCES regimen(id_regimen)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_rol INT UNSIGNED NOT NULL,
    correo VARCHAR(100) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME NULL,

    CONSTRAINT uq_usuario_correo UNIQUE (correo),

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE paciente (
    id_paciente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_eps INT UNSIGNED NOT NULL,
    id_usuario INT UNSIGNED NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_documento VARCHAR(30) NOT NULL,
    fecha_nacimiento DATE NULL,
    genero VARCHAR(20) NULL,
    direccion VARCHAR(150) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uq_paciente_usuario UNIQUE (id_usuario),
    CONSTRAINT uq_paciente_documento UNIQUE (tipo_documento, numero_documento),

    CONSTRAINT fk_paciente_eps
        FOREIGN KEY (id_eps)
        REFERENCES eps(id_eps)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_paciente_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE medico (
    id_medico INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT UNSIGNED NOT NULL,
    id_especialidad INT UNSIGNED NOT NULL,
    numero_documento VARCHAR(30) NOT NULL,
    tarjeta_profesional VARCHAR(50) NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uq_medico_usuario UNIQUE (id_usuario),
    CONSTRAINT uq_medico_documento UNIQUE (numero_documento),
    CONSTRAINT uq_medico_tarjeta UNIQUE (tarjeta_profesional),

    CONSTRAINT fk_medico_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_medico_especialidad
        FOREIGN KEY (id_especialidad)
        REFERENCES especialidad(id_especialidad)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE sede (
    id_sede INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_eps INT UNSIGNED NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT fk_sede_eps
        FOREIGN KEY (id_eps)
        REFERENCES eps(id_eps)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE consultorio (
    id_consultorio INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_sede INT UNSIGNED NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    tipo VARCHAR(50) NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT uq_consultorio_sede_nombre UNIQUE (id_sede, nombre),

    CONSTRAINT fk_consultorio_sede
        FOREIGN KEY (id_sede)
        REFERENCES sede(id_sede)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ============================================================
-- DISPONIBILIDAD Y CITAS
-- ============================================================

CREATE TABLE disponibilidad_medico (
    id_disponibilidad INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_medico INT UNSIGNED NOT NULL,
    id_consultorio INT UNSIGNED NULL,
    id_modalidad INT UNSIGNED NOT NULL,
    dia_semana TINYINT UNSIGNED NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado TINYINT(1) NOT NULL DEFAULT 1,

    CONSTRAINT chk_disponibilidad_dia
        CHECK (dia_semana BETWEEN 1 AND 7),

    CONSTRAINT chk_disponibilidad_horas
        CHECK (hora_fin > hora_inicio),

    CONSTRAINT fk_disponibilidad_medico
        FOREIGN KEY (id_medico)
        REFERENCES medico(id_medico)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_disponibilidad_consultorio
        FOREIGN KEY (id_consultorio)
        REFERENCES consultorio(id_consultorio)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_disponibilidad_modalidad
        FOREIGN KEY (id_modalidad)
        REFERENCES modalidad_cita(id_modalidad)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cita (
    id_cita BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT UNSIGNED NOT NULL,
    id_medico INT UNSIGNED NOT NULL,
    id_consultorio INT UNSIGNED NULL,
    id_disponibilidad INT UNSIGNED NULL,
    id_modalidad INT UNSIGNED NOT NULL,
    id_estado_cita INT UNSIGNED NOT NULL,
    fecha_cita DATETIME NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    observaciones VARCHAR(500) NULL,
    enlace_virtual VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_cita_paciente
        FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_cita_medico
        FOREIGN KEY (id_medico)
        REFERENCES medico(id_medico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_cita_consultorio
        FOREIGN KEY (id_consultorio)
        REFERENCES consultorio(id_consultorio)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_cita_disponibilidad
        FOREIGN KEY (id_disponibilidad)
        REFERENCES disponibilidad_medico(id_disponibilidad)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_cita_modalidad
        FOREIGN KEY (id_modalidad)
        REFERENCES modalidad_cita(id_modalidad)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_cita_estado
        FOREIGN KEY (id_estado_cita)
        REFERENCES estado_cita(id_estado_cita)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE historial_cita (
    id_historial BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cita BIGINT UNSIGNED NOT NULL,
    id_estado_cita INT UNSIGNED NOT NULL,
    id_usuario INT UNSIGNED NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones VARCHAR(255) NULL,

    CONSTRAINT fk_historial_cita
        FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_historial_estado
        FOREIGN KEY (id_estado_cita)
        REFERENCES estado_cita(id_estado_cita)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_historial_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX idx_eps_regimen
    ON eps(id_regimen);

CREATE INDEX idx_paciente_eps
    ON paciente(id_eps);

CREATE INDEX idx_medico_especialidad
    ON medico(id_especialidad);

CREATE INDEX idx_sede_eps
    ON sede(id_eps);

CREATE INDEX idx_consultorio_sede
    ON consultorio(id_sede);

CREATE INDEX idx_disponibilidad_medico
    ON disponibilidad_medico(id_medico);

CREATE INDEX idx_disponibilidad_modalidad
    ON disponibilidad_medico(id_modalidad);

CREATE INDEX idx_cita_paciente_fecha
    ON cita(id_paciente, fecha_cita);

CREATE INDEX idx_cita_medico_fecha
    ON cita(id_medico, fecha_cita);

CREATE INDEX idx_cita_estado_fecha
    ON cita(id_estado_cita, fecha_cita);

CREATE INDEX idx_historial_cita_fecha
    ON historial_cita(id_cita, fecha_cambio);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO regimen (nombre, descripcion) VALUES
('Contributivo', 'Régimen contributivo de salud'),
('Subsidiado', 'Régimen subsidiado de salud');

INSERT INTO rol (nombre, descripcion) VALUES
('MEDICO', 'Usuario profesional de la salud'),
('PACIENTE', 'Usuario solicitante de citas');

INSERT INTO modalidad_cita (nombre, descripcion) VALUES
('PRESENCIAL', 'Cita médica realizada físicamente en una sede'),
('VIRTUAL', 'Cita médica realizada por videollamada u otro medio remoto');

INSERT INTO estado_cita (nombre, descripcion) VALUES
('ASIGNADA', 'La cita ha sido programada'),
('CANCELADA', 'La cita fue cancelada'),
('ASISTIDA', 'El paciente asistió a la cita'),
('INASISTIDA', 'El paciente no asistió a la cita');

INSERT INTO especialidad (nombre, descripcion) VALUES
('Medicina General', 'Atención médica general');

-- ============================================================
-- NOTAS DE DISEÑO
-- ============================================================
-- 1. Un usuario tiene un rol: MEDICO o PACIENTE.
-- 2. Los datos de identidad comunes viven en usuario.
-- 3. paciente y medico contienen los atributos específicos de cada perfil.
-- 4. Cada EPS pertenece a un régimen en este modelo.
-- 5. Cada paciente pertenece a una EPS.
-- 6. Las citas pueden ser PRESENCIAL o VIRTUAL.
-- 7. Una cita presencial puede asociarse a un consultorio.
-- 8. Una cita virtual puede usar enlace_virtual y dejar consultorio en NULL.
-- 9. historial_cita conserva la trazabilidad de cambios de estado.
-- 10. El modelo evita guardar nombres de régimen, rol, modalidad o estado
--     directamente en las entidades transaccionales, favoreciendo 3FN.
