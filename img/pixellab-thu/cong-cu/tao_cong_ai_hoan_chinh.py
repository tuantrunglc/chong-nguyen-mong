import os
from PIL import Image, ImageDraw

# Bảng màu Resurrect 64
C_TRANS = (0, 0, 0, 0)
C_DARK = (46, 34, 47, 255)         # #2e222f - Outline sẫm
C_SHADOW = (62, 53, 70, 255)       # #3e3546 - Bóng đổ đá
C_STONE_DARK = (98, 85, 101, 255)  # #625565 - Đá xám đậm / mặt đường
C_STONE_MID = (127, 112, 138, 255) # #7f708a - Đá xám vừa
C_STONE_LIGHT = (155, 171, 178, 255)# #9babb2 - Đá xám sáng
C_STONE_PALE = (199, 220, 208, 255)# #c7dcd0 - Mép đá sáng

# Màu mái ngói mũi hài thời Trần
C_ROOF_DARK = (110, 39, 39, 255)   # #6e2727 - Ngói sẫm
C_ROOF_RED = (158, 69, 57, 255)    # #9e4539 - Ngói đất nung đỏ
C_ROOF_LIGHT = (205, 104, 61, 255) # #cd683d - Mép ngói đón nắng

# Gỗ lim bọc đồng
C_WOOD_DARK = (76, 62, 36, 255)    # #4c3e24 - Gỗ lim sẫm
C_WOOD_MID = (103, 102, 51, 255)   # #676633 - Gỗ lim nâu ôliu
C_WOOD_LIGHT = (171, 148, 122, 255)# #ab947a - Gỗ sáng
C_BRONZE = (230, 144, 78, 255)     # #e6904e - Đồng thau
C_GOLD = (251, 185, 84, 255)       # #fbb954 - Vàng đinh tán/chỉ đồng

# Rêu phong
C_MOSS_DARK = (55, 78, 74, 255)    # #374e4a
C_MOSS_MID = (22, 90, 76, 255)     # #165a4c

# Cờ lệnh Đại Việt
C_FLAG_RED = (174, 35, 52, 255)    # #ae2334
C_FLAG_GOLD = (249, 194, 43, 255)  # #f9c22b
C_LANTERN = (247, 150, 23, 255)    # #f79617

def draw_cổng_ải(variant=0):
    im = Image.new("RGBA", (64, 64), C_TRANS)
    draw = ImageDraw.Draw(im)
    
    # -------------------------------------------------------------
    # 1. LỐI ĐI LÁT ĐÁ XUYÊN QUA CỔNG ẢI (Pathway through Gate)
    # -------------------------------------------------------------
    # Mặt đường ở giữa (x: 14..49, y: 16..63)
    draw.rectangle([14, 16, 49, 63], fill=C_STONE_DARK)
    # Các hàng đá lát đường cổ kính
    for py in [24, 34, 44, 54]:
        draw.line([14, py, 49, py], fill=C_SHADOW)
        draw.line([14, py + 1, 49, py + 1], fill=C_STONE_MID)
    # Mạch đá so le
    for px, py_s, py_e in [(24, 16, 24), (38, 16, 24),
                           (18, 24, 34), (32, 24, 34), (44, 24, 34),
                           (22, 34, 44), (36, 34, 44),
                           (18, 44, 54), (30, 44, 54), (42, 44, 54),
                           (24, 54, 63), (38, 54, 63)]:
        draw.line([px, py_s, px, py_e], fill=C_SHADOW)
        draw.line([px + 1, py_s, px + 1, py_e], fill=C_STONE_MID)
        
    # -------------------------------------------------------------
    # 2. HAI TRỤ CỔNG THÀNH BỀ THẾ (Left & Right Bastion Pillars)
    # -------------------------------------------------------------
    # Trụ trái: x: 0..14 | Trụ phải: x: 49..63
    for p_start, p_end in [(0, 14), (49, 63)]:
        # Thân trụ đá tảng
        draw.rectangle([p_start, 16, p_end, 50], fill=C_STONE_MID)
        # Các khối đá tảng ghép nối
        for yb in [24, 32, 40, 48]:
            draw.line([p_start, yb, p_end, yb], fill=C_SHADOW)
            draw.line([p_start, yb + 1, p_end, yb + 1], fill=C_STONE_LIGHT)
        # Khối đá tảng so le
        mid_x = (p_start + p_end) // 2
        draw.line([mid_x, 16, mid_x, 24], fill=C_SHADOW)
        draw.line([mid_x, 32, mid_x, 40], fill=C_SHADOW)
        
        # Chân đế trụ đá (chân tảng) giật cấp bề thế ở y: 50..63
        draw.rectangle([p_start, 50, p_end, 62], fill=C_STONE_DARK)
        draw.line([p_start, 50, p_end, 50], fill=C_STONE_PALE)
        draw.line([p_start, 62, p_end, 62], fill=C_DARK)
        # Viền rêu ở chân cột
        draw.point((p_start + 2, 60), C_MOSS_MID)
        draw.point((p_start + 3, 61), C_MOSS_DARK)
        draw.point((p_end - 2, 60), C_MOSS_MID)
        
        # Mép trong cổng có bóng đổ sâu
        if p_start == 0:
            draw.line([14, 16, 14, 63], fill=C_DARK)
        else:
            draw.line([49, 16, 49, 63], fill=C_DARK)

    # -------------------------------------------------------------
    # 3. CÁNH CỔNG GỖ LIM DÀY BỌC ĐỒNG MỞ RA (Open Heavy Gate Doors)
    # -------------------------------------------------------------
    # Cánh cổng gỗ lim mở ép sát vào hai bên trụ:
    # Cánh trái (x: 15..20, y: 22..52)
    draw.rectangle([15, 22, 20, 52], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([17, 23, 17, 51], fill=C_WOOD_LIGHT) # Thớ gỗ lim
    # Đinh tán hoa mai và nẹp đồng
    draw.line([15, 26, 20, 26], fill=C_BRONZE)
    draw.point((17, 26), C_GOLD)
    draw.line([15, 48, 20, 48], fill=C_BRONZE)
    draw.point((17, 48), C_GOLD)
    
    # Cánh phải (x: 43..48, y: 22..52)
    draw.rectangle([43, 22, 48, 52], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([45, 23, 45, 51], fill=C_WOOD_LIGHT)
    draw.line([43, 26, 48, 26], fill=C_BRONZE)
    draw.point((45, 26), C_GOLD)
    draw.line([43, 48, 48, 48], fill=C_BRONZE)
    draw.point((45, 48), C_GOLD)

    # -------------------------------------------------------------
    # 4. VÒM CỔNG ẢI & ĐÀ NGANG KHÓA CỔNG (Gate Arch & Header Beam)
    # -------------------------------------------------------------
    # Vòm cuốn đá (Stone Archway) uốn lượn nối 2 trụ (y: 12..18)
    draw.rectangle([12, 13, 51, 18], fill=C_WOOD_DARK, outline=C_DARK)
    draw.line([13, 14, 50, 14], fill=C_WOOD_LIGHT)
    # Tấm biển đồng ở trung tâm vòm cổng
    draw.rectangle([25, 14, 38, 17], fill=C_BRONZE, outline=C_DARK)
    draw.line([26, 15, 37, 15], fill=C_GOLD)
    
    # Vòm cuốn phía trên (Arch curvature)
    draw.arc([16, 12, 47, 26], 180, 360, fill=C_STONE_LIGHT)

    # -------------------------------------------------------------
    # 5. MÁI CỔNG ẢI THỜI TRẦN (Curved Terracotta Tile Roof / Vọng Lâu)
    # -------------------------------------------------------------
    # Mái ngói mũi hài có đầu đao vuốt cong cổ kính:
    # Tầng mái dưới (y: 6..12, rộng từ x: 2 đến 61)
    draw.polygon([(2, 12), (61, 12), (56, 7), (7, 7)], fill=C_ROOF_RED)
    draw.polygon([(2, 12), (61, 12), (56, 7), (7, 7)], outline=C_DARK)
    # Đầu đao vuốt cong kiêu hãnh hai đầu mái
    draw.point((1, 11), C_ROOF_LIGHT)
    draw.point((0, 10), C_GOLD) # Mũi đầu đao vút nhọn
    draw.point((62, 11), C_ROOF_LIGHT)
    draw.point((63, 10), C_GOLD)
    
    # Sống mái tầng trên (y: 1..7, x: 10..53)
    draw.polygon([(10, 7), (53, 7), (47, 2), (16, 2)], fill=C_ROOF_LIGHT)
    draw.polygon([(10, 7), (53, 7), (47, 2), (16, 2)], outline=C_DARK)
    # Con kìm nóc thời Trần và sống bờ nóc
    draw.line([17, 2, 46, 2], fill=C_GOLD, width=1)
    draw.rectangle([14, 0, 16, 3], fill=C_GOLD)
    draw.rectangle([47, 0, 49, 3], fill=C_GOLD)
    
    # Rãnh ngói ống
    for rx in range(12, 52, 6):
        draw.line([rx, 7, rx - 1, 12], fill=C_ROOF_DARK)
        draw.line([rx + 1, 7, rx, 12], fill=C_ROOF_LIGHT)

    # -------------------------------------------------------------
    # 6. CHI TIẾT TỪNG BIẾN THỂ (Variants)
    # -------------------------------------------------------------
    if variant == 0:
        # Cờ lệnh Đại Việt đỏ viền vàng cắm trên trụ cổng bên trái
        draw.line([8, 0, 8, 14], fill=C_WOOD_DARK, width=2)
        draw.point((8, -1), C_GOLD)
        draw.polygon([(10, 0), (22, 4), (10, 8)], fill=C_FLAG_RED, outline=C_DARK)
        draw.line([10, 0, 22, 4], fill=C_FLAG_GOLD)
        draw.line([22, 4, 10, 8], fill=C_FLAG_GOLD)
        # Rêu đá xanh ở chân trụ
        draw.point((3, 44), C_MOSS_MID)
        draw.point((4, 45), C_MOSS_DARK)
    elif variant == 1:
        # Đèn lồng quân cơ thời Trần treo dưới vòm cổng
        draw.line([31, 18, 31, 20], fill=C_DARK)
        draw.rectangle([29, 21, 33, 26], fill=C_LANTERN, outline=C_DARK)
        draw.point((31, 23), C_GOLD)
        # Vệt rêu bên trụ phải
        draw.point((58, 36), C_MOSS_MID)
        draw.point((59, 37), C_MOSS_DARK)
    elif variant == 2:
        # Cọc chông gỗ cản kỵ binh đặt hai bên trụ cổng
        draw.line([10, 56, 4, 48], fill=C_WOOD_LIGHT, width=2)
        draw.line([53, 56, 59, 48], fill=C_WOOD_LIGHT, width=2)
        draw.point((3, 47), C_WOOD_DARK)
        draw.point((60, 47), C_WOOD_DARK)
    elif variant == 3:
        # Khiên gỗ phòng thủ gắn đinh đồng dựa vào trụ cổng bên phải
        draw.polygon([(52, 32), (58, 32), (57, 42), (53, 42)], fill=C_DARK, outline=C_BRONZE)
        draw.point((55, 37), C_GOLD)
        # Cọc chông cản kỵ binh bên trụ trái
        draw.line([10, 56, 4, 48], fill=C_WOOD_LIGHT, width=2)

    return im

out_dir = "game/assets/textures/dia_hinh"
for i in range(4):
    im = draw_cổng_ải(i)
    p = os.path.join(out_dir, f"tex_o_ai_be_da_{i}.png")
    im.save(p)
    print(f"Saved Gatehouse variant {i} to {p}")
