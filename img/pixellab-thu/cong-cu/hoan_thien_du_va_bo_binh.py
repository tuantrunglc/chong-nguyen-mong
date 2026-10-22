#!/usr/bin/env python3
"""
Hoàn thiện toàn bộ hoạt ảnh bước đi 4 hướng cho Trần Khánh Dư và Bộ Binh Nguyên:
- Trần Khánh Dư: Câu liêm cầm chắc tay, nhún nảy tự nhiên
- Bộ Binh Nguyên v3: Tay trái cầm Khiên, tay phải cầm Đao, bước đi quân kỷ
- Cập nhật Spritesheet, GIF preview, ảnh tổng hợp riêng
- Cập nhật Đại bảng tổng hợp 4 quân cờ: _tong_hop_hoat_anh_di_chuyen.png
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

OUT_ANIM_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh")

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
    print(f"Đang theo dõi {len(jobs_dict)} jobs...")
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
            else:
                pass
        for dk in done_keys:
            del pending[dk]
        if not pending:
            print("Toàn bộ các job đã hoàn tất 100%!")
            return
        print(f"  [{attempt+1}/50] Còn {len(pending)} jobs đang xử lý ({list(pending.keys())})...")
        time.sleep(8)
    raise TimeoutError(f"Hết thời gian chờ: {list(pending.keys())}")

def process_character(char_key, base_folder, jobs, display_name):
    print(f"\n=======================================================")
    print(f"XỬ LÝ NHÂN VẬT: {display_name.upper()}")
    print(f"=======================================================")
    char_dir = os.path.join(OUT_ANIM_DIR, char_key)
    os.makedirs(char_dir, exist_ok=True)
    
    frames_by_dir = {}
    
    for d in ["south", "east", "north"]:
        jid = jobs[d]
        print(f"  Đang tải và căn chỉnh {d} (job: {jid})...")
        # Tải frame 0 để tính toán offset
        url_0 = f"https://api.pixellab.ai/mcp/images/{jid}/download?index=0"
        req_0 = urllib.request.Request(url_0, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req_0) as resp:
            im_0 = Image.open(resp).convert("RGBA")
        arr_0 = np.array(im_0)
        y0, x0 = np.where(arr_0[..., 3] > 0)
        min_x0, min_y0 = x0.min(), y0.min()
        
        # Đọc base sprite
        base_p = os.path.join(BASE_DIR, "toi_uu", base_folder, f"{d}.png")
        base_im = Image.open(base_p)
        arr_b = np.array(base_im)
        yb, xb = np.where(arr_b[..., 3] > 0)
        min_xb, min_yb = xb.min(), yb.min()
        
        dx = min_x0 - min_xb
        dy = min_y0 - min_yb
        print(f"    Offset {d}: dx={dx}, dy={dy}")
        
        frames_by_dir[d] = []
        for idx in range(1, 5):
            url_i = f"https://api.pixellab.ai/mcp/images/{jid}/download?index={idx}"
            req_i = urllib.request.Request(url_i, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req_i) as resp:
                raw_im = Image.open(resp).convert("RGBA")
                cropped = raw_im.crop((dx, dy, dx + 64, dy + 64))
                q_im = quantize_frame(cropped)
                frames_by_dir[d].append(q_im)
                
    # Tạo west từ lật ngang east
    frames_by_dir["west"] = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in frames_by_dir["east"]]
    
    # Lưu từng frame
    for d, flist in frames_by_dir.items():
        for i, fim in enumerate(flist):
            fim.save(os.path.join(char_dir, f"{d}_{i}.png"))
    print(f"  Đã lưu 16 frame PNG riêng lẻ vào: {char_dir}")
    
    # Spritesheet 4x4
    dir_order = ["south", "west", "east", "north"]
    sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for row_idx, d in enumerate(dir_order):
        for col_idx, f_im in enumerate(frames_by_dir[d]):
            sheet.paste(f_im, (col_idx * 64, row_idx * 64))
    sheet_p = os.path.join(char_dir, "spritesheet_walk_256x256.png")
    sheet.save(sheet_p)
    print(f"  Đã lưu Spritesheet: {sheet_p}")
    
    # GIF preview
    gif_frames = []
    for i in range(4):
        g_im = Image.new("RGBA", (256, 64), (34, 32, 52, 255))
        for col_idx, d in enumerate(dir_order):
            g_im.paste(frames_by_dir[d][i], (col_idx * 64, 0), frames_by_dir[d][i])
        gif_frames.append(g_im.convert("RGB"))
    gif_p = os.path.join(char_dir, "walk_preview.gif")
    gif_frames[0].save(gif_p, save_all=True, append_images=gif_frames[1:], duration=160, loop=0)
    print(f"  Đã lưu GIF preview: {gif_p}")
    
    # Showcase sheet riêng cho nhân vật
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    scale = 2
    w_f, h_f = 64 * scale, 64 * scale
    pad = 12
    head_h = 44
    total_w = pad * 5 + w_f * 4
    total_h = head_h + (h_f + 24 + pad) * 4 + pad
    
    showcase = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(showcase)
    draw.text((pad, 12), f"HOẠT ẢNH BƯỚC ĐI ĐẦY ĐỦ 4 HƯỚNG: {display_name.upper()}", fill=(255, 230, 150), font=font)
    
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
            
    showcase_path = os.path.join(char_dir, f"_tong_hop_hoat_anh_{char_key}_4_huong.png")
    showcase.save(showcase_path)
    print(f"  Đã lưu ảnh showcase riêng: {showcase_path}")

def build_grand_overview():
    print("\nĐang tạo Đại bảng tổng hợp toàn bộ 4 quân cờ...")
    font = ImageFont.truetype(FONT_FILE, 14) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    
    chars = [
        ("khoai", "Nguyễn Khoái", "Mạch đao 1 tay"),
        ("lao", "Phạm Ngũ Lão", "Cầm ngọn giáo"),
        ("du", "Trần Khánh Dư", "Cầm câu liêm"),
        ("bo_binh", "Bộ Binh Nguyên", "Khiên & Đao")
    ]
    
    # 4 nhân vật, mỗi nhân vật hiện 4 hướng x 4 frames
    # Cấu trúc: 4 cột lớn (mỗi cột 1 nhân vật), mỗi cột rộng 4 frames x 40px = 160px
    # Hoặc 4 dòng lớn (mỗi dòng 1 nhân vật, hiển thị 4 hướng x 4 frames)
    # Kích thước: 16 frames x 48px = 768px chiều ngang, 4 nhân vật x 60px = 240px chiều cao
    # Để hiển thị cực rõ: Mỗi nhân vật chiếm 1 hàng ngang với 4 hướng:
    # [South 4f] [West 4f] [East 4f] [North 4f] = 16 frames x 48px = 768px + pads = ~860px
    
    scale = 1 # 64px nguyên gốc
    pad = 12
    cell = 64
    header_h = 56
    row_h = cell + 30
    
    # 16 frames: 4 hướng x 4 frames
    total_w = pad * 2 + 16 * (cell + 4) + 3 * 16 # separator between directions
    total_h = header_h + len(chars) * row_h + pad
    
    grand = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(grand)
    
    draw.text((pad, 14), "ĐẠI TỔNG HỢP HOẠT ẢNH DI CHUYỂN 4 HƯỚNG CỦA 4 QUÂN CỜ (CHUẨN 100% RESURRECT 64)", fill=(255, 230, 150), font=font)
    draw.text((pad, 36), "16 Khung hình mỗi quân cờ: 4 Nam (South) | 4 Tây (West) | 4 Đông (East) | 4 Bắc (North) — Vũ khí cầm tay & Bobbing tự nhiên", fill=(180, 200, 220), font=font_sub)
    
    dir_order = ["south", "west", "east", "north"]
    
    for r_idx, (ckey, cname, cdesc) in enumerate(chars):
        y_r = header_h + r_idx * row_h
        draw.text((pad, y_r + 2), f"{cname} ({cdesc})", fill=(255, 215, 120), font=font_sub)
        
        cur_x = pad
        for d in dir_order:
            for i in range(4):
                f_p = os.path.join(OUT_ANIM_DIR, ckey, f"{d}_{i}.png")
                if os.path.exists(f_p):
                    f_im = Image.open(f_p)
                    grand.paste(f_im, (cur_x, y_r + 18), f_im)
                cur_x += cell + 4
            cur_x += 16 # khoảng cách giữa các hướng
            
    out_grand = os.path.join(OUT_ANIM_DIR, "_tong_hop_hoat_anh_di_chuyen.png")
    grand.save(out_grand)
    print(f"Đã lưu Đại bảng tổng hợp: {out_grand}")

def main():
    jobs = {
        "du_south": "b55aac21-36eb-4600-811f-c321bae7ce6d",
        "du_east":  "0db46bd7-9259-41ba-bb85-d6a04c6fc12c",
        "du_north": "057350b0-5bc2-4c60-8192-d61e2dbbe547",
        "bb_south": "fcbe283f-7947-4968-82cd-060c542a5661",
        "bb_east":  "d2a60753-1f75-4a95-b745-9011f24d818a",
        "bb_north": "71675ad2-bcb8-4936-97eb-a2513f394161"
    }
    
    wait_for_jobs(jobs)
    
    du_jobs = {"south": jobs["du_south"], "east": jobs["du_east"], "north": jobs["du_north"]}
    bb_jobs = {"south": jobs["bb_south"], "east": jobs["bb_east"], "north": jobs["bb_north"]}
    
    process_character("du", "du", du_jobs, "Trần Khánh Dư (Câu liêm)")
    process_character("bo_binh", "nguyen_v3", bb_jobs, "Bộ Binh Nguyên (Khiên & Đao)")
    
    build_grand_overview()
    print("\nHOÀN TẤT 100% CẢ 4 QUÂN CỜ!")

if __name__ == "__main__":
    main()
