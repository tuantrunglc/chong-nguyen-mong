#!/usr/bin/env python3
"""
Sửa toàn diện các lỗi kỹ thuật và mỹ thuật của Nhóm F (Màn hình chính & Quảng bá):
1. Khắc phục triệt để lỗi anti-aliasing / semi-transparent alpha: đưa toàn bộ về 1-bit binary alpha (0 hoặc 255).
2. Sửa lỗi font bị nhòe và rác màu: Render typography logo F3 với pixel-grid snapping, double outline hoàng kim - đỏ sẫm - bóng đen #2e222f.
3. Sửa lỗi nút bấm menu bị kéo méo (broken scaling): Áp dụng giải thuật 9-slice mở rộng nút chuẩn pixel art.
4. Sửa lỗi bìa itch.io F5: Loại bỏ scale tỷ lệ lẻ (1.3875x) và gradient mờ; thay bằng nền 1:1, dithering chuyển sắc retro, và xếp 6 quân đối đầu tỉ lệ integer x2.
5. Sửa bộ Icon game F4: Giữ nguyên icon 64x64, tạo các cỡ 256x256, 128x128, 32x32 theo đúng nguyên tắc integer scaling và pixel art chuyên dụng.
6. Đảm bảo 100% không còn bất kỳ pixel nào nằm ngoài bảng màu Resurrect 64.
"""

import os, glob
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
OUT_DIR = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh")

os.makedirs(OUT_DIR, exist_ok=True)

# 1. Load Resurrect 64
palette_rgb = []
with open(PALETTE_FILE) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith(("#", "GIMP", "Name", "Columns")):
            continue
        parts = line.split()
        if len(parts) >= 3:
            palette_rgb.append((int(parts[0]), int(parts[1]), int(parts[2])))

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
OUTLINE_COLOR = (46, 34, 47, 255) # #2e222f

def quantize_color(r, g, b):
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 30 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR[:3]
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    return palette_rgb[best_idx]

# -------------------------------------------------------------
# 1. FIX F3: Logo chữ "HÀO KHÍ ĐÔNG A"
# -------------------------------------------------------------
def fix_f3_logo():
    print("1. Đang sửa F3 Logo chữ 'HÀO KHÍ ĐÔNG A' (chuẩn 1-bit alpha & Resurrect 64)...")
    w, h = 420, 84
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    font = ImageFont.truetype(FONT_FILE, 36)
    text = "HÀO KHÍ ĐÔNG A"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (w - tw) // 2
    ty = (h - th) // 2 - 8
    
    # Bóng đổ đen #2e222f dày 3px
    for dx in range(-2, 4):
        for dy in range(1, 4):
            draw.text((tx + dx, ty + dy), text, font=font, fill=(46, 34, 47, 255))
            
    # Viền đỏ sẫm Đại Việt #b33831
    for dx in range(-2, 3):
        for dy in range(-2, 3):
            if abs(dx) + abs(dy) <= 3 and (dx != 0 or dy != 0):
                draw.text((tx + dx, ty + dy), text, font=font, fill=(179, 56, 49, 255))
                
    # Mặt chữ vàng hoàng kim #fbb954
    draw.text((tx, ty), text, font=font, fill=(251, 185, 84, 255))
    
    # Subtitle tiếng Việt: "CHIẾN THUẬT THEO LƯỢT THỜI TRẦN"
    sub_font = ImageFont.truetype(FONT_FILE, 11)
    sub_text = "— CHIẾN THUẬT THEO LƯỢT THỜI TRẦN —"
    s_bbox = draw.textbbox((0, 0), sub_text, font=sub_font)
    stw = s_bbox[2] - s_bbox[0]
    stx = (w - stw) // 2
    sty = ty + th + 10
    
    # Viền subtitle
    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1), (0,1)]:
        draw.text((stx + dx, sty + dy), sub_text, font=sub_font, fill=(46, 34, 47, 255))
    draw.text((stx, sty), sub_text, font=sub_font, fill=(171, 148, 122, 255)) # màu đồng cổ
    
    # ÉP ALPHA VỀ 1-BIT (0 hoặc 255) VÀ LƯỢNG TỬ HÓA 100% VỀ RESURRECT 64
    opt = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pix = img.load()
    opt_pix = opt.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = pix[x, y]
            if a >= 120:
                qr, qg, qb = quantize_color(r, g, b)
                opt_pix[x, y] = (qr, qg, qb, 255)
            else:
                opt_pix[x, y] = (0, 0, 0, 0)
                
    out_path = os.path.join(OUT_DIR, "f3_logo_chu_hao_khi_dong_a.png")
    opt.save(out_path)
    print(f"   -> Đã lưu {out_path} (0 semi-alpha, 100% Resurrect 64)")
    return opt

# -------------------------------------------------------------
# 2. FIX 9-SLICE CHO NÚT MENU
# -------------------------------------------------------------
def expand_9slice(src_im, target_w, target_h, corner_w=4, corner_h=4):
    """Mở rộng khung 9-slice chuẩn pixel art không làm méo 4 góc."""
    sw, sh = src_im.size
    out = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    
    # 4 góc
    tl = src_im.crop((0, 0, corner_w, corner_h))
    tr = src_im.crop((sw - corner_w, 0, sw, corner_h))
    bl = src_im.crop((0, sh - corner_h, corner_w, sh))
    br = src_im.crop((sw - corner_w, sh - corner_h, sw, sh))
    
    out.paste(tl, (0, 0))
    out.paste(tr, (target_w - corner_w, 0))
    out.paste(bl, (0, target_h - corner_h))
    out.paste(br, (target_w - corner_w, target_h - corner_h))
    
    # 4 cạnh
    tw = target_w - 2 * corner_w
    th = target_h - 2 * corner_h
    
    top_edge = src_im.crop((corner_w, 0, sw - corner_w, corner_h))
    bot_edge = src_im.crop((corner_w, sh - corner_h, sw - corner_w, sh))
    left_edge = src_im.crop((0, corner_h, corner_w, sh - corner_h))
    right_edge = src_im.crop((sw - corner_w, corner_h, sw, sh - corner_h))
    center = src_im.crop((corner_w, corner_h, sw - corner_w, sh - corner_h))
    
    out.paste(top_edge.resize((tw, corner_h), Image.NEAREST), (corner_w, 0))
    out.paste(bot_edge.resize((tw, corner_h), Image.NEAREST), (corner_w, target_h - corner_h))
    out.paste(left_edge.resize((corner_w, th), Image.NEAREST), (0, corner_h))
    out.paste(right_edge.resize((corner_w, th), Image.NEAREST), (target_w - corner_w, corner_h))
    out.paste(center.resize((tw, th), Image.NEAREST), (corner_w, corner_h))
    
    return out

# -------------------------------------------------------------
# 3. FIX MOCKUP TITLE SCREEN (_mockup_man_hinh_chinh_640x360.png)
# -------------------------------------------------------------
def fix_title_screen_mockup(logo_img):
    print("2. Đang sửa Mockup Title Screen (chuẩn 9-slice và 1-bit alpha)...")
    bg_path = os.path.join(OUT_DIR, "f1_nen_man_hinh.png")
    screen = Image.open(bg_path).convert("RGBA")
    
    # Dán logo F3 (1-bit alpha)
    lx = (640 - logo_img.width) // 2
    ly = 45
    screen.paste(logo_img, (lx, ly), logo_img)
    
    # Mở rộng nút Menu bằng thuật toán 9-slice
    btn_norm_raw = Image.open(os.path.join(BASE_DIR, "toi_uu", "giao_dien", "nut_normal.png"))
    btn_hov_raw = Image.open(os.path.join(BASE_DIR, "toi_uu", "giao_dien", "nut_hover.png"))
    
    bw, bh = 144, 26
    btn_normal = expand_9slice(btn_norm_raw, bw, bh, 4, 4)
    btn_hover = expand_9slice(btn_hov_raw, bw, bh, 4, 4)
    
    font = ImageFont.truetype(FONT_FILE, 11)
    menu_items = [
        ("BẮT ĐẦU TRẬN 1", True),
        ("CHỌN TRẬN ĐÁNH", False),
        ("CÀI ĐẶT", False),
        ("THOÁT", False)
    ]
    
    for idx, (label, is_hover) in enumerate(menu_items):
        base_btn = btn_hover if is_hover else btn_normal
        btn_copy = base_btn.copy()
        draw_b = ImageDraw.Draw(btn_copy)
        
        bbox = draw_b.textbbox((0, 0), label, font=font)
        lw = bbox[2] - bbox[0]
        lh = bbox[3] - bbox[1]
        bx = (bw - lw) // 2
        by = (bh - lh) // 2 - 2
        
        # Bóng đen 1px
        draw_b.text((bx + 1, by + 1), label, font=font, fill=(46, 34, 47, 255))
        # Mặt chữ
        text_color = (255, 255, 255, 255) if is_hover else (171, 148, 122, 255)
        draw_b.text((bx, by), label, font=font, fill=text_color)
        
        # Khử anti-aliasing chữ trên nút
        btn_pix = btn_copy.load()
        for y in range(bh):
            for x in range(bw):
                r, g, b, a = btn_pix[x, y]
                if a > 0:
                    qr, qg, qb = quantize_color(r, g, b)
                    btn_pix[x, y] = (qr, qg, qb, 255)
                    
        sx = (640 - bw) // 2
        sy = 165 + idx * 32
        screen.paste(btn_copy, (sx, sy), btn_copy)
        
    # Version text góc dưới
    draw_scr = ImageDraw.Draw(screen)
    ver_font = ImageFont.truetype(FONT_FILE, 10)
    draw_scr.text((12, 340), "Hào Khí Đông A v0.2.10 — Godot 4.x", font=ver_font, fill=(155, 171, 178, 255))
    draw_scr.text((535, 340), "© 2026 Đại Việt Tactics", font=ver_font, fill=(155, 171, 178, 255))
    
    # Đảm bảo 100% alpha = 255
    s_pix = screen.load()
    for y in range(360):
        for x in range(640):
            r, g, b, a = s_pix[x, y]
            qr, qg, qb = quantize_color(r, g, b)
            s_pix[x, y] = (qr, qg, qb, 255)
            
    out_path = os.path.join(OUT_DIR, "_mockup_man_hinh_chinh_640x360.png")
    screen.save(out_path)
    print(f"   -> Đã lưu {out_path} (chuẩn 9-slice, 0 semi-alpha)")

# -------------------------------------------------------------
# 4. FIX F4: BỘ ICON GAME & FAVICON (256, 128, 64, 32)
# -------------------------------------------------------------
def fix_f4_icons():
    print("3. Đang sửa F4 Bộ Icon Game (chuẩn integer scale & favicon pixel art)...")
    base_path = os.path.join(OUT_DIR, "f4_icon_game.png")
    base_im = Image.open(base_path).convert("RGBA")
    
    # 64x64 gốc: đã chuẩn
    # 128x128: Integer 2x scale
    im_128 = base_im.resize((128, 128), Image.NEAREST)
    im_128.save(os.path.join(OUT_DIR, "f4_icon_128x128.png"))
    
    # 256x256: Integer 4x scale
    im_256 = base_im.resize((256, 256), Image.NEAREST)
    im_256.save(os.path.join(OUT_DIR, "f4_icon_256x256.png"))
    
    # 32x32: Favicon web - Thiết kế lại ở độ phân giải 32x32 để biểu tượng đọc cực nét
    fav = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    # Downscale bằng nearest neighbor rồi làm sạch
    small = base_im.resize((32, 32), Image.NEAREST)
    fav_pix = small.load()
    for y in range(32):
        for x in range(32):
            r, g, b, a = fav_pix[x, y]
            if a >= 128:
                qr, qg, qb = quantize_color(r, g, b)
                fav_pix[x, y] = (qr, qg, qb, 255)
            else:
                fav_pix[x, y] = (0, 0, 0, 0)
    small.save(os.path.join(OUT_DIR, "f4_icon_32x32.png"))
    print("   -> Đã lưu đầy đủ 256x256, 128x128, 64x64, 32x32 (chuẩn integer)")

# -------------------------------------------------------------
# 5. FIX F5: ẢNH BÌA ITCH.IO (630x500)
# -------------------------------------------------------------
def fix_f5_itch_io_cover(logo_img):
    print("4. Đang sửa F5 Ảnh bìa itch.io 630x500 (loại bỏ fractional scale & gradient)...")
    cw, ch = 630, 500
    cover = Image.new("RGBA", (cw, ch), (30, 26, 35, 255))
    
    # 1. Nền Bạch Đằng F1 (640x360): Crop chính xác 5px mỗi bên -> 630x360 (TỶ LỆ 1:1 HOÀN HẢO)
    bg_path = os.path.join(OUT_DIR, "f1_nen_man_hinh.png")
    bg = Image.open(bg_path).convert("RGBA")
    bg_1to1 = bg.crop((5, 0, 635, 360)) # 630 x 360
    cover.paste(bg_1to1, (0, 0))
    
    # 2. Mở rộng 140px phía dưới bằng nước sông & tiền đồn với DITHERING RETRO
    # Dải màu: Nước sâu (#374e4a), Xanh than (#313638), Đen (#2e222f)
    c_water_deep = (55, 78, 74, 255)
    c_water_dark = (49, 54, 56, 255)
    c_bottom_black = (46, 34, 47, 255)
    
    draw_c = ImageDraw.Draw(cover)
    for y in range(360, 500):
        for x in range(cw):
            # Kỹ thuật Dithering bàn cờ 2x2
            is_check = ((x // 2) + (y // 2)) % 2 == 0
            if y < 400:
                # Chuyển từ nước sâu sang xanh than
                col = c_water_dark if is_check else c_water_deep
            elif y < 450:
                # Chuyển từ xanh than sang đen
                col = c_bottom_black if is_check else c_water_dark
            else:
                col = c_bottom_black
            cover.putpixel((x, y), col)
            
    # Vẽ các ngọn cọc gỗ cắm trên sông ở tiền cảnh (gợi nhớ trận Bạch Đằng)
    for stake_x in [60, 140, 220, 420, 500, 580]:
        stake_h = 35 + (stake_x % 20)
        # Cọc vót nhọn
        for sy in range(stake_h):
            w_stake = max(1, 3 - sy // 12)
            for dx in range(-w_stake, w_stake + 1):
                px = stake_x + dx
                py = 390 - sy
                if 0 <= px < cw and 0 <= py < ch:
                    cover.putpixel((px, py), (76, 62, 36, 255))
                    
    # 3. Logo F3 ở trên cùng
    lx = (cw - logo_img.width) // 2
    cover.paste(logo_img, (lx, 20), logo_img)
    
    # 4. Đặt 6 quân cờ đối đầu tỷ lệ integer x2 (128x128)
    u_sz = 128
    
    # Đại Việt (bên trái nhìn sang phải)
    khoai = Image.open(os.path.join(BASE_DIR, "toi_uu", "khoai", "south-east.png")).resize((u_sz, u_sz), Image.NEAREST)
    lao = Image.open(os.path.join(BASE_DIR, "toi_uu", "lao", "south-east.png")).resize((u_sz, u_sz), Image.NEAREST)
    du = Image.open(os.path.join(BASE_DIR, "toi_uu", "du", "east.png")).resize((u_sz, u_sz), Image.NEAREST)
    
    # Nguyên (bên phải nhìn sang trái)
    bo_binh = Image.open(os.path.join(BASE_DIR, "toi_uu", "nguyen_v3", "south-west.png")).resize((u_sz, u_sz), Image.NEAREST)
    ky_binh = Image.open(os.path.join(BASE_DIR, "toi_uu", "ky_binh", "south-west.png")).resize((u_sz, u_sz), Image.NEAREST)
    cung_ky = Image.open(os.path.join(BASE_DIR, "toi_uu", "cung_ky", "west.png")).resize((u_sz, u_sz), Image.NEAREST)
    
    # Dán quân Đại Việt
    cover.paste(lao, (25, 250), lao)
    cover.paste(du, (165, 235), du)
    cover.paste(khoai, (100, 290), khoai) # Khoái đứng trước
    
    # Dán quân Nguyên
    cover.paste(ky_binh, (485, 250), ky_binh)
    cover.paste(cung_ky, (345, 235), cung_ky)
    cover.paste(bo_binh, (410, 290), bo_binh) # Bộ binh đứng trước
    
    # Hiệu ứng va chạm C3 giữa 2 phe
    c3 = Image.open(os.path.join(BASE_DIR, "toi_uu", "hieu_ung", "c3_va_cham.png")).resize((96, 96), Image.NEAREST)
    cover.paste(c3, (267, 305), c3)
    
    # 5. Dòng Tagline chuẩn 1-bit text dưới chân
    tag_font = ImageFont.truetype(FONT_FILE, 11)
    tag_text = "TURN-BASED TACTICS • 13th CENTURY VIETNAM • TRAN DYNASTY RESISTANCE"
    tb = draw_c.textbbox((0, 0), tag_text, font=tag_font)
    tw = tb[2] - tb[0]
    tx = (cw - tw) // 2
    ty = 472
    draw_c.text((tx + 1, ty + 1), tag_text, font=tag_font, fill=(46, 34, 47, 255))
    draw_c.text((tx, ty), tag_text, font=tag_font, fill=(251, 185, 84, 255))
    
    # Khung viền đồng 2px
    draw_c.rectangle([0, 0, cw-1, ch-1], outline=(171, 148, 122, 255), width=2)
    
    # Lượng tử hóa toàn bộ ảnh về Resurrect 64 và đảm bảo alpha = 255
    cov_pix = cover.load()
    for y in range(ch):
        for x in range(cw):
            r, g, b, a = cov_pix[x, y]
            qr, qg, qb = quantize_color(r, g, b)
            cov_pix[x, y] = (qr, qg, qb, 255)
            
    out_path = os.path.join(OUT_DIR, "f5_anh_bia_itch_io_630x500.png")
    cover.save(out_path)
    print(f"   -> Đã lưu {out_path} (chuẩn 1:1, 0 fractional scale, 0 semi-alpha, 100% Resurrect 64)")

if __name__ == "__main__":
    logo = fix_f3_logo()
    fix_title_screen_mockup(logo)
    fix_f4_icons()
    fix_f5_itch_io_cover(logo)
    print("\nHOÀN TẤT TOÀN DIỆN VIỆC SỬA LỖI NHÓM F!")
