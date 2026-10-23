#!/usr/bin/env python3
"""
Tạo bộ HOẠT ẢNH THẬT SỰ bằng AI Animation Model của PixelLab (animate_image) cho Kỵ Binh và Cung Kỵ:
- Hỗ trợ rate limit queue (tối đa 7 jobs đồng thời)
- Tự động nạp job_id đã gửi và tiếp tục
- Lượng tử hóa 100% Resurrect 64, 1-bit alpha, viền 1px #2e222f, không có màu đỏ
- Xuất Spritesheet 256x256 và các file GIF preview
"""

import os, sys, time, re, json, urllib.request, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
JOBS_CACHE_FILE = os.path.join(BASE_DIR, "cong-cu", "cavalry_jobs.json")

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
BROWN_LEATHER = (76, 62, 36, 255)

def quantize_frame(im):
    arr = np.array(im.convert("RGBA"))
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    opaque = alpha >= 120
    out_alpha = np.where(opaque, 255, 0).astype(np.uint8)
    
    rgb = arr[..., :3].astype(np.float32)
    px = rgb[opaque]
    if len(px) > 0:
        lab_px = rgb_to_cielab(px)
        diff = lab_px[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_idx = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_idx].astype(np.uint8)
        
        # Khử màu đỏ cho quân Nguyên
        r = q_rgb[:, 0].astype(int)
        g = q_rgb[:, 1].astype(int)
        b = q_rgb[:, 2].astype(int)
        red_mask = (r > 130) & (r > g + 40) & (r > b + 40)
        q_rgb[red_mask] = np.array(BROWN_LEATHER[:3], dtype=np.uint8)
        
        # Viền tối
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

def get_uploader():
    res = call("get_upload_url", {})
    for line in res.split("\n"):
        if line.startswith("https://api.pixellab.ai/v2/uploads/"):
            return line.strip()
    raise RuntimeError(f"Không lấy được upload url: {res}")

def upload_image(uploader_url, local_path):
    cmd = ["curl", "-sS", "-F", f"file=@{local_path}", uploader_url]
    out = subprocess.check_output(cmd).decode()
    d = json.loads(out)
    return d["ref"]

def submit_anim_job(img_ref, action):
    res = call("animate_image", {
        "first_frame_url": img_ref,
        "action": action,
        "frame_count": 4
    })
    m = re.search(r"job_id:\s*([a-f0-9\-]+)", res)
    if m:
        return m.group(1)
    m = re.search(r"^id:\s*([a-f0-9\-]+)", res, re.M)
    if m:
        return m.group(1)
    if "rate limit exceeded" in res:
        return None
    raise RuntimeError(f"Lỗi submit animation: {res}")

def download_frames(jid, count=4):
    frames = []
    # Index 1..count là các frame chuyển động được AI sinh ra
    for idx in range(1, count + 1):
        url = f"https://api.pixellab.ai/mcp/images/{jid}/download?index={idx}"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as resp:
            raw = Image.open(resp).convert("RGBA")
            if raw.size != (64, 64):
                raw = raw.crop((0, 0, 64, 64))
            frames.append(quantize_frame(raw))
    return frames

def main():
    print("=================================================================")
    print("KHỞI TẠO VÀ SINH TOÀN BỘ HOẠT ẢNH CHUẨN KỴ BINH VÀ CUNG KỴ BẰNG AI")
    print("=================================================================")
    
    # 1. Nạp cache hoặc upload
    uploader = get_uploader()
    base_paths = {
        "kb_south": os.path.join(BASE_DIR, "toi_uu", "ky_binh", "south.png"),
        "kb_east":  os.path.join(BASE_DIR, "toi_uu", "ky_binh", "east.png"),
        "kb_north": os.path.join(BASE_DIR, "toi_uu", "ky_binh", "north.png"),
        "ck_south": os.path.join(BASE_DIR, "toi_uu", "cung_ky", "south.png"),
        "ck_east":  os.path.join(BASE_DIR, "toi_uu", "cung_ky", "east.png"),
        "ck_north": os.path.join(BASE_DIR, "toi_uu", "cung_ky", "north.png")
    }
    
    refs = {
        "kb_south": "upload:8c9dcbef-902e-4d8a-80bb-8b186e3c0170",
        "kb_east":  "upload:85a91bd7-dab5-436e-a44b-9f48dce94b25",
        "kb_north": "upload:a2035040-abfe-4006-9382-c2ff8e48becc",
        "ck_south": "upload:ad719fad-a2b6-4852-9832-bdc1624d140b",
        "ck_east":  "upload:08373c77-0ff6-408a-a37c-f90d6a77717a",
        "ck_north": "upload:ba375276-3d5d-4d20-9ecc-ac591c7b7a4e"
    }
    
    actions = {
        # Kỵ binh
        "kb_walk_south": (refs["kb_south"], "warrior riding small horse trotting forward towards camera, horse legs moving in running trot cycle"),
        "kb_walk_east":  (refs["kb_east"],  "warrior riding horse galloping running to the right, full trot gallop animation cycle with moving legs"),
        "kb_walk_north": (refs["kb_north"], "warrior riding horse trotting forward away from camera, horse legs moving in trot cycle"),
        "kb_atk_south":  (refs["kb_south"], "mounted cavalry warrior thrusting lance spear downwards at enemy, attack thrust strike"),
        "kb_atk_east":   (refs["kb_east"],  "mounted cavalry charging and thrusting spear lance to the right at enemy, attack strike"),
        "kb_hurt":       (refs["kb_south"], "mounted horse rearing back flinching in pain recoil, warrior taking damage hit"),
        "kb_death":      (refs["kb_south"], "horse and mounted warrior collapsing falling down to the ground dead, death defeat"),

        # Cung kỵ
        "ck_walk_south": (refs["ck_south"], "horse archer riding small horse trotting forward towards camera, horse legs moving in running trot cycle"),
        "ck_walk_east":  (refs["ck_east"],  "horse archer riding horse galloping running to the right, full trot gallop animation cycle with moving legs"),
        "ck_walk_north": (refs["ck_north"], "horse archer riding horse trotting forward away from camera, horse legs moving in trot cycle"),
        "ck_atk_south":  (refs["ck_south"], "horse archer aiming short bow downwards drawing string and releasing arrow shot, shooting attack"),
        "ck_atk_east":   (refs["ck_east"],  "horse archer aiming bow to the right drawing bowstring and shooting arrow, archery attack"),
        "ck_hurt":       (refs["ck_south"], "horse archer and horse rearing back flinching in pain recoil, taking hit damage"),
        "ck_death":      (refs["ck_south"], "horse archer and horse collapsing falling down to the ground dead, defeat death fall")
    }
    
    # Đã gửi từ trước
    jobs = {
        "kb_walk_south": "95b2a8b1-08d3-49d6-a790-77651cfbe24b",
        "kb_walk_east":  "f5ab55e1-d8db-482b-823f-ad3e452a8bef",
        "kb_walk_north": "3f450084-d516-4fe2-80c1-090a97b16037",
        "kb_atk_south":  "108eb162-da02-4400-803b-62a23b115e2e",
        "kb_atk_east":   "aa4bf183-ac69-421d-83c7-4879ecfc5f5c",
        "kb_hurt":       "9909b1d1-3a8f-4ba9-89db-e6c4d14c7fbf",
        "kb_death":      "39c96684-96f2-4159-bbcc-cd0161f2a531",
        "ck_walk_south": "bfeaae10-3f16-4b2b-8ecb-5b9d8e59d728"
    }
    
    # Quản lý hàng đợi và xử lý song song
    completed_jobs = {}
    pending_to_submit = [k for k in actions.keys() if k not in jobs]
    
    print(f"\n--- TIẾN HÀNH THEO DÕI VÀ ĐIỀU PHỐI HÀNG ĐỢI ({len(actions)} JOBS TỔNG CỘNG) ---")
    
    for round_i in range(80):
        # 1. Kiểm tra trạng thái các job đang chạy trong jobs
        active_running = []
        for k, jid in list(jobs.items()):
            if k in completed_jobs:
                continue
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                print(f"  + Job {k} ({jid}) ĐÃ HOÀN TẤT!")
                completed_jobs[k] = jid
            elif "failed" in status_line:
                raise RuntimeError(f"Job {k} thất bại: {res}")
            else:
                active_running.append(k)
                
        print(f"  [Vòng {round_i+1}] Đã xong {len(completed_jobs)}/{len(actions)} | Đang chạy {len(active_running)}: {active_running} | Còn chờ gửi: {len(pending_to_submit)}")
        
        if len(completed_jobs) == len(actions):
            print("\nTOÀN BỘ 14 ANIMATION JOBS ĐÃ HOÀN TẤT 100%!")
            break
            
        # 2. Nếu số job đang chạy < 7 và còn job chờ gửi, gửi thêm
        while len(active_running) < 7 and pending_to_submit:
            next_k = pending_to_submit.pop(0)
            ref, act = actions[next_k]
            print(f"  -> Gửi job mới: {next_k}...")
            jid = submit_anim_job(ref, act)
            if jid:
                jobs[next_k] = jid
                active_running.append(next_k)
                print(f"     Gửi thành công! Job ID: {jid}")
            else:
                print(f"     Rate limit, đẩy lại {next_k} vào hàng đợi.")
                pending_to_submit.insert(0, next_k)
                break
            time.sleep(1)
            
        time.sleep(8)

    # 3. Tải và lưu các frames hoạt ảnh hoàn chỉnh
    print("\n--- XỬ LÝ VÀ LƯU HOẠT ẢNH HOÀN THIỆN ---")
    
    # Kỵ Binh
    print("\n[1/2] Xử lý hoạt ảnh Kỵ Binh:")
    kb_walk_dir = os.path.join(OUT_ANIM_DIR, "ky_binh")
    os.makedirs(kb_walk_dir, exist_ok=True)
    
    kb_walk_s = download_frames(completed_jobs["kb_walk_south"])
    kb_walk_e = download_frames(completed_jobs["kb_walk_east"])
    kb_walk_n = download_frames(completed_jobs["kb_walk_north"])
    kb_walk_w = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in kb_walk_e]
    
    for i in range(4):
        kb_walk_s[i].save(os.path.join(kb_walk_dir, f"south_{i}.png"))
        kb_walk_e[i].save(os.path.join(kb_walk_dir, f"east_{i}.png"))
        kb_walk_n[i].save(os.path.join(kb_walk_dir, f"north_{i}.png"))
        kb_walk_w[i].save(os.path.join(kb_walk_dir, f"west_{i}.png"))
        
    kb_sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for col in range(4):
        kb_sheet.paste(kb_walk_s[col], (col * 64, 0))
        kb_sheet.paste(kb_walk_e[col], (col * 64, 64))
        kb_sheet.paste(kb_walk_n[col], (col * 64, 128))
        kb_sheet.paste(kb_walk_w[col], (col * 64, 192))
    kb_sheet.save(os.path.join(kb_walk_dir, "spritesheet_walk_256x256.png"))
    
    kb_walk_gif = []
    for i in range(4):
        g = Image.new("RGBA", (128, 64), (34, 32, 52, 255))
        g.paste(kb_walk_s[i], (0, 0), kb_walk_s[i])
        g.paste(kb_walk_e[i], (64, 0), kb_walk_e[i])
        kb_walk_gif.append(g.convert("RGB"))
    kb_walk_gif[0].save(os.path.join(kb_walk_dir, "walk_preview.gif"), save_all=True, append_images=kb_walk_gif[1:], duration=150, loop=0)
    print("  + Đã lưu Walk Kỵ Binh")
    
    # Attack Kỵ Binh
    kb_atk_dir = os.path.join(OUT_ANIM_DIR, "tan_cong", "ky_binh")
    os.makedirs(kb_atk_dir, exist_ok=True)
    kb_atk_s = download_frames(completed_jobs["kb_atk_south"])
    kb_atk_e = download_frames(completed_jobs["kb_atk_east"])
    kb_atk_w = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in kb_atk_e]
    for i in range(4):
        kb_atk_s[i].save(os.path.join(kb_atk_dir, f"south_{i}.png"))
        kb_atk_e[i].save(os.path.join(kb_atk_dir, f"east_{i}.png"))
        kb_atk_w[i].save(os.path.join(kb_atk_dir, f"west_{i}.png"))
    kb_atk_gif = []
    for i in range(4):
        g = Image.new("RGBA", (192, 64), (34, 32, 52, 255))
        g.paste(kb_atk_s[i], (0, 0), kb_atk_s[i])
        g.paste(kb_atk_w[i], (64, 0), kb_atk_w[i])
        g.paste(kb_atk_e[i], (128, 0), kb_atk_e[i])
        kb_atk_gif.append(g.convert("RGB"))
    kb_atk_gif[0].save(os.path.join(kb_atk_dir, "attack_preview.gif"), save_all=True, append_images=kb_atk_gif[1:], duration=150, loop=0)
    print("  + Đã lưu Attack Kỵ Binh")
    
    # Hurt Kỵ Binh
    kb_hurt_dir = os.path.join(OUT_ANIM_DIR, "bi_thuong", "ky_binh")
    os.makedirs(kb_hurt_dir, exist_ok=True)
    kb_hurt_frames = download_frames(completed_jobs["kb_hurt"])
    for i in range(4):
        kb_hurt_frames[i].save(os.path.join(kb_hurt_dir, f"hurt_{i}.png"))
    kb_hurt_frames[0].save(os.path.join(kb_hurt_dir, "hurt_preview.gif"), save_all=True, append_images=kb_hurt_frames[1:], duration=150, loop=0)
    print("  + Đã lưu Hurt Kỵ Binh")
    
    # Death Kỵ Binh
    kb_death_dir = os.path.join(OUT_ANIM_DIR, "guc_nga", "ky_binh")
    os.makedirs(kb_death_dir, exist_ok=True)
    kb_death_frames = download_frames(completed_jobs["kb_death"])
    for i in range(4):
        kb_death_frames[i].save(os.path.join(kb_death_dir, f"death_{i}.png"))
    kb_death_frames[0].save(os.path.join(kb_death_dir, "death_preview.gif"), save_all=True, append_images=kb_death_frames[1:], duration=150, loop=0)
    print("  + Đã lưu Death Kỵ Binh")

    # Cung Kỵ
    print("\n[2/2] Xử lý hoạt ảnh Cung Kỵ:")
    ck_walk_dir = os.path.join(OUT_ANIM_DIR, "cung_ky")
    os.makedirs(ck_walk_dir, exist_ok=True)
    
    ck_walk_s = download_frames(completed_jobs["ck_walk_south"])
    ck_walk_e = download_frames(completed_jobs["ck_walk_east"])
    ck_walk_n = download_frames(completed_jobs["ck_walk_north"])
    ck_walk_w = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in ck_walk_e]
    
    for i in range(4):
        ck_walk_s[i].save(os.path.join(ck_walk_dir, f"south_{i}.png"))
        ck_walk_e[i].save(os.path.join(ck_walk_dir, f"east_{i}.png"))
        ck_walk_n[i].save(os.path.join(ck_walk_dir, f"north_{i}.png"))
        ck_walk_w[i].save(os.path.join(ck_walk_dir, f"west_{i}.png"))
        
    ck_sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    for col in range(4):
        ck_sheet.paste(ck_walk_s[col], (col * 64, 0))
        ck_sheet.paste(ck_walk_e[col], (col * 64, 64))
        ck_sheet.paste(ck_walk_n[col], (col * 64, 128))
        ck_sheet.paste(ck_walk_w[col], (col * 64, 192))
    ck_sheet.save(os.path.join(ck_walk_dir, "spritesheet_walk_256x256.png"))
    
    ck_walk_gif = []
    for i in range(4):
        g = Image.new("RGBA", (128, 64), (34, 32, 52, 255))
        g.paste(ck_walk_s[i], (0, 0), ck_walk_s[i])
        g.paste(ck_walk_e[i], (64, 0), ck_walk_e[i])
        ck_walk_gif.append(g.convert("RGB"))
    ck_walk_gif[0].save(os.path.join(ck_walk_dir, "walk_preview.gif"), save_all=True, append_images=ck_walk_gif[1:], duration=150, loop=0)
    print("  + Đã lưu Walk Cung Kỵ")
    
    # Attack Cung Kỵ
    ck_atk_dir = os.path.join(OUT_ANIM_DIR, "tan_cong", "cung_ky")
    os.makedirs(ck_atk_dir, exist_ok=True)
    ck_atk_s = download_frames(completed_jobs["ck_atk_south"])
    ck_atk_e = download_frames(completed_jobs["ck_atk_east"])
    ck_atk_w = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in ck_atk_e]
    for i in range(4):
        ck_atk_s[i].save(os.path.join(ck_atk_dir, f"south_{i}.png"))
        ck_atk_e[i].save(os.path.join(ck_atk_dir, f"east_{i}.png"))
        ck_atk_w[i].save(os.path.join(ck_atk_dir, f"west_{i}.png"))
    ck_atk_gif = []
    for i in range(4):
        g = Image.new("RGBA", (192, 64), (34, 32, 52, 255))
        g.paste(ck_atk_s[i], (0, 0), ck_atk_s[i])
        g.paste(ck_atk_w[i], (64, 0), ck_atk_w[i])
        g.paste(ck_atk_e[i], (128, 0), ck_atk_e[i])
        ck_atk_gif.append(g.convert("RGB"))
    ck_atk_gif[0].save(os.path.join(ck_atk_dir, "attack_preview.gif"), save_all=True, append_images=ck_atk_gif[1:], duration=150, loop=0)
    print("  + Đã lưu Attack Cung Kỵ")
    
    # Hurt Cung Kỵ
    ck_hurt_dir = os.path.join(OUT_ANIM_DIR, "bi_thuong", "cung_ky")
    os.makedirs(ck_hurt_dir, exist_ok=True)
    ck_hurt_frames = download_frames(completed_jobs["ck_hurt"])
    for i in range(4):
        ck_hurt_frames[i].save(os.path.join(ck_hurt_dir, f"hurt_{i}.png"))
    ck_hurt_frames[0].save(os.path.join(ck_hurt_dir, "hurt_preview.gif"), save_all=True, append_images=ck_hurt_frames[1:], duration=150, loop=0)
    print("  + Đã lưu Hurt Cung Kỵ")
    
    # Death Cung Kỵ
    ck_death_dir = os.path.join(OUT_ANIM_DIR, "guc_nga", "cung_ky")
    os.makedirs(ck_death_dir, exist_ok=True)
    ck_death_frames = download_frames(completed_jobs["ck_death"])
    for i in range(4):
        ck_death_frames[i].save(os.path.join(ck_death_dir, f"death_{i}.png"))
    ck_death_frames[0].save(os.path.join(ck_death_dir, "death_preview.gif"), save_all=True, append_images=ck_death_frames[1:], duration=150, loop=0)
    print("  + Đã lưu Death Cung Kỵ")

    # 4. Cập nhật ảnh đại tổng hợp
    print("\n--- CẬP NHẬT ẢNH ĐẠI TỔNG HỢP ---")
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    
    ov_w, ov_h = 760, 680
    overview = Image.new("RGBA", (ov_w, ov_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(overview)
    
    draw.text((16, 14), "TỔNG HỢP TOÀN BỘ ASSET HÌNH ẢNH HOÀN THIỆN (E8 - HOẠT ẢNH AI CHUẨN)", fill=(255, 230, 150), font=font)
    draw.text((16, 36), "100% Chuẩn Bảng Màu Resurrect 64 & 1-bit Alpha — Hoạt ảnh Kỵ Binh & Cung Kỵ sinh thật sự từ PixelLab AI", fill=(180, 200, 220), font=font_sub)
    
    # Hàng 1: E4 Chân dung & Giao diện, Hiệu ứng
    e4_p = os.path.join(BASE_DIR, "toi_uu", "chan_dung", "e4_nguoi_dan_chuyen_khung_96x96.png")
    if os.path.exists(e4_p): overview.paste(Image.open(e4_p), (16, 86))
    e4_64 = os.path.join(BASE_DIR, "toi_uu", "chan_dung", "e4_nguoi_dan_chuyen_khung_64x64.png")
    if os.path.exists(e4_64): overview.paste(Image.open(e4_64), (124, 86))
    
    c9_p = os.path.join(BASE_DIR, "toi_uu", "hieu_ung", "c9_hoi_mau.png")
    if os.path.exists(c9_p):
        im = Image.open(c9_p); overview.paste(im, (206, 86), im)
        draw.text((206, 138), "C9 Hồi máu", fill=(180, 220, 180), font=font_sub)
        
    c10_p = os.path.join(BASE_DIR, "toi_uu", "hieu_ung", "c10_lang_trung_don.png")
    if os.path.exists(c10_p):
        im = Image.open(c10_p); overview.paste(im, (270, 86), im)
        draw.text((270, 138), "C10 Làng trúng", fill=(220, 180, 180), font=font_sub)
        
    d6_t = os.path.join(BASE_DIR, "toi_uu", "giao_dien", "d6_nhiem_vu_tieu_diet_32x32.png")
    if os.path.exists(d6_t):
        im = Image.open(d6_t); overview.paste(im, (350, 86), im)
        draw.text((344, 124), "D6 Tiêu diệt", fill=(200, 200, 200), font=font_sub)
        
    d6_g = os.path.join(BASE_DIR, "toi_uu", "giao_dien", "d6_nhiem_vu_giu_ai_32x32.png")
    if os.path.exists(d6_g):
        im = Image.open(d6_g); overview.paste(im, (420, 86), im)
        draw.text((418, 124), "D6 Giữ ải", fill=(200, 200, 200), font=font_sub)
        
    for c_idx, (cn, cl) in enumerate([("mac_dinh", "Thường"), ("chon_tuong", "Chọn"), ("tan_cong", "Đánh")]):
        cp = os.path.join(BASE_DIR, "toi_uu", "giao_dien", "con_tro", f"d7_con_tro_{cn}.png")
        if os.path.exists(cp):
            im = Image.open(cp); overview.paste(im, (490 + c_idx * 60, 86), im)
            draw.text((486 + c_idx * 60, 124), f"D7 {cl}", fill=(200, 200, 200), font=font_sub)
            
    # Hàng 2: Tranh chuyển cảnh
    draw.text((16, 196), "F2: Tranh chuyển cảnh / Dẫn nhập lịch sử (Bình Than - Vạn Kiếp - Bạch Đằng)", fill=(255, 215, 120), font=font_sub)
    for idx, fn in enumerate(["f2_1_hoi_nghi_binh_than_320x180.png", "f2_2_luy_ai_van_kiep_320x180.png", "f2_3_thuy_chien_bach_dang_320x180.png"]):
        fp = os.path.join(BASE_DIR, "toi_uu", "chuyen_tran", fn)
        if os.path.exists(fp):
            fim = Image.open(fp).resize((224, 126), Image.NEAREST)
            overview.paste(fim, (16 + idx * 242, 218))
            
    # Hàng 3: Kỵ binh & Cung kỵ Hoạt ảnh thật sự
    draw.text((16, 362), "B5 Kỵ Binh & B6 Cung Kỵ: Hoạt ảnh Phi Nước Đại & Tấn Công do AI tạo", fill=(255, 215, 120), font=font_sub)
    for i in range(4):
        overview.paste(kb_walk_s[i], (16 + i * 68, 386), kb_walk_s[i])
    draw.text((16, 456), "Kỵ binh: Phi nước đại (South)", fill=(220, 220, 220), font=font_sub)
    
    for i in range(4):
        overview.paste(kb_atk_e[i], (300 + i * 68, 386), kb_atk_e[i])
    draw.text((300, 456), "Kỵ binh: Xung phong đâm thương (East)", fill=(220, 220, 220), font=font_sub)
    
    for i in range(4):
        overview.paste(ck_walk_s[i], (16 + i * 68, 480), ck_walk_s[i])
    draw.text((16, 550), "Cung kỵ: Phi nước đại (South)", fill=(220, 220, 220), font=font_sub)
    
    for i in range(4):
        overview.paste(ck_atk_e[i], (300 + i * 68, 480), ck_atk_e[i])
    draw.text((300, 550), "Cung kỵ: Giương cung bắn tên (East)", fill=(220, 220, 220), font=font_sub)
    
    # Hurt & Death
    draw.text((580, 362), "Bị thương & Gục ngã", fill=(255, 215, 120), font=font_sub)
    overview.paste(kb_hurt_frames[1], (580, 386), kb_hurt_frames[1])
    overview.paste(kb_death_frames[3], (650, 386), kb_death_frames[3])
    draw.text((580, 456), "Kỵ binh: Trúng & Gục", fill=(200, 200, 200), font=font_sub)
    
    overview.paste(ck_hurt_frames[1], (580, 480), ck_hurt_frames[1])
    overview.paste(ck_death_frames[3], (650, 480), ck_death_frames[3])
    draw.text((580, 550), "Cung kỵ: Trúng & Gục", fill=(200, 200, 200), font=font_sub)
    
    draw.text((16, 650), "✓ TOÀN BỘ HOẠT ẢNH KỴ BINH & CUNG KỴ ĐÃ ĐƯỢC TẠO CHUẨN XÁC VỚI PIXELLAB AI!", fill=(145, 219, 105), font=font)
    
    ov_out = os.path.join(BASE_DIR, "toi_uu", "_tong_hop_toan_bo_asset_con_lai.png")
    overview.save(ov_out)
    print(f"\nĐÃ LƯU BẢNG ĐẠI TỔNG HỢP MỚI: {ov_out}")
    print("HOÀN TẤT!")

if __name__ == "__main__":
    main()
