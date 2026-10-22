#!/usr/bin/env python3
"""
Hoàn thiện hoạt ảnh Chết đuối (Drown) cho Bộ Binh Nguyên rơi xuống sông:
Job: 6a56e10b-2e23-48f1-a8cf-50daea54977e
"""

import os, sys, time, json, urllib.request
import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

OUT_DROWN_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh", "chet_duoi")
os.makedirs(OUT_DROWN_DIR, exist_ok=True)

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

def main():
    jid = "6a56e10b-2e23-48f1-a8cf-50daea54977e"
    print("Đang chờ job chết đuối...")
    for attempt in range(50):
        res = call("get_image", {"job_id": jid})
        status_line = res.split("\n")[0]
        if "completed" in status_line:
            print("  + Job chết đuối ĐÃ HOÀN THÀNH!")
            break
        if "failed" in status_line:
            raise RuntimeError(f"Job chết đuối thất bại: {res}")
        print(f"  [{attempt+1}/50] {status_line}")
        time.sleep(8)
        
    # Tải frame 0 tính offset
    url_0 = f"https://api.pixellab.ai/mcp/images/{jid}/download?index=0"
    req_0 = urllib.request.Request(url_0, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req_0) as resp:
        im_0 = Image.open(resp).convert("RGBA")
    arr_0 = np.array(im_0)
    y0, x0 = np.where(arr_0[..., 3] > 0)
    min_x0, min_y0 = x0.min(), y0.min()
    
    base_p = os.path.join(BASE_DIR, "toi_uu", "nguyen_v3", "south.png")
    base_im = Image.open(base_p)
    arr_b = np.array(base_im)
    yb, xb = np.where(arr_b[..., 3] > 0)
    min_xb, min_yb = xb.min(), yb.min()
    
    dx = min_x0 - min_xb
    dy = min_y0 - min_yb
    
    frames = []
    for idx in range(1, 5):
        url_i = f"https://api.pixellab.ai/mcp/images/{jid}/download?index={idx}"
        req_i = urllib.request.Request(url_i, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req_i) as resp:
            raw_im = Image.open(resp).convert("RGBA")
            cropped = raw_im.crop((dx, dy, dx + 64, dy + 64))
            q_im = quantize_frame(cropped)
            q_im.save(os.path.join(OUT_DROWN_DIR, f"drown_{idx-1}.png"))
            frames.append(q_im)
            
    gif_p = os.path.join(OUT_DROWN_DIR, "drown_preview.gif")
    frames[0].save(gif_p, save_all=True, append_images=frames[1:], duration=220, loop=0)
    print(f"Đã lưu hoạt ảnh chết đuối: {OUT_DROWN_DIR}")

if __name__ == "__main__":
    main()
