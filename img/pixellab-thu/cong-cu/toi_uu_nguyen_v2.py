#!/usr/bin/env python3
"""
Tối ưu hóa sprite Quân Nguyên v2 theo quy chuẩn mỹ thuật:
1. Quy chuẩn 100% về bảng màu Resurrect 64 (resurrect-64.gpl).
2. Khử triệt để màu đỏ (chuyển các pixel đỏ/nâu đỏ sang nâu da thuộc #4c3e24 hoặc xám thép #625565).
3. Chuẩn hóa đường viền 1px: #2e222f.
4. Khử pixel mồ côi (orphan pixels) và đảm bảo alpha nhị phân tuyệt đối.
5. Căn chỉnh nhân vật vào khung 64x64 (đặt chân tại y=62, tâm x=32).
6. Tạo ảnh so sánh Trước / Sau để kiểm định.
"""

import os, glob
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
OUTPUT_DIR = os.path.join(BASE_DIR, "toi_uu", "nguyen_v2")

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

OUTLINE_COLOR = (46, 34, 47, 255) # #2e222f

# Màu thay thế cho các tông đỏ trên quân Nguyên (da thuộc và xám xanh)
BROWN_LEATHER_DARK = (76, 62, 36, 255)    # #4c3e24
BROWN_LEATHER_MID = (171, 148, 122, 255)  # #ab947a
SLATE_GREY = (98, 85, 101, 255)           # #625565

def quantize_pixel_nguyen(r, g, b, a):
    if a < 128:
        return (0, 0, 0, 0)
    
    # Khử màu đỏ trên quân Nguyên (đỏ dành riêng cho Đại Việt và ô báo đòn)
    if r > 115 and r > g * 1.35 and r > b * 1.35:
        # Chuyển sắc đỏ thành sắc da thuộc / nâu tối
        if r < 155:
            r, g, b = BROWN_LEATHER_DARK[:3]
        else:
            r, g, b = BROWN_LEATHER_MID[:3]
            
    # Viền tối -> #2e222f
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 36 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR
    
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    
    # Kiểm tra lần 2: nếu màu map ra là màu đỏ tươi (#e83b3b, #ea4f36, #ae2334, #6e2727), ép về nâu hoặc xám
    RED_HEXES = [(232, 59, 59), (234, 79, 54), (174, 35, 52), (110, 39, 39), (179, 56, 49)]
    if (best_rgb[0], best_rgb[1], best_rgb[2]) in RED_HEXES:
        best_rgb = BROWN_LEATHER_DARK[:3]
        
    return (best_rgb[0], best_rgb[1], best_rgb[2], 255)

def clean_orphan_pixels(im):
    w, h = im.size
    pix = im.load()
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            curr = pix[x, y]
            if curr[3] == 0:
                continue
            neighbors = [pix[x+dx, y+dy] for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]]
            if all(n[3] == 0 for n in neighbors):
                pix[x, y] = (0, 0, 0, 0)
    return im

def fit_to_64x64(im):
    """Căn chỉnh nhân vật 92x92 về khung 64x64 theo vị trí chân và tâm."""
    bbox = im.getbbox()
    if not bbox:
        return im
    
    # Tìm điểm chân thấp nhất
    foot_y = -1
    for y in range(im.size[1]-1, -1, -1):
        for x in range(im.size[0]):
            if im.getpixel((x, y))[3] > 0:
                foot_y = y
                break
        if foot_y != -1:
            break
            
    center_x = (bbox[0] + bbox[2]) // 2
    
    # Đích: chân tại y=62, tâm tại x=32
    target_foot_y = 62
    target_center_x = 32
    
    offset_x = target_center_x - center_x
    offset_y = target_foot_y - foot_y
    
    out_64 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            p = im.getpixel((x, y))
            if p[3] > 0:
                nx = x + offset_x
                ny = y + offset_y
                if 0 <= nx < 64 and 0 <= ny < 64:
                    out_64.putpixel((nx, ny), p)
    return out_64

def process_nguyen_v2():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    src_dir = os.path.join(BASE_DIR, "nguyen_v2")
    directions = ["south", "west", "north", "east"]
    
    # Chuẩn bị ảnh so sánh (4 cột x 2 hàng: Trước 92x92 phóng x2, Sau 64x64 phóng x2)
    sheet = Image.new("RGBA", (4 * 140, 2 * 140), (35, 30, 40, 255))
    
    for col, direction in enumerate(directions):
        src_path = os.path.join(src_dir, f"{direction}.png")
        if not os.path.exists(src_path):
            continue
        orig = Image.open(src_path).convert("RGBA")
        
        # 1. Quantize và làm sạch
        w, h = orig.size
        opt = Image.new("RGBA", (w, h))
        opt_data = [quantize_pixel_nguyen(r, g, b, a) for (r, g, b, a) in orig.getdata()]
        opt.putdata(opt_data)
        opt = clean_orphan_pixels(opt)
        
        # Lưu bản sạch 92x92
        opt.save(os.path.join(OUTPUT_DIR, f"{direction}_92.png"))
        
        # 2. Căn chỉnh về khung chuẩn 64x64
        opt_64 = fit_to_64x64(opt)
        opt_64.save(os.path.join(OUTPUT_DIR, f"{direction}.png"))
        
        # Vẽ vào sheet so sánh
        orig_disp = orig.resize((128, 128), Image.NEAREST)
        opt_disp = opt_64.resize((128, 128), Image.NEAREST)
        sheet.paste(orig_disp, (col * 140 + 6, 6), orig_disp)
        sheet.paste(opt_disp, (col * 140 + 6, 140 + 6), opt_disp)
        
    sheet_path = os.path.join(OUTPUT_DIR, "_so_sanh_truoc_sau.png")
    sheet.save(sheet_path)
    print(f"Đã tối ưu hóa Quân Nguyên v2 và lưu tại: {OUTPUT_DIR}")

if __name__ == "__main__":
    process_nguyen_v2()
