# Vẽ ô và quân pixel art tạm (bảng Resurrect 64) cho ảnh mẫu. Không thuộc repo.
import random, sys, colorsys, math
from PIL import Image
GPL, PNL, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
P = []
for line in open(GPL):
    parts = line.split('\t')
    if len(parts) >= 3 and parts[0].strip().isdigit():
        P.append(tuple(int(x) for x in parts[:3]))
def c(i): return P[i] + (255,)
T = 64

def noise_tile(base, specks, seed, size=T):
    r = random.Random(seed)
    im = Image.new('RGBA', (size, size), c(base))
    px = im.load()
    for idx, count, blob in specks:
        for _ in range(count):
            x, y = r.randrange(size), r.randrange(size)
            for dx, dy in blob:
                px[(x+dx) % size, (y+dy) % size] = c(idx)
    return im

TUFT = [(0,0),(1,-1),(2,0)]
DOT = [(0,0)]
DASH = [(0,0),(1,0)]
CLUMP = [(0,0),(1,0),(0,1),(1,1),(2,1),(1,2)]

def grass(seed, dirt=False):
    sp = [(35, 70, DOT), (35, 18, TUFT), (37, 40, DOT), (37, 10, TUFT), (25, 12, DASH)]
    im = noise_tile(36, sp, seed)
    if dirt:
        r = random.Random(seed+99); px = im.load()
        cx, cy = r.randrange(16, 48), r.randrange(16, 48)
        for y in range(T):
            for x in range(T):
                d = math.hypot((x-cx)/1.4, y-cy) + r.random()*4
                if d < 11: px[x, y] = c(24 if d > 8 else 4) if d > 9.5 else c(3 if r.random() < .3 else 24)
    return im

def water(seed, bank):
    sp = [(35, 30, DASH), (40, 26, [(0,0),(1,0),(2,0)]), (41, 6, DOT)]
    im = noise_tile(39, sp, seed); px = im.load()
    if bank:
        r = random.Random(seed)
        for x in range(T):
            h = 7 + (1 if r.random() < .3 else 0)
            for y in range(h):
                px[x, y] = c(36 if y == 0 else 37 if y == 1 else 24 if y < h-1 else 0)
            px[x, h] = c(35)
    return im

def blob(px, cx, cy, rad, cols, r, w, h):
    for y in range(int(cy-rad-1), int(cy+rad+2)):
        for x in range(int(cx-rad-1), int(cx+rad+2)):
            if 0 <= x < w and 0 <= y < h:
                d = math.hypot(x-cx, (y-cy)*1.1)
                if d <= rad - r.random()*1.2:
                    lit = math.hypot(x-(cx-rad*.35), y-(cy-rad*.45)) / rad + r.random()*.15
                    i = cols[0] if lit < .55 else cols[1] if lit < 1.05 else cols[2]
                    px[x, y] = c(i)

def forest(seed):
    w, h = 64, 92; r = random.Random(seed)
    im = Image.new('RGBA', (w, h), (0,0,0,0)); px = im.load()
    # bóng dưới gốc
    for y in range(h-14, h-2):
        for x in range(4, 60):
            if math.hypot((x-32)/28, (y-(h-8))/6) < 1: px[x, y] = (20, 30, 25, 110)
    for tx in (18, 44, 31):
        for y in range(h-22, h-6):
            for x in range(tx-2, tx+2): px[x, y] = c(24 if x < tx+1 else 0)
    for cx, cy, rad in [(18, 46, 15), (45, 44, 15), (31, 28, 17), (32, 54, 13)]:
        blob(px, cx, cy, rad, [29, 36, 37][::-1] and [37, 36, 29], r, w, h)
    for cx, cy, rad in [(18, 46, 15), (45, 44, 15), (31, 28, 17), (32, 54, 13)]:
        pass
    outline(im, 0)
    return im

def outline(im, idx):
    px = im.load(); w, h = im.size; edge = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] == 0:
                for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
                    X, Y = x+dx, y+dy
                    if 0 <= X < w and 0 <= Y < h and px[X, Y][3] == 255:
                        edge.append((x, y)); break
    for x, y in edge: px[x, y] = c(idx)

def hut(seed, granary=False):
    w, h = 64, 84; r = random.Random(seed)
    im = Image.new('RGBA', (w, h), (0,0,0,0)); px = im.load()
    for y in range(h-12, h-2):
        for x in range(2, 62):
            if math.hypot((x-32)/30, (y-(h-7))/5) < 1: px[x, y] = (20, 30, 25, 110)
    # tường
    wall_top, wall_bot = (h-34, h-8) if not granary else (h-30, h-14)
    for y in range(wall_top, wall_bot):
        for x in range(10, 54):
            px[x, y] = (c(24) if x in (10, 11, 52, 53) or (x % 11 == 0) else c(4 if r.random() < .15 else 3)) if not granary else c(3 if x % 7 else 24)
    if granary:
        for lx in (12, 30, 50):
            for y in range(wall_bot, h-6):
                for x in (lx, lx+1): px[x, y] = c(24)
        # bao lúa
        for sx in (16, 28, 40):
            blob(px, sx, h-20, 5, [38, 4, 3], r, w, h)
    else:
        for y in range(wall_bot-14, wall_bot):
            for x in range(28, 36): px[x, y] = c(0)
    # mái tranh
    roof_top, roof_bot = (h-70, wall_top+2) if not granary else (h-66, wall_top+2)
    for y in range(roof_top, roof_bot):
        t = (y - roof_top) / (roof_bot - roof_top)
        half = 8 + t * 26
        for x in range(int(32-half), int(32+half)):
            if 0 <= x < w:
                stripe = (x + y*2) % 5 == 0
                base = 23 if t < .25 else 4 if t < .75 else 3
                if granary: base = 4 if t < .5 else 3
                px[x, y] = c(38 if stripe and t < .7 else base if not stripe else 3)
    for x in range(4, 60):
        if px[x, roof_bot-1][3]: px[x, roof_bot-1] = c(24)
    outline(im, 0)
    return im

def spikes(seed):
    im = grass(seed); px = im.load(); r = random.Random(seed)
    for y in range(10, 56):
        for x in range(8, 56):
            if math.hypot((x-32)/24, (y-33)/22) < 1 - r.random()*.05:
                px[x, y] = c(0 if math.hypot((x-32)/24, (y-33)/22) < .8 else 24)
    for sx, sy in [(20,26),(32,22),(44,26),(24,40),(38,40),(30,32),(44,38),(18,36)]:
        for k in range(9):
            px[sx, sy-k] = c(26 if k < 6 else 33); px[sx+1, sy-k] = c(25)
    return im

def pal_nearest(rgb):
    return min(P, key=lambda p: (p[0]-rgb[0])**2*2 + (p[1]-rgb[1])**2*3 + (p[2]-rgb[2])**2)

def palettize(im):
    im = im.convert('RGBA'); px = im.load()
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r_, g, b, a = px[x, y]
            if a > 0: px[x, y] = pal_nearest((r_, g, b)) + (255 if a > 100 else 0,)
    return im

def to_nguyen(im):
    im = im.convert('RGBA'); px = im.load()
    blue = [44, 45, 6, 7]; steel = [1, 2, 7, 8]
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            r_, g, b, a = px[x, y]
            if a == 0: continue
            hh, l, s = colorsys.rgb_to_hls(r_/255, g/255, b/255)
            if s > .25 and (hh < .045 or hh > .9):     # đỏ -> xám xanh
                px[x, y] = c(blue[min(3, int(l*5))])
            elif s > .3 and .045 <= hh < .16 and l < .6 and not (l > .45 and s < .5):  # vàng đồng -> thép
                px[x, y] = c(steel[min(3, int(l*5))])
    return im

for i in range(3): grass(10+i, dirt=(i == 2)).save(f'{OUT}/dat_{i}.png')
water(5, False).save(f'{OUT}/song.png'); water(6, True).save(f'{OUT}/song_bo.png')
forest(3).save(f'{OUT}/rung.png'); hut(4).save(f'{OUT}/lang.png'); hut(7, True).save(f'{OUT}/kho.png')
spikes(8).save(f'{OUT}/chong.png')
lao = palettize(Image.open(PNL)); lao.save(f'{OUT}/lao.png')
palettize(to_nguyen(Image.open(PNL))).save(f'{OUT}/nguyen.png')
# bảng xem nhanh
sheet = Image.new('RGBA', (64*12, 100), c(34))
for k, n in enumerate(['dat_0','dat_1','dat_2','song','song_bo','chong','rung','lang','kho','lao','nguyen']):
    s = Image.open(f'{OUT}/{n}.png'); sheet.alpha_composite(s, (k*68, 100-s.size[1]))
sheet.resize((sheet.size[0]*2, 200), Image.NEAREST).save(f'{OUT}/_xem.png')
