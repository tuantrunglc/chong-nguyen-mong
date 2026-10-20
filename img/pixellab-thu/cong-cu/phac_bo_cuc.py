# Vẽ phác bố cục bản đồ theo lưới ô 64 px để PixelLab vẽ đè (create_image_pixflux, init_image_strength 40).
# Dùng: python3 phac_bo_cuc.py <tran.json> <ra.png>. '#' = đảo đá, '.' = bãi cát, '~' và 'L' = nước.
import json, math, sys
from PIL import Image
L = [r.replace(' ', '') for r in json.load(open(sys.argv[1]))['dia_hinh']]
R, C = len(L), len(L[0]); W, H = C * 64, R * 64
def kind(x, y): return L[min(R-1, max(0, y // 64))][min(C-1, max(0, x // 64))]
im = Image.new('RGB', (W, H)); px = im.load()
for y in range(H):
    for x in range(W):
        dx = int(6 * math.sin(y / 9.0 + x / 23.0)); dy = int(6 * math.cos(x / 11.0 + y / 29.0))
        X, Y = x + dx, y + dy; k = kind(X, Y)
        if k == '#': c = (98, 85, 101) if kind(X, Y + 24) != '#' else (84, 126, 100)
        elif k == '.': c = (171, 148, 122)
        else:
            near = any(kind(x + a, y + b) in '#.' for a, b in ((10, 0), (-10, 0), (0, 10), (0, -10)))
            c = (11, 138, 143) if near else (11, 94, 101)
        px[x, y] = c
im.save(sys.argv[2])
