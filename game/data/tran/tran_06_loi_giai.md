# Trận 6 — Phục Binh Bạch Đằng: lời giải Giữ ải không mất tướng

**Mục tiêu:** Giữ ba ô ải `A` (`1,7`, `2,7` và `8,7`) qua hết **5 hiệp**, không quân Nguyên nào vào ải, **không tướng nào gục**. Trận này cho phép mất máu (tác giả chốt 2026-10-31, như trận 5). Lời giải dưới đây thắng ở cuối hiệp 5, cả ba tướng 3/3 máu.

**Đây là trận bắt buộc dùng Sát Thát.** Mô phỏng bằng luật thật (Story 4.5): cấm Sát Thát thì không có cách đánh nào thắng mà không mất tướng. Mọi lối đều để giặc vào ải hoặc mất tướng, chậm nhất ở hiệp 4.

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0, giống phím F1 trong game. Bàn **10 cột × 8 hàng**. Các bàn dưới đây là bàn **đầu lượt người chơi**, tức sau khi quân Nguyên đã đi và báo đòn.

> Bấm sai một nước: dùng **Chơi lại hiệp** (phím `R`, mỗi trận 1 lần) để về đầu hiệp.

---

## Luật dùng trong trận này

- **Giữ ải:** quân Nguyên vào ô `A` bằng bất kỳ cách nào (tự đi, bị đẩy, bị kéo, tiếp viện hiện lên) là **thua ngay**. Thắng khi qua hết cuối hiệp 5. **Diệt hết quân Nguyên chưa phải là thắng.**
- **Bộ binh và Kỵ binh nhắm ô ải:** ải trống thì chúng đi thẳng vào. Ải có tướng đứng thì chúng đứng cạnh và đánh tướng đó. **Cung kỵ** luôn nhắm tướng gần nhất.
- **Sát Thát (nút hoặc phím `W`, 1 lần mỗi trận):** từ lúc bấm tới hết lượt người chơi đó, **Khoái chém 3** (thay vì 2), **Lão lao 2** (thay vì 1). Dư kéo vẫn 0. Va chạm, chông, sông không được cộng. Không tốn lượt tướng. Dùng xong thì không hủy nước đi trước đó được nữa.
- **Vườn không nhà trống (nút hoặc phím `Q`, 1 lần mỗi trận):** mọi kho lương thành đất trống, **mọi quân Nguyên mất 1 máu**. Không tốn lượt tướng.
- **Quân tiếp viện:** ô quân mới sẽ hiện lên được **đánh dấu riêng** (khác ô đỏ) từ hiệp trước, giữ suốt lượt của bạn. Đầu hiệp sau, quân mới hiện ở ô đó rồi **đi và báo đòn ngay**. Ô đó đang có quân đứng thì quân đứng đó mất 1 máu và quân tiếp viện bị hủy.
- **Chông (`^`):** ai đi qua cũng mất 1 máu, kể cả chỉ đi ngang. **Quân Nguyên không tránh chông**: Cung kỵ (1 máu) đi qua chông là gục.
- **Sông (`~`):** quân Nguyên bị đẩy/kéo xuống là chết đuối.
- **Khoái:** chém ô kề, 2 sát thương, đẩy 1 ô (mục tiêu gục thì không đẩy). **Lão:** lao thẳng hàng, bay qua ô kề, trúng vật đầu tiên ở ô 2–4, 1 sát thương. **Dư:** kéo vật đầu tiên trong 3 ô về 2 ô, 0 sát thương.

---

## Bàn đầu trận (sau khi quân Nguyên đi ở hiệp 1)

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  ◇ . . . . . . . . .      ◇ = ô báo tiếp viện (trong game: ô vàng có mũi tên)
hàng 1:  . . . . . . . . L .
hàng 2:  . # . . . . . B . .
hàng 3:  ~ ~ K ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . B . C # . . . .
hàng 5:  . . # . 1 3 2 . K ◇
hàng 6:  . . . # . . . . . .
hàng 7:  . A A . . . . . A .
```

- **Tướng:** Khoái `1` ở `4,5`, Dư `3` ở `5,5`, Lão `2` ở `6,5`, đều 3 máu.
- **Quân Nguyên:**
  - Kỵ binh `2,3`: đứng trên chông, còn **1 máu**.
  - Bộ binh `2,4`: đã đi qua chông, còn **2 máu**.
  - Bộ binh `7,2`: 3 máu.
  - Cung kỵ `4,4`: 1 máu.
  - Kỵ binh `8,5`: 2 máu. Nó cách ải `8,7` hai ô, đầu hiệp 2 sẽ phi vào.
- **Không có ô đỏ.**
- **Ô báo tiếp viện cho hiệp 2:** Bộ binh ở `9,5`, Cung kỵ ở `0,0`.

## Hiệp 1 — Quét sạch 5 quân đầu trận

1. Bấm **Vườn không nhà trống** (hoặc phím `Q`):
   - kho `8,1` cháy;
   - Kỵ binh `2,3` và Cung kỵ `4,4` (1 máu) **gục**;
   - Bộ binh `2,4` còn **1 máu**, Bộ binh `7,2` còn **2 máu**, Kỵ binh `8,5` còn **1 máu**.
2. Bấm `3` chọn **Dư**, bấm ô **`7,4`**, rồi bấm Bộ binh **`7,2`** (bấm lần nữa để đánh): kéo Bộ binh về phía Dư, nó rơi xuống sông `7,3`, **chết đuối**.
3. Bấm `1` chọn **Khoái**, bấm ô **`7,5`**, rồi bấm Kỵ binh **`8,5`**: Kỵ binh **gục**.
4. Bấm `2` chọn **Lão**, bấm ô **`4,4`**, rồi bấm Bộ binh **`2,4`**: lao bay qua ô trống `3,4`, trúng Bộ binh, **gục**.
5. Bấm **Kết thúc lượt** (`Space`).

**Vì sao dùng Vườn không nhà trống ngay hiệp 1?** Mưu kế hạ luôn hai quân 1 máu mà không tốn lượt tướng nào, và trừ đúng 1 máu còn thiếu của ba quân kia. Nhờ vậy mỗi tướng chỉ cần một đòn để hạ một quân: hết sạch 5 quân khởi đầu trong hiệp 1. Kỵ binh `8,5` mà còn sống thì đầu hiệp 2 nó phi vào ải `8,7`.

## Hiệp 2 — Sát Thát: chém gục Bộ binh sát ải

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  . . . . . . . . . .
hàng 1:  . . C . . . . . . .
hàng 2:  . # . . . . . . . .
hàng 3:  ~ ~ ^ ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . . . 2 # . 3 . ◇
hàng 5:  . . # . . . . 1 . .
hàng 6:  . . . # . . . . B ◇
hàng 7:  . A A . . . . . A .
```

- Hai quân tiếp viện đã tới và đi luôn: **Bộ binh `8,6`** (3 máu) đứng **sát ải `8,7`** (ngay phía trên ải), Cung kỵ `2,1` (1 máu). Không có ô đỏ.
- **Ô báo tiếp viện cho hiệp 3:** Cung kỵ ở `9,4` và ở `9,6`.

1. Bấm **Sát Thát** (hoặc phím `W`): chữ trên nút đổi thành "Sát Thát: đang +1 sát thương".
2. Bấm `2` chọn **Lão**, bấm ô **`2,4`**, rồi bấm Cung kỵ **`2,1`**: lao trúng, Cung kỵ **gục**.
3. Bấm `1` chọn **Khoái**, bấm ô **`8,7`** (đứng lên ải), rồi bấm Bộ binh **`8,6`**: **3 sát thương**, Bộ binh 3 máu **gục ngay**.
4. Bấm `3` chọn **Dư**, bấm ô **`8,5`**.
5. Bấm **Kết thúc lượt**.

**Vì sao phải dùng Sát Thát ở đây?** Bộ binh `8,6` có 3 máu, đứng sát ải. Hiệp sau nó sẽ bước vào ải, nên phải hạ nó ngay hiệp này. Không có Sát Thát, Khoái chỉ chém được 2: Bộ binh còn 1 máu và bị đẩy lên `8,5`, vẫn sống. Muốn hạ nó thì phải dồn thêm tướng khác vào, và cánh trái bị bỏ trống. Đánh lại đúng lời giải này mà bỏ riêng nước Sát Thát thì giặc vào ải ở hiệp 4. Mô phỏng mọi cách đánh không dùng Sát Thát cũng đều thua.

## Hiệp 3 — Giặc tự lao vào chông

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  . . . . . . . . . .
hàng 1:  . . . . . . . . . .
hàng 2:  . # . . . . . . . .
hàng 3:  ~ ~ ^ ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . 2 . . # . . . .
hàng 5:  . . # . . . . . 3 C
hàng 6:  ◇ . . # . . . . . .
hàng 7:  . A A . . . . . 1 .
```

- Đầu hiệp, hai Cung kỵ tiếp viện hiện ở `9,6` và `9,4`. Cung kỵ `9,4` đi lên chông `9,3` và **gục** (quân Nguyên không tránh chông). Cung kỵ kia đi tới `9,5`. Không có ô đỏ.
- **Ô báo tiếp viện cho hiệp 4:** Cung kỵ ở `0,6`.

1. Bấm `1` chọn **Khoái**, bấm ô **`9,6`**, rồi bấm Cung kỵ **`9,5`**: Cung kỵ **gục**.
2. Bấm `3` chọn **Dư**, bấm ô **`8,6`**.
3. Bấm `2` chọn **Lão**, bấm ô **`1,6`** (về giữ cánh trái).
4. Bấm **Kết thúc lượt**.

## Hiệp 4 — Dàn tướng giữ hai cánh

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  . . . . . . . . . .
hàng 1:  . . . . . . . . . .
hàng 2:  . # . . . . . . . .
hàng 3:  ~ ~ ^ ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . . . . # . . . ◇
hàng 5:  . . # . . . . . . .
hàng 6:  ◇ 2 . # . . . . 3 1
hàng 7:  . A A . . . . . A .
```

- Cung kỵ tiếp viện hiện ở `0,6`, đi lên chông `0,4` và **gục**. Bàn không còn quân Nguyên, nhưng màn hình vẫn ghi **"Hiệp 4/5"**: chưa thắng.
- **Ô báo tiếp viện cho hiệp 5:** Kỵ binh ở `9,4`, Bộ binh ở `0,6`.

1. Bấm `1` chọn **Khoái**, bấm ô **`8,5`**.
2. Bấm `3` chọn **Dư**, bấm ô **`9,6`**.
3. Bấm `2` chọn **Lão**, bấm ô **`1,7`** (đứng lên ải).
4. Bấm **Kết thúc lượt**.

**Vì sao Lão đứng lên ải `1,7`?** Bộ binh sắp hiện ở `0,6` chỉ cách ải `1,7` hai bước. Ải trống thì nó bước thẳng vào: **thua ngay**. Có tướng đứng trên ải thì nó chỉ đứng cạnh và báo đòn đánh tướng đó.

## Hiệp 5 — Hiệp cuối: né đòn và hạ Kỵ binh

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  . . . . . . . . . .
hàng 1:  . . . . . . . . . .
hàng 2:  . # . . . . . . . .
hàng 3:  ~ ~ ^ ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . . . . # . . . .
hàng 5:  . . # . . . . K 1 .
hàng 6:  . B . # . . . . . 3
hàng 7:  . 2 A . . . . . A .
```

- Kỵ binh tiếp viện hiện ở `9,4`, đi tới `7,5` (2 máu). Bộ binh tiếp viện hiện ở `0,6`, đi tới `1,6` (3 máu).
- **Ô đỏ:** Bộ binh `1,6` đánh **ô `1,7`** (chỗ Lão đang đứng). Số hiệp hiện **"Hiệp 5/5"**.

1. Bấm `2` chọn **Lão**, bấm ô **`2,6`**: Lão rời ô đỏ.
2. Bấm `1` chọn **Khoái**, bấm ô **`7,6`**, rồi bấm Kỵ binh **`7,5`**: Kỵ binh **gục**.
3. Bấm `3` chọn **Dư**, bấm ô **`8,4`**.
4. Bấm **Kết thúc lượt**: Bộ binh đánh vào ô `1,7` trống, rồi hiện bảng **Thắng**.

**Vì sao Lão rời ải được?** Đây là hiệp cuối. Quân Nguyên chỉ còn ra đòn đã báo, không còn lượt đi nào nữa, nên Bộ binh `1,6` không kịp bước vào ải. Lão né đi thì không mất máu.

### Bàn sau hiệp cuối

```text
         0 1 2 3 4 5 6 7 8 9
hàng 0:  . . . . . . . . . .
hàng 1:  . . . . . . . . . .
hàng 2:  . # . . . . . . . .
hàng 3:  ~ ~ ^ ~ ~ ~ ~ ~ ^ ^
hàng 4:  ^ . . . . # . . 3 .
hàng 5:  . . # . . . . . . .
hàng 6:  . B 2 # . . . 1 . .
hàng 7:  . A A . . . . . A .
```

Khoái `7,6` 3/3 máu, Lão `2,6` 3/3 máu, Dư `8,4` 3/3 máu. Bộ binh `1,6` còn sống nhưng không vào được ải.

---

## Nếu không làm gì

Đứng yên cả ba tướng và chỉ bấm Kết thúc lượt: đầu hiệp 2 Kỵ binh `8,5` phi vào ải `8,7`, **thua ngay ở hiệp 2** ("Thua: giặc vào ải").
