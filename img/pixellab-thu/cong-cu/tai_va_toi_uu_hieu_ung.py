#!/usr/bin/env python3
"""
Tải và tối ưu hóa bộ 5 hiệu ứng chiến đấu C1–C5:
- C1: Cây lao bay (Phạm Ngũ Lão)
- C2: Mũi tên bay (Cung kỵ Nguyên)
- C3: Bụi/sao va chạm (đẩy/kéo)
- C4: Nước bắn tóe (rơi sông)
- C5: Chông đâm (hầm chông)
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
RAW_DIR = os.path.join(BASE_DIR, "hieu_ung")
OPT_DIR = os.path.join(BASE_DIR, "toi_uu", "hieu_ung")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

os.makedirs(RAW_DIR, exist_ok=True)
os.makedirs(OPT_DIR, exist_ok=True)

JOBS = {
    "c1_lao_bay": "ff7976a4-96e3-45a3-b869-3d7a39926536",
    "c2_ten_bay": "a9775ce3-3a27-4d71-a5bf-c87cfea4cb04",
    "c3_va_cham": "0ca046aa-45e3-4081-ac28-d4fc3e044891",
    "c4_nuoc_ban": "37898e0b-4c76-46a9-beb4-a2b34b647d1e",
    "c5_chong_dam": "522b1f6a-a032-4fa4-9e7b-7c6e71915194"
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
BROWN_LEATHER = (76, 62, 36, 255) # #4c3e24

def quantize_pixel(r, g, b, a, no_red=False):
    if a < 100:
        return (0, 0, 0, 0)
    
    if no_red:
        if r > 115 and r > g * 1.35 and r > b * 1.35:
            r, g, b = BROWN_LEATHER[:3]
            
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    if lum < 32 or (r < 46 and g < 46 and b < 52):
        return OUTLINE_COLOR
        
    lab = rgb_to_cielab(np.array([r, g, b], dtype=np.float32))
    dists = np.sum((lab_palette - lab) ** 2, axis=-1)
    best_idx = np.argmin(dists)
    best_rgb = palette_rgb[best_idx]
    
    if no_red:
        RED_HEXES = [(232, 59, 59), (234, 79, 54), (174, 35, 52), (110, 39, 39), (179, 56, 49)]
        if (best_rgb[0], best_rgb[1], best_rgb[2]) in RED_HEXES:
            best_rgb = BROWN_LEATHER[:3]
            
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

def wait_and_download_all():
    print("Theo dõi và tải các hiệu ứng:")
    completed_jobs = {}
    
    for name, jid in JOBS.items():
        print(f"Đang đợi {name} ({jid})...")
        for i in range(20):
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                # Find download URL
                m = re.search(r"download:\s*(https://\S+)", res)
                if m:
                    url = m.group(1)
                    raw_path = os.path.join(RAW_DIR, f"{name}.png")
                    download_file(url, raw_path)
                    print(f"  + Đã tải {name} về {raw_path}")
                    completed_jobs[name] = raw_path
                    break
            time.sleep(5)
        else:
            print(f"  - Quá hạn chờ cho {name}")
            
    return completed_jobs

def optimize_all():
    print("\nTối ưu hóa Resurrect 64 cho các hiệu ứng:")
    for name in JOBS.keys():
        raw_path = os.path.join(RAW_DIR, f"{name}.png")
        if not os.path.exists(raw_path):
            continue
            
        im = Image.open(raw_path).convert("RGBA")
        w, h = im.size
        opt = Image.new("RGBA", (w, h))
        
        # Chỉ C1 (Lao Đại Việt) được dùng đỏ Đại Việt; C2 (Nguyên), C3 (va chạm), C4 (nước), C5 (bẫy chông) khử đỏ để nhường cho Telegraph
        no_red = (name != "c1_lao_bay")
        opt_data = [quantize_pixel(r, g, b, a, no_red=no_red) for (r, g, b, a) in im.getdata()]
        opt.putdata(opt_data)
        opt = clean_orphan_pixels(opt)
        
        opt_path = os.path.join(OPT_DIR, f"{name}.png")
        opt.save(opt_path)
        print(f"  + Đã lưu tối ưu: {opt_path} ({w}x{h})")

def generate_summary():
    # Ghép 5 hiệu ứng thành 1 ảnh hàng ngang phóng đại x4
    scale = 4
    pad = 16
    box_size = 64 * scale
    
    effects = [
        ("C1: Lao bay", os.path.join(OPT_DIR, "c1_lao_bay.png")),
        ("C2: Mũi tên", os.path.join(OPT_DIR, "c2_ten_bay.png")),
        ("C3: Va chạm", os.path.join(OPT_DIR, "c3_va_cham.png")),
        ("C4: Nước bắn", os.path.join(OPT_DIR, "c4_nuoc_ban.png")),
        ("C5: Chông đâm", os.path.join(OPT_DIR, "c5_chong_dam.png")),
    ]
    
    canvas_w = pad + len(effects) * (box_size + pad)
    canvas_h = pad + box_size + pad
    canvas = Image.new("RGBA", (canvas_w, canvas_h), (30, 26, 35, 255))
    
    for i, (label, path) in enumerate(effects):
        if os.path.exists(path):
            im = Image.open(path).convert("RGBA")
            # Canh giữa trong ô 64x64 rồi phóng to x4
            cell = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
            offset_x = (64 - im.width) // 2
            offset_y = (64 - im.height) // 2
            cell.paste(im, (offset_x, offset_y), im)
            cell_scaled = cell.resize((box_size, box_size), Image.NEAREST)
            canvas.paste(cell_scaled, (pad + i * (box_size + pad), pad), cell_scaled)
            
    out_p = os.path.join(OPT_DIR, "_tong_hop_hieu_ung_c1_c5.png")
    canvas.save(out_p)
    print(f"\nĐã lưu ảnh tổng hợp 5 hiệu ứng tại: {out_p}")

if __name__ == "__main__":
    wait_and_download_all()
    optimize_all()
    generate_summary()
