# Trận 2 — Ải Lãnh Kinh: lời giải không mất tướng

**Mục tiêu:** thắng (hạ 2 Kỵ binh + 1 Bộ binh) mà **không tướng nào mất máu**. Kết thúc, Khoái và Lão đều còn **3/3 máu**.

**Cách đọc ô:** `cột,hàng`, gốc ở góc trên trái, tính từ 0 — giống F1 trong game. Bàn **6 cột × 7 hàng**. Các bàn đầu hiệp dưới đây là bàn **đầu lượt người chơi**, sau khi quân Nguyên đã chạy pha chuẩn bị (đi nếu cần) và báo đòn.

> Bấm sai một nước: dùng **Chơi lại hiệp** (phím `R`, mỗi trận 1 lần) để lùi về đầu hiệp, không phải đánh lại từ đầu.

## Luật dùng trong trận này

- **Kỵ binh (`K`):** trong **pha chuẩn bị**, nó đi (tối đa 3 ô) rồi **báo hướng** bằng một dãy **ô đỏ** chạy thẳng từ nó ra. Trong **pha ra đòn** (cuối lượt của bạn), nó lao theo đúng hướng đó và **trúng vật đầu tiên** trên đường: quân đầu tiên (bất kỳ phe nào) hoặc **rừng**; sát thương 1, **không đẩy**, và **không dời chỗ** khi lao. Vì vậy Kỵ binh có thể đứng ở ô mới sau mỗi hiệp (do pha chuẩn bị), nhưng không nhảy thêm khi ra đòn.
- **Rừng (`#`):** **chặn đường lao**. Đường lao dừng ở ô rừng; nếu rừng là vật đầu tiên thì **không ai mất máu**. Đứng **sau rừng** (rừng nằm giữa bạn và Kỵ binh) là an toàn.
- **Địch đánh trúng nhau:** đòn Kỵ binh trúng **mọi phe**. Nếu bạn né khỏi ô đỏ và phía sau có quân Nguyên khác, Kỵ binh lao tiếp và đánh **quân Nguyên đó**.
- **Bộ binh (`B`):** báo đòn vào **ô đỏ**. Cuối lượt, nó đánh đúng ô đó. **Đi khỏi ô** là tránh được.
- **Khoái (`1`):** đánh ô kề, **2 sát thương**, đẩy mục tiêu 1 ô theo hướng đánh.
- **Lão (`2`):** lao thẳng hàng, trúng quân ở cách **2–4 ô**, **1 sát thương**, không đẩy. Lao **bay qua quân ở ô kề** (cách 1 ô) — trận này không dùng tới. Rừng chặn lao.
- Hạ **chủ đòn** trước khi nó ra đòn thì đòn đã báo bị **hủy hoàn toàn**: ô đỏ biến mất, **không ai mất máu**. Nếu chỉ làm chủ đòn **mất máu** mà nó không gục, đòn vẫn giáng đúng ô đỏ — ví dụ Bộ binh còn 1 máu ở hiệp 3 vẫn đánh ô `1,1` (ô trống).
- **Đi:** mỗi tướng đi tối đa **3 ô** một lượt, theo 4 hướng (không chéo), **đi xuyên qua tướng mình** nhưng **không dừng trên quân**. Đi rồi đánh được 1 lần; đánh rồi thì không đi nữa.
- **Sông (`~`):** **không đi vào được** — chỉ là tường chắn đường đi. Đòn lao và Kỵ binh xung phong **bay qua sông**, sông không chặn đòn. Trận này **không dạy chết đuối**: lời giải không đẩy ai xuống sông.
- **Thua khi:** mọi tướng trên bàn gục (trận này 2 tướng; không có giới hạn hiệp). Một tướng gục vẫn chơi tiếp, nhưng lời giải này đặt mục tiêu **không tướng nào mất máu**.

---

## Bàn đầu trận (sau khi quân Nguyên đi và báo đòn ở hiệp 1)

```
hàng 0:  . . K . . .
hàng 1:  . . . . . .
hàng 2:  . . . . . .
hàng 3:  . . . . . .
hàng 4:  . B 1 . . K
hàng 5:  . . # . ~ ~
hàng 6:  . . 2 . . .
```

- Khoái `1` ở `2,4`; Lão `2` ở `2,6`; rừng `#` ở `2,5`; sông `~` ở `4,5` và `5,5`.
- Kỵ binh thứ nhất `K` ở `2,0`; Bộ binh `B` ở `1,4`; Kỵ binh thứ hai `K` ở `5,4`.
- **Ba ô đỏ đang nhắm Khoái `2,4`:**
  - Kỵ binh `2,0` lao thẳng xuống cột 2: đỏ `2,1`, `2,2`, `2,3`, `2,4`.
  - Bộ binh `1,4` đánh ô `2,4`.
  - Kỵ binh `5,4` lao ngang sang trái: đỏ `4,4`, `3,4`, `2,4`.

> **Bài học 1 — né ô đỏ:** Khoái đang nằm trong **ba** ô đỏ. Đi khỏi `2,4`, khỏi cột 2 và khỏi hàng 4 là thoát cả ba. Về sau, đứng trong ô đỏ chỉ an toàn khi **hạ được chủ đòn ngay trong lượt đó** (hiệp 2, hiệp 6); nếu không, phải ra ngoài.

---

## Hiệp 1 — bài học rừng chặn và địch đánh nhau

1. Bấm `1` chọn **Khoái**, bấm ô `1,3` để đi.
   - `1,3` không nằm trong ô đỏ nào: ra khỏi cột 2 (đường lao Kỵ binh `2,0`), ra khỏi hàng 4 (đường lao Kỵ binh `5,4`) và ra khỏi ô `2,4` (đòn Bộ binh).
2. Bấm **Space** (Kết thúc lượt).

Quân Nguyên ra đòn:

- **Kỵ binh `2,0` lao xuống cột 2.** Khoái đã rời đi, nên đường lao chạy tiếp `2,3` → `2,4` (trống) → **`2,5` là rừng**. Đòn **dừng ở rừng, không ai mất máu**. Lão đứng `2,6` **sau rừng** nên an toàn.
  → **Đây là chỗ dạy “rừng chặn đường lao”.**
- **Bộ binh `1,4` đánh ô `2,4`.** Ô này trống vì Khoái đã đi — không ai mất máu.
- **Kỵ binh `5,4` lao sang trái theo hàng 4.** Đường lao `4,4` → `3,4` → `2,4` (trống) → **`1,4` là Bộ binh**. Đòn trúng **Bộ binh của chính nó**: Bộ binh mất **1 máu** (còn 2).
  → **Đây là chỗ dạy “địch đánh trúng nhau”.**

Sang hiệp 2, quân Nguyên đi và báo đòn mới:

```
hàng 0:  . K . . . .
hàng 1:  . . . . . .
hàng 2:  . . . . . .
hàng 3:  . 1 . . . K
hàng 4:  . B . . . .
hàng 5:  . . # . ~ ~
hàng 6:  . . 2 . . .
```

- Khoái `1` ở `1,3`; Lão `2` ở `2,6`.
- **Ô đỏ:** Kỵ binh `1,0` lao xuống cột 1 (`1,1`, `1,2`, `1,3`); Bộ binh `1,4` đánh `1,3`; Kỵ binh `5,3` lao sang trái theo hàng 3 (`4,3`, `3,3`, `2,3`, `1,3`).

## Hiệp 2 — hạ chủ đòn để hủy đòn

1. Bấm `1`, bấm ô `1,1` để đi. (Đi vào cột 1 là đi vào ô đỏ — nhưng Khoái sẽ hạ Kỵ binh ngay trong lượt này, nên đòn của nó bị hủy.)
2. Bấm ô `1,0` để **đánh** Kỵ binh. Khoái gây 2 sát thương → **Kỵ binh gục**, ô đỏ cột 1 biến mất.
3. Bấm **Space**.

Quân Nguyên còn lại:

- Bộ binh `1,4` đánh ô `1,3` — trống, không ai mất máu.
- Kỵ binh `5,3` lao sang trái theo hàng 3: `4,3` → `3,3` → `2,3` → `1,3` → `0,3`, toàn ô trống — không ai mất máu.

```
hàng 0:  . . . . . .
hàng 1:  . 1 . . . K
hàng 2:  . B . . . .
hàng 3:  . . . . . .
hàng 4:  . . . . . .
hàng 5:  . . # . ~ ~
hàng 6:  . . 2 . . .
```

- **Ô đỏ:** Bộ binh `1,2` đánh `1,1`; Kỵ binh `5,1` lao sang trái theo hàng 1 (`4,1`, `3,1`, `2,1`, `1,1`).

## Hiệp 3 — Lão vào cuộc, đánh Bộ binh

1. Bấm `1`, bấm ô `2,2` để đi. (Ra khỏi hàng 1 và khỏi ô `1,1` — thoát cả hai ô đỏ.)
2. Bấm `2` chọn **Lão**, bấm ô `1,4` để đi. (Lão rời chỗ nấp sau rừng; `1,4` không nằm trong ô đỏ nào.)
3. Bấm ô `1,2` để **đánh**. Lão lao 2 ô, trúng Bộ binh: Bộ binh mất **1 máu** (còn **1**).
4. Bấm **Space**.

Quân Nguyên:

- Bộ binh `1,2` đánh ô `1,1` — trống.
- Kỵ binh `5,1` lao sang trái theo hàng 1 — toàn ô trống, không ai mất máu.

```
hàng 0:  . . . . . .
hàng 1:  . . . . . .
hàng 2:  . B 1 . . K
hàng 3:  . . . . . .
hàng 4:  . 2 . . . .
hàng 5:  . . # . ~ ~
hàng 6:  . . . . . .
```

- **Ô đỏ:** Bộ binh `1,2` đánh `2,2`; Kỵ binh `5,2` lao sang trái theo hàng 2 (`4,2`, `3,2`, `2,2`).

## Hiệp 4 — hạ Bộ binh

1. Bấm `1`, bấm ô `2,3` để đi. (Ra khỏi hàng 2 và khỏi ô `2,2`.)
2. Bấm `2`, bấm ô `1,2` để **đánh**. Lão lao 2 ô, trúng Bộ binh: **Bộ binh gục**.
3. Bấm **Space**.

Quân Nguyên cuối:

- Kỵ binh `5,2` lao sang trái theo hàng 2: `4,2` → `3,2` → `2,2` → `1,2` (Bộ binh đã gục) → `0,2`, không ai mất máu.

```
hàng 0:  . . . . . .
hàng 1:  . . . . . .
hàng 2:  . . . . . .
hàng 3:  . . 1 . . K
hàng 4:  . 2 . . . .
hàng 5:  . . # . ~ ~
hàng 6:  . . . . . .
```

- **Ô đỏ:** Kỵ binh `5,3` lao sang trái theo hàng 3 (`4,3`, `3,3`, `2,3`).

## Hiệp 5 — dụ Kỵ binh cuối

1. Bấm `1`, bấm ô `4,4` để đi. (Ra khỏi hàng 3; `4,4` nằm ngoài ô đỏ.)
2. Bấm **Space**.

Quân Nguyên:

- Kỵ binh `5,3` lao sang trái theo hàng 3: `4,3` → `3,3` → `2,3` → `1,3` → `0,3`, toàn ô trống.
- Sang hiệp 6, Kỵ binh đi tới `4,3` và báo đòn xuống `4,4` — đúng ô Khoái đang đứng.

```
hàng 0:  . . . . . .
hàng 1:  . . . . . .
hàng 2:  . . . . . .
hàng 3:  . . . . K .
hàng 4:  . 2 . . 1 .
hàng 5:  . . # . ~ ~
hàng 6:  . . . . . .
```

- **Ô đỏ:** `4,4`.

## Hiệp 6 — hạ Kỵ binh cuối, thắng

1. Bấm `1`, bấm ô `4,3` để **đánh** Kỵ binh. Khoái gây 2 sát thương → **Kỵ binh gục**. **Thắng.**

```
hàng 0:  . . . . . .
hàng 1:  . . . . . .
hàng 2:  . . . . . .
hàng 3:  . . . . . .
hàng 4:  . 2 . . 1 .
hàng 5:  . . # . ~ ~
hàng 6:  . . . . . .
```

**Khoái 3/3 máu, Lão 3/3 máu — không tướng nào mất một máu nào.**

---

## Vì sao trận này dạy đúng ba bài

- **Né ô đỏ (Kỵ binh báo hướng rồi lao tới vật đầu tiên):** hiệp 1 Khoái đứng trong ba ô đỏ; hiệp 2 Khoái đi vào cột 1 để hạ chủ đòn trước khi đòn giáng; hiệp 5–6 Khoái né hàng 3 rồi quay lại hạ Kỵ binh cuối. Cả trận không lần nào đứng lại trong ô đỏ lúc hết lượt.
- **Rừng chặn đường lao:** hiệp 1, Khoái né khỏi cột 2; đường lao của Kỵ binh `2,0` chạy tiếp xuống và **dừng ở rừng `2,5`**. Lão đứng `2,6`, **sau rừng**, không mất máu. Bỏ ô rừng này đi thì đòn đó trúng Lão ngay hiệp 1 — rừng là **bắt buộc**, không phải trang trí.
- **Địch đánh trúng nhau:** hiệp 1, Khoái né khỏi hàng 4; đường lao của Kỵ binh `5,4` chạy tiếp sang trái và **trúng Bộ binh `1,4`** của chính nó. Bộ binh mất 1 máu, nhờ đó Lão chỉ cần 2 đòn là hạ được nó.

## Kiểm chứng

- Trận đã được phát lại bằng đúng luật thật (`Rules` + `BattleController`, không dùng luật riêng của công cụ): **thắng ở hiệp 6, hai tướng 3/3**.
- Kịch bản tự động `game/tests/kich_ban/tran/tran_02_loi_giai.json` — **`da_duyet: true`**, `ket_qua: "thang"`, `mau` **3/3** cho cả hai tướng. `tools/test.sh` phát lại trận này mỗi lần chạy và đang đạt.
