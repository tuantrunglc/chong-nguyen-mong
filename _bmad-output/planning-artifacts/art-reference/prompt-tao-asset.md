# Prompt tạo asset bằng AI

Lập 2026-10-20. Dùng với Gemini, ChatGPT, PixelLab hoặc công cụ AI vẽ hình khác.

**Cách dùng:**
1. Dán **phần 1 (bản mô tả thiết kế)** vào đầu cuộc trò chuyện, hoặc vào ô "hướng dẫn" hay "style" nếu công cụ có.
2. Mỗi lần cần một hình, dán thêm **một dòng ở phần 2**.

Prompt viết bằng tiếng Anh vì các công cụ AI vẽ hiểu tiếng Anh tốt nhất. Thông số lấy từ code hiện tại (`board_view.gd`, `unit_token.gd`) và từ `danh-sach-hinh-e8.md`. Đổi thông số trong game thì phải sửa cả file này.

Hình AI làm ra vẫn phải qua bước kiểm tra cuối `danh-sach-hinh-e8.md`: đổi về bảng màu, sửa tay, ghi vào `CREDITS.md`.

## Phần 1: Bản mô tả thiết kế (dán một lần)

```
You are making pixel art assets for a turn-based tactics game set in 13th-century Vietnam
(Tran dynasty, resisting the Mongol Yuan invasions). Every asset you make must follow these rules.

CAMERA AND GRID
- The board is a grid of SQUARE tiles, each exactly 64x64 pixels, shown 1:1 (no scaling).
- View: top-down with a slight front tilt. Flat ground is seen straight from above.
  Raised objects show ONLY their top face and their front face (the side facing the viewer, toward
  the bottom of the image). Never show left or right side faces. No isometric, no diamond tiles.
- Objects in lower rows are drawn in front of objects in upper rows, so tall things may overlap
  the tile above them, never the tiles to the left or right.
- Light comes from the top-left. Do NOT bake cast shadows; the game adds a soft shadow under units.

ASSET TYPES
1. Ground tiles (grass, water, river bank, spike pit): exactly 64x64, fully opaque, seamless on
   all four edges so the same tile repeats without visible seams. No objects that stand out.
2. Raised terrain (forest, village hut, granary): 64 pixels wide, up to 96 pixels tall,
   transparent background. Its footprint fills the bottom 64x64 of the image; the front face is
   about 16 pixels tall; anything taller extends upward into the tile above.
3. Units: 64x64 frame, transparent background. Feet stand at the center of the tile, slightly
   below the middle. The head may rise into the tile above. Weapons may not stick out more than
   half a tile to the left or right. One unit = one tile, never wider (horses included).

PALETTE AND RENDERING
- Use ONLY these 64 colors (Resurrect 64):
  #2e222f #3e3546 #625565 #966c6c #ab947a #694f62 #7f708a #9babb2 #c7dcd0 #ffffff #6e2727 #b33831
  #ea4f36 #f57d4a #ae2334 #e83b3b #fb6b1d #f79617 #f9c22b #7a3045 #9e4539 #cd683d #e6904e #fbb954
  #4c3e24 #676633 #a2a947 #d5e04b #fbff86 #165a4c #239063 #1ebc73 #91db69 #cddf6c #313638 #374e4a
  #547e64 #92a984 #b2ba90 #0b5e65 #0b8a8f #0eaf9b #30e1b9 #8ff8e2 #323353 #484a77 #4d65b4 #4d9be6
  #8fd3ff #45293f #6b3e75 #905ea9 #a884f3 #eaaded #753c54 #a24b6f #cf657f #ed8099 #831c5d #c32454
  #f04f78 #f68181 #fca790 #fdcbb0
- True pixel art: hard pixel edges, no anti-aliasing, no blur, no gradients, no soft brushes,
  no noise texture, no photo detail. Every pixel sits on the pixel grid.
- Units and raised objects have a 1-pixel dark outline (#2e222f). Ground tiles have no outline.

READABILITY (most important)
- Terrain must be muted and low-contrast: it is the background. Bright red is RESERVED for the
  game's attack-warning tiles, so never use bright red (#e83b3b, #ea4f36, #f04f78) on terrain.
- Factions must be recognizable at a glance:
  Dai Viet (player) = dark red, black, bronze.
  Mongol Yuan (enemy) = slate grey-blue, steel grey, brown leather. No red on enemies.
- Each unit needs a clear, bold silhouette that reads at 64x64.

HISTORY
- 13th-century Vietnam: thatched-roof huts with mud walls, bamboo, rice fields, tropical trees,
  muddy rivers. Not Japanese, not Chinese imperial, not European fantasy.
- Dai Viet generals: lacquered lamellar armor, cloth head bands, spears and polearms.
- Mongol Yuan soldiers: leather lamellar armor, fur-trimmed hats, curved sabres, short composite
  bows, small steppe horses.

NEVER
- No text, letters, numbers or writing anywhere. Flags have no writing (the game adds Han
  characters such as 陳 by hand later if needed).
- No logo, no watermark, no UI, no frame, no background scene behind single assets.
- Never output a whole scene or map when a single asset is requested.

OUTPUT
- One asset per image, exact pixel size stated above, PNG with transparency where required.
- If you can only output larger images, draw on a clear grid where 1 art pixel = N x N screen
  pixels, so it can be scaled down exactly with nearest-neighbor.
```

## Phần 2: Yêu cầu từng hình (dán sau phần 1)

Mã (A1, B2…) khớp với `danh-sach-hinh-e8.md`.

### Địa hình

| Mã | Dòng yêu cầu |
|---|---|
| A1 | `Ground tile: mossy grass with a few tiny dirt specks. Make 3 variants that tile together.` |
| A2 | `Ground tile: dark teal river water with gentle ripples. Plus a variant with a brown muddy bank strip along the TOP edge only.` |
| A3 | `Raised terrain: dense cluster of tropical trees, trunks at the bottom, canopy rising into the tile above. 2 variants.` |
| A4 | `Ground tile: camouflaged pit with sharpened bamboo stakes, clearly a trap but muted.` |
| A5 | `Raised terrain: wooden granary on stilts with straw roof and rice sacks. Plus a burned version (ash and charred posts, flat).` |
| A6 | `Raised terrain: small Vietnamese thatched-roof hut with mud walls. 2 variants, plus a version with smoke rising.` |
| A7 | `Raised terrain: low flat stone platform, front face 8 pixels tall, units can stand on top.` |
| A8 | `Decorative border tile (not part of the board): darker forest, water and rocks to frame the board.` |

### Quân (PixelLab: `create_character` mode **v3**, size 64, view **high top-down**; 2 lượt, ra 8 hướng)

Ba dòng B1–B3 dưới đây là prompt đã dùng cho bản v3 (2026-10-20). Bộ nhận diện lấy từ `tu-lieu-trang-phuc-dai-viet.md`.

| Mã | Dòng yêu cầu |
|---|---|
| B1 | `13th century Vietnamese Tran dynasty general Nguyen Khoai, stocky powerful man, black hair in a top knot tied with a dark red cloth head band, sleeveless dark red short tunic, black lacquered lamellar chest armor with bronze trim, red sash, knee-length black trousers, BARE muscular arms with small black ink tattoo on forearm, BARE FEET no shoes, wide stable stance. He holds upright a modao (mo dao): a huge two-handed long blade weapon, a VERY LONG STRAIGHT single-edged steel blade almost as long as his whole body mounted on a short wooden pole grip, blade pointing up, total weapon taller than him` |
| B2 | `13th century Vietnamese Tran dynasty general Pham Ngu Lao, very muscular young man, black hair in a top knot tied with a bright dark red cloth head band with long trailing ends, black lacquered lamellar chest armor with bronze trim, dark red short tunic, long red sash, knee-length black trousers, bare muscular arms with small black ink tattoo on forearm, bare feet. He holds a long spear STRAIGHT VERTICAL beside him, spear tip pointing up above his head, not horizontal` |
| B3 | `13th century Vietnamese Tran dynasty naval general Tran Khanh Du, lean proud noble man, wearing a WIDE POINTED CONICAL palm-leaf hat (Vietnamese non la, tall sharp peak, wide brim, pale straw color, chin strap), charcoal grey short robe over dark red tunic, black lacquered chest armor with bronze trim, red sash, knee-length black trousers, bare forearms, bare feet. He holds upright a long wooden pole topped with a VERY LARGE curved iron boat hook shaped like a big J, the hook clearly visible above his hat` |
| B4 | `13th century Mongol Yuan warrior foot soldier, short stocky warrior, wearing a CONICAL ROUND FUR-TRIMMED HAT with brown fur trim brim, dark brown LEATHER LAMELLAR CHEST ARMOR over a slate grey-blue tunic, dark brown leather belt, knee-length grey-blue trousers, dark brown leather riding boots, wide stable combat stance. He holds a CURVED STEEL MONGOLIAN SABRE in one hand, and a SMALL ROUND WOODEN LEATHER SHIELD with bronze center boss on the other arm. High top-down view, crisp pixel art, clean bold silhouette. ABSOLUTELY NO RED CLOTHING, NO RED FABRIC, NO CAPE.` (bản v3 id `1d7e8b91-2b67-4c5f-aa61-beee8d934860`) |
| B5 | `Unit: Mongol Yuan cavalryman on a small steppe horse, holding a lance, horse and rider fit inside one 64x64 tile.` |
| B6 | `Unit: Mongol Yuan horse archer on a small steppe horse with a short composite bow, fits inside one 64x64 tile.` |

### Ảnh mẫu toàn màn hình (Gemini, đính kèm `img/mau-hinh-thu.png`)

```
Redraw the attached game screenshot following all the rules above. Keep the EXACT layout:
same 1280x720 frame, same board position, same grid, same terrain and unit in every tile,
same HUD panel on the right. Leave HUD buttons blank, add no text.
```
