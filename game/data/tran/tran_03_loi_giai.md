# Trận 3 — Phục Kích Ải Nội Bàng: lời giải không mất tướng

**Mục tiêu:** thắng (hạ 1 Cung kỵ + 1 Bộ binh + 1 Kỵ binh) trong giới hạn **5 hiệp** mà **không tướng nào mất máu**. Kết thúc trận, cả ba tướng Khoái, Dư và Lão đều còn nguyên **3/3 máu**.

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0 — giống phím F1 trong game. Bàn **6 cột × 6 hàng**. Các bàn đầu hiệp dưới đây là bàn **đầu lượt người chơi**, sau khi quân Nguyên đã chạy pha chuẩn bị (đi nếu cần) và báo đòn.

> Bấm sai một nước: dùng **Chơi lại hiệp** (phím `R`, mỗi trận 1 lần) để lùi về đầu hiệp, không phải đánh lại từ đầu.

---

## Luật dùng trong trận này

- **Trần Khánh Dư (`3` — ra trận lần đầu):** dùng đòn kéo (`keo`), nhắm quân Nguyên đầu tiên trên hàng/cột trong vòng **2–3 ô**, kéo mục tiêu về phía mình **1–2 ô** (khoảng cách 2 ô kéo 1 ô, khoảng cách 3 ô kéo 2 ô; dừng sớm nếu bị cản), **0 sát thương trực tiếp**.
- **Hầm chông tre (`^`):** ô đi được. Bất kỳ quân nào bước vào, bị đẩy hoặc **bị kéo lướt qua ô chông** đều mất **1 máu cho mỗi ô chông đi qua**. Quân gục trên chông sẽ dừng lại ngay.
- **Cung kỵ (`C`):** máu **1**, bắn thẳng hàng trong tầm **2–3 ô**, tên bay qua quân đứng giữa; rừng hoặc kho lương chặn tên.
- **Kỵ binh (`K`):** máu **2**, xung phong theo đường thẳng tới vật cản đầu tiên.
- **Nguyễn Khoái (`1`):** đánh ô kề, **2 sát thương**, đẩy lùi mục tiêu **1 ô** theo hướng đánh. Đẩy địch vào hầm chông sẽ gây thêm 1 sát thương chông (tổng cộng 3 sát thương).
- **Phạm Ngũ Lão (`2`):** phóng lao thẳng hàng từ ô thứ **2–4**, **1 sát thương**. Lao **bay qua ô kề** (dù có tướng mình đứng chắn ở ô kề thì lao vẫn bay qua trúng địch phía sau).
- **Giới hạn hiệp:** trận có giới hạn tối đa **5 hiệp** (`so_hiep_toi_da: 5`). Hết hiệp 5 mà còn quân Nguyên thì thua. Lời giải này hoàn thành thắng lợi ngay ở **hiệp 2**.

---

## Bàn đầu trận (sau khi quân Nguyên báo đòn ở hiệp 1)

```text
hàng 0:  # . . . K #
hàng 1:  . . . . . .
hàng 2:  . . . C . ^
hàng 3:  . . ^ ^ . .
hàng 4:  ~ ~ . . . .
hàng 5:  . . 1 3 2 .
```

- **Địa hình:** Rừng `#` ở `0,0` và `5,0`; Hầm chông `^` ở `5,2`, `2,3`, `3,3`; Sông `~` ở `0,4`, `1,4`.
- **Tướng ta:** Khoái `1` ở `2,5`; Dư `3` ở `3,5`; Lão `2` ở `4,5`.
- **Quân Nguyên:** Kỵ binh `K` ở `4,0`; Cung kỵ `C` ở `3,2`; Bộ binh `B` ở `2,4`.
- **Ba ô đỏ đang đe dọa quân ta:**
  - Kỵ binh `4,0` lao thẳng xuống cột 4 nhắm Lão `4,5` (đỏ cả cột 4).
  - Cung kỵ `3,2` ngắm bắn thẳng xuống cột 3 nhắm Dư `3,5` (đỏ ô `3,5`).
  - Bộ binh `2,4` vung đao nhắm Khoái `2,5` (đỏ ô `2,5`).

---

## Hiệp 1 — Bài học kéo và đẩy địch vào hầm chông

1. Bấm `3` chọn **Trần Khánh Dư** (đang đứng ở `3,5`).
2. Bấm vào **Cung kỵ `C` ở ô `3,2`** để kéo:
   - Khoảng cách là 3 ô. Dư kéo C về phía Nam 2 ô (`3,2` → `3,3`).
   - Ô `3,3` là **Hầm chông**! Cung kỵ (1 máu) rơi vào chông, mất 1 máu → **Cung kỵ gục ngay lập tức**!
   - Ô đỏ nhắm Dư ở `3,5` biến mất.
   → **Đây là chỗ dạy “Dư kéo địch vào hầm chông”.**
3. Bấm `1` chọn **Nguyễn Khoái** (đang đứng ở `2,5`).
4. Bấm vào **Bộ binh `B` ở ô `2,4`** để đánh:
   - Khoái đánh hướng Bắc: gây 2 sát thương, đẩy lùi B lên ô `2,3`.
   - Ô `2,3` là **Hầm chông**! B nhận thêm 1 sát thương chông (tổng 2 + 1 = 3 sát thương) → **Bộ binh gục tại chỗ**!
   - Ô đỏ nhắm Khoái ở `2,5` biến mất.
   → **Đây là chỗ dạy “Khoái đẩy địch dính hầm chông dứt điểm 3 máu”.**
5. Bấm `2` chọn **Phạm Ngũ Lão** (đang đứng ở `4,5`).
6. Bấm ô **`5,5`** để Lão bước sang phải 1 bước, né hoàn toàn khỏi đường lao của Kỵ binh cột 4.
7. Bấm **Space** (Kết thúc lượt).

**Quân Nguyên ra đòn:**
- Kỵ binh `4,0` lao thẳng xuống cột 4. Lão đã né sang `5,5`, cột 4 trống không ai đứng → Kỵ binh không đánh trúng ai.

---

## Hiệp 2 — Bài học phối hợp khống chế và lao bay qua quân mình

```text
hàng 0:  # . . . . #
hàng 1:  . . . . . K
hàng 2:  . . . . . ^
hàng 3:  . . ^ ^ . .
hàng 4:  ~ ~ . . . .
hàng 5:  . . 1 3 . 2
```

- Kỵ binh `K` di chuyển tới `5,1`, ngắm lao thẳng xuống cột 5 nhắm Lão `5,5`.
- Khoái ở `2,5`, Dư ở `3,5`, Lão ở `5,5`.

**Các bước đi:**

1. Bấm `3` chọn **Trần Khánh Dư**, bấm ô **`5,4`** để đi (Dư bước xuyên qua Lão `5,5` tới `5,4`, tốn 3 bước).
2. Dư đang đứng ở `5,4`, bấm vào **Kỵ binh `K` ở `5,1`** để kéo:
   - Khoảng cách là 3 ô. Dư kéo K về phía Nam 2 ô (`5,1` → `5,2` → `5,3`).
   - Ô `5,2` là **Hầm chông**! Kỵ binh lướt qua chông mất 1 máu (máu còn 1/2), dừng lại tại `5,3`.
3. Bấm `2` chọn **Phạm Ngũ Lão** (đang đứng ở `5,5`).
4. Bấm vào **Kỵ binh ở `5,3`** để phóng lao:
   - Dư đang đứng ở ô kề `5,4`. Lao của Lão **bay xuyên qua Dư ở ô kề** và cắm trúng Kỵ binh ở ô thứ hai `5,3`!
   - Kỵ binh mất 1 máu cuối cùng → **Kỵ binh gục ngay lập tức**!
   → **Đây là chỗ dạy “lao bay qua đồng minh đứng ở ô kề”.**

---

## Kết quả

- Bảng **Thắng** hiện lên ngay cuối Hiệp 2 (hoàn thành trước giới hạn 5 hiệp).
- Cả 3 tướng Nguyễn Khoái, Trần Khánh Dư, Phạm Ngũ Lão đều còn nguyên vẹn **3/3 máu**.
