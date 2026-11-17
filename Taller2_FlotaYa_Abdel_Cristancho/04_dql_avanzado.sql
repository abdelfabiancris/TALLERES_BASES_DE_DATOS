USE flotaya;
-- MySQL exige declarar características de las funciones almacenadas.
-- DROP/CREATE de roles y cuentas es idempotente para ejecutar este archivo dos veces.
DROP FUNCTION IF EXISTS fn_prueba_1418;
-- ESPERADO: ERROR 1418 al intentar crear una función sin DETERMINISTIC/NO SQL/READS SQL DATA.
-- CREATE FUNCTION fn_prueba_1418() RETURNS INT RETURN 1;

DROP FUNCTION IF EXISTS fn_edad_conductor;
DELIMITER $$
CREATE FUNCTION fn_edad_conductor(p_birth_date DATE,p_reference_date DATE)
RETURNS INT DETERMINISTIC NO SQL
BEGIN
 RETURN TIMESTAMPDIFF(YEAR,p_birth_date,p_reference_date);
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS fn_valor_alquiler;
DELIMITER $$
CREATE FUNCTION fn_valor_alquiler(p_category_id BIGINT,p_pickup DATE,p_return DATE)
RETURNS DECIMAL(12,2) DETERMINISTIC READS SQL DATA
BEGIN
 DECLARE v_day DATE;
 DECLARE v_type VARCHAR(10);
 DECLARE v_rate DECIMAL(12,2);
 DECLARE v_total DECIMAL(12,2) DEFAULT 0;
 DECLARE v_message VARCHAR(128);
 IF p_return<=p_pickup THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha final debe ser posterior a la inicial'; END IF;
 SET v_day=p_pickup;
 WHILE v_day<p_return DO
  SET v_type=NULL; SET v_rate=NULL;
  SELECT s.season_type INTO v_type FROM seasons s WHERE v_day BETWEEN s.starts_on AND s.ends_on LIMIT 1;
  IF v_type IS NULL THEN
   SET v_message=CONCAT('No hay temporada o tarifa para el día ',DATE_FORMAT(v_day,'%Y-%m-%d'));
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
  END IF;
  SELECT daily_rate INTO v_rate FROM seasonal_rates WHERE category_id=p_category_id AND season_type=v_type;
  IF v_rate IS NULL THEN
   SET v_message=CONCAT('No hay temporada o tarifa para el día ',DATE_FORMAT(v_day,'%Y-%m-%d'));
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_message;
  END IF;
  SET v_total=v_total+v_rate;
  SET v_day=DATE_ADD(v_day,INTERVAL 1 DAY);
 END WHILE;
 RETURN v_total;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS fn_licencia_vigente;
DELIMITER $$
CREATE FUNCTION fn_licencia_vigente(p_customer_id BIGINT,p_reference_date DATE)
RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
BEGIN
 RETURN EXISTS(SELECT 1 FROM licenses WHERE customer_id=p_customer_id
 AND issued_on<=p_reference_date AND expires_on>=p_reference_date);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_crear_reserva;
DELIMITER $$
CREATE PROCEDURE sp_crear_reserva(IN p_customer_id BIGINT,IN p_vehicle_id BIGINT,
 IN p_pickup_branch_id BIGINT,IN p_return_branch_id BIGINT,IN p_pickup DATE,IN p_return DATE,
 OUT p_reservation_id BIGINT)
BEGIN
 DECLARE v_status VARCHAR(20); DECLARE v_birth DATE; DECLARE v_category BIGINT;
 DECLARE v_age INT; DECLARE v_min_age INT; DECLARE v_rate DECIMAL(12,2);
 DECLARE v_vehicle_status VARCHAR(30);
 IF NOT EXISTS(SELECT 1 FROM customers WHERE id=p_customer_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente no existe'; END IF;
 SELECT status,birth_date INTO v_status,v_birth FROM customers WHERE id=p_customer_id;
 IF v_status='BLOQUEADO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente está bloqueado'; END IF;
 IF p_return<=p_pickup THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La devolución debe ser posterior a la recogida'; END IF;
 IF NOT EXISTS(SELECT 1 FROM vehicles WHERE id=p_vehicle_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo no existe'; END IF;
 SELECT status,mo.category_id INTO v_vehicle_status,v_category FROM vehicles ve
 JOIN models mo ON mo.id=ve.model_id WHERE ve.id=p_vehicle_id;
 IF v_vehicle_status='FUERA_DE_SERVICIO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo está fuera de servicio'; END IF;
 IF EXISTS(SELECT 1 FROM reservations WHERE vehicle_id=p_vehicle_id
 AND status IN('PENDIENTE','CONFIRMADA','CONVERTIDA')
 AND pickup_date<=p_return AND return_date>=p_pickup) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El vehículo ya está reservado en esas fechas';
 END IF;
 SELECT min_driver_age INTO v_min_age FROM categories WHERE id=v_category;
 SET v_age=fn_edad_conductor(v_birth,p_pickup);
 IF v_age<v_min_age THEN
  SET @business_msg=CONCAT('El cliente tiene ',v_age,' años y la categoría exige ',v_min_age);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=@business_msg;
 END IF;
 IF NOT fn_licencia_vigente(p_customer_id,p_return) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El cliente no tiene licencia vigente durante todo el alquiler'; END IF;
 SET v_rate=fn_valor_alquiler(v_category,p_pickup,p_return);
 INSERT INTO reservations(customer_id,vehicle_id,pickup_branch_id,return_branch_id,pickup_date,return_date,quoted_amount,status)
 VALUES(p_customer_id,p_vehicle_id,p_pickup_branch_id,p_return_branch_id,p_pickup,p_return,v_rate,'PENDIENTE');
 SET p_reservation_id=LAST_INSERT_ID();
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_cerrar_contrato;
DELIMITER $$
CREATE PROCEDURE sp_cerrar_contrato(IN p_contract_id BIGINT,IN p_close_date DATE,OUT p_balance DECIMAL(12,2))
BEGIN
 DECLARE v_status VARCHAR(20); DECLARE v_return DATE; DECLARE v_start DATE;
 DECLARE v_reservation BIGINT; DECLARE v_vehicle BIGINT; DECLARE v_category BIGINT;
 DECLARE v_return_branch BIGINT; DECLARE v_mileage INT; DECLARE v_rental DECIMAL(12,2);
 DECLARE v_extras DECIMAL(12,2); DECLARE v_damages DECIMAL(12,2); DECLARE v_paid DECIMAL(12,2);
 DECLARE v_deposit DECIMAL(12,2); DECLARE v_apply DECIMAL(12,2);
 IF NOT EXISTS(SELECT 1 FROM contracts WHERE id=p_contract_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no existe'; END IF;
 SELECT status,started_on,expected_end,actual_return,reservation_id INTO v_status,v_start,@expected,v_return,v_reservation
 FROM contracts WHERE id=p_contract_id;
 IF v_status<>'ABIERTO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no está abierto'; END IF;
 IF v_return IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El contrato no tiene devolución registrada'; END IF;
 IF NOT EXISTS(SELECT 1 FROM inspections WHERE contract_id=p_contract_id AND stage='DEVOLUCION') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falta la inspección de devolución'; END IF;
 IF p_close_date<=v_start THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha de cierre debe ser posterior al inicio'; END IF;
 SELECT r.vehicle_id,r.return_branch_id,mo.category_id INTO v_vehicle,v_return_branch,v_category
 FROM reservations r JOIN vehicles ve ON ve.id=r.vehicle_id JOIN models mo ON mo.id=ve.model_id WHERE r.id=v_reservation;
 SELECT mileage_km INTO v_mileage FROM returns WHERE contract_id=p_contract_id;
 SET v_rental=fn_valor_alquiler(v_category,v_start,v_return);
 SELECT COALESCE(SUM(ce.quantity*ce.agreed_daily_price*DATEDIFF(v_return,v_start)),0) INTO v_extras
 FROM contract_extras ce WHERE ce.contract_id=p_contract_id;
 SELECT COALESCE(SUM(repair_cost),0) INTO v_damages FROM damages d
 JOIN inspections i ON i.id=d.inspection_id WHERE i.contract_id=p_contract_id AND i.stage='DEVOLUCION' AND d.charge_customer=TRUE;
 SELECT amount INTO v_deposit FROM deposits WHERE contract_id=p_contract_id;
 SET v_apply=LEAST(v_damages,v_deposit);
 UPDATE deposits SET applied_amount=v_apply,
 status=IF(v_apply>0,'APLICADO','LIBERADO'),
 released_at=IF(v_apply>0,NULL,NOW()) WHERE contract_id=p_contract_id;
 IF v_apply>0 THEN
  INSERT INTO payments(contract_id,concept,amount,payment_method,paid_at)
  VALUES(p_contract_id,'DAÑOS',v_apply,'DEPOSITO',NOW());
 END IF;
 SELECT COALESCE(SUM(amount),0) INTO v_paid FROM payments WHERE contract_id=p_contract_id;
 UPDATE contracts SET rental_amount=v_rental,actual_return=v_return,status='CERRADO' WHERE id=p_contract_id;
 UPDATE vehicles SET status='DISPONIBLE',branch_id=v_return_branch,mileage_km=v_mileage WHERE id=v_vehicle;
 SET p_balance=v_rental+v_extras+v_damages-v_paid;
END$$
DELIMITER ;

-- Roles y cuentas: DROP IF EXISTS evita fallos al repetir el archivo.
DROP ROLE IF EXISTS rol_asesor_flotaya;
DROP ROLE IF EXISTS rol_taller_flotaya;
DROP ROLE IF EXISTS rol_auditor_flotaya;
CREATE ROLE rol_asesor_flotaya,rol_taller_flotaya,rol_auditor_flotaya;
GRANT SELECT ON flotaya.reservations TO rol_asesor_flotaya;
GRANT INSERT,UPDATE ON flotaya.reservations TO rol_asesor_flotaya;
GRANT SELECT ON flotaya.customers TO rol_asesor_flotaya;
GRANT SELECT ON flotaya.vehicles TO rol_asesor_flotaya;
GRANT EXECUTE ON PROCEDURE flotaya.sp_crear_reserva TO rol_asesor_flotaya;
GRANT EXECUTE ON FUNCTION flotaya.fn_valor_alquiler TO rol_asesor_flotaya;
GRANT SELECT,INSERT,UPDATE ON flotaya.maintenances TO rol_taller_flotaya;
GRANT SELECT (id,plate,status,mileage_km,branch_id), UPDATE(status) ON flotaya.vehicles TO rol_taller_flotaya;
GRANT SELECT ON flotaya.contracts TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.reservations TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.vehicles TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.maintenances TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.returns TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.inspections TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.damages TO rol_auditor_flotaya;
GRANT SELECT ON flotaya.deposits TO rol_auditor_flotaya;
GRANT SELECT (id,contract_id,concept,amount,paid_at) ON flotaya.payments TO rol_auditor_flotaya;

DROP USER IF EXISTS 'asesor_flotaya'@'localhost';
DROP USER IF EXISTS 'taller_flotaya'@'localhost';
DROP USER IF EXISTS 'auditor_flotaya'@'localhost';
CREATE USER 'asesor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'taller_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
CREATE USER 'auditor_flotaya'@'localhost' IDENTIFIED BY 'Practica_2026*';
GRANT rol_asesor_flotaya TO 'asesor_flotaya'@'localhost';
GRANT rol_taller_flotaya TO 'taller_flotaya'@'localhost';
GRANT rol_auditor_flotaya TO 'auditor_flotaya'@'localhost';
SET DEFAULT ROLE rol_asesor_flotaya TO 'asesor_flotaya'@'localhost';
SET DEFAULT ROLE rol_taller_flotaya TO 'taller_flotaya'@'localhost';
SET DEFAULT ROLE rol_auditor_flotaya TO 'auditor_flotaya'@'localhost';

-- Pruebas administrativas: SELECT CURRENT_USER(), CURRENT_ROLE(); SHOW GRANTS;
-- Como asesor: CALL sp_crear_reserva(...); intentar SELECT * FROM payments (ERROR 1142).
-- Como taller: SELECT id,plate,status,mileage_km,branch_id FROM vehicles; UPDATE vehicles SET mileage_km=1 WHERE id=15 (ERROR 1143).
-- Como auditor: SELECT id,contract_id,concept,amount,paid_at FROM payments; SELECT card_last4 FROM payments (ERROR 1143).
-- El asesor no puede leer licencias directamente: el procedimiento con SQL SECURITY DEFINER
-- puede validar con privilegios del definidor y exponer solo el resultado; riesgo: abuso del procedimiento.
-- Error 1142 = privilegio de tabla/operación ausente; 1143 = privilegio de columna ausente.
-- Rol asignado pero no activo: sus privilegios no aplican; activar con SET ROLE rol_...;
