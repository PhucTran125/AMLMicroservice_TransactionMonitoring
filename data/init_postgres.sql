DROP TABLE IF EXISTS alerts CASCADE;
DROP TABLE IF EXISTS user_sanctions CASCADE;
DROP TABLE IF EXISTS user_peps CASCADE;
DROP TABLE IF EXISTS sanctions CASCADE;
DROP TABLE IF EXISTS peps CASCADE;
DROP TABLE IF EXISTS user_addresses CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Tạo bảng users
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    fullName VARCHAR(100),
    is_pep BOOLEAN,
    is_sanctioned BOOLEAN
);

-- Tạo bảng accounts
CREATE TABLE accounts (
    id BIGINT PRIMARY KEY,
    type VARCHAR(50),
    userId BIGINT,
    accountNumber VARCHAR(50),
    FOREIGN KEY (userId) REFERENCES users(id)
);

-- Tạo bảng transactions
CREATE TABLE transactions (
    id BIGINT PRIMARY KEY,
    transactionamount BIGINT,
    date TIMESTAMP,
    fromaccount BIGINT,
    toaccount BIGINT,
    country VARCHAR(100),
    isSuspiciousTransaction BOOLEAN DEFAULT false,
    isConfirmedMoneyLaundering BOOLEAN DEFAULT false,
    FOREIGN KEY (fromaccount) REFERENCES accounts(id),
    FOREIGN KEY (toaccount) REFERENCES accounts(id)
);

-- Tạo bảng addresses
CREATE TABLE addresses (
    id BIGINT PRIMARY KEY,
    value VARCHAR(255),
    country VARCHAR(100)
);

-- Tạo bảng user_addresses
CREATE TABLE user_addresses (
    userId BIGINT,
    addressId BIGINT,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (addressId) REFERENCES addresses(id),
    PRIMARY KEY (userId, addressId)
);

-- Tạo bảng peps
CREATE TABLE peps (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100)
);

-- Tạo bảng sanctions
CREATE TABLE sanctions (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100)
);

-- Tạo bảng user_peps
CREATE TABLE user_peps (
    userId BIGINT,
    pepId BIGINT,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (pepId) REFERENCES peps(id),
    PRIMARY KEY (userId, pepId)
);

-- Tạo bảng user_sanctions
CREATE TABLE user_sanctions (
    userId BIGINT,
    sanctionId BIGINT,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (sanctionId) REFERENCES sanctions(id),
    PRIMARY KEY (userId, sanctionId)
);

-- Tạo bảng alerts
CREATE TABLE alerts (
    id BIGSERIAL PRIMARY KEY,  -- Tự động tăng (IDENTITY trong Java)
    transaction_id BIGINT,
    customer_id VARCHAR(100),
    amount BIGINT,
    date TIMESTAMP,
    country VARCHAR(100),
    sourceaccountnumber BIGINT,
    destinationaccountnumber BIGINT,
    status VARCHAR(50),
    reason VARCHAR(255),
    isconfirmedmoneylaundering BOOLEAN DEFAULT FALSE
);

-- Thêm dữ liệu vào bảng users
INSERT INTO users (id, fullName, is_pep, is_sanctioned) VALUES
(1, 'Nguyen Van A', false, false),
(2, 'Le Thi B', true, false),
(3, 'Tran Van C', false, true),
(4, 'Pham Thi D', false, false),
(5, 'Vo Van E', false, false);

-- Thêm dữ liệu vào bảng accounts
INSERT INTO accounts (id, type, userId, accountNumber) VALUES
(101, 'personal', 1, 'AC001'),
(102, 'business', 2, 'AC002'),
(103, 'personal', 3, 'AC003'),
(104, 'personal', 4, 'AC004'),
(105, 'personal', 5, 'AC005');

-- Thêm dữ liệu vào bảng transactions
-- Smurfing: nhiều giao dịch nhỏ từ account 101 đến 102 trong 1 tuần
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country) VALUES
(201, 100, now() - interval '1 day', 101, 102, 'Vietnam'),
(202, 200, now() - interval '2 day', 101, 102, 'Vietnam'),
(203, 150, now() - interval '3 day', 101, 102, 'Vietnam'),
(204, 120, now() - interval '4 day', 101, 102, 'Vietnam'),
-- Large transactions
(205, 10000, now() - interval '1 day', 102, 105, 'Vietnam'),
(206, 15000, now() - interval '2 day', 103, 105, 'Vietnam'),
(207, 20000, now() - interval '3 day', 104, 105, 'Vietnam'),
-- Circular transactions: 101 -> 102 -> 103 -> 101
(208, 5000, now() - interval '1 day', 101, 102, 'Vietnam'),
(209, 5000, now() - interval '1 day', 102, 103, 'Vietnam'),
(210, 5000, now() - interval '1 day', 103, 101, 'Vietnam'),
-- High-risk jurisdiction
(211, 3000, now() - interval '1 day', 104, 103, 'Iran'),
(212, 4000, now() - interval '2 day', 105, 103, 'North Korea');

-- Thêm dữ liệu vào bảng addresses
INSERT INTO addresses (id, value, country) VALUES
(1, '123 Đường A, Hà Nội', 'Vietnam'),
(2, '456 Đường B, TP.HCM', 'Vietnam'),
(3, '789 Street C, Tehran', 'Iran'),
(4, '101 Street D, Pyongyang', 'North Korea');

-- Thêm dữ liệu vào bảng user_addresses
INSERT INTO user_addresses (userId, addressId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

-- Thêm dữ liệu vào bảng peps
INSERT INTO peps (id, name) VALUES
(1, 'Le Thi B');

-- Thêm dữ liệu vào bảng sanctions
INSERT INTO sanctions (id, name) VALUES
(1, 'Tran Van C');

-- Thêm dữ liệu vào bảng user_peps
INSERT INTO user_peps (userId, pepId) VALUES
(2, 1);

-- Thêm dữ liệu vào bảng user_sanctions
INSERT INTO user_sanctions (userId, sanctionId) VALUES
(3, 1);

-- Thêm dữ liệu vào bảng alerts
INSERT INTO alerts (
    transaction_id,
    customer_id,
    amount,
    date,
    country,
    sourceaccountnumber,
    destinationaccountnumber,
    status,
    reason,
    isconfirmedmoneylaundering
) VALUES
-- Smurfing case
(201, '1', 100, now() - interval '1 day', 'Vietnam', 101, 102, 'PENDING', 'Smurfing detected: small transactions in short time', false),

-- Large transaction
(207, '5', 20000, now() - interval '3 day', 'Vietnam', 104, 105, 'PENDING', 'Transaction exceeds threshold limit', false),

-- Circular transaction
(210, '1', 5000, now() - interval '1 day', 'Vietnam', 103, 101, 'INVESTIGATING', 'Circular transaction detected in customer accounts', false),

-- High-risk country
(211, '3', 3000, now() - interval '1 day', 'Iran', 104, 103, 'OPEN', 'Transaction from high-risk jurisdiction', true),

-- Sanctioned user transaction
(212, '3', 4000, now() - interval '2 day', 'North Korea', 105, 103, 'PENDING', 'Transaction involving sanctioned individual', true),

-- PEP (Politically Exposed Person)
(205, '2', 10000, now() - interval '1 day', 'Vietnam', 102, 105, 'PENDING', 'Large transaction involving PEP', false);
