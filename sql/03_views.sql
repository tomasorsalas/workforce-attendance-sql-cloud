CREATE OR REPLACE SQL SECURITY INVOKER VIEW v_asistencia AS
SELECT j.id_jornada,e.identificacion,
 CONCAT_WS(' ',e.nombre,e.segundo_nombre,e.apellido_paterno,e.apellido_materno) AS nombre_completo,
 j.fecha,j.activo,j.hora_inicio_programada,j.hora_fin_programada,ra.hora_entrada,ra.hora_salida,
 (ra.jornada_id IS NULL) AS sin_registro,
 (ra.hora_entrada IS NULL) AS sin_entrada,(ra.hora_salida IS NULL) AS sin_salida,
 CASE WHEN ra.jornada_id IS NULL THEN 'Sin registro de asistencia'
  WHEN ra.hora_entrada IS NULL AND ra.hora_salida IS NULL THEN 'Sin entrada y salida'
  WHEN ra.hora_entrada IS NULL THEN 'Sin entrada'
  WHEN ra.hora_salida IS NULL THEN 'Sin salida' ELSE 'Completa' END AS estado_marcaje,
 CASE WHEN ra.hora_entrada>j.hora_inicio_programada THEN 1 ELSE 0 END AS atraso,
 CASE WHEN ra.hora_salida<j.hora_fin_programada THEN 1 ELSE 0 END AS salida_anticipada,
 CASE WHEN ra.hora_salida>j.hora_fin_programada THEN 1 ELSE 0 END AS tiempo_adicional,
 CASE WHEN ra.hora_entrada>j.hora_inicio_programada
  THEN TIMESTAMPDIFF(MINUTE,j.hora_inicio_programada,ra.hora_entrada) ELSE 0 END AS minutos_atraso,
 CASE WHEN ra.hora_salida>j.hora_fin_programada
  THEN TIMESTAMPDIFF(MINUTE,j.hora_fin_programada,ra.hora_salida) ELSE 0 END AS minutos_adicionales,
 CASE WHEN j.fecha<cl.fecha_inicio OR (cl.fecha_termino IS NOT NULL AND j.fecha>cl.fecha_termino)
  THEN 1 ELSE 0 END AS contrato_fuera_vigencia,
 ed.area_id AS area_detalle,cl.area_id AS area_contrato
FROM jornada j
JOIN empleado_detalle ed ON ed.id_detalle=j.empleado_detalle_id
JOIN empleado e ON e.id_empleado=j.empleado_id
JOIN contrato_laboral cl ON cl.id_contrato=j.contrato_id
LEFT JOIN registro_asistencia ra ON ra.jornada_id=j.id_jornada;
