# Respaldo y restauración lógica

Durante el trabajo académico practiqué la exportación de una base MySQL y su posterior importación mediante MySQL Workbench. Esta guía describe cómo repetir ese procedimiento con el esquema sintético del repositorio, sin utilizar datos ni credenciales de la instancia académica.

## Exportación con MySQL Workbench

1. Abrir **Server → Data Export** y seleccionar el esquema `asistencia_demo`.
2. Seleccionar las tablas y la vista, elegir **Dump Structure and Data** y generar un archivo SQL autocontenido.
3. Guardar el respaldo en `backups/asistencia.sql`, carpeta excluida del control de versiones.
4. Evitar modificaciones del esquema durante la exportación. Opcionalmente, registrar la versión del servidor y calcular el hash del archivo:

   ```powershell
   Get-FileHash backups/asistencia.sql -Algorithm SHA256
   ```

## Restauración con MySQL Workbench

1. Crear un esquema de destino vacío, por ejemplo `asistencia_restore`.
2. Revisar el archivo exportado, especialmente cualquier instrucción `CREATE DATABASE` o `USE`, para evitar escribir en el esquema de origen.
3. Abrir **Server → Data Import**, elegir el archivo SQL y seleccionar el esquema de destino.
4. Ejecutar la importación y comprobar tablas, registros y consultas mediante el procedimiento de [validación](validacion.md).

## Alternativa desde la terminal

Los siguientes comandos permiten exportar e importar el esquema de demostración con las herramientas de MySQL. Ejecutarlos desde la raíz del repositorio, con `mysql` y `mysqldump` disponibles:

```powershell
New-Item -ItemType Directory -Force backups
mysqldump --host=127.0.0.1 --port=3306 --user=USUARIO --password --single-transaction --no-tablespaces --set-gtid-purged=OFF --skip-add-drop-table --result-file=backups/asistencia.sql asistencia_demo
Get-FileHash backups/asistencia.sql -Algorithm SHA256
mysql --host=127.0.0.1 --port=3306 --user=USUARIO --password -e "CREATE DATABASE asistencia_restore CHARACTER SET utf8mb4;"
mysql --host=127.0.0.1 --port=3306 --user=USUARIO --password asistencia_restore
```

Una vez abierta la sesión de `mysql`, importar el respaldo:

```sql
source backups/asistencia.sql;
exit
```

El archivo exportado no debe contener instrucciones que redirijan la importación al esquema original. Las opciones `--single-transaction` y `--set-gtid-purged=OFF` facilitan el respaldo lógico de esta base InnoDB sin incluir información de GTID; no reemplazan una estrategia de respaldo de producción.

## Comprobación de la restauración

Para revisar el esquema restaurado con PowerShell 7 y el cliente `mysql`:

```powershell
./tests/verify.ps1 -Database asistencia_restore -User USUARIO -DefaultsExtraFile C:/ruta/privada/cliente.cnf
```

La verificación comprueba los datos y las reglas incluidas en el proyecto. Utilizar un esquema de prueba: las comprobaciones de restricciones realizan inserciones que se revierten mediante transacciones. Los archivos `backups/` y `*.cnf` permanecen fuera de Git.
