#!/usr/bin/env python3
"""
Tải và khởi tạo toàn bộ bộ Giao diện UI thời Trần (D1–D4):
- D1: Khung 9-slice sơn mài viền đồng (khung bảng 48x48, khung tooltip 32x32)
- D2: Bộ nút bấm (Normal, Hover, Pressed, Disabled) dạng 80x24 và dạng 9-slice 32x24
- D3: Biểu tượng 2 mưu kế (Vườn không nhà trống, Sát Thát)
- D4: Biểu tượng trạng thái HUD (Máu HP, Lòng dân)
Tất cả 100% chuẩn bảng màu Resurrect 64.
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image, ImageDraw

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
RAW_DIR = os.path.join(BASE_DIR, "giao_dien_raw")
OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "giao_dien")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(OPT_DIR, exist_ok=True)

JOBS = {
    "ke_vuon_khong_nha_trong": "2a5f2c17-bc35-4b2e-8fd4-9367fa15496a",
    "ke_sat_that": "769ff14b-3b49-4889-b179-5d0b7dab7c34",
    "icon_long_dan": "43b49cfb-3fdc-408b-a90a-2201c88dee7b",
    "icon_mau": "e465d125-17fa-4300-bb5b-bd3fef4b800c"
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
OUTLINE_COLOR = (46, 34, 47, 255) # #2e222f

def quantize_pixel(r, g, b, a):
    if a < 100:
        return (0, 0, 0, 0)
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 28 or (r < 44 and g < 44 and b < 50):
        return OUTLINE_COLOR
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    return (best_rgb[0], best_rgb[1], best_rgb[2], 255)

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

def fetch_and_optimize_icons():
    print("1. Tải và tối ưu các biểu tượng từ PixelLab:")
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
                    opt = clean_orphan_pixels(opt)
                    
                    opt_path = os.path.join(OPT_DIR, f"{name}.png")
                    opt.save(opt_path)
                    print(f"    + Đã lưu {opt_path}")
                    break
            time.sleep(4)

def draw_9slice_panel(size=48, margin=8):
    # Khung bảng sơn mài viền đồng
    # Màu chuẩn Resurrect 64:
    # Viền đen ngoài: (46, 34, 47) #2e222f
    # Viền đồng sáng: (171, 148, 122) #ab947a
    # Viền đồng tối: (76, 62, 36) #4c3e24
    # Nền sơn mài sẫm: (49, 54, 56) #313638 / (62, 53, 70) #3e3546
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pix = im.load()
    
    C_OUTLINE = (46, 34, 47, 255)
    C_BRONZE_HI = (171, 148, 122, 255)
    C_BRONZE_MID = (103, 102, 51, 255)
    C_BRONZE_LO = (76, 62, 36, 255)
    C_BG = (49, 54, 56, 240)
    C_BG_INNER = (38, 41, 43, 240)
    
    # Fill background
    for y in range(size):
        for x in range(size):
            # Cắt góc 2px
            if (x < 2 and y < 2) or (x >= size - 2 and y < 2) or (x < 2 and y >= size - 2) or (x >= size - 2 and y >= size - 2):
                continue
            pix[x, y] = C_BG
            
    # Draw border
    for y in range(size):
        for x in range(size):
            # Outer 1px contour
            is_edge = (x == 0 or x == size - 1 or y == 0 or y == size - 1)
            is_corner_notch = ((x in (0, 1) and y in (0, 1)) or 
                               (x in (size-2, size-1) and y in (0, 1)) or
                               (x in (0, 1) and y in (size-2, size-1)) or
                               (x in (size-2, size-1) and y in (size-2, size-1)))
            if is_edge and not is_corner_notch:
                pix[x, y] = C_OUTLINE
            elif (x, y) in [(1,1), (size-2, 1), (1, size-2), (size-2, size-2)]:
                pix[x, y] = C_OUTLINE
                
    # Inner bronze trim (1px)
    for x in range(2, size - 2):
        pix[x, 1] = C_BRONZE_HI
        pix[x, 2] = C_BRONZE_LO
        pix[x, size - 2] = C_BRONZE_LO
    for y in range(2, size - 2):
        pix[1, y] = C_BRONZE_HI
        pix[2, y] = C_BRONZE_MID
        pix[size - 2, y] = C_BRONZE_LO
        
    # Bronze decorative corners at margin
    for cx, cy in [(margin-1, margin-1), (size-margin, margin-1), (margin-1, size-margin), (size-margin, size-margin)]:
        pix[cx, cy] = C_BRONZE_HI
        
    return im

def draw_button(w=80, h=24, state="normal"):
    # state: "normal", "hover", "pressed", "disabled"
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pix = im.load()
    
    C_OUTLINE = (46, 34, 47, 255)
    
    if state == "normal":
        C_BORDER_HI = (171, 148, 122, 255) # đồng sáng
        C_BORDER_LO = (76, 62, 36, 255)    # đồng tối
        C_BG_TOP = (62, 53, 70, 255)       # sơn mài tím đen
        C_BG_BOT = (46, 34, 47, 255)
    elif state == "hover":
        C_BORDER_HI = (251, 185, 84, 255)  # vàng hoàng kim rực
        C_BORDER_LO = (205, 104, 61, 255)  # đồng lửa
        C_BG_TOP = (73, 60, 80, 255)       # sáng hơn
        C_BG_BOT = (52, 42, 56, 255)
    elif state == "pressed":
        C_BORDER_HI = (76, 62, 36, 255)    # đồng tối
        C_BORDER_LO = (171, 148, 122, 255) # đảo ngược ánh sáng
        C_BG_TOP = (38, 30, 42, 255)       # lún tối
        C_BG_BOT = (46, 34, 47, 255)
    else: # disabled
        C_BORDER_HI = (98, 85, 101, 255)   # xám thép
        C_BORDER_LO = (49, 54, 56, 255)
        C_BG_TOP = (49, 54, 56, 200)
        C_BG_BOT = (35, 38, 40, 200)
        
    for y in range(h):
        for x in range(w):
            # vát góc 1px
            if (x == 0 and y == 0) or (x == w - 1 and y == 0) or (x == 0 and y == h - 1) or (x == w - 1 and y == h - 1):
                continue
            # Viền ngoài
            if x == 0 or x == w - 1 or y == 0 or y == h - 1:
                pix[x, y] = C_OUTLINE
            elif y == 1:
                pix[x, y] = C_BORDER_HI
            elif x == 1:
                pix[x, y] = C_BORDER_HI
            elif y == h - 2 or x == w - 2:
                pix[x, y] = C_BORDER_LO
            else:
                # Gradient ruột
                t = (y - 2) / max(1, (h - 4))
                r = int(C_BG_TOP[0] * (1 - t) + C_BG_BOT[0] * t)
                g = int(C_BG_TOP[1] * (1 - t) + C_BG_BOT[1] * t)
                b = int(C_BG_TOP[2] * (1 - t) + C_BG_BOT[2] * t)
                pix[x, y] = (r, g, b, 255)
                
    # Quy chuẩn 100% về Resurrect 64
    opt_data = [quantize_pixel(r, g, b, a) for (r, g, b, a) in im.getdata()]
    im.putdata(opt_data)
    return im

def build_all_ui():
    fetch_and_optimize_icons()
    
    print("\n2. Xuất các khung bảng 9-slice:")
    panel_48 = draw_9slice_panel(48, margin=8)
    p48_path = os.path.join(OPT_DIR, "khung_bang_48x48.png")
    panel_48.save(p48_path)
    print(f"  + Đã lưu: {p48_path} (margin: 8px)")
    
    tooltip_32 = draw_9slice_panel(32, margin=6)
    t32_path = os.path.join(OPT_DIR, "khung_tooltip_32x32.png")
    tooltip_32.save(t32_path)
    print(f"  + Đã lưu: {t32_path} (margin: 6px)")
    
    print("\n3. Xuất bộ 4 trạng thái nút bấm:")
    for state in ["normal", "hover", "pressed", "disabled"]:
        # Nút kích thước cố định 80x24
        btn = draw_button(80, 24, state)
        b_path = os.path.join(OPT_DIR, f"nut_{state}.png")
        btn.save(b_path)
        
        # Nút 9-slice 32x24 (margin: 6px)
        btn_9 = draw_button(32, 24, state)
        b9_path = os.path.join(OPT_DIR, f"nut_9slice_{state}.png")
        btn_9.save(b9_path)
        print(f"  + Đã lưu: nut_{state}.png & nut_9slice_{state}.png")

def generate_summary():
    # Tạo bảng tổng hợp UI
    canvas = Image.new("RGBA", (640, 280), (30, 26, 35, 255))
    
    # 1. Vẽ khung bảng to 9-slice test
    p48 = Image.open(os.path.join(OPT_DIR, "khung_bang_48x48.png"))
    # Thử scale khung 9-slice lên 220x160 để minh họa
    test_panel = Image.new("RGBA", (220, 160))
    # 9 slice slices
    m = 8
    w, h = 220, 160
    # Góc
    test_panel.paste(p48.crop((0, 0, m, m)), (0, 0))
    test_panel.paste(p48.crop((48-m, 0, 48, m)), (w-m, 0))
    test_panel.paste(p48.crop((0, 48-m, m, 48)), (0, h-m))
    test_panel.paste(p48.crop((48-m, 48-m, 48, 48)), (w-m, h-m))
    # Cạnh
    test_panel.paste(p48.crop((m, 0, 48-m, m)).resize((w-2*m, m), Image.NEAREST), (m, 0))
    test_panel.paste(p48.crop((m, 48-m, 48-m, 48)).resize((w-2*m, m), Image.NEAREST), (m, h-m))
    test_panel.paste(p48.crop((0, m, m, 48-m)).resize((m, h-2*m), Image.NEAREST), (0, m))
    test_panel.paste(p48.crop((48-m, m, 48, 48-m)).resize((m, h-2*m), Image.NEAREST), (w-m, m))
    # Ruột
    test_panel.paste(p48.crop((m, m, 48-m, 48-m)).resize((w-2*m, h-2*m), Image.NEAREST), (m, m))
    
    canvas.paste(test_panel, (20, 20), test_panel)
    
    # 2. Đặt các nút vào trong panel
    for idx, state in enumerate(["normal", "hover", "pressed", "disabled"]):
        btn = Image.open(os.path.join(OPT_DIR, f"nut_{state}.png"))
        canvas.paste(btn, (40, 35 + idx * 30), btn)
        
    # 3. Đặt khung tooltip test bên phải
    t32 = Image.open(os.path.join(OPT_DIR, "khung_tooltip_32x32.png"))
    # Phóng x2 demo
    canvas.paste(p48.resize((96, 96), Image.NEAREST), (260, 20))
    canvas.paste(t32.resize((64, 64), Image.NEAREST), (260, 130))
    
    # 4. Đặt các icon (phóng x2)
    icons = [
        os.path.join(OPT_DIR, "ke_vuon_khong_nha_trong.png"),
        os.path.join(OPT_DIR, "ke_sat_that.png"),
        os.path.join(OPT_DIR, "icon_long_dan.png"),
        os.path.join(OPT_DIR, "icon_mau.png"),
    ]
    
    for idx, ic_p in enumerate(icons):
        if os.path.exists(ic_p):
            ic = Image.open(ic_p).convert("RGBA")
            ic_x2 = ic.resize((ic.width * 2, ic.height * 2), Image.NEAREST)
            canvas.paste(ic_x2, (380 + (idx % 2) * 80, 40 + (idx // 2) * 80), ic_x2)
            
    out_p = os.path.join(OPT_DIR, "_tong_hop_giao_dien_d1_d4.png")
    canvas.save(out_p)
    print(f"\nĐã lưu ảnh tổng hợp giao diện: {out_p}")

if __name__ == "__main__":
    build_all_ui()
    generate_summary()
