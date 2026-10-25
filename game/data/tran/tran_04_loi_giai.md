# Trận 4 — Làng Quanh Vạn Kiếp: lời giải không mất tướng và bảo toàn Lòng dân

**Mục tiêu:** Thắng (tiêu diệt toàn bộ 1 Kỵ binh + 2 Bộ binh) trong giới hạn **6 hiệp** mà **không tướng nào mất máu** (3 tướng còn nguyên **3/3 máu**) và **Lòng dân còn nguyên 3/3** (không ngôi làng nào bị trúng đòn hay bị va chạm).

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0 — giống phím F1 trong game. Bàn **7 cột × 6 hàng** (cột 0–6, hàng 0–5). Các bàn đầu hiệp dưới đây là bàn **đầu lượt người chơi**, sau khi quân Nguyên đã chạy pha chuẩn bị (đi nếu cần) và báo đòn.

> Bấm sai một nước: dùng **Chơi lại hiệp** (phím `R`, mỗi trận 1 lần) để lùi về đầu hiệp, không phải đánh lại từ đầu.

---

## Luật dùng trong trận này

- **Làng (`D`):** Ô địa hình không đi vào được. Nếu bị quân Nguyên đánh trúng hoặc có quân cờ bị đẩy/kéo va chạm vào làng: **Lòng dân −1**! Nếu Lòng dân về 0, người chơi bị xử **Thua ngay lập tức**.
- **Chỉ số Lòng dân (`long_dan`):** Bắt đầu trận với **3 điểm**. Cần bảo vệ tuyệt đối không để mất điểm nào.
- **Rừng rậm (`#`):** Vật cản không đi vào được; đẩy quân va vào rừng gây **1 sát thương va chạm** (`COLLIDED`). Chặn đường kéo của Dư và chặn lao của Lão.
- **Sông (`~`):** Nằm ở góc Tây Nam (`0,4`, `1,4`, `0,5`, `1,5`).
- **Nguyễn Khoái (`1`):** Đánh ô kề, **2 sát thương**, đẩy lùi mục tiêu **1 ô** theo hướng đánh. Nếu đẩy địch va vào vật cản (rừng/mép bàn), địch mất thêm 1 máu (tổng 3 sát thương dứt điểm Bộ binh). **Đặc biệt lưu ý: Đẩy địch va chạm vào Làng cũng làm Lòng dân −1** (bẫy người chơi rất dễ phạm phải nếu đẩy địch bừa bãi về phía làng!).
- **Phạm Ngũ Lão (`2`):** Phóng lao thẳng hàng ô thứ 2–4, **1 sát thương**. Lao **bay qua ô kề** (dù có tướng mình đứng chắn ở ô kề thì lao vẫn bay qua trúng địch phía sau).
- **Trần Khánh Dư (`3`):** Dùng đòn kéo (`keo`), nhắm quân Nguyên đầu tiên trên hàng/cột trong tầm 2–3 ô, kéo mục tiêu về phía mình 1–2 ô, 0 sát thương trực tiếp. **Vật đầu tiên bất kỳ (tướng mình, làng, rừng) trên hướng kéo đều chặn đường kéo**, không thể kéo quân đứng sau vật cản. Rất hữu hiệu để kéo địch lệch khỏi ô làng đang bị nhắm đánh!
- **Giới hạn hiệp:** Tối đa **6 hiệp** (`so_hiep_toi_da: 6`). Lời giải này hoàn thành thắng lợi ngay ở **hiệp 3**.

---

## Bàn đầu trận (sau khi quân Nguyên báo đòn ở hiệp 1)

```text
hàng 0:  . B . . . # #
hàng 1:  D . . . # . .
hàng 2:  . . K . . B .
hàng 3:  . . . . . D .
hàng 4:  ~ ~ 1 3 2 . .
hàng 5:  ~ ~ . . . . .
```

- **Địa hình:** Làng `D` ở `0,1` (D1) và `5,3` (D2); Rừng `#` ở `4,1`, `5,0`, `6,0`; Sông `~` ở `0,4`, `1,4`, `0,5`, `1,5`.
- **Tướng ta:** Khoái `1` ở `2,4`; Dư `3` ở `3,4`; Lão `2` ở `4,4`.
- **Quân Nguyên:** 
  - Bộ binh B1 ở `1,0` (3 máu, đã tiến 2 bước từ `3,0` trong pha chuẩn bị).
  - Kỵ binh K ở `2,2` (2 máu).
  - Bộ binh B2 ở `5,2` (3 máu).
- **Hai đòn đỏ nguy hiểm đầu hiệp 1:**
  - Kỵ binh `2,2` ngắm xung phong thẳng xuống phía Nam vào ô Khoái đang đứng (`2,4`).
  - Bộ binh B2 ở `5,2` vung đao nhắm chém thẳng xuống Làng D2 ở `5,3`!
  *(Nếu không can thiệp, làng D2 sẽ bị chém và Lòng dân tụt xuống 2 ngay ở hiệp 1!)*

---

## Hiệp 1 — Phối hợp giải vây Làng D2 và né đòn Kỵ binh

```text
hàng 0:  . B . . . # #
hàng 1:  D . . . # . .
hàng 2:  . . K . . B .   <-- B2 nhắm vào Làng D2 ở 5,3!
hàng 3:  . . . . . D .
hàng 4:  ~ ~ 1 3 2 . .   <-- K nhắm vào Khoái ở 2,4!
hàng 5:  ~ ~ . . . . .
```

1. Bấm `3` chọn **Trần Khánh Dư** (đang ở `3,4`).
2. Bấm ô **`3,2`** để Dư tiến lên 2 bước.
3. Bấm vào **Bộ binh B2 ở `5,2`** để Dư phóng roi kéo:
   - Khoảng cách là 2 ô. Dư kéo B2 sang phía Tây 1 ô về **`4,2`**.
   - Đòn chém của B2 bị dời lệch từ `5,3` sang `4,3`, **ngôi làng D2 được giải cứu an toàn tuyệt đối!**
4. Bấm `1` chọn **Nguyễn Khoái** (đang ở `2,4` trong vùng nguy hiểm của Kỵ binh).
5. Bấm ô **`4,3`** để Khoái bước lên né hoàn toàn khỏi đường lao của Kỵ binh cột 2.
6. Bấm vào **Bộ binh B2 ở `4,2`** (đứng ngay phía Bắc Khoái):
   - Khoái chém hướng Bắc: gây 2 sát thương, đẩy B2 văng lên ô **`4,1`**.
   - Ô `4,1` là **Rừng rậm `#`**! B2 va vào rừng rậm mất thêm 1 máu (tổng 2 + 1 = 3 sát thương) → **Bộ binh B2 gục ngay tại chỗ!**
   - Đòn chém nhắm vào `4,3` bị hủy bỏ.
7. Bấm `2` chọn **Phạm Ngũ Lão** (đang ở `4,4`).
8. Bấm ô **`4,2`** để Lão bước lên 2 bước (lướt qua Khoái ở `4,3`).
9. Bấm vào **Kỵ binh K ở `2,2`**:
   - Khoảng cách từ Lão (`4,2`) đến K (`2,2`) là 2 ô. Ô kề `3,2` có Dư đứng chắn.
   - Lao của Lão **bay xuyên qua Dư** ở `3,2`, trúng Kỵ binh K ở `2,2` gây 1 sát thương → **Kỵ binh K còn 1/2 máu**.
10. Bấm **Space** (Kết thúc lượt).

- **Pha địch:**
  - Kỵ binh K lao thẳng xuống Nam hết cột 2 tới mép bàn (hàng 5) mà không trúng ai (toàn ô trống, không ai mất máu).
  - Bộ binh B1 từ `1,0` tiến sang `0,0` và vung đao nhắm Làng D1 ở `0,1`. K quay sang báo đòn vào Dư ở `3,2`.

---

## Hiệp 2 — Dứt điểm Kỵ binh và cứu Làng D1

Bàn đầu lượt người chơi ở hiệp 2:
```text
hàng 0:  B . . . . # #   <-- B1 ở 0,0 nhắm Làng D1 ở 0,1!
hàng 1:  D . . . # . .
hàng 2:  . . K 3 2 . .   <-- K ở 2,2 nhắm Dư ở 3,2
hàng 3:  . . . . 1 D .
hàng 4:  ~ ~ . . . . .
hàng 5:  ~ ~ . . . . .
```

1. Bấm `2` chọn **Phạm Ngũ Lão** (đang ở `4,2`).
2. Bấm vào **Kỵ binh K ở `2,2`**:
   - Lao tiếp tục bay qua Dư ở `3,2`, găm thẳng vào Kỵ binh K ở `2,2` gây 1 sát thương.
   - Kỵ binh (còn 1 máu) **gục ngay tại chỗ!** Đòn đỏ nhắm Dư từ phía Tây biến mất.
3. Bấm `3` chọn **Trần Khánh Dư** (đang ở `3,2`).
4. Bấm ô **`2,0`** để Dư chạy lên góc Tây Bắc (lướt qua ô `2,2` vừa sạch bóng Kỵ binh).
5. Bấm vào **Bộ binh B1 ở `0,0`**:
   - Khoảng cách từ Dư (`2,0`) đến B1 (`0,0`) là 2 ô. Dư dùng roi kéo B1 sang Đông 1 ô về **`1,0`**.
   - Đòn chém của B1 bị dời lệch từ `0,1` (Làng D1) sang `1,1` (khoảng đất trống), **ngôi làng D1 được giải cứu an toàn tuyệt đối!**
6. Bấm `1` chọn **Nguyễn Khoái** (đang ở `4,3`).
7. Bấm ô **`1,3`** để Khoái tiến 3 bước về phía Tây tiếp cận khu vực chiến sự.
8. Bấm **Space** (Kết thúc lượt).

- **Pha địch:**
  - B1 (còn 3 máu) ở `1,0` chém xuống ô `1,1` đất trống (không gây tổn thất nào). B1 quay sang báo đòn vào Dư ở `2,0`.

---

## Hiệp 3 — Né đòn và dứt điểm trận đấu

Bàn đầu lượt người chơi ở hiệp 3:
```text
hàng 0:  . B 3 . . # #   <-- B1 ở 1,0 nhắm Dư ở 2,0
hàng 1:  D . . . # . .
hàng 2:  . . . . 2 . .
hàng 3:  . 1 . . . D .   <-- Khoái ở 1,3 áp sát
hàng 4:  ~ ~ . . . . .
hàng 5:  ~ ~ . . . . .
```

1. Bấm `3` chọn **Trần Khánh Dư** (đang ở `2,0`).
2. Bấm ô **`3,0`** để Dư bước sang phải 1 bước né đòn chém của B1.
3. Bấm `1` chọn **Nguyễn Khoái** (đang ở `1,3`).
4. Bấm ô **`1,1`** để Khoái áp sát ngay phía Nam của B1.
5. Bấm vào **Bộ binh B1 ở `1,0`**:
   - Khoái vung đao chém hướng Bắc gây 2 sát thương, đồng thời đẩy B1 văng vào mép bàn phía Bắc!
   - B1 va vào mép bàn chịu thêm 1 sát thương va chạm (tổng 2 + 1 = 3 sát thương) → **Bộ binh B1 gục tại chỗ!**
6. Quân Nguyên bị quét sạch khỏi sa bàn: **Chiến thắng vang dội!**

Bàn sau khi quét sạch quân Nguyên (kết thúc trận):
```text
hàng 0:  . . . 3 . # #
hàng 1:  D 1 . . # . .
hàng 2:  . . . . 2 . .
hàng 3:  . . . . . D .
hàng 4:  ~ ~ . . . . .
hàng 5:  ~ ~ . . . . .
```

**Khoái 3/3 máu, Lão 3/3 máu, Dư 3/3 máu — Lòng dân 3/3 — không tướng nào mất máu, không ngôi làng nào bị hại.**

---

## Kết quả nghiệm thu

- **Số hiệp hoàn thành:** 3/6 hiệp.
- **Lòng dân:** Giữ trọn vẹn **3/3 điểm** (cả 2 ngôi làng D1 và D2 không mất giọt máu nào).
- **Máu 3 tướng:** Nguyễn Khoái (`3/3`), Phạm Ngũ Lão (`3/3`), Trần Khánh Dư (`3/3`).
