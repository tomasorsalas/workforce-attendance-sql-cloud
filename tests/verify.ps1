param(
 [string]$Mysql='mysql',
 [string]$HostName='127.0.0.1',
 [int]$Port=3306,
 [string]$User='root',
 [string]$Database='asistencia_demo',
 [string]$DefaultsExtraFile='',
 [switch]$Load
)
$ErrorActionPreference='Stop'
if ($Database -notmatch '^[a-zA-Z0-9_]+$') { throw 'Nombre de esquema no valido' }
$repoRoot=Split-Path $PSScriptRoot -Parent
$clientArgs=@('--no-defaults')
if ($DefaultsExtraFile) { $clientArgs=@("--defaults-extra-file=$DefaultsExtraFile") }
$clientArgs+=@("--host=$HostName","--port=$Port","--user=$User",'--default-character-set=utf8mb4','--batch','--skip-column-names',"--database=$Database")
function Invoke-Sql([string]$Sql) {
 $result=& $Mysql @clientArgs --execute="SET SESSION sql_mode='STRICT_TRANS_TABLES,ONLY_FULL_GROUP_BY,NO_ENGINE_SUBSTITUTION'; $Sql" 2>&1
 if ($LASTEXITCODE -ne 0) { throw ($result -join "`n") }
 return (($result | ForEach-Object { "$_" }) -join "`n").Trim()
}
function Assert-Equal([string]$Name,[string]$Sql,[string]$Expected) {
 $actual=Invoke-Sql $Sql
 if ($actual -ne $Expected) { throw "$Name esperado [$Expected], obtenido [$actual]" }
 Write-Output "PASS $Name"
}
function Assert-Rejected([string]$Name,[string]$Sql,[string]$ErrorCode) {
 # Un cliente nuevo desconectado revierte cualquier INSERT dentro de esta transaccion.
 $result=& $Mysql @clientArgs --execute="START TRANSACTION; $Sql; ROLLBACK;" 2>&1
 if ($LASTEXITCODE -eq 0 -or ($result -join ' ') -notmatch "ERROR $ErrorCode ") {
  throw "$Name no fue rechazado con el error esperado $ErrorCode : $result"
 }
 Write-Output "PASS $Name"
}
if ($Load) {
 foreach ($file in @('sql/01_schema.sql','sql/02_seed.sql','sql/03_views.sql')) {
  $null=Invoke-Sql (Get-Content -Raw -Encoding utf8 (Join-Path $repoRoot $file))
 }
}
# Ejecutar las ocho consultas completas, no solo su vista base.
$null=Invoke-Sql (Get-Content -Raw -Encoding utf8 (Join-Path $repoRoot 'sql/04_queries.sql'))
Write-Output 'PASS ocho consultas ejecutadas'
Assert-Equal 'grano jornada' 'SELECT CONCAT(COUNT(*),":",COUNT(DISTINCT id_jornada)) FROM v_asistencia;' '11:11'
Assert-Equal 'sin marcas completas' 'SELECT GROUP_CONCAT(id_jornada ORDER BY id_jornada) FROM v_asistencia WHERE activo=1 AND (sin_entrada OR sin_salida);' '3,4,5,11'
Assert-Equal 'contratos y limites inclusivos' 'SELECT GROUP_CONCAT(id_jornada ORDER BY id_jornada) FROM v_asistencia WHERE contrato_fuera_vigencia=1;' '8,9'
Assert-Equal 'alertas simultaneas y nocturna' 'SELECT GROUP_CONCAT(CONCAT(id_jornada,":",minutos_atraso,":",minutos_adicionales) ORDER BY id_jornada) FROM v_asistencia WHERE atraso=1 AND tiempo_adicional=1;' '2:15:30,10:5:10'
Assert-Equal 'fila sin registro vs ambas marcas NULL' 'SELECT GROUP_CONCAT(CONCAT(id_jornada,":",sin_registro) ORDER BY id_jornada) FROM v_asistencia WHERE id_jornada IN (3,11);' '3:1,11:0'
Assert-Equal 'diferencia de area' 'SELECT GROUP_CONCAT(id_detalle) FROM empleado_detalle ed JOIN contrato_laboral cl ON cl.id_contrato=ed.contrato_vigente_id WHERE ed.area_id<>cl.area_id;' '2'
Assert-Equal 'metricas demo' 'SELECT CONCAT(COUNT(*),":",SUM(sin_registro),":",SUM(sin_entrada),":",SUM(sin_salida),":",SUM(atraso),":",SUM(salida_anticipada),":",SUM(tiempo_adicional),":",SUM(contrato_fuera_vigencia),":",SUM(sin_entrada OR sin_salida OR atraso OR salida_anticipada OR tiempo_adicional OR contrato_fuera_vigencia)) FROM v_asistencia WHERE activo=1 AND fecha>="2025-01-01" AND fecha<"2025-02-01" AND hora_fin_programada<="2025-02-01 00:00:00";' '10:1:3:3:2:1:2:2:9'
Assert-Equal 'corte excluye turno nocturno abierto' 'SELECT COUNT(*) FROM v_asistencia WHERE activo=1 AND hora_fin_programada<="2025-01-13 00:00:00";' '6'
Assert-Equal 'poblacion vacia' 'SELECT CONCAT(COUNT(*),":",COALESCE(SUM(atraso),0),":",IFNULL(ROUND(100.0*SUM(atraso)/NULLIF(COUNT(*),0),2),"NULL")) FROM v_asistencia WHERE fecha>="2030-01-01";' '0:0:NULL'
Assert-Rejected 'unicidad asistencia' 'INSERT INTO registro_asistencia VALUES (99,1,NULL,NULL)' '1062'
Assert-Rejected 'FK persona contrato' 'INSERT INTO jornada VALUES (99,1,1,2,1,"2025-01-01","2025-01-01 09:00:00","2025-01-01 18:00:00",1)' '1452'
Assert-Rejected 'orden temporal marcas' 'INSERT INTO registro_asistencia VALUES (99,6,"2025-01-11 18:00:00","2025-01-11 09:00:00")' '3819'
Write-Output 'Validacion completada. Esquema de demostracion sin modificaciones de prueba persistentes.'
