#!/usr/bin/env python3
"""
Tạo hoạt cảnh mẫu hoàn chỉnh: Nguyễn Khoái chém Mạch đao đẩy lùi Kỵ binh xuống sông rồi chết đuối.
- Kích thước sa bàn: 4x2 ô (256x128 px)
  + Hàng trên & Hàng dưới: Cột 0..1 là Đất cỏ, Cột 2 là Bờ sông, Cột 3 là Lòng sông nước sâu
- Diễn tiến hành động (12 frames):
  1. Nguyễn Khoái đứng Cột 1, Kỵ binh đứng Cột 2 mép sông (Idle + Drop shadow + Target indicator).
  2. Nguyễn Khoái vào thế giương đao (Wind-up).
  3. Mạch đao chém quét vòng cung sấm sét (Slash Arc VFX).
  4. Trúng đòn cực mạnh: Tia va chạm C3 lóe sáng, Kỵ binh giật mình chồm lên.
  5. Lực đẩy (Knockback): Kỵ binh bị hất văng trượt lùi từ Cột 2 sang Cột 3.
  6. Rơi trúng mặt nước (Drown 0): chân ngựa chạm nước, sóng nước loang.
  7. Sập xuống làn nước (Drown 1): Bọt nước C4 bắn tung tóe hai bên, ngựa ngập nửa thân.
  8. Chìm sâu (Drown 2): Chỉ còn đầu ngựa và mũ lính nhô lên giữa dòng nước sủi bọt.
  9. Chìm hẳn (Drown 3): Vòng sóng cuộn xoáy, bong bóng nước sủi tăm.
  10. Mặt sông tĩnh lặng dần, bóng nước tan biến.
  11-12. Nguyễn Khoái thu đao oai nghiêm nhìn ra sông, triện son "ĐẠI THẮNG" khải hoàn.

100% chuẩn Resurrect 64, pixel-art hard edges, phóng to 2x (512x256).
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

# Load Tiles
tile_grass_0 = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_co_le_0.png")).convert("RGBA")
tile_grass_1 = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_co_le_1.png")).convert("RGBA")
tile_bank = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_11.png")).convert("RGBA") # Bờ cỏ uốn xuống nước phía đông
tile_river = Image.open(os.path.join(TOI_UU, "dia_hinh/o_nen/tile_0.png")).convert("RGBA") # Nước sông sâu

# Load Units & FX
khoai_idle_east = Image.open(os.path.join(TOI_UU, "khoai/east.png")).convert("RGBA")
khoai_atk_0 = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_0.png")).convert("RGBA")
khoai_atk_1 = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_1.png")).convert("RGBA")
khoai_atk_2 = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_2.png")).convert("RGBA")
khoai_atk_3 = Image.open(os.path.join(TOI_UU, "hoat_anh/tan_cong/khoai/east_3.png")).convert("RGBA")

kb_idle_west = Image.open(os.path.join(TOI_UU, "ky_binh/west.png")).convert("RGBA")
kb_hurt_0 = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/ky_binh/hurt_0.png")).convert("RGBA")
kb_hurt_1 = Image.open(os.path.join(TOI_UU, "hoat_anh/bi_thuong/ky_binh/hurt_1.png")).convert("RGBA")

kb_drown_0 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_0.png")).convert("RGBA")
kb_drown_1 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_1.png")).convert("RGBA")
kb_drown_2 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_2.png")).convert("RGBA")
kb_drown_3 = Image.open(os.path.join(TOI_UU, "hoat_anh/chet_duoi/ky_binh/drown_3.png")).convert("RGBA")

slash_0 = Image.open(os.path.join(TOI_UU, "hieu_ung/vet_chem/vet_chem_0.png")).convert("RGBA")
slash_1 = Image.open(os.path.join(TOI_UU, "hieu_ung/vet_chem/vet_chem_1.png")).convert("RGBA")
slash_2 = Image.open(os.path.join(TOI_UU, "hieu_ung/vet_chem/vet_chem_2.png")).convert("RGBA")
slash_3 = Image.open(os.path.join(TOI_UU, "hieu_ung/vet_chem/vet_chem_3.png")).convert("RGBA")

vfx_impact = Image.open(os.path.join(TOI_UU, "hieu_ung/c3_va_cham.png")).convert("RGBA")
vfx_splash = Image.open(os.path.join(TOI_UU, "hieu_ung/c4_nuoc_ban.png")).convert("RGBA")

shadow_unit = Image.open(os.path.join(TOI_UU, "giao_dien/bong_do/bong_do_quan_32x16.png")).convert("RGBA")
target_frame = Image.open(os.path.join(TOI_UU, "giao_dien/o_co/khung_o_danh_duoc_64x64.png")).convert("RGBA")
badge_win = Image.open(os.path.join(TOI_UU, "giao_dien/trien_an/trien_dai_thang_80x32.png")).convert("RGBA")

# Build Background (4 cols x 2 rows = 256 x 128)
def create_board_bg():
    bg = Image.new("RGBA", (256, 128), (0, 0, 0, 255))
    for row in range(2):
        y = row * 64
        # col 0: grass 0
        bg.paste(tile_grass_0, (0, y))
        # col 1: grass 1
        bg.paste(tile_grass_1, (64, y))
        # col 2: river bank
        bg.paste(tile_bank, (128, y))
        # col 3: river water
        bg.paste(tile_river, (192, y))
    return bg

# Coordinates on board:
# Khoai stands at Col 1, Row 1 (x=64, y=40, feet at y=64+48=112)
# KB stands at Col 2, Row 1 (x=128, y=40, feet at y=112)
# River tile is at Col 3, Row 1 (x=192, y=40)

frames = []
KHOAI_X = 64
KB_START_X = 128
RIVER_X = 192
BASE_Y = 40 # Unit draw Y (64x64)

# 12 Frames Sequence:
for f in range(12):
    f_im = create_board_bg()
    
    # Shadows
    # Khoai shadow
    f_im.paste(shadow_unit, (KHOAI_X + 16, BASE_Y + 44), shadow_unit)
    
    if f == 0:
        # Frame 0: Idle stance & Target lock
        # Target frame on Col 2
        f_im.paste(target_frame, (KB_START_X, 64), target_frame)
        # Shadow KB
        f_im.paste(shadow_unit, (KB_START_X + 16, BASE_Y + 44), shadow_unit)
        # Units
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        f_im.paste(kb_idle_west, (KB_START_X, BASE_Y), kb_idle_west)
        
    elif f == 1:
        # Frame 1: Khoai wind-up
        f_im.paste(shadow_unit, (KB_START_X + 16, BASE_Y + 44), shadow_unit)
        f_im.paste(khoai_atk_0, (KHOAI_X, BASE_Y), khoai_atk_0)
        f_im.paste(kb_idle_west, (KB_START_X, BASE_Y), kb_idle_west)
        
    elif f == 2:
        # Frame 2: Slash Arc emerges
        f_im.paste(shadow_unit, (KB_START_X + 16, BASE_Y + 44), shadow_unit)
        f_im.paste(khoai_atk_1, (KHOAI_X, BASE_Y), khoai_atk_1)
        f_im.paste(slash_1, (KHOAI_X + 36, BASE_Y + 8), slash_1)
        f_im.paste(kb_idle_west, (KB_START_X, BASE_Y), kb_idle_west)
        
    elif f == 3:
        # Frame 3: Slash Impact! Knockback starts, impact sparks C3
        f_im.paste(shadow_unit, (KB_START_X + 22, BASE_Y + 44), shadow_unit)
        f_im.paste(khoai_atk_2, (KHOAI_X + 4, BASE_Y), khoai_atk_2)
        f_im.paste(slash_2, (KHOAI_X + 44, BASE_Y + 4), slash_2)
        f_im.paste(vfx_impact, (KB_START_X - 4, BASE_Y + 8), vfx_impact)
        f_im.paste(kb_hurt_0, (KB_START_X + 8, BASE_Y - 4), kb_hurt_0)
        
    elif f == 4:
        # Frame 4: Flying back through the air towards river (x=160)
        f_im.paste(slash_3, (KHOAI_X + 48, BASE_Y + 4), slash_3)
        f_im.paste(khoai_atk_3, (KHOAI_X + 2, BASE_Y), khoai_atk_3)
        # Shadow sliding into bank edge
        f_im.paste(shadow_unit, (KB_START_X + 40, BASE_Y + 44), shadow_unit)
        f_im.paste(kb_hurt_1, (KB_START_X + 36, BASE_Y - 6), kb_hurt_1)
        
    elif f == 5:
        # Frame 5: Hits the river surface! Drown frame 0
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        # Horse hits river at x=192
        f_im.paste(kb_drown_0, (RIVER_X, BASE_Y), kb_drown_0)
        
    elif f == 6:
        # Frame 6: Sinking in water (Drown 1) + Massive water splash C4
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        f_im.paste(kb_drown_1, (RIVER_X, BASE_Y), kb_drown_1)
        f_im.paste(vfx_splash, (RIVER_X + 8, BASE_Y + 12), vfx_splash)
        
    elif f == 7:
        # Frame 7: Sinking deeper (Drown 2)
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        f_im.paste(kb_drown_2, (RIVER_X, BASE_Y), kb_drown_2)
        
    elif f == 8:
        # Frame 8: Completely submerged (Drown 3)
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        f_im.paste(kb_drown_3, (RIVER_X, BASE_Y), kb_drown_3)
        
    elif f == 9:
        # Frame 9: Water ripples fading
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        # Fading ripples
        d = ImageDraw.Draw(f_im)
        d.ellipse([RIVER_X + 16, BASE_Y + 44, RIVER_X + 48, BASE_Y + 54], outline=(104, 194, 211, 255), width=1)
        
    elif f == 10:
        # Frame 10: River calm, Khoai stands victorious
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        
    elif f == 11:
        # Frame 11: Victory Stamp appears!
        f_im.paste(khoai_idle_east, (KHOAI_X, BASE_Y), khoai_idle_east)
        f_im.paste(badge_win, (168, 12), badge_win)
        
    q_f = quantize_im(f_im, is_opaque=True)
    frames.append(q_f)

# Save Individual Frames, Filmstrip & GIFs
OUT_DEMO_DIR = os.path.join(TOI_UU, "hoat_anh", "demo_day_song")
os.makedirs(OUT_DEMO_DIR, exist_ok=True)

for i, f in enumerate(frames):
    f.save(os.path.join(OUT_DEMO_DIR, f"frame_{i:02d}.png"))

# Build Horizontal Filmstrip (12 frames x 256 = 3072 x 128)
strip = Image.new("RGBA", (256 * len(frames), 128), (46, 34, 47, 255))
for i, f in enumerate(frames):
    strip.paste(f, (i * 256, 0))
quantize_im(strip, is_opaque=True).save(os.path.join(OUT_DEMO_DIR, "filmstrip_12_frames.png"))

# Save GIF 1x
gif_1x_path = os.path.join(OUT_DEMO_DIR, "ky_binh_bi_day_xuong_song_1x.gif")
durations = [350, 200, 150, 150, 180, 180, 220, 220, 240, 280, 300, 700]

frames[0].save(
    gif_1x_path, save_all=True, append_images=frames[1:],
    duration=durations, loop=0
)

# Save GIF 2x (512 x 256) for crisp pixel art viewing
frames_2x = [f.resize((512, 256), Image.NEAREST) for f in frames]
gif_2x_path = os.path.join(OUT_DEMO_DIR, "ky_binh_bi_day_xuong_song_2x.gif")
frames_2x[0].save(
    gif_2x_path, save_all=True, append_images=frames_2x[1:],
    duration=durations, loop=0
)

print(f"✅ Hoàn tất tạo hoạt cảnh: {gif_2x_path}")
print(f"✅ Dải filmstrip: {os.path.join(OUT_DEMO_DIR, 'filmstrip_12_frames.png')}")
