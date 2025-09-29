# Team-Setup
Team Name:
# Byte me

# Project Description
This project builds an application to process and categorize MoMo SMS data from XML files. It stores the data in a database and displays it on a frontend dashboard.

# Team Members
- Sahra Omar- Sahraomar1
- Kyle Konan- Kylealu
- Garang Buke- garangbse
- Rajveer Singh Jolly - SpaceMan619

# Link to System Architecture
https://app.diagrams.net/#G1GRbP-ABcnm2IMREPV_XwySqk0tVJ4Avq#%7B%22pageId%22%3A%22Dxe8UFwux_gS2KKT1KYU%22%7D

# Scrum Board
Track our progress here (https://github.com/users/sahraomar1/projects/1)

# MoMo SMS Database

## Overview
This project implements a relational database to store and manage **Mobile Money (MoMo) SMS transaction data**.  
The database is designed to capture key entities such as **Users, Transactions, Categories, and System Logs** while maintaining relationships between them for accurate reporting and analysis.  

The database supports **CRUD operations** (Create, Read, Update, Delete) and enforces **constraints** to ensure data integrity.  

---

## Database Schema

### 1. Users
Stores mobile money customers.  
Each user has a unique phone number.  

**Columns**:
- `user_id` (PK)  
- `phone_number`  
- `full_name`  

---

### 2. Transactions
Stores transaction details such as amount, date, sender, receiver, balance, and status.  
Linked to **Users** through `sender_id` and `receiver_id`.  

**Columns**:
- `transaction_id` (PK)  
- `amount`  
- `transaction_date`  
- `sender_id` (FK → Users.user_id)  
- `receiver_id` (FK → Users.user_id)  
- `balance`  
- `fee`  
- `status` (`PENDING`, `COMPLETED`, `FAILED`)  

---

### 3. Transaction_Categories
Defines categories (e.g., Airtime Purchase, P2P Transfer, Bill Payment).  

**Columns**:
- `category_id` (PK)  
- `category_name` (unique)  
- `description`  

---

### 4. Transaction_Category_Mapping
A **junction table** for the many-to-many relationship between Transactions and Categories.  
Example: A transaction can belong to one or more categories.  

**Columns**:
- `mapping_id` (PK)  
- `transaction_id` (FK → Transactions.transaction_id)  
- `category_id` (FK → Transaction_Categories.category_id)  

---

### 5. System_Logs
Stores logs for each transaction (e.g., parsing status, error messages).  

**Columns**:
- `logs_id` (PK)  
- `transaction_id` (FK → Transactions.transaction_id)  
- `log_message`  
- `log_timestamp`  

---

## Entity-Relationship Diagram (ERD)


- A **User** can send/receive many **Transactions**.  
- A **Transaction** can belong to one or more **Categories**.  
- A **Transaction** can generate many **System Logs**.  

---

## Sample CRUD Operations

### Create – Add new users and transactions
```sql
INSERT INTO Users (phone_number, full_name)
VALUES ('+254700000006', 'Timothy Okoth');

INSERT INTO Transactions (amount, transaction_date, sender_id, receiver_id, balance, fee, status)
VALUES (500.00, NOW(), 7, 8, 1500.00, 2.50, 'COMPLETED');


### Read – Fetch recent transactions with sender and receiver names

SELECT t.transaction_id, t.amount, t.transaction_date, s.full_name AS sender, r.full_name AS receiver, t.status
FROM Transactions t
JOIN Users s ON t.sender_id = s.user_id
JOIN Users r ON t.receiver_id = r.user_id
ORDER BY t.transaction_date DESC;


## Update – Mark a pending transaction as completed 

UPDATE Transactions
SET status = 'COMPLETED', balance = 600.00
WHERE transaction_id = 4;


## Delete – Remove a transaction-category mapping

DELETE FROM Transaction_Category_Mapping
WHERE mapping_id = 5;
