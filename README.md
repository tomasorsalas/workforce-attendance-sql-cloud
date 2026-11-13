# Workforce Attendance — SQL & Cloud Database

Proyecto académico y personal de análisis de asistencia laboral con MySQL, desarrollado por **Tomás Orellana**. El proyecto relaciona turnos programados, contratos y registros de entrada y salida para identificar diferencias de horario y problemas de calidad de datos.

**MySQL · MySQL Workbench · Amazon RDS · Looker Studio · PowerShell**

## Análisis de asistencia

Las consultas permiten identificar marcas incompletas, atrasos, salidas anticipadas, tiempo adicional y jornadas fuera de vigencia contractual. También comparan el área del detalle laboral con la del contrato y presentan indicadores agregados sobre un periodo definido.

El estado de marcaje y las alertas se calculan por separado: una jornada puede tener atraso y tiempo adicional al mismo tiempo. Una marca faltante representa un dato pendiente; el tiempo adicional representa una salida posterior al horario programado y requiere evaluación independiente para determinar su autorización.

## Datos del proyecto

El repositorio organiza el modelo, los datos y las consultas de asistencia:

| Ubicación | Contenido |
|---|---|
| `consultas/` | Punto de acceso a las ocho consultas de asistencia |
| `sql/` | Esquema, dataset sintético determinista, vista y consultas ejecutables |

En el trabajo académico utilicé MySQL alojado en Amazon RDS y MySQL Workbench para consultar la base y practicar exportación y restauración lógica. Para compartir el análisis de forma reproducible, este repositorio utiliza un conjunto independiente de datos sintéticos, sin información personal ni respaldos de la instancia RDS.

El dataset ejecutable contiene tres empleados ficticios, once jornadas y nueve registros de asistencia. Utiliza identificadores `DEMO` y casos controlados de marcaje incompleto, turnos nocturnos y diferencias contractuales. Sus resultados corresponden a esta demostración. Como parte del trabajo académico, también desarrollé una visualización en Looker Studio. Este repositorio se concentra en la estructura de datos y el análisis SQL; el dashboard no forma parte de los archivos publicados.

## Instalación

Requisitos: servidor MySQL 8.0.16 o superior y un cliente SQL como MySQL Workbench. La ejecución local funciona sin una cuenta AWS.

1. Conectarse al servidor desde Workbench y crear un esquema vacío:

   ```sql
   CREATE DATABASE asistencia_demo CHARACTER SET utf8mb4;
   USE asistencia_demo;
   ```

2. Seleccionar `asistencia_demo` como esquema predeterminado. Confirmar la selección en cada pestaña SQL o ejecutar `USE asistencia_demo;`.
3. Ejecutar los archivos completos en este orden:

   | Archivo | Contenido |
   |---|---|
   | [`sql/01_schema.sql`](sql/01_schema.sql) | Tablas, claves y restricciones |
   | [`sql/02_seed.sql`](sql/02_seed.sql) | Dataset sintético |
   | [`sql/03_views.sql`](sql/03_views.sql) | Vista `v_asistencia` |
   | [`sql/04_queries.sql`](sql/04_queries.sql) | Consultas de análisis |

La carga es de una sola ejecución por esquema. Para repetirla, crear otro esquema vacío.

## Consultas disponibles

| N.º | Consulta |
|---|---|
| 1 | Jornadas con marcas incompletas |
| 2 | Atrasos y minutos asociados |
| 3 | Tiempo adicional observado |
| 4 | Jornadas fuera de vigencia contractual |
| 5 | Diferencias de área entre detalle laboral y contrato |
| 6 | Estado de marcaje y alertas por jornada |
| 7 | Indicadores agregados |
| 8 | Salidas anticipadas |

El archivo de consultas define `@desde`, `@hasta` y `@corte`. El periodo incluye el inicio y excluye el fin. Las consultas 1, 2, 3, 4, 7 y 8 usan jornadas activas finalizadas al corte; la 5 evalúa configuración laboral y la 6 muestra todas las jornadas del periodo con su estado.

## Verificación

Con PowerShell 7 y el cliente `mysql`, ejecutar desde la raíz del repositorio sobre un esquema vacío:

```powershell
./tests/verify.ps1 -Database asistencia_demo -User USUARIO -DefaultsExtraFile C:/ruta/privada/cliente.cnf -Load
```

El archivo de conexión contiene una sección `[client]` con la contraseña y se mantiene fuera de Git. Los parámetros `-Mysql`, `-HostName` y `-Port` permiten ajustar el cliente y la conexión. Para verificar una base ya cargada, omitir `-Load`.

El script permite ejecutar las ocho consultas y evaluar 13 comprobaciones automatizadas. Para el periodo de enero de 2025, los datos de demostración contemplan 10 jornadas activas finalizadas: 4 con marcas incompletas, 2 con atraso y 2 fuera de vigencia contractual. Consulta los [resultados esperados y el procedimiento de verificación](docs/validacion.md).

## Documentación

- [Modelo de datos y reglas](docs/modelo.md)
- [Conexión con Amazon RDS](docs/aws.md)
- [Respaldo y restauración](docs/backups.md)
- [Pruebas y resultados](docs/validacion.md)
- [Datos del proyecto](docs/datos.md)
- [Consultas de asistencia](consultas/README.md)

El alcance comprende un resumen de entrada y salida por jornada, fechas en hora local y controles de integridad relacional. Pausas, múltiples marcajes e historial de áreas quedan fuera del modelo.
