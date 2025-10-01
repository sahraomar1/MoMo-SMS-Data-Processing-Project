import json
import time

repeat = 10000

# Load transactions from JSON file
with open("08_09_2025/momo-sms-dashboard/data/processed/transactions.json", "r") as file:
    transactions = json.load(file)

# Filter out transactions without 'id'
transactions = [t for t in transactions if "date" in t]

# Create dictionary vimport json

# Load transactions from JSON file
with open("08_09_2025/momo-sms-dashboard/data/processed/transactions.json", "r") as file:
    transactions = json.load(file)

# Use only transactions that have a 'date'
transactions = [t for t in transactions if "date" in t]

# Create dictionary version for fast lookup
transactions_dict = {t["date"]: t for t in transactions}

# Linear search
def linear_search(transactions, target_id):
    for t in transactions:
        if t["date"] == target_id:
            return t
    return None

# Dictionary lookup
def dict_lookup(transactions_dict, target_id):
    return transactions_dict.get(target_id)

# --- Example: pick an existing date value ---
target_id = "1715351458724"  # Replace with any date value from your JSON

print("Linear Search Result:", linear_search(transactions, target_id))
print("Dictionary Lookup Result:", dict_lookup(transactions_dict, target_id))
#version for fast lookup
transactions_dict = {t["date"]: t for t in transactions}

# Linear search
def linear_search(transactions, target_id):
    for t in transactions:
        if t["date"] == target_id:
            return t
    return None

# Dictionary lookup
def dict_lookup(transactions_dict, target_id):
    return transactions_dict.get(target_id)


start_time = time.time()
for i in range(repeat):
    lin = linear_search(transactions, target_id)
end_time = time.time()
total_linear_time = end_time - start_time
print(f"Total linear search time for {repeat} runs: {total_linear_time:.6f} seconds")
print(f"Average linear search time: {total_linear_time/repeat:.10f} seconds")


start_time = time.time()
for i in range(repeat):
    dic = dict_lookup(transactions_dict, target_id)
end_time = time.time()
total_dict_time = end_time - start_time
print(f"Total  dictionary lookup time for {repeat} runs: {total_dict_time:.6f} seconds")
print(f"Average dictionary lookup time: {total_dict_time/repeat:.10f} seconds")

