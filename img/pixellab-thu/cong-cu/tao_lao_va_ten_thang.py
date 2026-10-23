#!/usr/bin/env python3
"""
Tạo bộ Mũi Lao Bay (C1) và Mũi Tên Bay (C2) 4 hướng thẳng tắp chuẩn Pixel Art:
- Đông (bay ngang sang phải)
- Tây (bay ngang sang trái)
- Bắc (bay dọc lên trên)
- Nam (bay dọc xuống dưới)

Đặc điểm ngọn lao Phạm Ngũ Lão:
- Mũi thép lá râm sắc nhọn ánh bạc (#d9effc, #94b0c2, viền #2e222f)
- Cổ giáo buộc dải lụa đỏ Đại Việt (#d53c2a, #b13e53) phất phới theo chiều gió
- Thân cán gỗ lim chắc chắn (#8f563b, #46222f)
- Vệt khí động (wind streaks) thẳng hàng tuyệt đối, không nằm chéo 45 độ!

100% chuẩn Resurrect 64, 1-bit alpha.
"""

import os
from PIL import Image, ImageDraw
import numpy as np

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")

TOI_UU = os.path.join(BASE_DIR, "toi_uu")
VFX_DIR = os.path.join(TOI_UU, "hieu_ung")

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
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

# 1. TẠO CÂY LAO BAY THẲNG HƯỚNG ĐÔNG (48x16 px)
# Đi ngang từ trái qua phải (East)
lao_east = Image.new("RGBA", (48, 16), (0, 0, 0, 0))
d = ImageDraw.Draw(lao_east)
cy = 8 # Trục ngang giữa

# 1.1 Vệt gió khí động (Wind streak trailing behind)
d.line([2, cy-2, 12, cy-2], fill=(217, 239, 252, 255), width=1)
d.line([0, cy, 14, cy], fill=(255, 255, 255, 255), width=1)
d.line([4, cy+2, 16, cy+2], fill=(217, 239, 252, 255), width=1)

# 1.2 Cán gỗ lim (Wooden shaft: x=12..36)
d.line([12, cy, 36, cy], fill=(46, 34, 47, 255), width=3) # outline
d.line([12, cy, 36, cy], fill=(143, 86, 59, 255), width=1) # wood

# 1.3 Dải lụa đỏ thắm Đại Việt buộc ở cổ giáo (Red silk tassel: x=30..36)
d.polygon([(30, cy+1), (24, cy+4), (20, cy+3), (25, cy+1)], fill=(213, 60, 42, 255))
d.polygon([(32, cy-1), (26, cy-3), (22, cy-2), (28, cy-1)], fill=(177, 62, 83, 255))

# 1.4 Mũi giáo thép lá râm sắc nhọn (Spearhead: x=34..46)
# Outline
d.polygon([(34, cy-3), (46, cy), (34, cy+3)], fill=(46, 34, 47, 255))
# Steel interior (Bright silver blade)
d.polygon([(35, cy-2), (44, cy), (35, cy+2)], fill=(217, 239, 252, 255))
d.line([(35, cy), (43, cy)], fill=(255, 255, 255, 255), width=1) # spine gleam

q_lao_e = quantize_im(lao_east)
q_lao_e.save(os.path.join(VFX_DIR, "c1_lao_bay_dong.png"))
q_lao_e.save(os.path.join(VFX_DIR, "c1_lao_bay.png")) # Default horizontal

# 1.5 Các hướng Tây, Bắc, Nam
q_lao_w = quantize_im(q_lao_e.transpose(Image.FLIP_LEFT_RIGHT))
q_lao_w.save(os.path.join(VFX_DIR, "c1_lao_bay_tay.png"))

# Xoay dọc 90 độ cho Bắc và Nam (16x48)
q_lao_n = quantize_im(q_lao_e.rotate(90, expand=True, resample=Image.NEAREST))
q_lao_n.save(os.path.join(VFX_DIR, "c1_lao_bay_bac.png"))

q_lao_s = quantize_im(q_lao_e.rotate(-90, expand=True, resample=Image.NEAREST))
q_lao_s.save(os.path.join(VFX_DIR, "c1_lao_bay_nam.png"))
print("✅ Đã tạo c1_lao_bay 4 hướng thẳng tắp!")

# 2. TẠO MŨI TÊN BAY THẲNG (C2) - 32x12 px
arrow_east = Image.new("RGBA", (32, 12), (0, 0, 0, 0))
ad = ImageDraw.Draw(arrow_east)
acy = 6

# Lông đuôi tên (Fletching: x=2..8)
ad.polygon([(2, acy-3), (8, acy-1), (8, acy+1), (2, acy+3)], fill=(148, 176, 194, 255))
# Cán tên (Shaft: x=6..24)
ad.line([6, acy, 24, acy], fill=(46, 34, 47, 255), width=3)
ad.line([6, acy, 24, acy], fill=(186, 145, 88, 255), width=1)
# Mũi tên sắt (Arrowhead: x=22..30)
ad.polygon([(22, acy-2), (30, acy), (22, acy+2)], fill=(46, 34, 47, 255))
ad.polygon([(23, acy-1), (28, acy), (23, acy+1)], fill=(217, 239, 252, 255))

q_arr_e = quantize_im(arrow_east)
q_arr_e.save(os.path.join(VFX_DIR, "c2_ten_bay_dong.png"))
q_arr_e.save(os.path.join(VFX_DIR, "c2_ten_bay.png"))

q_arr_w = quantize_im(q_arr_e.transpose(Image.FLIP_LEFT_RIGHT))
q_arr_w.save(os.path.join(VFX_DIR, "c2_ten_bay_tay.png"))

q_arr_n = quantize_im(q_arr_e.rotate(90, expand=True, resample=Image.NEAREST))
q_arr_n.save(os.path.join(VFX_DIR, "c2_ten_bay_bac.png"))

q_arr_s = quantize_im(q_arr_e.rotate(-90, expand=True, resample=Image.NEAREST))
q_arr_s.save(os.path.join(VFX_DIR, "c2_ten_bay_nam.png"))
print("✅ Đã tạo c2_ten_bay 4 hướng thẳng tắp!")
