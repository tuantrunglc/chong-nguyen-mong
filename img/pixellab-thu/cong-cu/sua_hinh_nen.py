#!/usr/bin/env python3
"""
Khôi phục nền màn hình chính f1_nen_man_hinh.png theo chuẩn Pixel Art:
1. Xóa bỏ hoàn toàn 2 tấm biển gỗ treo và chữ giả AI ("VIEHAN", "BECAM", "VIEIHAM", "TH TIH", dây treo).
2. Tái tạo bầu trời hoàng hôn Vịnh Hạ Long / Bạch Đằng mượt mà với kỹ thuật dithering 2x2 chuẩn Resurrect 64:
   - Tầng trời tím sẫm hoàng hôn (#625565)
   - Tầng mây tím tro (#7f708a, #966c6c)
   - Tầng mây rực rỡ đón ánh dương (#ab947a, #fca790, #fdcbb0)
3. Hoàn thiện đỉnh núi đá vôi (karst dome) tự nhiên bên trái với hình khối núi đặc trưng Vịnh Hạ Long (#2e222f, #313638, #374e4a).
4. Kéo dài các thân trúc và bụi lá trúc tự nhiên lên mép trên khung hình.
5. Đảm bảo 100% màu thuộc bảng màu Resurrect 64, 1-bit alpha (255), không anti-aliasing.
"""

import os
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
SRC_PATH = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh", "f1_nen_man_hinh.png")
OUT_PATH = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh", "f1_nen_man_hinh.png")
BACKUP_PATH = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh", "f1_nen_man_hinh_goc_co_bien.png")

# Palette constants
C_OUTLINE = (46, 34, 47, 255)    # #2e222f
C_DARK_ROCK = (49, 54, 56, 255)  # #313638
C_MOSS = (55, 78, 74, 255)       # #374e4a
C_BAMBOO_MID = (103, 102, 51, 255) # #676633
C_SKY_DUSK = (98, 85, 101, 255)  # #625565
C_SKY_MAUVE = (127, 112, 138, 255) # #7f708a
C_CLOUD_DARK = (150, 108, 108, 255) # #966c6c
C_CLOUD_LIGHT = (171, 148, 122, 255) # #ab947a
C_CLOUD_PEACH = (252, 167, 144, 255) # #fca790
C_CLOUD_WARM = (253, 203, 176, 255) # #fdcbb0
C_CLOUD_HIGHLIGHT = (155, 171, 178, 255) # #9babb2
C_GOLD = (230, 144, 78, 255)     # #e6904e

def dither2x2(x, y):
    return (x % 2 == 0 and y % 2 == 0) or (x % 2 == 1 and y % 2 == 1)

def restore_background():
    img = Image.open(SRC_PATH).convert("RGBA")
    w, h = img.size
    
    # Backup file gốc nếu chưa backup
    if not os.path.exists(BACKUP_PATH):
        img.save(BACKUP_PATH)
        print(f"Đã sao lưu ảnh gốc có biển tại: {BACKUP_PATH}")
        
    pixels = img.load()
    
    # -------------------------------------------------------------
    # 1. TÁI TẠO BẦU TRỜI NỀN KHU VỰC BIỂN PHẢI (x: 280 .. 530, y: 0 .. 125)
    # -------------------------------------------------------------
    # Bầu trời chuyển sắc:
    # y = 0..30: C_SKY_DUSK (#625565)
    # y = 30..45: Dither C_SKY_DUSK & C_SKY_MAUVE (#7f708a)
    # y = 45..75: C_SKY_MAUVE (#7f708a) với các vệt mây C_CLOUD_DARK (#966c6c)
    # y = 75..90: Dither C_SKY_MAUVE & C_CLOUD_DARK
    # y = 90..115: Mây C_CLOUD_DARK (#966c6c) & C_CLOUD_LIGHT (#ab947a)
    # y = 115..125: Chuyển tiếp mượt sang nền mây sẵn có
    
    # Tạo bản đồ trời và mây tự nhiên
    for y in range(0, 125):
        for x in range(280, 530):
            # Kiểm tra xem có phải thân trúc hoặc lá trúc bên phải không
            # Thân trúc tại x >= 510 và các lá trúc giữ lại nếu không thuộc biển gỗ
            cur_color = pixels[x, y]
            
            # Tính màu nền trời hoàng hôn tại (x, y)
            # Tạo dải mây bồng bềnh tự nhiên bằng sóng sin
            wave = np.sin((x + y * 0.4) * 0.08) * 8 + np.cos(x * 0.04) * 6
            eff_y = y + wave
            
            if eff_y < 35:
                bg_col = C_SKY_DUSK
            elif eff_y < 48:
                bg_col = C_SKY_MAUVE if dither2x2(x, y) else C_SKY_DUSK
            elif eff_y < 70:
                bg_col = C_SKY_MAUVE
            elif eff_y < 85:
                bg_col = C_CLOUD_DARK if dither2x2(x, y) else C_SKY_MAUVE
            elif eff_y < 100:
                bg_col = C_CLOUD_DARK
            elif eff_y < 112:
                bg_col = C_CLOUD_LIGHT if dither2x2(x, y) else C_CLOUD_DARK
            else:
                bg_col = C_CLOUD_LIGHT
                
            # Đắp vệt sáng mây highlight ánh hoàng hôn (#9babb2 & #fca790)
            if 70 <= eff_y <= 74 and (x % 3 != 0):
                bg_col = C_CLOUD_HIGHLIGHT
            elif 95 <= eff_y <= 99 and (x % 4 != 0):
                bg_col = C_CLOUD_PEACH
            elif 110 <= eff_y <= 114 and (x % 2 == 0):
                bg_col = C_CLOUD_WARM
                
            pixels[x, y] = bg_col

    # -------------------------------------------------------------
    # 2. TÁI TẠO BẦU TRỜI VÀ NÚI ĐÁ VÔI KHU VỰC BIỂN TRÁI (x: 0 .. 205, y: 0 .. 125)
    # -------------------------------------------------------------
    # Núi đá vôi Karst Dome bên trái:
    # Đỉnh núi tại x ~ 125, y ~ 68.
    # Dốc thoai thoải sang trái về phía mép ảnh (x=0, y~130), dốc xuống bên phải về phía bụi trúc (x=180, y~110).
    
    for y in range(0, 125):
        for x in range(0, 205):
            # Tính độ cao đỉnh núi Karst tại x
            # Đường cong parabol tự nhiên của đỉnh núi đá vôi Ninh Bình / Hạ Long
            mountain_top_y = 66 + 0.0055 * ((x - 120) ** 2)
            # Thêm chút mỏm đá gồ ghề phong cách pixel art
            crag = (np.sin(x * 0.35) * 2 + np.cos(x * 0.15) * 3)
            mountain_top_y += crag
            
            if y < mountain_top_y - 2:
                # Bầu trời bên trên núi
                wave = np.sin((x * 0.05)) * 6
                eff_y = y + wave
                if eff_y < 35:
                    bg_col = C_SKY_DUSK
                elif eff_y < 48:
                    bg_col = C_SKY_MAUVE if dither2x2(x, y) else C_SKY_DUSK
                elif eff_y < 70:
                    bg_col = C_SKY_MAUVE
                else:
                    bg_col = C_CLOUD_DARK if dither2x2(x, y) else C_SKY_MAUVE
                    
                # Vệt sáng mây hoàng hôn sau lưng núi
                if 50 <= eff_y <= 53 and x > 30 and (x % 3 != 0):
                    bg_col = C_CLOUD_HIGHLIGHT
                    
                pixels[x, y] = bg_col
                
            elif y <= mountain_top_y:
                # Viền đỉnh núi (Selective Outline #2e222f)
                pixels[x, y] = C_OUTLINE
            else:
                # Khối đá vôi bên trong núi
                depth = y - mountain_top_y
                if depth <= 4:
                    pixels[x, y] = C_DARK_ROCK if dither2x2(x, y) else C_OUTLINE
                elif depth <= 16:
                    # Đá sẫm màu rêu phong
                    pixels[x, y] = C_MOSS if dither2x2(x, y) else C_DARK_ROCK
                else:
                    # Phần lõi chân núi nối với nền gốc
                    # Nếu là rêu/đá/outline gốc thì giữ, nếu là rác chữ BECAM/gỗ thì tô màu đá/rêu
                    cur = pixels[x, y]
                    if cur not in [C_OUTLINE, C_DARK_ROCK, C_MOSS]:
                        pixels[x, y] = C_DARK_ROCK if (x + y) % 3 == 0 else C_OUTLINE

    # -------------------------------------------------------------
    # 3. KÉO DÀI CÁC THÂN TRÚC VÀ BỤI LÁ (Pixel Clusters)
    # -------------------------------------------------------------
    # Bụi trúc giữa (x: 180 .. 275):
    # Kéo các thân trúc thẳng đứng lên tận mép y=0
    stalks_mid = [188, 204, 222, 246, 268]
    for sx in stalks_mid:
        for y in range(0, 110):
            # Thân trúc rộng 4-5px với 2 đường viền #2e222f và ruột xanh #374e4a / #676633
            pixels[sx, y] = C_OUTLINE
            pixels[sx + 1, y] = C_MOSS
            pixels[sx + 2, y] = C_BAMBOO_MID if (y % 16 > 4) else C_MOSS
            pixels[sx + 3, y] = C_MOSS
            pixels[sx + 4, y] = C_OUTLINE
            # Đốt trúc ngang (bamboo node) mỗi 24px
            if y % 24 in [0, 1]:
                pixels[sx - 1, y] = C_OUTLINE
                pixels[sx, y] = C_OUTLINE
                pixels[sx + 1, y] = C_DARK_ROCK
                pixels[sx + 2, y] = C_DARK_ROCK
                pixels[sx + 3, y] = C_OUTLINE
                pixels[sx + 4, y] = C_OUTLINE
                pixels[sx + 5, y] = C_OUTLINE

    # Bụi trúc bên phải (x: 520 .. 640):
    stalks_right = [530, 560, 584, 612]
    for sx in stalks_right:
        for y in range(0, 70):
            if sx + 4 < w:
                pixels[sx, y] = C_OUTLINE
                pixels[sx + 1, y] = C_MOSS
                pixels[sx + 2, y] = C_BAMBOO_MID if (y % 18 > 4) else C_MOSS
                pixels[sx + 3, y] = C_OUTLINE
                if y % 22 in [0, 1]:
                    pixels[sx, y] = C_OUTLINE
                    pixels[sx + 1, y] = C_DARK_ROCK
                    pixels[sx + 2, y] = C_OUTLINE
                    pixels[sx + 3, y] = C_OUTLINE

    # Thêm các cụm lá trúc (clusters) buông lơi tự nhiên từ trên xuống
    # Lá trúc đặc trưng: các vệt dài 6-12px, chéo 45 độ, vuốt nhọn ở đầu
    def draw_leaf(x0, y0, dx, dy, length):
        for i in range(length):
            lx = int(x0 + i * dx)
            ly = int(y0 + i * dy)
            if 0 <= lx < w and 0 <= ly < h:
                pixels[lx, ly] = C_MOSS if (i > length // 2) else C_OUTLINE
                if i < length - 2:
                    if 0 <= lx + 1 < w:
                        pixels[lx + 1, ly] = C_OUTLINE

    # Cụm lá rủ ở ranh giới bụi trúc
    leaf_roots = [
        (188, 25, -1.2, 0.8, 10), (188, 50, -1.0, 1.0, 12), (188, 75, -1.4, 0.6, 9),
        (204, 15, -0.8, 1.2, 11), (204, 40, 1.0, 1.0, 13), (222, 20, 1.2, 0.7, 10),
        (222, 60, -1.1, 0.9, 12), (246, 30, 1.1, 0.8, 11), (268, 45, 1.3, 0.7, 14),
        (268, 70, 1.2, 0.9, 12), (530, 20, -1.2, 0.8, 12), (530, 45, -1.4, 0.7, 14),
        (530, 65, -1.1, 0.9, 10), (560, 25, -1.3, 0.7, 11), (560, 50, -1.0, 1.0, 12)
    ]
    for lx, ly, dx, dy, length in leaf_roots:
        draw_leaf(lx, ly, dx, dy, length)
        draw_leaf(lx, ly + 2, dx * 0.9, dy * 1.1, length - 2)

    img.save(OUT_PATH)
    print(f"Khôi phục hoàn tất background chuẩn Pixel Art: {OUT_PATH}")

if __name__ == "__main__":
    restore_background()
