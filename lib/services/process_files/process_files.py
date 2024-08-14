import sys
import os
import codecs
from pdf2image import convert_from_path
import pytesseract
from PIL import Image, ImageOps
from PyPDF2 import PdfReader, PdfWriter

def resource_path(relative_path):
    """Lấy đường dẫn tài nguyên khi chạy từ tệp thực thi"""
    try:
        base_path = sys._MEIPASS
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# Đường dẫn đến tesseract.exe và poppler
pytesseract.pytesseract.tesseract_cmd = resource_path('Tesseract-OCR/tesseract.exe')
poppler_path = resource_path('poppler-24.02.0/Library/bin')
tessdata_dir = resource_path('Tesseract-OCR/tessdata')
os.environ['TESSDATA_PREFIX'] = tessdata_dir

def detect_text_orientation(image):
    custom_config = r'--psm 0'
    osd_data = pytesseract.image_to_osd(image, config=custom_config)
    angle = 0
    for line in osd_data.split('\n'):
        if 'Rotate' in line:
            angle = int(line.split(':')[1].strip())
            break
    orientation = 'Portrait' if angle == 0 else \
                  'Landscape' if angle in (90, 270) else \
                  'Upside Down' if angle == 180 else 'Unknown'
    
    # Ensure the message can be printed
    return orientation, angle

def rotate_image(image, angle):
    rotations = {90: 270, 180: 180, 270: 90}
    return image.rotate(rotations.get(angle, 0), expand=True)

def preprocess_image(image_path):
    with Image.open(image_path) as img:
        new_size = (int(img.width * 2), int(img.height * 2))
        return img.resize(new_size, Image.Resampling.LANCZOS)

def process_pdf(pdf_path, output_pdf_path):
    images = convert_from_path(pdf_path, dpi=300, poppler_path=poppler_path)
    corrected_images = [rotate_image(img, detect_text_orientation(img)[1]) for img in images]
    if corrected_images:
        corrected_images[0].save(
            output_pdf_path, 
            save_all=True, 
            append_images=corrected_images[1:], 
            resolution=300.0, 
            quality=95
        )
    print("Done", file=sys.stdout)

def process_images(image_path, output_folder):
    img = preprocess_image(image_path)
    orientation, angle = detect_text_orientation(img)
    rotated_img = rotate_image(img, angle)
    output_path = os.path.join(output_folder, os.path.basename(image_path))
    rotated_img.save(output_path)
    print("Done", file=sys.stdout)

def process_files(file_paths, output_folder):
    for file_path in file_paths:
        if file_path.lower().endswith('.pdf'):
            output_pdf_path = os.path.join(output_folder, os.path.basename(file_path))
            process_pdf(file_path, output_pdf_path)
        elif file_path.lower().endswith(('.png', '.jpg', '.jpeg')):
            process_images(file_path, output_folder)
        else:
            print(f"File type not supported: {file_path}")

def main():
    if len(sys.argv) < 3:
        print("Usage: process_files.exe <output_folder> <file_paths...>")
        sys.exit(1)

    output_folder = sys.argv[1]
    file_paths = sys.argv[2:]

    os.makedirs(output_folder, exist_ok=True)
    process_files(file_paths, output_folder)
    print("Processing complete. Tất cả các ảnh đã được xoay đúng chìu.", file=sys.stdout)

if __name__ == "__main__":
    main()
