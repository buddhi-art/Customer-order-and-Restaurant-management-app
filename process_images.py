import os
import glob
from rembg import remove
from PIL import Image

def main():
    folder = 'assets/coffees'
    if not os.path.exists(folder):
        print(f"Folder {folder} does not exist.")
        return

    images = glob.glob(os.path.join(folder, '*.jpeg')) + glob.glob(os.path.join(folder, '*.jpg'))
    
    if not images:
        print("No images found.")
        return

    print(f"Found {len(images)} images to process.")

    for img_path in images:
        print(f"Processing {img_path}...")
        try:
            input_image = Image.open(img_path)
            output_image = remove(input_image)
            
            # Save as PNG
            png_path = os.path.splitext(img_path)[0] + '.png'
            output_image.save(png_path, "PNG")
            
            # Remove original
            os.remove(img_path)
            print(f"Saved {png_path} and deleted original.")
        except Exception as e:
            print(f"Failed to process {img_path}: {e}")

if __name__ == "__main__":
    main()
