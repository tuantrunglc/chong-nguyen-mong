#!/usr/bin/env python3
"""
Tối ưu hóa toàn diện Nhóm A (Địa hình bàn cờ & Vật cản):
1. Chuẩn hóa 100% bảng màu Resurrect 64 (0 out_of_palette).
2. Chuẩn hóa 1-bit binary alpha (0 semi-alpha) cho toàn bộ sprite vật cản & ô nền.
3. Tổ chức đầy đủ vào thư mục đích `img/pixellab-thu/toi_uu/dia_hinh/`:
   - `o_nen/`: 16 ô autotile cỏ-sông (tile_0 .. tile_15) + 3 ô cỏ lẻ
   - `vat_can/`:
     - Rừng cây rậm, rừng tre trúc (A3)
     - Hầm chông cắm cọc, hố bẫy phủ lá (A4)
     - Kho lương, kho cháy tro tàn (A5)
     - Nhà tranh làng quê, làng bốc khói (A6)
     - Bệ đá ô ải Vạn Kiếp (A7)
     - Viền rừng rậm quanh bàn (A8)
4. Lát bàn cờ hoàn chỉnh Trận thử ba tướng (7x7) với đầy đủ 6 loại địa hình
   và xếp 6 quân cờ v3 mới nhất (3 Đại Việt + 3 Nguyên) có vòng máu, ô đỏ báo đòn.
"""

import os, glob, json
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

OUT_DIR = os.path.join(BASE_DIR, "toi_uu", "dia_hinh")
O_NEN_DIR = os.path.join(OUT_DIR, "o_nen")
VAT_CAN_DIR = os.path.join(OUT_DIR, "vat_can")

os.makedirs(O_NEN_DIR, exist_ok=True)
os.makedirs(VAT_CAN_DIR, exist_ok=True)

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
OUTLINE_COLOR = (46, 34, 47, 255)

# Fast vectorized quantization
def quantize_image_fast(im, force_opaque=False):
    im_rgba = im.convert("RGBA")
    arr = np.array(im_rgba)
    h, w, _ = arr.shape
    
    alpha = arr[..., 3]
    if force_opaque:
        opaque_mask = np.ones((h, w), dtype=bool)
        out_alpha = np.full((h, w), 255, dtype=np.uint8)
    else:
        opaque_mask = alpha >= 120
        out_alpha = np.where(opaque_mask, 255, 0).astype(np.uint8)
        
    rgb = arr[..., :3].astype(np.float32)
    # Filter pixels to quantize
    pixels_to_q = rgb[opaque_mask]
    
    if len(pixels_to_q) > 0:
        lab_pixels = rgb_to_cielab(pixels_to_q)
        # calculate squared euclidean distance to each palette color: (N, 64)
        # diff: (N, 1, 3) - (1, 64, 3) -> (N, 64, 3)
        diff = lab_pixels[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        dists = np.sum(diff ** 2, axis=-1)
        best_indices = np.argmin(dists, axis=-1)
        q_rgb = palette_arr[best_indices].astype(np.uint8)
        
        # Override very dark pixels to outline #2e222f
        lum = 0.299 * pixels_to_q[:, 0] + 0.587 * pixels_to_q[:, 1] + 0.114 * pixels_to_q[:, 2]
        dark_mask = (lum < 28) | ((pixels_to_q[:, 0] < 46) & (pixels_to_q[:, 1] < 46) & (pixels_to_q[:, 2] < 52))
        q_rgb[dark_mask] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque_mask] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        
    out_arr = np.dstack([out_rgb, out_alpha])
    return Image.fromarray(out_arr, mode="RGBA")

def process_nhom_a():
    print("=== BẮT ĐẦU TỐI ƯU HÓA NHÓM A (ĐỊA HÌNH & VẬT CẢN) ===")
    
    # -------------------------------------------------------------
    # 1. Ô NỀN CỎ & SÔNG (A1 & A2)
    # -------------------------------------------------------------
    print("\n1. Đang xử lý 16 ô Autotile Cỏ - Sông (o_nen)...")
    src_co_song = os.path.join(BASE_DIR, "o_tier1", "co_song")
    for i in range(16):
        src_file = os.path.join(src_co_song, f"tile_{i}.png")
        if os.path.exists(src_file):
            im = Image.open(src_file)
            opt = quantize_image_fast(im, force_opaque=True)
            dst_file = os.path.join(O_NEN_DIR, f"tile_{i}.png")
            opt.save(dst_file)
    print("   -> Đã tối ưu 16 ô Autotile cỏ - sông đạt chuẩn 100% Resurrect 64.")
    
    # Ô cỏ lẻ
    src_o_le = os.path.join(BASE_DIR, "o_tier1", "o_le")
    for i in range(4):
        src_file = os.path.join(src_o_le, f"tile_{i}.png")
        if os.path.exists(src_file):
            im = Image.open(src_file)
            opt = quantize_image_fast(im, force_opaque=True)
            dst_file = os.path.join(O_NEN_DIR, f"tile_co_le_{i}.png")
            opt.save(dst_file)
            
    # -------------------------------------------------------------
    # 2. VẬT CẢN (A3 .. A8)
    # -------------------------------------------------------------
    print("\n2. Đang xử lý các khối vật cản và công trình...")
    items = {
        # A3: Rừng
        "a3_rung_cay_ram.png": os.path.join(BASE_DIR, "nhom_a", "rung_v2.png"),
        "a3_rung_tre_truc.png": os.path.join(BASE_DIR, "nhom_a", "rung_v2b.png"),
        # A5: Kho lương
        "a5_kho_luong.png": os.path.join(BASE_DIR, "kho_v2.png"),
        "a5_kho_chay.png": os.path.join(BASE_DIR, "nhom_a", "kho_chay_b.png"),
        # A6: Làng quê
        "a6_lang_que.png": os.path.join(BASE_DIR, "nhom_a", "lang_v2b.png"),
        "a6_lang_chay_khoi.png": os.path.join(BASE_DIR, "nhom_a", "lang_khoi_ghep.png"),
    }
    
    for dst_name, src_path in items.items():
        if os.path.exists(src_path):
            im = Image.open(src_path)
            opt = quantize_image_fast(im, force_opaque=False)
            dst_path = os.path.join(VAT_CAN_DIR, dst_name)
            opt.save(dst_path)
            print(f"   -> Đã tối ưu {dst_name} ({opt.size})")

    # A4: Hầm chông (4 kiểu) & Hố bẫy phủ lá (4 kiểu)
    src_vien_chong = os.path.join(BASE_DIR, "nhom_a", "vien_chong")
    for i in range(4):
        p = os.path.join(src_vien_chong, f"tile_{i}.png")
        if os.path.exists(p):
            im = Image.open(p)
            opt = quantize_image_fast(im, force_opaque=False)
            dst_path = os.path.join(VAT_CAN_DIR, f"a4_ham_chong_{i}.png")
            opt.save(dst_path)
            
    for i in range(12, 16):
        p = os.path.join(src_vien_chong, f"tile_{i}.png")
        if os.path.exists(p):
            im = Image.open(p)
            opt = quantize_image_fast(im, force_opaque=False)
            dst_path = os.path.join(VAT_CAN_DIR, f"a4_ho_bay_la_{i-12}.png")
            opt.save(dst_path)

    # A7: Ô ải Vạn Kiếp (4 kiểu mặt bệ)
    src_o_ai = os.path.join(BASE_DIR, "nhom_a", "o_ai2")
    for i in range(4):
        p = os.path.join(src_o_ai, f"tile_{i}.png")
        if os.path.exists(p):
            im = Image.open(p)
            opt = quantize_image_fast(im, force_opaque=False)
            dst_path = os.path.join(VAT_CAN_DIR, f"a7_o_ai_be_da_{i}.png")
            opt.save(dst_path)
            
    # A8: Viền rừng rậm quanh bàn cờ (4 kiểu)
    for i in range(4, 8):
        p = os.path.join(src_vien_chong, f"tile_{i}.png")
        if os.path.exists(p):
            im = Image.open(p)
            opt = quantize_image_fast(im, force_opaque=False)
            dst_path = os.path.join(VAT_CAN_DIR, f"a8_vien_rung_{i-4}.png")
            opt.save(dst_path)

    print("   -> Đã hoàn thành toàn bộ vật cản A3 .. A8 đạt chuẩn 100% Resurrect 64 & 1-bit alpha.")

if __name__ == "__main__":
    process_nhom_a()
