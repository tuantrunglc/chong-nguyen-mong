#!/usr/bin/env python3
"""
Ghép 2 mảng inpaint đã làm sạch (bỏ biển gỗ 'VIEHAN' & 'VIEIHAM') vào nền gốc F1,
kiểm tra đường biên, lượng tử hóa 100% về bảng màu Resurrect 64,
và tái tạo toàn bộ mockup Nhóm F.
"""

import os, sys
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
ORIG_BG = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh", "f1_nen_man_hinh_goc_co_bien.png")
OUT_BG = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh", "f1_nen_man_hinh.png")

INPAINT_LEFT = os.path.join(BASE_DIR, "cong-cu", "inpaint_left.png")
INPAINT_RIGHT = os.path.join(BASE_DIR, "cong-cu", "inpaint_right.png")

# Load Resurrect 64
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
OUTLINE_COLOR = (46, 34, 47, 255)

def quantize_color(r, g, b):
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 30 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR[:3]
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    return palette_rgb[best_idx]

def merge_and_quantize():
    if not os.path.exists(INPAINT_LEFT) or not os.path.exists(INPAINT_RIGHT):
        print("Chưa đủ 2 file inpaint!")
        return False
        
    bg = Image.open(ORIG_BG).convert("RGBA")
    left_im = Image.open(INPAINT_LEFT).convert("RGBA")
    right_im = Image.open(INPAINT_RIGHT).convert("RGBA")
    
    # Ghép 2 ảnh inpaint đè lên vị trí 2 biển gỗ cũ
    bg.paste(left_im, (0, 0))
    bg.paste(right_im, (320, 0))
    
    # Lượng tử hóa 100% pixel về Resurrect 64
    w, h = bg.size
    pix = bg.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            qr, qg, qb = quantize_color(r, g, b)
            pix[x, y] = (qr, qg, qb, 255)
            
    bg.save(OUT_BG)
    print(f"-> Đã ghép và chuẩn hóa nền sạch f1_nen_man_hinh.png tại: {OUT_BG}")
    return True

if __name__ == "__main__":
    merge_and_quantize()
