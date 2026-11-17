-- Taller 1 BiblioRed | Abdel Cristancho
DROP DATABASE IF EXISTS bibliored;
CREATE DATABASE bibliored;
USE bibliored;

CREATE TABLE branches (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE,
 municipality VARCHAR(80) NOT NULL,
 address VARCHAR(180) NOT NULL,
 opened_at DATE NOT NULL
);

CREATE TABLE memberships (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(50) NOT NULL UNIQUE,
 loan_limit INT NOT NULL,
 loan_days INT NOT NULL,
 renewals_allowed INT NOT NULL,
 fine_per_day DECIMAL(10,2) NOT NULL,
 annual_fee DECIMAL(12,2) NOT NULL,
 CHECK (loan_limit > 0),
 CHECK (loan_days > 0),
 CHECK (renewals_allowed >= 0),
 CHECK (fine_per_day >= 0),
 CHECK (annual_fee >= 0)
);

CREATE TABLE categories (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE publishers (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE,
 city VARCHAR(80) NOT NULL
);

CREATE TABLE authors (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 full_name VARCHAR(120) NOT NULL,
 nationality VARCHAR(80) NOT NULL,
 birth_year INT NOT NULL,
 CHECK (birth_year BETWEEN 1600 AND 2026)
);

CREATE TABLE employees (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 branch_id BIGINT NOT NULL,
 full_name VARCHAR(120) NOT NULL,
 email VARCHAR(120) NOT NULL UNIQUE,
 hired_at DATE NOT NULL,
 role ENUM('COORDINADOR','BIBLIOTECARIO','AUXILIAR') NOT NULL DEFAULT 'BIBLIOTECARIO',
 FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE titles (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 isbn VARCHAR(20) NOT NULL UNIQUE,
 name VARCHAR(180) NOT NULL,
 publication_year INT NOT NULL,
 category_id BIGINT NOT NULL,
 publisher_id BIGINT NOT NULL,
 replacement_cost DECIMAL(12,2) NOT NULL DEFAULT 50000.00,
 FOREIGN KEY (category_id) REFERENCES categories(id),
 FOREIGN KEY (publisher_id) REFERENCES publishers(id),
 CHECK (publication_year BETWEEN 1400 AND 2026),
 CHECK (replacement_cost > 0)
);

CREATE TABLE title_authors (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 title_id BIGINT NOT NULL,
 author_id BIGINT NOT NULL,
 author_order INT NOT NULL,
 FOREIGN KEY (title_id) REFERENCES titles(id),
 FOREIGN KEY (author_id) REFERENCES authors(id),
 UNIQUE (title_id, author_id),
 UNIQUE (title_id, author_order),
 CHECK (author_order > 0)
);

CREATE TABLE copies (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 title_id BIGINT NOT NULL,
 branch_id BIGINT NOT NULL,
 barcode VARCHAR(40) NOT NULL UNIQUE,
 acquired_at DATE NOT NULL,
 status ENUM('DISPONIBLE','PRESTADO','EN_REPARACION','PERDIDO','DADO_DE_BAJA') NOT NULL DEFAULT 'DISPONIBLE',
 FOREIGN KEY (title_id) REFERENCES titles(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE members (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 document_number VARCHAR(30) NOT NULL UNIQUE,
 first_name VARCHAR(80) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 email VARCHAR(120) UNIQUE,
 phone VARCHAR(30),
 birth_date DATE NOT NULL,
 joined_at DATE NOT NULL,
 membership_id BIGINT NOT NULL,
 branch_id BIGINT NOT NULL,
 status ENUM('ACTIVO','SUSPENDIDO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
 FOREIGN KEY (membership_id) REFERENCES memberships(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id)
);

CREATE TABLE loans (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 copy_id BIGINT NOT NULL,
 member_id BIGINT NOT NULL,
 employee_id BIGINT NOT NULL,
 loan_date DATE NOT NULL,
 due_date DATE NOT NULL,
 returned_at DATE,
 status ENUM('ACTIVO','DEVUELTO','PERDIDO') NOT NULL DEFAULT 'ACTIVO',
 FOREIGN KEY (copy_id) REFERENCES copies(id),
 FOREIGN KEY (member_id) REFERENCES members(id),
 FOREIGN KEY (employee_id) REFERENCES employees(id),
 CHECK (due_date > loan_date),
 CHECK (returned_at IS NULL OR returned_at >= loan_date)
) AUTO_INCREMENT=1001;

CREATE TABLE renewals (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 loan_id BIGINT NOT NULL,
 renewed_at DATE NOT NULL,
 previous_due_date DATE NOT NULL,
 new_due_date DATE NOT NULL,
 FOREIGN KEY (loan_id) REFERENCES loans(id),
 CHECK (new_due_date > previous_due_date)
);

CREATE TABLE reservations (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 member_id BIGINT NOT NULL,
 title_id BIGINT NOT NULL,
 branch_id BIGINT NOT NULL,
 reserved_at DATE NOT NULL,
 expires_at DATE NOT NULL,
 status ENUM('PENDIENTE','ATENDIDA','CANCELADA','VENCIDA') NOT NULL DEFAULT 'PENDIENTE',
 FOREIGN KEY (member_id) REFERENCES members(id),
 FOREIGN KEY (title_id) REFERENCES titles(id),
 FOREIGN KEY (branch_id) REFERENCES branches(id),
 CHECK (expires_at >= reserved_at)
);

CREATE TABLE fines (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 loan_id BIGINT NOT NULL,
 reason ENUM('MORA','DAÑO','PERDIDA') NOT NULL,
 overdue_days INT NOT NULL DEFAULT 0,
 amount DECIMAL(12,2) NOT NULL,
 generated_at DATE NOT NULL,
 status ENUM('PENDIENTE','PAGADA','ANULADA') NOT NULL DEFAULT 'PENDIENTE',
 FOREIGN KEY (loan_id) REFERENCES loans(id),
 CHECK (overdue_days >= 0),
 CHECK (amount > 0)
);

CREATE TABLE fine_payments (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 fine_id BIGINT NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 paid_at DATE NOT NULL,
 payment_method ENUM('EFECTIVO','TARJETA','TRANSFERENCIA') NOT NULL,
 FOREIGN KEY (fine_id) REFERENCES fines(id),
 CHECK (amount > 0)
);

SHOW TABLES;
DESCRIBE loans;

-- CHECK no puede calcular el vencimiento desde los días de membresía ni consultar otras filas.
-- CHECK tampoco puede validar topes agregados de préstamos, multas pendientes, reservas activas,
-- sincronía entre estado del ejemplar y préstamo, mora calculada, suma de abonos o expiración
-- de reservas: esas reglas requieren consultar/modificar varias filas y se implementan con SP.
