# Ghép bản đồ lớn từ "con dấu" (đảo, bãi) cắt ra từ một bức tranh nhỏ đã vẽ khớp lưới ô 64 px.
import random, sys, json
from collections import deque
from PIL import Image
T = 64
src = Image.open(sys.argv[1]).convert('RGB'); sp = src.load(); SW, SH = src.size
DEEP = (8, 100, 110)
def waterish(p): return p[2] > p[0] * 3 and p[1] < 140
# Con dấu: tên -> (ô trong tranh gốc)
STAMPS = {
  'tay_bac': [(0,0),(1,0),(0,1),(1,1)],
  'dao_bai': [(4,0),(5,0),(5,1)],
  'hon': [(3,2)],
  'day': [(3,4),(4,4),(5,4),(5,3)],
  'bai_trai': [(0,3),(0,4),(1,4)],
}
def foam(p): return (p[0] < 120 and p[1] > 140) or min(p) > 215
def cut(cells):
    xs=[c[0] for c in cells]; ys=[c[1] for c in cells]
    x0,y0=max(0,min(xs)*T-20),max(0,min(ys)*T-20); x1,y1=min(SW,(max(xs)+1)*T+20),min(SH,(max(ys)+1)*T+20)
    seen=set(); q=deque()
    for cx,cy in cells:
        for y in range(cy*T+16,cy*T+48):
            for x in range(cx*T+16,cx*T+48):
                if not waterish(sp[x,y]): q.append((x,y)); seen.add((x,y))
    while q:
        x,y=q.popleft()
        for a,b in ((1,0),(-1,0),(0,1),(0,-1)):
            n=(x+a,y+b)
            if not (x0<=n[0]<x1 and y0<=n[1]<y1) or n in seen or sp[n]==DEEP: continue
            # Đất chỉ lấy trong ô của con dấu (cho phép vách nhô xuống 24 px); ngoài ô chỉ lấy nước nông, bọt sóng.
            inside = any(cx*T <= n[0] < (cx+1)*T and cy*T-16 <= n[1] < (cy+1)*T+24 for cx,cy in cells)
            if inside or waterish(sp[n]) or foam(sp[n]):
                seen.add(n); q.append(n)
    st=Image.new('RGBA',(x1-x0,y1-y0),(0,0,0,0)); p=st.load()
    for (x,y) in seen: p[x-x0,y-y0]=sp[x,y]+(255,)
    ox,oy=min(xs)*T-x0,min(ys)*T-y0   # vị trí ô trái trên trong con dấu
    return st,(ox,oy),cells
# Mặt nước: các ô 64x64 toàn nước trong tranh gốc
wins=[]
for y in range(0,SH-T,8):
    for x in range(0,SW-T,8):
        if all(waterish(sp[x+i,y+j]) for i in range(0,T,2) for j in range(0,T,2)): wins.append((x,y))
print('cua so nuoc', len(wins))
lay=json.load(open(sys.argv[2]))
C,R=lay['cot'],lay['hang']; r=random.Random(7)
out=Image.new('RGBA',(C*T,R*T),DEEP+(255,))
for yy in range(R):
    for xx in range(C):
        x,y=r.choice(wins); out.paste(src.crop((x,y,x+T,y+T)),(xx*T,yy*T))
grid=[['~']*C for _ in range(R)]
for item in lay['dat']:
    name,gx,gy=item[:3]
    st,(ox,oy),cells=cut(STAMPS[name])
    if len(item) > 3 and item[3]:
        st=st.transpose(Image.FLIP_LEFT_RIGHT); ox=st.size[0]-ox-T
    out.alpha_composite(st,(gx*T-ox,gy*T-oy))
    bx=min(c[0] for c in cells); by=min(c[1] for c in cells)
    for cx,cy in cells:
        k=lay['nguon'][cy][cx]
        grid[gy+cy-by][gx+cx-bx]=k
out.convert('RGB').save(sys.argv[3])
print('\n'.join(' '.join(row) for row in grid))
