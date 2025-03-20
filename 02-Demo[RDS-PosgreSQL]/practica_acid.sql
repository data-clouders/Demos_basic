-- Tabla de clientes
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla de cuentas: cada cuenta está asociada a un cliente
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    balance NUMERIC(10,2) NOT NULL DEFAULT 0
);

-- Tabla de transacciones: registra movimientos entre cuentas
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_from INT REFERENCES accounts(account_id),
    account_to INT REFERENCES accounts(account_id),
    amount NUMERIC(10,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar registros a las tablas:

INSERT INTO customers (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com'),
('David', 'david@example.com'),
('Eva', 'eva@example.com'),
('Frank', 'frank@example.com'),
('Grace', 'grace@example.com'),
('Hector', 'hector@example.com'),
('Irene', 'irene@example.com'),
('John', 'john@example.com');


INSERT INTO accounts (customer_id, balance) VALUES
(1, 1000.00),
(2, 1500.00),
(3, 2000.00),
(4, 2500.00),
(5, 3000.00),
(6, 3500.00),
(7, 4000.00),
(8, 4500.00),
(9, 5000.00),
(10, 5500.00);

INSERT INTO transactions (account_from, account_to, amount) VALUES
(1, 2, 100.00),
(2, 3, 200.00),
(3, 4, 150.00),
(4, 5, 250.00),
(5, 6, 300.00),
(6, 7, 350.00),
(7, 8, 400.00),
(8, 9, 450.00),
(9, 10, 500.00),
(10, 1, 550.00);


-- Ejemplo de transacción:

-- PASO 1: Iniciar la transacción y establecer un alto nivel de aislamiento para evitar interferencias de otras transacciones.
-- [ATOMICIDAD] Se inicia la transacción para garantizar que todas las operaciones sean todo o nada.
BEGIN;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- PASO 2: Actualizar el saldo de la cuenta de origen (deducir 100 unidades de account_id = 1).
-- [CONSISTENCIA] Se asegura que la cuenta de origen disminuya su saldo correctamente, respetando la regla de integridad del sistema.

UPDATE accounts
SET balance = balance - 20
WHERE account_id = 1;

-- Paso 3: Registrar la transacción en la tabla de transacciones.
-- [CONSISTENCIA] Se guarda el registro del movimiento para mantener la integridad y trazabilidad de las operaciones.

INSERT INTO transactions (account_from, account_to, amount)
VALUES (1, 2, 20);


-- Paso 4: Simular un error intencional para demostrar la Atomicidad.
-- [Atomicidad] El error genera la falla de la transacción, de modo que ninguna de las operaciones previas se aplicará.

SELECT 1/0;  -- Esta operación provoca un error de división por cero.

-- Paso 5: (Este paso no se ejecutará debido al error anterior)
-- [Consistencia] (Si se ejecutara) se aseguraría que la cuenta destino incremente su saldo de forma correcta.

UPDATE accounts
SET balance = balance + 20
WHERE account_id = 2;

-- Paso 6: Confirmar la transacción.
-- [Durabilidad] Una vez que se ejecuta COMMIT (en un escenario sin error), los cambios quedarían grabados de forma permanente en la base de datos.
COMMIT;

-- Devolver los cambios:
ROLLBACK;

-- Consultar tablas:
SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM transactions;

-- Eliminar tablas:
DROP TABLE transactions;
DROP TABLE accounts;
DROP TABLE customers;

-- Eliminar todos los registros de las tablas:
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE transactions;