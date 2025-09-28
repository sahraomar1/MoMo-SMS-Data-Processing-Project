import xml.etree.ElementTree as ET
import json
import re

# Load the XML file
tree = ET.parse('08_09_2025/momo-sms-dashboard/data/raw/momo.xml')
root = tree.getroot()

# List to hold transactions
transactions = []

# Patterns to find info in body
patterns = {
    'transaction_id': r'(?:Financial Transaction Id|TxId):?\s*(\d+)|Deposit::CASH::::0::(\d+)',
    'amount': r'(?:received|payment of|transferred to|deposit of)\s*(\d+\.?\d*)\s*RWF',
    'sender_name': r'(?:from|to)\s*([A-Za-z\s]+)\s*\(\d+\*+\d+\)|\(from\s*(\d+)\s*at',
    'sender_phone': r'(?:from|to)\s*[A-Za-z\s]+\s*\((\d+\*+\d+)\)|\(from\s*(\d+)\s*at',
    'receiver_name': r'(?:to)\s*([A-Za-z\s]+)\s*\d+\s*has been|to\s*([A-Za-z\s]+)\s*\(\d+\)|to\s*([A-Za-z\s]+)\s*\(\d+\*+\d+\)',
    'receiver_phone': r'(?:to)\s*[A-Za-z\s]+\s*(\d+)\s*has been|to\s*[A-Za-z\s]+\s*\((\d+\*+\d+)\)',
    'transaction_date': r'at\s*(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})',
    'balance': r'(?:new balance|NEW BALANCE)\s*[:]?(\d+\.?\d*)\s*RWF',
    'fee': r'Fee was\s*[:]?(\d+\.?\d*)\s*RWF',
    'message': r'Message\s*(?:from sender)?:\s*(.*?)\.\s*(?:Your new balance|Fee was)'
}

# Process each SMS
for sms in root.findall('sms'):
    transaction = {
        'date': sms.get('date'),
        'type': sms.get('type'),
        'readable_date': sms.get('readable_date'),
        'address': sms.get('address'),
        'contact_name': sms.get('contact_name')
    }
    
    body = sms.get('body')
    for key, pattern in patterns.items():
        match = re.search(pattern, body, re.IGNORECASE)
        if match:
            # Try group(1), then group(2), else None
            try:
                transaction[key] = match.group(1) or match.group(2)
            except IndexError:
                transaction[key] = None
        else:
            transaction[key] = None
    
    transactions.append(transaction)

# Save as JSON (list version for API)
with open('08_09_2025/momo-sms-dashboard/data/processed/transactions.json', 'w') as f:
    json.dump(transactions, f, indent=4)

# Save dictionary version for DSA
transaction_dict = {t['transaction_id']: t for t in transactions if t['transaction_id'] is not None}
with open('08_09_2025/momo-sms-dashboard/data/processed/transactions_dict.json', 'w') as f:
    json.dump(transaction_dict, f, indent=4)

print("XML parsed and saved to data/processed/transactions.json and data/processed/transactions_dict.json")