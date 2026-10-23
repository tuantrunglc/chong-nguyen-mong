#!/usr/bin/env python3
"""
Tạo Demo Mô Phỏng Bàn Cờ Thử Ba Đòn Đặc Sắc:
- Bàn cờ 6x5 ô vuông 64x64 (384x320 px)
- 3 tướng Đại Việt & 3 quân Nguyên
- 3 đòn phối hợp liên hoàn trong 1 hiệp:
  1. Nguyễn Khoái chém Mạch đao đẩy Bộ binh vào hầm chông -> chông đâm gục!
  2. Trần Khánh Dư móc câu liêm kéo Kỵ binh rơi tõm xuống sông -> chết đuối!
  3. Phạm Ngũ Lão phóng ngọn lao tầm xa cắm phập Cung kỵ -> gục ngã!
  4. Quét sạch quân địch -> Triện son "ĐẠI THẮNG" khải hoàn.

100% chuẩn Resurrect 64, 1-bit alpha, xuất GIF 1x và 2x.
"""

import os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

TOI_UU = os.path.join(BASE_DIR, "toi_uu")

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
        
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

# Load Tiles & Assets
tile_grass_0 = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_co_le_0.png")).convert("RGBA")
tile_grass_1 = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_co_le_1.png")).convert("RGBA")
tile_spikes = Image.open(os.path.join(TOI_UU, "dia_hinh/vat_can/a4_ham_chong_0.png")).convert("RGBA")
tile_river = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_0.png")).convert("RGBA")
tile_bank = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_11.png")).convert("RGBA")

# Generals
khoai_idle = Image.open(os.path.join(TOI_UU, "khoai/north.png")).convert("RGBA")
khoai_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_2.png")).convert("RGBA") # Slash stance

du_idle = Image.open(os.path.join(TOI_UU, "du/east.png")).convert("RGBA")
du_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/du/east_1.png")).convert("RGBA") # Hook pull

lao_idle = Image.open(os.path.join(TOI_UU, "lao/east.png")).convert("RGBA")
lao_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/lao/east_2.png")).convert("RGBA") # Spear throw

# Enemies
bb_idle = Image.open(os.path.join(TOI_UU, "nguyen_v3/south.png")).convert("RGBA")
bb_hurt = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/bo_binh/hurt_1.png")).convert("RGBA")
bb_dead = Image.open(os.path.join(TOI_UU, "hoat_anh/guc_nga/bo_binh/death_3.png")).convert("RGBA")

kb_idle = Image.open(os.path.join(TOI_UU, "ky_binh/west.png")).convert("RGBA")
kb_hurt = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/ky_binh/hurt_1.png")).convert("RGBA")
kb_drown_0 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_0.png")).convert("RGBA")
kb_drown_1 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_1.png")).convert("RGBA")
kb_drown_2 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_2.png")).convert("RGBA")
kb_drown_3 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_3.png")).convert("RGBA")

ck_idle = Image.open(os.path.join(TOI_UU, "cung_ky/west.png")).convert("RGBA")
ck_hurt = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/cung_ky/hurt_1.png")).convert("RGBA")
ck_dead = Image.open(os.path.join(TOI_UU, "hoat_anh/guc_nga/cung_ky/death_3.png")).convert("RGBA")

# VFX & UI Overlays
shadow = Image.open(os.path.join(TOI_UU, "giao_dien/bong_do/bong_do_quan_32x16.png")).convert("RGBA")
frame_sel = Image.open(os.path.join(TOI_UU, "giao_dien/o_co/khung_chon_tuong_64x64.png")).convert("RGBA")
frame_atk = Image.open(os.path.join(TOI_UU, "giao_dien/o_co/khung_o_danh_duoc_64x64.png")).convert("RGBA")

arrow_west = Image.open(os.path.join(TOI_UU, "giao_dien/o_co/mui_ten_xung_phong_tay.png")).convert("RGBA")
num_1 = Image.open(os.path.join(TOI_UU, "giao_dien/chu_so/so_to_1.png")).convert("RGBA")
num_2 = Image.open(os.path.join(TOI_UU, "giao_dien/chu_so/so_to_2.png")).convert("RGBA")
num_3 = Image.open(os.path.join(TOI_UU, "giao_dien/chu_so/so_to_3.png")).convert("RGBA")

vfx_slash = Image.open(os.path.join(TOI_UU, "hieu_ung/vet_chem/vet_chem_2.png")).convert("RGBA")
vfx_spikes_hit = Image.open(os.path.join(TOI_UU, "hieu_ung/c5_chong_dam.png")).convert("RGBA")
vfx_impact = Image.open(os.path.join(TOI_UU, "hieu_ung/c3_va_cham.png")).convert("RGBA")
vfx_splash = Image.open(os.path.join(TOI_UU, "hieu_ung/c4_nuoc_ban.png")).convert("RGBA")
vfx_spear = Image.open(os.path.join(TOI_UU, "hieu_ung/c1_lao_bay.png")).convert("RGBA")

badge_win = Image.open(os.path.join(TOI_UU, "giao_dien/trien_an/trien_dai_thang_160x64.png")).convert("RGBA")

# Build Base Terrain (6 cols x 5 rows = 384 x 320 px)
def get_base_board():
    board = Image.new("RGBA", (384, 320), (0, 0, 0, 255))
    for r in range(5):
        for c in range(6):
            x, y = c * 64, r * 64
            if (c, r) == (1, 0):
                # Spikes tile
                board.paste(tile_grass_0, (x, y))
                board.paste(tile_spikes, (x, y), tile_spikes)
            elif (c, r) == (3, 2):
                # River tile in middle
                board.paste(tile_river, (x, y))
            elif c == 2 and r == 2:
                # Bank to the west of river
                board.paste(tile_bank, (x, y))
            elif (c + r) % 2 == 0:
                board.paste(tile_grass_0, (x, y))
            else:
                board.paste(tile_grass_1, (x, y))
    return board

# Grid mapping:
# (1, 0): Spikes
# (1, 1): BB (start)
# (1, 2): Khoai
# (2, 2): Du
# (3, 2): River
# (4, 2): KB
# (1, 4): Lao
# (4, 4): CK

frames = []

def tile_pos(c, r):
    return (c * 64, r * 64)

def unit_draw(canvas, sprite, c, r, off_x=0, off_y=0, has_shadow=True):
    x, y = c * 64 + off_x, r * 64 + off_y
    if has_shadow:
        canvas.paste(shadow, (x + 16, y + 44), shadow)
    canvas.paste(sprite, (x, y), sprite)

# SEQUENCE DEFINITION (16 Key frames)
# Frame 0: Battle Start, Enemy Telegraphs
f0 = get_base_board()
# Telegraphs on player generals
# BB aims at Khoai (1, 2)
f0.paste(frame_atk, tile_pos(1, 2), frame_atk)
f0.paste(num_1, (1*64 + 48, 2*64 + 44), num_1)
# KB aims West (arrow at 4, 2)
f0.paste(arrow_west, tile_pos(4, 2), arrow_west)
f0.paste(num_2, (4*64 + 48, 2*64 + 44), num_2)
# CK aims at Lao (1, 4)
f0.paste(frame_atk, tile_pos(1, 4), frame_atk)
f0.paste(num_3, (1*64 + 48, 4*64 + 44), num_3)
# Draw units
unit_draw(f0, bb_idle, 1, 1)
unit_draw(f0, khoai_idle, 1, 2)
unit_draw(f0, du_idle, 2, 2)
unit_draw(f0, kb_idle, 4, 2)
unit_draw(f0, lao_idle, 1, 4)
unit_draw(f0, ck_idle, 4, 4)
frames.append(quantize_im(f0, is_opaque=True))

# Frame 1: Select Khoai -> Target BB (1, 1)
f1 = get_base_board()
f1.paste(frame_sel, tile_pos(1, 2), frame_sel)
f1.paste(frame_atk, tile_pos(1, 1), frame_atk)
unit_draw(f1, bb_idle, 1, 1)
unit_draw(f1, khoai_idle, 1, 2)
unit_draw(f1, du_idle, 2, 2)
unit_draw(f1, kb_idle, 4, 2)
unit_draw(f1, lao_idle, 1, 4)
unit_draw(f1, ck_idle, 4, 4)
frames.append(quantize_im(f1, is_opaque=True))

# Frame 2: Khoai strikes Mạch đao! (Slash Arc)
f2 = get_base_board()
f2.paste(vfx_slash, (1*64 + 8, 1*64 + 20), vfx_slash)
f2.paste(vfx_impact, (1*64 + 8, 1*64 + 8), vfx_impact)
unit_draw(f2, bb_hurt, 1, 1, off_y=-8)
unit_draw(f2, khoai_atk, 1, 2)
unit_draw(f2, du_idle, 2, 2)
unit_draw(f2, kb_idle, 4, 2)
unit_draw(f2, lao_idle, 1, 4)
unit_draw(f2, ck_idle, 4, 4)
frames.append(quantize_im(f2, is_opaque=True))

# Frame 3: BB pushed onto Spikes (1, 0)! Spikes impale!
f3 = get_base_board()
f3.paste(vfx_spikes_hit, (1*64 + 8, 0*64 + 8), vfx_spikes_hit)
unit_draw(f3, bb_dead, 1, 0, has_shadow=False)
unit_draw(f3, khoai_idle, 1, 2)
unit_draw(f3, du_idle, 2, 2)
unit_draw(f3, kb_idle, 4, 2)
unit_draw(f3, lao_idle, 1, 4)
unit_draw(f3, ck_idle, 4, 4)
frames.append(quantize_im(f3, is_opaque=True))

# Frame 4: BB dead. Select Dư -> Target KB (4, 2)
f4 = get_base_board()
f4.paste(frame_sel, tile_pos(2, 2), frame_sel)
f4.paste(frame_atk, tile_pos(4, 2), frame_atk)
unit_draw(f4, khoai_idle, 1, 2)
unit_draw(f4, du_idle, 2, 2)
unit_draw(f4, kb_idle, 4, 2)
unit_draw(f4, lao_idle, 1, 4)
unit_draw(f4, ck_idle, 4, 4)
frames.append(quantize_im(f4, is_opaque=True))

# Frame 5: Dư hooks & pulls KB! (Hook line + KB pulled west)
f5 = get_base_board()
d5 = ImageDraw.Draw(f5)
# Draw Hook line from (2, 2) to (3.5, 2)
d5.line([2*64 + 48, 2*64 + 32, 4*64 - 10, 2*64 + 32], fill=(171, 148, 122, 255), width=2)
unit_draw(f5, khoai_idle, 1, 2)
unit_draw(f5, du_atk, 2, 2)
# KB being pulled into river tile (3, 2)
unit_draw(f5, kb_hurt, 3, 2, off_x=16, off_y=-4, has_shadow=False)
unit_draw(f5, lao_idle, 1, 4)
unit_draw(f5, ck_idle, 4, 4)
frames.append(quantize_im(f5, is_opaque=True))

# Frame 6: KB hits river! Water splash C4
f6 = get_base_board()
f6.paste(vfx_splash, (3*64 + 8, 2*64 + 10), vfx_splash)
unit_draw(f6, khoai_idle, 1, 2)
unit_draw(f6, du_idle, 2, 2)
unit_draw(f6, kb_drown_1, 3, 2, has_shadow=False)
unit_draw(f6, lao_idle, 1, 4)
unit_draw(f6, ck_idle, 4, 4)
frames.append(quantize_im(f6, is_opaque=True))

# Frame 7: KB sinks deep into water
f7 = get_base_board()
unit_draw(f7, khoai_idle, 1, 2)
unit_draw(f7, du_idle, 2, 2)
unit_draw(f7, kb_drown_2, 3, 2, has_shadow=False)
unit_draw(f7, lao_idle, 1, 4)
unit_draw(f7, ck_idle, 4, 4)
frames.append(quantize_im(f7, is_opaque=True))

# Frame 8: KB submerged! Select Lão -> Target CK (4, 4)
f8 = get_base_board()
unit_draw(f8, kb_drown_3, 3, 2, has_shadow=False)
f8.paste(frame_sel, tile_pos(1, 4), frame_sel)
f8.paste(frame_atk, tile_pos(4, 4), frame_atk)
unit_draw(f8, khoai_idle, 1, 2)
unit_draw(f8, du_idle, 2, 2)
unit_draw(f8, lao_idle, 1, 4)
unit_draw(f8, ck_idle, 4, 4)
frames.append(quantize_im(f8, is_opaque=True))

# Frame 9: Lão throws lance! Lance flying across row 4
f9 = get_base_board()
# Lance in flight at col 2.5
f9.paste(vfx_spear, (2*64 + 32, 4*64 + 16), vfx_spear)
unit_draw(f9, khoai_idle, 1, 2)
unit_draw(f9, du_idle, 2, 2)
unit_draw(f9, lao_atk, 1, 4)
unit_draw(f9, ck_idle, 4, 4)
frames.append(quantize_im(f9, is_opaque=True))

# Frame 10: Lance hits CK! Impact sparks C3
f10 = get_base_board()
f10.paste(vfx_impact, (4*64 + 6, 4*64 + 6), vfx_impact)
unit_draw(f10, khoai_idle, 1, 2)
unit_draw(f10, du_idle, 2, 2)
unit_draw(f10, lao_atk, 1, 4)
unit_draw(f10, ck_hurt, 4, 4, off_x=8)
frames.append(quantize_im(f10, is_opaque=True))

# Frame 11: CK dead! Collapses onto ground
f11 = get_base_board()
unit_draw(f11, khoai_idle, 1, 2)
unit_draw(f11, du_idle, 2, 2)
unit_draw(f11, lao_idle, 1, 4)
unit_draw(f11, ck_dead, 4, 4, has_shadow=False)
frames.append(quantize_im(f11, is_opaque=True))

# Frame 12: Board cleared! Three Generals stand triumphant!
f12 = get_base_board()
unit_draw(f12, khoai_idle, 1, 2)
unit_draw(f12, du_idle, 2, 2)
unit_draw(f12, lao_idle, 1, 4)
frames.append(quantize_im(f12, is_opaque=True))

# Frame 13: Victory Badge slams onto screen!
f13 = get_base_board()
unit_draw(f13, khoai_idle, 1, 2)
unit_draw(f13, du_idle, 2, 2)
unit_draw(f13, lao_idle, 1, 4)
# Center stamp: (384 - 160)/2 = 112, (320 - 64)/2 = 128
f13.paste(badge_win, (112, 128), badge_win)
frames.append(quantize_im(f13, is_opaque=True))

# Frame 14-15: Victory lingering
frames.append(frames[-1])
frames.append(frames[-1])

# Save Animation Files
OUT_DEMO_DIR = os.path.join(TOI_UU, "hoat_anh", "demo_map_ba_tuong")
os.makedirs(OUT_DEMO_DIR, exist_ok=True)

for i, f in enumerate(frames):
    f.save(os.path.join(OUT_DEMO_DIR, f"frame_{i:02d}.png"))

durations = [500, 350, 200, 350, 350, 220, 250, 250, 350, 200, 220, 350, 400, 700, 700, 700]

gif_1x = os.path.join(OUT_DEMO_DIR, "demo_map_ba_tuong_combo_1x.gif")
frames[0].save(gif_1x, save_all=True, append_images=frames[1:], duration=durations, loop=0)

# 2x Scale (768 x 640) for high-def pixel inspection
frames_2x = [f.resize((768, 640), Image.NEAREST) for f in frames]
gif_2x = os.path.join(OUT_DEMO_DIR, "demo_map_ba_tuong_combo_2x.gif")
frames_2x[0].save(gif_2x, save_all=True, append_images=frames_2x[1:], duration=durations, loop=0)

# Filmstrip (First 14 key frames x 384 = 5376 x 320)
strip = Image.new("RGBA", (384 * 14, 320), (46, 34, 47, 255))
for i in range(14):
    strip.paste(frames[i], (i * 384, 0))
quantize_im(strip, is_opaque=True).save(os.path.join(OUT_DEMO_DIR, "filmstrip_14_frames.png"))

print(f"✅ Hoàn tất Demo Map Ba Tướng:")
print(f"  -> GIF 2x: {gif_2x}")
print(f"  -> GIF 1x: {gif_1x}")
print(f"  -> Filmstrip: {os.path.join(OUT_DEMO_DIR, 'filmstrip_14_frames.png')}")
