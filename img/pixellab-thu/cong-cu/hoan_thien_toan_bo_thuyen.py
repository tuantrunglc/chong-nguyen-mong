#!/usr/bin/env python3
"""
Hoàn thiện toàn bộ hệ thống Thuyền chiến & Thủy chiến:
1. Trạng thái tác chiến: Thuyền đắm cọc Bạch Đằng, Thuyền lương cháy Vân Đồn, Chiến thuyền cháy
2. Soái hạm hạng nặng (64x128): Soái hạm Đại Việt (rồng viền đồng) & Soái hạm Nguyên Mông (lầu canh khiên)
3. Hoạt ảnh lướt sóng chèo thuyền (Rowing Animation 4 frames)
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

OUT_THUYEN_DIR = os.path.join(BASE_DIR, "toi_uu", "thuyen")
os.makedirs(OUT_THUYEN_DIR, exist_ok=True)

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

def quantize_im(im):
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
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 28) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 52))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

def wait_and_download(jobs):
    print(f"Đang theo dõi {len(jobs)} jobs thuyền...")
    pending = dict(jobs)
    results = {}
    for attempt in range(40):
        done_keys = []
        for k, jid in pending.items():
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                print(f"  + Job {k} ({jid}) ĐÃ HOÀN THÀNH!")
                # Parse download url
                for line in res.split("\n"):
                    if "download:" in line:
                        url = line.split("download:")[1].strip()
                        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
                        with urllib.request.urlopen(req) as resp:
                            raw = Image.open(resp).convert("RGBA")
                            results[k] = quantize_im(raw)
                        break
                done_keys.append(k)
            elif "failed" in status_line:
                raise RuntimeError(f"Job {k} thất bại: {res}")
        for dk in done_keys:
            del pending[dk]
        if not pending:
            print("Toàn bộ các job thuyền đã hoàn tất!")
            return results
        print(f"  [{attempt+1}/40] Còn {len(pending)} jobs ({list(pending.keys())})...")
        time.sleep(6)
    raise TimeoutError("Hết thời gian chờ")

def create_rowing_animation():
    print("\nĐang tạo hoạt ảnh chèo thuyền lướt sóng (Rowing Animation)...")
    base_p = os.path.join(OUT_THUYEN_DIR, "thuyen_chien_dai_viet.png")
    base_im = Image.open(base_p)
    w, h = base_im.size
    
    # 4 frames:
    # Frame 0: Dáng gốc
    # Frame 1: Mái chèo nhấc lên, bọt nước sủi ở đầu chèo
    # Frame 2: Mái chèo gạt nước đẩy về sau, thuyền nhích 1px về hướng tiến (Tây Nam: dx=-1, dy=+1)
    # Frame 3: Mái chèo phục hồi, vệt rẽ sóng trắng sau đuôi thuyền
    
    foam_color = (235, 237, 233, 255) # white foam Resurrect 64
    water_blue = (57, 120, 168, 255)  # blue water ripple
    
    rowing_frames = []
    
    # Frame 0
    f0 = base_im.copy()
    rowing_frames.append(quantize_im(f0))
    
    # Frame 1: Cắm chèo + bọt nước
    f1 = base_im.copy()
    arr1 = np.array(f1)
    # Thêm bọt nước trắng ở các mũi chèo dọc mạn (x=24..48, y=42..54)
    oar_tips = [(25, 48), (29, 50), (33, 52), (37, 54), (41, 56)]
    for ox, oy in oar_tips:
        for dx, dy in [(0, 1), (1, 1), (-1, 1)]:
            if 0 <= ox+dx < w and 0 <= oy+dy < h:
                arr1[oy+dy, ox+dx] = np.array(foam_color)
    f1 = Image.fromarray(arr1)
    rowing_frames.append(quantize_im(f1))
    
    # Frame 2: Đẩy nước + Thuyền lướt nhẹ
    f2 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    f2.paste(base_im, (-1, 1), base_im)
    arr2 = np.array(f2)
    for ox, oy in oar_tips:
        for dx, dy in [(1, 0), (2, -1), (1, 1)]:
            if 0 <= ox+dx < w and 0 <= oy+dy < h:
                arr2[oy+dy, ox+dx] = np.array(water_blue)
    f2 = Image.fromarray(arr2)
    rowing_frames.append(quantize_im(f2))
    
    # Frame 3: Nhấc chèo + rẽ sóng đuôi thuyền
    f3 = base_im.copy()
    arr3 = np.array(f3)
    # Đuôi thuyền ở góc trên bên phải (x=50..58, y=24..30)
    wake_pts = [(54, 24), (56, 22), (58, 20), (52, 28), (50, 30)]
    for wx, wy in wake_pts:
        if 0 <= wx < w and 0 <= wy < h:
            arr3[wy, wx] = np.array(foam_color)
    f3 = Image.fromarray(arr3)
    rowing_frames.append(quantize_im(f3))
    
    # Lưu 4 frames
    for i, frm in enumerate(rowing_frames):
        frm.save(os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_{i}.png"))
        # Bản lật ngược dòng
        frm.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_nguoc_{i}.png"))
        
    gif_p = os.path.join(OUT_THUYEN_DIR, "thuyen_cheo_preview.gif")
    rowing_frames[0].save(gif_p, save_all=True, append_images=rowing_frames[1:], duration=180, loop=0)
    print(f"Đã lưu hoạt ảnh chèo thuyền: {gif_p}")

def build_grand_boat_showcase():
    print("\nĐang tạo Đại bảng tổng hợp toàn bộ Thuyền chiến...")
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    
    # 4 Hàng lớn:
    # Hàng 1: Chiến thuyền cơ bản (Đại Việt, Nguyên Mông, Thuyền lương Trương Văn Hổ)
    # Hàng 2: Trạng thái tác chiến (Đắm cọc Bạch Đằng, Thuyền lương cháy, Chiến thuyền cháy)
    # Hàng 3: Soái hạm hạng nặng 64x128 (Đại Việt rồng viền đồng & Nguyên Mông lầu canh)
    # Hàng 4: Hoạt ảnh chèo thuyền lướt sóng (4 frames)
    
    total_w = 720
    total_h = 760
    pad = 16
    
    board = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(board)
    
    draw.text((pad, 14), "ĐẠI TỔNG HỢP HỆ THỐNG THỦY CHIẾN & THUYỀN (CHUẨN 100% RESURRECT 64)", fill=(255, 230, 150), font=font)
    draw.text((pad, 34), "Chiến thuyền cơ bản, Tác chiến cháy/đắm cọc, Soái hạm 64×128 & Hoạt ảnh chèo thuyền", fill=(180, 200, 220), font=font_sub)
    
    # HÀNG 1: Thuyền cơ bản (y=60)
    y1 = 64
    draw.text((pad, y1), "1. CHIẾN THUYỀN CƠ BẢN (64×64 PX)", fill=(255, 215, 120), font=font)
    base_list = [
        ("thuyen_chien_dai_viet.png", "Thuyền Mông Đồng Đại Việt"),
        ("thuyen_chien_nguyen.png", "Chiến thuyền Nguyên Mông"),
        ("thuyen_tai_luong_nguyen.png", "Thuyền lương Trương Văn Hổ")
    ]
    for i, (fn, title) in enumerate(base_list):
        p = os.path.join(OUT_THUYEN_DIR, fn)
        if os.path.exists(p):
            im = Image.open(p).resize((96, 96), Image.NEAREST)
            x = pad + i * 220
            board.paste(im, (x, y1 + 22), im)
            draw.text((x, y1 + 122), title, fill=(200, 220, 240), font=font_sub)
            
    # HÀNG 2: Tác chiến Cháy & Đắm cọc (y=220)
    y2 = 216
    draw.text((pad, y2), "2. TRẠNG THÁI TÁC CHIẾN: CHÁY & ĐẮM CỌC BẠCH ĐẰNG (64×64 PX)", fill=(255, 215, 120), font=font)
    combat_list = [
        ("thuyen_dam_coc_bach_dang.png", "Đắm cọc Bạch Đằng (Mạn vỡ)"),
        ("thuyen_tai_luong_chay.png", "Thuyền lương cháy Vân Đồn"),
        ("thuyen_chien_nguyen_chay.png", "Chiến thuyền trúng hỏa công")
    ]
    for i, (fn, title) in enumerate(combat_list):
        p = os.path.join(OUT_THUYEN_DIR, fn)
        if os.path.exists(p):
            im = Image.open(p).resize((96, 96), Image.NEAREST)
            x = pad + i * 220
            board.paste(im, (x, y2 + 22), im)
            draw.text((x, y2 + 122), title, fill=(255, 140, 140), font=font_sub)

    # HÀNG 3: Soái hạm hạng nặng 64x128 (y=370)
    y3 = 372
    draw.text((pad, y3), "3. SOÁI HẠM HẠNG NẶNG (64×128 PX — DÀI 2 Ô)", fill=(255, 215, 120), font=font)
    cap_list = [
        ("soai_ham_dai_viet_64x128.png", "Đại Soái Hạm Mông Đồng (Đại Việt - Rồng & Đồng)"),
        ("soai_ham_nguyen_64x128.png", "Đại Hạm Ô Mã Nhi (Nguyên Mông - Tháp canh)")
    ]
    for i, (fn, title) in enumerate(cap_list):
        p = os.path.join(OUT_THUYEN_DIR, fn)
        if os.path.exists(p):
            im = Image.open(p).resize((80, 160), Image.NEAREST)
            x = pad + i * 330
            board.paste(im, (x, y3 + 22), im)
            draw.text((x, y3 + 186), title, fill=(255, 230, 160), font=font_sub)

    # HÀNG 4: Hoạt ảnh chèo thuyền lướt sóng (y=590)
    y4 = 590
    draw.text((pad, y4), "4. HOẠT ẢNH CHÈO THUYỀN LƯỚT SÓNG (ROWING ANIMATION - 4 FRAMES)", fill=(255, 215, 120), font=font)
    for i in range(4):
        p = os.path.join(OUT_THUYEN_DIR, f"thuyen_cheo_{i}.png")
        if os.path.exists(p):
            im = Image.open(p).resize((96, 96), Image.NEAREST)
            x = pad + i * 160
            board.paste(im, (x, y4 + 22), im)
            draw.text((x + 20, y4 + 122), f"Frame {i}", fill=(180, 220, 255), font=font_sub)

    out_p = os.path.join(OUT_THUYEN_DIR, "_tong_hop_toan_bo_thuyen_chien.png")
    board.save(out_p)
    print(f"Đã lưu Đại bảng tổng hợp toàn bộ thuyền chiến: {out_p}")

def main():
    jobs = {
        "dam_coc": "e47521c0-6115-4367-b227-08f6fe50b6d1",
        "luong_chay": "057488b4-1ba9-49ed-a002-454f2de94c42",
        "nguyen_chay": "ce20d0e2-84c2-4deb-8b4f-ad6445053838",
        "soai_ham_dv": "b3351234-0431-415c-9b54-31b23dc16c8b",
        "soai_ham_nm": "e63a4ea2-b8ec-47dd-a274-6619595f29f3"
    }
    
    res = wait_and_download(jobs)
    
    # Lưu kết quả
    res["dam_coc"].save(os.path.join(OUT_THUYEN_DIR, "thuyen_dam_coc_bach_dang.png"))
    res["luong_chay"].save(os.path.join(OUT_THUYEN_DIR, "thuyen_tai_luong_chay.png"))
    res["nguyen_chay"].save(os.path.join(OUT_THUYEN_DIR, "thuyen_chien_nguyen_chay.png"))
    res["soai_ham_dv"].save(os.path.join(OUT_THUYEN_DIR, "soai_ham_dai_viet_64x128.png"))
    res["soai_ham_nm"].save(os.path.join(OUT_THUYEN_DIR, "soai_ham_nguyen_64x128.png"))
    print("Đã lưu toàn bộ 5 asset thuyền mới!")
    
    # Tạo hoạt ảnh chèo thuyền lướt sóng
    create_rowing_animation()
    
    # Tạo đại bảng tổng hợp
    build_grand_boat_showcase()
    print("\nHOÀN TẤT TOÀN DIỆN HỆ THỐNG THUYỀN CHIẾN!")

if __name__ == "__main__":
    main()
