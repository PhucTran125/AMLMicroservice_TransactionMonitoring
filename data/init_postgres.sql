-- Xóa các bảng hiện có
DROP TABLE IF EXISTS alerts CASCADE;
DROP TABLE IF EXISTS user_sanctions CASCADE;
DROP TABLE IF EXISTS user_peps CASCADE;
DROP TABLE IF EXISTS sanctions CASCADE;
DROP TABLE IF EXISTS peps CASCADE;
DROP TABLE IF EXISTS user_addresses CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS transaction_transfers CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS account_openings CASCADE;
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

-- Tạo bảng account_openings
CREATE TABLE account_openings (
    id BIGINT PRIMARY KEY,
    timestamp BIGINT,
    customer_id BIGINT,
    customer_name VARCHAR(100),
    customer_identification_number VARCHAR(50),
    dob VARCHAR(10),
    nationality VARCHAR(100),
    residential_address VARCHAR(255),
    status VARCHAR(50),
    result VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES users(id)
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

-- Tạo bảng transaction_transfers
CREATE TABLE transaction_transfers (
    id BIGINT PRIMARY KEY,
    timestamp BIGINT,
    amount BIGINT,
    currency VARCHAR(10),
    source_account_number BIGINT,
    destination_account_number BIGINT,
    customer_id BIGINT,
    customer_name VARCHAR(100),
    customer_identification_number VARCHAR(50),
    date TIMESTAMP,
    country VARCHAR(100),
    status VARCHAR(50),
    FOREIGN KEY (source_account_number) REFERENCES accounts(id),
    FOREIGN KEY (destination_account_number) REFERENCES accounts(id),
    FOREIGN KEY (customer_id) REFERENCES users(id)
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

-- Thêm dữ liệu vào bảng account_openings
INSERT INTO account_openings (
    id, timestamp, customer_id, customer_name, customer_identification_number, 
    dob, nationality, residential_address, status, result
) VALUES
(101, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000, 1, 'Nguyễn Văn An', '123456789', '1985-05-10', 'Vietnam', '123 Đường Láng, Hà Nội', 'APPROVED', ''),
(102, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 2, 'Lê Thị Bình', '987654321', '1978-03-15', 'Vietnam', '456 Nguyễn Huệ, TP.HCM', 'PENDING', 'Under review due to PEP status'),
(103, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 172800000, 3, 'Trần Văn Cường', '456789123', '1990-07-20', 'Vietnam', '789 Street C, Tehran', 'REJECTED', 'Sanctioned individual detected'),
(104, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 259200000, 4, 'Phạm Thị Dung', '321654987', '1988-11-25', 'Vietnam', '101 Street D, Pyongyang', 'APPROVED', ''),
(105, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 345600000, 5, 'Võ Văn Em', '789123456', '1995-01-30', 'Vietnam', '202 Street E, Damascus', 'APPROVED', '');

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

-- Thêm dữ liệu vào bảng transaction_transfers
INSERT INTO transaction_transfers (
    id, timestamp, amount, currency, source_account_number, destination_account_number,
    customer_id, customer_name, customer_identification_number, date, country, status
) VALUES
-- Case 1: Smurfing
(201, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 5000000, 'VND', 101, 102, 1, 'Nguyễn Văn An', '123456789', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'PENDING'),
(202, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 172800000, 6000000, 'VND', 101, 102, 1, 'Nguyễn Văn An', '123456789', CURRENT_TIMESTAMP - INTERVAL '2 day', 'Vietnam', 'PENDING'),
(203, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 259200000, 7000000, 'VND', 101, 102, 1, 'Nguyễn Văn An', '123456789', CURRENT_TIMESTAMP - INTERVAL '3 day', 'Vietnam', 'PENDING'),
(204, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 345600000, 8000000, 'VND', 101, 102, 1, 'Nguyễn Văn An', '123456789', CURRENT_TIMESTAMP - INTERVAL '4 day', 'Vietnam', 'PENDING'),
-- Case 2: Large transactions
(205, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 500000000, 'VND', 102, 105, 2, 'Lê Thị Bình', '987654321', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'PENDING'),
(206, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 172800000, 600000000, 'VND', 103, 105, 3, 'Trần Văn Cường', '456789123', CURRENT_TIMESTAMP - INTERVAL '2 day', 'Vietnam', 'REJECTED'),
(207, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 259200000, 450000000, 'VND', 104, 105, 4, 'Phạm Thị Dung', '321654987', CURRENT_TIMESTAMP - INTERVAL '3 day', 'Vietnam', 'PENDING'),
-- Case 3: Circular transactions
(208, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 200000000, 'VND', 101, 102, 1, 'Nguyễn Văn An', '123456789', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'PENDING'),
(209, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 200000000, 'VND', 102, 103, 2, 'Lê Thị Bình', '987654321', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'PENDING'),
(210, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 200000000, 'VND', 103, 101, 3, 'Trần Văn Cường', '456789123', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'REJECTED'),
-- Case 4: High-risk jurisdiction
(211, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 150000000, 'VND', 104, 103, 4, 'Phạm Thị Dung', '321654987', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Iran', 'PENDING'),
(212, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 172800000, 200000000, 'VND', 105, 103, 5, 'Võ Văn Em', '789123456', CURRENT_TIMESTAMP - INTERVAL '2 day', 'North Korea', 'PENDING'),
(213, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 259200000, 180000000, 'VND', 104, 105, 4, 'Phạm Thị Dung', '321654987', CURRENT_TIMESTAMP - INTERVAL '3 day', 'Syria', 'PENDING'),
-- Case 5: Sanctioned user
(214, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 300000000, 'VND', 103, 104, 3, 'Trần Văn Cường', '456789123', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'REJECTED'),
-- Case 6: PEP
(215, EXTRACT(EPOCH FROM CURRENT_TIMESTAMP) * 1000 - 86400000, 250000000, 'VND', 102, 105, 2, 'Lê Thị Bình', '987654321', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Vietnam', 'PENDING');

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
    transaction_id, customer_id, amount, date, country, 
    sourceaccountnumber, destinationaccountnumber, status, reason, isconfirmedmoneylaundering
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