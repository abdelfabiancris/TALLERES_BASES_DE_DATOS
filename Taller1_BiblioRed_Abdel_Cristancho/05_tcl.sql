USE bibliored;

-- T1. El ejemplar sin ficha.
-- Identifica el ejemplar disponible y socio activo sin multas (copia 25 y socio 14).
SELECT id,barcode,status FROM copies WHERE id=25;
SELECT id,document_number,status FROM members WHERE id=14;
-- Sin transacción: la llamada actualiza primero copies y luego falla al insertar el préstamo
-- por la FK employee_id (empleado 99999 inexistente). Ejecutar esta llamada sola.
-- CALL sp_prestar_ejemplar(25,14,99999,'2026-11-10');
-- Comprobar que quedó PRESTADO sin préstamo ACTIVO:
SELECT c.id,c.barcode,c.status,l.id AS prestamo_activo
FROM copies c LEFT JOIN loans l ON l.copy_id=c.id AND l.status='ACTIVO'
WHERE c.id=25;
-- Corregir el estado con SELECT previo y UPDATE por PK.
SELECT id,barcode,status FROM copies WHERE id=25;
UPDATE copies SET status='DISPONIBLE' WHERE id=25;
SELECT id,barcode,status FROM copies WHERE id=25;

-- Con transacción: repetir el error; antes del ROLLBACK debe observarse el cambio no confirmado.
START TRANSACTION;
-- Ejecutar individualmente y luego continuar con los SELECT siguientes:
-- CALL sp_prestar_ejemplar(25,14,99999,'2026-11-10');
SELECT id,barcode,status FROM copies WHERE id=25;
ROLLBACK;
SELECT id,barcode,status FROM copies WHERE id=25;
-- Respuesta: sin transacción, el UPDATE previo al INSERT es una sentencia confirmada
-- independientemente; el error posterior no revierte automáticamente la sentencia anterior.
-- Dentro de la transacción, ROLLBACK revierte el UPDATE y conserva DISPONIBLE.

-- T2. Wrapper transaccional: todo o nada.
DROP PROCEDURE IF EXISTS sp_prestar_ejemplar_tx;
DELIMITER $$
CREATE PROCEDURE sp_prestar_ejemplar_tx(IN p_copy_id BIGINT, IN p_member_id BIGINT,
 IN p_employee_id BIGINT, IN p_loan_date DATE)
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN
  ROLLBACK;
  RESIGNAL;
 END;
 START TRANSACTION;
 CALL sp_prestar_ejemplar(p_copy_id,p_member_id,p_employee_id,p_loan_date);
 COMMIT;
END$$
DELIMITER ;

-- Caso 1: debe fallar por FK del empleado y dejar el ejemplar DISPONIBLE.
SELECT id,status FROM copies WHERE id=25;
-- CALL sp_prestar_ejemplar_tx(25,14,99999,'2026-11-10');
SELECT id,status FROM copies WHERE id=25;

-- Caso 2: ejemplar prestado; debe fallar con el mensaje de negocio.
-- CALL sp_prestar_ejemplar_tx(7,14,2,'2026-11-10');

-- Caso 3: préstamo correcto (solo ejecutar una vez).
-- CALL sp_prestar_ejemplar_tx(25,14,2,'2026-11-10');

-- Evidencia final: los ejemplares prestados deben coincidir con préstamos activos.
SELECT
 (SELECT COUNT(*) FROM copies WHERE status='PRESTADO') AS ejemplares_prestados,
 (SELECT COUNT(*) FROM loans WHERE status='ACTIVO') AS prestamos_activos;
-- El AUTO_INCREMENT puede avanzar aunque una transacción se revierta:
-- MySQL no reutiliza necesariamente los valores de AUTO_INCREMENT consumidos.
