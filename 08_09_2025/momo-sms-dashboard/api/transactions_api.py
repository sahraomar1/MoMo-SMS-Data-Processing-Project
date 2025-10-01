import Flask
from Flask import Flask, request, jsonify, Response
import json
import os
import uuid
from functools import wraps
import base64

app = Flask(__name__)


#Credentials for logging in

# Hardcoded credentials
USERNAME = "MotoMan"
PASSWORD = "password123"

def check_auth(username, password):
    """Check if a username/password combo is valid."""
    return username == USERNAME and password == PASSWORD

def authenticate():
    """Send 401 response prompting for login."""
    return Response(
        'Could not verify your access level.\n'
        'You must provide valid credentials.', 
        401,
        {'WWW-Authenticate': 'Basic realm="Login Required"'}
    )

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

# Path to the transactions_dict.json file
DATA_FILE = "08_09_2025/momo-sms-dashboard/data/processed/transactions_dict.json"

# -------------------------
# Load data at startup
# -------------------------
if os.path.exists(DATA_FILE):
    # If the file exists, read it into memory
    with open(DATA_FILE, "r") as f:
        transactions = json.load(f)   # Dictionary keyed by transaction_id
else:
    # If file doesn't exist, start with empty dict
    transactions = {}

# -------------------------
# Helper functions
# -------------------------
def save_data():
    """Write the in-memory transactions dict back to the JSON file."""
    with open(DATA_FILE, "w") as f:
        json.dump(transactions, f, indent=4)

def generate_id():
    """Generate a new random transaction_id (12 digits)."""
    # uuid4().int is a very large integer, we just slice 12 digits for readability
    return str(uuid.uuid4().int)[:12]

# -------------------------
# CRUD Endpoints
# -------------------------

@app.route("/transactions", methods=["GET"])
@requires_auth
def get_all():
    """Return all transactions as a JSON dictionary."""
    return jsonify(transactions)

@app.route("/transactions/<tx_id>", methods=["GET"])
@requires_auth
def get_one(tx_id):
    """Return a single transaction by its transaction_id."""
    tx = transactions.get(tx_id)
    if not tx:
        return jsonify({"error": "Transaction not found"}), 404
    return jsonify(tx)

@app.route("/transactions", methods=["POST"])
@requires_auth
def create():
    """Create a new transaction. If no ID is provided, auto-generate one."""
    data = request.json
    if not data:
        return jsonify({"error": "No data provided"}), 400

    # Use provided ID or generate one if missing
    tx_id = data.get("transaction_id") or generate_id()
    data["transaction_id"] = tx_id

    # Insert into our in-memory dictionary
    transactions[tx_id] = data
    save_data()  # Persist to file
    return jsonify(data), 201

@app.route("/transactions/<tx_id>", methods=["PUT"])
@requires_auth
def update(tx_id):
    """Update an existing transaction (except transaction_id)."""
    tx = transactions.get(tx_id)
    if not tx:
        return jsonify({"error": "Transaction not found"}), 404

    data = request.json
    # Update all fields except transaction_id
    for key, value in data.items():
        if key != "transaction_id":  # prevent overwriting the unique ID
            tx[key] = value

    save_data()
    return jsonify(tx)

@app.route("/transactions/<tx_id>", methods=["DELETE"])
@requires_auth
def delete(tx_id):
    """Delete a transaction by its transaction_id."""
    if tx_id not in transactions:
        return jsonify({"error": "Transaction not found"}), 404

    # Remove the transaction from memory and save
    del transactions[tx_id]
    save_data()
    return jsonify({"message": "Transaction deleted"})

# -------------------------
# Run server
# -------------------------
if __name__ == "__main__":
    # Run the Flask development server
    app.run(debug=True)
