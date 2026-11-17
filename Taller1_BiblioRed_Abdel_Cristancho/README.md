# Taller 1 – BiblioRed

**Estudiante:** Abdel Cristancho  
**Asignatura:** MySQL II  
**Base de datos:** `bibliored`  
**Fecha de corte del taller:** 10 de noviembre de 2026

## Descripción
Diseño y construcción de una base de datos para una red física de bibliotecas. Incluye el modelo entidad-relación, creación de tablas, carga y manipulación de datos, consultas, procedimientos almacenados y transacciones.

## Herramientas
- MySQL Server 8.0.16 o superior.
- MySQL Workbench.
- Visual Studio Code (opcional, para editar los archivos SQL y Markdown).

## Archivos
| Archivo | Contenido |
|---|---|
| `00_diagrama.md` | Diagrama ER en Mermaid, cardinalidades y normalización |
| `01_ddl.sql` | Creación de la base, tablas y restricciones |
| `02_dml.sql` | Datos, UPDATE, DELETE y pruebas de restricciones |
| `03_dql.sql` | Consultas Q-01 a Q-12 |
| `04_dql_avanzado.sql` | Seis procedimientos almacenados y pruebas |
| `05_tcl.sql` | Ejercicios de transacciones y procedimiento todo-o-nada |
| `06_retos.sql` | Retos opcionales R1, R2 y R3 |

## Cómo ejecutar
1. Abre MySQL Workbench y conéctate a tu servidor local.
2. Abre cada archivo `.sql` y ejecútalos en este orden: `01_ddl.sql`, `02_dml.sql`, `03_dql.sql`, `04_dql_avanzado.sql`, `05_tcl.sql`.
3. Ejecuta `06_retos.sql` si deseas realizar la bonificación.
4. Para las pruebas marcadas como **ESPERADO: ERROR**, descomenta y ejecuta cada llamada por separado. Es normal que esas pruebas produzcan el error descrito.
5. `01_ddl.sql` elimina y vuelve a crear la base `bibliored`. No lo ejecutes si necesitas conservar datos previos.

## Nota
El taller fija todas las fechas de negocio en el 10 de noviembre de 2026. Los datos personales, autores, editoriales e ISBN usados son ficticios. Revisa y ejecuta las pruebas de manera individual en Workbench, especialmente las que se espera que fallen.
