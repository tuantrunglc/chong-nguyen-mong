#!/usr/bin/env python3
"""
Tối ưu hóa sprite 3 vị tướng PixelLab theo quy chuẩn mỹ thuật:
1. Quy chuẩn 100% về bảng màu Resurrect 64 (resurrect-64.gpl).
2. Chuẩn hóa đường viền 1px màu chuẩn dự án: #2e222f.
3. Khử pixel mồ côi (orphan pixels / noise) và xóa triệt để semi-transparent alpha.
4. Đồng bộ màu áo đỏ Đại Việt cho Trần Khánh Dư trên tất cả các hướng (kế thừa kết quả south_ao_do.png).
5. Xuất ảnh so sánh Trước / Sau (Before & After) phóng to x2 để kiểm tra.
"""

import os, glob
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
OUTPUT_DIR = os.path.join(BASE_DIR, "toi_uu")

# 1. Load Resurrect 64
palette_rgb = []
with open(PALETTE_FILE) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith(("#", "GIMP", "Name", "Columns")):
            continue
        parts = line.split()
        if len(parts) >= 3:
            palette_rgb.append((int(parts[0]), int(parts[1]), int(parts[2])))

palette_arr = np.array(palette_rgb, dtype=np.float32)

def rgb_to_cielab(rgb):
    rgb = np.clip(rgb / 255.0, 0, 1)
    mask = rgb > 0.04045
    rgb_lin = np.where(mask, ((rgb + 0.055) / 1.055) ** 2.4, rgb / 12.92)
    matrix = np.array([
        [0.4124564, 0.3575761, 0.1804375],
        [0.2126729, 0.7151522, 0.0721750],
        [0.0193339, 0.1191920, 0.9503041]
    ])
    xyz = np.dot(rgb_lin, matrix.T)
    ref_white = np.array([0.95047, 1.00000, 1.08883])
    xyz = xyz / ref_white
    mask = xyz > 0.008856
    xyz_f = np.where(mask, xyz ** (1/3), 7.787 * xyz + 16/116)
    L = 116 * xyz_f[..., 1] - 16
    a = 500 * (xyz_f[..., 0] - xyz_f[..., 1])
    b = 200 * (xyz_f[..., 1] - xyz_f[..., 2])
    return np.stack([L, a, b], axis=-1)

lab_palette = rgb_to_cielab(palette_arr)

# Outline chuẩn #2e222f: (46, 34, 47, 255)
OUTLINE_COLOR = (46, 34, 47, 255)

# Bảng màu đỏ Đại Việt trong Resurrect 64
RED_DARK = (110, 39, 39, 255)    # #6e2727
RED_MID = (174, 35, 52, 255)     # #ae2334
RED_BRIGHT = (179, 56, 49, 255)  # #b33831
RED_SASH = (232, 59, 59, 255)    # #e83b3b

def quantize_pixel(r, g, b, a):
    if a < 128:
        return (0, 0, 0, 0)
    # Rất tối -> outline #2e222f
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 36 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR
    
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    return (best_rgb[0], best_rgb[1], best_rgb[2], 255)

def clean_orphan_pixels(im):
    """Khử điểm ảnh mồ côi (1 pixel đơn lẻ không có láng giềng cùng màu)."""
    w, h = im.size
    pix = im.load()
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            curr = pix[x, y]
            if curr[3] == 0:
                continue
            neighbors = [pix[x+dx, y+dy] for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]]
            # Nếu 4 phía xung quanh đều là transparent -> orphan pixel
            if all(n[3] == 0 for n in neighbors):
                pix[x, y] = (0, 0, 0, 0)
    return im

def enhance_du_red_tunic(im, is_south=False):
    """
    Trần Khánh Dư: Chuyển các mảng áo/quần màu xám than sang dải màu đỏ sẫm Đại Việt.
    Nếu là hướng south thì đã có south_ao_do.png làm mẫu chuẩn.
    Với các hướng khác: thay thế các tông xám than vùng thân thành tông đỏ sẫm.
    """
    w, h = im.size
    pix = im.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a == 0:
                continue
            # Vùng thân/chân (y từ 26 đến 52), loại trừ vũ khí/khuôn mặt/nón
            if 25 <= y <= 54:
                # Kiểm tra màu xám than / xám xanh (r, g, b gần nhau, lum trung bình)
                max_c = max(r, g, b)
                min_c = min(r, g, b)
                lum = 0.299 * r + 0.587 * g + 0.114 * b
                # Nếu là màu xám chì/xám lạnh của áo cũ (không phải giáp đen <35, không phải da người >150 và r>g>b)
                if (max_c - min_c < 28) and (40 <= lum <= 125):
                    # Chuyển sắc độ xám sang các cấp độ đỏ sẫm Đại Việt tương ứng
                    if lum < 65:
                        pix[x, y] = RED_DARK
                    elif lum < 95:
                        pix[x, y] = RED_MID
                    else:
                        pix[x, y] = RED_BRIGHT
    return im

DIRECTIONS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]

GENERALS = [
    {
        "name": "khoai",
        "title": "Nguyễn Khoái (Mạch đao)",
        "src_dir": os.path.join(BASE_DIR, "khoai_mach_dao"),
        "is_du": False
    },
    {
        "name": "lao",
        "title": "Phạm Ngũ Lão (Giáo đứng)",
        "src_dir": os.path.join(BASE_DIR, "lao_v3"),
        "is_du": False
    },
    {
        "name": "du",
        "title": "Trần Khánh Dư (Móc dài & Áo đỏ)",
        "src_dir": os.path.join(BASE_DIR, "du_v3"),
        "is_du": True
    }
]

def process_all():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Chuẩn bị ảnh tổng hợp Before & After (1024 x 768: 8 hướng x 6 hàng, mỗi ô 128x128 phóng x2)
    sheet_w = 8 * 128
    sheet_h = 6 * 128
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (35, 30, 40, 255)) # Nền tối nhẹ để thấy rõ viền
    
    row = 0
    for gen in GENERALS:
        gen_out = os.path.join(OUTPUT_DIR, gen["name"])
        os.makedirs(gen_out, exist_ok=True)
        print(f"Đang tối ưu: {gen['title']}...")
        
        for col, direction in enumerate(DIRECTIONS):
            # Chọn file nguồn
            if gen["is_du"] and direction == "south" and os.path.exists(os.path.join(gen["src_dir"], "south_ao_do.png")):
                src_path = os.path.join(gen["src_dir"], "south_ao_do.png")
            else:
                src_path = os.path.join(gen["src_dir"], f"{direction}.png")
            
            orig_im = Image.open(src_path).convert("RGBA")
            
            # Xử lý áo đỏ cho Trần Khánh Dư nếu chưa có
            work_im = orig_im.copy()
            if gen["is_du"] and direction != "south":
                work_im = enhance_du_red_tunic(work_im)
            
            # Lượng tử hóa từng pixel về Resurrect 64 & viền #2e222f
            w, h = work_im.size
            opt_im = Image.new("RGBA", (w, h))
            orig_data = work_im.getdata()
            opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in orig_data]
            opt_im.putdata(opt_data)
            
            # Khử orphan pixels
            opt_im = clean_orphan_pixels(opt_im)
            
            # Lưu file tối ưu 64x64
            dst_path = os.path.join(gen_out, f"{direction}.png")
            opt_im.save(dst_path)
            
            # Vẽ vào bảng so sánh phóng x2 (Before ở hàng row, After ở hàng row+1)
            orig_2x = orig_im.resize((128, 128), Image.NEAREST)
            opt_2x = opt_im.resize((128, 128), Image.NEAREST)
            sheet.paste(orig_2x, (col * 128, row * 128), orig_2x)
            sheet.paste(opt_2x, (col * 128, (row + 1) * 128), opt_2x)
            
        row += 2

    sheet_path = os.path.join(OUTPUT_DIR, "_so_sanh_truoc_sau.png")
    sheet.save(sheet_path)
    print(f"Đã lưu bảng so sánh Trước & Sau tại: {sheet_path}")

if __name__ == "__main__":
    process_all()
