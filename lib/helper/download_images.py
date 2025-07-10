#download jpg images from web if any other extension then convert it into jpg. (auto search)
import json
import os
import requests
from PIL import Image
from io import BytesIO

# Your API credentials
GOOGLE_API_KEY = 'AIzaSyD5bDlRZ9ajlQ2OLDQbwStYrRCWP_lC_Dc'
SEARCH_ENGINE_ID = '1295011aa3b6a44b1'

INPUT_JSON = r'D:/ai_recipe/lib/helper/recipee.json'
IMAGES_DIR = 'recipe_images'
os.makedirs(IMAGES_DIR, exist_ok=True)

def search_image_google(query):
    search_url = "https://www.googleapis.com/customsearch/v1"
    params = {
        'key': GOOGLE_API_KEY,
        'cx': SEARCH_ENGINE_ID,
        'q': query,
        'searchType': 'image',
        'num': 1,
        'safe': 'medium'
    }
    response = requests.get(search_url, params=params)
    response.raise_for_status()
    results = response.json()
    items = results.get('items')
    if items and len(items) > 0:
        return items[0]['link']
    return None

def download_and_save_image(image_url, recipe_name):
    try:
        response = requests.get(image_url, timeout=15)
        response.raise_for_status()
        image_bytes = BytesIO(response.content)

        # Try opening image with PIL
        img = Image.open(image_bytes).convert('RGB')  # Convert to RGB to avoid PNG alpha issues

        # Define final JPG path
        filename = f"{recipe_name.strip()}.jpg"
        filepath = os.path.join(IMAGES_DIR, filename)

        img.save(filepath, 'JPEG')
        print(f"Downloaded and converted image: {filepath}")
        return True
    except Exception as e:
        print(f"Failed to process image for {recipe_name}: {e}")
        return False

def main():
    with open(INPUT_JSON, 'r', encoding='utf-8') as f:
        recipes = json.load(f)

    for recipe in recipes:
        recipe_name = recipe.get('recipe_name', None)
        if not recipe_name:
            print("Recipe name missing, skipping...")
            continue

        print(f"Searching image for: {recipe_name}")

        try:
            image_url = search_image_google(recipe_name)
            if not image_url:
                print(f"No image found for {recipe_name}")
                continue

            # Get extension
            ext = os.path.splitext(image_url)[1].split('?')[0].lower()

            # If image is jpg/jpeg, download directly
            if ext in ['.jpg', '.jpeg']:
                filename = f"{recipe_name.strip()}{ext}"
                filepath = os.path.join(IMAGES_DIR, filename)
                download_success = download_and_save_image(image_url, recipe_name)
            else:
                # If not jpg/jpeg, still download and convert to jpg
                print(f"Converting non-JPG image ({ext}) for: {recipe_name}")
                download_success = download_and_save_image(image_url, recipe_name)

        except Exception as e:
            print(f"Error processing {recipe_name}: {e}")

if __name__ == "__main__":
    main()
