#!/usr/bin/env python3
"""
Tạo bộ ô nền rừng rậm 64x64 liền mạch (seamless tiling), tương phản thấp cho game Chống Nguyên Mông.
Đáp ứng đầy đủ các tiêu chí thiết kế:
1. Kích thước 64x64, PNG RGBA, 100% bảng màu Resurrect 64 chuẩn của dự án.
2. Lát liền mạch 100% theo cả 2 trục X và Y (toroidal wrapping).
3. Tương phản thấp (Low contrast): tông xanh lục sẫm rừng già nhiệt đới (#165A4C, #374E4A), tối hơn cỏ bàn cờ (#547E64).
4. Không có vật thể lớn hoặc chi tiết nổi bật ở giữa ô gây cảm giác lặp bàn cờ ca-rô.
5. Cấu trúc khóm tán lá hữu cơ (organic foliage leaf clumps) với hướng đón sáng Tây-Bắc đồng nhất với sa bàn.
6. Hỗ trợ cả 1 ô đơn liền mạch và bộ 4 biến thể chia sẻ dải biên (Cross-variant seamless) ghép tự do.
"""

import math
import os
import random
from PIL import Image

W, H = 64, 64

# Bảng màu Resurrect 64 chuẩn dùng cho viền rừng rậm
C_SHADOW = (46, 34, 47, 255)   # #2E222F: bóng kẽ lá sâu
C_DARK   = (49, 54, 56, 255)   # #313638: viền râm mát
C_BASE   = (22, 90, 76, 255)   # #165A4C: xanh lục sẫm rừng già nhiệt đới Đại Việt (chủ đạo)
C_MOSS   = (55, 78, 74, 255)   # #374E4A: xanh rêu trầm (tán mờ)
C_BARK   = (76, 62, 36, 255)   # #4C3E24: nâu mùn đất / cành lá rụng
C_LEAF   = (35, 144, 99, 255)  # #239063: xanh lá cây đón nắng nhẹ

def make_variant(seed, border_seed=12345):
    rng = random.Random(seed)
    border_rng = random.Random(border_seed)
    
    # 1. Nền hòa trộn vi mô checkerboard êm dịu
    canvas = [[C_BASE for _ in range(W)] for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if (x + y) % 2 == 0:
                canvas[y][x] = C_MOSS
            else:
                canvas[y][x] = C_BASE
                
    # 2. Khóm lá biên (Border clumps) - CỐ ĐỊNH CHO TẤT CẢ BIẾN THỂ
    # Đặt ở các mép [0..8] và [55..63] với cùng một seed biên để ghép chéo bất kỳ
    border_clumps = []
    for _ in range(16):
        side = border_rng.choice(['top', 'bottom', 'left', 'right'])
        if side == 'top':
            cx = border_rng.uniform(0, 64)
            cy = border_rng.uniform(0, 8)
        elif side == 'bottom':
            cx = border_rng.uniform(0, 64)
            cy = border_rng.uniform(56, 64)
        elif side == 'left':
            cx = border_rng.uniform(0, 8)
            cy = border_rng.uniform(0, 64)
        else:
            cx = border_rng.uniform(56, 64)
            cy = border_rng.uniform(0, 64)
        rad = border_rng.uniform(4.5, 6.5)
        border_clumps.append((cx, cy, rad))
        
    # 3. Khóm lá trong lòng ô (Internal clumps) - RIÊNG TỪNG BIẾN THỂ
    inner_clumps = []
    for _ in range(22):
        cx = rng.uniform(8, 56)
        cy = rng.uniform(8, 56)
        rad = rng.uniform(4.5, 7.5)
        inner_clumps.append((cx, cy, rad))
        
    all_clumps = border_clumps + inner_clumps
    all_clumps.sort(key=lambda c: c[1])
    
    for cx, cy, rad in all_clumps:
        for ox in [-64, 0, 64]:
            for oy in [-64, 0, 64]:
                tx = cx + ox
                ty = cy + oy
                x_min = max(0, int(tx - rad - 2))
                x_max = min(63, int(tx + rad + 2))
                y_min = max(0, int(ty - rad - 2))
                y_max = min(63, int(ty + rad + 2))
                
                for py in range(y_min, y_max + 1):
                    for px in range(x_min, x_max + 1):
                        dx = px - tx
                        dy = py - ty
                        dist = math.hypot(dx, dy)
                        if dist > rad:
                            continue
                        theta = math.atan2(dy, dx)
                        r_var = rad * (1.0 + 0.15 * math.cos(4 * theta))
                        if dist > r_var:
                            continue
                        # Shading: bóng dưới Đông-Nam (dx > 0, dy > 0), sáng Tây-Bắc (dx < 0, dy < 0)
                        if dist > r_var * 0.75 and dy > 0.4:
                            canvas[py][px] = C_SHADOW
                        elif dist > r_var * 0.85:
                            canvas[py][px] = C_DARK if (px + py) % 2 == 0 else C_BASE
                        elif dx < -0.4 and dy < -0.4 and dist < r_var * 0.5:
                            canvas[py][px] = C_LEAF if (px * 3 + py * 7) % 5 == 0 else C_BASE
                        elif dist < r_var * 0.6:
                            canvas[py][px] = C_BASE
                        else:
                            canvas[py][px] = C_MOSS
                            
    img = Image.new('RGBA', (W, H))
    for y in range(H):
        for x in range(W):
            img.putpixel((x, y), canvas[y][x])
    return img

def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    vat_can_dir = os.path.join(repo_root, "img", "pixellab-thu", "toi_uu", "dia_hinh", "vat_can")
    tex_dia_hinh_dir = os.path.join(repo_root, "game", "assets", "textures", "dia_hinh")
    
    os.makedirs(vat_can_dir, exist_ok=True)
    os.makedirs(tex_dia_hinh_dir, exist_ok=True)
    
    print("Tạo 4 biến thể rừng rậm hữu cơ liền mạch...")
    tiles = [make_variant(seed=101 + i * 777) for i in range(4)]
    
    # 1. Lưu vào img/pixellab-thu/toi_uu/dia_hinh/vat_can/
    for i, t in enumerate(tiles):
        p = os.path.join(vat_can_dir, f"a8_vien_rung_{i}.png")
        t.save(p)
        print(f"Đã lưu: {p}")
        
    # 2. Lưu vào game/assets/textures/dia_hinh/
    for i, t in enumerate(tiles):
        p = os.path.join(tex_dia_hinh_dir, f"tex_vien_rung_{i}.png")
        t.save(p)
        print(f"Đã lưu: {p}")
        
    # 3. Lưu bản ô đơn tex_vien_rung_don.png (dùng biến thể 0)
    p_don = os.path.join(tex_dia_hinh_dir, "tex_vien_rung_don.png")
    tiles[0].save(p_don)
    print(f"Đã lưu ô đơn: {p_don}")

if __name__ == "__main__":
    main()
