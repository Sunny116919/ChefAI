from PIL import Image
import os

# Paths
input_folder = r'D:/ai_recipe/All recipe images/jpeg'       # Folder with .webp images
output_folder = r'D:/ai_recipe/All recipe images/jpg'        # Folder to save .jpg images

# Create output folder if it doesn't exist
os.makedirs(output_folder, exist_ok=True)

# Process all .webp files
for filename in os.listdir(input_folder):
    if filename.lower().endswith('.jpeg'):             # change here to from image
        webp_path = os.path.join(input_folder, filename)
        jpg_filename = os.path.splitext(filename)[0] + '.jpg'       # need image after change
        jpg_path = os.path.join(output_folder, jpg_filename)

        with Image.open(webp_path) as img:
            img.convert('RGB').save(jpg_path, 'JPEG')
            print(f"Converted: {filename} → {jpg_filename}")

print("All conversions complete.")
