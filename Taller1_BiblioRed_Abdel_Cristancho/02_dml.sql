USE bibliored;
-- Datos fijos de negocio. Ejecutar sobre la base recién creada.

INSERT INTO branches (name,municipality,address,opened_at) VALUES
('Sede Central Chía','Chía','Calle 10 # 8-20','2012-01-01'),
('Sede Cajicá','Cajicá','Carrera 6 # 4-18','2015-01-01'),
('Sede Zipaquirá','Zipaquirá','Calle 5 # 7-11','2017-01-01'),
('Sede Cota','Cota','Carrera 5 # 12-30','2020-01-01'),
('Sede Tabio','Tabio','Calle 3 # 2-15','2026-10-01');

INSERT INTO memberships (name,loan_limit,loan_days,renewals_allowed,fine_per_day,annual_fee) VALUES
('Básica',2,14,1,500,0),('Estudiante',3,14,2,300,0),('Docente',5,21,2,300,30000),
('Infantil',2,7,1,200,0),('Institucional',10,30,3,1000,250000);

INSERT INTO categories (name) VALUES
('Novela'),('Cuento'),('Poesía'),('Historia'),('Ciencia'),('Infantil'),('Referencia'),('Cómic');

INSERT INTO publishers (name,city) VALUES
('Editorial Horizonte','Bogotá'),('Letras del Norte','Chía'),('Ediciones Sabana','Cajicá'),
('Universo Académico','Bogotá'),('Papel y Tinta','Medellín'),('Editorial Andina','Tunja');

INSERT INTO authors (full_name,nationality,birth_year) VALUES
('Lucía Herrera','Colombiana',1978),('Mateo Rincón','Colombiano',1982),
('Elena Pardo','Colombiana',1969),('Samuel Torres','Colombiano',1990),
('Isabel Cárdenas','Colombiana',1975),('Tomás Gil','Colombiano',1988),
('Valeria Montes','Colombiana',1984),('Nicolás Vega','Colombiano',1972),
('Camila Duarte','Colombiana',1993),('Julián Acosta','Colombiano',1980);

INSERT INTO employees (branch_id,full_name,email,hired_at,role) VALUES
(1,'Patricia Lemus','patricia.lemus@bibliored.test','2012-02-01','COORDINADOR'),
(1,'Andrés Mora','andres.mora@bibliored.test','2018-03-12','BIBLIOTECARIO'),
(2,'Diana Ruiz','diana.ruiz@bibliored.test','2016-05-10','BIBLIOTECARIO'),
(3,'Felipe León','felipe.leon@bibliored.test','2018-02-20','BIBLIOTECARIO'),
(4,'Sara Peña','sara.pena@bibliored.test','2021-01-15','BIBLIOTECARIO'),
(5,'Óscar Niño','oscar.nino@bibliored.test','2026-10-01','AUXILIAR');

INSERT INTO titles (isbn,name,publication_year,category_id,publisher_id,replacement_cost) VALUES
('9780000000001','Cuentos de la Sabana',2018,2,1,52000),
('9780000000002','Átomos para curiosos',2020,5,4,68000),
('9780000000003','La casa del viento',2015,1,2,45000),
('9780000000004','Historia de nuestros pueblos',2012,4,3,60000),
('9780000000005','Versos del camino',2019,3,5,38000),
('9780000000006','Pequeños exploradores',2021,6,1,42000),
('9780000000007','Atlas de Colombia',2010,7,4,90000),
('9780000000008','El río secreto',2017,1,2,50000),
('9780000000009','Ciencia cotidiana',2022,5,4,55000),
('9780000000010','Relatos de montaña',2016,2,3,47000),
('9780000000011','La niña de los mapas',2023,6,5,50000),
('9780000000012','Memorias de la región',2011,4,6,72000),
('9780000000013','Poemas para volver',2020,3,5,50000),
('9780000000014','Manual de lectura',2014,7,1,50000);

-- Sin indicar replacement_cost: debe aplicarse el DEFAULT de $50.000.
INSERT INTO titles (isbn,name,publication_year,category_id,publisher_id)
VALUES ('9780000000015','Cuaderno de observación',2024,5,4);

INSERT INTO title_authors (title_id,author_id,author_order) VALUES
(1,1,1),(1,2,2),(2,3,1),(2,4,2),(3,5,1),(4,6,1),(5,7,1),(6,8,1),
(7,9,1),(8,1,1),(8,10,2),(9,3,1),(10,4,1),(10,5,2),(11,7,1),(12,8,1),(13,9,1),(14,10,1);

-- 25 ejemplares; Tabio no recibe ejemplares. El más antiguo es el de Zipaquirá.
INSERT INTO copies (title_id,branch_id,barcode,acquired_at,status) VALUES
(1,1,'BR-0001','2018-02-01','DISPONIBLE'),
(1,2,'BR-0002','2019-03-01','DISPONIBLE'),
(1,3,'BR-0003','2020-04-01','DISPONIBLE'),
(2,4,'BR-0004','2021-01-01','PERDIDO'),
(2,1,'BR-0005','2022-02-01','DISPONIBLE'),
(3,1,'BR-0006','2015-05-01','DISPONIBLE'),
(3,2,'BR-0007','2016-06-01','DISPONIBLE'),
(4,3,'BR-0008','2011-01-01','DISPONIBLE'),
(4,1,'BR-0009','2017-07-01','DISPONIBLE'),
(5,2,'BR-0010','2019-09-01','DISPONIBLE'),
(5,3,'BR-0011','2020-10-01','EN_REPARACION'),
(6,1,'BR-0012','2021-03-01','DISPONIBLE'),
(6,2,'BR-0013','2022-04-01','DISPONIBLE'),
(7,3,'BR-0014','2012-02-01','DISPONIBLE'),
(7,1,'BR-0015','2013-03-01','DISPONIBLE'),
(8,2,'BR-0016','2017-08-01','DISPONIBLE'),
(8,4,'BR-0017','2018-09-01','DISPONIBLE'),
(9,1,'BR-0018','2022-05-01','DISPONIBLE'),
(9,2,'BR-0019','2023-06-01','DISPONIBLE'),
(10,3,'BR-0020','2016-10-01','DISPONIBLE'),
(10,1,'BR-0021','2017-11-01','DISPONIBLE'),
(11,2,'BR-0022','2023-02-01','DISPONIBLE'),
(12,3,'BR-0023','2012-03-01','DISPONIBLE'),
(13,1,'BR-0024','2020-05-01','EN_REPARACION'),
(13,2,'BR-0025','2015-08-01','DADO_DE_BAJA');

INSERT INTO members (document_number,first_name,last_name,email,phone,birth_date,joined_at,membership_id,branch_id,status) VALUES
('CC1001','Ana','Beltrán','ana.beltran@test.co','3001110001','1990-02-10','2024-01-10',1,1,'ACTIVO'),
('CC1002','Bruno','Salas','bruno.salas@test.co','3001110002','1988-04-12','2024-02-11',2,2,'ACTIVO'),
('CC1003','Carla','Méndez','carla.mendez@test.co','3001110003','1980-06-13','2023-03-12',3,1,'ACTIVO'),
('TI1004','Daniel','Rojas',NULL,NULL,'2017-08-01','2025-01-05',4,5,'ACTIVO'),
('CC1005','Eva','Suárez','eva.suarez@test.co','3001110005','1995-09-09','2024-04-15',1,2,'SUSPENDIDO'),
('CC1006','Fabio','Lara','fabio.lara@test.co','3001110006','1992-10-10','2024-05-16',2,3,'ACTIVO'),
('CC1007','Gina','Cruz','gina.cruz@test.co','3001110007','1985-11-11','2024-06-17',1,4,'ACTIVO'),
('CC1008','Hugo','Díaz','hugo.diaz@test.co','3001110008','1975-12-12','2023-07-18',3,1,'ACTIVO'),
('CC1009','Inés','Vargas','ines.vargas@test.co','3001110009','2000-01-13','2024-08-19',2,2,'ACTIVO'),
('CC1010','Jorge','Paz','jorge.paz@test.co','3001110010','1998-02-14','2024-09-20',1,3,'ACTIVO'),
('TI1011','Karla','León',NULL,NULL,'2016-03-15','2025-02-01',4,1,'ACTIVO'),
('CC1012','Luis','Rey','luis.rey@test.co','3001110012','1987-04-16','2024-10-22',1,4,'ACTIVO'),
('CC1013','Mara','Solís','mara.solis@test.co','3001110013','1991-05-17','2024-11-23',2,5,'INACTIVO'),
('CC1014','Nora','Vidal','nora.vidal@test.co','3001110014','1989-06-18','2025-01-24',1,1,'ACTIVO');

-- 20 préstamos. Los ids se generan desde 1001; los ejemplares prestados quedan sincronizados.
INSERT INTO loans (copy_id,member_id,employee_id,loan_date,due_date,returned_at,status) VALUES
(1,1,2,'2026-09-01','2026-09-15','2026-09-12','DEVUELTO'),
(2,2,3,'2026-09-03','2026-09-17','2026-09-20','DEVUELTO'),
(6,3,2,'2026-09-05','2026-09-26','2026-09-25','DEVUELTO'),
(7,6,3,'2026-09-08','2026-09-22',NULL,'ACTIVO'),
(8,8,4,'2026-09-10','2026-10-01',NULL,'ACTIVO'),
(9,1,2,'2026-09-15','2026-09-29','2026-09-29','DEVUELTO'),
(10,2,3,'2026-09-18','2026-10-02','2026-10-06','DEVUELTO'),
(12,3,2,'2026-09-20','2026-10-11',NULL,'ACTIVO'),
(13,6,3,'2026-09-22','2026-10-06','2026-10-05','DEVUELTO'),
(14,8,4,'2026-09-25','2026-10-16',NULL,'ACTIVO'),
(15,9,2,'2026-10-01','2026-10-15','2026-10-14','DEVUELTO'),
(16,10,3,'2026-10-03','2026-10-17',NULL,'ACTIVO'),
(17,12,5,'2026-10-05','2026-10-19','2026-10-23','DEVUELTO'),
(18,1,2,'2026-10-08','2026-10-22',NULL,'ACTIVO'),
(19,2,3,'2026-10-10','2026-10-24',NULL,'ACTIVO'),
(20,3,4,'2026-10-12','2026-11-02',NULL,'ACTIVO'),
(21,6,2,'2026-10-15','2026-10-29',NULL,'ACTIVO'),
(22,8,3,'2026-10-20','2026-11-10',NULL,'ACTIVO'),
(23,9,4,'2026-10-25','2026-11-10',NULL,'ACTIVO'),
(4,7,5,'2026-10-28','2026-11-11',NULL,'PERDIDO');

-- Ajustes de diseño de datos para cubrir los escenarios D1, D4, D7, D8 y D12.
-- El título 14 queda sin ejemplares y el autor 10 queda sin títulos (D1).
UPDATE copies SET title_id=13 WHERE id=25;
DELETE FROM title_authors WHERE (title_id=8 AND author_id=10) OR (title_id=14 AND author_id=10);
INSERT INTO title_authors (title_id,author_id,author_order) VALUES (14,9,1);

-- El socio suspendido tiene un préstamo histórico y una multa pendiente (D4).
UPDATE loans SET member_id=5 WHERE id=1007;

-- El socio Básico 1 queda en su tope con dos préstamos activos; se construye empate histórico (D7 y D12).
UPDATE loans SET member_id=1 WHERE id=1016;
UPDATE loans SET member_id=2 WHERE id=1003;
UPDATE loans SET member_id=2 WHERE id=1009;

-- El préstamo 1010 consume las dos renovaciones permitidas a su membresía Docente (D8).
UPDATE loans SET due_date='2026-11-27' WHERE id=1010;
INSERT INTO renewals (loan_id,renewed_at,previous_due_date,new_due_date)
VALUES (1010,'2026-11-06','2026-11-06','2026-11-27');

-- Estados físicos coherentes con préstamos activos/perdidos.
UPDATE copies SET status='PRESTADO' WHERE id IN (7,8,12,14,16,18,19,20,21,22,23);
UPDATE copies SET status='PERDIDO' WHERE id=4;

INSERT INTO renewals (loan_id,renewed_at,previous_due_date,new_due_date) VALUES
(1004,'2026-09-20','2026-09-22','2026-10-06'),
(1010,'2026-10-01','2026-10-16','2026-11-06'),
(1012,'2026-10-10','2026-10-17','2026-10-31');

INSERT INTO reservations (member_id,title_id,branch_id,reserved_at,expires_at,status) VALUES
(10,1,2,'2026-11-01','2026-11-05','PENDIENTE'),
(11,3,1,'2026-11-02','2026-11-20','PENDIENTE'),
(5,2,4,'2026-10-20','2026-10-30','VENCIDA'),
(6,4,3,'2026-10-25','2026-11-15','PENDIENTE'),
(7,6,1,'2026-10-26','2026-11-12','CANCELADA'),
(8,8,2,'2026-10-27','2026-11-08','ATENDIDA'),
(14,9,1,'2026-11-03','2026-11-20','PENDIENTE');

INSERT INTO fines (loan_id,reason,overdue_days,amount,generated_at,status) VALUES
(1002,'MORA',3,1500,'2026-09-20','PAGADA'),
(1007,'MORA',4,1200,'2026-10-06','PAGADA'),
(1013,'MORA',4,2000,'2026-10-23','PENDIENTE'),
(1020,'PERDIDA',0,68000,'2026-10-28','PENDIENTE'),
(1009,'DAÑO',0,8000,'2026-10-05','ANULADA'),
(1007,'DAÑO',0,1000,'2026-10-06','PENDIENTE');

INSERT INTO fine_payments (fine_id,amount,paid_at,payment_method) VALUES
(1,1500,'2026-09-21','EFECTIVO'),
(2,500,'2026-10-07','TARJETA'),
(2,700,'2026-10-08','TRANSFERENCIA'),
(3,500,'2026-10-24','EFECTIVO');

-- UPDATE con SELECT previo y comprobación.
SELECT id,barcode,status FROM copies WHERE id=11;
UPDATE copies SET status='DISPONIBLE' WHERE id=11;
SELECT id,barcode,status FROM copies WHERE id=11;

SELECT id,status,expires_at FROM reservations WHERE status='PENDIENTE' AND expires_at<'2026-11-10';
UPDATE reservations SET status='VENCIDA' WHERE id IN (SELECT id FROM (SELECT id FROM reservations WHERE status='PENDIENTE' AND expires_at<'2026-11-10') AS expiradas);
SELECT id,status,expires_at FROM reservations WHERE status='VENCIDA';

SELECT id,name,annual_fee FROM memberships WHERE id=3;
UPDATE memberships SET annual_fee=annual_fee*1.10 WHERE id=3;
SELECT id,name,annual_fee FROM memberships WHERE id=3;

SELECT id,document_number,phone FROM members WHERE id=14;
UPDATE members SET phone='3009990014' WHERE id=14;
SELECT id,document_number,phone FROM members WHERE id=14;

-- DELETE con SELECT previo: reserva cancelada.
SELECT id,status FROM reservations WHERE id=5;
DELETE FROM reservations WHERE id=5 AND status='CANCELADA';
SELECT id,status FROM reservations WHERE id=5;

-- DELETE de editorial sin títulos: la editorial Andina (id 6) no tiene títulos.
SELECT p.id,p.name FROM publishers p LEFT JOIN titles t ON t.publisher_id=p.id WHERE p.id=6;
DELETE FROM publishers WHERE id=6 AND NOT EXISTS (SELECT 1 FROM titles WHERE publisher_id=6);

-- Errores provocados: ejecutar cada sentencia individualmente (Ctrl+Enter).
-- ERROR esperado: duplicidad de código de barras (1062).
-- INSERT INTO copies (title_id,branch_id,barcode,acquired_at) VALUES (1,1,'BR-0001','2026-01-01');
-- ERROR esperado: CHECK amount > 0 (3819).
-- INSERT INTO fine_payments (fine_id,amount,paid_at,payment_method) VALUES (1,0,'2026-11-10','EFECTIVO');
-- ERROR esperado: FK a socio inexistente (1452).
-- INSERT INTO reservations (member_id,title_id,branch_id,reserved_at,expires_at) VALUES (9999,1,1,'2026-11-10','2026-11-11');

-- Verificación de consistencia: cada ejemplar PRESTADO tiene exactamente un préstamo ACTIVO y viceversa.
SELECT c.id,c.barcode,COUNT(l.id) AS prestamos_activos
FROM copies c LEFT JOIN loans l ON l.copy_id=c.id AND l.status='ACTIVO'
WHERE c.status='PRESTADO' GROUP BY c.id,c.barcode;
SELECT COUNT(*) AS prestamos_activos_sin_ejemplar_prestado
FROM loans l JOIN copies c ON c.id=l.copy_id
WHERE l.status='ACTIVO' AND c.status<>'PRESTADO';

-- Conteo final de registros (resultado reproducible tras ejecutar el script completo).
SELECT 'branches' AS tabla,COUNT(*) AS filas FROM branches
UNION ALL SELECT 'memberships',COUNT(*) FROM memberships
UNION ALL SELECT 'categories',COUNT(*) FROM categories
UNION ALL SELECT 'publishers',COUNT(*) FROM publishers
UNION ALL SELECT 'authors',COUNT(*) FROM authors
UNION ALL SELECT 'employees',COUNT(*) FROM employees
UNION ALL SELECT 'titles',COUNT(*) FROM titles
UNION ALL SELECT 'title_authors',COUNT(*) FROM title_authors
UNION ALL SELECT 'copies',COUNT(*) FROM copies
UNION ALL SELECT 'members',COUNT(*) FROM members
UNION ALL SELECT 'loans',COUNT(*) FROM loans
UNION ALL SELECT 'renewals',COUNT(*) FROM renewals
UNION ALL SELECT 'reservations',COUNT(*) FROM reservations
UNION ALL SELECT 'fines',COUNT(*) FROM fines
UNION ALL SELECT 'fine_payments',COUNT(*) FROM fine_payments;

-- D14 en ambos sentidos: ningún ejemplar prestado sin préstamo activo y viceversa.
SELECT c.id,c.barcode FROM copies c
LEFT JOIN loans l ON l.copy_id=c.id AND l.status='ACTIVO'
WHERE c.status='PRESTADO' GROUP BY c.id,c.barcode HAVING COUNT(l.id)<>1;
SELECT l.id FROM loans l JOIN copies c ON c.id=l.copy_id
WHERE l.status='ACTIVO' AND c.status<>'PRESTADO';
