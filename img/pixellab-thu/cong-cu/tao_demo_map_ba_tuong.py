#!/usr/bin/env python3
"""
Tạo Demo Mô Phỏng Bàn Cờ Thử Ba Đòn Đặc Sắc (Phiên bản trau chuốt theo phản hồi):
- Bàn cờ 6x5 ô vuông 64x64 (384x320 px)
- 3 tướng Đại Việt & 3 quân Nguyên
- 3 đòn phối hợp liên hoàn trong 1 hiệp:
  1. Nguyễn Khoái chém Mạch đao đẩy Bộ binh văng lên không, CHẠM VÀO CHÔNG (cọc đâm sập) RỒI MỚI GỤC NGÃ.
  2. Trần Khánh Dư giữ nguyên ÁO ĐỎ ĐẠI VIỆT khi móc câu liêm kéo Kỵ binh rơi tõm xuống sông chết đuối.
  3. Phạm Ngũ Lão phóng lao cắm phập Cung kỵ -> Cung kỵ giữ đúng HƯỚNG TÂY (không bị xoay hướng), gục ngã tại chỗ.
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
khoai_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_2.png")).convert("RGBA")

# Dư (now wearing 100% crimson red robe)
du_idle = Image.open(os.path.join(TOI_UU, "du/east.png")).convert("RGBA")
du_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/du/east_1.png")).convert("RGBA")

lao_idle = Image.open(os.path.join(TOI_UU, "lao/east.png")).convert("RGBA")
lao_atk = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/lao/east_2.png")).convert("RGBA")

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

# Cung kỵ facing WEST (Consistent orientation!)
ck_idle = Image.open(os.path.join(TOI_UU, "cung_ky/west.png")).convert("RGBA")
ck_hurt_w = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/cung_ky/hurt_west_1.png")).convert("RGBA")
ck_dead_w0 = Image.open(os.path.join(TOI_UU, "hoat_anh/guc_nga/cung_ky/death_west_0.png")).convert("RGBA")
ck_dead_w1 = Image.open(os.path.join(TOI_UU, "hoat_anh/guc_nga/cung_ky/death_west_1.png")).convert("RGBA")
ck_dead_w3 = Image.open(os.path.join(TOI_UU, "hoat_anh/guc_nga/cung_ky/death_west_3.png")).convert("RGBA")

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

def get_base_board():
    board = Image.new("RGBA", (384, 320), (0, 0, 0, 255))
    for r in range(5):
        for c in range(6):
            x, y = c * 64, r * 64
            if (c, r) == (1, 0):
                board.paste(tile_grass_0, (x, y))
                board.paste(tile_spikes, (x, y), tile_spikes)
            elif (c, r) == (3, 2):
                board.paste(tile_river, (x, y))
            elif c == 2 and r == 2:
                board.paste(tile_bank, (x, y))
            elif (c + r) % 2 == 0:
                board.paste(tile_grass_0, (x, y))
            else:
                board.paste(tile_grass_1, (x, y))
    return board

frames = []

def tile_pos(c, r):
    return (c * 64, r * 64)

def unit_draw(canvas, sprite, c, r, off_x=0, off_y=0, has_shadow=True):
    x, y = c * 64 + off_x, r * 64 + off_y
    if has_shadow:
        canvas.paste(shadow, (x + 16, y + 44), shadow)
    canvas.paste(sprite, (x, y), sprite)

# ----------------------------------------------------
# 18-FRAME REFINED CHOREOGRAPHY
# ----------------------------------------------------

# Frame 0: Battle Start (Telegraphs)
f0 = get_base_board()
f0.paste(frame_atk, tile_pos(1, 2), frame_atk)
f0.paste(num_1, (1*64 + 48, 2*64 + 44), num_1)
f0.paste(arrow_west, tile_pos(4, 2), arrow_west)
f0.paste(num_2, (4*64 + 48, 2*64 + 44), num_2)
f0.paste(frame_atk, tile_pos(1, 4), frame_atk)
f0.paste(num_3, (1*64 + 48, 4*64 + 44), num_3)
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

# Frame 2: Khoai strikes Mạch đao! Impact on BB (1, 1)
f2 = get_base_board()
f2.paste(vfx_slash, (1*64 + 8, 1*64 + 20), vfx_slash)
f2.paste(vfx_impact, (1*64 + 8, 1*64 + 8), vfx_impact)
unit_draw(f2, bb_hurt, 1, 1, off_y=-6)
unit_draw(f2, khoai_atk, 1, 2)
unit_draw(f2, du_idle, 2, 2)
unit_draw(f2, kb_idle, 4, 2)
unit_draw(f2, lao_idle, 1, 4)
unit_draw(f2, ck_idle, 4, 4)
frames.append(quantize_im(f2, is_opaque=True))

# Frame 3: BB is pushed, flying in the air towards Spikes (y sliding between row 1 and 0)! Still alive/hurt!
f3 = get_base_board()
unit_draw(f3, bb_hurt, 1, 0, off_y=28, has_shadow=False) # flying over boundary
unit_draw(f3, khoai_idle, 1, 2)
unit_draw(f3, du_idle, 2, 2)
unit_draw(f3, kb_idle, 4, 2)
unit_draw(f3, lao_idle, 1, 4)
unit_draw(f3, ck_idle, 4, 4)
frames.append(quantize_im(f3, is_opaque=True))

# Frame 4: BB IMPACTS & TOUCHES SPIKES (1, 0)! Spikes impale! Blood/impact sparks burst!
f4 = get_base_board()
f4.paste(vfx_spikes_hit, (1*64 + 8, 0*64 + 8), vfx_spikes_hit)
f4.paste(vfx_impact, (1*64 + 12, 0*64 + 14), vfx_impact)
unit_draw(f4, bb_hurt, 1, 0, off_y=4, has_shadow=False) # slammed onto spikes, flinching!
unit_draw(f4, khoai_idle, 1, 2)
unit_draw(f4, du_idle, 2, 2)
unit_draw(f4, kb_idle, 4, 2)
unit_draw(f4, lao_idle, 1, 4)
unit_draw(f4, ck_idle, 4, 4)
frames.append(quantize_im(f4, is_opaque=True))

# Frame 5: AFTER TOUCHING SPIKES -> BB finally collapses & dies on the spikes!
f5 = get_base_board()
unit_draw(f5, bb_dead, 1, 0, has_shadow=False) # dead flat on spikes
unit_draw(f5, khoai_idle, 1, 2)
unit_draw(f5, du_idle, 2, 2)
unit_draw(f5, kb_idle, 4, 2)
unit_draw(f5, lao_idle, 1, 4)
unit_draw(f5, ck_idle, 4, 4)
frames.append(quantize_im(f5, is_opaque=True))

# Frame 6: Select Dư (Crisp Crimson Red Robe) -> Target KB (4, 2)
f6 = get_base_board()
f6.paste(frame_sel, tile_pos(2, 2), frame_sel)
f6.paste(frame_atk, tile_pos(4, 2), frame_atk)
unit_draw(f6, khoai_idle, 1, 2)
unit_draw(f6, du_idle, 2, 2)
unit_draw(f6, kb_idle, 4, 2)
unit_draw(f6, lao_idle, 1, 4)
unit_draw(f6, ck_idle, 4, 4)
frames.append(quantize_im(f6, is_opaque=True))

# Frame 7: Dư hooks & pulls KB (DƯ WEARS FULL RED ROBE)!
f7 = get_base_board()
d7 = ImageDraw.Draw(f7)
d7.line([2*64 + 48, 2*64 + 32, 4*64 - 10, 2*64 + 32], fill=(171, 148, 122, 255), width=2)
unit_draw(f7, khoai_idle, 1, 2)
unit_draw(f7, du_atk, 2, 2) # Now confirmed 100% crimson red robe!
unit_draw(f7, kb_hurt, 3, 2, off_x=16, off_y=-4, has_shadow=False)
unit_draw(f7, lao_idle, 1, 4)
unit_draw(f7, ck_idle, 4, 4)
frames.append(quantize_im(f7, is_opaque=True))

# Frame 8: KB hits river! Water splash C4
f8 = get_base_board()
f8.paste(vfx_splash, (3*64 + 8, 2*64 + 10), vfx_splash)
unit_draw(f8, khoai_idle, 1, 2)
unit_draw(f8, du_idle, 2, 2)
unit_draw(f8, kb_drown_1, 3, 2, has_shadow=False)
unit_draw(f8, lao_idle, 1, 4)
unit_draw(f8, ck_idle, 4, 4)
frames.append(quantize_im(f8, is_opaque=True))

# Frame 9: KB sinks deep into river
f9 = get_base_board()
unit_draw(f9, khoai_idle, 1, 2)
unit_draw(f9, du_idle, 2, 2)
unit_draw(f9, kb_drown_2, 3, 2, has_shadow=False)
unit_draw(f9, lao_idle, 1, 4)
unit_draw(f9, ck_idle, 4, 4)
frames.append(quantize_im(f9, is_opaque=True))

# Frame 10: KB submerged! Select Lão -> Target CK (4, 4)
f10 = get_base_board()
unit_draw(f10, kb_drown_3, 3, 2, has_shadow=False)
f10.paste(frame_sel, tile_pos(1, 4), frame_sel)
f10.paste(frame_atk, tile_pos(4, 4), frame_atk)
unit_draw(f10, khoai_idle, 1, 2)
unit_draw(f10, du_idle, 2, 2)
unit_draw(f10, lao_idle, 1, 4)
unit_draw(f10, ck_idle, 4, 4)
frames.append(quantize_im(f10, is_opaque=True))

# Frame 11: Lão throws lance! Lance flying horizontally across row 4
f11 = get_base_board()
f11.paste(vfx_spear, (2*64 + 32, 4*64 + 16), vfx_spear)
unit_draw(f11, khoai_idle, 1, 2)
unit_draw(f11, du_idle, 2, 2)
unit_draw(f11, lao_atk, 1, 4)
unit_draw(f11, ck_idle, 4, 4)
frames.append(quantize_im(f11, is_opaque=True))

# Frame 12: Lance strikes CK! (CK FACING WEST - RECOILS WEST)
f12 = get_base_board()
f12.paste(vfx_impact, (4*64 + 6, 4*64 + 6), vfx_impact)
unit_draw(f12, khoai_idle, 1, 2)
unit_draw(f12, du_idle, 2, 2)
unit_draw(f12, lao_atk, 1, 4)
unit_draw(f12, ck_hurt_w, 4, 4, off_x=6) # Stays facing West!
frames.append(quantize_im(f12, is_opaque=True))

# Frame 13: CK front knees buckle (STAYS FACING WEST)
f13 = get_base_board()
unit_draw(f13, khoai_idle, 1, 2)
unit_draw(f13, du_idle, 2, 2)
unit_draw(f13, lao_idle, 1, 4)
unit_draw(f13, ck_dead_w1, 4, 4, has_shadow=False) # Knees buckling facing West!
frames.append(quantize_im(f13, is_opaque=True))

# Frame 14: CK collapsed flat on ground (STAYS FACING WEST)
f14 = get_base_board()
unit_draw(f14, khoai_idle, 1, 2)
unit_draw(f14, du_idle, 2, 2)
unit_draw(f14, lao_idle, 1, 4)
unit_draw(f14, ck_dead_w3, 4, 4, has_shadow=False) # Motionless facing West!
frames.append(quantize_im(f14, is_opaque=True))

# Frame 15: Board cleared! Three Generals stand victorious!
f15 = get_base_board()
unit_draw(f15, khoai_idle, 1, 2)
unit_draw(f15, du_idle, 2, 2)
unit_draw(f15, lao_idle, 1, 4)
frames.append(quantize_im(f15, is_opaque=True))

# Frame 16: Victory Seal slams onto board!
f16 = get_base_board()
unit_draw(f16, khoai_idle, 1, 2)
unit_draw(f16, du_idle, 2, 2)
unit_draw(f16, lao_idle, 1, 4)
f16.paste(badge_win, (112, 128), badge_win)
frames.append(quantize_im(f16, is_opaque=True))

# Frame 17: Hold victory
frames.append(frames[-1])

# Save Animation Files
OUT_DEMO_DIR = os.path.join(TOI_UU, "hoat_anh", "demo_map_ba_tuong")
os.makedirs(OUT_DEMO_DIR, exist_ok=True)

for i, f in enumerate(frames):
    f.save(os.path.join(OUT_DEMO_DIR, f"frame_{i:02d}.png"))

durations = [500, 350, 200, 220, 300, 350, 350, 220, 250, 250, 350, 200, 220, 240, 350, 400, 800, 800]

gif_1x = os.path.join(OUT_DEMO_DIR, "demo_map_ba_tuong_combo_1x.gif")
frames[0].save(gif_1x, save_all=True, append_images=frames[1:], duration=durations, loop=0)

frames_2x = [f.resize((768, 640), Image.NEAREST) for f in frames]
gif_2x = os.path.join(OUT_DEMO_DIR, "demo_map_ba_tuong_combo_2x.gif")
frames_2x[0].save(gif_2x, save_all=True, append_images=frames_2x[1:], duration=durations, loop=0)

# Filmstrip (First 16 frames x 384 = 6144 x 320)
strip = Image.new("RGBA", (384 * 16, 320), (46, 34, 47, 255))
for i in range(16):
    strip.paste(frames[i], (i * 384, 0))
quantize_im(strip, is_opaque=True).save(os.path.join(OUT_DEMO_DIR, "filmstrip_14_frames.png"))

print(f"✅ Hoàn tất Demo Map Ba Tướng (Đã sửa 3 điểm góp ý):")
print(f"  -> GIF 2x: {gif_2x}")
