USE flotaya;
-- Catálogos geográficos
INSERT INTO departments(name) VALUES
('Bogotá D.C.'),('Antioquia'),('Bolívar'),('Valle del Cauca'),('Santander'),('Quindío'),('Magdalena');
INSERT INTO cities(department_id,name) VALUES
(1,'Bogotá'),(2,'Medellín'),(2,'Rionegro'),(3,'Cartagena'),(4,'Cali'),(5,'Bucaramanga'),(6,'Armenia');
INSERT INTO branches(city_id,name,address,phone,is_airport) VALUES
(1,'FlotaYa Bogotá Calle 26','Avenida Calle 26 # 69-76','6017001001',FALSE),
(1,'FlotaYa Aeropuerto El Dorado','Avenida El Dorado # 103-09','6017001002',TRUE),
(2,'FlotaYa Medellín El Poblado','Carrera 43A # 7-50','6047001003',FALSE),
(3,'FlotaYa Aeropuerto José María Córdova','Vía Aeropuerto JMC km 1','6047001004',TRUE),
(4,'FlotaYa Cartagena Bocagrande','Carrera 2 # 8-120','6057001005',FALSE),
(5,'FlotaYa Cali Granada','Avenida 9N # 15-20','6027001006',FALSE);
INSERT INTO categories(name,min_driver_age,deposit_amount) VALUES
('Económico',21,1500000),('Compacto',21,1500000),('SUV',23,2500000),
('Camioneta 4x4',25,3000000),('Van',25,3000000),('Lujo',30,5000000);
INSERT INTO seasonal_rates(category_id,season_type,daily_rate) VALUES
(1,'BAJA',120000),(1,'MEDIA',140000),(1,'ALTA',180000),
(2,'BAJA',150000),(2,'MEDIA',175000),(2,'ALTA',220000),
(3,'BAJA',230000),(3,'MEDIA',270000),(3,'ALTA',340000),
(4,'BAJA',300000),(4,'MEDIA',350000),(4,'ALTA',430000),
(5,'BAJA',320000),(5,'MEDIA',370000),(5,'ALTA',460000),
(6,'BAJA',450000),(6,'MEDIA',520000),(6,'ALTA',650000);
INSERT INTO seasons(name,season_type,starts_on,ends_on) VALUES
('Fin de año 2025','ALTA','2025-12-15','2026-01-15'),
('Baja de inicio de año','BAJA','2026-01-16','2026-03-28'),
('Semana Santa','ALTA','2026-03-29','2026-04-05'),
('Baja de abril a junio','BAJA','2026-04-06','2026-06-12'),
('Vacaciones de mitad de año','ALTA','2026-06-13','2026-07-19'),
('Baja de segundo semestre','BAJA','2026-07-20','2026-10-02'),
('Receso escolar de octubre','MEDIA','2026-10-03','2026-10-12'),
('Baja de noviembre','BAJA','2026-10-13','2026-11-30'),
('Temporada de novenas','MEDIA','2026-12-01','2026-12-14'),
('Fin de año 2026','ALTA','2026-12-15','2027-01-15');
INSERT INTO brands(name) VALUES ('Renault'),('Kia'),('Chevrolet'),('Mazda'),('Toyota'),('Hyundai'),('Nissan');
INSERT INTO models(brand_id,category_id,name,transmission,fuel,seats) VALUES
(1,1,'Kwid','MECANICA','GASOLINA',5),(2,1,'Picanto','AUTOMATICA','GASOLINA',5),
(3,2,'Onix','AUTOMATICA','GASOLINA',5),(4,2,'Mazda 2','AUTOMATICA','GASOLINA',5),
(1,3,'Duster','MECANICA','GASOLINA',5),(2,3,'Sportage','AUTOMATICA','HIBRIDO',5),
(5,4,'Hilux','MECANICA','DIESEL',5),(6,5,'Staria','AUTOMATICA','DIESEL',11),
(4,3,'CX-30','AUTOMATICA','GASOLINA',5);
INSERT INTO workshops(name,city_id) VALUES
('Taller FlotaYa Bogotá',1),('Diésel del Valle',5),('Latonería Caribe',4),('Mecánica Andina',2);
INSERT INTO employees(branch_id,full_name,email,hired_at,role) VALUES
(1,'Mónica Gaitán','monica.gaitan@flotaya.example.com','2018-01-10','ADMINISTRADOR'),
(1,'Gustavo Pérez','gustavo.perez@flotaya.example.com','2019-02-11','MECANICO'),
(1,'Laura Ríos','laura.rios@flotaya.example.com','2020-03-12','ASESOR'),
(2,'Camilo Díaz','camilo.diaz@flotaya.example.com','2021-04-13','ASESOR'),
(3,'Natalia Gil','natalia.gil@flotaya.example.com','2020-05-14','ASESOR'),
(4,'Pedro León','pedro.leon@flotaya.example.com','2021-06-15','ASESOR'),
(5,'María Sol','maria.sol@flotaya.example.com','2022-07-16','ASESOR'),
(6,'Juan Rey','juan.rey@flotaya.example.com','2022-08-17','ASESOR'),
(1,'Elena Cruz','elena.cruz@flotaya.example.com','2019-09-18','INSPECTOR'),
(4,'David Mora','david.mora@flotaya.example.com','2020-10-19','INSPECTOR');
INSERT INTO vehicles(model_id,branch_id,plate,model_year,color,mileage_km,status) VALUES
(1,1,'KWD101',2024,'Blanco',18950,'DISPONIBLE'),
(1,2,'KWD102',2024,'Gris',22100,'DISPONIBLE'),
(1,6,'KWD103',2021,'Blanco',98400,'FUERA_DE_SERVICIO'),
(2,2,'PCN201',2025,'Rojo',10450,'DISPONIBLE'),
(2,3,'PCN202',2025,'Blanco',12400,'DISPONIBLE'),
(3,2,'ONX301',2024,'Plata',30500,'ALQUILADO'),
(3,5,'ONX302',2023,'Negro',41890,'MANTENIMIENTO'),
(4,4,'MZD401',2025,'Azul',9310,'DISPONIBLE'),
(4,4,'MZD402',2024,'Rojo',26300,'ALQUILADO'),
(5,1,'DST501',2023,'Blanco',48620,'DISPONIBLE'),
(5,6,'DST502',2024,'Gris',22710,'DISPONIBLE'),
(6,2,'SPT601',2025,'Negro',11500,'ALQUILADO'),
(6,4,'SPT602',2025,'Blanco',9600,'DISPONIBLE'),
(7,3,'HLX701',2023,'Plata',64380,'DISPONIBLE'),
(7,6,'HLX702',2022,'Blanco',88100,'MANTENIMIENTO'),
(8,2,'STR801',2024,'Gris',35700,'DISPONIBLE'),
(8,5,'STR802',2025,'Blanco',15480,'DISPONIBLE');
INSERT INTO maintenances(vehicle_id,workshop_id,maintenance_type,description,started_on,ended_on,cost) VALUES
(3,1,'CORRECTIVO','Diagnóstico de motor; pérdida total','2026-09-01','2026-09-10',850000),
(7,3,'LATONERIA','Reparación de latonería','2026-10-26',NULL,NULL),
(15,2,'CORRECTIVO','Cambio de embrague','2026-11-16',NULL,NULL),
(1,1,'PREVENTIVO','Cambio de aceite','2026-08-10','2026-08-10',180000),
(9,4,'PREVENTIVO','Alineación y balanceo','2026-09-20','2026-09-20',120000),
(12,1,'PREVENTIVO','Revisión de frenos','2026-10-01','2026-10-02',240000);
INSERT INTO customers(city_id,document_type,document_number,first_name,last_name,email,phone,birth_date,registered_at,status) VALUES
(1,'CC','CC100001','Andrea','Salazar','andrea.salazar@flotaya.example.com','3100000001','1990-04-12','2025-01-10','ACTIVO'),
(2,'CC','CC100002','Carlos','Mejía','carlos.mejia@flotaya.example.com','3100000002','1985-09-30','2025-01-11','ACTIVO'),
(1,'CC','CC100003','Juliana','Patiño','juliana.patino@flotaya.example.com','3100000003','2004-07-15','2025-01-12','ACTIVO'),
(4,'CE','CE100004','Lucas','Ferreira','lucas.ferreira@flotaya.example.com','3100000004','1979-02-02','2025-01-13','ACTIVO'),
(5,'CC','CC100005','Diana','Rozo','diana.rozo@flotaya.example.com','3100000005','1993-11-25','2025-01-14','ACTIVO'),
(4,'PASAPORTE','PA100006','Emma','Walker','emma.walker@flotaya.example.com','3100000006','1988-06-18','2025-01-15','ACTIVO'),
(2,'CC','CC100007','Jorge','Arango','jorge.arango@flotaya.example.com','3100000007','1975-01-09','2025-01-16','ACTIVO'),
(1,'CC','CC100008','Paola','Quintero','paola.quintero@flotaya.example.com','3100000008','1999-12-03','2025-01-17','ACTIVO'),
(6,'CC','CC100009','Esteban','Rueda','esteban.rueda@flotaya.example.com','3100000009','2002-05-21','2025-01-18','ACTIVO'),
(1,'CC','CC100010','Martha','Cifuentes','martha.cifuentes@flotaya.example.com','3100000010','1968-03-14','2025-01-19','BLOQUEADO'),
(5,'CC','CC100011','Kevin','Morales','kevin.morales@flotaya.example.com','3100000011','2005-10-02','2025-01-20','ACTIVO'),
(2,'CC','CC100012','Laura','Benítez','laura.benitez@flotaya.example.com',NULL,'1996-08-08','2025-01-21','ACTIVO'),
(1,'CC','CC100013','Ricardo','Lozano','ricardo.lozano@flotaya.example.com','3100000013','1982-12-24','2025-01-22','ACTIVO'),
(3,'CC','CC100014','Sofía','Herrera','sofia.herrera@flotaya.example.com','3100000014','2001-01-30','2025-01-23','ACTIVO');
INSERT INTO licenses(customer_id,license_number,category,issued_on,expires_on,issuing_country) VALUES
(1,'LIC10001','B1','2010-05-10','2028-05-10','Colombia'),
(2,'LIC10002','B1','2005-02-20','2027-02-20','Colombia'),
(3,'LIC10003','B1','2022-08-01','2032-08-01','Colombia'),
(4,'LIC10004','B1','2010-01-01','2026-12-31','Brasil'),
(5,'LIC10005','B1','2013-11-30','2029-11-30','Colombia'),
(6,'LIC10006','B1','2008-06-01','2031-06-01','Canadá'),
(7,'LIC10007A','C1','2000-01-15','2010-01-15','Colombia'),
(7,'LIC10007B','C1','2010-01-15','2030-01-15','Colombia'),
(8,'LIC10008','B1','2016-12-10','2026-12-10','Colombia'),
(9,'LIC10009','B1','2020-08-01','2026-08-01','Colombia'),
(10,'LIC10010','B1','2008-04-04','2028-04-04','Colombia'),
(11,'LIC10011','B1','2023-10-10','2033-10-10','Colombia'),
(13,'LIC10013','B1','2010-12-24','2027-12-24','Colombia'),
(14,'LIC10014','B1','2020-02-01','2029-02-01','Colombia');
INSERT INTO additional_drivers(document_number,full_name,birth_date,license_number,license_expires_on) VALUES
('AD1001','Felipe Salazar','1988-03-03','ADLIC1001','2029-03-03'),
('AD1002','Mónica Arango','1977-07-07','ADLIC1002','2028-07-07'),
('AD1003','Tomás Ferreira','2006-03-03','ADLIC1003','2030-03-03'),
('AD1004','Natalia Rozo','1995-05-05','ADLIC1004','2026-09-30');
INSERT INTO extras(name,list_daily_price) VALUES
('GPS',15000),('Silla de bebé',12000),('Seguro total',45000),
('Conductor adicional',20000),('Wi-Fi portátil',10000),('Portabicicletas',18000);
-- Reservas y contratos. IDs de reserva desde 501 y contratos desde 9001.
INSERT INTO reservations(customer_id,vehicle_id,pickup_branch_id,return_branch_id,pickup_date,return_date,quoted_amount,status) VALUES
(3,1,1,1,'2026-11-27','2026-12-02',620000,'CONFIRMADA'),
(5,16,2,2,'2026-12-18','2026-12-23',2300000,'CONFIRMADA'),
(11,5,3,3,'2026-12-10','2026-12-17',980000,'PENDIENTE'),
(14,13,4,4,'2026-12-05','2026-12-09',1080000,'PENDIENTE'),
(8,2,2,2,'2026-12-08','2026-12-12',720000,'PENDIENTE'),
(2,1,1,1,'2026-11-30','2026-12-04',520000,'CANCELADA'),
(10,2,2,2,'2026-12-01','2026-12-03',240000,'CANCELADA'),
(4,17,5,5,'2026-10-01','2026-10-06',1600000,'CONVERTIDA'),
(7,14,3,3,'2026-10-15','2026-10-20',1500000,'CONVERTIDA'),
(6,7,5,5,'2026-10-20','2026-10-24',600000,'CONVERTIDA'),
(5,11,6,6,'2026-10-08','2026-10-12',920000,'CONVERTIDA'),
(1,6,1,1,'2026-09-10','2026-09-14',600000,'CONVERTIDA'),
(2,9,4,4,'2026-11-18','2026-11-25',1050000,'CONVERTIDA'),
(8,12,2,2,'2026-11-15','2026-11-22',1610000,'CONVERTIDA'),
(13,6,2,1,'2026-11-17','2026-11-21',600000,'CONVERTIDA');
INSERT INTO contracts(reservation_id,employee_id,started_on,expected_end,actual_return,rental_amount,status) VALUES
(508,7,'2026-10-01','2026-10-06','2026-10-06',1600000,'CERRADO'),
(509,5,'2026-10-15','2026-10-20','2026-10-20',1500000,'CERRADO'),
(510,7,'2026-10-20','2026-10-24','2026-10-24',600000,'CERRADO'),
(511,8,'2026-10-08','2026-10-12','2026-10-13',920000,'CERRADO'),
(512,3,'2026-09-10','2026-09-14','2026-09-14',600000,'CERRADO'),
(513,4,'2026-11-18','2026-11-25',NULL,1050000,'ABIERTO'),
(514,4,'2026-11-15','2026-11-22',NULL,1610000,'ABIERTO'),
(515,3,'2026-11-17','2026-11-21',NULL,600000,'ABIERTO');
UPDATE reservations SET status='CONVERTIDA' WHERE id IN (508,509,510,511,512,513,514,515);
INSERT INTO contract_extras(contract_id,extra_id,quantity,agreed_daily_price) VALUES
(9001,1,1,15000),(9002,4,1,20000),(9003,1,1,15000),
(9006,4,1,20000),(9006,2,2,12000),(9007,3,1,45000),(9007,4,1,20000),(9008,1,1,15000);
INSERT INTO contract_additional_drivers(contract_id,additional_driver_id) VALUES
(9001,3),(9002,4),(9007,1),(9006,2);
INSERT INTO deliveries(contract_id,branch_id,employee_id,delivered_at,mileage_km,fuel_pct) VALUES
(9001,5,10,'2026-10-01 09:00:00',15400,100),
(9002,3,9,'2026-10-15 09:00:00',64000,100),
(9003,5,10,'2026-10-20 09:00:00',41890,100),
(9004,6,9,'2026-10-08 09:00:00',22000,100),
(9005,1,9,'2026-09-10 09:00:00',30000,100),
(9006,4,9,'2026-11-18 09:00:00',26300,100),
(9007,2,9,'2026-11-15 09:00:00',11000,100),
(9008,2,9,'2026-11-17 09:00:00',30000,100);
INSERT INTO inspections(contract_id,employee_id,stage,inspected_at,exterior_ok,interior_ok,notes) VALUES
(9001,10,'ENTREGA','2026-10-01 08:50:00',FALSE,TRUE,'Rayón previo en bómper trasero'),
(9001,10,'DEVOLUCION','2026-10-06 10:00:00',TRUE,TRUE,'Sin novedades'),
(9002,9,'ENTREGA','2026-10-15 08:50:00',TRUE,TRUE,'Sin novedades'),
(9002,9,'DEVOLUCION','2026-10-20 10:00:00',FALSE,TRUE,'Rayón puerta conductor'),
(9003,10,'ENTREGA','2026-10-20 08:50:00',TRUE,TRUE,'Sin novedades'),
(9003,10,'DEVOLUCION','2026-10-24 10:00:00',FALSE,TRUE,'Golpe puerta trasera derecha'),
(9004,9,'ENTREGA','2026-10-08 08:50:00',TRUE,TRUE,'Sin novedades'),
(9004,9,'DEVOLUCION','2026-10-13 10:00:00',TRUE,TRUE,'Sin novedades'),
(9005,9,'ENTREGA','2026-09-10 08:50:00',TRUE,TRUE,'Sin novedades');
INSERT INTO damages(inspection_id,description,severity,repair_cost,charge_customer) VALUES
(1,'Rayón previo en bómper trasero','LEVE',180000,FALSE),
(4,'Rayón en puerta del conductor','LEVE',350000,TRUE),
(6,'Golpe en puerta trasera derecha','GRAVE',2400000,TRUE);
INSERT INTO deposits(contract_id,amount,held_at,applied_amount,status) VALUES
(9001,3000000,'2026-10-01 09:00:00',0,'LIBERADO'),
(9002,3000000,'2026-10-15 09:00:00',350000,'APLICADO'),
(9003,1500000,'2026-10-20 09:00:00',1500000,'APLICADO'),
(9004,2500000,'2026-10-08 09:00:00',0,'LIBERADO'),
(9005,1500000,'2026-09-10 09:00:00',0,'LIBERADO'),
(9006,1500000,'2026-11-18 09:00:00',0,'RETENIDO'),
(9007,2500000,'2026-11-15 09:00:00',0,'RETENIDO'),
(9008,1500000,'2026-11-17 09:00:00',0,'RETENIDO');
INSERT INTO payments(contract_id,concept,amount,payment_method,paid_at,card_last4,authorization_code) VALUES
(9001,'ALQUILER',1600000,'TARJETA','2026-10-06 10:30:00','1122','AUT1001'),
(9002,'ALQUILER',1500000,'TARJETA','2026-10-20 10:30:00','2233','AUT1002'),
(9002,'DAÑOS',350000,'DEPOSITO','2026-10-20 10:31:00',NULL,NULL),
(9003,'ALQUILER',600000,'TARJETA','2026-10-24 10:30:00','3344','AUT1003'),
(9003,'EXTRAS',240000,'TARJETA','2026-10-24 10:31:00','3344','AUT1004'),
(9003,'DAÑOS',1500000,'DEPOSITO','2026-10-24 10:32:00',NULL,NULL),
(9004,'ALQUILER',920000,'EFECTIVO','2026-10-13 10:30:00',NULL,NULL),
(9005,'ALQUILER',600000,'TRANSFERENCIA','2026-09-14 10:30:00',NULL,NULL),
(9007,'ALQUILER',1610000,'TARJETA','2026-11-15 09:10:00','4455','AUT1007'),
(9008,'ALQUILER',600000,'TARJETA','2026-11-17 09:10:00','5566','AUT1008');
-- Conteo esperado aproximado de semillas (verificar con SELECT COUNT por tabla).
SELECT 'vehicles' tabla,COUNT(*) filas FROM vehicles
UNION ALL SELECT 'customers',COUNT(*) FROM customers
UNION ALL SELECT 'licenses',COUNT(*) FROM licenses
UNION ALL SELECT 'reservations',COUNT(*) FROM reservations
UNION ALL SELECT 'contracts',COUNT(*) FROM contracts
UNION ALL SELECT 'payments',COUNT(*) FROM payments;
