#!/usr/bin/env python3
"""
Hoàn thiện toàn bộ 4 hướng hoạt ảnh bước đi cho Phạm Ngũ Lão:
- East job: 4ff487b5-faf5-4f83-a9c4-b6bced14881b
- North job: 1cb83df3-643e-49e3-a4ec-a4e58078297b
- South: Đã có sẵn từ lần chạy trước trong thu_nghiem_lao_v3
- West: Lật ngang từ East
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

OUT_LAO_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh", "lao")
os.makedirs(OUT_LAO_DIR, exist_ok=True)

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

def wait_for_job(job_id, name):
    print(f"Đang chờ hoàn thành job {name} ({job_id})...")
    for attempt in range(40):
        res = call("get_image", {"job_id": job_id})
        status_line = res.split("\n")[0]
        if "completed" in status_line:
            print(f"  + Job {name} đã hoàn thành!")
            return res
        if "failed" in status_line:
            raise RuntimeError(f"Job {name} thất bại: {res}")
        print(f"  [{attempt+1}/40] {status_line}")
        time.sleep(8)
    raise TimeoutError(f"Hết thời gian chờ job {name}")

def download_and_crop_frames(job_id, name):
    print(f"Tải các frame của {name}...")
    frames = []
    for idx in range(1, 5): # 4 animation frames (bỏ reference frame index 0)
        url = f"https://api.pixellab.ai/mcp/images/{job_id}/download?index={idx}"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as resp:
            raw_im = Image.open(resp).convert("RGBA")
            # Cắt từ 88x88 về 64x64
            cropped = raw_im.crop((12, 12, 12+64, 12+64))
            q_im = quantize_frame(cropped)
            frames.append(q_im)
    return frames

def main():
    job_east = "4ff487b5-faf5-4f83-a9c4-b6bced14881b"
    job_north = "1cb83df3-643e-49e3-a4ec-a4e58078297b"
    
    wait_for_job(job_east, "East")
    wait_for_job(job_north, "North")
    
    frames_east = download_and_crop_frames(job_east, "East")
    frames_north = download_and_crop_frames(job_north, "North")
    
    # Lấy frames South đã có
    dir_south = os.path.join(BASE_DIR, "toi_uu", "hoat_anh", "thu_nghiem_lao_v3")
    frames_south = [Image.open(os.path.join(dir_south, f"lao_v3_south_{i}.png")) for i in range(4)]
    
    # Tạo frames West từ lật ngang East
    frames_west = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in frames_east]
    
    frames_by_dir = {
        "south": frames_south,
        "west": frames_west,
        "east": frames_east,
        "north": frames_north
    }
    
    # Lưu từng frame riêng lẻ vào thư mục chính thức lao/
    for d, flist in frames_by_dir.items():
        for i, fim in enumerate(flist):
            out_p = os.path.join(OUT_LAO_DIR, f"{d}_{i}.png")
            fim.save(out_p)
    print(f"Đã lưu toàn bộ 16 frame PNG riêng lẻ vào: {OUT_LAO_DIR}")
    
    # Ghép Spritesheet 4x4 (256x256 px)
    dir_order = ["south", "west", "east", "north"]
    sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for row_idx, d in enumerate(dir_order):
        for col_idx, f_im in enumerate(frames_by_dir[d]):
            sheet.paste(f_im, (col_idx * 64, row_idx * 64))
    sheet_path = os.path.join(OUT_LAO_DIR, "spritesheet_walk_256x256.png")
    sheet.save(sheet_path)
    print(f"Đã lưu Spritesheet hoàn chỉnh: {sheet_path}")
    
    # Tạo GIF xem trước 4 hướng đồng bộ (256x64 px)
    gif_frames = []
    for i in range(4):
        g_im = Image.new("RGBA", (256, 64), (34, 32, 52, 255))
        for col_idx, d in enumerate(dir_order):
            g_im.paste(frames_by_dir[d][i], (col_idx * 64, 0), frames_by_dir[d][i])
        gif_frames.append(g_im.convert("RGB"))
    gif_path = os.path.join(OUT_LAO_DIR, "walk_preview.gif")
    gif_frames[0].save(gif_path, save_all=True, append_images=gif_frames[1:], duration=160, loop=0)
    print(f"Đã lưu GIF xem trước 4 hướng: {gif_path}")
    
    # Tạo ảnh tổng hợp showcase 4 hướng x 4 frames scale x3
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    scale = 2
    w_f, h_f = 64 * scale, 64 * scale
    pad = 12
    head_h = 44
    total_w = pad * 5 + w_f * 4
    total_h = head_h + (h_f + 24 + pad) * 4 + pad
    
    showcase = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(showcase)
    draw.text((pad, 12), "HOẠT ẢNH BƯỚC ĐI ĐẦY ĐỦ 4 HƯỚNG: PHẠM NGŨ LÃO (TAY CẦM GIÁO)", fill=(255, 230, 150), font=font)
    
    dir_names = {
        "south": "HƯỚNG NAM (CHÍNH DIỆN - SOUTH)",
        "west": "HƯỚNG TÂY (SANG TRÁI - WEST)",
        "east": "HƯỚNG ĐÔNG (SANG PHẢI - EAST)",
        "north": "HƯỚNG BẮC (SAU LƯNG - NORTH)"
    }
    
    for r_idx, d in enumerate(dir_order):
        y_r = head_h + r_idx * (h_f + 24 + pad)
        draw.text((pad, y_r), dir_names[d], fill=(180, 220, 255), font=font)
        for c_idx, f_im in enumerate(frames_by_dir[d]):
            x = pad + c_idx * (w_f + pad)
            f_big = f_im.resize((w_f, h_f), Image.NEAREST)
            showcase.paste(f_big, (x, y_r + 20), f_big)
            
    showcase_path = os.path.join(OUT_LAO_DIR, "_tong_hop_hoat_anh_lao_4_huong.png")
    showcase.save(showcase_path)
    print(f"Đã lưu ảnh tổng hợp: {showcase_path}")

if __name__ == "__main__":
    main()
