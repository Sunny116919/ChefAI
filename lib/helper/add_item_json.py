import json
import os

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(script_dir, 'recipee.json')

# Load the JSON data
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Add nationality based on ID
for item in data:
    if 1 <= item['id'] <= 20:
        item['cuisine'] = 'Gujarati'

    elif 21 <= item['id'] <= 40:
        item['cuisine'] = 'Punjabi'

    elif 41 <= item['id'] <= 60:
        item['cuisine'] = 'Rajasthani'

    elif 61 <= item['id'] <= 70:
        item['cuisine'] = 'Bengali'

    elif 71 <= item['id'] <= 90:
        item['cuisine'] = 'South Indian'

    elif 91 <= item['id'] <= 100:
        item['cuisine'] = 'Andhra'

    elif 101 <= item['id'] <= 120:
        item['cuisine'] = 'Maharashtrian'

    elif 121 <= item['id'] <= 130:
        item['cuisine'] = 'Goan'

    elif 131 <= item['id'] <= 140:
        item['cuisine'] = 'Kashmiri'

    elif 141 <= item['id'] <= 150:
        item['cuisine'] = 'North-East Indian'

    elif 151 <= item['id'] <= 160:
        item['cuisine'] = 'Italian'

    elif 161 <= item['id'] <= 170:
        item['cuisine'] = 'French'

    elif 171 <= item['id'] <= 180:
        item['cuisine'] = 'Chinese'

    elif 181 <= item['id'] <= 190:
        item['cuisine'] = 'Thai'

    elif 191 <= item['id'] <= 200:
        item['cuisine'] = 'Japanese'

    elif 201 <= item['id'] <= 210:
        item['cuisine'] = 'Korean'

    elif 211 <= item['id'] <= 220:
        item['cuisine'] = 'Mexican'

    elif 221 <= item['id'] <= 230:
        item['cuisine'] = 'American'

    elif 231 <= item['id'] <= 240:
        item['cuisine'] = 'Russian'

    elif 241 <= item['id'] <= 250:
        item['cuisine'] = 'Spanish'

    elif 251 <= item['id'] <= 260:
        item['cuisine'] = 'Middle Eastern'

    elif 261 <= item['id'] <= 270:
        item['cuisine'] = 'African'

    elif 271 <= item['id'] <= 280:
        item['cuisine'] = 'British'

    elif 281 <= item['id'] <= 290:
        item['cuisine'] = 'German'

    elif 291 <= item['id'] <= 300:
        item['cuisine'] = 'Brazilian'

# Write updated JSON back to file
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("added successfully to all entries.")


