USE flotaya;
-- R1 Cotización que no coincide con temporadas. Reservas creadas por sp_crear_reserva
-- no deberían aparecer porque la función calcula el mismo importe que se almacena.
SELECT r.id AS reserva,CONCAT(c.first_name,' ',c.last_name) AS cliente,cat.name AS categoria,
r.pickup_date AS inicio,r.return_date AS fin,r.quoted_amount AS cotizado,
fn_valor_alquiler(cat.id,r.pickup_date,r.return_date) AS segun_temporada,
r.quoted_amount-fn_valor_alquiler(cat.id,r.pickup_date,r.return_date) AS diferencia
FROM reservations r JOIN customers c ON c.id=r.customer_id JOIN vehicles v ON v.id=r.vehicle_id
JOIN models m ON m.id=v.model_id JOIN categories cat ON cat.id=m.category_id
WHERE ABS(r.quoted_amount-fn_valor_alquiler(cat.id,r.pickup_date,r.return_date))>0
ORDER BY diferencia DESC;
-- R2 Saldo de contratos cerrados; agregados independientes para evitar multiplicación de filas.
WITH ex AS (SELECT ce.contract_id,SUM(ce.quantity*ce.agreed_daily_price*DATEDIFF(ct.actual_return,ct.started_on)) extras
FROM contract_extras ce JOIN contracts ct ON ct.id=ce.contract_id GROUP BY ce.contract_id),
da AS (SELECT ct.id contract_id,SUM(d.repair_cost) danos FROM contracts ct
JOIN inspections i ON i.contract_id=ct.id AND i.stage='DEVOLUCION'
JOIN damages d ON d.inspection_id=i.id AND d.charge_customer=TRUE GROUP BY ct.id),
pa AS (SELECT contract_id,SUM(amount) pagado FROM payments GROUP BY contract_id)
SELECT ct.id contrato,CONCAT(c.first_name,' ',c.last_name) cliente,ct.rental_amount alquiler,
COALESCE(ex.extras,0) extras,COALESCE(da.danos,0) danos,COALESCE(pa.pagado,0) pagado,
ct.rental_amount+COALESCE(ex.extras,0)+COALESCE(da.danos,0)-COALESCE(pa.pagado,0) saldo
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN customers c ON c.id=r.customer_id
LEFT JOIN ex ON ex.contract_id=ct.id LEFT JOIN da ON da.contract_id=ct.id LEFT JOIN pa ON pa.contract_id=ct.id
WHERE ct.status='CERRADO' AND ct.rental_amount+COALESCE(ex.extras,0)+COALESCE(da.danos,0)-COALESCE(pa.pagado,0)>0
ORDER BY saldo DESC;
-- R3 Conductores titulares y adicionales (la licencia adicional se valida por su vencimiento).
SELECT ct.id contrato,CONCAT(c.first_name,' ',c.last_name) conductor,'TITULAR' rol,cat.name categoria,
fn_edad_conductor(c.birth_date,ct.started_on) edad,cat.min_driver_age edad_minima,
IF(fn_licencia_vigente(c.id,COALESCE(ct.actual_return,ct.expected_end)),'Sí','No') licencia_vigente
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN customers c ON c.id=r.customer_id
JOIN vehicles v ON v.id=r.vehicle_id JOIN models m ON m.id=v.model_id JOIN categories cat ON cat.id=m.category_id
UNION ALL
SELECT ct.id,ad.full_name,'ADICIONAL',cat.name,fn_edad_conductor(ad.birth_date,ct.started_on),cat.min_driver_age,
IF(ad.license_expires_on>=COALESCE(ct.actual_return,ct.expected_end),'Sí','No')
FROM contracts ct JOIN contract_additional_drivers cad ON cad.contract_id=ct.id
JOIN additional_drivers ad ON ad.id=cad.additional_driver_id JOIN reservations r ON r.id=ct.reservation_id
JOIN vehicles v ON v.id=r.vehicle_id JOIN models m ON m.id=v.model_id JOIN categories cat ON cat.id=m.category_id
ORDER BY contrato,conductor;
