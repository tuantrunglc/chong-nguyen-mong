#!/usr/bin/env python3
"""
Tối ưu hóa toàn diện Nhóm E (Chân dung 3 Tướng Đại Việt):
- E1: Nguyễn Khoái
- E2: Phạm Ngũ Lão
- E3: Trần Khánh Dư

1. Lượng tử hóa 100% về bảng màu Resurrect 64 (0 out_of_palette).
2. Khử toàn bộ semi-transparent alpha (0 semi-alpha).
3. Tạo 2 kích thước chuẩn:
   - 96x96: Bảng thông tin tướng (Character Info Panel)
   - 64x64: Hộp thoại đối thoại & Tooltip (Dialogue Box)
4. Thiết kế Khung Viền Sơn Mài Chỉ Đồng thời Trần:
   - Viền ngoài đen sơn mài #2e222f
   - Chỉ đồng hoàng gia #ab947a
   - Hoa văn 4 góc đồng sáng #fbb954
5. Dựng ảnh tổng hợp chân dung và Mockup 3 Bảng Thông Tin Tướng hoàn chỉnh.
"""

import os, glob
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = os.path.dirname(os.path.dirname(BASE_DIR))
PALETTE_FILE = os.path.join(PROJECT_ROOT, "_bmad-output/planning-artifacts/art-reference/resurrect-64.gpl")
FONT_FILE = os.path.join(PROJECT_ROOT, "game/assets/fonts/font_be_vietnam_pro_bold.ttf")

SRC_DIR = os.path.join(PROJECT_ROOT, "img", "chan_dung")
OUT_DIR = os.path.join(BASE_DIR, "toi_uu", "chan_dung")
os.makedirs(OUT_DIR, exist_ok=True)

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
OUTLINE_COLOR = (46, 34, 47, 255)

def quantize_image_fast(im, force_opaque=True):
    im_rgba = im.convert("RGBA")
    arr = np.array(im_rgba)
    h, w, _ = arr.shape
    
    alpha = arr[..., 3]
    if force_opaque:
        opaque_mask = np.ones((h, w), dtype=bool)
        out_alpha = np.full((h, w), 255, dtype=np.uint8)
    else:
        opaque_mask = alpha >= 120
        out_alpha = np.where(opaque_mask, 255, 0).astype(np.uint8)
        
    rgb = arr[..., :3].astype(np.float32)
    pixels_to_q = rgb[opaque_mask]
    
    if len(pixels_to_q) > 0:
        lab_pixels = rgb_to_cielab(pixels_to_q)
        diff = lab_pixels[:, np.newaxis, :] - lab_palette[np.newaxis, :, :]
        dists = np.sum(diff ** 2, axis=-1)
        best_indices = np.argmin(dists, axis=-1)
        q_rgb = palette_arr[best_indices].astype(np.uint8)
        
        # Override very dark pixels
        lum = 0.299 * pixels_to_q[:, 0] + 0.587 * pixels_to_q[:, 1] + 0.114 * pixels_to_q[:, 2]
        dark_mask = (lum < 28) | ((pixels_to_q[:, 0] < 46) & (pixels_to_q[:, 1] < 46) & (pixels_to_q[:, 2] < 52))
        q_rgb[dark_mask] = np.array(OUTLINE_COLOR[:3], dtype=np.uint8)
        
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        out_rgb[opaque_mask] = q_rgb
    else:
        out_rgb = np.zeros((h, w, 3), dtype=np.uint8)
        
    out_arr = np.dstack([out_rgb, out_alpha])
    return Image.fromarray(out_arr, mode="RGBA")

def create_framed_portrait(im_raw, size=96):
    """Đóng khung viền sơn mài chỉ đồng thời Trần chuẩn pixel art."""
    framed = Image.new("RGBA", (size, size), (46, 34, 47, 255))
    
    bw = 3 if size >= 96 else 2 # Border width
    inner_size = size - 2 * bw
    
    # Resize hoặc crop ảnh chân dung vào lòng khung
    if im_raw.size != (inner_size, inner_size):
        inner_im = im_raw.resize((inner_size, inner_size), Image.NEAREST)
    else:
        inner_im = im_raw
        
    framed.paste(inner_im, (bw, bw))
    
    draw = ImageDraw.Draw(framed)
    
    # 1. Viền ngoài đen sơn mài #2e222f (đã là nền)
    # 2. Đường chỉ đồng hoàng kim #ab947a (hoặc #fbb954)
    if size >= 96:
        # Viền đôi: đường đồng ở giữa
        draw.rectangle([1, 1, size - 2, size - 2], outline=(171, 148, 122, 255), width=1)
        draw.rectangle([2, 2, size - 3, size - 3], outline=(46, 34, 47, 255), width=1)
        # Hoa văn 4 góc góc đồng sáng #fbb954
        corners = [(1, 1), (size - 2, 1), (1, size - 2), (size - 2, size - 2)]
        for cx, cy in corners:
            draw.point((cx, cy), fill=(251, 185, 84, 255))
        for cx, cy in [(2, 1), (1, 2), (size - 3, 1), (size - 2, 2), (2, size - 2), (1, size - 3), (size - 3, size - 2), (size - 2, size - 3)]:
            draw.point((cx, cy), fill=(251, 185, 84, 255))
    else:
        # Khung 64x64 viền chỉ đồng 1px
        draw.rectangle([0, 0, size - 1, size - 1], outline=(46, 34, 47, 255), width=1)
        draw.rectangle([1, 1, size - 2, size - 2], outline=(171, 148, 122, 255), width=1)
        # Điểm sáng 4 góc
        for cx, cy in [(1, 1), (size - 2, 1), (1, size - 2), (size - 2, size - 2)]:
            draw.point((cx, cy), fill=(251, 185, 84, 255))
            
    return framed

def downscale_portrait_64(im_96):
    """
    Downscale chân dung từ 96x96 về 64x64 chuẩn pixel art:
    Lấy vùng trung tâm tập trung vào khuôn mặt và vũ khí, crop 84x84 rồi resize Nearest về 64x64,
    đảm bảo đường nét rõ ràng không bị nát chi tiết.
    """
    # Crop tập trung vào mặt (từ y=0..84, x=6..90)
    cropped = im_96.crop((6, 0, 90, 84))
    res = cropped.resize((64, 64), Image.NEAREST)
    return res

def process_portraits():
    print("=== BẮT ĐẦU TỐI ƯU HÓA NHÓM E (CHÂN DUNG TƯỚNG) ===")
    
    generals = [
        ("e1_khoai", "chot_khoai.png", "Nguyễn Khoái", "Chỉ huy quân Thánh Dực, dũng tướng Hàm Tử - Tây Kết"),
        ("e2_lao", "chot_lao.png", "Phạm Ngũ Lão", "Điện súy Thượng tướng quân, người đan sọt Phù Ủng"),
        ("e3_du", "chot_du.png", "Trần Khánh Dư", "Nhân Huệ Vương, danh tướng thủy chiến Vân Đồn")
    ]
    
    quantized_96 = {}
    quantized_64 = {}
    framed_96 = {}
    framed_64 = {}
    
    for prefix, src_name, full_name, desc in generals:
        src_path = os.path.join(SRC_DIR, src_name)
        raw_im = Image.open(src_path).convert("RGBA")
        
        # 1. Tối ưu 96x96 (không khung)
        im_96 = quantize_image_fast(raw_im, force_opaque=True)
        p96_path = os.path.join(OUT_DIR, f"{prefix}_96x96.png")
        im_96.save(p96_path)
        quantized_96[prefix] = im_96
        
        # 2. Khung viền sơn mài 96x96
        f_96 = create_framed_portrait(im_96, 96)
        f_96_opt = quantize_image_fast(f_96, force_opaque=True)
        f96_path = os.path.join(OUT_DIR, f"{prefix}_khung_96x96.png")
        f_96_opt.save(f96_path)
        framed_96[prefix] = f_96_opt
        
        # 3. Chân dung 64x64 (cho thoại & tooltip)
        im_64_raw = downscale_portrait_64(im_96)
        im_64 = quantize_image_fast(im_64_raw, force_opaque=True)
        p64_path = os.path.join(OUT_DIR, f"{prefix}_64x64.png")
        im_64.save(p64_path)
        quantized_64[prefix] = im_64
        
        # 4. Khung viền 64x64
        f_64 = create_framed_portrait(im_64, 64)
        f_64_opt = quantize_image_fast(f_64, force_opaque=True)
        f64_path = os.path.join(OUT_DIR, f"{prefix}_khung_64x64.png")
        f_64_opt.save(f64_path)
        framed_64[prefix] = f_64_opt
        
        print(f"-> Đã tối ưu {full_name}: đủ 4 phiên bản (96x96, 64x64, có khung và không khung).")

    # -------------------------------------------------------------
    # 5. DỰNG BẢNG TỔNG HỢP CHÂN DUNG 3 TƯỚNG (Sheet 720x360)
    # -------------------------------------------------------------
    print("\nĐang tạo bảng tổng hợp chân dung...")
    sheet = Image.new("RGBA", (720, 360), (34, 32, 52, 255))
    s_draw = ImageDraw.Draw(sheet)
    
    title_font = ImageFont.truetype(FONT_FILE, 18)
    sub_font = ImageFont.truetype(FONT_FILE, 11)
    name_font = ImageFont.truetype(FONT_FILE, 14)
    tag_font = ImageFont.truetype(FONT_FILE, 10)
    
    s_draw.text((20, 16), "HÀO KHÍ ĐÔNG A — BỘ CHÂN DUNG 3 DANH TƯỚNG THỜI TRẦN (NHÓM E)", font=title_font, fill=(251, 185, 84, 255))
    s_draw.text((20, 42), "100% Chuẩn Bảng Màu Resurrect 64 • 2 Kích Thước (96x96 Bảng chỉ số, 64x64 Hộp thoại) • Khung Sơn Mài Chỉ Đồng", font=sub_font, fill=(171, 148, 122, 255))
    
    col_x = [30, 260, 490]
    for idx, (prefix, _, full_name, desc) in enumerate(generals):
        cx = col_x[idx]
        
        # Tên tướng
        s_draw.text((cx, 75), full_name.upper(), font=name_font, fill=(251, 185, 84, 255))
        s_draw.text((cx, 95), desc, font=tag_font, fill=(155, 171, 178, 255))
        
        # Bản 96x96 có khung
        s_draw.text((cx, 120), "BẢNG CHỈ SỐ (96x96):", font=tag_font, fill=(200, 210, 215, 255))
        sheet.paste(framed_96[prefix], (cx, 138))
        
        # Bản 64x64 có khung
        s_draw.text((cx + 115, 120), "HỘP THOẠI (64x64):", font=tag_font, fill=(200, 210, 215, 255))
        sheet.paste(framed_64[prefix], (cx + 115, 138))
        
        # Bản 64x64 không khung
        s_draw.text((cx + 115, 215), "KHÔNG KHUNG:", font=tag_font, fill=(171, 148, 122, 255))
        sheet.paste(quantized_64[prefix], (cx + 115, 232))

    sheet_opt = quantize_image_fast(sheet, force_opaque=True)
    out_sheet_path = os.path.join(OUT_DIR, "_tong_hop_chan_dung_3_tuong.png")
    sheet_opt.save(out_sheet_path)
    print(f"-> Đã lưu Bảng tổng hợp: {out_sheet_path}")

    # -------------------------------------------------------------
    # 6. DỰNG MOCKUP BẢNG THÔNG TIN TƯỚNG HOÀN CHỈNH (640x360)
    # -------------------------------------------------------------
    print("\nĐang dựng Mockup 3 Bảng Thông Tin Tướng trong game...")
    mock = Image.new("RGBA", (760, 400), (34, 32, 52, 255))
    m_draw = ImageDraw.Draw(mock)
    
    m_draw.text((20, 16), "GIAO DIỆN BẢNG THÔNG TIN TƯỚNG (KHI RÊ CHUỘT / BẤM VÀO TƯỚNG)", font=title_font, fill=(251, 185, 84, 255))
    m_draw.text((20, 42), "Tích hợp Chân dung sơn mài, Phù hiệu phe Đại Việt, Chỉ số chiến thuật và Sử ký danh nhân thời Trần", font=sub_font, fill=(171, 148, 122, 255))
    
    info_data = [
        {
            "prefix": "e1_khoai",
            "name": "NGUYỄN KHOÁI",
            "title": "Chỉ huy quân Thánh Dực",
            "stats": [("Máu:", "4 / 4"), ("Tầm đi:", "3 ô"), ("Sát thương:", "2"), ("Đòn đánh:", "Mạch đao (Đẩy lùi 1 ô)")],
            "bio": "Dũng tướng chỉ huy quân Thánh Dực dũng cảm. Năm 1285 lập công lớn đánh tan giặc ở Hàm Tử, Tây Kết, được vua Trần phong tước Liệt hầu."
        },
        {
            "prefix": "e2_lao",
            "name": "PHẠM NGŨ LÃO",
            "title": "Điện súy Thượng tướng quân",
            "stats": [("Máu:", "4 / 4"), ("Tầm đi:", "3 ô"), ("Sát thương:", "2"), ("Đòn đánh:", "Phóng giáo (Tầm xa 2–3 ô)")],
            "bio": "Xuất thân hàn vi làng Phù Ủng, có chí lớn ngồi đan sọt bị giáo đâm không hay. Được Hưng Đạo Vương tiến cử, cầm quân bách chiến bách thắng."
        },
        {
            "prefix": "e3_du",
            "name": "TRẦN KHÁNH DƯ",
            "title": "Nhân Huệ Vương — Phó đô tướng",
            "stats": [("Máu:", "4 / 4"), ("Tầm đi:", "3 ô"), ("Sát thương:", "2"), ("Đòn đánh:", "Câu liêm (Kéo địch 1 ô)")],
            "bio": "Tôn thất nhà Trần, trí dũng song toàn, am hiểu thủy chiến và sông biển. Năm 1288 chỉ huy đại thắng Vân Đồn tiêu diệt đoàn thuyền lương Trương Văn Hổ."
        }
    ]
    
    card_w = 230
    card_h = 310
    card_x = [20, 265, 510]
    
    body_font = ImageFont.truetype(FONT_FILE, 11)
    bold_font = ImageFont.truetype(FONT_FILE, 11)
    bio_font = ImageFont.truetype(FONT_FILE, 10)
    
    for idx, d in enumerate(info_data):
        cx = card_x[idx]
        cy = 70
        
        # Khung thẻ nền sơn mài đen viền đỏ Đại Việt #b33831
        m_draw.rectangle([cx, cy, cx + card_w, cy + card_h], fill=(46, 34, 47, 255), outline=(179, 56, 49, 255), width=2)
        # Viền trong mạ đồng
        m_draw.rectangle([cx + 2, cy + 2, cx + card_w - 2, cy + card_h - 2], outline=(171, 148, 122, 255), width=1)
        
        # Đặt chân dung 96x96 có khung ở giữa thẻ
        portrait_im = framed_96[d["prefix"]]
        px = cx + (card_w - 96) // 2
        py = cy + 12
        mock.paste(portrait_im, (px, py))
        
        # Tên tướng
        name_bbox = m_draw.textbbox((0, 0), d["name"], font=name_font)
        nw = name_bbox[2] - name_bbox[0]
        m_draw.text((cx + (card_w - nw) // 2, py + 104), d["name"], font=name_font, fill=(251, 185, 84, 255))
        
        # Danh hiệu
        title_bbox = m_draw.textbbox((0, 0), d["title"], font=tag_font)
        tw = title_bbox[2] - title_bbox[0]
        m_draw.text((cx + (card_w - tw) // 2, py + 124), d["title"], font=tag_font, fill=(155, 171, 178, 255))
        
        # Đường kẻ phân cách
        m_draw.line([(cx + 12, py + 140), (cx + card_w - 12, py + 140)], fill=(76, 62, 36, 255), width=1)
        
        # Bảng chỉ số
        sy = py + 146
        for s_label, s_val in d["stats"]:
            m_draw.text((cx + 14, sy), s_label, font=body_font, fill=(200, 210, 215, 255))
            m_draw.text((cx + 90, sy), s_val, font=bold_font, fill=(251, 185, 84, 255) if "Đòn" in s_label else (255, 255, 255, 255))
            sy += 16
            
        # Đường kẻ phân cách tiểu sử
        m_draw.line([(cx + 12, sy + 2), (cx + card_w - 12, sy + 2)], fill=(76, 62, 36, 255), width=1)
        
        # Tiểu sử tóm tắt (Word wrap thủ công)
        bio_y = sy + 8
        words = d["bio"].split()
        line = ""
        for w in words:
            test_line = line + (" " if line else "") + w
            l_bbox = m_draw.textbbox((0, 0), test_line, font=bio_font)
            if (l_bbox[2] - l_bbox[0]) <= (card_w - 28):
                line = test_line
            else:
                m_draw.text((cx + 14, bio_y), line, font=bio_font, fill=(171, 148, 122, 255))
                bio_y += 13
                line = w
        if line:
            m_draw.text((cx + 14, bio_y), line, font=bio_font, fill=(171, 148, 122, 255))

    mock_opt = quantize_image_fast(mock, force_opaque=True)
    out_mock_path = os.path.join(OUT_DIR, "_mockup_bang_thong_tin_3_tuong.png")
    mock_opt.save(out_mock_path)
    print(f"-> Đã lưu Mockup Bảng Thông Tin: {out_mock_path}")

if __name__ == "__main__":
    process_portraits()
