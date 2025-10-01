
# MoMo Transactions API Documentation

This API provides CRUD operations for managing mobile money (MoMo) transactions.  
All data is stored in `transactions_dict.json`.

---

## Authentication
All endpoints require **Basic Authentication**.

- **Username:** `admin`
- **Password:** `password123`

Unauthorized requests will return `401 Unauthorized`.

Example (with curl):
```bash
curl -u admin:password123 http://127.0.0.1:5000/transactions


⸻

Endpoints

1. Get All Transactions
	•	Method: GET
	•	URL: /transactions

Request Example:

curl -u admin:password123 http://127.0.0.1:5000/transactions

Response Example:

{
  "123456789012": {
    "transaction_id": "123456789012",
    "sender": "Ishimwe",
    "receiver": "Jean Claude",
    "amount": 100
  },
  "987654321098": {
    "transaction_id": "987654321098",
    "sender": "John",
    "receiver": "Mary",
    "amount": 250
  }
}

Errors:
	•	401 Unauthorized

⸻

2. Get Transaction by ID
	•	Method: GET
	•	URL: /transactions/<transaction_id>

Request Example:

curl -u admin:password123 http://127.0.0.1:5000/transactions/123456789012

Response Example:

{
  "transaction_id": "123456789012",
  "sender": "Alice",
  "receiver": "Bob",
  "amount": 100
}

Errors:
	•	401 Unauthorized
	•	404 Not Found – if transaction ID doesn’t exist

⸻

3. Create a Transaction
	•	Method: POST
	•	URL: /transactions

Request Example:

curl -u admin:password123 -X POST http://127.0.0.1:5000/transactions \
  -H "Content-Type: application/json" \
  -d '{
        "sender": "Alice",
        "receiver": "Bob",
        "amount": 150
      }'

Response Example:

{
  "transaction_id": "654321987654",
  "sender": "Alice",
  "receiver": "Bob",
  "amount": 150
}

Notes:
	•	If no transaction_id is provided, one will be auto-generated.

Errors:
	•	400 Bad Request – if no data provided
	•	401 Unauthorized

⸻

4. Update a Transaction
	•	Method: PUT
	•	URL: /transactions/<transaction_id>

Request Example:

curl -u admin:password123 -X PUT http://127.0.0.1:5000/transactions/123456789012 \
  -H "Content-Type: application/json" \
  -d '{
        "amount": 200,
        "receiver": "Charlie"
      }'

Response Example:

{
  "transaction_id": "123456789012",
  "sender": "Alice",
  "receiver": "Charlie",
  "amount": 200
}

Notes:
	•	transaction_id cannot be changed.
	•	Only other fields are updated.

Errors:
	•	401 Unauthorized
	•	404 Not Found – if transaction doesn’t exist

⸻

5. Delete a Transaction
	•	Method: DELETE
	•	URL: /transactions/<transaction_id>

Request Example:

curl -u admin:password123 -X DELETE http://127.0.0.1:5000/transactions/123456789012

Response Example:

{
  "message": "Transaction deleted"
}

Errors:
	•	401 Unauthorized
	•	404 Not Found – if transaction doesn’t exist

⸻

Error Codes Summary
	•	400 Bad Request – Missing or invalid request body
	•	401 Unauthorized – Invalid or missing credentials
	•	404 Not Found – Resource doesn’t exist

⸻

Running the API

Run the API locally with:

python api/transactions_api.py

Server starts at:
http://127.0.0.1:5000

⸻

File Storage

Transactions are stored persistently in:

08_09_2025/momo-sms-dashboard/data/processed/transactions_dict.json


⸻

Example Workflow
	1.	Create a transaction (POST /transactions)
	2.	Retrieve it (GET /transactions/<id>)
	3.	Update it (PUT /transactions/<id>)
	4.	Delete it (DELETE /transactions/<id>)

---
