#!/usr/bin/env python3
"""
Tạo bộ Asset bổ sung chuyên sâu cho Game (Chuẩn Resurrect 64, 1-bit alpha, pixel-art):
1. Bóng đổ (Drop Shadows): Dithered checkerboard 1-bit alpha (quân cờ 32x16, vật cản 48x24)
2. Bộ số chiến đấu Pixel Art (Combat Numbers 0-9 & ký hiệu): Khổ lớn 12x16 & Khổ nhỏ 8x10
3. Chỉ báo chiến thuật ô cờ: Mũi tên xung phong 4 hướng, Khung chọn tướng, Khung ô đi được, Khung ô đánh được
4. Vệt chém Mạch đao (Slash Arc VFX 48x48, 4 frames + GIF preview)
5. Triện ấn Thắng / Bại: "ĐẠI THẮNG" (son đỏ vàng kim) & "THẤT THỦ" (tro tàn nứt vỡ)
6. Hoạt ảnh rơi sông (Drown) cho Kỵ binh & Cung kỵ (4 frames + GIF preview)
7. Khung viền sa bàn bàn cờ gỗ lim viền đồng (Board border 9-slice pieces)
"""

import os, sys, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

OUT_DIR = os.path.join(BASE_DIR, "toi_uu")

# Subdirectories
DIR_SHADOWS = os.path.join(OUT_DIR, "giao_dien", "bong_do")
DIR_NUMBERS = os.path.join(OUT_DIR, "giao_dien", "chu_so")
DIR_GRID = os.path.join(OUT_DIR, "giao_dien", "o_co")
DIR_BADGES = os.path.join(OUT_DIR, "giao_dien", "trien_an")
DIR_SLASH = os.path.join(OUT_DIR, "hieu_ung", "vet_chem")
DIR_DROWN_KB = os.path.join(OUT_DIR, "hoat_anh", "chet_duoi", "ky_binh")
DIR_DROWN_CK = os.path.join(OUT_DIR, "hoat_anh", "chet_duoi", "cung_ky")
DIR_BORDER = os.path.join(OUT_DIR, "dia_hinh", "khung_ban_co")

for d in [DIR_SHADOWS, DIR_NUMBERS, DIR_GRID, DIR_BADGES, DIR_SLASH, DIR_DROWN_KB, DIR_DROWN_CK, DIR_BORDER]:
    os.makedirs(d, exist_ok=True)

# 1. Load Resurrect 64
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

def quantize_im(im, is_opaque=False):
    arr = np.array(im.convert("RGBA"))
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    if is_opaque:
        opaque = np.ones((h, w), dtype=bool)
        out_alpha = np.full((h, w), 255, dtype=np.uint8)
    else:
        opaque = alpha >= 120
        out_alpha = np.where(opaque, 255, 0).astype(np.uint8)
        
    rgb = arr[..., :3].astype(np.float32)
    px = rgb[opaque]
    if len(px) > 0:
        lab_px = rgb_to_cielab(px)
        diff = lab_px[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_idx = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_idx].astype(np.uint8)
        
        # Keep dark outline dark
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

def save_gif(frames, out_path, duration=180):
    if not frames:
        return
    q_frames = [quantize_im(f) for f in frames]
    # Convert RGBA to P with palette for clean GIF
    pal_img = Image.new("P", (1, 1))
    pal_flat = []
    for c in palette_rgb:
        pal_flat.extend(c)
    while len(pal_flat) < 768:
        pal_flat.extend([0, 0, 0])
    pal_img.putpalette(pal_flat)
    
    gif_frames = []
    for f in q_frames:
        rgba = np.array(f)
        # find matching indices
        p_frame = Image.new("P", f.size, 0)
        # map rgb to index
        for y in range(f.height):
            for x in range(f.width):
                if rgba[y, x, 3] >= 128:
                    col = tuple(rgba[y, x, :3])
                    try:
                        idx = palette_rgb.index(col)
                    except ValueError:
                        idx = 0
                    p_frame.putpixel((x, y), idx)
                else:
                    p_frame.putpixel((x, y), 255) # transparent
        p_frame.putpalette(pal_flat[:765] + [0, 0, 0])
        gif_frames.append(p_frame)
        
    gif_frames[0].save(
        out_path, save_all=True, append_images=gif_frames[1:],
        duration=duration, loop=0, transparency=255, disposal=2
    )

print("=== 1. TẠO BÓNG ĐỔ DITHER CHÂN THỰC (DROP SHADOWS) ===")
# 32x16 cho quân cờ, 48x24 cho vật cản
def make_dither_shadow(w, h, out_path):
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    cx, cy = w / 2.0, h / 2.0
    rx, ry = (w - 2) / 2.0, (h - 2) / 2.0
    shadow_col = (46, 34, 47, 255) # #2e222f lacquer black
    
    for y in range(h):
        for x in range(w):
            dx = (x + 0.5 - cx) / rx
            dy = (y + 0.5 - cy) / ry
            dist = dx*dx + dy*dy
            if dist <= 1.0:
                # 50% dither: (x + y) % 2 == 0
                # center 70% solid if very close
                if dist < 0.35:
                    im.putpixel((x, y), shadow_col)
                elif (x + y) % 2 == 0:
                    im.putpixel((x, y), shadow_col)
    im = quantize_im(im)
    im.save(out_path)
    print(f"  -> {os.path.basename(out_path)} ({w}x{h})")

make_dither_shadow(32, 16, os.path.join(DIR_SHADOWS, "bong_do_quan_32x16.png"))
make_dither_shadow(48, 24, os.path.join(DIR_SHADOWS, "bong_do_vat_can_48x24.png"))


print("\n=== 2. TẠO BỘ SỐ PIXEL ART CHIẾN ĐẤU (COMBAT NUMBERS 0-9) ===")
# Số to: 12x16 viền đen dày, ruột vàng kim ánh cam (cực nổi trên nền đỏ báo đòn)
# Số nhỏ: 8x10 viền đen, ruột trắng kem/vàng sáng (cho máu ♥ 3/3, HUD)
font_large = ImageFont.truetype(FONT_FILE, 13)
font_small = ImageFont.truetype(FONT_FILE, 9)

# Ký tự cần vẽ
chars_large = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "dot", "dash", "cross"]
char_map_l = {"dot": "·", "dash": "-", "cross": "×"}

sheet_w = 12 * len(chars_large)
sheet_large = Image.new("RGBA", (sheet_w, 16), (0, 0, 0, 0))

for i, key in enumerate(chars_large):
    c = char_map_l.get(key, key)
    im = Image.new("RGBA", (12, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    
    # Draw thick black outline
    for ox in [-1, 0, 1]:
        for oy in [-1, 0, 1]:
            d.text((3 + ox, 0 + oy), c, font=font_large, fill=(46, 34, 47, 255))
    # Draw bright yellow/gold interior with orange shadow
    d.text((3, 0), c, font=font_large, fill=(247, 228, 118, 255))
    
    q_im = quantize_im(im)
    q_im.save(os.path.join(DIR_NUMBERS, f"so_to_{key}.png"))
    sheet_large.paste(q_im, (i * 12, 0))

quantize_im(sheet_large).save(os.path.join(DIR_NUMBERS, "so_to_sheet_156x16.png"))
print("  -> Đã tạo 13 số to (12x16) và spritesheet so_to_sheet_156x16.png")

chars_small = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "slash", "plus", "minus"]
char_map_s = {"slash": "/", "plus": "+", "minus": "-"}
sheet_s_w = 8 * len(chars_small)
sheet_small = Image.new("RGBA", (sheet_s_w, 10), (0, 0, 0, 0))

for i, key in enumerate(chars_small):
    c = char_map_s.get(key, key)
    im = Image.new("RGBA", (8, 10), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for ox in [-1, 0, 1]:
        for oy in [-1, 0, 1]:
            d.text((2 + ox, -1 + oy), c, font=font_small, fill=(46, 34, 47, 255))
    d.text((2, -1), c, font=font_small, fill=(255, 255, 255, 255))
    q_im = quantize_im(im)
    q_im.save(os.path.join(DIR_NUMBERS, f"so_nho_{key}.png"))
    sheet_small.paste(q_im, (i * 8, 0))

quantize_im(sheet_small).save(os.path.join(DIR_NUMBERS, "so_nho_sheet_104x10.png"))
print("  -> Đã tạo 13 số nhỏ (8x10) và spritesheet so_nho_sheet_104x10.png")


print("\n=== 3. TẠO CHỈ BÁO CHIẾN THUẬT Ô CỜ (TACTICAL GRID OVERLAYS) ===")
# 3.1 Mũi tên xung phong Kỵ binh (Bắc, Đông, Nam, Tây) - 64x64
def make_charge_arrow(direction):
    im = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    
    # Mũi tên đỏ rực nhọn viền đen
    # Điểm gốc vẽ hướng Bắc rồi xoay
    base_arrow = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    bd = ImageDraw.Draw(base_arrow)
    
    # Arrow head (pointing North)
    # Outline
    bd.polygon([(32, 8), (48, 30), (38, 30), (38, 54), (26, 54), (26, 30), (16, 30)], fill=(46, 34, 47, 255))
    # Interior Red & Orange
    bd.polygon([(32, 11), (45, 28), (36, 28), (36, 52), (28, 52), (28, 28), (19, 28)], fill=(213, 60, 42, 255))
    # Chevron stripes
    bd.polygon([(32, 14), (41, 26), (36, 26), (32, 20), (28, 26), (23, 26)], fill=(251, 185, 84, 255))
    
    rot_map = {"bac": 0, "dong": 270, "nam": 180, "tay": 90}
    res = base_arrow.rotate(rot_map[direction], resample=Image.NEAREST)
    return quantize_im(res)

for direct in ["bac", "dong", "nam", "tay"]:
    p = os.path.join(DIR_GRID, f"mui_ten_xung_phong_{direct}.png")
    make_charge_arrow(direct).save(p)
    print(f"  -> {os.path.basename(p)}")

# 3.2 Khung chọn tướng 64x64 (Corner brackets vàng đồng sơn mài)
im_sel = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
d = ImageDraw.Draw(im_sel)
gold = (251, 185, 84, 255)
dark = (46, 34, 47, 255)
corners = [
    (2, 2, 1, 1),
    (61, 2, -1, 1),
    (2, 61, 1, -1),
    (61, 61, -1, -1)
]
for x, y, dx, dy in corners:
    # 12px horizontal and vertical arms
    for i in range(12):
        im_sel.putpixel((x + i*dx, y), dark)
        im_sel.putpixel((x + i*dx, y + dy), gold)
        im_sel.putpixel((x + i*dx, y + 2*dy), dark)
        
        im_sel.putpixel((x, y + i*dy), dark)
        im_sel.putpixel((x + dx, y + i*dy), gold)
        im_sel.putpixel((x + 2*dx, y + i*dy), dark)

quantize_im(im_sel).save(os.path.join(DIR_GRID, "khung_chon_tuong_64x64.png"))
print("  -> khung_chon_tuong_64x64.png")

# 3.3 Khung ô đi được 64x64 (Xanh ngọc lãng mạn dithered)
im_move = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
teal = (68, 193, 181, 255)
teal_d = (47, 135, 127, 255)
for x in range(64):
    for y in range(64):
        # 2px border + 50% dither interior
        if x in [1, 62] or y in [1, 62]:
            im_move.putpixel((x, y), dark)
        elif x in [2, 61] or y in [2, 61]:
            im_move.putpixel((x, y), teal)
        elif x > 2 and x < 61 and y > 2 and y < 61:
            if (x % 4 == 0 and y % 4 == 0):
                im_move.putpixel((x, y), teal_d)

quantize_im(im_move).save(os.path.join(DIR_GRID, "khung_o_di_duoc_64x64.png"))
print("  -> khung_o_di_duoc_64x64.png")

# 3.4 Khung ô đánh được 64x64 (Viền đỏ đồng nhọn)
im_atk = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
red = (213, 60, 42, 255)
orange = (236, 71, 0, 255)
for x, y, dx, dy in corners:
    for i in range(14):
        im_atk.putpixel((x + i*dx, y), dark)
        im_atk.putpixel((x + i*dx, y + dy), red)
        im_atk.putpixel((x, y + i*dy), dark)
        im_atk.putpixel((x + dx, y + i*dy), red)
# Central crosshair dot
for cx in [31, 32]:
    for cy in [31, 32]:
        im_atk.putpixel((cx, cy), red)
im_atk.putpixel((31, 28), orange); im_atk.putpixel((32, 28), orange)
im_atk.putpixel((31, 35), orange); im_atk.putpixel((32, 35), orange)
im_atk.putpixel((28, 31), orange); im_atk.putpixel((28, 32), orange)
im_atk.putpixel((35, 31), orange); im_atk.putpixel((35, 32), orange)

quantize_im(im_atk).save(os.path.join(DIR_GRID, "khung_o_danh_duoc_64x64.png"))
print("  -> khung_o_danh_duoc_64x64.png")


print("\n=== 4. TẠO VỆT CHÉM MẠCH ĐAO (SLASH ARC VFX 48x48) ===")
# 4 frames thể hiện đòn chém sấm sét đẩy lùi của Nguyễn Khoái
slash_frames = []
for f_idx in range(4):
    im = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    cx, cy = 24, 24
    
    if f_idx == 0:
        # Start flash point: tia chớp nhỏ
        d.ellipse([cx-4, cy-4, cx+4, cy+4], fill=(255, 255, 255, 255), outline=(251, 185, 84, 255))
        d.line([cx-8, cy, cx+8, cy], fill=(247, 228, 118, 255), width=2)
        d.line([cx, cy-8, cx, cy+8], fill=(247, 228, 118, 255), width=2)
    elif f_idx == 1:
        # Strong arc slash cutting diagonally from top-right to bottom-left
        d.arc([6, 6, 42, 42], start=-70, end=110, fill=(46, 34, 47, 255), width=7)
        d.arc([8, 8, 40, 40], start=-65, end=105, fill=(217, 239, 252, 255), width=4)
        d.arc([9, 9, 39, 39], start=-60, end=100, fill=(255, 255, 255, 255), width=2)
        # Sparkles
        d.point([38, 10], fill=(251, 185, 84, 255))
        d.point([10, 36], fill=(251, 185, 84, 255))
    elif f_idx == 2:
        # Wide expanded arc burst
        d.arc([2, 2, 46, 46], start=-90, end=130, fill=(46, 34, 47, 255), width=6)
        d.arc([4, 4, 44, 44], start=-85, end=125, fill=(148, 176, 194, 255), width=3)
        d.arc([5, 5, 43, 43], start=-80, end=120, fill=(255, 255, 255, 255), width=1)
        # Kinetic shock lines (knockback force)
        d.line([24, 24, 10, 38], fill=(251, 185, 84, 255), width=2)
        d.line([28, 20, 14, 34], fill=(247, 228, 118, 255), width=1)
    elif f_idx == 3:
        # Dissipating blade particles & smoke
        particles = [(8, 38), (14, 40), (22, 42), (32, 22), (40, 14), (20, 30), (12, 32)]
        for px, py in particles:
            d.ellipse([px-1, py-1, px+1, py+1], fill=(251, 185, 84, 255), outline=(46, 34, 47, 255))
            
    q_f = quantize_im(im)
    q_f.save(os.path.join(DIR_SLASH, f"vet_chem_{f_idx}.png"))
    slash_frames.append(q_f)

save_gif(slash_frames, os.path.join(DIR_SLASH, "slash_preview.gif"), duration=90)
print("  -> Đã tạo 4 frames vệt chém Mạch đao và slash_preview.gif")


print("\n=== 5. TẠO TRIỆN ẤN THẮNG / BẠI (VICTORY & DEFEAT BADGES) ===")
# 160x64 và 80x32: "ĐẠI THẮNG" (son đỏ thắm hoàng kim) & "THẤT THỦ" (tro tàn nứt vỡ)
font_badge = ImageFont.truetype(FONT_FILE, 24)
font_badge_sm = ImageFont.truetype(FONT_FILE, 12)

# 5.1 ĐẠI THẮNG
im_win = Image.new("RGBA", (160, 64), (0, 0, 0, 0))
wd = ImageDraw.Draw(im_win)
# Seal box with decorative corners
wd.rectangle([4, 4, 155, 59], fill=(115, 23, 45, 255), outline=(46, 34, 47, 255), width=3)
wd.rectangle([8, 8, 151, 55], outline=(162, 38, 51, 255), width=2)
# Corner lotus brackets
for cx, cy in [(12, 12), (147, 12), (12, 51), (147, 51)]:
    wd.rectangle([cx-2, cy-2, cx+2, cy+2], fill=(251, 185, 84, 255))
# Text "ĐẠI THẮNG"
text_win = "ĐẠI THẮNG"
bbox = wd.textbbox((0, 0), text_win, font=font_badge)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
tx = (160 - tw) // 2
ty = (64 - th) // 2 - 2
for ox in [-2, -1, 0, 1, 2]:
    for oy in [-2, -1, 0, 1, 2]:
        if abs(ox) + abs(oy) > 0:
            wd.text((tx+ox, ty+oy), text_win, font=font_badge, fill=(46, 34, 47, 255))
wd.text((tx, ty), text_win, font=font_badge, fill=(247, 228, 118, 255))
q_win = quantize_im(im_win)
q_win.save(os.path.join(DIR_BADGES, "trien_dai_thang_160x64.png"))
q_win_sm = quantize_im(q_win.resize((80, 32), Image.NEAREST))
q_win_sm.save(os.path.join(DIR_BADGES, "trien_dai_thang_80x32.png"))
print("  -> trien_dai_thang_160x64.png & 80x32.png")

# 5.2 THẤT THỦ
im_loss = Image.new("RGBA", (160, 64), (0, 0, 0, 0))
ld = ImageDraw.Draw(im_loss)
ld.rectangle([4, 4, 155, 59], fill=(53, 43, 66, 255), outline=(46, 34, 47, 255), width=3)
ld.rectangle([8, 8, 151, 55], outline=(78, 74, 78, 255), width=2)
# Crack lines
ld.line([20, 8, 35, 25], fill=(46, 34, 47, 255), width=2)
ld.line([35, 25, 45, 20], fill=(46, 34, 47, 255), width=2)
ld.line([130, 45, 145, 55], fill=(46, 34, 47, 255), width=2)
text_loss = "THẤT THỦ"
bbox_l = ld.textbbox((0, 0), text_loss, font=font_badge)
tw_l, th_l = bbox_l[2] - bbox_l[0], bbox_l[3] - bbox_l[1]
tx_l = (160 - tw_l) // 2
ty_l = (64 - th_l) // 2 - 2
for ox in [-2, -1, 0, 1, 2]:
    for oy in [-2, -1, 0, 1, 2]:
        if abs(ox) + abs(oy) > 0:
            ld.text((tx_l+ox, ty_l+oy), text_loss, font=font_badge, fill=(46, 34, 47, 255))
ld.text((tx_l, ty_l), text_loss, font=font_badge, fill=(133, 123, 141, 255))
q_loss = quantize_im(im_loss)
q_loss.save(os.path.join(DIR_BADGES, "trien_that_thu_160x64.png"))
q_loss_sm = quantize_im(q_loss.resize((80, 32), Image.NEAREST))
q_loss_sm.save(os.path.join(DIR_BADGES, "trien_that_thu_80x32.png"))
print("  -> trien_that_thu_160x64.png & 80x32.png")


print("\n=== 6. TẠO HOẠT ẢNH RƠI SÔNG (DROWN) KỴ BINH & CUNG KỴ ===")
# Base sprites
base_kb = Image.open(os.path.join(OUT_DIR, "ky_binh", "south.png")).convert("RGBA")
base_ck = Image.open(os.path.join(OUT_DIR, "cung_ky", "south.png")).convert("RGBA")

def generate_drown_cycle(base_sprite, out_dir, prefix):
    frames = []
    # Water color params: #265c42, #68c2d3, white
    for f in range(4):
        im = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        
        # Submerge height
        # f=0: sink 10px, tilt 5 deg
        # f=1: sink 22px, ripples
        # f=2: sink 36px, splash
        # f=3: sink 54px, big ripples only
        sink_y = [8, 20, 34, 50][f]
        
        # Paste shifted unit
        cropped = base_sprite.crop((0, 0, 64, 64 - sink_y))
        im.paste(cropped, (0, sink_y), cropped)
        
        # Water surface Y
        water_y = 52
        
        if f == 0:
            # Water ripples at bottom
            d.line([16, water_y, 48, water_y], fill=(104, 194, 211, 255), width=2)
            d.point([20, water_y-2], fill=(255, 255, 255, 255))
            d.point([44, water_y-2], fill=(255, 255, 255, 255))
        elif f == 1:
            # Foaming water covering legs
            d.ellipse([10, water_y-6, 54, water_y+6], fill=(38, 92, 66, 255), outline=(104, 194, 211, 255), width=2)
            d.line([14, water_y, 50, water_y], fill=(255, 255, 255, 255), width=2)
        elif f == 2:
            # Heavy splash bursting upwards
            d.ellipse([8, water_y-8, 56, water_y+8], fill=(38, 92, 66, 255), outline=(104, 194, 211, 255), width=2)
            splash_pts = [(16, water_y-14), (24, water_y-20), (32, water_y-16), (40, water_y-22), (48, water_y-14)]
            for sx, sy in splash_pts:
                d.line([sx, water_y-4, sx, sy], fill=(255, 255, 255, 255), width=2)
        elif f == 3:
            # Fading rings of water, unit almost gone
            d.ellipse([6, water_y-6, 58, water_y+6], outline=(104, 194, 211, 255), width=2)
            d.ellipse([14, water_y-4, 50, water_y+4], outline=(255, 255, 255, 255), width=1)
            # Bubbles rising
            d.point([30, water_y-10], fill=(255, 255, 255, 255))
            d.point([34, water_y-16], fill=(255, 255, 255, 255))
            d.point([32, water_y-22], fill=(217, 239, 252, 255))
            
        q_im = quantize_im(im)
        q_im.save(os.path.join(out_dir, f"drown_{f}.png"))
        frames.append(q_im)
        
    save_gif(frames, os.path.join(out_dir, "drown_preview.gif"), duration=180)
    print(f"  -> {prefix}: 4 frames và drown_preview.gif")

generate_drown_cycle(base_kb, DIR_DROWN_KB, "Kỵ binh rơi sông")
generate_drown_cycle(base_ck, DIR_DROWN_CK, "Cung kỵ rơi sông")


print("\n=== 7. TẠO KHUNG VIỀN SA BÀN BÀN CỜ GỖ LIM CHỈ ĐỒNG (BOARD BORDER) ===")
# 8 mảnh ghép 9-slice: góc 32x32, cạnh 32x32 (lặp lại được)
def make_board_border():
    dark_wood = (46, 34, 47, 255) # #2e222f
    med_wood = (78, 74, 78, 255)
    bronze = (171, 148, 122, 255) # #ab947a
    gold = (251, 185, 84, 255)
    
    # 7.1 Cạnh trên (Top edge 64x16)
    top_edge = Image.new("RGBA", (64, 16), dark_wood)
    td = ImageDraw.Draw(top_edge)
    td.line([0, 2, 63, 2], fill=bronze, width=1)
    td.line([0, 3, 63, 3], fill=gold, width=1)
    td.line([0, 15, 63, 15], fill=dark_wood, width=1)
    quantize_im(top_edge).save(os.path.join(DIR_BORDER, "canh_tren_64x16.png"))
    
    # 7.2 Cạnh dưới (Bottom edge 64x16)
    bot_edge = top_edge.transpose(Image.FLIP_TOP_BOTTOM)
    quantize_im(bot_edge).save(os.path.join(DIR_BORDER, "canh_duoi_64x16.png"))
    
    # 7.3 Cạnh trái (Left edge 16x64)
    left_edge = Image.new("RGBA", (16, 64), dark_wood)
    ld = ImageDraw.Draw(left_edge)
    ld.line([2, 0, 2, 63], fill=bronze, width=1)
    ld.line([3, 0, 3, 63], fill=gold, width=1)
    quantize_im(left_edge).save(os.path.join(DIR_BORDER, "canh_trai_16x64.png"))
    
    # 7.4 Cạnh phải (Right edge 16x64)
    right_edge = left_edge.transpose(Image.FLIP_LEFT_RIGHT)
    quantize_im(right_edge).save(os.path.join(DIR_BORDER, "canh_phai_16x64.png"))
    
    # 7.5 Góc trên trái (Corner Top-Left 32x32)
    corner_tl = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    cd = ImageDraw.Draw(corner_tl)
    cd.rectangle([4, 4, 31, 31], fill=dark_wood)
    cd.line([6, 6, 31, 6], fill=gold, width=2)
    cd.line([6, 6, 6, 31], fill=gold, width=2)
    cd.ellipse([4, 4, 10, 10], fill=bronze, outline=dark_wood)
    quantize_im(corner_tl).save(os.path.join(DIR_BORDER, "goc_tren_trai_32x32.png"))
    
    # 7.6 3 góc còn lại
    quantize_im(corner_tl.transpose(Image.FLIP_LEFT_RIGHT)).save(os.path.join(DIR_BORDER, "goc_tren_phai_32x32.png"))
    quantize_im(corner_tl.transpose(Image.FLIP_TOP_BOTTOM)).save(os.path.join(DIR_BORDER, "goc_duoi_trai_32x32.png"))
    quantize_im(corner_tl.transpose(Image.FLIP_LEFT_RIGHT).transpose(Image.FLIP_TOP_BOTTOM)).save(os.path.join(DIR_BORDER, "goc_duoi_phai_32x32.png"))
    print("  -> Đã tạo 8 mảnh ghép khung viền bàn cờ gỗ lim chỉ đồng.")

make_board_border()

print("\n=== KIỂM TRA BẢNG MÀU VÀ ĐỘ CHÍNH XÁC ===")
all_new_files = []
for root, dirs, files in os.walk(OUT_DIR):
    for f in files:
        if f.endswith(".png") and any(sub in root for sub in ["bong_do", "chu_so", "o_co", "trien_an", "vet_chem", "chet_duoi", "khung_ban_co"]):
            all_new_files.append(os.path.join(root, f))

invalid_count = 0
for fpath in all_new_files:
    im = Image.open(fpath).convert("RGBA")
    arr = np.array(im)
    alpha = arr[..., 3]
    # Check 1-bit alpha
    semi = np.sum((alpha > 0) & (alpha < 255))
    if semi > 0:
        print(f"  [LỖI ALPHA]: {os.path.basename(fpath)} có {semi} điểm ảnh bán trong suốt!")
        invalid_count += 1
    # Check palette
    opaque = alpha == 255
    px = arr[opaque][..., :3]
    for p in px:
        if tuple(p) not in palette_rgb:
            print(f"  [LỖI MÀU]: {os.path.basename(fpath)} có màu {p} ngoài Resurrect 64!")
            invalid_count += 1
            break

if invalid_count == 0:
    print(f"✅ TẤT CẢ {len(all_new_files)} FILE MỚI ĐỀU ĐẠT 100% RESURRECT 64 VÀ 1-BIT ALPHA!")
else:
    print(f"❌ Có {invalid_count} file chưa đạt.")
