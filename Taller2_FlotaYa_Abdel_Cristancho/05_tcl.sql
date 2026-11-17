USE flotaya;
-- Los dos cierres deben ejecutarse en conexiones de prueba con los registros iniciales.
-- 6.1 Paola: devolución + inspección + SAVEPOINT + daño corregido + cierre + pago.
START TRANSACTION;
SELECT ct.id,ct.status,v.plate,v.status AS estado_vehiculo,d.status AS deposito
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN vehicles v ON v.id=r.vehicle_id
JOIN deposits d ON d.contract_id=ct.id WHERE ct.id=9007;
INSERT INTO returns(contract_id,branch_id,employee_id,returned_at,mileage_km,fuel_pct)
VALUES(9007,2,9,'2026-11-23 09:30:00',12480,100);
INSERT INTO inspections(contract_id,employee_id,stage,inspected_at,exterior_ok,interior_ok,notes)
VALUES(9007,9,'DEVOLUCION','2026-11-23 09:40:00',FALSE,TRUE,'Rin delantero izquierdo rayado');
SET @inspection_paola=LAST_INSERT_ID();
SAVEPOINT antes_dano;
INSERT INTO damages(inspection_id,description,severity,repair_cost,charge_customer)
VALUES(@inspection_paola,'Rin delantero izquierdo rayado','LEVE',3800000,TRUE);
SELECT id,repair_cost FROM damages WHERE inspection_id=@inspection_paola;
ROLLBACK TO SAVEPOINT antes_dano;
INSERT INTO damages(inspection_id,description,severity,repair_cost,charge_customer)
VALUES(@inspection_paola,'Rin delantero izquierdo rayado','LEVE',380000,TRUE);
SET @saldo_paola=0;
CALL sp_cerrar_contrato(9007,'2026-11-23',@saldo_paola);
SELECT @saldo_paola AS saldo_cierre;
INSERT INTO payments(contract_id,concept,amount,payment_method,paid_at,card_last4,authorization_code)
VALUES(9007,'CIERRE',@saldo_paola,'TARJETA','2026-11-23 10:00:00','3307','AUT-580114');
COMMIT;
SELECT ct.id,ct.status,ct.rental_amount,v.status,v.mileage_km,d.status,d.applied_amount
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN vehicles v ON v.id=r.vehicle_id
JOIN deposits d ON d.contract_id=ct.id WHERE ct.id=9007;

-- 6.2 Carlos: la forma de pago CHEQUE debe fallar y provocar rollback total.
START TRANSACTION;
SELECT ct.id,ct.status,v.plate,v.status AS estado_vehiculo,d.status AS deposito
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN vehicles v ON v.id=r.vehicle_id
JOIN deposits d ON d.contract_id=ct.id WHERE ct.id=9006;
INSERT INTO returns(contract_id,branch_id,employee_id,returned_at,mileage_km,fuel_pct)
VALUES(9006,4,10,'2026-11-23 18:00:00',26950,50);
INSERT INTO inspections(contract_id,employee_id,stage,inspected_at,exterior_ok,interior_ok,notes)
VALUES(9006,10,'DEVOLUCION','2026-11-23 18:10:00',TRUE,TRUE,'Sin novedades');
SET @saldo_carlos=0;
CALL sp_cerrar_contrato(9006,'2026-11-23',@saldo_carlos);
SELECT @saldo_carlos AS saldo_cierre;
-- ESPERADO: ERROR por enum payment_method; ejecutar individualmente y luego ROLLBACK.
-- INSERT INTO payments(contract_id,concept,amount,payment_method,paid_at) VALUES(9006,'CIERRE',@saldo_carlos,'CHEQUE','2026-11-23 18:20:00');
ROLLBACK;
SELECT ct.id,ct.status,v.plate,v.status AS estado_vehiculo,d.status AS deposito
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN vehicles v ON v.id=r.vehicle_id
JOIN deposits d ON d.contract_id=ct.id WHERE ct.id=9006;

-- 6.3 Auditoría de consistencia
SELECT
 (SELECT COUNT(*) FROM vehicles v WHERE v.status='ALQUILADO'
  AND NOT EXISTS(SELECT 1 FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id
  WHERE r.vehicle_id=v.id AND ct.status='ABIERTO')) AS alquilados_sin_contrato,
 (SELECT COUNT(*) FROM contracts ct WHERE ct.status='CERRADO'
  AND NOT EXISTS(SELECT 1 FROM returns rt WHERE rt.contract_id=ct.id)) AS cerrados_sin_devolucion,
 (SELECT COUNT(*) FROM deposits d JOIN contracts ct ON ct.id=d.contract_id
  WHERE d.status='RETENIDO' AND ct.status='CERRADO') AS depositos_retenidos_de_cerrados,
 (SELECT COUNT(*) FROM contracts WHERE status='ABIERTO') AS contratos_abiertos,
 (SELECT COUNT(*) FROM payments) AS pagos;
