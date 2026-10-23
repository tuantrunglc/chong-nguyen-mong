#!/usr/bin/env python3
"""
Tạo Filmstrip và GIF Preview Chèo Thuyền Trên Sông:
- Filmstrip 4 frames cạnh nhau phóng to x3 kèm nhãn từng pha chèo thuyền.
- GIF Preview trên nền nước sông Bạch Đằng (x3) để thấy rõ bọt sóng và vệt rẽ sóng.
"""

import os
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
OUT_THUYEN = os.path.join(BASE_DIR, "toi_uu", "thuyen")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")
CONV_DIR = "/home/trung.nguyen11/.gemini/antigravity-cli/brain/02722460-1e37-46a7-ad1f-65c92d14f54b"

tile_water = Image.open(os.path.join(BASE_DIR, "toi_uu/dia_hinh/o_nen/tile_0.png")).convert("RGBA")

frames = []
for i in range(4):
    p = os.path.join(OUT_THUYEN, f"thuyen_cheo_{i}.png")
    frames.append(Image.open(p).convert("RGBA"))

# 1. TẠO FILMSTRIP 4 FRAMES (PHÓNG TO X3)
font = ImageFont.truetype(FONT_FILE, 13) if os.path.exists(FONT_FILE) else ImageFont.load_default()
font_sub = ImageFont.truetype(FONT_FILE, 11) if os.path.exists(FONT_FILE) else ImageFont.load_default()

fw = 192
fh = 192
pad = 16
total_w = pad * 5 + fw * 4
total_h = fh + 90

strip = Image.new("RGBA", (total_w, total_h), (34, 32, 52, 255))
draw = ImageDraw.Draw(strip)

phases = [
    ("Frame 0: Vươn Chèo (Reach)", "Mái chèo vươn về trước mũi thuyền, lưỡi chèo lướt sát mặt nước"),
    ("Frame 1: Cắm Chèo (Catch)", "Mái chèo cắm ngập nước, bọt nước tròn quanh lưỡi chèo"),
    ("Frame 2: Gạt Nước (Power Stroke)", "Quét mạnh về sau đẩy thuyền, vệt sóng cuộn sủi bọt trắng xóa"),
    ("Frame 3: Nhấc Chèo (Release & Wake)", "Nhấc chèo thu về, vệt rẽ sóng chữ V ở đuôi thuyền khi lướt tới")
]

for i, (title, desc) in enumerate(phases):
    x = pad + i * (fw + pad)
    y = 16
    
    # Nền nước sông cho từng frame
    w_box = Image.new("RGBA", (fw, fh), (18, 78, 137, 255))
    tile_w3 = tile_water.resize((fw, fh), Image.NEAREST)
    w_box.alpha_composite(tile_w3, (0, 0))
    
    f3 = frames[i].resize((fw, fh), Image.NEAREST)
    w_box.alpha_composite(f3, (0, 0))
    
    strip.alpha_composite(w_box, (x, y))
    draw.rectangle([x - 1, y - 1, x + fw, y + fh], outline=(90, 105, 136, 255), width=1)
    
    draw.text((x + fw // 2, y + fh + 8), title, fill=(255, 230, 150, 255), font=font, anchor="mt")
    # wrap desc
    draw.text((x + fw // 2, y + fh + 26), desc[:35], fill=(180, 200, 220, 255), font=font_sub, anchor="mt")
    if len(desc) > 35:
        draw.text((x + fw // 2, y + fh + 40), desc[35:], fill=(180, 200, 220, 255), font=font_sub, anchor="mt")

strip_out = os.path.join(OUT_THUYEN, "thuyen_cheo_filmstrip.png")
strip.save(strip_out)
import shutil
shutil.copyfile(strip_out, os.path.join(CONV_DIR, "thuyen_cheo_filmstrip.png"))
print(f"Đã lưu Filmstrip: {strip_out}")

# 2. TẠO GIF PREVIEW TRÊN NƯỚC SÔNG (X3)
water_frames = []
for i in range(4):
    wf = Image.new("RGBA", (192, 192), (18, 78, 137, 255))
    wf.alpha_composite(tile_water.resize((192, 192), Image.NEAREST), (0, 0))
    wf.alpha_composite(frames[i].resize((192, 192), Image.NEAREST), (0, 0))
    water_frames.append(wf)

gif_water = os.path.join(OUT_THUYEN, "thuyen_cheo_tren_song_3x.gif")
water_frames[0].save(
    gif_water,
    save_all=True,
    append_images=water_frames[1:],
    duration=200,
    loop=0
)
shutil.copyfile(gif_water, os.path.join(CONV_DIR, "thuyen_cheo_tren_song_3x.gif"))
print(f"Đã lưu GIF trên sông: {gif_water}")
