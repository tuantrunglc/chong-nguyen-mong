# Thêm viền biển quanh nền bàn: phản chiếu mép tranh ra ngoài M px rồi làm tối, để đầu quân, vũ khí, ngọn đảo
# thò ra ngoài mép bàn vẫn nằm trên nền. Dùng: python3 them_vien.py <nen.png> <ra.png> [M=48]
import sys
from PIL import Image, ImageEnhance
src = Image.open(sys.argv[1]).convert('RGB'); M = int(sys.argv[3]) if len(sys.argv) > 3 else 48
W, H = src.size
out = Image.new('RGB', (W + 2*M, H + 2*M))
out.paste(src, (M, M))
F, Fv = Image.FLIP_LEFT_RIGHT, Image.FLIP_TOP_BOTTOM
out.paste(src.crop((0, 0, M, H)).transpose(F), (0, M)); out.paste(src.crop((W-M, 0, W, H)).transpose(F), (W+M, M))
mid = out.crop((0, M, W+2*M, 2*M)).transpose(Fv); out.paste(mid, (0, 0))
mid = out.crop((0, H, W+2*M, H+M)).transpose(Fv); out.paste(mid, (0, H+M))
dark = ImageEnhance.Brightness(ImageEnhance.Color(out).enhance(0.6)).enhance(0.55)
dark.paste(src, (M, M))
dark.save(sys.argv[2])
