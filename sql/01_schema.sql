-- MySQL >= 8.0.16. Ejecutar en un esquema NUEVO seleccionado previamente.
SET NAMES utf8mb4;
CREATE TABLE area (id_area INT PRIMARY KEY, nombre VARCHAR(80) NOT NULL UNIQUE) ENGINE=InnoDB;
CREATE TABLE puesto (id_puesto INT PRIMARY KEY, nombre VARCHAR(80) NOT NULL UNIQUE) ENGINE=InnoDB;
CREATE TABLE tipo_jornada (id_tipo INT PRIMARY KEY, nombre VARCHAR(80) NOT NULL UNIQUE) ENGINE=InnoDB;
CREATE TABLE empleado (
 id_empleado INT PRIMARY KEY, identificacion VARCHAR(30) NOT NULL UNIQUE,
 nombre VARCHAR(60) NOT NULL, segundo_nombre VARCHAR(60),
 apellido_paterno VARCHAR(60) NOT NULL, apellido_materno VARCHAR(60)
) ENGINE=InnoDB;
CREATE TABLE contrato_laboral (
 id_contrato INT PRIMARY KEY, empleado_id INT NOT NULL, area_id INT NOT NULL,
 puesto_id INT NOT NULL, fecha_inicio DATE NOT NULL, fecha_termino DATE, motivo_salida VARCHAR(120),
 UNIQUE KEY uq_contrato_empleado (id_contrato,empleado_id),
 FOREIGN KEY (empleado_id) REFERENCES empleado(id_empleado),
 FOREIGN KEY (area_id) REFERENCES area(id_area),
 FOREIGN KEY (puesto_id) REFERENCES puesto(id_puesto),
 CHECK (fecha_termino IS NULL OR fecha_termino>=fecha_inicio),
 CHECK (motivo_salida IS NULL OR fecha_termino IS NOT NULL)
) ENGINE=InnoDB;
CREATE TABLE empleado_detalle (
 id_detalle INT PRIMARY KEY, empleado_id INT NOT NULL, area_id INT NOT NULL, contrato_vigente_id INT NOT NULL,
 UNIQUE KEY uq_detalle_empleado (id_detalle,empleado_id),
 FOREIGN KEY (empleado_id) REFERENCES empleado(id_empleado),
 FOREIGN KEY (area_id) REFERENCES area(id_area),
 FOREIGN KEY (contrato_vigente_id,empleado_id) REFERENCES contrato_laboral(id_contrato,empleado_id)
) ENGINE=InnoDB;
CREATE TABLE jornada (
 id_jornada INT PRIMARY KEY, empleado_detalle_id INT NOT NULL, empleado_id INT NOT NULL,
 contrato_id INT NOT NULL, tipo_jornada_id INT NOT NULL, fecha DATE NOT NULL,
 hora_inicio_programada DATETIME NOT NULL, hora_fin_programada DATETIME NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 FOREIGN KEY (empleado_detalle_id,empleado_id) REFERENCES empleado_detalle(id_detalle,empleado_id),
 FOREIGN KEY (contrato_id,empleado_id) REFERENCES contrato_laboral(id_contrato,empleado_id),
 FOREIGN KEY (tipo_jornada_id) REFERENCES tipo_jornada(id_tipo),
 CHECK (activo IN (0,1)), CHECK (DATE(hora_inicio_programada)=fecha),
 CHECK (hora_fin_programada>hora_inicio_programada),
 INDEX ix_jornada_activo_fecha (activo,fecha)
) ENGINE=InnoDB;
CREATE TABLE registro_asistencia (
 id_registro INT PRIMARY KEY, jornada_id INT NOT NULL UNIQUE,
 hora_entrada DATETIME, hora_salida DATETIME,
 FOREIGN KEY (jornada_id) REFERENCES jornada(id_jornada),
 CHECK (hora_entrada IS NULL OR hora_salida IS NULL OR hora_salida>=hora_entrada)
) ENGINE=InnoDB;
