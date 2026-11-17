USE bibliored;

DROP PROCEDURE IF EXISTS sp_resumen_socio;
DELIMITER $$
CREATE PROCEDURE sp_resumen_socio(IN p_member_id BIGINT)
BEGIN
 IF NOT EXISTS (SELECT 1 FROM members WHERE id=p_member_id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio no existe';
 END IF;
 SELECT (SELECT COUNT(*) FROM loans WHERE member_id=p_member_id AND status='ACTIVO') AS prestamos_activos,
 CAST(COALESCE((SELECT SUM(f.amount-COALESCE(x.pagado,0))
  FROM fines f JOIN loans l ON l.id=f.loan_id
  LEFT JOIN (SELECT fine_id,SUM(amount) pagado FROM fine_payments GROUP BY fine_id) x ON x.fine_id=f.id
  WHERE l.member_id=p_member_id AND f.status='PENDIENTE'),0) AS DECIMAL(12,2)) AS saldo_multas;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_prestar_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_prestar_ejemplar(IN p_copy_id BIGINT, IN p_member_id BIGINT, IN p_employee_id BIGINT, IN p_loan_date DATE)
BEGIN
 DECLARE v_member_status VARCHAR(20);
 DECLARE v_copy_status VARCHAR(20);
 DECLARE v_membership_id BIGINT;
 DECLARE v_limit INT;
 DECLARE v_days INT;
 DECLARE v_active INT;
 DECLARE v_fines INT;
 DECLARE v_new_id BIGINT;
 DECLARE v_msg VARCHAR(128);
 IF NOT EXISTS (SELECT 1 FROM members WHERE id=p_member_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio no existe'; END IF;
 SELECT status,membership_id INTO v_member_status,v_membership_id FROM members WHERE id=p_member_id;
 IF v_member_status<>'ACTIVO' THEN
  SET v_msg=CONCAT('El socio no está activo: ',v_member_status);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_msg;
 END IF;
 IF NOT EXISTS (SELECT 1 FROM copies WHERE id=p_copy_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El ejemplar no existe'; END IF;
 SELECT status INTO v_copy_status FROM copies WHERE id=p_copy_id;
 IF v_copy_status<>'DISPONIBLE' THEN
  SET @msg=CONCAT('El ejemplar no está disponible: ',v_copy_status);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=@msg;
 END IF;
 SELECT COUNT(*) INTO v_fines FROM fines f JOIN loans l ON l.id=f.loan_id
 WHERE l.member_id=p_member_id AND f.status='PENDIENTE'
 AND f.amount>(SELECT COALESCE(SUM(fp.amount),0) FROM fine_payments fp WHERE fp.fine_id=f.id);
 IF v_fines>0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El socio tiene multas pendientes'; END IF;
 SELECT loan_limit,loan_days INTO v_limit,v_days FROM memberships WHERE id=v_membership_id;
 SELECT COUNT(*) INTO v_active FROM loans WHERE member_id=p_member_id AND status='ACTIVO';
 IF v_active>=v_limit THEN
  SET v_msg=CONCAT('El socio alcanzó su tope de ',v_limit,' préstamos');
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_msg;
 END IF;
 UPDATE copies SET status='PRESTADO' WHERE id=p_copy_id;
 INSERT INTO loans(copy_id,member_id,employee_id,loan_date,due_date,status)
 VALUES(p_copy_id,p_member_id,p_employee_id,p_loan_date,DATE_ADD(p_loan_date,INTERVAL v_days DAY),'ACTIVO');
 SET v_new_id=LAST_INSERT_ID();
 SELECT v_new_id AS prestamo_creado;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_devolver_ejemplar;
DELIMITER $$
CREATE PROCEDURE sp_devolver_ejemplar(IN p_loan_id BIGINT, IN p_return_date DATE)
BEGIN
 DECLARE v_copy BIGINT;
 DECLARE v_member BIGINT;
 DECLARE v_due DATE;
 DECLARE v_loan_date DATE;
 DECLARE v_daily DECIMAL(10,2);
 DECLARE v_days INT;
 DECLARE v_amount DECIMAL(12,2) DEFAULT 0;
 IF NOT EXISTS (SELECT 1 FROM loans WHERE id=p_loan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no existe'; END IF;
 IF (SELECT status FROM loans WHERE id=p_loan_id)<>'ACTIVO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no está activo'; END IF;
 SELECT copy_id,member_id,due_date,loan_date INTO v_copy,v_member,v_due,v_loan_date FROM loans WHERE id=p_loan_id;
 IF p_return_date<v_loan_date THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La fecha de devolución es anterior al préstamo'; END IF;
 SELECT mb.fine_per_day INTO v_daily FROM members m JOIN memberships mb ON mb.id=m.membership_id WHERE m.id=v_member;
 SET v_days=GREATEST(DATEDIFF(p_return_date,v_due),0);
 IF v_days>0 THEN
  SET v_amount=v_days*v_daily;
  INSERT INTO fines(loan_id,reason,overdue_days,amount,generated_at,status)
  VALUES(p_loan_id,'MORA',v_days,v_amount,p_return_date,'PENDIENTE');
 END IF;
 UPDATE loans SET status='DEVUELTO',returned_at=p_return_date WHERE id=p_loan_id;
 UPDATE copies SET status='DISPONIBLE' WHERE id=v_copy;
 SELECT v_amount AS multa_generada;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_renovar_prestamo;
DELIMITER $$
CREATE PROCEDURE sp_renovar_prestamo(IN p_loan_id BIGINT, IN p_renewal_date DATE)
BEGIN
 DECLARE v_due DATE;
 DECLARE v_member BIGINT;
 DECLARE v_title BIGINT;
 DECLARE v_membership BIGINT;
 DECLARE v_days INT;
 DECLARE v_allowed INT;
 DECLARE v_used INT;
 DECLARE v_new_due DATE;
 DECLARE v_msg VARCHAR(128);
 IF NOT EXISTS (SELECT 1 FROM loans WHERE id=p_loan_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no existe'; END IF;
 IF (SELECT status FROM loans WHERE id=p_loan_id)<>'ACTIVO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo no está activo'; END IF;
 SELECT l.due_date,l.member_id,c.title_id INTO v_due,v_member,v_title
 FROM loans l JOIN copies c ON c.id=l.copy_id WHERE l.id=p_loan_id;
 IF p_renewal_date>v_due THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El préstamo está vencido: primero debe devolverse'; END IF;
 SELECT m.membership_id INTO v_membership FROM members m WHERE m.id=v_member;
 SELECT loan_days,renewals_allowed INTO v_days,v_allowed FROM memberships WHERE id=v_membership;
 SELECT COUNT(*) INTO v_used FROM renewals WHERE loan_id=p_loan_id;
 IF v_used>=v_allowed THEN
  SET v_msg=CONCAT('El préstamo ya usó sus ',v_allowed,' renovaciones');
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=v_msg;
 END IF;
 IF EXISTS(SELECT 1 FROM reservations WHERE title_id=v_title AND status='PENDIENTE') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Hay reservas pendientes para este título';
 END IF;
 SET v_new_due=DATE_ADD(v_due,INTERVAL v_days DAY);
 INSERT INTO renewals(loan_id,renewed_at,previous_due_date,new_due_date) VALUES(p_loan_id,p_renewal_date,v_due,v_new_due);
 UPDATE loans SET due_date=v_new_due WHERE id=p_loan_id;
 SELECT v_new_due AS nuevo_vencimiento;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_reporte_sedes;
DELIMITER $$
CREATE PROCEDURE sp_reporte_sedes(IN p_cutoff DATE)
BEGIN
 DECLARE v_done INT DEFAULT 0;
 DECLARE v_branch_id BIGINT;
 DECLARE v_branch_name VARCHAR(100);
 DECLARE v_total INT;
 DECLARE v_loaned INT;
 DECLARE v_overdue INT;
 DECLARE cur CURSOR FOR SELECT id,name FROM branches ORDER BY id;
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=1;
 DROP TEMPORARY TABLE IF EXISTS tmp_branch_report;
 CREATE TEMPORARY TABLE tmp_branch_report(
  sede VARCHAR(100),ejemplares INT,prestados INT,vencidos INT,ocupacion_pct DECIMAL(6,2)
 );
 OPEN cur;
 branch_loop: LOOP
  FETCH cur INTO v_branch_id,v_branch_name;
  IF v_done=1 THEN LEAVE branch_loop; END IF;
  SELECT COUNT(*) INTO v_total FROM copies
   WHERE branch_id=v_branch_id AND status NOT IN('PERDIDO','DADO_DE_BAJA');
  SELECT COUNT(*) INTO v_loaned FROM copies WHERE branch_id=v_branch_id AND status='PRESTADO';
  SELECT COUNT(*) INTO v_overdue FROM loans l JOIN copies c ON c.id=l.copy_id
   WHERE c.branch_id=v_branch_id AND l.status='ACTIVO' AND l.due_date<p_cutoff;
  INSERT INTO tmp_branch_report VALUES(v_branch_name,v_total,v_loaned,v_overdue,
   IF(v_total=0,0,ROUND(v_loaned*100/v_total,2)));
 END LOOP;
 CLOSE cur;
 SELECT * FROM tmp_branch_report ORDER BY ocupacion_pct DESC,sede;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_pagar_multa;
DELIMITER $$
CREATE PROCEDURE sp_pagar_multa(IN p_fine_id BIGINT, IN p_amount DECIMAL(12,2),
 IN p_method VARCHAR(30), IN p_payment_date DATE)
BEGIN
 DECLARE v_status VARCHAR(20);
 DECLARE v_total DECIMAL(12,2);
 DECLARE v_paid DECIMAL(12,2);
 DECLARE v_balance DECIMAL(12,2);
 DECLARE v_invalid_method INT DEFAULT 0;
 DECLARE CONTINUE HANDLER FOR 1265 SET v_invalid_method=1;
 IF NOT EXISTS(SELECT 1 FROM fines WHERE id=p_fine_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La multa no existe'; END IF;
 SELECT status,amount INTO v_status,v_total FROM fines WHERE id=p_fine_id;
 IF v_status<>'PENDIENTE' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La multa no está pendiente'; END IF;
 SELECT COALESCE(SUM(amount),0) INTO v_paid FROM fine_payments WHERE fine_id=p_fine_id;
 SET v_balance=v_total-v_paid;
 IF p_amount<=0 OR p_amount>v_balance THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El abono debe ser mayor que 0 y no superar el saldo';
 END IF;
 INSERT INTO fine_payments(fine_id,amount,paid_at,payment_method) VALUES(p_fine_id,p_amount,p_payment_date,p_method);
 IF v_invalid_method=1 THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Medio de pago no válido: use EFECTIVO, TARJETA o TRANSFERENCIA';
 END IF;
 IF v_paid+p_amount=v_total THEN UPDATE fines SET status='PAGADA' WHERE id=p_fine_id; END IF;
 SELECT v_balance-p_amount AS saldo_restante;
END$$
DELIMITER ;

-- Pruebas ilustrativas. Ejecutar las pruebas que modifican datos solo una vez.
CALL sp_resumen_socio(5);
-- ESPERADO: ERROR 1644 - socio inexistente.
-- CALL sp_resumen_socio(9999);

-- Préstamo correcto: socio activo sin préstamos ni multas pendientes.
-- CALL sp_prestar_ejemplar(25,14,2,'2026-11-10');
-- ESPERADO: ERROR 1644 - El socio no está activo: SUSPENDIDO.
-- CALL sp_prestar_ejemplar(25,5,2,'2026-11-10');

-- Devolución y renovación: probar con ids que sigan ACTIVO según la consulta previa.
-- SELECT id,copy_id,member_id,due_date,status FROM loans WHERE status='ACTIVO';
-- CALL sp_devolver_ejemplar(1004,'2026-11-10');
-- CALL sp_renovar_prestamo(1018,'2026-11-10');

CALL sp_reporte_sedes('2026-11-10');
-- Pagar la multa pendiente parcialmente (multa 3 tiene abono previo).
-- CALL sp_pagar_multa(3,500,'TARJETA','2026-11-10');
-- ESPERADO: ERROR 1644 - La multa no está pendiente.
-- CALL sp_pagar_multa(1,100,'EFECTIVO','2026-11-10');

SHOW PROCEDURE STATUS WHERE Db='bibliored';
