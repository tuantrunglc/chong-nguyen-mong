# Nền bàn đất liền đầy đủ: cỏ–sông lát góc (lat_o.py), hầm chông, ô ải (mặt trên + mặt trước 8 px), kho đã cháy,
# và viền rừng rậm quanh bàn. Dùng: python3 nen_dat_lien.py <tran.json> <ra.png> [x,y kho cháy ...]
import json, random, subprocess, sys, os
from PIL import Image, ImageEnhance
H = os.path.dirname(os.path.abspath(__file__)); P = os.path.dirname(H); T = 64; M = 64
tran, out_path = sys.argv[1], sys.argv[2]
rows = [r.split() for r in json.load(open(tran))['dia_hinh']]; R, C = len(rows), len(rows[0])
tmp = out_path + '.lat.png'
subprocess.run([sys.executable, f'{H}/lat_o.py', f'{P}/o_tier1/co_song', tran, '.#^ADL', tmp], check=True)
lat = Image.open(tmp).convert('RGBA'); os.remove(tmp)
def tile(d, i): return Image.open(f'{P}/{d}/tile_{i}.png').convert('RGBA')
r = random.Random(5)
W, Hh = C*T + 2*M, R*T + 2*M
out = Image.new('RGBA', (W, Hh))
for y in range(0, Hh, T):
    for x in range(0, W, T):
        out.alpha_composite(tile('nhom_a/vien_chong', r.choice([4, 5, 6, 7, 4, 5, 8, 10])), (x, y))
out = ImageEnhance.Brightness(out).enhance(0.7)
out.alpha_composite(lat, (M - T//2, M - T//2))
for y in range(R):
    for x in range(C):
        px, py = M + x*T, M + y*T
        if rows[y][x] == '^':
            out.alpha_composite(tile('nhom_a/vien_chong', r.choice([0, 1, 2, 3])), (px, py))
        if rows[y][x] == 'A':
            top = tile('nhom_a/o_ai2', 0)
            # Mặt trên nâng lên 8 px (PASS_HEIGHT), mặt trước là 8 hàng cuối làm tối.
            front = ImageEnhance.Brightness(top.crop((0, 56, 64, 64))).enhance(0.5)
            out.alpha_composite(front, (px, py + 56)); out.alpha_composite(top, (px, py - 8))
for xy in sys.argv[3:]:
    x, y = map(int, xy.split(',')); k = Image.open(f'{P}/nhom_a/kho_chay_b.png').convert('RGBA')
    out.alpha_composite(k, (M + x*T, M + y*T + T - k.height + 4))
out.convert('RGB').save(out_path)
