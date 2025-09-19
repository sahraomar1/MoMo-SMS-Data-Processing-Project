
-- database_setup.sql
-- MySQL schema and sample data for MoMo SMS Data ERD

-- Create database
CREATE DATABASE IF NOT EXISTS momo_sms;
USE momo_sms;

-- Users table
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for users',
  phone_number VARCHAR(20) NOT NULL UNIQUE COMMENT 'E.164 or local phone number string',
  full_name VARCHAR(200) NOT NULL COMMENT 'Full name of the user',
  CHECK (CHAR_LENGTH(phone_number) BETWEEN 7 AND 20)
);

CREATE INDEX idx_users_phone ON Users(phone_number);

-- Transactions table
CREATE TABLE IF NOT EXISTS Transactions (
  transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for transactions',
  amount DECIMAL(10,2) NOT NULL COMMENT 'Transaction amount in local currency; must be >= 0',
  transaction_date DATETIME NOT NULL COMMENT 'When the transaction occurred',
  sender_id INT NOT NULL COMMENT 'FK -> Users.user_id (sender)',
  receiver_id INT NOT NULL COMMENT 'FK -> Users.user_id (receiver)',
  balance DECIMAL(14,2) DEFAULT NULL COMMENT 'Account balance after transaction (if available)',
  fee DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Transaction fee',
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT 'Transaction status: PENDING, COMPLETED, FAILED',
  CHECK (amount >= 0),
  CHECK (fee >= 0),
  CHECK (status IN ('PENDING','COMPLETED','FAILED')),
  CONSTRAINT fk_transactions_sender FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_transactions_receiver FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_transactions_date ON Transactions(transaction_date);
CREATE INDEX idx_transactions_sender ON Transactions(sender_id);
CREATE INDEX idx_transactions_receiver ON Transactions(receiver_id);
CREATE INDEX idx_transactions_status ON Transactions(status);

-- Transaction categories table
CREATE TABLE IF NOT EXISTS Transaction_Categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for categories',
  category_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Human-readable category name',
  description VARCHAR(200) COMMENT 'Short category description'
);

CREATE INDEX idx_category_name ON Transaction_Categories(category_name);



-- Transaction to category mapping (many-to-many)
CREATE TABLE IF NOT EXISTS Transaction_Category_Mapping (
  mapping_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for mapping',
  transaction_id BIGINT NOT NULL COMMENT 'FK -> Transactions.transaction_id',
  category_id INT NOT NULL COMMENT 'FK -> Transaction_Categories.category_id',
  CONSTRAINT fk_map_transaction FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_map_category FOREIGN KEY (category_id) REFERENCES Transaction_Categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY uq_transaction_category (transaction_id, category_id)
);

CREATE INDEX idx_map_category ON Transaction_Category_Mapping(category_id);

-- System logs table
CREATE TABLE IF NOT EXISTS System_Logs (
  logs_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key for system logs',
  transaction_id BIGINT NOT NULL COMMENT 'FK -> Transactions.transaction_id',
  log_message VARCHAR(500) NOT NULL COMMENT 'Log message captured from processing',
  log_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When log was recorded',
  CONSTRAINT fk_logs_transaction FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_logs_tx ON System_Logs(transaction_id);

-- ---------------------------
-- Sample data (DML) - at least 5 records per main table
-- ---------------------------

-- Users (at least 5)
INSERT INTO Users (phone_number, full_name) VALUES
('+254700000001', 'Alice Mwangi'),
('+254700000002', 'Brian Otieno'),
('+254700000003', 'Catherine Njoroge'),
('+254700000004', 'David Kamau'),
('+254700000005', 'Eunice Wanjiru')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

-- Transaction categories (at least 5)
INSERT INTO Transaction_Categories (category_name, description) VALUES
('Airtime Purchase', 'Top-up airtime transactions'),
('P2P Transfer', 'Person-to-person money transfer'),
('Bill Payment', 'Payments to utility providers'),
('Merchant Payment', 'Payments made to merchants'),
('Cash-Out', 'Cash withdrawals at agents')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Transactions (at least 5) -- ensure sender and receiver exist
INSERT INTO Transactions (amount, transaction_date, sender_id, receiver_id, balance, fee, status) VALUES
(200.00, '2025-09-01 08:12:00', 1, 2, 1200.00, 2.00, 'COMPLETED'),
(50.50,  '2025-09-01 09:30:00', 2, 3, 950.50, 0.50, 'COMPLETED'),
(1000.00,'2025-09-02 10:00:00', 3, 4, 3000.00, 5.00, 'COMPLETED'),
(150.00, '2025-09-03 12:45:00', 4, 5, 450.00, 1.50, 'PENDING'),
(20.00,  '2025-09-04 14:20:00', 5, 1, 80.00, 0.20, 'FAILED');

-- Transaction_Category_Mapping (at least 5)
-- Map transactions to categories by ids (assumes categories inserted earlier)
INSERT INTO Transaction_Category_Mapping (transaction_id, category_id) VALUES
(1, 2), -- P2P Transfer
(2, 1), -- Airtime Purchase
(3, 4), -- Merchant Payment
(4, 5), -- Cash-Out
(5, 3)  -- Bill Payment
ON DUPLICATE KEY UPDATE category_id=VALUES(category_id);

-- System logs (at least 5)
INSERT INTO System_Logs (transaction_id, log_message, log_timestamp) VALUES
(1, 'Parsed SMS: TXN 1 processed successfully', '2025-09-01 08:12:05'),
(2, 'Parsed SMS: Airtime top-up recorded', '2025-09-01 09:30:03'),
(3, 'Parsed SMS: Merchant payment logged', '2025-09-02 10:00:10'),
(4, 'Parsed SMS: Pending confirmation from agent', '2025-09-03 12:45:10'),
(5, 'Parsed SMS: Failed due to insufficient funds', '2025-09-04 14:20:05');

-- ---------------------------
-- Sample CRUD operations to test the implementation
-- Run these after the DML above and observe results
-- ---------------------------

-- 1) Read: show recent transactions with user names and category
SELECT t.transaction_id, t.amount, t.transaction_date, s.full_name AS sender, r.full_name AS receiver, t.status
FROM Transactions t
JOIN Users s ON t.sender_id = s.user_id
JOIN Users r ON t.receiver_id = r.user_id
ORDER BY t.transaction_date DESC;

-- | transaction\_id | amount  | transaction\_date   | sender            | receiver          | status    |
-- | --------------- | ------- | ------------------- | ----------------- | ----------------- | --------- |
-- | 5               | 20.00   | 2025-09-04 14:20:00 | Eunice Wanjiru    | Alice Mwangi      | FAILED    |
-- | 4               | 150.00  | 2025-09-03 12:45:00 | David Kamau       | Eunice Wanjiru    | PENDING   |
-- | 3               | 1000.00 | 2025-09-02 10:00:00 | Catherine Njoroge | David Kamau       | COMPLETED |
-- | 2               | 50.50   | 2025-09-01 09:30:00 | Brian Otieno      | Catherine Njoroge | COMPLETED |
-- | 1               | 200.00  | 2025-09-01 08:12:00 | Alice Mwangi      | Brian Otieno      | COMPLETED |


-- 2) Read with category
SELECT t.transaction_id, c.category_name
FROM Transactions t
LEFT JOIN Transaction_Category_Mapping m ON t.transaction_id = m.transaction_id
LEFT JOIN Transaction_Categories c ON m.category_id = c.category_id
ORDER BY t.transaction_id;

-- | transaction\_id | category\_name   |
-- | --------------- | ---------------- |
-- | 1               | P2P Transfer     |
-- | 2               | Airtime Purchase |
-- | 3               | Merchant Payment |
-- | 4               | Cash-Out         |
--  | 5               | Bill Payment     |


-- 3) Create: insert a new user and a transaction
INSERT INTO Users (phone_number, full_name) VALUES ('+254700000006', 'Timothy Okoth');
INSERT INTO Users (phone_number, full_name) VALUES ('+254700000007', 'Deng Akinyi');
INSERT INTO Users (phone_number, full_name) VALUES ('+254700000008', 'Ben Bob');
INSERT INTO Transactions (amount, transaction_date, sender_id, receiver_id, balance, fee, status) VALUES (500.00, NOW(), 7, 8, 1500.00, 2.50, 'COMPLETED');

-- | user\_id | phone\_number | full\_name        |
-- | -------- | ------------- | ----------------- |
-- | 1        | +254700000001 | Alice Mwangi      |
-- | 2        | +254700000002 | Brian Otieno      |
-- | 3        | +254700000003 | Catherine Njoroge |
-- | 4        | +254700000004 | David Kamau       |
-- | 5        | +254700000005 | Eunice Wanjiru    |
-- | 6        | +254700000006 | Timothy Okoth     |
-- | 7        | +254700000007 | Deng Akinyi       |
-- | 8        | +254700000008 | Ben Bob           |


-- 4) Update: mark a pending transaction as completed and set balance
UPDATE Transactions SET status = 'COMPLETED', balance = 600.00 WHERE transaction_id = 4;

-- | transaction\_id | amount | transaction\_date   | sender\_id | receiver\_id | balance | fee  | status    |
-- | --------------- | ------ | ------------------- | ---------- | ------------ | ------- | ---- | --------- |
-- | 4               | 150.00 | 2025-09-03 12:45:00 | 4          | 5            | 600.00  | 1.50 | COMPLETED |


-- 5) Delete: remove a mapping (example)
DELETE FROM Transaction_Category_Mapping WHERE mapping_id = 5;

-- | mapping\_id | transaction\_id | category\_id |
-- | ----------- | --------------- | ------------ |
-- | 1           | 1               | 2            |
-- | 2           | 2               | 1            |
-- | 3           | 3               | 4            |
-- | 4           | 4               | 5            |


-- ---------------------------
-- End of script
-- ---------------------------
