#!/usr/bin/env python3
"""
Tải và tối ưu hóa toàn bộ 8 hướng của Cung kỵ Nguyên B6 (Mongol Horse Archer):
1. Theo dõi job PixelLab cde16945-9ae2-441f-a2e2-279cb5b683a6.
2. Tải đủ 8 hướng về img/pixellab-thu/cung_ky/.
3. Quy chuẩn 100% về Resurrect 64 (resurrect-64.gpl).
4. Khử triệt để màu đỏ (chuyển sang nâu da thuộc #4c3e24 / xám thép #625565).
5. Chuẩn hóa viền đen 1px #2e222f và khử orphan pixels.
6. Lưu ảnh tối ưu tại img/pixellab-thu/toi_uu/cung_ky/.
7. Tạo ảnh so sánh 8 hướng và ảnh đối chiếu hàng ngang 6 quân cờ hoàn chỉnh x4.
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
RAW_DIR = os.path.join(BASE_DIR, "cung_ky")
OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "cung_ky")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

CHAR_ID = "cde16945-9ae2-441f-a2e2-279cb5b683a6"
VALID_DIRECTIONS = ["south", "south-west", "west", "north-west", "north", "north-east", "east", "south-east"]

os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(OPT_DIR, exist_ok=True)

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
BROWN_LEATHER = (76, 62, 36, 255) # #4c3e24

def quantize_pixel(r, g, b, a):
    if a < 128:
        return (0, 0, 0, 0)
    
    # Khử đỏ
    if r > 115 and r > g * 1.35 and r > b * 1.35:
        r, g, b = BROWN_LEATHER[:3]
        
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 36 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR
    
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    
    # Check red avoidance
    RED_HEXES = [(232, 59, 59), (234, 79, 54), (174, 35, 52), (110, 39, 39), (179, 56, 49)]
    if (best_rgb[0], best_rgb[1], best_rgb[2]) in RED_HEXES:
        best_rgb = BROWN_LEATHER[:3]
        
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

def download_file(url, target_path):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=60) as response, open(target_path, 'wb') as out_file:
        out_file.write(response.read())

def wait_and_download():
    print(f"Kiểm tra job {CHAR_ID}...")
    for i in range(20):
        res = call("get_character", {"character_id": CHAR_ID})
        status_line = res.split("\n")[0]
        print(f" [{i+1}/20] {status_line}")
        if "completed" in status_line and "pending jobs" not in res:
            break
        if "completed" in status_line:
            # Check if all 8 directions in rotations exist
            count = sum(1 for d in VALID_DIRECTIONS if f"  {d}: https://" in res)
            if count == 8:
                print("Đã có đủ 8 hướng rotations!")
                break
        time.sleep(10)
        
    print("Job đã hoàn thành! Đang phân tích link tải...")
    lines = res.split("\n")
    download_map = {}
    in_rotations = False
    for line in lines:
        if line.strip().startswith("rotations:"):
            in_rotations = True
            continue
        if in_rotations and line and not line.startswith("  "):
            in_rotations = False
        if in_rotations:
            m = re.match(r"^\s*([a-z\-]+):\s*(https://\S+)", line)
            if m and m.group(1) in VALID_DIRECTIONS:
                download_map[m.group(1)] = m.group(2)
            
    print(f"Tìm thấy {len(download_map)} hướng: {list(download_map.keys())}")
    for dir_name, url in download_map.items():
        raw_path = os.path.join(RAW_DIR, f"{dir_name}.png")
        download_file(url, raw_path)
        print(f"  Đã tải: {dir_name}.png")
        
    return len(download_map) == 8

def optimize_all():
    sheet = Image.new("RGBA", (8 * 128, 2 * 128), (35, 30, 40, 255))
    
    for col, direction in enumerate(VALID_DIRECTIONS):
        raw_path = os.path.join(RAW_DIR, f"{direction}.png")
        if not os.path.exists(raw_path):
            print(f"Cảnh báo: không thấy {raw_path}")
            continue
        orig = Image.open(raw_path).convert("RGBA")
        
        w, h = orig.size
        opt = Image.new("RGBA", (w, h))
        opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in orig.getdata()]
        opt.putdata(opt_data)
        opt = clean_orphan_pixels(opt)
        
        opt_path = os.path.join(OPT_DIR, f"{direction}.png")
        opt.save(opt_path)
        
        orig_2x = orig.resize((128, 128), Image.NEAREST)
        opt_2x = opt.resize((128, 128), Image.NEAREST)
        sheet.paste(orig_2x, (col * 128, 0), orig_2x)
        sheet.paste(opt_2x, (col * 128, 128), opt_2x)
        
    sheet_p = os.path.join(OPT_DIR, "_so_sanh_cung_ky_8_huong.png")
    sheet.save(sheet_p)
    print(f"Đã lưu bảng so sánh 8 hướng tại: {sheet_p}")

def generate_six_units_comparison():
    scale = 4
    pad = 16
    w, h = 64 * scale, 64 * scale
    canvas = Image.new("RGBA", (pad + 6 * (w + pad), pad + h + pad), (30, 26, 35, 255))
    
    units = [
        ("Khoái (Đại Việt)", os.path.join(BASE_DIR, "toi_uu", "khoai", "south.png")),
        ("Lão (Đại Việt)", os.path.join(BASE_DIR, "toi_uu", "lao", "south.png")),
        ("Dư (Đại Việt)", os.path.join(BASE_DIR, "toi_uu", "du", "south.png")),
        ("Bộ binh v3 (Nguyên)", os.path.join(BASE_DIR, "toi_uu", "nguyen_v3", "south.png")),
        ("Kỵ binh B5 (Nguyên)", os.path.join(BASE_DIR, "toi_uu", "ky_binh", "south.png")),
        ("Cung kỵ B6 (Nguyên)", os.path.join(OPT_DIR, "south.png"))
    ]
    
    for i, (name, path) in enumerate(units):
        if os.path.exists(path):
            im = Image.open(path).convert("RGBA").resize((w, h), Image.NEAREST)
            canvas.paste(im, (pad + i * (w + pad), pad), im)
            print(f"  + Ghép {name} từ {path}")
        else:
            print(f"  - Thiếu ảnh: {path}")
            
    out_p = os.path.join(BASE_DIR, "toi_uu", "_so_sanh_sau_quan_v3_x4.png")
    canvas.save(out_p)
    print(f"Đã lưu ảnh đối chiếu 6 quân tại: {out_p}")

if __name__ == "__main__":
    if wait_and_download():
        optimize_all()
        generate_six_units_comparison()
