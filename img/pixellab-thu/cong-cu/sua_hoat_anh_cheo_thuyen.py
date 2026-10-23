#!/usr/bin/env python3
"""
Sửa Triệt Để Hoạt Ảnh Chèo Thuyền Lướt Sóng (Rowing Animation):
Khắc phục toàn bộ 5 lỗi nghiêm trọng:
1. Loại bỏ hoàn toàn lỗi thuyền nhảy giật cục chéo (-1, 1). Thân thuyền giữ vững độ ổn định trên mặt nước.
2. Diễn hoạt thật sự góc quét của MÁI CHÈO (Oar Sweep) qua 4 pha:
   - Frame 0: Vươn chèo về trước (Reach forward)
   - Frame 1: Cắm chèo xuống nước, bọt nước tròn quanh lưỡi (Catch)
   - Frame 2: Gạt chèo mạnh về sau, vệt sóng cuộn sủi bọt trắng xóa (Power Stroke)
   - Frame 3: Nhấc chèo lên khỏi nước, vệt rẽ sóng chữ V ở đuôi thuyền (Release & Wake)
3. Diễn hoạt đồng bộ cả 2 bên mạn thuyền (mạn phải và mạn trái).
4. Chuẩn hóa màu sắc 100% Resurrect 64, 1-bit alpha.
5. Xuất ảnh động GIF preview mượt mà và đại bảng tổng hợp cập nhật.
"""

import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
OUT_THUYEN_DIR = os.path.join(BASE_DIR, "toi_uu", "thuyen")
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")

# Load Palette
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
OUTLINE = (46, 34, 47, 255)

def quantize_im(im):
    arr = np.array(im.convert("RGBA"))
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    opaque = alpha >= 128
    out_alpha = np.where(opaque, 255, 0).astype(np.uint8)
    rgb = arr[..., :3].astype(np.float32)
    px = rgb[opaque]
    if len(px) > 0:
        lab_px = rgb_to_cielab(px)
        diff = lab_px[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_idx = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_idx].astype(np.uint8)
        
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

# Bảng màu
C_OAR_SHAFT = (171, 148, 122, 255) # Gỗ chèo sáng
C_OAR_BLADE = (253, 203, 176, 255) # Lưỡi chèo
C_OAR_DARK  = (76, 62, 36, 255)    # Gỗ bóng tối
C_FOAM      = (255, 255, 255, 255) # Bọt nước trắng xóa
C_WATER_MID = (63, 120, 157, 255)  # Gợn sóng nước xanh
C_WATER_DARK= (18, 78, 137, 255)   # Nước sâu

# Tải thuyền gốc
base_p = os.path.join(OUT_THUYEN_DIR, "thuyen_chien_dai_viet.png")
base_im = Image.open(base_p).convert("RGBA")
w, h = base_im.size

# Tách thân thuyền: giữ lại thân thuyền chính, xóa các đầu chèo cũ bên ngoài mạn thuyền
# để vẽ lại góc quét chèo động mới
hull_im = base_im.copy()
arr_hull = np.array(hull_im)

# Các điểm mái chèo cũ nhô ra ngoài mạn phải (x >= 45, y >= 35 và x >= 30, y >= 50)
for y in range(35, 60):
    for x in range(25, 64):
        # Nếu là màu của mái chèo cũ ở ngoài mép nước
        if arr_hull[y, x, 3] > 0:
            c = tuple(arr_hull[y, x, :3])
            # Điểm chèo cũ ở ngoài viền mạn
            if x >= 46 and y >= 40:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif x >= 36 and y >= 48:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif x >= 27 and y >= 53:
                arr_hull[y, x] = [0, 0, 0, 0]

hull_clean = Image.fromarray(arr_hull)

# 4 VỊ TRÍ CỌC CHÈO TRÊN MẠN THUYỀN (Pivots):
# Mạn phải (hướng Đông Nam):
pivots_right = [
    (48, 41), # Chèo đuôi
    (42, 44), # Chèo thân sau
    (36, 47), # Chèo giữa
    (30, 50), # Chèo thân trước
    (24, 53)  # Chèo mũi
]

# Mạn trái (hướng Tây Bắc):
pivots_left = [
    (28, 32), # Chèo sau
    (24, 35), # Chèo giữa
    (20, 38)  # Chèo trước
]

# ĐỊNH NGHĨA VECTOR GÓC QUÉT CỦA MÁI CHÈO TRONG 4 FRAME:
# Mũi thuyền hướng Tây Nam (~ góc 225 độ).
# Khi chèo:
# - Frame 0 (Vươn tới): Mái chèo vươn về phía mũi thuyền (Southwest)
# - Frame 1 (Cắm chèo): Mái chèo vuông góc mạn thuyền (South-Southeast)
# - Frame 2 (Gạt nước mạnh): Mái chèo quét về phía sau (East-Southeast)
# - Frame 3 (Nhấc chèo): Mái chèo thu về, nhấc lên khỏi mặt nước

oar_offsets_right = [
    # Frame 0: Vươn tới (chếch về mũi thuyền)
    {"dx": -3, "dy": 8, "blade_dx": -4, "blade_dy": 10},
    # Frame 1: Cắm nước (hơi vuông góc)
    {"dx": 1, "dy": 9, "blade_dx": 2, "blade_dy": 11},
    # Frame 2: Gạt mạnh về sau (chếch về đuôi thuyền)
    {"dx": 6, "dy": 7, "blade_dx": 8, "blade_dy": 8},
    # Frame 3: Nhấc chèo (ngắn hơn vì nhấc lên cao)
    {"dx": 2, "dy": 6, "blade_dx": 3, "blade_dy": 7}
]

oar_offsets_left = [
    # Frame 0: Vươn tới
    {"dx": -6, "dy": -2, "blade_dx": -8, "blade_dy": -3},
    # Frame 1: Cắm nước
    {"dx": -6, "dy": -5, "blade_dx": -7, "blade_dy": -6},
    # Frame 2: Gạt mạnh về sau
    {"dx": -2, "dy": -7, "blade_dx": -2, "blade_dy": -8},
    # Frame 3: Nhấc chèo
    {"dx": -4, "dy": -4, "blade_dx": -5, "blade_dy": -5}
]

frames = []

for frame_idx in range(4):
    f_im = hull_clean.copy()
    draw_f = ImageDraw.Draw(f_im)
    
    vec_r = oar_offsets_right[frame_idx]
    vec_l = oar_offsets_left[frame_idx]
    
    # 1. Vẽ mái chèo Mạn Trái (vẽ sau lưng thân thuyền)
    # Tạo layer chèo trái rồi ghép dưới thân thuyền
    layer_left = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw_l = ImageDraw.Draw(layer_left)
    for px, py in pivots_left:
        tx = px + vec_l["dx"]
        ty = py + vec_l["dy"]
        bx = px + vec_l["blade_dx"]
        by = py + vec_l["blade_dy"]
        # Cán chèo
        draw_l.line([(px, py), (tx, ty)], fill=C_OAR_DARK, width=2)
        # Lưỡi chèo
        draw_l.line([(tx, ty), (bx, by)], fill=C_OAR_BLADE, width=2)
        draw_l.point((bx, by), fill=OUTLINE)
        
        # Bọt nước mạn trái
        if frame_idx == 1:
            draw_l.point((bx - 1, by), fill=C_FOAM)
            draw_l.point((bx, by - 1), fill=C_WATER_MID)
        elif frame_idx == 2:
            draw_l.line([(bx, by), (bx - 2, by + 1)], fill=C_FOAM, width=1)
            draw_l.point((bx - 1, by + 2), fill=C_WATER_MID)
            
    # Ghép layer chèo trái vào nền trước khi vẽ thân thuyền
    f_im = Image.alpha_composite(layer_left, f_im)
    draw_f = ImageDraw.Draw(f_im)
    
    # 2. Vẽ mái chèo Mạn Phải (vẽ đè lên mạn trước)
    for px, py in pivots_right:
        tx = px + vec_r["dx"]
        ty = py + vec_r["dy"]
        bx = px + vec_r["blade_dx"]
        by = py + vec_r["blade_dy"]
        
        # Viền cọc chèo
        draw_f.point((px, py), fill=OUTLINE)
        # Cán chèo
        draw_f.line([(px, py), (tx, ty)], fill=C_OAR_SHAFT, width=2)
        draw_f.line([(px + 1, py), (tx + 1, ty)], fill=OUTLINE, width=1)
        # Lưỡi chèo to hơn
        draw_f.line([(tx, ty), (bx, by)], fill=C_OAR_BLADE, width=2)
        draw_f.point((bx, by), fill=OUTLINE)
        draw_f.point((bx + 1, by), fill=OUTLINE)
        
        # Hiệu ứng bọt sóng theo từng frame
        if frame_idx == 1:
            # Cắm chèo: vòng bọt nước tròn quanh lưỡi chèo
            draw_f.point((bx, by + 1), fill=C_FOAM)
            draw_f.point((bx + 1, by + 1), fill=C_FOAM)
            draw_f.point((bx - 1, by + 1), fill=C_WATER_MID)
            draw_f.point((bx, by + 2), fill=C_WATER_MID)
        elif frame_idx == 2:
            # Gạt nước mạnh: vệt sóng rẽ nước kéo dài về sau
            draw_f.line([(bx, by), (bx + 2, by - 1)], fill=C_FOAM, width=1)
            draw_f.line([(bx + 1, by + 1), (bx + 3, by)], fill=C_FOAM, width=1)
            draw_f.point((bx + 4, by), fill=C_WATER_MID)
            draw_f.point((bx + 2, by + 2), fill=C_WATER_DARK)
        elif frame_idx == 3:
            # Nhấc chèo: giọt nước rơi từ lưỡi chèo
            draw_f.point((bx, by + 2), fill=C_FOAM)
            draw_f.point((bx + 1, by + 3), fill=C_WATER_MID)

    # 3. Hiệu ứng Vệt Rẽ Sóng ở Đuôi và Mũi Thuyền
    # Mũi thuyền ở (10, 52), Đuôi thuyền ở (54, 24)
    if frame_idx in [1, 2]:
        # Mũi thuyền rẽ sóng nhẹ
        draw_f.line([(8, 54), (5, 57)], fill=C_FOAM, width=1)
        draw_f.point((6, 56), fill=C_WATER_MID)
    if frame_idx in [2, 3]:
        # Đuôi thuyền để lại vệt rẽ sóng chữ V
        draw_f.line([(55, 23), (59, 21)], fill=C_FOAM, width=1)
        draw_f.line([(56, 25), (61, 26)], fill=C_FOAM, width=1)
        draw_f.point((60, 22), fill=C_WATER_MID)
        draw_f.point((62, 27), fill=C_WATER_DARK)

    # Lượng hóa chuẩn 100% Resurrect 64
    f_q = quantize_im(f_im)
    frames.append(f_q)

# Lưu 4 frames chuẩn
for i, frm in enumerate(frames):
    out_p = os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_{i}.png")
    frm.save(out_p)
    # Bản lật ngược dòng
    frm.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_nguoc_{i}.png"))
    print(f"Đã lưu frame {i}: {out_p}")

# Tạo GIF Preview mượt mà chuẩn 1-bit alpha
gif_1x = os.path.join(OUT_THUYEN_DIR, "thuyen_cheo_preview.gif")
# Lưu GIF chuẩn: dùng frame đầu tiên làm palette, duration 200ms mỗi frame
frames[0].save(
    gif_1x,
    save_all=True,
    append_images=frames[1:],
    duration=200,
    loop=0,
    disposal=2
)

# Tạo bản phóng to x3 để review cực kỳ rõ ràng
frames_3x = [frm.resize((frm.width * 3, frm.height * 3), Image.NEAREST) for frm in frames]
gif_3x = os.path.join(OUT_THUYEN_DIR, "thuyen_cheo_preview_3x.gif")
frames_3x[0].save(
    gif_3x,
    save_all=True,
    append_images=frames_3x[1:],
    duration=200,
    loop=0,
    disposal=2
)

# Copy sang Artifact directory
CONV_DIR = "/home/trung.nguyen11/.gemini/antigravity-cli/brain/02722460-1e37-46a7-ad1f-65c92d14f54b"
import shutil
shutil.copyfile(gif_1x, os.path.join(CONV_DIR, "thuyen_cheo_preview.gif"))
shutil.copyfile(gif_3x, os.path.join(CONV_DIR, "thuyen_cheo_preview_3x.gif"))

# Cập nhật lại Đại bảng tổng hợp _tong_hop_toan_bo_thuyen_chien.png
from PIL import ImageFont
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()

total_w = 760
total_h = 760
pad = 16

board = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
draw_b = ImageDraw.Draw(board)

draw_b.text((pad, 14), "ĐẠI TỔNG HỢP HỆ THỐNG THỦY CHIẾN ĐẠI VIỆT (CHUẨN LỊCH SỬ THỜI TRẦN)", fill=(255, 230, 150), font=font)
draw_b.text((pad, 34), "Đại Việt dùng thuyền nhỏ cơ động (1 ô) — Thuyền lớn cồng kềnh (2 ô) độc quyền cho quân Nguyên", fill=(180, 200, 220), font=font_sub)

# HÀNG 1: Thuyền chiến cơ bản (y=64)
y1 = 64
draw_b.text((pad, y1), "1. THUYỀN CHIẾN CƠ ĐỘNG (64×64 PX — 1 Ô BÀN CỜ)", fill=(255, 215, 120), font=font)
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
        draw_b.text((x, y1 + 122), title, fill=(200, 240, 220), font=font_sub)
        draw_b.text((x, y1 + 138), desc, fill=(160, 180, 200), font=font_sub)

# HÀNG 2: Tác chiến Cháy & Đắm cọc (y=230)
y2 = 230
draw_b.text((pad, y2), "2. TÁC CHIẾN BẠCH ĐẰNG & VÂN ĐỒN (64×64 PX)", fill=(255, 215, 120), font=font)
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
        draw_b.text((x, y2 + 122), title, fill=(255, 140, 140), font=font_sub)
        draw_b.text((x, y2 + 138), desc, fill=(180, 160, 160), font=font_sub)

# HÀNG 3: Chiến hạm lớn quân Nguyên 64x128 (y=400)
y3 = 400
draw_b.text((pad, y3), "3. CHIẾN HẠM HẠNG NẶNG QUÂN NGUYÊN (64×128 PX — DÀI 2 Ô BÀN CỜ)", fill=(255, 215, 120), font=font)
p_cap = os.path.join(OUT_THUYEN_DIR, "soai_ham_nguyen_64x128.png")
if os.path.exists(p_cap):
    im_cap = Image.open(p_cap).resize((70, 140), Image.NEAREST)
    board.paste(im_cap, (pad + 40, y3 + 22), im_cap)
draw_b.text((pad + 130, y3 + 40), "Đại Hạm Chỉ Huy Ô Mã Nhi (Nguyên Mông - 64×128 px)", fill=(255, 230, 160), font=font)
draw_b.text((pad + 130, y3 + 64), "• Thân thuyền bọc giáp gỗ kiên cố, tháp canh lầu tên, buồm xám xanh lớn.", fill=(200, 200, 210), font=font_sub)
draw_b.text((pad + 130, y3 + 82), "• Mục tiêu to lớn, chậm chạp — điểm yếu chí mạng khi thủy triều rút ở Bạch Đằng.", fill=(255, 180, 150), font=font_sub)

# HÀNG 4: Hoạt ảnh chèo thuyền lướt sóng mới (y=580)
y4 = 580
draw_b.text((pad, y4), "4. HOẠT ẢNH THUYỀN MÔNG ĐỒNG CHÈO LƯỚT SÓNG (4 FRAMES ĐÃ SỬA CHUẨN)", fill=(255, 215, 120), font=font)
for i in range(4):
    p = os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_{i}.png")
    if os.path.exists(p):
        im = Image.open(p).resize((96, 96), Image.NEAREST)
        x = pad + i * 180
        board.paste(im, (x, y4 + 22), im)
        draw_b.text((x + 20, y4 + 122), f"Frame {i}", fill=(180, 220, 255), font=font_sub)

board_q = quantize_im(board)
grand_p = os.path.join(OUT_THUYEN_DIR, "_tong_hop_toan_bo_thuyen_chien.png")
board_q.save(grand_p)
shutil.copyfile(grand_p, os.path.join(CONV_DIR, "_tong_hop_toan_bo_thuyen_chien.png"))
print(f"Đã cập nhật Đại bảng tổng hợp thuyền chiến: {grand_p}")
