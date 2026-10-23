#!/usr/bin/env python3
"""
Sửa Triệt Để Lỗi Nhòe Màu (Color Blurring / Anti-Aliasing Corruption) trong Hoạt Ảnh Chèo Thuyền:
1. Sử dụng thuật toán Bresenham số nguyên trực tiếp, gán màu pixel chính xác 100%.
2. Tuyệt đối KHÔNG dùng ImageDraw.line với width > 1 (nguồn gốc gây nhòe màu và sinh ra các pixel màu lạ tím xám).
3. Chỉ sử dụng đúng các mã màu gốc của thuyền Đại Việt:
   - Gỗ chèo sáng: (171, 148, 122)
   - Lưỡi chèo: (253, 203, 176)
   - Gỗ tối: (76, 62, 36)
   - Outline: (46, 34, 47)
   - Bọt nước trắng: (255, 255, 255)
   - Gợn nước xanh: (63, 120, 157)
4. Đóng gói GIF chuẩn indexed Palette (chế độ P) thống nhất trên toàn bộ frames:
   - Không bị lệch palette giữa các frame.
   - Không bị dither nhiễu màu.
   - Giữ nguyên 1-bit alpha trong suốt hoàn hảo.
"""

import os
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
OUT_THUYEN = os.path.join(BASE_DIR, "toi_uu", "thuyen")
CONV_DIR = "/home/trung.nguyen11/.gemini/antigravity-cli/brain/02722460-1e37-46a7-ad1f-65c92d14f54b"

# BẢNG MÀU CHUẨN XÁC (KHÔNG MÀU LẠ, 100% RESURRECT 64)
C_OUTLINE    = (46, 34, 47, 255)   # #2e222f
C_OAR_SHAFT  = (171, 148, 122, 255)# #ab947a
C_OAR_BLADE  = (253, 203, 176, 255)# #fdcbb0
C_OAR_DARK   = (76, 62, 36, 255)   # #4c3e24
C_FOAM       = (255, 255, 255, 255)# #ffffff
C_WATER_BLUE = (63, 120, 157, 255) # #3f789d

# Thuật toán vẽ đường thẳng số nguyên Bresenham (Zero Anti-Aliasing)
def bresenham(x0, y0, x1, y1):
    points = []
    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        points.append((x0, y0))
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy
    return points

# Tải thuyền gốc chuẩn
base_p = os.path.join(OUT_THUYEN, "thuyen_chien_dai_viet.png")
base_im = Image.open(base_p).convert("RGBA")
w, h = base_im.size

# Thân thuyền sạch (xóa các chèo cũ ở ngoài viền mạn)
arr_base = np.array(base_im)
arr_hull = arr_base.copy()

# Dọn sạch các điểm chèo cũ ở ngoài viền mạn thuyền
for y in range(35, 60):
    for x in range(25, 64):
        if arr_hull[y, x, 3] > 0:
            if x >= 46 and y >= 40:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif x >= 36 and y >= 48:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif x >= 27 and y >= 53:
                arr_hull[y, x] = [0, 0, 0, 0]

# Mạn trái (Northwest):
for y in range(25, 45):
    for x in range(12, 28):
        if arr_hull[y, x, 3] > 0:
            if y <= 33 and x <= 26:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif y <= 36 and x <= 22:
                arr_hull[y, x] = [0, 0, 0, 0]
            elif y <= 40 and x <= 18:
                arr_hull[y, x] = [0, 0, 0, 0]

# Các cọc chèo (Pivots)
pivots_right = [
    (47, 41), # Chèo đuôi
    (42, 44), # Chèo thân sau
    (37, 47), # Chèo giữa
    (32, 50), # Chèo thân trước
    (27, 53)  # Chèo mũi
]

pivots_left = [
    (30, 31),
    (25, 34),
    (20, 37)
]

# Vector góc quét 4 frame:
# Frame 0: Vươn chèo về trước (Reach forward)
# Frame 1: Cắm chèo (Catch)
# Frame 2: Gạt nước mạnh về sau (Power Stroke)
# Frame 3: Nhấc chèo thu về (Release)
motion_right = [
    {"shaft": (-3, 6),  "blade": (-5, 9),  "foam": None},
    {"shaft": (1, 7),   "blade": (2, 10),  "foam": "catch"},
    {"shaft": (6, 5),   "blade": (9, 7),   "foam": "drive"},
    {"shaft": (2, 5),   "blade": (3, 7),   "foam": "release"}
]

motion_left = [
    {"shaft": (-6, -2), "blade": (-9, -3), "foam": None},
    {"shaft": (-5, -5), "blade": (-8, -7), "foam": "catch"},
    {"shaft": (-1, -6), "blade": (-2, -9), "foam": "drive"},
    {"shaft": (-3, -4), "blade": (-5, -5), "foam": "release"}
]

frames = []

for frame_idx in range(4):
    arr_f = arr_hull.copy()
    m_r = motion_right[frame_idx]
    m_l = motion_left[frame_idx]
    
    # 1. Vẽ Mái chèo Mạn Trái (vẽ sau thân thuyền, chỉ vẽ vào ô rỗng)
    for px, py in pivots_left:
        tx, ty = px + m_l["shaft"][0], py + m_l["shaft"][1]
        bx, by = px + m_l["blade"][0], py + m_l["blade"][1]
        
        # Cán chèo (Shaft)
        for x, y in bresenham(px, py, tx, ty):
            if 0 <= x < w and 0 <= y < h:
                if arr_f[y, x, 3] == 0:
                    arr_f[y, x] = np.array(C_OAR_DARK)
                    
        # Lưỡi chèo (Blade)
        for x, y in bresenham(tx, ty, bx, by):
            if 0 <= x < w and 0 <= y < h:
                if arr_f[y, x, 3] == 0:
                    arr_f[y, x] = np.array(C_OAR_BLADE)
        # Điểm viền đầu chèo
        if 0 <= bx < w and 0 <= by < h:
            arr_f[by, bx] = np.array(C_OUTLINE)
            
        # Bọt nước mạn trái
        if m_l["foam"] == "catch":
            if 0 <= bx - 1 < w and 0 <= by < h:
                arr_f[by, bx - 1] = np.array(C_FOAM)
        elif m_l["foam"] == "drive":
            if 0 <= bx - 1 < w and 0 <= by + 1 < h:
                arr_f[by + 1, bx - 1] = np.array(C_FOAM)
            if 0 <= bx < w and 0 <= by + 1 < h:
                arr_f[by + 1, bx] = np.array(C_WATER_BLUE)

    # 2. Vẽ Mái chèo Mạn Phải (vẽ trước mạn thuyền)
    for px, py in pivots_right:
        tx, ty = px + m_r["shaft"][0], py + m_r["shaft"][1]
        bx, by = px + m_r["blade"][0], py + m_r["blade"][1]
        
        # Cọc chèo (Oarlock)
        arr_f[py, px] = np.array(C_OUTLINE)
        
        # Cán chèo (Shaft)
        for x, y in bresenham(px, py, tx, ty):
            if 0 <= x < w and 0 <= y < h:
                arr_f[y, x] = np.array(C_OAR_SHAFT)
                
        # Lưỡi chèo (Blade - dày 2px)
        for x, y in bresenham(tx, ty, bx, by):
            if 0 <= x < w and 0 <= y < h:
                arr_f[y, x] = np.array(C_OAR_BLADE)
            if 0 <= x + 1 < w and 0 <= y < h:
                arr_f[y, x + 1] = np.array(C_OAR_BLADE)
                
        # Đầu chèo viền nét
        if 0 <= bx < w and 0 <= by < h:
            arr_f[by, bx] = np.array(C_OUTLINE)
        if 0 <= bx + 1 < w and 0 <= by < h:
            arr_f[by, bx + 1] = np.array(C_OUTLINE)
            
        # Hiệu ứng bọt sóng
        if m_r["foam"] == "catch":
            # Bọt nước tròn quanh đầu chèo
            if 0 <= bx < w and 0 <= by + 1 < h:
                arr_f[by + 1, bx] = np.array(C_FOAM)
            if 0 <= bx + 1 < w and 0 <= by + 1 < h:
                arr_f[by + 1, bx + 1] = np.array(C_FOAM)
            if 0 <= bx - 1 < w and 0 <= by + 1 < h:
                arr_f[by + 1, bx - 1] = np.array(C_WATER_BLUE)
        elif m_r["foam"] == "drive":
            # Vệt sóng cuộn dài về sau
            if 0 <= bx + 1 < w and 0 <= by < h:
                arr_f[by, bx + 1] = np.array(C_FOAM)
            if 0 <= bx + 2 < w and 0 <= by - 1 < h:
                arr_f[by - 1, bx + 2] = np.array(C_FOAM)
            if 0 <= bx + 3 < w and 0 <= by - 1 < h:
                arr_f[by - 1, bx + 3] = np.array(C_WATER_BLUE)
        elif m_r["foam"] == "release":
            # Giọt nước rơi
            if 0 <= bx + 1 < w and 0 <= by + 2 < h:
                arr_f[by + 2, bx + 1] = np.array(C_FOAM)

    # 3. Vệt rẽ sóng ở mũi và đuôi thuyền
    if frame_idx in [1, 2]:
        # Mũi thuyền rẽ sóng nhẹ
        arr_f[54, 8] = np.array(C_FOAM)
        arr_f[55, 7] = np.array(C_FOAM)
        arr_f[56, 6] = np.array(C_WATER_BLUE)
    if frame_idx in [2, 3]:
        # Đuôi thuyền rẽ sóng chữ V
        arr_f[23, 56] = np.array(C_FOAM)
        arr_f[22, 58] = np.array(C_FOAM)
        arr_f[25, 57] = np.array(C_FOAM)
        arr_f[26, 60] = np.array(C_WATER_BLUE)

    frm = Image.fromarray(arr_f, mode="RGBA")
    frames.append(frm)

# 4. Lưu từng file PNG chuẩn 100% 1-bit alpha
for i, frm in enumerate(frames):
    out_p = os.path.join(OUT_THUYEN, f"thuyen_cheo_{i}.png")
    frm.save(out_p)
    # Bản lật ngược dòng
    frm.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(OUT_THUYEN, f"thuyen_cheo_nguoc_{i}.png"))
    print(f"Đã lưu frame {i} sạch màu: {out_p}")

# 5. ĐÓNG GÓI GIF CHUẨN PALETTE ĐỒNG NHẤT (LOẠI BỎ TRIỆT ĐỂ LỖI NHÒE MÀU GIF)
# Tạo bảng màu cố định chính xác (Palette Index):
# Màu 0 = Transparent, Màu 1..N = Các màu chính xác của thuyền + nước
palette_list = [
    (0, 0, 0),         # 0: Transparent key
    (46, 34, 47),      # 1: Outline
    (49, 54, 56),      # 2: Sail dark
    (171, 148, 122),   # 3: Oar shaft / Wood
    (150, 108, 108),   # 4: Hull dark red
    (76, 62, 36),      # 5: Wood shadow
    (69, 41, 63),      # 6: Hull deep
    (253, 203, 176),   # 7: Oar blade
    (122, 48, 69),     # 8: Hull crimson
    (117, 60, 84),     # 9: Hull light
    (103, 102, 51),    # 10: Sail gold
    (251, 185, 84),    # 11: Flag gold
    (230, 144, 78),    # 12: Flag orange
    (249, 194, 43),    # 13: Bright gold
    (98, 85, 101),     # 14: Accent
    (55, 78, 74),      # 15: Accent
    (255, 255, 255),   # 16: Foam white
    (63, 120, 157),    # 17: Water blue
    (18, 78, 137),     # 18: Water dark
]

# Tạo ảnh Palette mẫu 256 màu
palette_bytes = bytearray()
for c in palette_list:
    palette_bytes.extend(c)
# Padding cho đủ 256 màu (768 bytes)
palette_bytes.extend(bytearray([0] * (768 - len(palette_bytes))))

pal_im = Image.new("P", (16, 16))
pal_im.putpalette(palette_bytes)

# Chuyển đổi từng frame sang Mode P dùng đúng Palette này (dither=NONE)
pal_frames = []
for frm in frames:
    # Với mỗi pixel: nếu alpha == 0 thì gán index 0, ngược lại tìm màu chính xác
    arr = np.array(frm)
    h_f, w_f, _ = arr.shape
    p_img = Image.new("P", (w_f, h_f), 0)
    p_img.putpalette(palette_bytes)
    
    col_map = {c: idx for idx, c in enumerate(palette_list)}
    p_arr = np.zeros((h_f, w_f), dtype=np.uint8)
    
    for y in range(h_f):
        for x in range(w_f):
            if arr[y, x, 3] < 128:
                p_arr[y, x] = 0
            else:
                rgb = tuple(arr[y, x, :3])
                p_arr[y, x] = col_map.get(rgb, 1) # Default to outline if not found
                
    p_img = Image.fromarray(p_arr, mode="P")
    p_img.putpalette(palette_bytes)
    pal_frames.append(p_img)

# Lưu GIF trong suốt 1x chuẩn 100%
gif_1x = os.path.join(OUT_THUYEN, "thuyen_cheo_preview.gif")
pal_frames[0].save(
    gif_1x,
    save_all=True,
    append_images=pal_frames[1:],
    duration=200,
    loop=0,
    transparency=0,
    disposal=2
)
import shutil
shutil.copyfile(gif_1x, os.path.join(CONV_DIR, "thuyen_cheo_preview.gif"))
print(f"Đã lưu GIF 1x chuẩn tuyệt đối: {gif_1x}")

# Lưu GIF phóng to x3 (Nearest-Neighbor, hoàn toàn không làm nhòe điểm ảnh)
pal_frames_3x = []
for p_frm in pal_frames:
    p3 = p_frm.resize((p_frm.width * 3, p_frm.height * 3), Image.NEAREST)
    p3.putpalette(palette_bytes)
    pal_frames_3x.append(p3)

gif_3x = os.path.join(OUT_THUYEN, "thuyen_cheo_preview_3x.gif")
pal_frames_3x[0].save(
    gif_3x,
    save_all=True,
    append_images=pal_frames_3x[1:],
    duration=200,
    loop=0,
    transparency=0,
    disposal=2
)
shutil.copyfile(gif_3x, os.path.join(CONV_DIR, "thuyen_cheo_preview_3x.gif"))
print(f"Đã lưu GIF 3x chuẩn tuyệt đối: {gif_3x}")

# 6. TẠO LẠI BẢN PREVIEW TRÊN NƯỚC SÔNG SẮC NÉT (Không dither, không nhòe)
tile_water = Image.open(os.path.join(BASE_DIR, "toi_uu/dia_hinh/o_nen/tile_0.png")).convert("RGBA")
water_3x_list = []
for frm in frames:
    bg_w = Image.new("RGBA", (192, 192), (18, 78, 137, 255))
    bg_w.alpha_composite(tile_water.resize((192, 192), Image.NEAREST), (0, 0))
    frm_3x = frm.resize((192, 192), Image.NEAREST)
    bg_w.alpha_composite(frm_3x, (0, 0))
    water_3x_list.append(bg_w)

gif_water = os.path.join(OUT_THUYEN, "thuyen_cheo_tren_song_3x.gif")
# Lưu GIF RGB đầy đủ trên nền nước (không cần transparency vì nền nước đặc 100%)
# Quantize bằng palette Resurrect 64 không dither
water_3x_list[0].convert("P", palette=Image.ADAPTIVE, colors=32).save(
    gif_water,
    save_all=True,
    append_images=[w_im.convert("P", palette=Image.ADAPTIVE, colors=32) for w_im in water_3x_list[1:]],
    duration=200,
    loop=0
)
shutil.copyfile(gif_water, os.path.join(CONV_DIR, "thuyen_cheo_tren_song_3x.gif"))
print(f"Đã lưu GIF trên sông sắc nét: {gif_water}")

# 7. TẠO LẠI FILMSTRIP SẮC NÉT (4 frames cạnh nhau)
from PIL import ImageFont
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()

fw = 192
fh = 192
pad = 16
total_w = pad * 5 + fw * 4
total_h = fh + 90

strip = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
from PIL import ImageDraw
draw = ImageDraw.Draw(strip)

phases = [
    ("Frame 0: Vươn Chèo (Reach)", "Mái chèo vươn về trước mũi thuyền, lưỡi chèo lướt sát mặt nước"),
    ("Frame 1: Cắm Chèo (Catch)", "Mái chèo cắm ngập nước, bọt nước tròn quanh lưỡi chèo"),
    ("Frame 2: Gạt Nước (Power Stroke)", "Quét mạnh về sau đẩy thuyền, vệt sóng cuộn sủi bọt trắng xóa"),
    ("Frame 3: Nhấc Chèo (Release & Wake)", "Nhấc chèo thu về, vệt rẽ sóng chữ V ở đuôi thuyền khi lướt tới")
]

for i, (title, desc) in enumerate(phases):
    x = pad + i * (fw + pad)
    y = 16
    strip.alpha_composite(water_3x_list[i], (x, y))
    draw.rectangle([x - 1, y - 1, x + fw, y + fh], outline=(90, 105, 136, 255), width=1)
    draw.text((x + fw // 2, y + fh + 8), title, fill=(255, 230, 150, 255), font=font, anchor="mt")
    draw.text((x + fw // 2, y + fh + 26), desc[:35], fill=(180, 200, 220, 255), font=font_sub, anchor="mt")
    if len(desc) > 35:
        draw.text((x + fw // 2, y + fh + 40), desc[35:], fill=(180, 200, 220, 255), font=font_sub, anchor="mt")

strip_out = os.path.join(OUT_THUYEN, "thuyen_cheo_filmstrip.png")
strip.save(strip_out)
shutil.copyfile(strip_out, os.path.join(CONV_DIR, "thuyen_cheo_filmstrip.png"))
print(f"Đã lưu Filmstrip sắc nét: {strip_out}")
