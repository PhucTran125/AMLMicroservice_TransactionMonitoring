-- Xóa các bảng hiện có
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
    accountNumber BIGINT,
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
    issuspicioustransaction BOOLEAN DEFAULT false,
    isconfirmedmoneylaundering BOOLEAN DEFAULT false,
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
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT,
    customer_id BIGINT,
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
(1, 'Nguyễn Văn An', false, false),
(2, 'Lê Thị Bình', true, false),
(3, 'Trần Văn Cường', false, true),
(4, 'Phạm Thị Dung', false, false),
(5, 'Võ Văn Em', false, false);

-- Thêm dữ liệu vào bảng accounts
INSERT INTO accounts (id, type, userId, accountNumber) VALUES
(101, 'personal', 1, 1234567890),
(102, 'business', 2, 1234567891),
(103, 'personal', 3, 1234567892),
(104, 'personal', 4, 1234567893),
(105, 'personal', 5, 1234567894);

-- Thêm dữ liệu vào bảng transactions
-- Case 1: Smurfing - Nhiều giao dịch nhỏ (< 10 triệu VND) từ account 101 đến 102 trong 7 ngày
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(201, 5000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 101, 102, 'Vietnam', true),
(202, 6000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 101, 102, 'Vietnam', true),
(203, 7000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 101, 102, 'Vietnam', true),
(204, 8000000, CURRENT_TIMESTAMP - INTERVAL '4 day', 101, 102, 'Vietnam', true);

-- Case 2: Large transactions - Giao dịch vượt quá 400 triệu VND
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(205, 500000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 102, 105, 'Vietnam', true),
(206, 600000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 103, 105, 'Vietnam', true),
(207, 450000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 104, 105, 'Vietnam', true);

-- Case 3: Circular transactions - Giao dịch vòng tròn: 101 -> 102 -> 103 -> 101
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(208, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 101, 102, 'Vietnam', true),
(209, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 102, 103, 'Vietnam', true),
(210, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 103, 101, 'Vietnam', true);

-- Case 4: High-risk jurisdiction - Giao dịch liên quan đến Iran, North Korea, Syria
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(211, 150000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 104, 103, 'Iran', true),
(212, 200000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 105, 103, 'North Korea', true),
(213, 180000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 104, 105, 'Syria', true);

-- Case 5: Sanctioned user - Giao dịch liên quan đến user bị trừng phạt (userId = 3)
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(214, 300000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 103, 104, 'Vietnam', true);

-- Case 6: PEP - Giao dịch liên quan đến user là PEP (userId = 2)
INSERT INTO transactions (id, transactionamount, date, fromaccount, toaccount, country, issuspicioustransaction) VALUES
(215, 250000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 102, 105, 'Vietnam', true);

-- Thêm dữ liệu vào bảng addresses
INSERT INTO addresses (id, value, country) VALUES
(1, '123 Đường Láng, Hà Nội', 'Vietnam'),
(2, '456 Nguyễn Huệ, TP.HCM', 'Vietnam'),
(3, '789 Street C, Tehran', 'Iran'),
(4, '101 Street D, Pyongyang', 'North Korea'),
(5, '202 Street E, Damascus', 'Syria');

-- Thêm dữ liệu vào bảng user_addresses
INSERT INTO user_addresses (userId, addressId) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Thêm dữ liệu vào bảng peps
INSERT INTO peps (id, name) VALUES
(1, 'Lê Thị Bình');

-- Thêm dữ liệu vào bảng sanctions
INSERT INTO sanctions (id, name) VALUES
(1, 'Trần Văn Cường');

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
-- Case 1: Smurfing
(201, 1, 5000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 101, 102, 'PENDING', 'Smurfing detected: 4 small transactions in 7 days', false),
(202, 1, 6000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 'Vietnam', 101, 102, 'PENDING', 'Smurfing detected: 4 small transactions in 7 days', false),
(203, 1, 7000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 'Vietnam', 101, 102, 'PENDING', 'Smurfing detected: 4 small transactions in 7 days', false),
(204, 1, 8000000, CURRENT_TIMESTAMP - INTERVAL '4 day', 'Vietnam', 101, 102, 'PENDING', 'Smurfing detected: 4 small transactions in 7 days', false),

-- Case 2: Large transactions
(205, 2, 500000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 102, 105, 'PENDING', 'Large transaction: Amount exceeds 400,000,000 VND', false),
(206, 3, 600000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 'Vietnam', 103, 105, 'PENDING', 'Large transaction: Amount exceeds 400,000,000 VND', false),
(207, 4, 450000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 'Vietnam', 104, 105, 'PENDING', 'Large transaction: Amount exceeds 400,000,000 VND', false),

-- Case 3: Circular transactions
(208, 1, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 101, 102, 'INVESTIGATING', 'Circular transaction detected: 101 -> 102 -> 103 -> 101', false),
(209, 2, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 102, 103, 'INVESTIGATING', 'Circular transaction detected: 101 -> 102 -> 103 -> 101', false),
(210, 3, 200000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 103, 101, 'INVESTIGATING', 'Circular transaction detected: 101 -> 102 -> 103 -> 101', false),

-- Case 4: High-risk jurisdiction
(211, 4, 150000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Iran', 104, 103, 'OPEN', 'Transaction from high-risk jurisdiction: Iran', false),
(212, 5, 200000000, CURRENT_TIMESTAMP - INTERVAL '2 day', 'North Korea', 105, 103, 'OPEN', 'Transaction from high-risk jurisdiction: North Korea', false),
(213, 4, 180000000, CURRENT_TIMESTAMP - INTERVAL '3 day', 'Syria', 104, 105, 'OPEN', 'Transaction from high-risk jurisdiction: Syria', false),

-- Case 5: Sanctioned user
(214, 3, 300000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 103, 104, 'PENDING', 'Transaction involving sanctioned individual: Trần Văn Cường', false),

-- Case 6: PEP
(215, 2, 250000000, CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 102, 105, 'PENDING', 'Large transaction involving PEP: Lê Thị Bình', false);