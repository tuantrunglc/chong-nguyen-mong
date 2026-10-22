#!/usr/bin/env python3
"""
Điều chỉnh hệ thống thuyền chiến theo đúng chuẩn lịch sử Đại Việt:
1. Đại Việt không có thuyền lớn cồng kềnh. Thủy quân Đại Việt lấy nhỏ thắng lớn, lấy cơ động thắng cồng kềnh.
2. Thuyền chỉ huy của Trần Khánh Dư là Thuyền Soái Mông Đồng (64x64, 1 ô), có Soái kỳ đỏ viền vàng phất phới.
3. Thuyền lớn 2 ô (64x128) ĐỘC QUYỀN cho Chiến hạm Nguyên Mông (Đại hạm Ô Mã Nhi / thuyền lớn đáy sâu mắc cạn).
4. Xóa bỏ soai_ham_dai_viet_64x128.png.
5. Cập nhật đại bảng tổng hợp và tài liệu.
"""

import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
OUT_THUYEN_DIR = os.path.join(BASE_DIR, "toi_uu", "thuyen")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")

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

def quantize_im(im):
    arr = np.array(im.convert("RGBA"))
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    opaque = alpha >= 120
    out_alpha = np.where(opaque, 255, 0).astype(np.uint8)
    rgb = arr[..., :3].astype(np.float32)
    px = rgb[opaque]
    if len(px) > 0:
        lab_px = rgb_to_cielab(px)
        diff = lab_px[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_idx = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_idx].astype(np.uint8)
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 28) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 52))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

# 1. Tạo Thuyền Soái Mông Đồng Đại Việt (64x64, 1 ô):
base_p = os.path.join(OUT_THUYEN_DIR, "thuyen_chien_dai_viet.png")
soai_im = Image.open(base_p).copy()
arr = np.array(soai_im)

# Màu Resurrect 64
RED = (184, 52, 60, 255)     # #b8343c - Đỏ cờ Đại Việt
GOLD = (251, 185, 84, 255)   # #fbb954 - Vàng kim viền cờ
POLE = (138, 72, 54, 255)    # Cán cờ gỗ
OUTL = (46, 34, 47, 255)     # Outline

# Cột cờ ở đuôi thuyền (x=48, y=6..24)
for y in range(8, 22):
    arr[y, 48] = np.array(POLE)
    arr[y, 47] = np.array(OUTL)
    arr[y, 49] = np.array(OUTL)
# Đỉnh cọc đồng
arr[7, 48] = np.array(GOLD)
arr[6, 48] = np.array(GOLD)

# Lá cờ đỏ thêu viền vàng bay về bên phải (x=49..60, y=9..18)
# Dáng cờ tam giác đuôi nheo Đại Việt
for y in range(9, 17):
    width_flag = 10 - (y - 9)
    for x in range(49, 49 + width_flag):
        if x == 49 + width_flag - 1 or y == 9 or y == 16:
            arr[y, x] = np.array(GOLD) # Viền vàng
        else:
            arr[y, x] = np.array(RED)  # Lòng cờ đỏ
            
# Outline bao quanh cờ
for y in range(8, 18):
    width_flag = 11 - max(0, y - 9)
    x_edge = 49 + width_flag
    if x_edge < 64:
        arr[y, x_edge] = np.array(OUTL)

soai_final = quantize_im(Image.fromarray(arr))
soai_path = os.path.join(OUT_THUYEN_DIR, "thuyen_soai_mong_dong_dai_viet.png")
soai_final.save(soai_path)
print(f"Đã tạo Thuyền Soái Mông Đồng 64x64: {soai_path}")

# Xóa soai_ham_dai_viet_64x128.png nếu tồn tại
old_soai_128 = os.path.join(OUT_THUYEN_DIR, "soai_ham_dai_viet_64x128.png")
if os.path.exists(old_soai_128):
    os.remove(old_soai_128)
    print("Đã xóa bỏ soai_ham_dai_viet_64x128.png (không dùng thuyền lớn cho Đại Việt).")

# 2. Tạo lại Bảng Tổng Hợp Thuyền Chiến chuẩn lịch sử:
font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()

total_w = 760
total_h = 760
pad = 16

board = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
draw = ImageDraw.Draw(board)

draw.text((pad, 14), "ĐẠI TỔNG HỢP HỆ THỐNG THỦY CHIẾN ĐẠI VIỆT (CHUẨN LỊCH SỬ THỜI TRẦN)", fill=(255, 230, 150), font=font)
draw.text((pad, 34), "Đại Việt dùng thuyền nhỏ cơ động (1 ô) — Thuyền lớn cồng kềnh (2 ô) độc quyền cho quân Nguyên", fill=(180, 200, 220), font=font_sub)

# HÀNG 1: Thuyền chiến cơ bản (y=64)
y1 = 64
draw.text((pad, y1), "1. THUYỀN CHIẾN CƠ ĐỘNG (64×64 PX — 1 Ô BÀN CỜ)", fill=(255, 215, 120), font=font)
row1_list = [
    ("thuyen_chien_dai_viet.png", "Thuyền Mông Đồng (Đại Việt)", "Đáy nông, lướt nhanh, luồn lách"),
    ("thuyen_soai_mong_dong_dai_viet.png", "Thuyền Soái Trần Khánh Dư", "Thuyền Mông Đồng cắm Soái kỳ"),
    ("thuyen_chien_nguyen.png", "Chiến thuyền Nguyên Mông", "Buồm xám, hàng khiên mạn")
]
for i, (fn, title, desc) in enumerate(row1_list):
    p = os.path.join(OUT_THUYEN_DIR, fn)
    if os.path.exists(p):
        im = Image.open(p).resize((96, 96), Image.NEAREST)
        x = pad + i * 240
        board.paste(im, (x, y1 + 22), im)
        draw.text((x, y1 + 122), title, fill=(200, 240, 220), font=font_sub)
        draw.text((x, y1 + 138), desc, fill=(160, 180, 200), font=font_sub)

# HÀNG 2: Tác chiến Cháy & Đắm cọc (y=230)
y2 = 230
draw.text((pad, y2), "2. TÁC CHIẾN BẠCH ĐẰNG & VÂN ĐỒN (64×64 PX)", fill=(255, 215, 120), font=font)
row2_list = [
    ("thuyen_dam_coc_bach_dang.png", "Thuyền Nguyên cắm cọc", "Mắc cạn, mạn vỡ toác khi triều rút"),
    ("thuyen_tai_luong_chay.png", "Thuyền lương Trương Văn Hổ cháy", "17 vạn thạch lương bị đốt sạch"),
    ("thuyen_chien_nguyen_chay.png", "Chiến thuyền trúng hỏa công", "Buồm rách, lửa thiêu rụi hạm đội")
]
for i, (fn, title, desc) in enumerate(row2_list):
    p = os.path.join(OUT_THUYEN_DIR, fn)
    if os.path.exists(p):
        im = Image.open(p).resize((96, 96), Image.NEAREST)
        x = pad + i * 240
        board.paste(im, (x, y2 + 22), im)
        draw.text((x, y2 + 122), title, fill=(255, 140, 140), font=font_sub)
        draw.text((x, y2 + 138), desc, fill=(180, 160, 160), font=font_sub)

# HÀNG 3: Chiến hạm lớn quân Nguyên 64x128 (y=400)
y3 = 400
draw.text((pad, y3), "3. CHIẾN HẠM HẠNG NẶNG QUÂN NGUYÊN (64×128 PX — DÀI 2 Ô BÀN CỜ)", fill=(255, 215, 120), font=font)
p_cap = os.path.join(OUT_THUYEN_DIR, "soai_ham_nguyen_64x128.png")
if os.path.exists(p_cap):
    im_cap = Image.open(p_cap).resize((70, 140), Image.NEAREST)
    board.paste(im_cap, (pad + 40, y3 + 22), im_cap)
    
draw.text((pad + 130, y3 + 40), "Đại Hạm Chỉ Huy Ô Mã Nhi (Nguyên Mông - 64×128 px)", fill=(255, 230, 160), font=font)
draw.text((pad + 130, y3 + 64), "• Thân thuyền bọc giáp gỗ kiên cố, tháp canh lầu tên, buồm xám xanh lớn.", fill=(200, 200, 210), font=font_sub)
draw.text((pad + 130, y3 + 82), "• Mục tiêu to lớn, chậm chạp — điểm yếu chí mạng khi thủy triều rút ở Bạch Đằng.", fill=(255, 180, 150), font=font_sub)
draw.text((pad + 130, y3 + 100), "• Tôn vinh chiến thuật 'Lấy nhỏ thắng lớn, lấy đoản chế trường' của nhà Trần.", fill=(150, 230, 180), font=font_sub)

# HÀNG 4: Hoạt ảnh chèo thuyền lướt sóng (y=580)
y4 = 580
draw.text((pad, y4), "4. HOẠT ẢNH THUYỀN MÔNG ĐỒNG CHÈO LƯỚT SÓNG (4 FRAMES)", fill=(255, 215, 120), font=font)
for i in range(4):
    p = os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_{i}.png")
    if os.path.exists(p):
        im = Image.open(p).resize((96, 96), Image.NEAREST)
        x = pad + i * 180
        board.paste(im, (x, y4 + 22), im)
        draw.text((x + 24, y4 + 122), f"Frame {i}", fill=(180, 220, 255), font=font_sub)

out_grand = os.path.join(OUT_THUYEN_DIR, "_tong_hop_toan_bo_thuyen_chien.png")
board.save(out_grand)
print(f"Đã cập nhật Đại bảng tổng hợp chuẩn lịch sử: {out_grand}")
