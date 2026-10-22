#!/usr/bin/env python3
"""
Hoàn thiện toàn bộ hoạt ảnh Tấn công (Attack) cho 4 nhân vật:
1. Nguyễn Khoái: Vung Mạch đao 1 tay chém sấm sét đẩy lùi
2. Phạm Ngũ Lão: Lùi người phóng lao tầm xa
3. Trần Khánh Dư: Phóng câu liêm móc kéo quân địch
4. Bộ Binh Nguyên: Chém đao từ sau khiên
"""

import os, sys, time, json, urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

OUT_ATTACK_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh", "tan_cong")
os.makedirs(OUT_ATTACK_DIR, exist_ok=True)

# Load Resurrect 64
palette_rgb = []
with open(PALETTE_FILE) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith(("#", "GIMP", "Name", "Columns")):
            continue
        p = line.split()
        if len(p) >= 3:
            palette_rgb.append((int(p[0]), int(p[1]), int(p[2])))

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

def quantize_frame(im):
    im_rgba = im.convert("RGBA")
    arr = np.array(im_rgba)
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    opaque_mask = alpha >= 120
    out_alpha = np.where(opaque_mask, 255, 0).astype(np.uint8)
    rgb = arr[..., :3].astype(np.float32)
    pixels_to_q = rgb[opaque_mask]
    
    if len(pixels_to_q) > 0:
        lab_pixels = rgb_to_cielab(pixels_to_q)
        diff = lab_pixels[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_indices = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_indices].astype(np.uint8)
        
        lum = 0.299 * pixels_to_q[:, 0] + 0.587 * pixels_to_q[:, 1] + 0.114 * pixels_to_q[:, 2]
        dark_mask = (lum < 28) | ((pixels_to_q[:, 0] < 46) & (pixels_to_q[:, 1] < 46) & (pixels_to_q[:, 2] < 52))
        q_rgb[dark_mask] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque_mask] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        
    out_arr = np.dstack([out_rgb, out_alpha])
    return Image.fromarray(out_arr, mode="RGBA")

def wait_for_jobs(jobs_dict):
    print(f"Đang theo dõi {len(jobs_dict)} attack jobs...")
    pending = dict(jobs_dict)
    for attempt in range(50):
        done_keys = []
        for k, jid in pending.items():
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                print(f"  + Job {k} ({jid}) ĐÃ HOÀN THÀNH!")
                done_keys.append(k)
            elif "failed" in status_line:
                raise RuntimeError(f"Job {k} thất bại: {res}")
        for dk in done_keys:
            del pending[dk]
        if not pending:
            print("Toàn bộ 8 attack jobs đã hoàn tất 100%!")
            return
        print(f"  [{attempt+1}/50] Còn {len(pending)} attack jobs đang xử lý ({list(pending.keys())})...")
        time.sleep(8)
    raise TimeoutError(f"Hết thời gian chờ: {list(pending.keys())}")

def process_attack(char_key, base_folder, jobs, display_name):
    print(f"\n--- XỬ LÝ HOẠT ẢNH TẤN CÔNG: {display_name.upper()} ---")
    char_atk_dir = os.path.join(OUT_ATTACK_DIR, char_key)
    os.makedirs(char_atk_dir, exist_ok=True)
    
    frames_by_dir = {}
    
    for d in ["south", "east"]:
        jid = jobs[d]
        # Tải frame 0 tính offset
        url_0 = f"https://api.pixellab.ai/mcp/images/{jid}/download?index=0"
        req_0 = urllib.request.Request(url_0, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req_0) as resp:
            im_0 = Image.open(resp).convert("RGBA")
        arr_0 = np.array(im_0)
        y0, x0 = np.where(arr_0[..., 3] > 0)
        min_x0, min_y0 = x0.min(), y0.min()
        
        base_p = os.path.join(BASE_DIR, "toi_uu", base_folder, f"{d}.png")
        base_im = Image.open(base_p)
        arr_b = np.array(base_im)
        yb, xb = np.where(arr_b[..., 3] > 0)
        min_xb, min_yb = xb.min(), yb.min()
        
        dx = min_x0 - min_xb
        dy = min_y0 - min_yb
        
        frames_by_dir[d] = []
        for idx in range(1, 5):
            url_i = f"https://api.pixellab.ai/mcp/images/{jid}/download?index={idx}"
            req_i = urllib.request.Request(url_i, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req_i) as resp:
                raw_im = Image.open(resp).convert("RGBA")
                cropped = raw_im.crop((dx, dy, dx + 64, dy + 64))
                q_im = quantize_frame(cropped)
                frames_by_dir[d].append(q_im)
                
    # Lật ngang east để tạo west
    frames_by_dir["west"] = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in frames_by_dir["east"]]
    
    # Lưu frame
    for d, flist in frames_by_dir.items():
        for i, fim in enumerate(flist):
            fim.save(os.path.join(char_atk_dir, f"{d}_{i}.png"))
            
    # Tạo gif preview đòn đánh (South và East)
    # Hàng trên South, hàng dưới East: 128x64 px
    gif_frames = []
    for i in range(4):
        g_im = Image.new("RGBA", (192, 64), (34, 32, 52, 255))
        # 3 hướng: South, West, East
        g_im.paste(frames_by_dir["south"][i], (0, 0), frames_by_dir["south"][i])
        g_im.paste(frames_by_dir["west"][i], (64, 0), frames_by_dir["west"][i])
        g_im.paste(frames_by_dir["east"][i], (128, 0), frames_by_dir["east"][i])
        gif_frames.append(g_im.convert("RGB"))
        
    gif_p = os.path.join(char_atk_dir, "attack_preview.gif")
    gif_frames[0].save(gif_p, save_all=True, append_images=gif_frames[1:], duration=150, loop=0)
    print(f"  Đã lưu frames và GIF đòn đánh: {char_atk_dir}")

def build_attack_overview():
    print("\nĐang tạo Bảng tổng hợp Hoạt ảnh Tấn công...")
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    
    chars = [
        ("khoai", "Nguyễn Khoái", "Chém đại đao 1 tay đẩy lùi"),
        ("lao", "Phạm Ngũ Lão", "Phóng lao thẳng hàng"),
        ("du", "Trần Khánh Dư", "Móc câu liêm kéo địch"),
        ("bo_binh", "Bộ Binh Nguyên", "Chém đao thủ khiên")
    ]
    
    # Mỗi nhân vật hiển thị 4 frames đòn đánh hướng South và 4 frames hướng East
    # Tổng: 8 frames x 64px = 512px + labels = ~600px width
    cell = 64
    pad = 12
    head_h = 56
    row_h = cell + 30
    
    total_w = pad * 2 + 8 * (cell + 4) + 20
    total_h = head_h + len(chars) * row_h + pad
    
    showcase = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(showcase)
    
    draw.text((pad, 14), "TỔNG HỢP HOẠT ẢNH TẤN CÔNG (ATTACK ANIMATIONS - 4 FRAMES)", fill=(255, 230, 150), font=font)
    draw.text((pad, 36), "Cột 1-4: Đòn đánh Hướng Nam (South) | Cột 5-8: Đòn đánh Hướng Đông (East) — Chuẩn Resurrect 64", fill=(180, 200, 220), font=font_sub)
    
    for r_idx, (ckey, cname, cdesc) in enumerate(chars):
        y_r = head_h + r_idx * row_h
        draw.text((pad, y_r + 2), f"{cname} — {cdesc}", fill=(255, 215, 120), font=font_sub)
        
        cur_x = pad
        # South
        for i in range(4):
            fp = os.path.join(OUT_ATTACK_DIR, ckey, f"south_{i}.png")
            if os.path.exists(fp):
                fim = Image.open(fp)
                showcase.paste(fim, (cur_x, y_r + 18), fim)
            cur_x += cell + 4
        cur_x += 16
        # East
        for i in range(4):
            fp = os.path.join(OUT_ATTACK_DIR, ckey, f"east_{i}.png")
            if os.path.exists(fp):
                fim = Image.open(fp)
                showcase.paste(fim, (cur_x, y_r + 18), fim)
            cur_x += cell + 4
            
    out_p = os.path.join(OUT_ATTACK_DIR, "_tong_hop_hoat_anh_tan_cong.png")
    showcase.save(out_p)
    print(f"Đã lưu Bảng tổng hợp đòn đánh: {out_p}")

def main():
    jobs = {
        "khoai_south": "98c19198-26cc-4102-8ce4-adf7a0122441",
        "khoai_east":  "02bc8832-6f42-46ab-892e-fc3fd51531da",
        "lao_south":   "8b95c34e-49fa-497f-ab29-d5f8bfbeee4d",
        "lao_east":    "13b0cbe9-94e1-476f-894b-7235e655d0cd",
        "du_south":    "89d5f314-d004-4ad4-8664-e1542f228059",
        "du_east":     "bafc41df-c73f-492f-8d8b-4cfd6eea84e4",
        "bb_south":    "8dec66f4-27cf-4239-a975-e30cbb89a9e9",
        "bb_east":     "83fa8b86-afb0-43be-a37f-200170eb8255"
    }
    
    wait_for_jobs(jobs)
    
    process_attack("khoai", "khoai", {"south": jobs["khoai_south"], "east": jobs["khoai_east"]}, "Nguyễn Khoái")
    process_attack("lao", "lao", {"south": jobs["lao_south"], "east": jobs["lao_east"]}, "Phạm Ngũ Lão")
    process_attack("du", "du", {"south": jobs["du_south"], "east": jobs["du_east"]}, "Trần Khánh Dư")
    process_attack("bo_binh", "nguyen_v3", {"south": jobs["bb_south"], "east": jobs["bb_east"]}, "Bộ Binh Nguyên")
    
    build_attack_overview()
    print("\nHOÀN TẤT TOÀN BỘ HOẠT ẢNH TẤN CÔNG!")

if __name__ == "__main__":
    main()
