USE bibliored;
-- Fecha de corte fija: 2026-11-10.

-- Q-01
SELECT m.id, CONCAT(m.first_name,' ',m.last_name) AS socio, m.status AS estado, COALESCE(m.phone,'') AS telefono
FROM members m
WHERE m.phone IS NULL OR m.status<>'ACTIVO'
ORDER BY m.id;

-- Q-02
SELECT l.id AS prestamo, CONCAT(m.first_name,' ',m.last_name) AS socio, mb.name AS membresia,
 t.name AS titulo, c.barcode AS ejemplar, b.name AS sede, l.due_date AS vence,
 DATEDIFF('2026-11-10',l.due_date) AS dias_mora,
 CAST(DATEDIFF('2026-11-10',l.due_date)*mb.fine_per_day AS DECIMAL(12,2)) AS multa_estimada
FROM loans l JOIN members m ON m.id=l.member_id
JOIN memberships mb ON mb.id=m.membership_id
JOIN copies c ON c.id=l.copy_id JOIN titles t ON t.id=c.title_id
JOIN branches b ON b.id=c.branch_id
WHERE l.status='ACTIVO' AND l.due_date<'2026-11-10'
ORDER BY dias_mora DESC,l.id;

-- Q-03
SELECT t.name AS titulo, COUNT(ta.author_id) AS autores
FROM titles t JOIN title_authors ta ON ta.title_id=t.id
GROUP BY t.id,t.name HAVING COUNT(ta.author_id)>1 ORDER BY t.id;

-- Q-04
SELECT b.name AS sede, COUNT(l.id) AS prestamos_totales,
 SUM(CASE WHEN l.status='ACTIVO' THEN 1 ELSE 0 END) AS prestamos_activos,
 COUNT(DISTINCT l.member_id) AS socios_distintos
FROM branches b JOIN copies c ON c.branch_id=b.id
JOIN loans l ON l.copy_id=c.id
GROUP BY b.id,b.name HAVING COUNT(l.id)>=5
ORDER BY prestamos_totales DESC,b.name;

-- Q-05
SELECT m.id, CONCAT(m.first_name,' ',m.last_name) AS socio, m.joined_at AS afiliado_desde
FROM members m LEFT JOIN loans l ON l.member_id=m.id
WHERE l.id IS NULL ORDER BY m.id;

-- Q-06
SELECT 'categoria' AS tipo,c.name AS nombre
FROM categories c LEFT JOIN titles t ON t.category_id=c.id
WHERE t.id IS NULL
UNION ALL
SELECT 'autor',a.full_name
FROM authors a LEFT JOIN title_authors ta ON ta.author_id=a.id
WHERE ta.id IS NULL;

-- Q-07
SELECT DISTINCT m.id, CONCAT(m.first_name,' ',m.last_name) AS socio,m.status AS estado
FROM members m JOIN loans l ON l.member_id=m.id
JOIN fines f ON f.loan_id=l.id
WHERE f.status='PENDIENTE' ORDER BY m.id;

-- Q-08
SELECT r.id AS reserva, CONCAT(m.first_name,' ',m.last_name) AS socio,
 t.name AS titulo,b.name AS sede,r.expires_at AS expira
FROM reservations r JOIN members m ON m.id=r.member_id
JOIN titles t ON t.id=r.title_id JOIN branches b ON b.id=r.branch_id
WHERE r.status='PENDIENTE'
AND NOT EXISTS (SELECT 1 FROM copies c WHERE c.title_id=r.title_id AND c.branch_id=r.branch_id AND c.status='DISPONIBLE')
ORDER BY r.id;

-- Q-09
SELECT name AS titulo,replacement_cost AS costo_reposicion
FROM titles WHERE replacement_cost>(SELECT AVG(replacement_cost) FROM titles)
ORDER BY replacement_cost DESC,name;

-- Q-10: incluye todos los empates en el máximo.
SELECT m.id,CONCAT(m.first_name,' ',m.last_name) AS socio,COUNT(l.id) AS prestamos
FROM members m JOIN loans l ON l.member_id=m.id
GROUP BY m.id,m.first_name,m.last_name
HAVING COUNT(l.id)=(SELECT MAX(x.cantidad) FROM
 (SELECT COUNT(*) AS cantidad FROM loans GROUP BY member_id) x)
ORDER BY m.id;

-- Q-11
SELECT b.name AS sede,c.barcode AS ejemplar,t.name AS titulo,c.acquired_at AS adquirido
FROM branches b JOIN copies c ON c.branch_id=b.id JOIN titles t ON t.id=c.title_id
WHERE c.acquired_at=(SELECT MIN(c2.acquired_at) FROM copies c2 WHERE c2.branch_id=b.id)
ORDER BY b.id,c.barcode;

-- Q-12: suma pagos por multa antes de agrupar por socio para evitar duplicar importes.
SELECT m.id,CONCAT(m.first_name,' ',m.last_name) AS socio,
 CAST(SUM(f.amount) AS DECIMAL(12,2)) AS total_multas,
 CAST(SUM(COALESCE(fp.pagado,0)) AS DECIMAL(12,2)) AS pagado,
 CAST(SUM(f.amount-COALESCE(fp.pagado,0)) AS DECIMAL(12,2)) AS saldo
FROM members m JOIN loans l ON l.member_id=m.id
JOIN fines f ON f.loan_id=l.id
LEFT JOIN (SELECT fine_id,SUM(amount) AS pagado FROM fine_payments GROUP BY fine_id) fp ON fp.fine_id=f.id
WHERE f.status<>'ANULADA'
GROUP BY m.id,m.first_name,m.last_name
HAVING saldo>0
ORDER BY saldo DESC,m.id;
