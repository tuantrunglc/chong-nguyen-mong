# Lát nền bàn bằng bộ ô chuyển tiếp góc (create_tiles_pro, tile_feature=tileset; mặt nạ NW<<3|NE<<2|SW<<1|SE,
# bit bật = địa hình thứ nhất). Vẽ trên lưới lệch nửa ô: mỗi ô vẽ có 4 góc là 4 ô luật quanh nó, nên sông
# rộng 1 ô vẫn hiện thành một dải. Ảnh ra rộng (cột+1)×64, cao (hàng+1)×64: canh giữa quanh bàn.
# Dùng: python3 lat_o.py <thư mục bộ ô> <tran.json> <ký tự địa hình thứ nhất> <ra.png> [ký tự:ảnh dán giữa ô ...]
import json, sys
from PIL import Image
T = 64
tiles = {i: Image.open(f'{sys.argv[1]}/tile_{i}.png').convert('RGBA') for i in range(16)}
rows = [r.split() for r in json.load(open(sys.argv[2]))['dia_hinh']]
first = set(sys.argv[3]); R, C = len(rows), len(rows[0])
def is_first(x, y):
    x = min(C-1, max(0, x)); y = min(R-1, max(0, y)); return rows[y][x] in first
out = Image.new('RGBA', ((C+1)*T, (R+1)*T))
for vy in range(R+1):
    for vx in range(C+1):
        m = (is_first(vx-1, vy-1) << 3) | (is_first(vx, vy-1) << 2) | (is_first(vx-1, vy) << 1) | is_first(vx, vy)
        out.alpha_composite(tiles[m], (vx*T, vy*T))
for arg in sys.argv[5:]:
    ch, path = arg.split(':', 1); st = Image.open(path).convert('RGBA')
    for y in range(R):
        for x in range(C):
            if rows[y][x] == ch: out.alpha_composite(st, (x*T + T//2, y*T + T//2))
out.convert('RGB').save(sys.argv[4])
