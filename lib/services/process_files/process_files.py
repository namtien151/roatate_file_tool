import sys
import os
import time
from pdf2image import convert_from_path
import pytesseract
from PIL import Image, ImageOps
from PyPDF2 import PdfReader, PdfWriter
from concurrent.futures import ThreadPoolExecutor, as_completed
import fitz

def resource_path(relative_path):
    """Lấy đường dẫn tài nguyên khi chạy từ tệp thực thi"""
    try:
        base_path = sys._MEIPASS
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# Đường dẫn đến tesseract.exe và poppler
pytesseract.pytesseract.tesseract_cmd = resource_path('Tesseract-OCR/tesseract.exe')
tessdata_dir = resource_path('Tesseract-OCR/tessdata')
os.environ['TESSDATA_PREFIX'] = tessdata_dir

def detect_text_orientation(image):
    start_time = time.time()
    
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
    
    end_time = time.time()
    print(f"detect_text_orientation took {end_time - start_time:.4f} seconds", file=sys.stdout)
    
    return orientation, angle

def rotate_image(image, angle):
    start_time = time.time()
    
    rotations = {90: 270, 180: 180, 270: 90}
    rotated_img = image.rotate(rotations.get(angle, 0), expand=True)
    
    end_time = time.time()
    print(f"rotate_image took {end_time - start_time:.4f} seconds", file=sys.stdout)
    
    return rotated_img

def preprocess_image(image_path):
    start_time = time.time()
    
    with Image.open(image_path) as img:
        new_size = (int(img.width * 2), int(img.height * 2))
        processed_img = img.resize(new_size, Image.Resampling.LANCZOS)
    
    end_time = time.time()
    print(f"preprocess_image took {end_time - start_time:.4f} seconds", file=sys.stdout)
    
    return processed_img

def convert_pdf_to_images(pdf_path, dpi=170):
    pdf_document = fitz.open(pdf_path)
    images = []
    for page_number in range(len(pdf_document)):
        page = pdf_document.load_page(page_number)
        pix = page.get_pixmap(matrix=fitz.Matrix(dpi / 72, dpi / 72))
        img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples)
        images.append(img)
    return images

def process_pdf(pdf_path, output_pdf_path):
    start_time = time.time()
    
    images = convert_pdf_to_images(pdf_path, dpi=170)
    print(f"convert pdf -------------> png {time.time() - start_time:.4f} seconds", file=sys.stdout)
    
    if images:
        first_image_orientation, first_image_angle = detect_text_orientation(images[0])
        corrected_images = [rotate_image(img, first_image_angle) for img in images]
        corrected_images[0].save(
            output_pdf_path, 
            save_all=True, 
            append_images=corrected_images[1:], 
            resolution=170.0, 
            quality=95
        )
    
    end_time = time.time()
    print(f"process_pdf took {end_time - start_time:.4f} seconds", file=sys.stdout)
    print("Done", file=sys.stdout)

def process_images(image_path, output_folder):
    start_time = time.time()
    
    img = preprocess_image(image_path)
    orientation, angle = detect_text_orientation(img)
    rotated_img = rotate_image(img, angle)
    output_path = os.path.join(output_folder, os.path.basename(image_path))
    rotated_img.save(output_path)
    
    end_time = time.time()
    print(f"process_images took {end_time - start_time:.4f} seconds", file=sys.stdout)
    print("Done", file=sys.stdout)

def process_file(file_path, output_folder):
    """Xử lý từng tệp đơn lẻ."""
    if file_path.lower().endswith('.pdf'):
        output_pdf_path = os.path.join(output_folder, os.path.basename(file_path))
        process_pdf(file_path, output_pdf_path)
    elif file_path.lower().endswith(('.png', '.jpg', '.jpeg')):
        process_images(file_path, output_folder)
    else:
        print(f"File type not supported: {file_path}")

def process_files(file_paths, output_folder):
    start_time = time.time()
    
    num_threads = os.cpu_count()
    with ThreadPoolExecutor(max_workers=num_threads) as executor:
        future_to_file = {executor.submit(process_file, file_path, output_folder): file_path for file_path in file_paths}
        for future in as_completed(future_to_file):
            file_path = future_to_file[future]
            try:
                future.result()  # Xử lý lỗi nếu có
            except Exception as exc:
                print(f'{file_path} generated an exception: {exc}')
    
    end_time = time.time()
    print(f"process_files took {end_time - start_time:.4f} seconds", file=sys.stdout)


def main():
    if len(sys.argv) < 3:
        print("Usage: process_files.exe <output_folder> <file_paths...>")
        sys.exit(1)

    output_folder = sys.argv[1]
    file_paths = sys.argv[2:]

    os.makedirs(output_folder, exist_ok=True)
    start_time = time.time()
    process_files(file_paths, output_folder)
    end_time = time.time()
    print(f"main took {end_time - start_time:.4f} seconds", file=sys.stdout)
    print("Processing complete. Tất cả các ảnh đã được xoay đúng chiều.", file=sys.stdout)

if __name__ == "__main__":
    main()
