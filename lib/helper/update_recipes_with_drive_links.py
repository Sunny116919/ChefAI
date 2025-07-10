import json
import time
from google.oauth2 import service_account
from googleapiclient.discovery import build

# === CONFIGURATION ===
JSON_FILE_PATH = 'D:/ai_recipe/lib/helper/recipee.json'                # Input JSON
OUTPUT_FILE_PATH = 'D:/ai_recipe/lib/helper/recipes_with_images.json'  # Output JSON
CREDENTIALS_FILE = 'D:/downloads/glass-sequence-463113-t6-6a5309000b49.json'    # Service account key
DRIVE_FOLDER_ID = '187F0UsO5RnNdJwydpj9tk3Yd7D3XbigU'  # Drive folder ID

# === GOOGLE DRIVE API SETUP ===
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
creds = service_account.Credentials.from_service_account_file(
    CREDENTIALS_FILE, scopes=SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

# === FUNCTION TO SEARCH IMAGE BY RECIPE NAME ===
def get_drive_image_url(recipe_name):
    query = f"'{DRIVE_FOLDER_ID}' in parents"
    results = drive_service.files().list(
        q=query,
        spaces='drive',
        fields='files(id, name)',
        pageSize=1000
    ).execute()

    files = results.get('files', [])
    for file in files:
        if file['name'].lower().startswith(recipe_name.lower()):
            file_id = file['id']
            return f"https://drive.google.com/uc?id={file_id}"

    print(f"❌ Image not found for: {recipe_name}")
    return ""

# === READ YOUR JSON DATA ===
with open(JSON_FILE_PATH, 'r', encoding='utf-8') as f:
    data = json.load(f)

total = len(data)

# === UPDATE JSON IMAGE URLS WITH LOGGING AND DELAY ===
for index, recipe in enumerate(data, start=1):
    name = recipe.get("recipe_name")
    print(f"[{index}/{total}] Processing: {name}...", end=" ")
    
    if name:
        image_url = get_drive_image_url(name)
        if image_url:
            recipe["image_url"] = image_url
            print("✅ Found")
        else:
            print("❌ Not Found")
    
    time.sleep(0.2)  # Delay to avoid rate limiting

# === WRITE UPDATED DATA ===
with open(OUTPUT_FILE_PATH, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("✅ All image URLs updated and saved!")
