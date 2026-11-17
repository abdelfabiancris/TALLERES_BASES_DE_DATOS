-- Taller 2 FlotaYa | Abdel Cristancho
-- Reglas entre filas/tablas se implementan en fase 5: temporadas sin huecos/cruces,
-- reservas sin solapamiento y elegibilidad del cliente, coherencia de estados,
-- cálculo de tarifas y cierre integral del contrato.
DROP DATABASE IF EXISTS flotaya;
CREATE DATABASE flotaya;
USE flotaya;

CREATE TABLE departments (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE cities (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 department_id BIGINT NOT NULL,
 name VARCHAR(100) NOT NULL,
 FOREIGN KEY (department_id) REFERENCES departments(id),
 UNIQUE (department_id,name)
);
CREATE TABLE branches (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 city_id BIGINT NOT NULL,
 name VARCHAR(120) NOT NULL UNIQUE,
 address VARCHAR(180) NOT NULL,
 phone VARCHAR(20),
 is_airport BOOLEAN NOT NULL DEFAULT FALSE,
 FOREIGN KEY (city_id) REFERENCES cities(id)
);
CREATE TABLE employees (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 branch_id BIGINT NOT NULL,
 full_name VARCHAR(120) NOT NULL,
 email VARCHAR(140) NOT NULL UNIQUE,
 hired_at DATE NOT NULL,
 role ENUM('ADMINISTRADOR','ASESOR','INSPECTOR','MECANICO') NOT NULL,
 FOREIGN KEY (branch_id) REFERENCES branches(id)
);
CREATE TABLE categories (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(60) NOT NULL UNIQUE,
 min_driver_age INT NOT NULL,
 deposit_amount DECIMAL(12,2) NOT NULL,
 CHECK (min_driver_age>=18),
 CHECK (deposit_amount>0)
);
CREATE TABLE brands (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(80) NOT NULL UNIQUE
);
CREATE TABLE models (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 brand_id BIGINT NOT NULL,
 category_id BIGINT NOT NULL,
 name VARCHAR(80) NOT NULL,
 transmission ENUM('MECANICA','AUTOMATICA') NOT NULL,
 fuel ENUM('GASOLINA','DIESEL','HIBRIDO','ELECTRICO') NOT NULL,
 seats INT NOT NULL,
 FOREIGN KEY (brand_id) REFERENCES brands(id),
 FOREIGN KEY (category_id) REFERENCES categories(id),
 UNIQUE (brand_id,name),
 CHECK (seats>0)
);
CREATE TABLE vehicles (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 model_id BIGINT NOT NULL,
 branch_id BIGINT NOT NULL,
 plate VARCHAR(12) NOT NULL UNIQUE,
 model_year INT NOT NULL,
 color VARCHAR(40) NOT NULL,
 mileage_km INT NOT NULL,
 status ENUM('DISPONIBLE','ALQUILADO','MANTENIMIENTO','FUERA_DE_SERVICIO') NOT NULL DEFAULT 'DISPONIBLE',
 FOREIGN KEY (model_id) REFERENCES models(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id),
 CHECK (mileage_km>=0)
);
CREATE TABLE seasons (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE,
 season_type ENUM('BAJA','MEDIA','ALTA') NOT NULL,
 starts_on DATE NOT NULL,
 ends_on DATE NOT NULL,
 CHECK (ends_on>=starts_on)
);
CREATE TABLE seasonal_rates (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 category_id BIGINT NOT NULL,
 season_type ENUM('BAJA','MEDIA','ALTA') NOT NULL,
 daily_rate DECIMAL(12,2) NOT NULL,
 FOREIGN KEY (category_id) REFERENCES categories(id),
 UNIQUE (category_id,season_type),
 CHECK (daily_rate>0)
);
CREATE TABLE workshops (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(120) NOT NULL UNIQUE,
 city_id BIGINT NOT NULL,
 FOREIGN KEY (city_id) REFERENCES cities(id)
);
CREATE TABLE maintenances (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 vehicle_id BIGINT NOT NULL,
 workshop_id BIGINT NOT NULL,
 maintenance_type ENUM('PREVENTIVO','CORRECTIVO','LATONERIA') NOT NULL,
 description VARCHAR(220) NOT NULL,
 started_on DATE NOT NULL,
 ended_on DATE,
 cost DECIMAL(12,2),
 FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
 FOREIGN KEY (workshop_id) REFERENCES workshops(id),
 CHECK (ended_on IS NULL OR ended_on>=started_on),
 CHECK (cost IS NULL OR cost>=0),
 CHECK ((ended_on IS NULL AND cost IS NULL) OR ended_on IS NOT NULL)
);
CREATE TABLE customers (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 city_id BIGINT NOT NULL,
 document_type ENUM('CC','CE','PASAPORTE') NOT NULL DEFAULT 'CC',
 document_number VARCHAR(30) NOT NULL UNIQUE,
 first_name VARCHAR(80) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 email VARCHAR(140) NOT NULL UNIQUE,
 phone VARCHAR(30),
 birth_date DATE NOT NULL,
 registered_at DATE NOT NULL,
 status ENUM('ACTIVO','BLOQUEADO') NOT NULL DEFAULT 'ACTIVO',
 FOREIGN KEY (city_id) REFERENCES cities(id)
);
CREATE TABLE licenses (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 customer_id BIGINT NOT NULL,
 license_number VARCHAR(40) NOT NULL UNIQUE,
 category ENUM('B1','B2','C1','C2') NOT NULL,
 issued_on DATE NOT NULL,
 expires_on DATE NOT NULL,
 issuing_country VARCHAR(60) NOT NULL,
 FOREIGN KEY (customer_id) REFERENCES customers(id),
 CHECK (expires_on>=issued_on)
);
CREATE TABLE additional_drivers (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 document_number VARCHAR(30) NOT NULL UNIQUE,
 full_name VARCHAR(120) NOT NULL,
 birth_date DATE NOT NULL,
 license_number VARCHAR(40) NOT NULL UNIQUE,
 license_expires_on DATE NOT NULL
);
CREATE TABLE extras (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(80) NOT NULL UNIQUE,
 list_daily_price DECIMAL(12,2) NOT NULL,
 CHECK (list_daily_price>0)
);
CREATE TABLE reservations (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 customer_id BIGINT NOT NULL,
 vehicle_id BIGINT NOT NULL,
 pickup_branch_id BIGINT NOT NULL,
 return_branch_id BIGINT NOT NULL,
 pickup_date DATE NOT NULL,
 return_date DATE NOT NULL,
 quoted_amount DECIMAL(12,2) NOT NULL,
 created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 status ENUM('PENDIENTE','CONFIRMADA','CONVERTIDA','CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
 FOREIGN KEY (customer_id) REFERENCES customers(id),
 FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
 FOREIGN KEY (pickup_branch_id) REFERENCES branches(id),
 FOREIGN KEY (return_branch_id) REFERENCES branches(id),
 CHECK (return_date>pickup_date),
 CHECK (quoted_amount>0)
) AUTO_INCREMENT=501;
CREATE TABLE contracts (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 reservation_id BIGINT NOT NULL UNIQUE,
 employee_id BIGINT NOT NULL,
 started_on DATE NOT NULL,
 expected_end DATE NOT NULL,
 actual_return DATE,
 rental_amount DECIMAL(12,2) NOT NULL,
 status ENUM('ABIERTO','CERRADO') NOT NULL DEFAULT 'ABIERTO',
 FOREIGN KEY (reservation_id) REFERENCES reservations(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id),
 CHECK (expected_end>started_on),
 CHECK (actual_return IS NULL OR actual_return>started_on),
 CHECK (rental_amount>=0)
) AUTO_INCREMENT=9001;
CREATE TABLE contract_extras (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL,
 extra_id BIGINT NOT NULL,
 quantity INT NOT NULL,
 agreed_daily_price DECIMAL(12,2) NOT NULL,
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 FOREIGN KEY (extra_id) REFERENCES extras(id),
 UNIQUE (contract_id,extra_id),
 CHECK (quantity>=1),
 CHECK (agreed_daily_price>0)
);
CREATE TABLE contract_additional_drivers (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL,
 additional_driver_id BIGINT NOT NULL,
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 FOREIGN KEY (additional_driver_id) REFERENCES additional_drivers(id),
 UNIQUE (contract_id,additional_driver_id)
);
CREATE TABLE deliveries (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL UNIQUE,
 branch_id BIGINT NOT NULL,
 employee_id BIGINT NOT NULL,
 delivered_at DATETIME NOT NULL,
 mileage_km INT NOT NULL,
 fuel_pct INT NOT NULL,
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id),
 CHECK (mileage_km>=0),
 CHECK (fuel_pct BETWEEN 0 AND 100)
);
CREATE TABLE returns (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL UNIQUE,
 branch_id BIGINT NOT NULL,
 employee_id BIGINT NOT NULL,
 returned_at DATETIME NOT NULL,
 mileage_km INT NOT NULL,
 fuel_pct INT NOT NULL,
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id),
 CHECK (mileage_km>=0),
 CHECK (fuel_pct BETWEEN 0 AND 100)
);
CREATE TABLE inspections (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL,
 employee_id BIGINT NOT NULL,
 stage ENUM('ENTREGA','DEVOLUCION') NOT NULL,
 inspected_at DATETIME NOT NULL,
 exterior_ok BOOLEAN NOT NULL,
 interior_ok BOOLEAN NOT NULL,
 notes VARCHAR(250),
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id),
 UNIQUE (contract_id,stage)
);
CREATE TABLE damages (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 inspection_id BIGINT NOT NULL,
 description VARCHAR(220) NOT NULL,
 severity ENUM('LEVE','MODERADO','GRAVE') NOT NULL,
 repair_cost DECIMAL(12,2) NOT NULL,
 charge_customer BOOLEAN NOT NULL DEFAULT FALSE,
 FOREIGN KEY (inspection_id) REFERENCES inspections(id),
 CHECK (repair_cost>=0)
);
CREATE TABLE deposits (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL UNIQUE,
 amount DECIMAL(12,2) NOT NULL,
 held_at DATETIME NOT NULL,
 released_at DATETIME,
 applied_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
 status ENUM('RETENIDO','LIBERADO','APLICADO') NOT NULL DEFAULT 'RETENIDO',
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 CHECK (amount>0),
 CHECK (applied_amount>=0 AND applied_amount<=amount)
);
CREATE TABLE payments (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 contract_id BIGINT NOT NULL,
 concept ENUM('ALQUILER','EXTRAS','DAÑOS','CIERRE') NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 payment_method ENUM('TARJETA','EFECTIVO','TRANSFERENCIA','DEPOSITO') NOT NULL,
 paid_at DATETIME NOT NULL,
 card_last4 CHAR(4),
 authorization_code VARCHAR(40),
 FOREIGN KEY (contract_id) REFERENCES contracts(id),
 CHECK (amount>0),
 CHECK (card_last4 IS NULL OR card_last4 REGEXP '^[0-9]{4}$')
);

SHOW TABLES;
DESCRIBE reservations;
DESCRIBE contracts;
