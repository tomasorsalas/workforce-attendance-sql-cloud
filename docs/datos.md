# Datos del proyecto

## Dataset ejecutable

Los archivos de `sql/` contienen el esquema de asistencia y registros sintéticos deterministas.

| Contenido | Cantidad |
|---|---:|
| Empleados ficticios | 3 |
| Áreas | 2 |
| Puestos | 1 |
| Tipos de jornada | 2 |
| Contratos | 3 |
| Detalles laborales | 3 |
| Jornadas | 11 |
| Registros de asistencia | 9 |

Los casos incluyen un turno nocturno, marcas incompletas, atrasos, tiempo adicional, una salida anticipada, diferencias de área y jornadas fuera de vigencia contractual. Los empleados utilizan nombres genéricos e identificadores `DEMO`.

## Alcance

Los registros son ficticios y permiten estudiar reglas de asistencia. Las métricas describen esta muestra y no representan resultados de una organización. El proyecto tiene carácter académico y personal.

Para cargar los datos, seguir el orden de los archivos en [`sql/`](../sql/) indicado en el [README](../README.md). Las ocho consultas están disponibles tanto en [`consultas/queries.sql`](../consultas/queries.sql) como en [`sql/04_queries.sql`](../sql/04_queries.sql).
