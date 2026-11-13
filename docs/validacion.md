# Pruebas y resultados esperados

## Verificación reproducible

El script [`tests/verify.ps1`](../tests/verify.ps1) permite ejecutar las ocho consultas y comprobar 13 condiciones: una de ejecución conjunta, nueve de valores y tres de rechazo por restricciones. Utiliza los modos SQL `STRICT_TRANS_TABLES`, `ONLY_FULL_GROUP_BY` y `NO_ENGINE_SUBSTITUTION` para las consultas y comprobaciones de valores.

La tabla siguiente reúne los resultados esperados para los datos sintéticos. Para obtener resultados de una instalación concreta, ejecutar el script contra un esquema de prueba.

## Resultados del dataset sintético

Periodo: `[2025-01-01,2025-02-01)`. Corte: `2025-02-01 00:00:00`.

| Indicador | Resultado |
|---|---:|
| Jornadas totales | 11 |
| Activas finalizadas dentro del periodo | 10 |
| Con marcas incompletas | 4 |
| Sin registro de asistencia | 1 |
| Sin entrada, incluyendo falta de registro | 3 |
| Sin salida, incluyendo falta de registro | 3 |
| Con atraso | 2 |
| Con salida anticipada | 1 |
| Con tiempo adicional | 2 |
| Fuera de vigencia contractual | 2 |
| Jornadas con al menos una alerta operativa | 9 |
| Porcentaje de jornadas con alerta | 90,00 % |

Las categorías se superponen. La diferencia de área es un control separado y queda fuera del porcentaje operativo. Los cuatro casos con marcas incompletas son las jornadas 3, 4, 5 y 11.

## Cobertura de las comprobaciones

| Grupo | Casos |
|---|---|
| Ejecución | Ocho consultas completas |
| Granularidad | Una fila por jornada en la vista |
| Marcaje | Marcas incompletas; registro inexistente frente a ambas marcas NULL |
| Contratos | Fuera de vigencia y fecha de término inclusiva |
| Horarios | Alertas simultáneas y turno nocturno |
| Configuración | Diferencia de área |
| Agregación | Métricas, corte temporal y población vacía |
| Restricciones | Rechazo de asistencia duplicada, contrato de otra persona y salida anterior a entrada |

Las comprobaciones de rechazo están diseñadas para revertir sus inserciones mediante transacciones, de modo que el conjunto de datos de demostración se conserve.

## Reproducción

Desde la raíz del repositorio, con un esquema vacío y PowerShell 7:

```powershell
./tests/verify.ps1 -Database asistencia_demo -User USUARIO -DefaultsExtraFile C:/ruta/privada/cliente.cnf -Load
```

Para una base cargada o restaurada, ejecutar el mismo comando sin `-Load`. La guía de [respaldo y restauración](backups.md) describe la preparación de un segundo esquema.

## Alcance de las pruebas

La versión mínima del esquema es MySQL 8.0.16 por el uso de `CHECK`. El resultado depende del servidor y del esquema utilizados. Para registrar una ejecución, conservar la versión de MySQL, la fecha, el entorno y la salida del script.

La muestra está destinada a verificar reglas y consultas. Las mediciones de rendimiento, recuperación ante fallos y objetivos RPO/RTO requieren un entorno y volumen de datos específicos.
