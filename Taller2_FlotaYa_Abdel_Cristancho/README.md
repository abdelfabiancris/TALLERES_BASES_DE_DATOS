# Taller 2 – FlotaYa
**Estudiante:** Abdel Cristancho  
**Motor:** MySQL 8.0.16 o superior  
**Fecha de corte:** 2026-11-23

## Archivos
- `00_diagrama.md`: modelo ER Mermaid, cardinalidades, normalización y preguntas guía.
- `01_ddl.sql`: base `flotaya` y 25 tablas.
- `02_dml.sql`: catálogos, datos semilla y conteos.
- `03_dql.sql`: Q-01 a Q-12.
- `04_dql_avanzado.sql`: funciones, procedimientos, roles y cuentas.
- `05_tcl.sql`: transacciones y auditoría.
- `06_retos.sql`: R1-R3 opcionales.

## Ejecución
1. Abre MySQL Workbench y conecta con una cuenta administradora local.
2. Ejecuta `01_ddl.sql`, `02_dml.sql`, `03_dql.sql`, `04_dql_avanzado.sql`, `05_tcl.sql`.
3. Ejecuta `06_retos.sql` si deseas la bonificación.
4. Las sentencias con `ESPERADO: ERROR` están comentadas: descoméntalas y ejecútalas individualmente para probar el error. No ejecutes operaciones TCL más de una vez sobre el mismo conjunto de datos.
5. Para evidencias, crea tres conexiones en Workbench con los usuarios `asesor_flotaya`, `taller_flotaya` y `auditor_flotaya`. Clave de práctica: `Practica_2026*`. Guarda una captura por cuenta en `evidencias/`.

## Advertencias importantes
- `01_ddl.sql` elimina y recrea `flotaya`; no lo ejecutes si quieres conservar datos.
- Los identificadores de reserva y contrato empiezan en 501 y 9001.
- El enunciado exige más casos históricos y operaciones de seguridad que los que se pueden demostrar con una única ejecución automática. Revisa las llamadas comentadas y completa las capturas desde Workbench.
- Verifica los resultados en tu instalación de MySQL antes de entregar. No se ha certificado la ejecución en un servidor MySQL real desde este entorno.
