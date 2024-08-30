import json
import sys
import os
from pdf2image import convert_from_path
import pytesseract
from PIL import Image
from PyPDF2 import PdfWriter
from concurrent.futures import ThreadPoolExecutor
import fitz

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

pytesseract.pytesseract.tesseract_cmd = resource_path('Tesseract-OCR/tesseract.exe')
tessdata_dir = resource_path('Tesseract-OCR/tessdata')
os.environ['TESSDATA_PREFIX'] = tessdata_dir

def detect_text_orientation(image):
    # small_image = image.resize((image.width // 2, image.height // 2), Image.Resampling.LANCZOS)
    custom_config = r'--psm 0 -l vie+eng'
    try:
        osd_data = pytesseract.image_to_osd(image, config=custom_config)
        angle = next((int(line.split(':')[1].strip()) for line in osd_data.split('\n') if 'Rotate' in line), 0)
    except pytesseract.TesseractError as e:
        angle = 0
    return angle

def rotate_image(image, angle):
    rotations = {90: 270, 180: 180, 270: 90}
    rotated_img = image.rotate(rotations.get(angle, 0), expand=True)
    return rotated_img

def convert_pdf_to_images(pdf_path, dpi=300):
    pdf_document = fitz.open(pdf_path)
    images = []
    for page_number in range(len(pdf_document)):
        page = pdf_document.load_page(page_number)
        pix = page.get_pixmap(matrix=fitz.Matrix(dpi / 72, dpi / 72))
        if pix.width == 0 or pix.height == 0:
            continue
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        images.append(img)
    return images

def has_text(image):
    try:
        resized_image = image.resize((image.width // 5, image.height // 5), Image.Resampling.LANCZOS)
        text = pytesseract.image_to_string(resized_image)
    except pytesseract.TesseractError as e:
        text = ""
    return bool(text.strip())

def process_pdf(pdf_path, output_pdf_path):
    images = convert_pdf_to_images(pdf_path, dpi=300)
    total_pages = len(images)
    if total_pages == 0:
        return

    corrected_images = []
    for i, img in enumerate(images):
        try:
            contains_text = has_text(img)
            if contains_text:
                angle = detect_text_orientation(img)
                if angle != 0:
                    img = rotate_image(img, angle)
            corrected_images.append(img)
        except Exception as e:
            corrected_images.append(img)
            continue
        
        # Tính toán và ghi nhận tiến độ
        progress = (i + 1) / total_pages * 100
        print(json.dumps({"progress": progress}), file=sys.stdout)
        sys.stdout.flush()


    if corrected_images:
        corrected_images[0].save(
            output_pdf_path,
            save_all=True,
            append_images=corrected_images[1:],
            resolution=200.0,
            quality=95
        )
    print("Done", file=sys.stdout)
    sys.stdout.flush()
    
def preprocess_image(image_path):
    with Image.open(image_path) as img:
        new_size = (int(img.width * 2), int(img.height * 2))
        return img.resize(new_size, Image.Resampling.LANCZOS)

def process_images(image_path, output_folder):
    try:
        # Mở và xử lý ảnh
        img = preprocess_image(image_path)
        
        # Phát hiện hướng và xoay ảnh
        angle = detect_text_orientation(img)
        if angle != 0:
            rotated_img = rotate_image(img, angle)
        else:
            rotated_img = img
        
        # Tạo đường dẫn lưu ảnh đã xử lý
        output_path = os.path.join(output_folder, os.path.basename(image_path))
        
        # Lưu ảnh đã xoay vào thư mục đầu ra
        rotated_img.save(output_path)
        
        print(f"Done", file=sys.stdout)
    except Exception as e:
        print(f"Error processing {image_path}: {e}", file=sys.stderr)



def process_file(file_path, output_folder):
    if file_path.lower().endswith('.pdf'):
        output_pdf_path = os.path.join(output_folder, os.path.basename(file_path))
        process_pdf(file_path, output_pdf_path)
    elif file_path.lower().endswith(('.png', '.jpg', '.jpeg')):
        process_images(file_path, output_folder)

def process_files(file_paths, output_folder):
    with ThreadPoolExecutor(max_workers=os.cpu_count()*2) as executor:
        executor.map(lambda file_path: process_file(file_path, output_folder), file_paths)

def main():
    if len(sys.argv) < 3:
        print("Usage: process_files.exe <output_folder> <file_paths...>")
        sys.exit(1)

    output_folder = sys.argv[1]
    file_paths = sys.argv[2:]

    os.makedirs(output_folder, exist_ok=True)
    process_files(file_paths, output_folder)

if __name__ == "__main__":
    main()
