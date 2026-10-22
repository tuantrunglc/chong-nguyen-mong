import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
VAT_CAN_DIR = os.path.join(BASE_DIR, "toi_uu", "dia_hinh", "vat_can")
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")

# Load base house: lang.png
house = Image.open(os.path.join(BASE_DIR, "lang.png")).convert("RGBA")
smoke = Image.open(os.path.join(BASE_DIR, "nhom_a", "khoi.png")).convert("RGBA")

# We create:
# 1) a6_lang_que.png: 64x96 (original compact size)
# 2) a6_lang_chay_khoi.png: 64x128 (house at bottom, aligned at y=32)
# And also 64x128 version of both for engines that prefer identical canvas dimensions.

H_W, H_H = 64, 128
HOFF_Y = 32 # y=32 so house bottom y=113

# 1. Base House (Normal)
im_normal_128 = Image.new("RGBA", (H_W, H_H), (0, 0, 0, 0))
im_normal_128.alpha_composite(house, (0, HOFF_Y))

# 2. Damaged / Burning House (64x128)
im_burning_128 = Image.new("RGBA", (H_W, H_H), (0, 0, 0, 0))
im_burning_128.alpha_composite(house, (0, HOFF_Y))

# Resurrect 64 color constants
C_OUTLINE = (46, 34, 47, 255)     # #2e222f
C_CHAR = (49, 54, 56, 255)        # #313638 (than tối)
C_DARK_WOOD = (76, 62, 36, 255)   # #4c3e24
C_SMOKE_DARK = (98, 85, 101, 255) # #625565
C_SMOKE_MID = (127, 112, 138, 255)# #7f708a
C_SMOKE_LIGHT = (155, 171, 178, 255) # #9babb2
C_RED_FIRE = (179, 56, 49, 255)   # #b33831
C_ORANGE = (230, 144, 78, 255)    # #e6904e
C_GOLD = (251, 185, 84, 255)      # #fbb954
C_SPARK = (255, 236, 39, 255)     # #ffec27

b_pix = im_burning_128.load()

# Step A: Place smoke plume with natural billow
# Take upper smoke from khoi.png (y: 0..58)
smoke_top = smoke.crop((0, 0, 64, 58))
# Composite smoke at y=0, shifted slightly to center above the fire breach
im_burning_128.alpha_composite(smoke_top, (3, 0))

# Step B: Sculpt organic smoke & flame billows connecting smoke_top into roof
# Draw smoke puffs swirling around the breach between y=48 and y=62
smoke_clusters = [
    # Cụm khói phồng bên trái che bớt thân cột
    (24, 50, C_SMOKE_DARK), (25, 50, C_SMOKE_MID), (26, 50, C_SMOKE_LIGHT), (27, 50, C_SMOKE_MID),
    (23, 51, C_OUTLINE), (24, 51, C_SMOKE_MID), (25, 51, C_SMOKE_LIGHT), (26, 51, C_SMOKE_MID), (27, 51, C_SMOKE_DARK),
    (23, 52, C_OUTLINE), (24, 52, C_SMOKE_DARK), (25, 52, C_SMOKE_MID), (26, 52, C_SMOKE_DARK), (27, 52, C_OUTLINE),
    (24, 53, C_OUTLINE), (25, 53, C_OUTLINE), (26, 53, C_OUTLINE),
    
    # Cụm khói cuộn bên phải phồng ra phía mái hông
    (38, 48, C_SMOKE_DARK), (39, 48, C_SMOKE_MID), (40, 48, C_SMOKE_LIGHT), (41, 48, C_OUTLINE),
    (38, 49, C_SMOKE_MID), (39, 49, C_SMOKE_LIGHT), (40, 49, C_SMOKE_LIGHT), (41, 49, C_SMOKE_MID), (42, 49, C_OUTLINE),
    (39, 50, C_SMOKE_MID), (40, 50, C_SMOKE_LIGHT), (41, 50, C_SMOKE_MID), (42, 50, C_OUTLINE),
    (40, 51, C_SMOKE_DARK), (41, 51, C_SMOKE_MID), (42, 51, C_OUTLINE),
    (41, 52, C_OUTLINE), (42, 52, C_OUTLINE),
    
    # Khói ở giữa chân cuộn khói nối với mái nhà
    (28, 52, C_SMOKE_MID), (29, 52, C_SMOKE_LIGHT), (30, 52, C_SMOKE_MID), (31, 52, C_SMOKE_DARK),
    (28, 53, C_SMOKE_DARK), (29, 53, C_SMOKE_MID), (30, 53, C_SMOKE_LIGHT), (31, 53, C_SMOKE_MID), (32, 53, C_SMOKE_DARK),
    (29, 54, C_OUTLINE), (30, 54, C_SMOKE_DARK), (31, 54, C_SMOKE_MID), (32, 54, C_SMOKE_LIGHT), (33, 54, C_SMOKE_MID), (34, 54, C_OUTLINE),
    (30, 55, C_OUTLINE), (31, 55, C_SMOKE_DARK), (32, 55, C_SMOKE_MID), (33, 55, C_SMOKE_LIGHT), (34, 55, C_SMOKE_MID), (35, 55, C_OUTLINE),
    (31, 56, C_OUTLINE), (32, 56, C_SMOKE_DARK), (33, 56, C_SMOKE_MID), (34, 56, C_SMOKE_MID), (35, 56, C_OUTLINE)
]

for sx, sy, scol in smoke_clusters:
    b_pix[sx, sy] = scol

# Step C: Ngọn lửa bùng cháy từ lỗ thủng mái tranh (y: 56..64)
flame_pixels = [
    # Viền đen/cháy quanh lỗ thủng mái
    (30, 57, C_OUTLINE), (31, 57, C_CHAR), (32, 57, C_RED_FIRE), (33, 57, C_ORANGE), (34, 57, C_GOLD), (35, 57, C_SPARK), (36, 57, C_GOLD), (37, 57, C_ORANGE), (38, 57, C_RED_FIRE), (39, 57, C_CHAR), (40, 57, C_OUTLINE),
    (30, 58, C_OUTLINE), (31, 58, C_CHAR), (32, 58, C_RED_FIRE), (33, 58, C_GOLD), (34, 58, C_SPARK), (35, 58, C_SPARK), (36, 58, C_GOLD), (37, 58, C_ORANGE), (38, 58, C_RED_FIRE), (39, 58, C_CHAR), (40, 58, C_OUTLINE),
    (31, 59, C_OUTLINE), (32, 59, C_CHAR), (33, 59, C_RED_FIRE), (34, 59, C_ORANGE), (35, 59, C_GOLD), (36, 59, C_GOLD), (37, 59, C_ORANGE), (38, 59, C_RED_FIRE), (39, 59, C_CHAR), (40, 59, C_OUTLINE),
    (32, 60, C_OUTLINE), (33, 60, C_CHAR), (34, 60, C_RED_FIRE), (35, 60, C_ORANGE), (36, 60, C_ORANGE), (37, 60, C_RED_FIRE), (38, 60, C_CHAR), (39, 60, C_OUTLINE),
    (33, 61, C_OUTLINE), (34, 61, C_CHAR), (35, 61, C_CHAR), (36, 61, C_CHAR), (37, 61, C_CHAR), (38, 61, C_OUTLINE),
    
    # Lưỡi lửa liếm ngược lên khói
    (34, 54, C_RED_FIRE), (35, 54, C_ORANGE), (36, 54, C_GOLD), (37, 54, C_ORANGE),
    (35, 53, C_RED_FIRE), (36, 53, C_GOLD), (37, 53, C_SPARK), (38, 53, C_ORANGE),
    (36, 52, C_ORANGE), (37, 52, C_GOLD), (38, 52, C_RED_FIRE),
    (37, 51, C_GOLD), (38, 51, C_ORANGE),
    (37, 50, C_RED_FIRE)
]

for fx, fy, fcol in flame_pixels:
    b_pix[fx, fy] = fcol

# Kèo tre bắt chéo trên nóc bị ám khói than đen một nửa
b_pix[30, 46] = C_CHAR
b_pix[31, 46] = C_CHAR
b_pix[31, 47] = C_OUTLINE
b_pix[32, 48] = C_CHAR
b_pix[33, 49] = C_CHAR

# Tàn lửa bay lơ lửng trong khói (Floating sparks)
sparks = [
    (38, 44, C_SPARK), (33, 42, C_GOLD), (42, 38, C_ORANGE), (35, 36, C_SPARK),
    (40, 31, C_GOLD), (32, 27, C_SPARK), (41, 22, C_ORANGE), (37, 18, C_SPARK),
    (43, 14, C_GOLD), (34, 11, C_SPARK), (39, 6, C_SPARK)
]
for sx, sy, scol in sparks:
    b_pix[sx, sy] = scol

# Lượng tử hóa 100% Resurrect 64
from toi_uu_nhom_a import quantize_image_fast

final_normal = quantize_image_fast(house, force_opaque=False) # 64x96
final_normal_128 = quantize_image_fast(im_normal_128, force_opaque=False) # 64x128
final_burning_128 = quantize_image_fast(im_burning_128, force_opaque=False) # 64x128

# Lưu vào VAT_CAN_DIR
out_que_path = os.path.join(VAT_CAN_DIR, "a6_lang_que.png")
out_chay_path = os.path.join(VAT_CAN_DIR, "a6_lang_chay_khoi.png")

# Lưu cả 2 bản
final_normal.save(out_que_path)
final_burning_128.save(out_chay_path)

# Lưu thêm bản đồng kích thước 64x128 cho engine Godot swap texture
final_normal_128.save(os.path.join(VAT_CAN_DIR, "a6_lang_que_128.png"))

print(f"-> Đã lưu a6_lang_que.png: {final_normal.size}")
print(f"-> Đã lưu a6_lang_chay_khoi.png: {final_burning_128.size}")
