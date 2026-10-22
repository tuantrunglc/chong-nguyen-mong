#!/usr/bin/env python3
"""
Theo dõi, tải, và chuẩn hóa hoạt ảnh (Animations) cho các nhân vật:
1. Chờ các job PixelLab hoàn thành.
2. Tải từng khung hình hoạt ảnh (frames).
3. Lật hướng east -> west chuẩn pixel art.
4. Lượng tử hóa 100% Resurrect 64 & 1-bit alpha.
5. Tạo Spritesheet hoàn chỉnh (dòng = hướng, cột = frame).
6. Tạo ảnh GIF động xem trước chuyển động.
"""

import os, sys, time, json, urllib.request
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

OUT_ANIM_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh")
os.makedirs(OUT_ANIM_DIR, exist_ok=True)

# Load Resurrect 64
palette_rgb = []
with open(PALETTE_FILE) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith(("#", "GIMP", "Name", "Columns")):
            continue
        p = line.split()
        if len(p) >= 3:
            palette_rgb.append((int(p[0]), int(p[1]), int(p[2])))

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

def quantize_frame(im):
    im_rgba = im.convert("RGBA")
    arr = np.array(im_rgba)
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    opaque_mask = alpha >= 120
    out_alpha = np.where(opaque_mask, 255, 0).astype(np.uint8)
    rgb = arr[..., :3].astype(np.float32)
    pixels_to_q = rgb[opaque_mask]
    
    if len(pixels_to_q) > 0:
        lab_pixels = rgb_to_cielab(pixels_to_q)
        diff = lab_pixels[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_indices = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_indices].astype(np.uint8)
        
        lum = 0.299 * pixels_to_q[:, 0] + 0.587 * pixels_to_q[:, 1] + 0.114 * pixels_to_q[:, 2]
        dark_mask = (lum < 28) | ((pixels_to_q[:, 0] < 46) & (pixels_to_q[:, 1] < 46) & (pixels_to_q[:, 2] < 52))
        q_rgb[dark_mask] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque_mask] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        
    out_arr = np.dstack([out_rgb, out_alpha])
    return Image.fromarray(out_arr, mode="RGBA")

def wait_and_process_character(char_id, char_name, anim_name, expected_dirs):
    print(f"\n=== THEO DÕI HOẠT ẢNH: {char_name.upper()} ({anim_name}) ===")
    char_anim_dir = os.path.join(OUT_ANIM_DIR, f"{char_name}_{anim_name}")
    os.makedirs(char_anim_dir, exist_ok=True)
    
    for attempt in range(40):
        c_info = call("get_character", {"character_id": char_id})
        # Parse animations
        if "animations:" in c_info:
            anim_section = c_info.split("animations:")[1].split("download:")[0]
            # Check if animation is ready
            if anim_name in anim_section or "walking" in anim_section:
                print(f"Hoạt ảnh {anim_name} đã sẵn sàng trong get_character!")
                break
        print(f"[{attempt+1}/40] Đang chờ generation hoàn tất...")
        time.sleep(10)
        
    # Lấy thông tin chi tiết các frame từ get_character
    # Sau đó tải spritesheet từ URL
    sheet_url = f"https://api.pixellab.ai/mcp/characters/{char_id}/download"
    print(f"Thông tin nhân vật:\n{c_info[:500]}...")

if __name__ == "__main__":
    wait_and_process_character("17c58452-574e-449b-ac07-313596d9d02e", "khoai", "walking-4-frames", ["south", "east", "north"])
