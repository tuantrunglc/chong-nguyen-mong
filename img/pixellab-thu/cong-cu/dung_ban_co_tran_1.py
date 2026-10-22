#!/usr/bin/env python3
"""
Dựng ảnh phối cảnh hoàn chỉnh Bàn cờ Showcase 7x7:
- Ghép 16 ô Autotile cỏ - sông chuẩn tỷ lệ 1:1 (64x64)
- Đặt các vật cản: Rừng tre trúc, Rừng cây rậm, Kho lương, Làng quê, Hầm chông, Bệ đá ải
- Đặt 6 đạo quân v3 mới nhất (3 tướng Đại Việt + 3 quân Nguyên)
- Thêm viền rừng rậm quanh bàn cờ
- Thêm ô đỏ báo đòn (Telegraph), số thứ tự ra đòn (1, 2, 3), và chấm máu (HP)
- Xuất ảnh chuẩn 100% Resurrect 64, 0 semi-alpha.
"""

import os, json, random
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

DIA_HINH_DIR = os.path.join(BASE_DIR, "toi_uu", "dia_hinh")
O_NEN_DIR = os.path.join(DIA_HINH_DIR, "o_nen")
VAT_CAN_DIR = os.path.join(DIA_HINH_DIR, "vat_can")
TOI_UU_DIR = os.path.join(BASE_DIR, "toi_uu")

OUT_MOCKUP = os.path.join(DIA_HINH_DIR, "_mockup_ban_co_showcase_7x7.png")
OUT_TILES_SHEET = os.path.join(DIA_HINH_DIR, "_tong_hop_dia_hinh_va_vat_can.png")

# Palette constants
C_OUTLINE = (46, 34, 47, 255)
C_RED_TELEGRAPH = (179, 56, 49, 140) # Màu báo đòn đỏ Đại Việt
C_WHITE = (255, 255, 255, 255)
C_BLACK = (46, 34, 47, 255)
C_GOLD = (251, 185, 84, 255)
C_HP_BG = (235, 237, 233, 255)

T = 64
M = 64 # Viền ngoài bàn cờ 64px
COLS = 7
ROWS = 7
W = COLS * T + 2 * M # 576 px
H = ROWS * T + 2 * M # 576 px

def build_board():
    board = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    
    # 1. LÁT VIỀN RỪNG RẬM (A8)
    r = random.Random(42)
    for y in range(0, H, T):
        for x in range(0, W, T):
            tile_idx = r.choice([0, 1, 2, 3])
            v_tile = Image.open(os.path.join(VAT_CAN_DIR, f"a8_vien_rung_{tile_idx}.png"))
            # Làm tối viền rừng 30% để bàn cờ nổi bật
            enhancer = ImageEnhance.Brightness(v_tile)
            v_dark = enhancer.enhance(0.7)
            board.alpha_composite(v_dark, (x, y))

    # 2. LÁT NỀN CỎ & SÔNG BẰNG 16 Ô AUTOTILE
    # Cấu trúc địa hình:
    # Cột 3 là sông (từ trên xuống dưới), riêng (x=3, y=3) là ô lội nông nối 2 bờ
    # Sử dụng logic ghép ô mượt:
    # - Cột 0..2: Toàn cỏ (tile_15)
    # - Cột 4..6: Toàn cỏ (tile_15)
    # - Bờ Tây sông (cột 2 giáp sông): bờ sông bên phải
    # - Bờ Đông sông (cột 4 giáp sông): bờ sông bên trái
    # - Lòng sông (cột 3): nước chảy cuộn sóng (tile_0)
    
    # Nạp 16 ô autotile
    tiles = [Image.open(os.path.join(O_NEN_DIR, f"tile_{i}.png")).convert("RGBA") for i in range(16)]
    
    # Tạo nền bàn cờ bằng cách lát autotile
    # Bản đồ nhị phân: 1 = đất/cỏ, 0 = nước sông
    # Lưới (ROWS+1) x (COLS+1) cho 4 góc autotile (marching squares / 2x2 corner autotile)
    grid = [[1 for _ in range(COLS)] for _ in range(ROWS)]
    for y in range(ROWS):
        if y != 3: # y=3 là ô lội
            grid[y][3] = 0 # sông
            
    # Lát từng ô trên bàn cờ
    for y in range(ROWS):
        for x in range(COLS):
            px = M + x * T
            py = M + y * T
            
            # Phân loại ô:
            is_river = (grid[y][x] == 0)
            
            if is_river:
                # Nước sông
                tile_im = tiles[0]
            else:
                # Đất cỏ: kiểm tra xem có giáp sông không
                adj_left_river = (x > 0 and grid[y][x-1] == 0)
                adj_right_river = (x < COLS - 1 and grid[y][x+1] == 0)
                adj_up_river = (y > 0 and grid[y-1][x] == 0)
                adj_down_river = (y < ROWS - 1 and grid[y+1][x] == 0)
                
                if adj_right_river:
                    tile_im = tiles[11] # Bờ Tây uốn xuống nước bên phải
                elif adj_left_river:
                    tile_im = tiles[7]  # Bờ Đông uốn xuống nước bên trái
                elif x == 3 and y == 3:
                    tile_im = tiles[14] # Ô lội bùn đất nối hai bờ
                else:
                    # Cỏ nền điểm xuyết cỏ hoa
                    sub_idx = (x * 7 + y * 13) % 4
                    if sub_idx == 0:
                        tile_im = tiles[15]
                    else:
                        tile_im = tiles[15]
                        
            board.alpha_composite(tile_im, (px, py))

    # 3. KẺ LƯỚI BÀN CỜ NHẸ (Subtle grid lines chuẩn Resurrect 64)
    draw = ImageDraw.Draw(board)
    for x in range(COLS + 1):
        lx = M + x * T
        draw.line([(lx, M), (lx, M + ROWS * T)], fill=(46, 34, 47, 80), width=1)
    for y in range(ROWS + 1):
        ly = M + y * T
        draw.line([(M, ly), (M + COLS * T, ly)], fill=(46, 34, 47, 80), width=1)
        
    # Viền đen dày bao quanh sân thi đấu
    draw.rectangle([M - 1, M - 1, M + COLS * T, M + ROWS * T], outline=(46, 34, 47, 255), width=2)

    # 4. VẼ CÁC Ô ĐỎ BÁO ĐÒN (TELEGRAPH)
    # Ô (2, 5) Kỵ binh nhắm đòn vào ô (2, 6) Phạm Ngũ Lão
    # Ô (5, 6) Bộ binh nhắm đòn vào ô (4, 6) Trần Khánh Dư
    telegraph_cells = [(2, 6), (4, 6)]
    for cx, cy in telegraph_cells:
        t_x = M + cx * T
        t_y = M + cy * T
        t_overlay = Image.new("RGBA", (T, T), (179, 56, 49, 100))
        t_draw = ImageDraw.Draw(t_overlay)
        t_draw.rectangle([0, 0, T - 1, T - 1], outline=(179, 56, 49, 255), width=2)
        # Gạch chéo báo nguy hiểm
        t_draw.line([4, 4, T - 5, T - 5], fill=(179, 56, 49, 180), width=2)
        t_draw.line([4, T - 5, T - 5, 4], fill=(179, 56, 49, 180), width=2)
        board.alpha_composite(t_overlay, (t_x, t_y))

    # 5. ĐẶT CÁC VẬT CẢN (A3..A7) THEO ĐÚNG THỨ TỰ Y-SORT (Vật ở trên vẽ trước, ở dưới vẽ sau)
    # Danh sách vật cản: (loại, cx, cy, tên file, offset_y)
    obstacles = [
        ("rung_cay", 1, 1, "a3_rung_cay_ram.png", -32),
        ("kho_luong", 5, 1, "a5_kho_luong.png", -32),
        ("ham_chong", 1, 3, "a4_ham_chong_0.png", 0),
        ("o_ai", 6, 3, "a7_o_ai_be_da_0.png", 0),
        ("lang_que", 4, 4, "a6_lang_que.png", -32),
        ("kho_chay", 5, 0, "a5_kho_chay.png", -32), # Điểm xuyết kho cháy
    ]
    
    for o_type, cx, cy, fname, off_y in obstacles:
        im = Image.open(os.path.join(VAT_CAN_DIR, fname))
        px = M + cx * T
        py = M + cy * T + off_y
        
        # Nếu là ô ải: nâng mặt bệ lên 8px và vẽ chân bệ 8px
        if o_type == "o_ai":
            front = ImageEnhance.Brightness(im.crop((0, 56, 64, 64))).enhance(0.5)
            board.alpha_composite(front, (px, py + 56))
            board.alpha_composite(im, (px, py - 8))
        else:
            board.alpha_composite(im, (px, py))

    # 6. ĐẶT 6 ĐẠO QUÂN V3 (Y-SORT THEO HÀNG ĐỂ CHE PHỦ ĐÚNG CHIỀU SÂU)
    # Danh sách quân: (tên, phe, cx, cy, folder, huong, hp, order)
    units = [
        # Hàng 2
        ("Cung Kỵ B6", "nguyen", 5, 2, "cung_ky", "south_west", 3, "1"),
        # Hàng 5
        ("Bộ Binh B4 (1)", "nguyen", 0, 5, "nguyen_v3", "east", 3, "2"),
        ("Kỵ Binh B5", "nguyen", 2, 5, "ky_binh", "south", 4, "3"),
        # Hàng 6
        ("Nguyễn Khoái", "daiviet", 0, 6, "khoai", "north_east", 4, None),
        ("Phạm Ngũ Lão", "daiviet", 2, 6, "lao", "north", 4, None),
        ("Trần Khánh Dư", "daiviet", 4, 6, "du", "north_east", 4, None),
        ("Bộ Binh B4 (2)", "nguyen", 5, 6, "nguyen_v3", "west", 3, "4"),
    ]
    
    font_badge = ImageFont.truetype(FONT_FILE, 10)
    
    for u_name, faction, cx, cy, u_folder, u_dir, hp, order in units:
        u_path = os.path.join(TOI_UU_DIR, u_folder, f"{u_dir}.png")
        if not os.path.exists(u_path):
            # fallback
            u_path = os.path.join(TOI_UU_DIR, u_folder, "south.png")
            
        u_sprite = Image.open(u_path).convert("RGBA")
        
        # Tọa độ ô
        px = M + cx * T
        # Sprite 64x64, chân đặt vào tâm ô
        py = M + cy * T - 8
        
        # Vẽ bóng đổ hình elip dưới chân quân cờ
        shadow = Image.new("RGBA", (36, 14), (0, 0, 0, 0))
        sh_draw = ImageDraw.Draw(shadow)
        sh_draw.ellipse([0, 0, 35, 13], fill=(46, 34, 47, 120))
        board.alpha_composite(shadow, (px + 14, py + 54))
        
        # Vẽ sprite quân
        board.alpha_composite(u_sprite, (px, py))
        
        # Vẽ Chấm Máu (HP Badge) ở góc dưới phải ô
        # Hình tròn trắng viền đen dày 1.5px, số máu ở giữa
        badge_x = px + 44
        badge_y = py + 48
        b_img = Image.new("RGBA", (18, 18), (0, 0, 0, 0))
        b_draw = ImageDraw.Draw(b_img)
        # Viền bóng đen
        b_draw.ellipse([0, 0, 17, 17], fill=(46, 34, 47, 255))
        # Ruột trắng
        b_draw.ellipse([2, 2, 15, 15], fill=(235, 237, 233, 255))
        # Số máu
        bbox = b_draw.textbbox((0, 0), str(hp), font=font_badge)
        bw = bbox[2] - bbox[0]
        bh = bbox[3] - bbox[1]
        b_draw.text(((18 - bw) // 2, (18 - bh) // 2 - 2), str(hp), font=font_badge, fill=(46, 34, 47, 255))
        board.alpha_composite(b_img, (badge_x, badge_y))
        
        # Nếu có số thứ tự ra đòn (Order Badge trên đầu quân địch)
        if order is not None:
            ord_x = px + 44
            ord_y = py - 4
            o_img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
            o_draw = ImageDraw.Draw(o_img)
            o_draw.ellipse([0, 0, 15, 15], fill=(46, 34, 47, 255))
            o_draw.ellipse([1, 1, 14, 14], fill=(251, 185, 84, 255)) # Vàng hoàng kim
            bbox = o_draw.textbbox((0, 0), str(order), font=font_badge)
            ow = bbox[2] - bbox[0]
            oh = bbox[3] - bbox[1]
            o_draw.text(((16 - ow) // 2, (16 - oh) // 2 - 2), str(order), font=font_badge, fill=(46, 34, 47, 255))
            board.alpha_composite(o_img, (ord_x, ord_y))

    # 7. QUY CHUẨN 100% RESURRECT 64 CHO BÀN CỜ
    b_pix = board.load()
    palette_rgb = []
    with open(PALETTE_FILE) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith(("#", "GIMP", "Name", "Columns")):
                continue
            p = line.split()
            if len(p) >= 3:
                palette_rgb.append((int(p[0]), int(p[1]), int(p[2])))
    pal_arr = np.array(palette_rgb, dtype=np.float32)
    
    # Vectorized check & quantize
    b_arr = np.array(board)
    rgb = b_arr[..., :3].astype(np.float32)
    alpha = b_arr[..., 3]
    
    # Ép alpha về 255 vì nền bàn cờ là toàn phần
    out_alpha = np.full((H, W), 255, dtype=np.uint8)
    
    # Quantize fast
    from toi_uu_nhom_a import rgb_to_cielab, lab_palette
    lab_pixels = rgb_to_cielab(rgb.reshape(-1, 3))
    diff = lab_pixels[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
    dists = np.sum(diff ** 2, axis=-1)
    best_idx = np.argmin(dists, axis=-1)
    q_rgb = pal_arr[best_idx].astype(np.uint8).reshape(H, W, 3)
    
    final_arr = np.dstack([q_rgb, out_alpha])
    final_board = Image.fromarray(final_arr, mode="RGBA")
    final_board.save(OUT_MOCKUP)
    print(f"-> Đã dựng xong Bàn cờ Showcase 7x7 hoàn chỉnh: {OUT_MOCKUP}")
    
    # 8. TẠO BẢNG TỔNG HỢP TOÀN BỘ ĐỊA HÌNH VÀ VẬT CẢN (Sheet 800x480)
    print("-> Đang tạo bảng tổng hợp Địa hình & Vật cản...")
    sheet = Image.new("RGBA", (840, 420), (34, 32, 52, 255))
    s_draw = ImageDraw.Draw(sheet)
    
    title_font = ImageFont.truetype(FONT_FILE, 18)
    sub_font = ImageFont.truetype(FONT_FILE, 12)
    
    s_draw.text((20, 16), "HÀO KHÍ ĐÔNG A — TRỌN BỘ ĐỊA HÌNH & VẬT CẢN (NHÓM A)", font=title_font, fill=C_GOLD)
    s_draw.text((20, 42), "100% Chuẩn Bảng Màu Resurrect 64 • 1-bit Alpha • Tỉ lệ 1:1 Ô vuông 64x64", font=sub_font, fill=(171, 148, 122, 255))
    
    # Hàng 1: 16 ô Autotile Sông & Cỏ (A1, A2) thu nhỏ x1
    s_draw.text((20, 75), "A1 & A2: 16 Ô AUTOTILE CỎ - SÔNG (64x64)", font=sub_font, fill=C_WHITE)
    for i in range(16):
        t_im = Image.open(os.path.join(O_NEN_DIR, f"tile_{i}.png"))
        sheet.paste(t_im.resize((48, 48), Image.NEAREST), (20 + i * 50, 95))
        
    # Hàng 2: Các vật cản chính (A3 .. A7)
    s_draw.text((20, 165), "A3 .. A7: CÁC KHỐI VẬT CẢN & CÔNG TRÌNH TRÊN BÀN CỜ", font=sub_font, fill=C_WHITE)
    show_items = [
        ("Rừng tre", "a3_rung_tre_truc.png"),
        ("Rừng rậm", "a3_rung_cay_ram.png"),
        ("Hầm chông", "a4_ham_chong_0.png"),
        ("Hố bẫy lá", "a4_ho_bay_la_0.png"),
        ("Kho lương", "a5_kho_luong.png"),
        ("Kho cháy", "a5_kho_chay.png"),
        ("Làng quê", "a6_lang_que.png"),
        ("Làng khói", "a6_lang_chay_khoi.png"),
        ("Bệ ải", "a7_o_ai_be_da_0.png"),
        ("Viền rừng", "a8_vien_rung_0.png"),
    ]
    
    for idx, (label, fname) in enumerate(show_items):
        item_im = Image.open(os.path.join(VAT_CAN_DIR, fname))
        ix = 20 + idx * 80
        iy = 195
        # Căn đáy để các vật cao 96px đứng bằng chân
        ih = item_im.height
        sheet.paste(item_im, (ix, iy + (96 - ih)), item_im)
        # Nhãn
        s_draw.text((ix, iy + 104), label, font=sub_font, fill=(200, 210, 215, 255))
        
    # Hàng 3: Cỏ lẻ
    s_draw.text((20, 335), "BIẾN THỂ CỎ LẺ (A1):", font=sub_font, fill=C_WHITE)
    for i in range(4):
        p = os.path.join(O_NEN_DIR, f"tile_co_le_{i}.png")
        if os.path.exists(p):
            im = Image.open(p)
            sheet.paste(im.resize((48, 48), Image.NEAREST), (200 + i * 56, 330))

    # Quantize sheet
    s_arr = np.array(sheet)
    s_rgb = s_arr[..., :3].astype(np.float32)
    lab_s = rgb_to_cielab(s_rgb.reshape(-1, 3))
    diff_s = lab_s[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
    best_s = np.argmin(np.sum(diff_s ** 2, axis=-1), axis=-1)
    q_s_rgb = pal_arr[best_s].astype(np.uint8).reshape(420, 840, 3)
    final_sheet = Image.fromarray(np.dstack([q_s_rgb, np.full((420, 840), 255, dtype=np.uint8)]), mode="RGBA")
    final_sheet.save(OUT_TILES_SHEET)
    print(f"-> Đã lưu Bảng tổng hợp Địa hình & Vật cản: {OUT_TILES_SHEET}")

if __name__ == "__main__":
    build_board()
