# Trận 5 — Thăng Long Bỏ Ngỏ: lời giải Giữ ải không mất tướng

**Mục tiêu:** Giữ hai ô ải `A` (`3,7` và `4,7`) qua hết **5 hiệp**, không quân Nguyên nào vào ải, **không tướng nào gục**. Trận này cho phép mất máu (tác giả chốt 2026-10-27). Lời giải dưới đây thắng ở cuối hiệp 5: Khoái 3/3, Lão 3/3, Dư 2/3.

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0, giống phím F1 trong game. Bàn **8 cột × 8 hàng**. Các bàn dưới đây là bàn **đầu lượt người chơi**, tức sau khi quân Nguyên đã đi và báo đòn.

> Bấm sai một nước: dùng **Chơi lại hiệp** (phím `R`, mỗi trận 1 lần) để về đầu hiệp.

---

## Luật dùng trong trận này

- **Giữ ải:** quân Nguyên vào ô `A` bằng bất kỳ cách nào (tự đi, bị đẩy, bị kéo, tiếp viện hiện lên) là **thua ngay**. Thắng khi qua hết cuối hiệp 5. **Diệt hết quân Nguyên chưa phải là thắng**: vẫn phải giữ cho đủ 5 hiệp.
- **Kho lương (`L`):** cuối mỗi hiệp, quân Nguyên bị thương đứng kề kho (trên, dưới, trái, phải) **hồi 1 máu**. Kho là vật cản như rừng.
- **Vườn không nhà trống (nút hoặc phím `Q`, 1 lần mỗi trận):** mọi kho lương thành đất trống, **mọi quân Nguyên mất 1 máu**. Không tốn lượt của tướng. Dùng xong thì **không hủy nước đi trước đó được nữa**.
- **Quân tiếp viện:** ở hiệp trước, ngay khi quân Nguyên đi và báo đòn xong, ô quân mới sẽ hiện lên được **đánh dấu riêng** (khác ô đỏ) và giữ suốt lượt của bạn. Đầu hiệp sau, quân mới hiện ở ô đó. **Nếu ô đó đang có quân đứng** (kể cả tướng mình) thì quân đứng đó mất 1 máu và **quân tiếp viện bị hủy**.
- **Kỵ binh** trong trận Giữ ải nhắm ô ải: ô ải trống thì nó phi thẳng vào.
- **Khoái:** chém ô kề, 2 sát thương, đẩy 1 ô (mục tiêu gục thì không đẩy). **Lão:** lao thẳng hàng, bay qua ô kề, trúng vật đầu tiên ở ô 2–4, 1 sát thương. **Dư:** kéo, 0 sát thương.
- **Sông** (`0,3`, `1,3`, `6,4`, `7,4`): quân Nguyên bị đẩy/kéo xuống là chết đuối. Lời giải này không cần tới sông, nhưng đây là một cách giữ ải khác.

---

## Bàn đầu trận (sau khi quân Nguyên báo đòn ở hiệp 1)

```text
         0 1 2 3 4 5 6 7
hàng 0:  . . L . . L . .
hàng 1:  # . B . . B . #
hàng 2:  . . . . . . . .
hàng 3:  ~ ~ . C # . . .
hàng 4:  . . . . . . ~ ~
hàng 5:  . . # . . . . .
hàng 6:  . . 1 3 2 . . .
hàng 7:  . . . A A . . .
```

- **Tướng:** Khoái `1` ở `2,6`, Dư `3` ở `3,6`, Lão `2` ở `4,6`, đều 3 máu.
- **Quân Nguyên:** Bộ binh `2,1` (3 máu, kề kho `2,0`), Bộ binh `5,1` (3 máu, kề kho `5,0`), Cung kỵ `3,3` (1 máu).
- **Ô đỏ:** Cung kỵ `3,3` bắn **ô `3,6`** (chỗ Dư đang đứng).

---

## Hiệp 1 — Đốt kho trước khi giặc kịp hồi máu

1. Bấm `3` chọn **Dư**, bấm ô **`5,7`**: Dư rời ô đỏ `3,6` và đứng sẵn cách ô `7,7` hai bước, để hiệp 2 kịp lên chặn tiếp viện (xem hiệp 2).
2. Bấm **Vườn không nhà trống** (hoặc phím `Q`):
   - hiện dòng "Vườn không nhà trống!";
   - hai kho `2,0` và `5,0` cháy, thành đất trống;
   - Cung kỵ (1 máu) gục, **ô đỏ của nó biến mất**;
   - hai Bộ binh còn **2 máu**.
3. Bấm `2` chọn **Lão**, bấm ô **`5,5`**, rồi bấm Bộ binh **`5,1`** (bấm lần nữa để đánh): lao bay qua `5,4`, trúng Bộ binh, còn **1 máu**.
4. Bấm `1` chọn **Khoái**, bấm ô **`4,5`**.
5. Bấm **Kết thúc lượt** (`Space`).

**Vì sao dùng mưu kế ngay hiệp 1?** Nếu không đốt kho, Bộ binh `5,1` vừa bị Lão lao trúng (còn 2 máu) vẫn đứng kề kho `5,0`. Cuối hiệp nó **hồi về đủ 3 máu**, như chưa bị đánh. Mưu kế còn hạ luôn Cung kỵ (1 máu) mà không tốn lượt tướng nào, nên Lão rảnh tay lao Bộ binh. Đốt kho ngay lúc giặc còn đứng cạnh kho thì vừa trừ máu cả ba, vừa cắt đường hồi máu đến hết trận.

## Hiệp 2 — Diệt hai Bộ binh, đứng chặn ô tiếp viện

```text
         0 1 2 3 4 5 6 7
hàng 0:  . . . . . . . .
hàng 1:  # . . B . . . #
hàng 2:  . . . B . . . .
hàng 3:  ~ ~ . . # . . .
hàng 4:  . . . . . . ~ ~
hàng 5:  . . # . 1 2 . .
hàng 6:  . . . . . . . .
hàng 7:  . . . A A 3 . ◇      ◇ = ô báo tiếp viện 7,7 (trong game: ô vàng có mũi tên)
```

- Bộ binh `3,1` còn 1 máu, Bộ binh `3,2` còn 2 máu (không hồi vì kho đã cháy). Không có ô đỏ.
- **Ô `7,7` được đánh dấu tiếp viện**: đầu hiệp 3 sẽ có quân mới hiện ở đó.

1. Bấm `1` chọn **Khoái**, bấm ô **`3,3`**, rồi bấm Bộ binh **`3,2`** (bấm lần nữa để đánh): 2 sát thương, Bộ binh gục, không bị đẩy.
2. Bấm `2` chọn **Lão**, bấm ô **`3,4`**, rồi bấm Bộ binh **`3,1`**: lao bay qua Khoái ở `3,3`, qua ô trống `3,2`, trúng Bộ binh `3,1`, **gục**.
3. Bấm `3` chọn **Dư**, bấm ô **`7,7`** (ô báo tiếp viện).
4. Bấm **Kết thúc lượt**.

**Vì sao Dư phải đứng ở `7,7`?** Ô tiếp viện nằm ngay hàng ải. Nếu để trống, đầu hiệp 3 Kỵ binh hiện ở `7,7`, thấy ô ải `4,7` trống trên cùng hàng, và **phi thẳng vào ải: thua ngay**. Đứng lên ô đó thì Dư mất 1 máu nhưng Kỵ binh bị hủy.

## Hiệp 3 — Tiếp viện bị chặn

```text
         0 1 2 3 4 5 6 7
hàng 0:  . . . . . . . .
hàng 1:  # . . . . . . #
hàng 2:  . . . . . . . .
hàng 3:  ~ ~ . 1 # . . .
hàng 4:  . . . 2 . . ~ ~
hàng 5:  . . # . . . . .
hàng 6:  . . . . . . . .
hàng 7:  . . . A A . . 3
```

- Đầu hiệp, Kỵ binh tiếp viện **không xuất hiện**. Dư mất 1 máu, còn **2/3**.
- Bàn không còn quân Nguyên nào, nhưng màn hình vẫn ghi **"Hiệp 3/5"**: chưa thắng.

1. Bấm **Kết thúc lượt**.

## Hiệp 4 — Giữ ải

Bàn như hiệp 3, không có gì thay đổi.

1. Bấm **Kết thúc lượt**.

## Hiệp 5 — Hiệp cuối

Bàn như hiệp 3. Số hiệp hiện **"Hiệp 5/5"** (đổi màu nổi bật).

1. Bấm **Kết thúc lượt**: hiện bảng **Thắng**.

### Bàn sau hiệp cuối

```text
         0 1 2 3 4 5 6 7
hàng 0:  . . . . . . . .
hàng 1:  # . . . . . . #
hàng 2:  . . . . . . . .
hàng 3:  ~ ~ . 1 # . . .
hàng 4:  . . . 2 . . ~ ~
hàng 5:  . . # . . . . .
hàng 6:  . . . . . . . .
hàng 7:  . . . A A . . 3
```

Khoái `3,3` 3/3 máu, Lão `3,4` 3/3 máu, Dư `7,7` 2/3 máu. Không quân Nguyên nào vào ải.

---

## Nếu không làm gì

Đứng yên cả ba tướng và chỉ bấm Kết thúc lượt: hai Bộ binh tràn xuống, Cung kỵ bắn Dư. Đầu hiệp 3 Kỵ binh tiếp viện hiện ở `7,7` và phi vào ải `4,7`: **thua ngay ở hiệp 3** ("Thua: giặc vào ải").
