import json
import os
import re
from collections import Counter

def normalize_name(name):
    return re.sub(r'\s+', ' ', name.strip().lower())

script_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(script_dir, 'recipee.json')

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

recipe_names = [normalize_name(item.get('recipe_name', '')) for item in data]

counts = Counter(recipe_names)
duplicates = {name: count for name, count in counts.items() if count > 1}

if duplicates:
    print("Duplicate recipe_name(s) found:")
    for name, count in duplicates.items():
        print(f"'{name}' appears {count} times")
else:
    print("No duplicate recipe_name found.")
