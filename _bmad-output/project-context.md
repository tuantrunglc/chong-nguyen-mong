---
project_name: 'GameTest (Chống Nguyên Mông, tên tạm)'
user_name: 'Trung.nguyen11'
date: '2026-10-16'
sections_completed: ['technology_stack', 'engine_rules', 'performance', 'organization', 'testing', 'platform', 'anti_patterns']
existing_patterns_found: 0
status: 'complete'
rule_count: 57
optimized_for_llm: true
source: '_bmad-output/planning-artifacts/game-architecture.md'
language: 'vi'
---

# Bối cảnh dự án cho AI

_File này chứa các luật và mẫu mà mọi phiên AI phải theo khi viết code cho dự án. Chỉ ghi những điều dễ bị bỏ sót. Chi tiết đầy đủ nằm trong `game-architecture.md`._

---

## Công nghệ và phiên bản

| Thứ | Phiên bản | Ghi chú |
|---|---|---|
| Godot | **4.7.2.stable** (standard, không .NET) | Chỉ GDScript. Renderer Compatibility. Không tự nâng phiên bản |
| GUT | **v9.7.1** | Chép vào `game/addons/gut/`, chạy `--headless` |
| GoPeak | **2.3.8**, profile `compact` | Ghim phiên bản, không `npx -y gopeak` trần |
| Context7 | — | Tra API Godot 4.7 trước khi dùng API lạ |
| butler | bản mới nhất | Chỉ dùng trong `tools/deploy_itch.sh` |

- Lối thoát duy nhất là lùi về Godot 4.6.3, và chỉ khi tác giả đồng ý. **Không đề xuất đổi engine.**

## Luật triển khai bắt buộc

### Luật riêng của Godot

- **Chỉ cú pháp Godot 4:** `await`, `@export`, `@onready`, `signal.connect(callable)`. Cấm `yield`, `export var`, `onready var`, `connect("tên", obj, "hàm")`.
- **Gõ kiểu tĩnh mọi nơi.** `untyped_declaration` là error. Giá trị từ `JSON.parse_string()` là `Variant`: phải kiểm tra kiểu rồi ép kiểu tường minh, không dùng `:=` trực tiếp trên nó.
- **JSON trả mọi số về `float`.** Luôn `int()` các giá trị máu, tọa độ, thứ tự khi nạp. Luật không bao giờ tính bằng `float`.
- **`clone()` phải tự viết, sao chép sâu từng `Unit` và `Telegraph`.** `Array.duplicate(true)` **không** sao chép object `RefCounted` bên trong; hoàn tác sẽ hỏng âm thầm.
- **Scene nhỏ và phẳng.** File `.tscn` chỉ là khung vài node. Ô, quân, ô đỏ đều sinh bằng code. Signal nối trong code. Không có việc nào đòi tác giả mở editor.
- **Lấy node bằng `%TênDuyNhất`.** Cấm đường dẫn `/root/...`, hạn chế `get_node("../..")`.
- **Đi xuống thì gọi hàm, đi lên thì phát signal.** Không Event Bus. `app_state.gd` là **autoload duy nhất**; `Log` là lớp static, không phải autoload.
- **Hoạt ảnh dùng `Tween`** và chỉ phát lại `BattleEvent`. Không đọc trạng thái sống, không sửa trạng thái.
- **Không dùng** vật lý, `AStarGrid2D`, TileMap để chứa luật, StateMachine dạng Node, behavior tree, object pool.

### Hiệu năng

- Mục tiêu: **60 FPS** trên laptop văn phòng dùng card tích hợp, chạy trên trình duyệt. Bàn tối đa 10×8 (80 ô) nên hiệu năng **không phải vấn đề**: không tối ưu sớm, không dùng object pool, không cache phức tạp.
- **Không lặp cứng cỡ bàn** (`range(7)`, `49`). Luôn dùng `level.size` hoặc cỡ của trận thử. Mỗi trận có cỡ riêng, từ 5×5 đến 10×8 (2026-10-20).
- `clone()` rẻ, cứ dùng thoải mái cho hoàn tác và xem trước.
- **Xem trước** chỉ chạy lại khi ô trỏ chuột đổi, không chạy mỗi khung hình trong `_process`.
- Mỗi pha địch ra đòn **≤ 3 giây** hoạt ảnh. Tua nhanh bằng cách đổi tốc độ Tween, không bỏ qua sự kiện.
- **Web đơn luồng:** không dùng `Thread`, không dùng `WorkerThreadPool`.
- **Dung lượng:** bản nén ≤ 25MB (`build_web.sh` tự kiểm tra). Nạp sẵn toàn bộ asset, không nạp động.

### Tổ chức code

- Project Godot nằm trong **`game/`**. Lệnh cho tác giả nằm trong **`tools/`**, chạy từ gốc repo.
- **Tầng, đi từ trong ra ngoài:** `src/core` (luật) → `src/data` (nạp file) → `src/battle` + `src/ui` (hiển thị) → `src/app` (màn hình, `AppState`). `src/debug` chứa code chỉ chạy khi bật dev.
- **`src/core/` là vùng cấm:** chỉ `RefCounted`; không `Node`, `get_tree()`, `$`, `Input`, `FileAccess`, `Time`, `randi`/`randf`, `print`. `check_boundaries.sh` sẽ báo trượt nếu vi phạm.
- **Điểm vào duy nhất của luật:** `Rules.resolve(state, command) -> Array[BattleEvent]`. Luật mới thì đặt vào file `rules_<mảng>.gd` đúng mảng, không tạo file luật ở chỗ khác.
- **Chỉ `Effects.damage` / `Effects.move` được đổi máu và vị trí.** Đẩy/kéo đi qua `ForcedMove.run`, từng ô một.
- **Chỉ `BattleController` giữ trạng thái sống.** UI gửi `Command` qua `submit()`; không bao giờ sửa `BattleState`.
- **Quân chỉ tạo qua `UnitFactory.create`:** id tướng là 1–3, quân Nguyên từ 101.
- **Đặt tên:**
  - code và tên script viết tiếng Anh, `snake_case`;
  - `class_name` dùng PascalCase;
  - file dữ liệu, kịch bản và khóa JSON viết **tiếng Việt không dấu** (`chi_so.json`, `thu_tu_dich`);
  - tên riêng lịch sử viết UPPER không dấu (`NGUYEN_KHOAI`);
  - tọa độ là `Vector2i(cot, hang)`, gốc ở góc trên trái; trong file ghi dạng `"cot,hang"`.
- **Thuật ngữ:** *hiệp* = cả 4 pha; *lượt người chơi* = chỉ pha `PLAYER`. Không dùng lẫn hai từ này.
- **Con số cân bằng chỉ nằm trong `data/chi_so.json`.** Chữ hiển thị chỉ đi qua `tr()`, với khóa dạng `<man>.<muc>`.
- **Log** gọi qua `Log.error/warn/info/debug("he_thong", "...")`, không dùng `print()`. Lõi luật không ghi log trong vòng phân giải.

### Test

- **Một lệnh duy nhất:** `tools/test.sh`, chạy từ gốc repo. Lệnh này:
  1. chạy `check_boundaries.sh`;
  2. kiểm tra khóa `da_duyet`;
  3. chạy toàn bộ GUT `--headless`;
  4. in tóm tắt **tiếng Việt**.
  Mã thoát khác 0 nghĩa là **trượt**.
- **Kịch bản luật là spec** (`game/tests/kich_ban/<nhóm>/<luat>_<truong_hop>.json`). Mỗi kịch bản gồm `truoc` (bàn cờ chữ), `hanh_dong`, `sau` (bàn cờ chữ + máu, thêm `hiep` và `da_di` khi cần kiểm số hiệp và tướng đã đi), `mo_ta` (một câu tiếng Việt), `da_duyet`. Lệnh luật phải từ chối ghi thêm `"tu_choi": "<mã lý do>"`, bắt buộc (tác giả chốt 2026-10-18).
- **Quy trình M3, không ngoại lệ:**
  1. AI viết kịch bản (ca thường và mọi ca biên đã biết), đặt `da_duyet: false`.
  2. Tác giả duyệt bằng `tools/xem_kich_ban.sh`, mỗi story luật một đợt nhỏ, trước khi viết code.
  3. Chạy test: kịch bản mới phải **trượt**.
  4. Viết code cho tới khi toàn bộ test **xanh**.
- **Cấm** xóa hoặc sửa kịch bản `da_duyet: true` để test đạt. Kịch bản đúng mà code sai thì sửa code. Nghi kịch bản sai thì **hỏi tác giả**, đừng tự quyết.
- **Báo lỗi F2:** việc đầu tiên là chuyển báo lỗi thành kịch bản tái hiện (trượt), rồi mới sửa.
- **Mọi test chạy không cần màn hình:** lõi luật test trực tiếp bằng `BattleState` + `Rules.resolve`. Không có test tự động cho UI và hoạt ảnh; phần đó tác giả test bằng tay.
- Sau mỗi lần phân giải trong test, gọi `state.validate()`. Phải rỗng.
- **Tất định:** `test_determinism.gd` chạy mỗi kịch bản hai lần, kết quả phải giống hệt. Duyệt quân theo `order` hoặc `thu_tu_dich`, không duyệt theo khóa Dictionary.
- Bộ nạp dữ liệu có `test_loaders.gd`: file sai phải ra **đúng** câu lỗi tiếng Việt, kèm file, dòng và giá trị sai.
- **Xong một việc** nghĩa là `tools/test.sh` xanh, sau đó commit. Không bao giờ báo "xong" khi chưa chạy test.

### Nền tảng và build

- **Chỉ làm bản web** (Chrome, Firefox, Edge trên desktop). Bản Windows/Steam để giai đoạn 2. Không làm riêng cho Safari hay điện thoại.
- **Export đơn luồng**, không cần SharedArrayBuffer hay header COOP/COEP. Renderer **Compatibility** (WebGL 2).
- **Build bằng dòng lệnh** (`tools/build_web.sh` chạy `--headless --export-release`). Không cần mở editor.
- **Preset export phải:**
  - có filter **`*.json`** (thiếu thì bản web không có dữ liệu trận);
  - loại trừ `tests/*` và `addons/gut/*`.
- **Lưu game** là JSON trong `user://`, có trường phiên bản. Trên web, `user://` là IndexedDB và phải chạy được trong iframe của itch.io.
- **Âm thanh** chỉ phát sau lần bấm đầu tiên của người chơi, vì trình duyệt chặn âm thanh tự phát.
- **Input:** mọi thao tác phải làm được bằng **một cú bấm chuột**. Phím tắt (1-2-3, Q/W, Z, Space, R) khai báo trong InputMap, không bắt phím trực tiếp. Không dùng thao tác chỉ có trên bàn phím hoặc chỉ có khi rê chuột.
- **Độ phân giải** 1280×720, stretch `canvas_items`, aspect `keep`. Font tiếng Việt đủ dấu (OFL).
- **Bật dev** bằng `?dev=1` (web) hoặc `--dev` (desktop). Phím F1/F2/F3/F5 phải **không có tác dụng** khi không bật dev. Phiên bản build và mã commit luôn hiện ở góc màn hình.
- **Deploy** bằng `tools/deploy_itch.sh` (butler). Mặc định để **riêng tư**; chỉ công khai khi tác giả nói.

### Những điều không được quên

- **Luật không có trong GDD hay trong bảng thứ tự phân giải thì HỎI tác giả.** Không tự đoán rồi viết code. Tác giả là người quyết spec, AI không quyết.
- **Đòn địch lưu tương đối** (`owner_id` + `offset`), không lưu ô tuyệt đối. Chủ đòn bị đẩy thì đòn dịch theo; dịch ra ngoài bàn thì đòn bị hủy.
- **Đòn trúng mọi phe,** kể cả quân Nguyên đánh nhau. Đòn của địch chỉ gây sát thương, không đẩy.
- **Đẩy/kéo đi từng ô:** mép bàn, rừng, kho lương hoặc quân khác thì dừng và mất 1 máu (va vào quân thì cả hai mất). Sông: quân Nguyên chết đuối, tướng tính như va chạm. **Hầm chông trừ máu cả khi chỉ đi ngang qua.**
- **Thứ tự cố định B→Đ→N→T** cho mọi trường hợp hòa: BFS, chọn ô đứng, chọn đường. Không dùng số ngẫu nhiên trong combat.
- **Kiểm tra thắng/thua sau mỗi sự kiện gây gục.** Thắng được ưu tiên khi thắng và thua xảy ra cùng lúc.
- **Hủy nước đi** chỉ áp dụng cho nước gần nhất, đúng **một** nước (hủy xong phải đi nước mới mới hủy tiếp; tác giả chốt 2026-10-18), khi tướng đó chưa đánh. **Đánh, dùng mưu kế hoặc kết thúc lượt thì xóa bản chụp hủy.** **Chơi lại hiệp** mỗi trận chỉ được 1 lần, trả lại cả mưu kế đã dùng trong lượt.
- **Không được chọn tướng mình làm mục tiêu.** Bấm vào tướng mình luôn là chọn tướng. Tướng mình chỉ trúng đòn như hệ quả (lao, va chạm).
- **Số tướng do file trận quy định** (trận 1–2: 2 tướng). Thua khi *mọi tướng trên bàn* gục, không viết cứng số 3.
- **Không để game kẹt:** `validate()` thất bại thì ghi log ERROR, khôi phục bản chụp trước và báo cho người chơi. Lỗi dữ liệu trả về `LoadResult` với câu lỗi tiếng Việt. Không dùng `assert()` cho lỗi dữ liệu.
- **Git:** chỉ commit khi test xanh, lời commit viết tiếng Việt. Không `push --force`, không viết lại lịch sử.
- **Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được:** dùng bàn cờ chữ, tên luật, các bước để thử. Không bắt tác giả đọc code.

---

## Cách dùng

**Với AI:**
- Đọc file này **trước khi viết bất kỳ dòng code nào**. Chi tiết (bảng thứ tự phân giải, ADR, cây thư mục) tra trong `_bmad-output/planning-artifacts/game-architecture.md`.
- Theo đúng mọi luật. Khi phân vân, chọn phương án chặt hơn, hoặc hỏi tác giả.
- Có mẫu mới lặp lại nhiều lần thì đề xuất bổ sung vào file này. Tác giả duyệt rồi mới ghi.

**Với tác giả:**
- Giữ file gọn, chỉ ghi điều AI hay quên.
- Cập nhật khi đổi phiên bản công cụ hoặc khi chốt luật mới.
- Xem lại sau mỗi epic, xóa luật đã lỗi thời.

Cập nhật lần cuối: 2026-10-16
