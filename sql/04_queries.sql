-- Ejecutar sql/01, 02 y 03 primero. Periodo [desde,hasta), corte reproducible.
SET @desde='2025-01-01';
SET @hasta='2025-02-01';
SET @corte='2025-02-01 00:00:00';

-- 1. Jornadas activas finalizadas con marcas incompletas.
SELECT id_jornada,identificacion,nombre_completo,fecha,estado_marcaje
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta
 AND hora_fin_programada<=@corte AND (sin_entrada=1 OR sin_salida=1)
ORDER BY fecha,id_jornada;

-- 2. Atrasos; minutos enteros truncados, flag conserva segundos positivos.
SELECT id_jornada,identificacion,fecha,minutos_atraso
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta
 AND hora_fin_programada<=@corte AND atraso=1
ORDER BY fecha,id_jornada;

-- 3. Tiempo adicional observado, no horas extra aprobadas.
SELECT id_jornada,identificacion,fecha,minutos_adicionales
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta
 AND hora_fin_programada<=@corte AND tiempo_adicional=1
ORDER BY fecha,id_jornada;

-- 4. Vigencia inclusiva, evaluada en la fecha de inicio de la jornada.
SELECT id_jornada,identificacion,fecha
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta
 AND hora_fin_programada<=@corte AND contrato_fuera_vigencia=1
ORDER BY fecha,id_jornada;

-- 5. Diferencias de area en la configuracion del detalle laboral.
SELECT ed.id_detalle,e.identificacion,ed.area_id AS area_empleado,cl.area_id AS area_contrato
FROM empleado_detalle ed
JOIN empleado e ON e.id_empleado=ed.empleado_id
JOIN contrato_laboral cl ON cl.id_contrato=ed.contrato_vigente_id
WHERE ed.area_id<>cl.area_id
ORDER BY ed.id_detalle;

-- 6. Marcaje y flags independientes; permite atraso y tiempo adicional juntos.
SELECT id_jornada,identificacion,fecha,
 CASE WHEN activo=0 THEN 'Jornada inactiva'
      WHEN hora_fin_programada>@corte THEN 'Pendiente de cierre'
      ELSE estado_marcaje END AS estado,
 atraso,salida_anticipada,tiempo_adicional,contrato_fuera_vigencia
FROM v_asistencia
WHERE fecha>=@desde AND fecha<@hasta
ORDER BY fecha,id_jornada;

-- 7. Misma poblacion para todos los indicadores; categorias se superponen.
SELECT COUNT(*) AS jornadas_activas_finalizadas,
 COALESCE(SUM(sin_registro),0) AS sin_registro,
 COALESCE(SUM(sin_entrada),0) AS sin_entrada,
 COALESCE(SUM(sin_salida),0) AS sin_salida,
 COALESCE(SUM(atraso),0) AS atrasos,
 COALESCE(SUM(salida_anticipada),0) AS salidas_anticipadas,
 COALESCE(SUM(tiempo_adicional),0) AS con_tiempo_adicional,
 COALESCE(SUM(contrato_fuera_vigencia),0) AS contratos_fuera_vigencia,
 COALESCE(SUM(sin_entrada OR sin_salida OR atraso OR salida_anticipada
  OR tiempo_adicional OR contrato_fuera_vigencia),0) AS jornadas_con_alerta,
 ROUND(100.0*SUM(sin_entrada OR sin_salida OR atraso OR salida_anticipada
  OR tiempo_adicional OR contrato_fuera_vigencia)/NULLIF(COUNT(*),0),2) AS porcentaje_con_alerta
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta AND hora_fin_programada<=@corte;

-- 8. Salidas anticipadas, independientes del atraso.
SELECT id_jornada,identificacion,fecha,hora_salida,hora_fin_programada
FROM v_asistencia
WHERE activo=1 AND fecha>=@desde AND fecha<@hasta
 AND hora_fin_programada<=@corte AND salida_anticipada=1
ORDER BY fecha,id_jornada;
