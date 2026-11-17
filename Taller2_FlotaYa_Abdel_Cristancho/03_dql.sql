USE flotaya;
-- Fecha de corte fija: 2026-11-23.
-- Q-01
SELECT status AS estado,COUNT(*) AS vehiculos FROM vehicles GROUP BY status ORDER BY vehiculos DESC,estado;
-- Q-02
SELECT name AS temporada,starts_on AS desde,ends_on AS hasta,DATEDIFF(ends_on,starts_on)+1 AS dias
FROM seasons WHERE season_type='ALTA' ORDER BY starts_on;
-- Q-03
SELECT v.plate,b.name AS marca,m.name AS modelo,c.name AS categoria,br.name AS sede,ci.name AS ciudad
FROM vehicles v JOIN models m ON m.id=v.model_id JOIN brands b ON b.id=m.brand_id
JOIN categories c ON c.id=m.category_id JOIN branches br ON br.id=v.branch_id JOIN cities ci ON ci.id=br.city_id
WHERE v.status='DISPONIBLE'
ORDER BY FIELD(c.name,'Económico','Compacto','SUV','Camioneta 4x4','Van','Lujo'),v.plate;
-- Q-04
SELECT ct.id AS contrato,CONCAT(c.first_name,' ',c.last_name) AS cliente,v.plate,m.name AS modelo,
bp.name AS sede_recogida,ct.expected_end AS fin_esperado,
DATEDIFF(ct.expected_end,'2026-11-23') AS dias_para_devolver,
(SELECT COUNT(*) FROM contract_additional_drivers cad WHERE cad.contract_id=ct.id) AS conductores_adicionales
FROM contracts ct JOIN reservations r ON r.id=ct.reservation_id JOIN customers c ON c.id=r.customer_id
JOIN vehicles v ON v.id=r.vehicle_id
JOIN models m ON m.id=v.model_id JOIN branches bp ON bp.id=r.pickup_branch_id
WHERE ct.status='ABIERTO' ORDER BY dias_para_devolver,ct.id;
-- Q-05: sumar pagos por contrato antes de agrupar para no duplicar contratos.
SELECT b.name AS sede,COUNT(*) AS contratos,SUM(x.total_pagado) AS recaudado
FROM (SELECT contract_id,SUM(amount) total_pagado FROM payments GROUP BY contract_id) x
JOIN contracts ct ON ct.id=x.contract_id JOIN reservations r ON r.id=ct.reservation_id
JOIN branches b ON b.id=r.pickup_branch_id
GROUP BY b.id,b.name HAVING SUM(x.total_pagado)>2000000 ORDER BY recaudado DESC,sede;
-- Q-06
SELECT b.name AS marca,m.name AS modelo FROM models m JOIN brands b ON b.id=m.brand_id
LEFT JOIN vehicles v ON v.model_id=m.id WHERE v.id IS NULL ORDER BY b.name,m.name;
-- Q-07
SELECT c.id,CONCAT(c.first_name,' ',c.last_name) AS cliente FROM customers c
WHERE NOT EXISTS(SELECT 1 FROM licenses l WHERE l.customer_id=c.id AND l.issued_on<='2026-11-23' AND l.expires_on>='2026-11-23')
ORDER BY c.registered_at,c.id;
-- Q-08
SELECT v.plate,m.name AS modelo,b.name AS sede FROM vehicles v
JOIN models m ON m.id=v.model_id JOIN branches b ON b.id=v.branch_id
WHERE v.status='DISPONIBLE'
AND NOT EXISTS(SELECT 1 FROM reservations r WHERE r.vehicle_id=v.id AND r.status IN('PENDIENTE','CONFIRMADA','CONVERTIDA')
AND r.pickup_date<='2026-12-31' AND r.return_date>='2026-12-01')
ORDER BY v.plate;
-- Q-09: promedio por vehículo que ha tenido mantenimiento; costo NULL no suma.
WITH spend AS (SELECT v.id,v.plate,SUM(m.cost) gasto FROM vehicles v
JOIN maintenances m ON m.vehicle_id=v.id GROUP BY v.id,v.plate)
SELECT plate,gasto FROM spend WHERE gasto>(SELECT AVG(gasto) FROM spend) ORDER BY gasto DESC;
SELECT AVG(gasto) AS promedio_por_vehiculo,COUNT(*) AS vehiculos,
SUM(gasto IS NOT NULL) AS con_gasto FROM
(SELECT v.id,SUM(m.cost) gasto FROM vehicles v JOIN maintenances m ON m.vehicle_id=v.id GROUP BY v.id) x;
-- Los mantenimientos en curso cuentan como vehículo que fue al taller, pero su costo NULL no aumenta el gasto.
-- Q-10
WITH ranked AS (SELECT c.name categoria,v.plate,v.mileage_km kilometraje,
DENSE_RANK() OVER(PARTITION BY c.id ORDER BY v.mileage_km DESC) rn
FROM vehicles v JOIN models m ON m.id=v.model_id JOIN categories c ON c.id=m.category_id)
SELECT categoria,plate,kilometraje FROM ranked WHERE rn=1
ORDER BY FIELD(categoria,'Económico','Compacto','SUV','Camioneta 4x4','Van','Lujo');
-- Lujo no aparece porque tiene tarifas, pero aún no tiene modelos ni vehículos.
-- Q-11
SELECT e.name AS extra,COUNT(DISTINCT ce.contract_id) AS contratos,
CAST(COALESCE(SUM(ce.quantity*ce.agreed_daily_price*DATEDIFF(COALESCE(ct.actual_return,ct.expected_end),ct.started_on)),0) AS DECIMAL(12,2)) AS ingresos
FROM extras e LEFT JOIN contract_extras ce ON ce.extra_id=e.id
LEFT JOIN contracts ct ON ct.id=ce.contract_id
GROUP BY e.id,e.name ORDER BY ingresos DESC,e.name;
-- Q-12
SELECT ct.id AS contrato,v.plate,CONCAT(c.first_name,' ',c.last_name) AS cliente,
i.stage AS etapa,d.description AS dano,d.severity AS severidad,d.repair_cost AS costo,
IF(d.charge_customer,'Sí','No') AS se_cobra
FROM damages d JOIN inspections i ON i.id=d.inspection_id JOIN contracts ct ON ct.id=i.contract_id
JOIN reservations r ON r.id=ct.reservation_id JOIN customers c ON c.id=r.customer_id
JOIN vehicles v ON v.id=r.vehicle_id
ORDER BY ct.id,d.id;
