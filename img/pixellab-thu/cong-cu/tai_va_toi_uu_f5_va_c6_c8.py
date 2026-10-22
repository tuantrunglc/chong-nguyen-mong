#!/usr/bin/env python3
"""
Tải và tối ưu hóa nốt các hiệu ứng kỹ năng C6–C8 và xuất ảnh bìa itch.io F5 (630x500):
- C6: Lửa cháy kho lương (Vườn không nhà trống)
- C7: Hào quang đỏ Sát Thát
- C8: Dấu báo quân tiếp viện
- F5: Ảnh bìa itch.io 630x500 hoàn chỉnh với bố cục 2 phe đối đầu
100% chuẩn bảng màu Resurrect 64.
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

VFX_RAW_DIR = os.path.join(BASE_DIR, "hieu_ung")
VFX_OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "hieu_ung")
SCREEN_OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "man_hinh_chinh")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

os.makedirs(VFX_RAW_DIR, exist_ok=True)
os.makedirs(VFX_OPT_DIR, exist_ok=True)
os.makedirs(SCREEN_OPT_DIR, exist_ok=True)

JOBS_VFX = {
    "c6_lua_chay_kho": "67c45ea5-1fb4-48ce-bb05-813f39ed0dde",
    "c7_hao_quang_sat_that": "f7b5c4e6-a723-4289-8723-bf97ac757dc8",
    "c8_dau_tiep_vien": "e3ffafec-79e5-4588-a4cd-071158f2e78d"
}

# Load Resurrect 64
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
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 26 or (r < 40 and g < 40 and b < 46):
        return OUTLINE_COLOR
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

def fetch_and_optimize_vfx():
    print("1. Tải và tối ưu hóa hiệu ứng C6–C8:")
    for name, jid in JOBS_VFX.items():
        print(f"  Kiểm tra {name} ({jid})...")
        for _ in range(15):
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                m = re.search(r"download:\s*(https://\S+)", res)
                if m:
                    url = m.group(1)
                    raw_path = os.path.join(VFX_RAW_DIR, f"{name}.png")
                    download_file(url, raw_path)
                    
                    im = Image.open(raw_path).convert("RGBA")
                    opt = Image.new("RGBA", im.size)
                    opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in im.getdata()]
                    opt.putdata(opt_data)
                    opt = clean_orphan_pixels(opt)
                    
                    opt_path = os.path.join(VFX_OPT_DIR, f"{name}.png")
                    opt.save(opt_path)
                    print(f"    + Đã lưu: {opt_path} ({im.size})")
                    break
            time.sleep(4)

def generate_vfx_summary():
    print("\n2. Tạo ảnh tổng hợp toàn bộ 8 hiệu ứng C1–C8:")
    scale = 3
    pad = 12
    box_size = 48 * scale
    
    effects = [
        ("C1: Lao bay", os.path.join(VFX_OPT_DIR, "c1_lao_bay.png")),
        ("C2: Mũi tên", os.path.join(VFX_OPT_DIR, "c2_ten_bay.png")),
        ("C3: Va chạm", os.path.join(VFX_OPT_DIR, "c3_va_cham.png")),
        ("C4: Nước bắn", os.path.join(VFX_OPT_DIR, "c4_nuoc_ban.png")),
        ("C5: Chông đâm", os.path.join(VFX_OPT_DIR, "c5_chong_dam.png")),
        ("C6: Lửa kho", os.path.join(VFX_OPT_DIR, "c6_lua_chay_kho.png")),
        ("C7: Hào quang", os.path.join(VFX_OPT_DIR, "c7_hao_quang_sat_that.png")),
        ("C8: Tiếp viện", os.path.join(VFX_OPT_DIR, "c8_dau_tiep_vien.png")),
    ]
    
    cols = 4
    rows = 2
    canvas_w = pad + cols * (box_size + pad)
    canvas_h = pad + rows * (box_size + pad)
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (30, 26, 35, 255))
    
    for idx, (label, path) in enumerate(effects):
        c = idx % cols
        r = idx // cols
        if os.path.exists(path):
            im = Image.open(path).convert("RGBA")
            cell = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
            ox = (48 - im.width) // 2
            oy = (48 - im.height) // 2
            cell.paste(im, (ox, oy), im)
            cell_scaled = cell.resize((box_size, box_size), Image.NEAREST)
            canvas.paste(cell_scaled, (pad + c * (box_size + pad), pad + r * (box_size + pad)), cell_scaled)
            
    out_p = os.path.join(VFX_OPT_DIR, "_tong_hop_tat_ca_hieu_ung_c1_c8.png")
    canvas.save(out_p)
    print(f"  + Đã lưu tổng hợp C1–C8: {out_p}")

def generate_itch_io_cover():
    print("\n3. Tạo Ảnh bìa itch.io F5 (630x500):")
    cw, ch = 630, 500
    cover = Image.new("RGBA", (cw, ch), (30, 26, 35, 255))
    
    # 1. Lấy nền Bạch Đằng F1 và crop/scale căn giữa
    bg_path = os.path.join(SCREEN_OPT_DIR, "f1_nen_man_hinh.png")
    if os.path.exists(bg_path):
        bg = Image.open(bg_path).convert("RGBA")
        # Scale tỷ lệ phủ kín 630x500: bg là 640x360 -> scale lên 888x500 rồi crop giữa
        bg_scaled = bg.resize((888, 500), Image.NEAREST)
        crop_x = (888 - 630) // 2
        bg_cropped = bg_scaled.crop((crop_x, 0, crop_x + 630, 500))
        cover.paste(bg_cropped, (0, 0))
        
    # Làm tối nhẹ nửa dưới để quân cờ và chữ nổi bật
    dimmer = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    draw_dim = ImageDraw.Draw(dimmer)
    for y in range(ch):
        if y < 140:
            alpha = int(40 + (y / 140) * 40)
        else:
            alpha = int(80 + ((y - 140) / 360) * 110)
        draw_dim.line([(0, y), (cw, y)], fill=(30, 26, 35, alpha))
    cover.alpha_composite(dimmer)
    
    # 2. Đặt Logo chữ ở phía trên
    logo_path = os.path.join(SCREEN_OPT_DIR, "f3_logo_chu_hao_khi_dong_a.png")
    if os.path.exists(logo_path):
        logo = Image.open(logo_path).convert("RGBA")
        lx = (cw - logo.width) // 2
        cover.paste(logo, (lx, 24), logo)
        
    # 3. Đặt 6 quân cờ đối đầu ở nửa dưới
    # Bên trái: Đại Việt (Khoái, Lão, Dư) phóng x2.5 (~160px)
    # Bên phải: Nguyên (Bộ binh, Kỵ binh, Cung kỵ) phóng x2.5
    u_size = 128 # 64 * 2
    
    dv_units = [
        ("Khoái", os.path.join(BASE_DIR, "toi_uu", "khoai", "south-east.png")),
        ("Lão", os.path.join(BASE_DIR, "toi_uu", "lao", "south-east.png")),
        ("Dư", os.path.join(BASE_DIR, "toi_uu", "du", "east.png")),
    ]
    
    nguyen_units = [
        ("Bộ binh", os.path.join(BASE_DIR, "toi_uu", "nguyen_v3", "south-west.png")),
        ("Kỵ binh", os.path.join(BASE_DIR, "toi_uu", "ky_binh", "south-west.png")),
        ("Cung kỵ", os.path.join(BASE_DIR, "toi_uu", "cung_ky", "west.png")),
    ]
    
    # Đại Việt bên trái (hàng trước sau)
    # Khoái ở giữa, Lão bên trái, Dư bên phải
    dv_coords = [(110, 290), (30, 260), (170, 240)]
    for (name, p), (ux, uy) in zip(dv_units, dv_coords):
        if os.path.exists(p):
            im = Image.open(p).convert("RGBA").resize((u_size, u_size), Image.NEAREST)
            cover.paste(im, (ux, uy), im)
            
    # Quân Nguyên bên phải (đối mặt nhìn sang trái)
    nguyen_coords = [(400, 290), (480, 260), (340, 240)]
    for (name, p), (ux, uy) in zip(nguyen_units, nguyen_coords):
        if os.path.exists(p):
            im = Image.open(p).convert("RGBA").resize((u_size, u_size), Image.NEAREST)
            cover.paste(im, (ux, uy), im)
            
    # Hiệu ứng va chạm C3 ở trung tâm giữa 2 phe
    c3_path = os.path.join(VFX_OPT_DIR, "c3_va_cham.png")
    if os.path.exists(c3_path):
        c3 = Image.open(c3_path).convert("RGBA").resize((96, 96), Image.NEAREST)
        cover.paste(c3, (267, 305), c3)
        
    # Thêm dòng chữ tag dưới đáy
    draw_c = ImageDraw.Draw(cover)
    font = ImageFont.truetype(FONT_FILE, 11)
    tag_text = "TURN-BASED TACTICS • 13th CENTURY VIETNAM • TRAN DYNASTY RESISTANCE"
    t_bbox = draw_c.textbbox((0, 0), tag_text, font=font)
    tx = (cw - (t_bbox[2] - t_bbox[0])) // 2
    draw_c.text((tx+1, 470+1), tag_text, font=font, fill=(46, 34, 47, 255))
    draw_c.text((tx, 470), tag_text, font=font, fill=(251, 185, 84, 255))
    
    # Viền khung ngoài 1px đồng
    draw_c.rectangle([0, 0, cw-1, ch-1], outline=(171, 148, 122, 255), width=2)
    
    # Lượng tử hóa 100% về Resurrect 64
    print("  Đang lượng tử hóa ảnh bìa về Resurrect 64...")
    opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in cover.getdata()]
    cover.putdata(opt_data)
    
    out_path = os.path.join(SCREEN_OPT_DIR, "f5_anh_bia_itch_io_630x500.png")
    cover.save(out_path)
    print(f"  + Đã lưu ảnh bìa itch.io F5: {out_path}")

if __name__ == "__main__":
    fetch_and_optimize_vfx()
    generate_vfx_summary()
    generate_itch_io_cover()
