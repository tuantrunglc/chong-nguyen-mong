# Trận 1 — lời giải không mất tướng

**Mục tiêu:** thắng (hạ hết 3 Bộ binh) mà **không tướng nào gục**. Cả hai tướng còn đủ 3 máu khi bảng Thắng hiện ra.

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0 — giống F1 trong game. Bàn 7×7, sông ở **cột 3** (trừ hàng 3 đi được).

**Lưu ý luật (dùng trong lời giải):**
- **Khoái** đánh ô kề, 2 sát thương, **đẩy 1 ô** theo hướng đánh. Đẩy quân Nguyên xuống sông là nó chết đuối ngay.
- **Lão** lao thẳng hàng, chỉ trúng quân ở cách **2–4 ô** (quân đứng sát hơn 2 ô không bị tính), 1 sát thương, không đẩy.
- Tướng **đi xuyên qua tướng mình** được, nhưng không dừng trên ô có quân.
- Ô đỏ là đòn quân Nguyên **đã báo**: hiệp sau, lúc bạn bấm Kết thúc lượt, đòn đó giáng xuống đúng ô đỏ. Hạ chủ đòn trước thì đòn bị hủy; không hạ được thì phải **đi khỏi ô đỏ**.

---

## Bàn đầu trận (sau khi quân Nguyên đi ở hiệp 1)

```
hàng 0:  . . . ~ . . .
hàng 1:  . . . ~ B . .
hàng 2:  . . . ~ . . .
hàng 3:  . . . . B . .
hàng 4:  . . . ~ . . .
hàng 5:  . . B ~ . . .
hàng 6:  1 . 2 ~ . . .
```

- Khoái `1` ở `0,6`; Lão `2` ở `2,6`.
- Ba Bộ binh ở `2,5`, `4,1`, `4,3`.
- **Ô đỏ:** Bộ binh `2,5` đang nhắm `2,6` — đúng ô Lão đang đứng.

## Hiệp 1 — bài học "đẩy xuống sông"

1. Bấm `1` chọn **Khoái**.
2. Bấm ô `1,5` để đi (tốn 2 bước).
3. Bấm ô `2,5` để **đánh** Bộ binh đang đứng đó.
   → Khoái đẩy nó sang `3,5` — ô sông. **Nó chết đuối.** Ô đỏ trên `2,6` biến mất vì chủ đòn đã chết.
4. Bấm `2` chọn **Lão**, bấm ô `2,5` (ô Bộ binh vừa bỏ trống) để đi.
5. Bấm **Space** (Kết thúc lượt).

Quân Nguyên còn lại: `4,1` đi tới `4,2`; `4,3` đi tới `2,3`. Không có đòn nào giáng xuống.

```
hàng 2:  . . . ~ B . .
hàng 3:  . . B . . . .
hàng 5:  . 1 2 ~ . . .
hàng 6:  . . . ~ . . .
```

## Hiệp 2 — bài học "lao phải đứng xa"

1. Khoái đi `1,5` → `2,4`.
2. Khoái đánh `2,3`: Bộ binh mất 2 máu, bị đẩy lên `2,2`.
3. Lão đứng nguyên `2,5`, đánh ô `2,2`: lao bay 3 ô, trúng Bộ binh, mất 1 máu cuối → **nó gục**.
4. Bấm **Space**.

Quân Nguyên cuối: `4,2` đi tới `3,3`.

```
hàng 3:  . . . B . . .
hàng 4:  . . 1 ~ . . .
hàng 5:  . . 2 ~ . . .
```

## Hiệp 3 — hạ quân cuối

1. Khoái đi `2,4` → `2,3`.
2. Khoái đánh `3,3`: mất 2 máu, bị đẩy sang `4,3`.
3. Lão đi `2,5` → `1,3` (đi xuyên qua ô Khoái đang đứng — hợp lệ).
4. Lão đánh `4,3`: lao 3 ô, 1 máu cuối → **nó gục**. **Thắng**, cả hai tướng còn 3 máu.

---

## Vì sao trận này dạy đúng hai bài

- **Đẩy xuống sông:** hiệp 1, Bộ binh đứng sát sông; Khoái đẩy 1 ô là nó rơi xuống nước và chết ngay, không cần đánh đủ 3 máu.
- **Né ô đỏ:** hiệp 1 có ô đỏ nhắm thẳng vào Lão. Lời giải chính chọn **hạ chủ đòn** (Khoái đẩy nó xuống sông) nên ô đỏ tự mất. Muốn thấy cảnh **né**, đi theo nhánh dưới đây.

## Nhánh né ô đỏ — đường khác, 4 hiệp (đã có kịch bản)

Đường này để thấy đòn đã báo giáng xuống ô trống. **Không trộn** với 3 hiệp ở trên.

1. Hiệp 1: Lão đi `1,6` (rời ô đỏ `2,6`); Khoái đi `1,5`; Space. Đòn giáng xuống `2,6` — ô trống, không ai mất máu.
2. Hiệp 2: Khoái đánh `2,5` (đẩy xuống sông `3,5`); Lão đi `2,5`; Space.
3. Hiệp 3: Khoái đi `1,4`, đánh `2,4` (đẩy xuống sông `3,4`); Lão đi `1,5`; Space.
4. Hiệp 4: Khoái đánh `1,3` (đẩy lên `1,2`); Lão đánh `1,2` → thắng, hai tướng vẫn 3 máu.

Kịch bản: `game/tests/kich_ban/tran/tran_01_ne_o_do.json` (đang `da_duyet: false`, chờ tác giả duyệt).

## Kiểm chứng

Mỗi lần gõ `tools/test.sh`, hai kịch bản `tran_01_loi_giai.json` và `tran_01_ne_o_do.json` đều được phát lại và ghi kết quả. Chúng chỉ trở thành **chốt chặn** (làm test đỏ khi lời giải hỏng) sau khi tác giả đánh tay xác nhận và `da_duyet` được đổi sang `true`.
