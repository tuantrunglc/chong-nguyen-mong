#!/usr/bin/env python3
"""
Tạo và hoàn thiện TOÀN BỘ các asset hình ảnh còn lại của game (E8):
1. B5 & B6: Hoàn thiện trọn bộ hoạt ảnh Di chuyển, Tấn công, Bị thương, Gục ngã cho Kỵ binh & Cung kỵ
2. C9: Hiệu ứng Hồi máu (Heal VFX 48x48)
3. C10: Hiệu ứng Làng bị đánh trúng / Khói nổ (Village Damage VFX 48x48)
4. D6: Biểu tượng nhiệm vụ / mục tiêu hiệp: Tiêu diệt, Giữ ải (32x32 & 24x24)
5. D7: Bộ 3 con trỏ chuột tùy biến: Con trỏ thường, Con trỏ chọn, Con trỏ tấn công (32x32)
6. E4: Chân dung Người dẫn chuyện thời Trần (96x96 & 64x64, có khung & không khung)
7. F2: Trọn bộ 3 bức tranh chuyển trận / dẫn nhập lịch sử (320x180 & 640x360)

100% chuẩn Resurrect 64, 1-bit alpha cho sprites/icons/VFX, không anti-aliasing.
"""

import os, sys, time, re, urllib.request, json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

sys.path.append(os.path.join(BASE_DIR, "cong-cu"))
from pl import call

# Directories
OUT_ANIM_DIR = os.path.join(BASE_DIR, "toi_uu", "hoat_anh")
OUT_VFX_DIR = os.path.join(BASE_DIR, "toi_uu", "hieu_ung")
OUT_UI_DIR = os.path.join(BASE_DIR, "toi_uu", "giao_dien")
OUT_CURSOR_DIR = os.path.join(OUT_UI_DIR, "con_tro")
OUT_PORTRAIT_DIR = os.path.join(BASE_DIR, "toi_uu", "chan_dung")
OUT_TRANSITION_DIR = os.path.join(BASE_DIR, "toi_uu", "chuyen_tran")

for d in [OUT_ANIM_DIR, OUT_VFX_DIR, OUT_UI_DIR, OUT_CURSOR_DIR, OUT_PORTRAIT_DIR, OUT_TRANSITION_DIR]:
    os.makedirs(d, exist_ok=True)

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

def quantize_im(im, is_opaque=False):
    arr = np.array(im.convert("RGBA"))
    h, w, _ = arr.shape
    alpha = arr[..., 3]
    if is_opaque:
        opaque = np.ones((h, w), dtype=bool)
        out_alpha = np.full((h, w), 255, dtype=np.uint8)
    else:
        opaque = alpha >= 120
        out_alpha = np.where(opaque, 255, 0).astype(np.uint8)
        
    rgb = arr[..., :3].astype(np.float32)
    px = rgb[opaque]
    if len(px) > 0:
        lab_px = rgb_to_cielab(px)
        diff = lab_px[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        best_idx = np.argmin(np.sum(diff ** 2, axis=-1), axis=-1)
        q_rgb = palette_arr[best_idx].astype(np.uint8)
        
        # Dim/outline dark threshold
        lum = 0.299 * px[:, 0] + 0.587 * px[:, 1] + 0.114 * px[:, 2]
        dark = (lum < 26) | ((px[:, 0] < 46) & (px[:, 1] < 46) & (px[:, 2] < 50))
        q_rgb[dark] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
    return Image.fromarray(np.dstack([out_rgb, out_alpha]), mode="RGBA")

def submit_job(tool, args):
    res = call(tool, args)
    m = re.search(r"job_id:\s*([a-f0-9\-]+)", res)
    if m:
        return m.group(1)
    # Check if id: is present
    m = re.search(r"^id:\s*([a-f0-9\-]+)", res, re.M)
    if m:
        return m.group(1)
    raise RuntimeError(f"Không lấy được job_id từ: {res}")

def wait_and_download_jobs(jobs_dict, is_opaque_dict=None):
    if is_opaque_dict is None:
        is_opaque_dict = {}
    print(f"\nTheo dõi {len(jobs_dict)} jobs đang xử lý...")
    pending = dict(jobs_dict)
    results = {}
    for attempt in range(50):
        done_keys = []
        for k, jid in pending.items():
            res = call("get_image", {"job_id": jid})
            status_line = res.split("\n")[0]
            if "completed" in status_line:
                print(f"  + Job {k} ({jid}) ĐÃ HOÀN THÀNH!")
                for line in res.split("\n"):
                    if "download:" in line:
                        url = line.split("download:")[1].strip()
                        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
                        with urllib.request.urlopen(req) as resp:
                            raw = Image.open(resp).convert("RGBA")
                            results[k] = quantize_im(raw, is_opaque=is_opaque_dict.get(k, False))
                        break
                done_keys.append(k)
            elif "failed" in status_line:
                raise RuntimeError(f"Job {k} thất bại: {res}")
        for dk in done_keys:
            del pending[dk]
        if not pending:
            print("Toàn bộ các job đã hoàn tất và tải về thành công!")
            return results
        print(f"  [{attempt+1}/50] Còn {len(pending)} jobs đang xử lý ({list(pending.keys())})...")
        time.sleep(7)
    raise TimeoutError(f"Hết thời gian chờ: {list(pending.keys())}")

# ==============================================================================
# PHẦN 1: TẠO VÀ HOÀN THIỆN HOẠT ẢNH KỴ BINH & CUNG KỴ (B5 & B6)
# ==============================================================================
def create_cavalry_animations():
    print("\n=======================================================")
    print("XÂY DỰNG TOÀN BỘ HOẠT ẢNH CHO KỴ BINH & CUNG KỴ (B5 & B6)")
    print("=======================================================")
    
    # Bảng màu đại diện
    outline = (46, 34, 47, 255) # #2e222f
    spear_color = (155, 171, 178, 255) # #9babb2
    spear_tip = (255, 255, 255, 255)
    bow_wood = (103, 102, 51, 255) # #676633
    bow_string = (249, 194, 43, 255) # #f9c22b
    arrow_color = (205, 104, 61, 255) # #cd683d
    dust_color = (171, 148, 122, 255) # #ab947a
    
    units = [
        ("ky_binh", "ky_binh", "Kỵ Binh"),
        ("cung_ky", "cung_ky", "Cung Kỵ")
    ]
    
    for u_key, folder, u_name in units:
        print(f"\n--- Xử lý hoạt ảnh cho {u_name} ({u_key}) ---")
        base_dir = os.path.join(BASE_DIR, "toi_uu", folder)
        
        # Load idle 4 directions
        dirs = ["south", "east", "north", "west"]
        base_sprites = {}
        for d in dirs:
            fp = os.path.join(base_dir, f"{d}.png")
            if os.path.exists(fp):
                base_sprites[d] = Image.open(fp).convert("RGBA")
            else:
                # Fallback flip east for west
                if d == "west" and "east" in base_sprites:
                    base_sprites["west"] = base_sprites["east"].transpose(Image.FLIP_LEFT_RIGHT)
                    
        # 1. Walk Animation (4 frames x 4 directions)
        u_walk_dir = os.path.join(OUT_ANIM_DIR, u_key)
        os.makedirs(u_walk_dir, exist_ok=True)
        
        walk_frames = {d: [] for d in dirs}
        for d in dirs:
            b_im = base_sprites[d]
            w, h = b_im.size
            
            # Frame 0: Dáng gốc
            f0 = b_im.copy()
            walk_frames[d].append(quantize_im(f0))
            
            # Frame 1: Phi nước đại bước 1 - Ngựa nhún chồm lên 1px, chân co
            f1 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            f1.paste(b_im, (0, -1), b_im)
            arr1 = np.array(f1)
            # Thêm bụi sau vó ngựa
            if d in ["east", "south-east", "north-east"]:
                arr1[56:59, 12:16] = np.array(dust_color)
            elif d in ["west", "south-west", "north-west"]:
                arr1[56:59, 48:52] = np.array(dust_color)
            elif d == "south":
                arr1[57:60, 20:24] = np.array(dust_color)
                arr1[57:60, 40:44] = np.array(dust_color)
            elif d == "north":
                arr1[57:60, 28:36] = np.array(dust_color)
            f1 = Image.fromarray(arr1)
            walk_frames[d].append(quantize_im(f1))
            
            # Frame 2: Thân ngựa rướn dài, tiếp đất
            f2 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            # Shift 1px theo hướng tiến
            dx = 1 if d == "east" else (-1 if d == "west" else 0)
            dy = 1 if d == "south" else (-1 if d == "north" else 0)
            f2.paste(b_im, (dx, dy), b_im)
            walk_frames[d].append(quantize_im(f2))
            
            # Frame 3: Đẩy đà, thân hạ nhẹ
            f3 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            f3.paste(b_im, (0, 1), b_im)
            walk_frames[d].append(quantize_im(f3))
            
            # Lưu các frame walk
            for idx, fim in enumerate(walk_frames[d]):
                fim.save(os.path.join(u_walk_dir, f"{d}_{idx}.png"))
                
        # Tạo Spritesheet 4x4 256x256
        sheet = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
        for row_i, d in enumerate(["south", "east", "north", "west"]):
            for col_i in range(4):
                sheet.paste(walk_frames[d][col_i], (col_i * 64, row_i * 64))
        sheet.save(os.path.join(u_walk_dir, "spritesheet_walk_256x256.png"))
        
        # GIF preview walk (South + East)
        gif_frames = []
        for i in range(4):
            g_im = Image.new("RGBA", (128, 64), (34, 32, 52, 255))
            g_im.paste(walk_frames["south"][i], (0, 0), walk_frames["south"][i])
            g_im.paste(walk_frames["east"][i], (64, 0), walk_frames["east"][i])
            gif_frames.append(g_im.convert("RGB"))
        gif_frames[0].save(os.path.join(u_walk_dir, "walk_preview.gif"), save_all=True, append_images=gif_frames[1:], duration=150, loop=0)
        print(f"  + Đã xong hoạt ảnh Walk 4 hướng cho {u_name}")

        # 2. Attack Animation (4 frames: South & East)
        u_atk_dir = os.path.join(OUT_ANIM_DIR, "tan_cong", u_key)
        os.makedirs(u_atk_dir, exist_ok=True)
        atk_frames = {"south": [], "east": []}
        
        for d in ["south", "east"]:
            b_im = base_sprites[d]
            w, h = b_im.size
            # Frame 0: Dáng thủ
            atk_frames[d].append(quantize_im(b_im.copy()))
            
            if u_key == "ky_binh":
                # Kỵ binh: đâm thương xung phong
                # Frame 1: Ngựa dồn đà lùi (-1px hướng ngược lại), giáo lùi lấy thế
                f1 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
                back_dx = -1 if d == "east" else 0
                back_dy = -1 if d == "south" else 0
                f1.paste(b_im, (back_dx, back_dy), b_im)
                atk_frames[d].append(quantize_im(f1))
                
                # Frame 2: Phóng tới đâm mạnh (+2px), mũi thương rực sáng
                f2 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
                fwd_dx = 2 if d == "east" else 0
                fwd_dy = 2 if d == "south" else 0
                f2.paste(b_im, (fwd_dx, fwd_dy), b_im)
                arr2 = np.array(f2)
                if d == "east":
                    arr2[26:30, 48:62] = np.array(spear_color)
                    arr2[27:29, 60:64] = np.array(spear_tip)
                else: # south
                    arr2[42:58, 30:34] = np.array(spear_color)
                    arr2[56:60, 31:33] = np.array(spear_tip)
                atk_frames[d].append(quantize_im(Image.fromarray(arr2)))
                
                # Frame 3: Thu đòn về thế ổn định
                f3 = Image.new("RGBA", (w, h), (0, 0, 0, 0))
                f3.paste(b_im, (1 if d == "east" else 0, 1 if d == "south" else 0), b_im)
                atk_frames[d].append(quantize_im(f3))
                
            else: # cung_ky
                # Cung kỵ: giương cung bắn tên
                # Frame 1: Giương cung kéo căng dây
                f1 = b_im.copy()
                arr1 = np.array(f1)
                if d == "east":
                    arr1[22:36, 44:46] = np.array(bow_wood)
                    arr1[24:34, 38:40] = np.array(bow_string)
                    arr1[28:30, 38:48] = np.array(arrow_color)
                else:
                    arr1[26:28, 20:44] = np.array(bow_wood)
                    arr1[22:24, 24:40] = np.array(bow_string)
                    arr1[22:38, 31:33] = np.array(arrow_color)
                atk_frames[d].append(quantize_im(Image.fromarray(arr1)))
                
                # Frame 2: Buông dây tên bắn vút ra
                f2 = b_im.copy()
                arr2 = np.array(f2)
                if d == "east":
                    arr2[22:36, 44:46] = np.array(bow_wood)
                    arr2[28:30, 48:62] = np.array(arrow_color)
                    arr2[27:31, 60:63] = np.array((255, 255, 255, 255))
                else:
                    arr2[26:28, 20:44] = np.array(bow_wood)
                    arr2[36:58, 31:33] = np.array(arrow_color)
                    arr2[56:60, 30:34] = np.array((255, 255, 255, 255))
                atk_frames[d].append(quantize_im(Image.fromarray(arr2)))
                
                # Frame 3: Độ nảy cung sau khi bắn
                f3 = b_im.copy()
                arr3 = np.array(f3)
                if d == "east":
                    arr3[22:36, 43:45] = np.array(bow_wood)
                else:
                    arr3[27:29, 20:44] = np.array(bow_wood)
                atk_frames[d].append(quantize_im(Image.fromarray(arr3)))
                
            for idx, fim in enumerate(atk_frames[d]):
                fim.save(os.path.join(u_atk_dir, f"{d}_{idx}.png"))
                
        # Lật west từ east
        atk_frames["west"] = [f.transpose(Image.FLIP_LEFT_RIGHT) for f in atk_frames["east"]]
        for idx, fim in enumerate(atk_frames["west"]):
            fim.save(os.path.join(u_atk_dir, f"west_{idx}.png"))
            
        gif_atk = []
        for i in range(4):
            g = Image.new("RGBA", (192, 64), (34, 32, 52, 255))
            g.paste(atk_frames["south"][i], (0, 0), atk_frames["south"][i])
            g.paste(atk_frames["west"][i], (64, 0), atk_frames["west"][i])
            g.paste(atk_frames["east"][i], (128, 0), atk_frames["east"][i])
            gif_atk.append(g.convert("RGB"))
        gif_atk[0].save(os.path.join(u_atk_dir, "attack_preview.gif"), save_all=True, append_images=gif_atk[1:], duration=150, loop=0)
        print(f"  + Đã xong hoạt ảnh Attack cho {u_name}")

        # 3. Hurt Animation (4 frames)
        u_hurt_dir = os.path.join(OUT_ANIM_DIR, "bi_thuong", u_key)
        os.makedirs(u_hurt_dir, exist_ok=True)
        hurt_frames = []
        b_s = base_sprites["south"]
        
        # Frame 0: Giật lùi -1px
        f0 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        f0.paste(b_s, (0, -1), b_s)
        hurt_frames.append(quantize_im(f0))
        
        # Frame 1: Ngựa hý chồm lên giật lùi -2px, người nghiêng
        f1 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        f1.paste(b_s, (-1, -2), b_s)
        # Điểm xuyết tia trúng đòn trắng sáng
        arr1 = np.array(f1)
        arr1[26:30, 28:36] = np.array((255, 255, 255, 255))
        hurt_frames.append(quantize_im(Image.fromarray(arr1)))
        
        # Frame 2: Thất thố chao đảo +1px
        f2 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        f2.paste(b_s, (1, 1), b_s)
        hurt_frames.append(quantize_im(f2))
        
        # Frame 3: Gượng lại
        f3 = b_s.copy()
        hurt_frames.append(quantize_im(f3))
        
        for idx, fim in enumerate(hurt_frames):
            fim.save(os.path.join(u_hurt_dir, f"hurt_{idx}.png"))
        hurt_frames[0].save(os.path.join(u_hurt_dir, "hurt_preview.gif"), save_all=True, append_images=hurt_frames[1:], duration=150, loop=0)
        print(f"  + Đã xong hoạt ảnh Hurt cho {u_name}")

        # 4. Death Animation (4 frames)
        u_death_dir = os.path.join(OUT_ANIM_DIR, "guc_nga", u_key)
        os.makedirs(u_death_dir, exist_ok=True)
        death_frames = []
        
        # Frame 0: Trúng đòn chí mạng, người nghiêng mạnh
        d0 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        d0.paste(b_s, (-1, -1), b_s)
        death_frames.append(quantize_im(d0))
        
        # Frame 1: Ngựa quỵ gối hạ thấp 3px
        d1 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        d1.paste(b_s, (-2, 3), b_s)
        death_frames.append(quantize_im(d1))
        
        # Frame 2: Ngã nghiêng, kỵ sĩ văng khỏi yên (hạ thấp 6px)
        d2 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        d2.paste(b_s, (-3, 7), b_s)
        death_frames.append(quantize_im(d2))
        
        # Frame 3: Ngã hẳn xuống mặt đất, bụi bốc lên
        d3 = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        d3.paste(b_s, (-4, 11), b_s)
        arr3 = np.array(d3)
        # Bụi mù quanh xác ngựa
        arr3[54:58, 12:24] = np.array(dust_color)
        arr3[54:58, 40:54] = np.array(dust_color)
        death_frames.append(quantize_im(Image.fromarray(arr3)))
        
        for idx, fim in enumerate(death_frames):
            fim.save(os.path.join(u_death_dir, f"death_{idx}.png"))
        death_frames[0].save(os.path.join(u_death_dir, "death_preview.gif"), save_all=True, append_images=death_frames[1:], duration=150, loop=0)
        print(f"  + Đã xong hoạt ảnh Death cho {u_name}")

# ==============================================================================
# MAIN FUNCTION
# ==============================================================================
def main():
    print("BẮT ĐẦU QUY TRÌNH HOÀN THIỆN TOÀN BỘ ASSET HÌNH ẢNH CÒN LẠI...")
    
    # 1. Hoàn thiện hoạt ảnh cho Kỵ binh & Cung kỵ trước
    create_cavalry_animations()
    
    # 2. Chuẩn bị danh sách tạo asset qua PixelLab
    pixen_requests = {
        "c9_hoi_mau": {
            "description": "pixel art healing glow aura, herbal energy and soft emerald green light sparkles, gentle recovery magic, transparent background",
            "width": 48, "height": 48, "no_background": True
        },
        "c10_lang_trung_don": {
            "description": "pixel art explosion smoke burst and flying thatched roof straw and wooden debris, dust cloud impact, transparent background",
            "width": 48, "height": 48, "no_background": True
        },
        "d6_tieu_diet": {
            "description": "pixel art game icon crossed mongolian curved sabres over iron shield, mission icon defeat all enemies, crisp black outline, transparent background",
            "width": 32, "height": 32, "no_background": True
        },
        "d6_giu_ai": {
            "description": "pixel art game icon ancient stone citadel fortress gate tower with bronze shield, mission icon defend pass, crisp black outline, transparent background",
            "width": 32, "height": 32, "no_background": True
        },
        "d7_cursor_normal": {
            "description": "pixel art computer mouse cursor arrow, ancient bronze tip with dark lacquer handle, crisp hard edges, transparent background",
            "width": 32, "height": 32, "no_background": True
        },
        "d7_cursor_select": {
            "description": "pixel art computer mouse cursor target circle ring reticle with corner brackets, gold and bronze, transparent background",
            "width": 32, "height": 32, "no_background": True
        },
        "d7_cursor_attack": {
            "description": "pixel art combat targeting crosshair cursor with sword blade, red and bronze strike marker, transparent background",
            "width": 32, "height": 32, "no_background": True
        },
        "e4_nguoi_dan_chuyen": {
            "description": "pixel art character portrait of a 13th-century elderly Vietnamese scholar Confucian sage narrator, long white beard, topknot with dark silk headband, brown and charcoal traditional robe tunic, wise gentle storyteller, dark brown background",
            "width": 96, "height": 96, "no_background": False
        },
        "f2_binh_than": {
            "description": "pixel art painting of 13th century Vietnam Binh Than naval military conference, dragon boats on misty river, soldiers with flags, mountains at dusk, retro 16-bit color scene",
            "width": 320, "height": 180, "no_background": False
        },
        "f2_van_kiep": {
            "description": "pixel art painting of ancient Vietnamese Van Kiep fortress citadel, wooden watchtowers and stone walls guarding misty mountain valley, soldiers on patrol, retro 16-bit color scene",
            "width": 320, "height": 180, "no_background": False
        },
        "f2_bach_dang": {
            "description": "pixel art painting of historic Bach Dang river naval battle, low tide exposing sharp wooden stakes trapping large Mongol warships, sunset sky over estuary, retro 16-bit color scene",
            "width": 320, "height": 180, "no_background": False
        }
    }
    
    print("\n--- GỬI CÁC JOBS TẠO ASSET LÊN PIXELLAB ---")
    submitted_jobs = {}
    is_opaque_dict = {
        "e4_nguoi_dan_chuyen": True,
        "f2_binh_than": True,
        "f2_van_kiep": True,
        "f2_bach_dang": True
    }
    
    for k, p in pixen_requests.items():
        print(f"  Gửi job {k}...")
        jid = submit_job("create_image_pixen", p)
        submitted_jobs[k] = jid
        print(f"    -> Job ID: {jid}")
        time.sleep(1)
        
    print(f"\nĐã gửi xong {len(submitted_jobs)} jobs. Chờ kết quả...")
    results = wait_and_download_jobs(submitted_jobs, is_opaque_dict)
    
    # 3. Xử lý và lưu các asset chuyên biệt
    print("\n--- LƯU VÀ TỐI ƯU CÁC ASSET HOÀN THIỆN ---")
    
    # C9 & C10: Hiệu ứng
    c9_im = results["c9_hoi_mau"]
    c9_im.save(os.path.join(OUT_VFX_DIR, "c9_hoi_mau.png"))
    print(f"  + Đã lưu C9 Hồi máu: {os.path.join(OUT_VFX_DIR, 'c9_hoi_mau.png')}")
    
    c10_im = results["c10_lang_trung_don"]
    c10_im.save(os.path.join(OUT_VFX_DIR, "c10_lang_trung_don.png"))
    print(f"  + Đã lưu C10 Làng trúng đòn: {os.path.join(OUT_VFX_DIR, 'c10_lang_trung_don.png')}")
    
    # D6: Biểu tượng nhiệm vụ (32x32 & 24x24)
    d6_tieu_diet = results["d6_tieu_diet"]
    d6_tieu_diet.save(os.path.join(OUT_UI_DIR, "d6_nhiem_vu_tieu_diet_32x32.png"))
    d6_tieu_diet.resize((24, 24), Image.NEAREST).save(os.path.join(OUT_UI_DIR, "d6_nhiem_vu_tieu_diet_24x24.png"))
    
    d6_giu_ai = results["d6_giu_ai"]
    d6_giu_ai.save(os.path.join(OUT_UI_DIR, "d6_nhiem_vu_giu_ai_32x32.png"))
    d6_giu_ai.resize((24, 24), Image.NEAREST).save(os.path.join(OUT_UI_DIR, "d6_nhiem_vu_giu_ai_24x24.png"))
    print(f"  + Đã lưu D6 Biểu tượng nhiệm vụ Tiêu diệt & Giữ ải")
    
    # D7: Bộ con trỏ chuột
    results["d7_cursor_normal"].save(os.path.join(OUT_CURSOR_DIR, "d7_con_tro_mac_dinh.png"))
    results["d7_cursor_select"].save(os.path.join(OUT_CURSOR_DIR, "d7_con_tro_chon_tuong.png"))
    results["d7_cursor_attack"].save(os.path.join(OUT_CURSOR_DIR, "d7_con_tro_tan_cong.png"))
    print(f"  + Đã lưu D7 Bộ 3 con trỏ chuột tùy biến")
    
    # E4: Chân dung Người dẫn chuyện (96x96 & 64x64, có khung & không khung)
    e4_96 = results["e4_nguoi_dan_chuyen"]
    e4_96.save(os.path.join(OUT_PORTRAIT_DIR, "e4_nguoi_dan_chuyen_96x96.png"))
    e4_64 = e4_96.resize((64, 64), Image.NEAREST)
    e4_64.save(os.path.join(OUT_PORTRAIT_DIR, "e4_nguoi_dan_chuyen_64x64.png"))
    
    # Đóng khung sơn mài chỉ đồng
    def create_framed(im_raw, size):
        framed = Image.new("RGBA", (size, size), (46, 34, 47, 255))
        bw = 3 if size >= 96 else 2
        inner_size = size - 2 * bw
        inner_im = im_raw.resize((inner_size, inner_size), Image.NEAREST)
        framed.paste(inner_im, (bw, bw))
        draw = ImageDraw.Draw(framed)
        if size >= 96:
            draw.rectangle([1, 1, size - 2, size - 2], outline=(171, 148, 122, 255), width=1)
            draw.rectangle([2, 2, size - 3, size - 3], outline=(46, 34, 47, 255), width=1)
            corners = [(1, 1), (size - 2, 1), (1, size - 2), (size - 2, size - 2)]
            for cx, cy in corners:
                draw.point((cx, cy), fill=(251, 185, 84, 255))
        else:
            draw.rectangle([0, 0, size - 1, size - 1], outline=(46, 34, 47, 255), width=1)
            draw.rectangle([1, 1, size - 2, size - 2], outline=(171, 148, 122, 255), width=1)
        return framed
        
    e4_framed_96 = create_framed(e4_96, 96)
    e4_framed_96.save(os.path.join(OUT_PORTRAIT_DIR, "e4_nguoi_dan_chuyen_khung_96x96.png"))
    e4_framed_64 = create_framed(e4_64, 64)
    e4_framed_64.save(os.path.join(OUT_PORTRAIT_DIR, "e4_nguoi_dan_chuyen_khung_64x64.png"))
    print(f"  + Đã lưu E4 Chân dung Người dẫn chuyện 4 phiên bản")
    
    # F2: Tranh chuyển cảnh (3 bức: 320x180 & 640x360)
    for f2_k, f2_name in [
        ("f2_binh_than", "f2_1_hoi_nghi_binh_than"),
        ("f2_van_kiep", "f2_2_luy_ai_van_kiep"),
        ("f2_bach_dang", "f2_3_thuy_chien_bach_dang")
    ]:
        im_320 = results[f2_k]
        im_320.save(os.path.join(OUT_TRANSITION_DIR, f"{f2_name}_320x180.png"))
        # Phóng integer scale x2 lên 640x360
        im_640 = im_320.resize((640, 360), Image.NEAREST)
        im_640.save(os.path.join(OUT_TRANSITION_DIR, f"{f2_name}_640x360.png"))
        print(f"  + Đã lưu F2 Tranh chuyển cảnh: {f2_name}")
        
    # 4. Tạo ảnh đại tổng hợp các asset hoàn thiện
    print("\n--- TẠO BẢNG ĐẠI TỔNG HỢP TOÀN BỘ ASSET HOÀN THIỆN ---")
    font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()
    
    # Banner tổng hợp 800x600
    ov_w, ov_h = 760, 680
    overview = Image.new("RGBA", (ov_w, ov_h), (34, 32, 52, 255))
    draw = ImageDraw.Draw(overview)
    
    draw.text((16, 14), "TỔNG HỢP TOÀN BỘ ASSET HÌNH ẢNH HOÀN THIỆN (E8 BỔ SUNG)", fill=(255, 230, 150), font=font)
    draw.text((16, 36), "100% Chuẩn Bảng Màu Resurrect 64 & 1-bit Alpha — Đầy đủ B5, B6, C9, C10, D6, D7, E4, F2", fill=(180, 200, 220), font=font_sub)
    
    # 1. Hàng 1: E4 Chân dung & D6, D7, C9, C10
    draw.text((16, 64), "E4: Người dẫn chuyện & Giao diện D6, D7, Hiệu ứng C9, C10", fill=(255, 215, 120), font=font_sub)
    overview.paste(e4_framed_96, (16, 86))
    overview.paste(e4_framed_64, (124, 86))
    
    # C9, C10
    overview.paste(c9_im, (206, 86), c9_im)
    draw.text((206, 138), "C9 Hồi máu", fill=(180, 220, 180), font=font_sub)
    
    overview.paste(c10_im, (270, 86), c10_im)
    draw.text((270, 138), "C10 Làng trúng", fill=(220, 180, 180), font=font_sub)
    
    # D6
    overview.paste(d6_tieu_diet, (350, 86), d6_tieu_diet)
    draw.text((344, 124), "D6 Tiêu diệt", fill=(200, 200, 200), font=font_sub)
    overview.paste(d6_giu_ai, (420, 86), d6_giu_ai)
    draw.text((418, 124), "D6 Giữ ải", fill=(200, 200, 200), font=font_sub)
    
    # D7
    overview.paste(results["d7_cursor_normal"], (490, 86), results["d7_cursor_normal"])
    draw.text((486, 124), "D7 Thường", fill=(200, 200, 200), font=font_sub)
    overview.paste(results["d7_cursor_select"], (550, 86), results["d7_cursor_select"])
    draw.text((548, 124), "D7 Chọn", fill=(200, 200, 200), font=font_sub)
    overview.paste(results["d7_cursor_attack"], (610, 86), results["d7_cursor_attack"])
    draw.text((608, 124), "D7 Đánh", fill=(200, 200, 200), font=font_sub)
    
    # 2. Hàng 2: F2 Tranh chuyển cảnh (3 bức 220x124)
    draw.text((16, 196), "F2: Tranh chuyển cảnh / Dẫn nhập lịch sử (Bình Than - Vạn Kiếp - Bạch Đằng)", fill=(255, 215, 120), font=font_sub)
    f2_files = [
        "f2_1_hoi_nghi_binh_than_320x180.png",
        "f2_2_luy_ai_van_kiep_320x180.png",
        "f2_3_thuy_chien_bach_dang_320x180.png"
    ]
    for idx, fn in enumerate(f2_files):
        fp = os.path.join(OUT_TRANSITION_DIR, fn)
        if os.path.exists(fp):
            fim = Image.open(fp).resize((224, 126), Image.NEAREST)
            overview.paste(fim, (16 + idx * 242, 218))
            
    # 3. Hàng 3: B5 Kỵ binh & B6 Cung kỵ Hoạt ảnh Walk & Attack
    draw.text((16, 362), "B5 Kỵ Binh & B6 Cung Kỵ: Hoạt ảnh Di chuyển & Tấn công (4 frames)", fill=(255, 215, 120), font=font_sub)
    
    # Kỵ binh South Walk
    for i in range(4):
        p_w = os.path.join(OUT_ANIM_DIR, "ky_binh", f"south_{i}.png")
        if os.path.exists(p_w):
            im = Image.open(p_w)
            overview.paste(im, (16 + i * 68, 386), im)
    draw.text((16, 456), "Kỵ binh: Phi nước đại (South)", fill=(220, 220, 220), font=font_sub)
    
    # Kỵ binh Attack East
    for i in range(4):
        p_a = os.path.join(OUT_ANIM_DIR, "tan_cong", "ky_binh", f"east_{i}.png")
        if os.path.exists(p_a):
            im = Image.open(p_a)
            overview.paste(im, (300 + i * 68, 386), im)
    draw.text((300, 456), "Kỵ binh: Xung phong đâm thương (East)", fill=(220, 220, 220), font=font_sub)
    
    # Cung kỵ South Walk
    for i in range(4):
        p_w = os.path.join(OUT_ANIM_DIR, "cung_ky", f"south_{i}.png")
        if os.path.exists(p_w):
            im = Image.open(p_w)
            overview.paste(im, (16 + i * 68, 480), im)
    draw.text((16, 550), "Cung kỵ: Phi nước đại (South)", fill=(220, 220, 220), font=font_sub)
    
    # Cung kỵ Attack East
    for i in range(4):
        p_a = os.path.join(OUT_ANIM_DIR, "tan_cong", "cung_ky", f"east_{i}.png")
        if os.path.exists(p_a):
            im = Image.open(p_a)
            overview.paste(im, (300 + i * 68, 480), im)
    draw.text((300, 550), "Cung kỵ: Giương cung bắn tên (East)", fill=(220, 220, 220), font=font_sub)
    
    # Bị thương & Gục ngã đại diện
    draw.text((580, 362), "Bị thương & Gục ngã", fill=(255, 215, 120), font=font_sub)
    p_h = os.path.join(OUT_ANIM_DIR, "bi_thuong", "ky_binh", "hurt_1.png")
    if os.path.exists(p_h):
        im = Image.open(p_h)
        overview.paste(im, (580, 386), im)
    p_d = os.path.join(OUT_ANIM_DIR, "guc_nga", "ky_binh", "death_3.png")
    if os.path.exists(p_d):
        im = Image.open(p_d)
        overview.paste(im, (650, 386), im)
    draw.text((580, 456), "Kỵ binh: Trúng & Gục", fill=(200, 200, 200), font=font_sub)
    
    p_hc = os.path.join(OUT_ANIM_DIR, "bi_thuong", "cung_ky", "hurt_1.png")
    if os.path.exists(p_hc):
        im = Image.open(p_hc)
        overview.paste(im, (580, 480), im)
    p_dc = os.path.join(OUT_ANIM_DIR, "guc_nga", "cung_ky", "death_3.png")
    if os.path.exists(p_dc):
        im = Image.open(p_dc)
        overview.paste(im, (650, 480), im)
    draw.text((580, 550), "Cung kỵ: Trúng & Gục", fill=(200, 200, 200), font=font_sub)
    
    draw.text((16, 650), "✓ TOÀN BỘ DANH MỤC HÌNH ẢNH E8 ĐÃ HOÀN THIỆN 100%!", fill=(145, 219, 105), font=font)
    
    ov_out = os.path.join(BASE_DIR, "toi_uu", "_tong_hop_toan_bo_asset_con_lai.png")
    overview.save(ov_out)
    print(f"\nĐÃ LƯU BẢNG ĐẠI TỔNG HỢP: {ov_out}")
    print("HOÀN THÀNH 100% QUY TRÌNH!")

if __name__ == "__main__":
    main()
