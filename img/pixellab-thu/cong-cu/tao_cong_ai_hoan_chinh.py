import os
from PIL import Image, ImageDraw

# Bảng màu Resurrect 64
C_TRANS = (0, 0, 0, 0)
C_DARK = (46, 34, 47, 255)         # #2e222f - Outline sẫm
C_DEEP_SHADOW = (46, 34, 47, 255)  # #1a121c - Lòng cổng sâu tối
C_SHADOW = (62, 53, 70, 255)       # #3e3546 - Bóng đổ đá
C_STONE_DARK = (98, 85, 101, 255)  # #625565 - Khối đá xám đậm
C_STONE_MID = (127, 112, 138, 255) # #7f708a - Đá xám vừa
C_STONE_LIGHT = (155, 171, 178, 255)# #9babb2 - Highlight đá đón sáng
C_STONE_PALE = (199, 220, 208, 255)# #c7dcd0 - Mép đá sáng nhất

# Màu mái ngói mũi hài thời Trần
C_ROOF_DARK = (110, 39, 39, 255)   # #6e2727 - Ngói sẫm bóng
C_ROOF_RED = (158, 69, 57, 255)    # #9e4539 - Ngói đỏ nung
C_ROOF_LIGHT = (205, 104, 61, 255) # #cd683d - Mép ngói đón nắng
C_ROOF_PEAK = (230, 144, 78, 255)  # #e6904e - Sống nóc rực sáng

# Gỗ lim & đồng
C_WOOD_DARK = (76, 62, 36, 255)    # #4c3e24 - Gỗ lim sẫm
C_WOOD_MID = (103, 102, 51, 255)   # #676633 - Gỗ lim nâu
C_WOOD_LIGHT = (171, 148, 122, 255)# #ab947a - Gỗ sáng
C_BRONZE = (230, 144, 78, 255)     # #e6904e - Bản lề & nẹp đồng
C_GOLD = (251, 185, 84, 255)       # #fbb954 - Vàng đinh tán / then khóa

# Cờ lệnh Đại Việt & Điểm nhấn
C_FLAG_RED = (174, 35, 52, 255)    # #ae2334 - Đỏ cờ Đại Việt
C_FLAG_GOLD = (249, 194, 43, 255)  # #f9c22b - Viền răng cưa vàng
C_LANTERN = (247, 150, 23, 255)    # #f79617 - Đèn lồng treo
C_MOSS_MID = (22, 90, 76, 255)     # #165a4c - Rêu đá
C_MOSS_DARK = (55, 78, 74, 255)    # #374e4a

def draw_ashlar_blocks(draw, x0, y0, x1, y1, row_h=8, block_w=14):
    """Vẽ khối đá tảng ashlar sắc nét."""
    draw.rectangle([x0, y0, x1, y1], fill=C_STONE_MID, outline=C_DARK)
    draw.line([x0 + 1, y0 + 1, x1 - 1, y0 + 1], fill=C_STONE_LIGHT)
    curr_y = y0 + row_h
    row_idx = 0
    while curr_y <= y1 - 3:
        draw.line([x0 + 1, curr_y, x1 - 1, curr_y], fill=C_SHADOW)
        draw.line([x0 + 1, curr_y + 1, x1 - 1, curr_y + 1], fill=C_STONE_LIGHT)
        offset = 0 if row_idx % 2 == 0 else block_w // 2
        curr_x = x0 + offset + block_w
        while curr_x < x1 - 2:
            draw.line([curr_x, curr_y - row_h + 2, curr_x, curr_y - 1], fill=C_SHADOW)
            draw.line([curr_x + 1, curr_y - row_h + 2, curr_x + 1, curr_y - 1], fill=C_STONE_LIGHT)
            curr_x += block_w
        curr_y += row_h
        row_idx += 1
    # Chân bệ tiếp đất
    draw.rectangle([x0, y1 - 4, x1, y1], fill=C_STONE_DARK)
    draw.line([x0, y1 - 4, x1, y1 - 4], fill=C_STONE_PALE)
    draw.line([x0, y1, x1, y1], fill=C_DARK)

def draw_grand_double_gate(variant=0):
    """Tạo Đại Quan Ải 2 ô (128x64 px)."""
    im = Image.new("RGBA", (128, 64), C_TRANS)
    draw = ImageDraw.Draw(im)

    # 1. Bệ móng và tường thành hai bên (Left Bastion X: 4..42, Right Bastion X: 85..123)
    draw_ashlar_blocks(draw, 4, 18, 42, 61, row_h=8, block_w=14)
    draw_ashlar_blocks(draw, 85, 18, 123, 61, row_h=8, block_w=14)

    # Lỗ châu mai (Arrow slits)
    for bx in [16, 30, 97, 111]:
        draw.rectangle([bx, 30, bx + 2, 38], fill=C_DEEP_SHADOW, outline=C_DARK)
        draw.line([bx - 1, 29, bx + 3, 29], fill=C_STONE_PALE)

    # 2. VÒM CỔNG CHÍNH Ở GIỮA (Center Archway X: 43..84)
    # Lòng cổng sâu tối (Arch interior opening X: 48..79, Y: 24..61)
    draw.rectangle([48, 24, 79, 61], fill=C_DEEP_SHADOW)
    # Vòm cong lòng cổng
    draw.polygon([(48, 28), (56, 22), (71, 22), (79, 28), (79, 24), (48, 24)], fill=C_DEEP_SHADOW)
    
    # Mặt đường lát đá xuyên qua vòm cổng
    draw.rectangle([48, 48, 79, 61], fill=C_STONE_DARK)
    for ry in [52, 57]:
        draw.line([48, ry, 79, ry], fill=C_DARK)
        draw.line([48, ry + 1, 79, ry + 1], fill=C_STONE_MID)
    for rx, ry_s, ry_e in [(56, 48, 52), (72, 48, 52), (64, 52, 57), (54, 57, 61), (74, 57, 61)]:
        draw.line([rx, ry_s, rx, ry_e], fill=C_DARK)
        draw.line([rx + 1, ry_s, rx + 1, ry_e], fill=C_STONE_LIGHT)

    # Cánh cổng gỗ lim dày bọc đồng mở nép vào hai bên trụ vòm
    # Cánh trái (X: 42..47, Y: 28..57)
    draw.rectangle([42, 28, 47, 57], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([44, 29, 44, 56], fill=C_WOOD_LIGHT) # Thớ gỗ
    draw.line([42, 34, 47, 34], fill=C_BRONZE)
    draw.point((44, 34), C_GOLD)
    draw.line([42, 51, 47, 51], fill=C_BRONZE)
    draw.point((44, 51), C_GOLD)

    # Cánh phải (X: 80..85, Y: 28..57)
    draw.rectangle([80, 28, 85, 57], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([82, 29, 82, 56], fill=C_WOOD_LIGHT)
    draw.line([80, 34, 85, 34], fill=C_BRONZE)
    draw.point((82, 34), C_GOLD)
    draw.line([80, 51, 85, 51], fill=C_BRONZE)
    draw.point((82, 51), C_GOLD)

    # Vòm cuốn đá (Stone Voussoirs Arch) bao quanh lòng vòm
    draw.polygon([(42, 28), (48, 20), (58, 16), (69, 16), (79, 20), (85, 28),
                  (80, 28), (71, 22), (56, 22), (47, 28)], fill=C_STONE_LIGHT, outline=C_DARK)
    # Đá khóa vòm ở đỉnh (Keystone at center X: 61..66, Y: 14..22)
    draw.polygon([(61, 22), (66, 22), (68, 14), (59, 14)], fill=C_STONE_PALE, outline=C_DARK)
    draw.line([48, 20, 58, 16], fill=C_STONE_PALE)
    draw.line([69, 16, 79, 20], fill=C_STONE_PALE)

    # Tấm biển đồng Đại Quan Ải ở giữa đỉnh cổng (X: 52..75, Y: 11..15)
    draw.rectangle([52, 11, 75, 15], fill=C_BRONZE, outline=C_DARK)
    draw.line([53, 12, 74, 12], fill=C_GOLD)
    draw.line([53, 14, 74, 14], fill=C_WOOD_DARK)

    # 3. HỆ MÁI NGÓI MŨI HÀI THỜI TRẦN NỐI LIỀN 2 THÁP (Y: 4..16)
    roof_pts = [(2, 13), (125, 13), (118, 6), (9, 6)]
    draw.polygon(roof_pts, fill=C_ROOF_RED, outline=C_DARK)
    draw.line([10, 6, 117, 6], fill=C_ROOF_PEAK, width=2)
    draw.line([10, 7, 117, 7], fill=C_ROOF_LIGHT)
    draw.rectangle([8, 4, 10, 7], fill=C_GOLD, outline=C_DARK)
    draw.rectangle([117, 4, 119, 7], fill=C_GOLD, outline=C_DARK)
    # Đầu đao vuốt cong kiêu hãnh hai bên
    draw.line([4, 13, 0, 9], fill=C_ROOF_LIGHT, width=2)
    draw.point((-1, 8), C_GOLD)
    draw.point((0, 8), C_GOLD)
    draw.line([123, 13, 127, 9], fill=C_ROOF_LIGHT, width=2)
    draw.point((128, 8), C_GOLD)
    draw.point((127, 8), C_GOLD)

    for rx in range(14, 115, 6):
        draw.line([rx, 7, rx - 1, 13], fill=C_ROOF_DARK)
        draw.line([rx + 1, 7, rx, 13], fill=C_ROOF_LIGHT)
    draw.line([3, 13, 124, 13], fill=C_DARK)
    draw.line([4, 12, 123, 12], fill=C_ROOF_LIGHT)

    # 4. CHI TIẾT THEO BIẾN THỂ
    if variant == 0:
        # Cờ lệnh Đại Việt trên đỉnh tháp trái
        draw.line([10, 0, 10, 18], fill=C_WOOD_DARK, width=2)
        draw.point((10, -1), C_GOLD)
        draw.point((11, -1), C_GOLD)
        flag_pts = [(12, 0), (28, 5), (12, 10)]
        draw.polygon(flag_pts, fill=C_FLAG_RED, outline=C_DARK)
        draw.line([12, 0, 28, 5], fill=C_FLAG_GOLD)
        draw.line([28, 5, 12, 10], fill=C_FLAG_GOLD)
        draw.point((29, 5), C_GOLD)
        draw.point((30, 6), C_GOLD)

        # Đèn lồng treo bên tháp phải
        draw.line([116, 14, 116, 16], fill=C_DARK)
        draw.rectangle([114, 17, 118, 22], fill=C_LANTERN, outline=C_DARK)
        draw.point((116, 19), C_GOLD)
        draw.line([115, 23, 117, 23], fill=C_FLAG_RED)
    else:
        # Biến thể 1: Đèn lồng treo 2 bên, khiên phòng thủ ở tháp trái
        draw.polygon([(8, 36), (14, 36), (13, 46), (9, 46)], fill=C_DARK, outline=C_BRONZE)
        draw.point((11, 41), C_GOLD)

        # Cờ lệnh Đại Việt trên tháp phải
        draw.line([117, 0, 117, 18], fill=C_WOOD_DARK, width=2)
        draw.point((117, -1), C_GOLD)
        flag_pts = [(101, 5), (117, 0), (117, 10)]
        draw.polygon(flag_pts, fill=C_FLAG_RED, outline=C_DARK)
        draw.line([101, 5, 117, 0], fill=C_FLAG_GOLD)
        draw.line([101, 5, 117, 10], fill=C_FLAG_GOLD)
        draw.point((100, 5), C_GOLD)

    # Rêu phong cổ kính
    for mx in [6, 14, 38, 88, 118]:
        draw.point((mx, 59), C_MOSS_MID)
        draw.point((mx + 1, 60), C_MOSS_DARK)

    return im

def draw_single_gate(variant=0):
    """Tạo Cổng Ải Đơn 1 ô (64x64 px) sắc nét, cân đối, không chạm mép ngoài."""
    im = Image.new("RGBA", (64, 64), C_TRANS)
    draw = ImageDraw.Draw(im)

    # 1. Trụ thành hai bên (Trái X: 6..21, Phải X: 42..57)
    draw_ashlar_blocks(draw, 6, 18, 21, 61, row_h=8, block_w=12)
    draw_ashlar_blocks(draw, 42, 18, 57, 61, row_h=8, block_w=12)

    # 2. Vòm cổng ở giữa (Opening X: 22..41, Y: 24..61)
    draw.rectangle([22, 24, 41, 61], fill=C_DEEP_SHADOW)
    draw.polygon([(22, 28), (28, 22), (35, 22), (41, 28), (41, 24), (22, 24)], fill=C_DEEP_SHADOW)
    
    # Mặt đường lát đá
    draw.rectangle([22, 48, 41, 61], fill=C_STONE_DARK)
    for ry in [52, 57]:
        draw.line([22, ry, 41, ry], fill=C_DARK)
        draw.line([22, ry + 1, 41, ry + 1], fill=C_STONE_MID)
    draw.line([31, 48, 31, 52], fill=C_DARK)
    draw.line([26, 52, 26, 57], fill=C_DARK)
    draw.line([36, 52, 36, 57], fill=C_DARK)

    # Cánh cổng gỗ lim
    draw.rectangle([18, 28, 22, 57], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([20, 29, 20, 56], fill=C_WOOD_LIGHT)
    draw.line([18, 34, 22, 34], fill=C_BRONZE)
    draw.point((20, 34), C_GOLD)
    draw.line([18, 51, 22, 51], fill=C_BRONZE)
    draw.point((20, 51), C_GOLD)

    draw.rectangle([41, 28, 45, 57], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([43, 29, 43, 56], fill=C_WOOD_LIGHT)
    draw.line([41, 34, 45, 34], fill=C_BRONZE)
    draw.point((43, 34), C_GOLD)
    draw.line([41, 51, 45, 51], fill=C_BRONZE)
    draw.point((43, 51), C_GOLD)

    # Vòm cuốn đá
    draw.polygon([(18, 28), (22, 20), (28, 17), (35, 17), (41, 20), (45, 28),
                  (41, 28), (35, 22), (28, 22), (22, 28)], fill=C_STONE_LIGHT, outline=C_DARK)
    draw.polygon([(29, 22), (34, 22), (36, 15), (27, 15)], fill=C_STONE_PALE, outline=C_DARK)
    draw.line([22, 20, 28, 17], fill=C_STONE_PALE)
    draw.line([35, 17, 41, 20], fill=C_STONE_PALE)

    # Biển đồng
    draw.rectangle([25, 12, 38, 15], fill=C_BRONZE, outline=C_DARK)
    draw.line([26, 13, 37, 13], fill=C_GOLD)

    # 3. Mái ngói mũi hài (X: 4..59, Y: 5..14)
    roof_pts = [(4, 13), (59, 13), (52, 6), (11, 6)]
    draw.polygon(roof_pts, fill=C_ROOF_RED, outline=C_DARK)
    draw.line([12, 6, 51, 6], fill=C_ROOF_PEAK, width=2)
    draw.line([12, 7, 51, 7], fill=C_ROOF_LIGHT)
    draw.rectangle([10, 4, 12, 7], fill=C_GOLD, outline=C_DARK)
    draw.rectangle([51, 4, 53, 7], fill=C_GOLD, outline=C_DARK)
    # Đầu đao vuốt cong
    draw.line([5, 13, 1, 9], fill=C_ROOF_LIGHT, width=2)
    draw.point((0, 8), C_GOLD)
    draw.line([58, 13, 62, 9], fill=C_ROOF_LIGHT, width=2)
    draw.point((63, 8), C_GOLD)

    for rx in range(16, 49, 6):
        draw.line([rx, 7, rx - 1, 13], fill=C_ROOF_DARK)
        draw.line([rx + 1, 7, rx, 13], fill=C_ROOF_LIGHT)
    draw.line([5, 13, 58, 13], fill=C_DARK)
    draw.line([6, 12, 57, 12], fill=C_ROOF_LIGHT)

    # 4. Biến thể
    if variant == 0:
        draw.line([10, 0, 10, 18], fill=C_WOOD_DARK, width=2)
        draw.point((10, -1), C_GOLD)
        flag_pts = [(12, 0), (24, 4), (12, 8)]
        draw.polygon(flag_pts, fill=C_FLAG_RED, outline=C_DARK)
        draw.line([12, 0, 24, 4], fill=C_FLAG_GOLD)
        draw.line([24, 4, 12, 8], fill=C_FLAG_GOLD)
        draw.point((25, 4), C_GOLD)
    elif variant == 1:
        draw.line([31, 16, 31, 18], fill=C_DARK)
        draw.rectangle([29, 19, 33, 24], fill=C_LANTERN, outline=C_DARK)
        draw.point((31, 21), C_GOLD)
        draw.line([30, 25, 32, 25], fill=C_FLAG_RED)
    elif variant == 2:
        draw.line([8, 59, 3, 52], fill=C_WOOD_LIGHT, width=2)
        draw.line([55, 59, 60, 52], fill=C_WOOD_LIGHT, width=2)
        draw.point((2, 51), C_WOOD_DARK)
        draw.point((61, 51), C_WOOD_DARK)
    elif variant == 3:
        draw.polygon([(49, 36), (54, 36), (53, 46), (50, 46)], fill=C_DARK, outline=C_BRONZE)
        draw.point((52, 41), C_GOLD)

    draw.point((8, 59), C_MOSS_MID)
    draw.point((54, 59), C_MOSS_MID)

    return im

def draw_middle_wall(variant=0):
    """Tạo Tường Thành Ở Giữa (64x64 px) trong trường hợp 3 ô ải liền nhau."""
    im = Image.new("RGBA", (64, 64), C_TRANS)
    draw = ImageDraw.Draw(im)
    draw_ashlar_blocks(draw, 0, 18, 63, 61, row_h=8, block_w=14)
    # Lỗ châu mai
    for bx in [16, 46]:
        draw.rectangle([bx, 30, bx + 2, 38], fill=C_DEEP_SHADOW, outline=C_DARK)
        draw.line([bx - 1, 29, bx + 3, 29], fill=C_STONE_PALE)
    # Mái ngói chạy xuyên suốt từ x=0 đến x=63
    roof_pts = [(0, 13), (63, 13), (63, 6), (0, 6)]
    draw.polygon(roof_pts, fill=C_ROOF_RED, outline=C_DARK)
    draw.line([0, 6, 63, 6], fill=C_ROOF_PEAK, width=2)
    draw.line([0, 7, 63, 7], fill=C_ROOF_LIGHT)
    for rx in range(4, 64, 6):
        draw.line([rx, 7, rx - 1, 13], fill=C_ROOF_DARK)
        draw.line([rx + 1, 7, rx, 13], fill=C_ROOF_LIGHT)
    draw.line([0, 13, 63, 13], fill=C_DARK)
    draw.line([0, 12, 63, 12], fill=C_ROOF_LIGHT)
    return im

out_dir = "game/assets/textures/dia_hinh"

# 1. Cổng đơn (0..3)
for i in range(4):
    sg = draw_single_gate(i)
    p = os.path.join(out_dir, f"tex_o_ai_be_da_{i}.png")
    sg.save(p)
    print(f"Saved single gate variant {i} to {p}")

# 2. Cổng đôi (nửa trái và nửa phải, 2 biến thể 0..1)
for i in range(2):
    grand = draw_grand_double_gate(i)
    left_gate = grand.crop((0, 0, 64, 64))
    right_gate = grand.crop((64, 0, 128, 64))
    p_left = os.path.join(out_dir, f"tex_o_ai_doi_trai_{i}.png")
    p_right = os.path.join(out_dir, f"tex_o_ai_doi_phai_{i}.png")
    left_gate.save(p_left)
    right_gate.save(p_right)
    print(f"Saved grand gate pair {i} to {p_left} and {p_right}")

# 3. Tường giữa (2 biến thể 0..1)
for i in range(2):
    mid = draw_middle_wall(i)
    p_mid = os.path.join(out_dir, f"tex_o_ai_doi_giua_{i}.png")
    mid.save(p_mid)
    print(f"Saved grand gate middle {i} to {p_mid}")

print("All gatehouse assets created successfully!")
