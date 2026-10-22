#!/usr/bin/env python3
"""
Hoàn thiện toàn bộ Hoạt ảnh di chuyển (Walk Animations) cho các nhân vật:
- Tải các frame ảnh (4 frames / hướng: south, east, north)
- Tạo hướng west bằng cách lật ngang east
- Lượng tử hóa 100% Resurrect 64 & 1-bit alpha
- Ghép Spritesheet 4x4 (64x64 mỗi cell, tổng 256x256)
- Tạo ảnh GIF động xem trước
"""

import os, sys, time, re, urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

OUT_ANIM_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh")
os.makedirs(OUT_ANIM_DIR, exist_ok=True)

# 1. Load Resurrect 64
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

def fetch_and_build(char_key, char_id, char_title):
    print(f"\n=======================================================")
    print(f"XỬ LÝ HOẠT ẢNH: {char_title.upper()}")
    print(f"=======================================================")
    
    # 1. Chờ hoàn thành
    for attempt in range(40):
        info = call("get_character", {"character_id": char_id})
        # Check if walking-4-frames has at least 3 directions
        if "animations (" in info:
            m = re.search(r"walking-4-frames — (\d+) dir", info)
            if m and int(m.group(1)) >= 3:
                print(f"  + Đã xong đủ {m.group(1)} hướng!")
                break
        print(f"  [{attempt+1}/40] Đang chờ generation hoàn tất...")
        time.sleep(8)
        
    # Phân tích URL của các hướng
    # Tìm đoạn sau "walking-4-frames"
    anim_part = info.split("walking-4-frames")[1].split("download:")[0]
    dir_urls = {}
    for d in ["south", "east", "north"]:
        m = re.search(rf"\b{d}:\s*(https://\S+)", anim_part)
        if m:
            dir_urls[d] = m.group(1)
            
    print(f"  Tìm thấy link các hướng: {list(dir_urls.keys())}")
    
    char_dir = os.path.join(OUT_ANIM_DIR, char_key)
    os.makedirs(char_dir, exist_ok=True)
    
    frames_by_dir = {}
    
    # Tải và lượng tử hóa
    for d, url_pattern in dir_urls.items():
        frames_by_dir[d] = []
        for i in range(4):
            # Thay {i} bằng số frame
            frame_url = url_pattern.replace("{i}", str(i))
            req = urllib.request.Request(frame_url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
            try:
                with urllib.request.urlopen(req) as response:
                    raw_im = Image.open(response).convert("RGBA")
                    # Tối ưu Resurrect 64
                    opt_im = quantize_frame(raw_im)
                    # Lưu frame riêng
                    f_name = f"{d}_{i}.png"
                    opt_im.save(os.path.join(char_dir, f_name))
                    frames_by_dir[d].append(opt_im)
            except Exception as e:
                print(f"  Lỗi tải frame {d}_{i}: {e}")
                
    # Tạo hướng west từ lật ngang east
    if "east" in frames_by_dir and len(frames_by_dir["east"]) == 4:
        frames_by_dir["west"] = []
        for i, e_im in enumerate(frames_by_dir["east"]):
            w_im = e_im.transpose(Image.FLIP_LEFT_RIGHT)
            w_im.save(os.path.join(char_dir, f"west_{i}.png"))
            frames_by_dir["west"].append(w_im)
        print("  + Đã tạo tự động hướng west từ lật ngang east!")

    # Tạo Spritesheet 4x4 (256x256 px):
    # Dòng 0: South (i=0..3)
    # Dòng 1: West  (i=0..3)
    # Dòng 2: East  (i=0..3)
    # Dòng 3: North (i=0..3)
    dir_order = ["south", "west", "east", "north"]
    sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for row_idx, d in enumerate(dir_order):
        if d in frames_by_dir:
            for col_idx, f_im in enumerate(frames_by_dir[d]):
                sheet.paste(f_im, (col_idx * 64, row_idx * 64))
                
    sheet_path = os.path.join(char_dir, f"spritesheet_walk_256x256.png")
    sheet.save(sheet_path)
    print(f"  + Đã lưu Spritesheet: {sheet_path}")
    
    # Tạo ảnh GIF động 4 hướng đặt cạnh nhau
    # Kích thước GIF: 256x64 (4 hướng x 64px)
    gif_frames = []
    for i in range(4):
        g_im = Image.new("RGBA", (256, 64), (34, 32, 52, 255))
        for col_idx, d in enumerate(dir_order):
            if d in frames_by_dir and len(frames_by_dir[d]) > i:
                g_im.paste(frames_by_dir[d][i], (col_idx * 64, 0), frames_by_dir[d][i])
        # Convert to P mode for GIF with exact palette
        gif_frames.append(g_im.convert("RGB"))
        
    gif_path = os.path.join(char_dir, f"walk_preview.gif")
    gif_frames[0].save(gif_path, save_all=True, append_images=gif_frames[1:], duration=160, loop=0)
    print(f"  + Đã lưu GIF xem trước: {gif_path}")
    
    return sheet_path

def main():
    characters = [
        ("khoai", "17c58452-574e-449b-ac07-313596d9d02e", "Nguyễn Khoái (Mạch đao)"),
        ("lao", "1835f646-6eb5-47f1-8d91-73136596cd86", "Phạm Ngũ Lão (Giáo)"),
        ("du", "ae2a3750-9712-4d58-b2ce-0910e9180fb9", "Trần Khánh Dư (Câu liêm)"),
        ("bo_binh", "1d7e8b91-2b67-4c5f-aa61-beee8d934860", "Bộ Binh Nguyên v3 (Khiên & Đao)")
    ]
    
    for key, cid, title in characters:
        fetch_and_build(key, cid, title)
        
    print("\nHOÀN TẤT TOÀN BỘ HOẠT ẢNH DI CHUYỂN!")

if __name__ == "__main__":
    main()
