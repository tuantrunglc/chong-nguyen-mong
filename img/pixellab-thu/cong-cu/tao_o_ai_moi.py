import os
import sys
from PIL import Image, ImageDraw

# Colors from Resurrect 64
C_TRANS = (0, 0, 0, 0)
C_DARK = (46, 34, 47, 255)       # #2e222f - Outline / darkest shadow
C_SHADOW = (62, 53, 70, 255)     # #3e3546 - Deep stone shadow
C_STONE_DARK = (98, 85, 101, 255)# #625565 - Slate stone
C_STONE_MID = (127, 112, 138, 255)# #7f708a - Mid stone
C_STONE_LIGHT = (155, 171, 178, 255)# #9babb2 - Highlight stone
C_STONE_PALE = (199, 220, 208, 255)# #c7dcd0 - Bright stone edge

C_MOSS_DARK = (55, 78, 74, 255)  # #374e4a - Dark moss
C_MOSS_MID = (22, 90, 76, 255)   # #165a4c - Green moss
C_MOSS_LIGHT = (103, 102, 51, 255)# #676633 - Olive moss/lichen

C_WOOD_DARK = (76, 62, 36, 255)  # #4c3e24 - Dark oak wood
C_WOOD_MID = (158, 69, 57, 255)  # #9e4539 - Reddish wood
C_WOOD_LIGHT = (171, 148, 122, 255)# #ab947a - Weathered timber
C_WOOD_WARM = (205, 104, 61, 255)# #cd683d - Golden timber

C_BRONZE = (230, 144, 78, 255)   # #e6904e - Bronze fitting
C_GOLD = (251, 185, 84, 255)     # #fbb954 - Gold trim/stud
C_IRON = (78, 74, 78, 255)       # Iron spike band

C_FLAG_DARK = (122, 48, 69, 255) # #7a3045 - Deep lacquer crimson
C_FLAG_RED = (174, 35, 52, 255)  # #ae2334 - Đại Việt red banner
C_FLAG_GOLD = (249, 194, 43, 255)# #f9c22b - Banner tassel/fringe

def create_base_rampart():
    """Tạo khối nền lũy đá kiên cố 64x64."""
    im = Image.new("RGBA", (64, 64), C_TRANS)
    draw = ImageDraw.Draw(im)
    
    # Mặt bằng lũy đá (Walkway platform) từ y=10 đến y=48
    draw.rectangle([0, 10, 63, 48], fill=C_STONE_MID)
    
    # Các khối đá lát sàn (Flagstone pavement patterns)
    # Rãnh đá và mạch vữa
    stone_joints_h = [22, 34, 44]
    for yj in stone_joints_h:
        draw.line([0, yj, 63, yj], fill=C_SHADOW, width=1)
        # Highlight mép trên của rãnh
        draw.line([0, yj + 1, 63, yj + 1], fill=C_STONE_LIGHT, width=1)
        
    # Mạch vữa dọc so le
    vertical_joints = [
        # Hàng 1 (10..22)
        (16, 10, 22), (36, 10, 22), (52, 10, 22),
        # Hàng 2 (22..34)
        (8, 22, 34), (28, 22, 34), (48, 22, 34),
        # Hàng 3 (34..44)
        (20, 34, 44), (40, 34, 44), (58, 34, 44),
        # Hàng 4 (44..48)
        (12, 44, 48), (32, 44, 48), (50, 44, 48),
    ]
    for xj, y1, y2 in vertical_joints:
        draw.line([xj, y1, xj, y2], fill=C_SHADOW, width=1)
        draw.line([xj + 1, y1, xj + 1, y2], fill=C_STONE_LIGHT, width=1)
        
    # Mép trước mặt bục đá (Curb / lip) ở y=48..50
    draw.rectangle([0, 48, 63, 50], fill=C_STONE_LIGHT)
    draw.line([0, 48, 63, 48], fill=C_STONE_PALE, width=1)
    
    # Chân thành đá mặt trước (Front wall face) từ y=51 đến y=63
    draw.rectangle([0, 51, 63, 62], fill=C_STONE_DARK)
    # Khối đá tảng mặt dựng (vertical face ashlar blocks)
    for bx in [14, 30, 46]:
        draw.line([bx, 51, bx, 62], fill=C_DARK, width=1)
        draw.line([bx + 1, 51, bx + 1, 62], fill=C_STONE_MID, width=1)
    draw.line([0, 56, 63, 56], fill=C_DARK, width=1)
    
    # Đáy chân thành rêu mốc và bóng đổ
    draw.line([0, 63, 63, 63], fill=C_DARK, width=1)
    for rx in range(0, 64, 4):
        draw.point((rx, 61), C_MOSS_DARK)
        draw.point((rx + 1, 62), C_MOSS_MID)
        draw.point((rx + 2, 60), C_MOSS_DARK)
        
    # Đốm rêu và vết nứt trên mặt sàn
    for mx, my in [(5, 14), (6, 14), (5, 15), (26, 26), (27, 26), (44, 38), (45, 38), (44, 39), (55, 18)]:
        im.putpixel((mx, my), C_MOSS_MID)
    for mx, my in [(6, 15), (26, 27), (45, 39)]:
        im.putpixel((mx, my), C_MOSS_LIGHT)
        
    return im

def draw_spikes(im, x_start, x_end, base_y=11):
    """Vẽ hàng cọc gỗ vát nhọn cản giặc (wooden palisade spikes) chĩa lên hướng Bắc."""
    draw = ImageDraw.Draw(im)
    spacing = 7
    for sx in range(x_start, x_end, spacing):
        if sx + 5 > 64:
            break
        # Cọc cắm: thân rộng 4px, đỉnh vát nhọn 1px
        # Thân cọc từ base_y - 8 đến base_y
        top_y = base_y - 8
        draw.line([sx + 2, top_y, sx + 2, top_y + 1], fill=C_WOOD_LIGHT) # Mũi nhọn
        draw.rectangle([sx + 1, top_y + 2, sx + 3, base_y], fill=C_WOOD_MID)
        draw.line([sx, top_y + 2, sx, base_y], fill=C_DARK) # Viền trái
        draw.line([sx + 4, top_y + 2, sx + 4, base_y], fill=C_DARK) # Viền phải
        draw.point((sx + 1, top_y + 2), C_WOOD_LIGHT) # Ánh sáng
        # Đai sắt/đồng bọc cọc
        draw.line([sx, top_y + 5, sx + 4, top_y + 5], fill=C_BRONZE)
        
def draw_crenellation(im, x, y_top=2, width=16, height=10):
    """Vẽ ụ đá châu mai (battlement crenellation) kiên cố."""
    draw = ImageDraw.Draw(im)
    # Khối ụ đá
    draw.rectangle([x, y_top, x + width - 1, y_top + height], fill=C_STONE_MID)
    # Viền ngoài
    draw.rectangle([x, y_top, x + width - 1, y_top + height], outline=C_DARK)
    # Mép trên sáng
    draw.line([x + 1, y_top + 1, x + width - 2, y_top + 1], fill=C_STONE_LIGHT)
    # Lỗ châu mai (arrow slit) ở giữa
    slit_x = x + width // 2
    draw.rectangle([slit_x - 1, y_top + 3, slit_x + 1, y_top + 7], fill=C_DARK)
    draw.point((slit_x, y_top + 4), C_SHADOW)
    draw.point((slit_x, y_top + 5), C_SHADOW)

def draw_dai_viet_flag(im, pole_x=8, pole_y_bottom=30):
    """Vẽ cột cờ và cờ lệnh Đại Việt phấp phới."""
    draw = ImageDraw.Draw(im)
    pole_y_top = 2
    # Cán cờ gỗ lim
    draw.line([pole_x, pole_y_top, pole_x, pole_y_bottom], fill=C_WOOD_DARK, width=2)
    draw.point((pole_x, pole_y_top - 1), C_GOLD) # Đỉnh chóp đồng
    draw.point((pole_x + 1, pole_y_top - 1), C_GOLD)
    
    # Lá cờ tam giác bay sang phải (bay theo gió Đông sang Tây / Tây sang Đông)
    # Cờ Đại Việt: đỏ thắm viền răng cưa vàng
    flag_points = [
        (pole_x + 2, pole_y_top + 1),
        (pole_x + 18, pole_y_top + 5),
        (pole_x + 2, pole_y_top + 10)
    ]
    draw.polygon(flag_points, fill=C_FLAG_RED, outline=C_FLAG_DARK)
    # Viền vàng và tua cờ
    draw.line([pole_x + 2, pole_y_top + 1, pole_x + 18, pole_y_top + 5], fill=C_FLAG_GOLD)
    draw.line([pole_x + 18, pole_y_top + 5, pole_x + 2, pole_y_top + 10], fill=C_FLAG_GOLD)
    draw.point((pole_x + 19, pole_y_top + 5), C_GOLD) # Dải tua bay
    draw.point((pole_x + 20, pole_y_top + 6), C_GOLD)

# ==============================================================
# TẠO 4 BIẾN THỂ Ô ẢI (A7)
# ==============================================================

# BIẾN THỂ 0: Lũy đá kiên cố + Cờ lệnh Đại Việt + Hàng cọc chông cản kỵ binh
im0 = create_base_rampart()
draw_spikes(im0, 16, 62, base_y=11)
draw_dai_viet_flag(im0, pole_x=8, pole_y_bottom=28)
# Chân bệ cắm cọc đá
d0 = ImageDraw.Draw(im0)
d0.rectangle([6, 26, 12, 30], fill=C_STONE_LIGHT, outline=C_DARK)

# BIẾN THỂ 1: Lũy ải có Ụ đá châu mai kiên cố ở giữa + Hai bên cọc nhọn
im1 = create_base_rampart()
# Hai hàng cọc hai bên
draw_spikes(im1, 2, 22, base_y=11)
draw_spikes(im1, 44, 62, base_y=11)
# Ụ đá châu mai ở giữa
draw_crenellation(im1, x=22, y_top=2, width=20, height=10)

# BIẾN THỂ 2: Cổng vòm lũy ải gỗ lim nẹp đồng + Hàng cọc cản kỵ binh
im2 = create_base_rampart()
draw_spikes(im2, 2, 62, base_y=11)
# Nẹp xà ngang gỗ lim bọc đinh đồng (Timber barricade beam) ở y=8..12
d2 = ImageDraw.Draw(im2)
d2.rectangle([4, 8, 60, 13], fill=C_WOOD_DARK, outline=C_DARK)
d2.line([5, 9, 59, 9], fill=C_WOOD_WARM)
for stud_x in [8, 18, 28, 38, 48, 58]:
    d2.point((stud_x, 10), C_GOLD)
    d2.point((stud_x + 1, 10), C_BRONZE)

# BIẾN THỂ 3: Chiến lũy có Giá mác phòng thủ + Ụ đá sừng sững bên phải
im3 = create_base_rampart()
draw_spikes(im3, 2, 38, base_y=11)
draw_crenellation(im3, x=42, y_top=2, width=20, height=10)
# Khiên gỗ phòng ngự dựa vào lũy đá
d3 = ImageDraw.Draw(im3)
# Khiên sơn đen viền đồng thời Trần
d3.polygon([(10, 24), (20, 24), (18, 34), (12, 34)], fill=C_DARK, outline=C_BRONZE)
d3.line([12, 25, 18, 25], fill=C_GOLD)
d3.point((15, 29), C_GOLD)

# Lưu 4 ảnh vào game/assets/textures/dia_hinh/
out_dir = "game/assets/textures/dia_hinh"
for i, img in enumerate([im0, im1, im2, im3]):
    p = os.path.join(out_dir, f"tex_o_ai_be_da_{i}.png")
    img.save(p)
    print(f"Saved: {p} (size={img.size})")

# Tạo ảnh ghép so sánh trực quan 4 biến thể
summary = Image.new("RGBA", (64 * 4 + 30, 84), (20, 20, 24, 255))
s_draw = ImageDraw.Draw(summary)
for i, img in enumerate([im0, im1, im2, im3]):
    sx = 10 + i * 70
    summary.paste(img, (sx, 10), img)
    s_draw.rectangle([sx, 10, sx + 63, 10 + 63], outline=(80, 80, 90, 255))

summary.resize(((64 * 4 + 30) * 2, 84 * 2), Image.NEAREST).save(
    "/Users/nguyentrung/.gemini/antigravity-cli/brain/80f9ff46-91fc-44ce-a613-78f9a43b7313/anh_4_o_ai_moi.png"
)
print("Saved summary: anh_4_o_ai_moi.png")
