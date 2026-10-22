#!/usr/bin/env python3
"""
Tải và tối ưu hóa bộ Màn hình chính & Quảng bá (F1, F3, F4):
- F1: Nền màn hình chính (640x360)
- F3: Logo chữ "Hào Khí Đông A" (bản huy hiệu và bản typography tiếng Việt chuẩn font thời Trần)
- F4: Biểu tượng game / Favicon (đa kích thước 256, 128, 64, 32)
- Phối cảnh hoàn chỉnh Title Screen (640x360)
Quy chuẩn 100% bảng màu Resurrect 64.
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
RAW_DIR = os.path.join(BASE_DIR, "man_hinh_chinh_raw")
OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(OPT_DIR, exist_ok=True)

JOBS = {
    "f1_nen_man_hinh": "ce86a082-7415-4c11-88cb-a3f3648fdcad",
    "f4_icon_game": "1dc65480-3159-47c0-92c9-4a544f3fd13a",
    "f3_badge_logo": "b3aa9560-87cf-44fb-9b53-d53bbdfb6ae9"
}

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
OUTLINE_COLOR = (46, 34, 47, 255)

def quantize_pixel(r, g, b, a):
    if a < 100:
        return (0, 0, 0, 0)
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    return (best_rgb[0], best_rgb[1], best_rgb[2], a)

def clean_orphan_pixels(im):
    w, h = im.size
    pix = im.load()
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            curr = pix[x, y]
            if curr[3] == 0:
                continue
            neighbors = [pix[x+dx, y+dy] for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]]
            if all(n[3] == 0 for n in neighbors):
                pix[x, y] = (0, 0, 0, 0)
    return im

def download_file(url, target_path):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=60) as response, open(target_path, 'wb') as out_file:
        out_file.write(response.read())

def fetch_and_optimize():
    print("1. Tải và tối ưu các ảnh từ PixelLab:")
    for name, jid in JOBS.items():
        print(f"  Kiểm tra {name} ({jid})...")
        for _ in range(15):
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                m = re.search(r"download:\s*(https://\S+)", res)
                if m:
                    url = m.group(1)
                    raw_path = os.path.join(RAW_DIR, f"{name}.png")
                    download_file(url, raw_path)
                    
                    im = Image.open(raw_path).convert("RGBA")
                    opt = Image.new("RGBA", im.size)
                    opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in im.getdata()]
                    opt.putdata(opt_data)
                    if name != "f1_nen_man_hinh":
                        opt = clean_orphan_pixels(opt)
                        
                    opt_path = os.path.join(OPT_DIR, f"{name}.png")
                    opt.save(opt_path)
                    print(f"    + Đã lưu: {opt_path} ({im.size})")
                    break
            time.sleep(4)

def generate_logo_typography():
    print("\n2. Tạo Logo chữ 'HÀO KHÍ ĐÔNG A' chuẩn pixel art:")
    # Render typography logo sắc nét
    w, h = 420, 84
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    font = ImageFont.truetype(FONT_FILE, 36)
    text = "HÀO KHÍ ĐÔNG A"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (w - tw) // 2
    ty = (h - th) // 2 - 4
    
    # Bóng đổ dày 2-3px đen #2e222f
    for dx in range(-2, 4):
        for dy in range(1, 4):
            draw.text((tx + dx, ty + dy), text, font=font, fill=(46, 34, 47, 255))
            
    # Viền đỏ sẫm Đại Việt #b33831
    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (1,-1), (-1,1), (1,1)]:
        draw.text((tx + dx, ty + dy), text, font=font, fill=(179, 56, 49, 255))
        
    # Mặt chữ vàng hoàng kim #fbb954
    draw.text((tx, ty), text, font=font, fill=(251, 185, 84, 255))
    
    # Subtitle nhỏ: CHIẾN THUẬT THỜI TRẦN
    sub_font = ImageFont.truetype(FONT_FILE, 12)
    sub_text = "— CHIẾN THUẬT THEO LƯỢT THỜI TRẦN —"
    s_bbox = draw.textbbox((0, 0), sub_text, font=sub_font)
    stx = (w - (s_bbox[2] - s_bbox[0])) // 2
    sty = ty + th + 10
    draw.text((stx + 1, sty + 1), sub_text, font=sub_font, fill=(46, 34, 47, 255))
    draw.text((stx, sty), sub_text, font=sub_font, fill=(171, 148, 122, 255)) # màu đồng
    
    # Lượng tử hóa về Resurrect 64
    opt = Image.new("RGBA", (w, h))
    opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in img.getdata()]
    opt.putdata(opt_data)
    
    out_path = os.path.join(OPT_DIR, "f3_logo_chu_hao_khi_dong_a.png")
    opt.save(out_path)
    print(f"  + Đã lưu: {out_path}")
    return opt

def generate_multi_size_icons():
    print("\n3. Tạo các cỡ Icon game F4:")
    base_icon_path = os.path.join(OPT_DIR, "f4_icon_game.png")
    if not os.path.exists(base_icon_path):
        return
    base = Image.open(base_icon_path).convert("RGBA")
    
    for sz in [256, 128, 64, 32]:
        resized = base.resize((sz, sz), Image.NEAREST)
        # Bọc nền bo góc nhẹ
        canvas = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
        # Viền tròn/vuông bo nhẹ
        draw = ImageDraw.Draw(canvas)
        r = sz // 8
        draw.rounded_rectangle([0, 0, sz-1, sz-1], radius=r, fill=(46, 34, 47, 255), outline=(171, 148, 122, 255), width=max(1, sz//32))
        pad = sz // 10
        inner = base.resize((sz - 2*pad, sz - 2*pad), Image.NEAREST)
        canvas.paste(inner, (pad, pad), inner)
        
        opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in canvas.getdata()]
        canvas.putdata(opt_data)
        
        ic_p = os.path.join(OPT_DIR, f"f4_icon_{sz}x{sz}.png")
        canvas.save(ic_p)
        print(f"  + Đã lưu: {ic_p}")

def build_title_screen_mockup(logo_img):
    print("\n4. Phối cảnh mẫu Màn hình chính hoàn chỉnh (640x360):")
    bg_path = os.path.join(OPT_DIR, "f1_nen_man_hinh.png")
    if not os.path.exists(bg_path):
        return
        
    screen = Image.open(bg_path).convert("RGBA")
    
    # 1. Đặt Logo chữ ở giữa trên
    lx = (640 - logo_img.width) // 2
    ly = 45
    screen.paste(logo_img, (lx, ly), logo_img)
    
    # 2. Đặt nút bấm vào giữa dưới (mẫu các nút Menu)
    btn_normal_path = os.path.join(BASE_DIR, "toi_uu", "giao_dien", "nut_normal.png")
    btn_hover_path = os.path.join(BASE_DIR, "toi_uu", "giao_dien", "nut_hover.png")
    
    font = ImageFont.truetype(FONT_FILE, 11)
    
    menu_items = [
        ("BẮT ĐẦU TRẬN 1", True),
        ("CHỌN TRẬN ĐÁNH", False),
        ("CÀI ĐẶT", False),
        ("THOÁT", False)
    ]
    
    for idx, (label, is_hover) in enumerate(menu_items):
        p = btn_hover_path if is_hover else btn_normal_path
        if os.path.exists(p):
            btn = Image.open(p).convert("RGBA")
            # Mở rộng nút cho menu: 140x26
            bw, bh = 140, 26
            b_scaled = btn.resize((bw, bh), Image.NEAREST)
            draw_b = ImageDraw.Draw(b_scaled)
            bbox = draw_b.textbbox((0, 0), label, font=font)
            lw = bbox[2] - bbox[0]
            lh = bbox[3] - bbox[1]
            bx = (bw - lw) // 2
            by = (bh - lh) // 2 - 1
            col = (255, 255, 255, 255) if is_hover else (200, 210, 215, 255)
            draw_b.text((bx+1, by+1), label, font=font, fill=(46, 34, 47, 255))
            draw_b.text((bx, by), label, font=font, fill=col)
            
            # Đặt vào màn hình
            sx = (640 - bw) // 2
            sy = 165 + idx * 32
            screen.paste(b_scaled, (sx, sy), b_scaled)
            
    # Thêm số phiên bản góc dưới
    draw_scr = ImageDraw.Draw(screen)
    ver_font = ImageFont.truetype(FONT_FILE, 10)
    draw_scr.text((12, 340), "Hào Khí Đông A v0.2.10 — Godot 4.x", font=ver_font, fill=(155, 171, 178, 255))
    draw_scr.text((540, 340), "© 2026 Đại Việt", font=ver_font, fill=(155, 171, 178, 255))
    
    out_path = os.path.join(OPT_DIR, "_mockup_man_hinh_chinh_640x360.png")
    screen.save(out_path)
    print(f"  + Đã lưu ảnh phối cảnh hoàn chỉnh: {out_path}")

if __name__ == "__main__":
    fetch_and_optimize()
    logo = generate_logo_typography()
    generate_multi_size_icons()
    build_title_screen_mockup(logo)
