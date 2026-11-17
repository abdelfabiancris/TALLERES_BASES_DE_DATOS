USE bibliored;
-- R1. Socios con saldo en multas o préstamos vencidos.
SELECT CONCAT(m.first_name,' ',m.last_name) AS socio,m.phone,
 COALESCE(f.saldo_multas,0) AS saldo_multas,
 COALESCE(l.libros_vencidos,0) AS libros_vencidos,l.mora_mas_antigua
FROM members m
LEFT JOIN (
 SELECT x.member_id,SUM(x.saldo) AS saldo_multas FROM (
  SELECT l.member_id,f.id,f.amount-COALESCE(p.pagado,0) AS saldo
  FROM fines f JOIN loans l ON l.id=f.loan_id
  LEFT JOIN (SELECT fine_id,SUM(amount) pagado FROM fine_payments GROUP BY fine_id) p ON p.fine_id=f.id
  WHERE f.status<>'ANULADA'
 ) x GROUP BY x.member_id
) f ON f.member_id=m.id
LEFT JOIN (
 SELECT member_id,COUNT(*) AS libros_vencidos,MAX(DATEDIFF('2026-11-10',due_date)) AS mora_mas_antigua
 FROM loans WHERE status='ACTIVO' AND due_date<'2026-11-10' GROUP BY member_id
) l ON l.member_id=m.id
WHERE COALESCE(f.saldo_multas,0)>0 OR COALESCE(l.libros_vencidos,0)>0
ORDER BY saldo_multas DESC,libros_vencidos DESC;

-- R2. Rotación del catálogo desde 2026-10-01.
SELECT c.name AS categoria,COUNT(DISTINCT t.id) AS titulos,
 COUNT(DISTINCT CASE WHEN cp.status NOT IN('PERDIDO','DADO_DE_BAJA') THEN cp.id END) AS ejemplares_circulacion,
 COUNT(DISTINCT CASE WHEN l.loan_date>='2026-10-01' THEN l.id END) AS prestamos_desde_octubre,
 CAST(COUNT(DISTINCT CASE WHEN l.loan_date>='2026-10-01' THEN l.id END) /
 NULLIF(COUNT(DISTINCT CASE WHEN cp.status NOT IN('PERDIDO','DADO_DE_BAJA') THEN cp.id END),0) AS DECIMAL(12,2)) AS prestamos_por_ejemplar
FROM categories c LEFT JOIN titles t ON t.category_id=c.id
LEFT JOIN copies cp ON cp.title_id=t.id
LEFT JOIN loans l ON l.copy_id=cp.id
GROUP BY c.id,c.name ORDER BY prestamos_desde_octubre DESC,c.name;

-- R3. Procedimiento para vencer reservas con fecha recibida.
DROP PROCEDURE IF EXISTS sp_vencer_reservas;
DELIMITER $$
CREATE PROCEDURE sp_vencer_reservas(IN p_cutoff DATE)
BEGIN
 UPDATE reservations SET status='VENCIDA'
 WHERE status='PENDIENTE' AND expires_at<p_cutoff;
 SELECT ROW_COUNT() AS reservas_vencidas;
END$$
DELIMITER ;
CALL sp_vencer_reservas('2026-11-21');
CALL sp_vencer_reservas('2026-11-21');
