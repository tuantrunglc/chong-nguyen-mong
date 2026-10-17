---
baseline_commit: bec53eb
---

# Story 0.4: Chữ tiếng Việt và font

Status: done

## Story

Là tác giả,
tôi muốn mọi chữ trong game nằm trong một file riêng và hiện đủ dấu,
để sau này dịch sang tiếng Anh mà không phải sửa code.

## Acceptance Criteria

1. **Cho** `game/i18n/text.csv` có khóa `app.title` = "Chống Nguyên Mông", **khi** mở game, **thì**:
   - tiêu đề hiện đúng, đủ dấu, ở giữa phía trên bàn cờ;
   - thanh tiêu đề cửa sổ cũng hiện đúng tiêu đề đó;
   - thử cả "ữ, ặ, ượ" đều hiện đủ dấu.
2. **Khi** sửa chữ trong file CSV rồi chạy lại game (`tools/chay.sh`), **thì** chữ trên màn hình đổi theo, không cần sửa code.
3. **Và** font là Be Vietnam Pro (OFL), dùng chung một Theme cho toàn game: mọi chữ (tiêu đề, nhãn phiên bản, chữ DEV) dùng font này (NFR7).
4. **Và** (bổ sung, đã kiểm chứng 2026-10-17) trên máy hoặc trình duyệt cài **ngôn ngữ khác tiếng Việt**, game vẫn hiện tiếng Việt, không hiện tên khóa như `app.title`.
5. **Và** `tools/test.sh` xanh, có test GUT kiểm:
   - mọi khóa trong `text.csv` đều dịch được, kể cả khi máy đặt ngôn ngữ tiếng Anh;
   - font có đủ toàn bộ chữ cái tiếng Việt (hoa và thường, đủ 5 dấu thanh, đủ `đ`);
   - Theme của project dùng đúng font này.

## Tasks / Subtasks

- [x] **Task 1: Font Be Vietnam Pro** (AC: 1, 3)
  - [x] 1.1 Tải từ repo `google/fonts`, **ghim theo commit** `c13390277dfb1fcc7415d84ef7ef9cfc1e52f8c1`. Đường dẫn là `https://raw.githubusercontent.com/google/fonts/<commit>/ofl/bevietnampro/<file>`. Kiểm SHA-256 trước khi chép (đã kiểm 2026-10-17):

    | File | SHA-256 | Dung lượng |
    |---|---|---|
    | `BeVietnamPro-Regular.ttf` | `cd1ef6e9d7db28ad5cdb88a65ccbe693870e60d340b791f349d248342b4fe4c3` | 132 948 byte |
    | `BeVietnamPro-Bold.ttf` | `7f738fe5c43c8872807b20e2d30d42163618de8a4daf7f48a939adac32c16847` | 140 300 byte |
    | `OFL.txt` | `6b7f8f73609a25ea78c891e34cf37b06f8a676b7ea986e941e43b009110f2a85` | 4 397 byte |

    SHA khác thì **dừng lại và báo**, không chép.
  - [x] 1.2 Chép vào `game/assets/fonts/` và đặt tên theo quy ước asset (tiền tố theo loại, `snake_case`):
    - `font_be_vietnam_pro_regular.ttf`
    - `font_be_vietnam_pro_bold.ttf`
    - `OFL.txt` (giấy phép OFL bắt buộc đi kèm font; giữ nguyên tên)
  - [x] 1.3 Không sửa file font. Để thiết lập import mặc định của Godot. Commit cả các file `.ttf.import` do `--import` sinh ra.

- [x] **Task 2: Theme dùng chung** (AC: 3)
  - [x] 2.1 Tạo `game/assets/theme/main_theme.tres`, viết tay. Mẫu dưới đây, chỉnh nếu Godot báo lỗi khi import:
    ```
    [gd_resource type="Theme" load_steps=3 format=3]

    [ext_resource type="FontFile" path="res://assets/fonts/font_be_vietnam_pro_regular.ttf" id="1_regular"]
    [ext_resource type="FontFile" path="res://assets/fonts/font_be_vietnam_pro_bold.ttf" id="2_bold"]

    [resource]
    default_font = ExtResource("1_regular")
    default_font_size = 16
    TitleLabel/base_type = &"Label"
    TitleLabel/font_sizes/font_size = 28
    TitleLabel/fonts/font = ExtResource("2_bold")
    ```
    - `TitleLabel` là *type variation*: nhãn nào đặt `theme_type_variation = &"TitleLabel"` thì dùng chữ đậm cỡ 28.
    - Cỡ chữ và kiểu chữ nằm ở **một chỗ** này, không rải trong code.
  - [x] 2.2 Thêm vào `game/project.godot` mục `[gui]` với dòng `theme/custom="res://assets/theme/main_theme.tres"`. Theme này áp lên **mọi** Control trong game, kể cả Label nằm dưới Node2D như nhãn phiên bản và chữ DEV.
  - [x] 2.3 **Không** đổi `add_theme_font_size_override` hiện có (nhãn phiên bản cỡ 14, chữ DEV cỡ 20, màu đỏ của DEV). Các nhãn đó chỉ đổi font, giữ cỡ chữ.

- [x] **Task 3: File dịch `text.csv`** (AC: 1, 2, 4)
  - [x] 3.1 Tạo `game/i18n/text.csv`, mã hóa UTF-8, **không BOM**, xuống dòng `\n`. Nội dung:
    ```
    keys,vi
    app.title,Chống Nguyên Mông
    ```
    - Cột đầu tên là `keys`, cột tiếp theo là mã ngôn ngữ.
    - Sau này thêm tiếng Anh thì chỉ cần thêm cột `en`.
    - Giá trị có dấu phẩy thì bọc trong `"..."`.
  - [x] 3.2 Thêm vào `game/project.godot`:
    ```
    [internationalization]

    locale/fallback="vi"
    locale/translations=PackedStringArray("res://i18n/text.vi.translation")
    ```
    - **`locale/fallback="vi"` là bắt buộc** (AC 4). Mặc định của Godot là `"en"`. Đã kiểm 2026-10-17 trên Godot 4.7.2: khi đặt `TranslationServer.set_locale("en")`, `tr("app.title")` trả về **`app.title`** nếu fallback là `en`, và trả về `Chống Nguyên Mông` nếu fallback là `vi`.
    - Máy tác giả đang là `vi_VN` nên sẽ không thấy lỗi này. Máy người thân và trình duyệt thì có thể thấy.
  - [x] 3.3 `--import` sinh ra hai file **ngay cạnh** CSV (không phải trong `.godot/`):
    - `game/i18n/text.vi.translation`;
    - `game/i18n/text.csv.import`.

    **Commit cả hai.** Lý do: nếu repo mới clone chưa có `text.vi.translation`, lần `--import` đầu sẽ in `ERROR: Cannot open file 'res://i18n/text.vi.translation'`, vì `project.godot` trỏ tới file chưa tồn tại (đã kiểm). `.gitignore` hiện chỉ bỏ `game/.godot/`, nên hai file này không bị bỏ qua.
  - [x] 3.4 Sửa CSV xong thì `tools/chay.sh` và `tools/test.sh` tự `--import` lại, nên file `.translation` cập nhật theo. Đây là cơ chế của AC 2. Không cần code đọc CSV lúc chạy.

- [x] **Task 4: Hiện tiêu đề** (AC: 1, 2)
  - [x] 4.1 Trong `game/src/app/main.gd` (`_ready()`), tạo `Label` tiêu đề:
    - `text = tr("app.title")`, `theme_type_variation = &"TitleLabel"`;
    - canh giữa ngang: `horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER`, `size = Vector2(BoardView.viewport_size.x, 44)`, `position = Vector2(0, 4)`.
    - Bàn cờ bắt đầu ở y = 52, nên tiêu đề nằm gọn phía trên. Chữ DEV ở góc trái (x = 8) không đè lên tiêu đề ở giữa.
    - Đặt hằng `TITLE_HEIGHT` và `TITLE_TOP` cho hai số trên.
  - [x] 4.2 Đặt tiêu đề cửa sổ: `get_window().title = tr("app.title")`. Trên web, Godot đổi theo tiêu đề tab trình duyệt.
    - `application/config/name` trong `project.godot` **giữ nguyên**. Đó là tên project, dùng trước khi script chạy.
  - [x] 4.3 Thêm tiêu đề **trước** `_board_view`, để thứ tự vẽ không đổi với các phần đã có. Giữ nguyên nhãn phiên bản, `DevTools`, `BUILD_INFO_PATH`, `_read_version()`.
  - [x] 4.4 Nhãn phiên bản (`v0.1.0 · <commit>`) và chữ "DEV" **không** qua `tr()`. Tác giả đã chốt ở Story 0.3 rằng đó là nhãn kỹ thuật, không dịch.

- [x] **Task 5: Test** (AC: 4, 5)
  - [x] 5.1 `game/tests/test_i18n.gd`:
    - đọc `res://i18n/text.csv` bằng `FileAccess`;
    - bỏ dòng tiêu đề và dòng rỗng; khóa là phần trước dấu phẩy đầu tiên (khóa không bao giờ chứa dấu phẩy);
    - với **mỗi** khóa, sau khi `TranslationServer.set_locale("en")`, kiểm `tr(khóa) != khóa` và không rỗng.
    - `before_each` lưu locale cũ; `after_each` đặt lại (`TranslationServer.set_locale(...)`).

    Các ca:
    - mọi khóa dịch được khi locale là `en`;
    - file có ít nhất khóa `app.title`;
    - `ProjectSettings.get_setting("internationalization/locale/fallback") == "vi"`.

    **Không** viết test so `tr("app.title") == "Chống Nguyên Mông"`: tác giả được quyền sửa chữ này (AC 2), test như vậy sẽ trượt oan.
  - [x] 5.2 `game/tests/test_font.gd`. Với **cả hai** file font (`load(...) as FontFile`), mọi ký tự trong chuỗi dưới đây, cùng bản `.to_upper()` của nó, đều phải có `font.has_char(ch.unicode_at(0))`:
    ```
    aàảãáạăằẳẵắặâầẩẫấậbcdđeèẻẽéẹêềểễếệghiìỉĩíịklmnoòỏõóọôồổỗốộơờởỡớợpqrstuùủũúụưừửữứựvxyỳỷỹýỵ
    ```
    Khi trượt, ghi rõ những ký tự thiếu trong thông điệp. Đã kiểm 2026-10-17: Be Vietnam Pro Regular không thiếu ký tự nào.
  - [x] 5.3 Thêm vào `test_font.gd` một ca kiểm Theme:
    - `ProjectSettings.get_setting("gui/theme/custom")` là `"res://assets/theme/main_theme.tres"`;
    - theme nạp được và `default_font.resource_path` là file Regular;
    - type variation `TitleLabel` có font Bold.
  - [x] 5.4 Mỗi test có ít nhất một assert, vì `tools/test.sh` báo trượt nếu có test không có assert nào.

- [x] **Task 6: Ghi chú cho Story 0.5** (AC: —)
  - [x] 6.1 Thêm vào `_bmad-output/implementation-artifacts/deferred-work.md`:
    - "Story 0.5: bản web phải hiện tiêu đề tiếng Việt (không phải `app.title`), kiểm trên trình duyệt đặt ngôn ngữ tiếng Anh."
    - "Giấy phép OFL yêu cầu `OFL.txt` đi kèm font khi phát hành. Preset export phải gồm `assets/fonts/OFL.txt` (filter `*.txt` hoặc đúng file đó), hoặc ghi giấy phép ở chỗ người chơi thấy được."

- [x] **Task 7: Kiểm tra** (AC: 1–5)
  - [x] 7.1 Viết test trước (Task 5), chạy `tools/test.sh` và thấy **trượt**. Ghi vào Debug Log.
  - [x] 7.2 Làm Task 1–4 tới khi `tools/test.sh` **xanh**. Dự kiến 40 + 3 + 3 ≈ 46 test. Ghi số thật.
  - [x] 7.3 Chụp khung hình bằng `--write-movie <thư mục>/f.png --quit-after 3`, có và không có `-- --dev`. Đọc ảnh, ghi vào Debug Log. Phải thấy:
    - tiêu đề "Chống Nguyên Mông" đậm, ở giữa phía trên bàn cờ;
    - nhãn phiên bản dùng font mới;
    - khi bật dev, chữ DEV đỏ dùng font mới;
    - bàn cờ ở đúng chỗ cũ.
  - [x] 7.4 Thử AC 2 trên **bản sao tạm**, không sửa repo thật:
    - sửa `app.title` thành `Thử dấu: ữ, ặ, ượ` (bọc ngoặc kép vì có dấu phẩy);
    - chạy `--import` rồi chụp khung hình: tiêu đề đổi theo, đủ dấu.
  - [x] 7.5 Thử AC 4 trên bản sao tạm: đặt `locale/fallback="en"` thì `test_i18n.gd` phải **trượt**. Việc này chứng minh test bắt được lỗi.
  - [x] 7.6 Commit khi xanh. Lời commit gợi ý: `Thêm file dịch, font Be Vietnam Pro và Theme chung (Story 0.4)`. Chuyển story sang `review`.

### Review Findings

Code review 2026-10-17. Bốn lớp: Blind Hunter, Edge Case Hunter, Verification Gap, Acceptance Auditor. Không lớp nào hỏng.

- [x] [Review][Patch] Tắt mượn font hệ thống (tác giả chốt 2026-10-17: máy hiện giống web, thiếu chữ thì thấy ô vuông ngay): đặt `allow_system_fallback=false` ở cả hai `.ttf.import` [game/assets/fonts/font_be_vietnam_pro_regular.ttf.import:22]
- [x] [Review][Patch] Không test nào chạy `main.gd`: đổi nhầm `TitleLabel`, bỏ `tr()`, xóa dòng `get_window().title` thì `tools/test.sh` vẫn xanh. Riêng tiêu đề cửa sổ: `config/name` đã là "Chống Nguyên Mông" nên mắt thường không phân biệt được dòng đó có chạy hay không. Thêm `test_main.gd` kiểm chữ tiêu đề = `tr("app.title")`, đúng `TitleLabel`, nằm trên bàn cờ (đáy < 52), tiêu đề cửa sổ = `tr("app.title")` [game/src/app/main.gd:17]
- [x] [Review][Patch] Test Theme không kiểm cỡ chữ 16/28 và `TitleLabel/base_type` (quyết định 2 của tác giả: chữ đậm cỡ 28) [game/tests/test_font.gd:29]
- [x] [Review][Patch] Test font chỉ kiểm chữ cái; chưa kiểm chữ số và dấu đang hiện trên màn hình (`·` của nhãn phiên bản, `: , . - "`) [game/tests/test_font.gd:7]
- [x] [Review][Patch] Bước 3 `tools/test.sh` quét lại thì ghi đè `import.log`: mất log lần đầu, báo cáo không nói đã quét lại. Giữ log lần đầu (`import.lan1.log`) và in một dòng "đã quét lại" [tools/test.sh:110]
- [x] [Review][Defer] Bước 3 `tools/test.sh` (quét lại khi có lỗi oan) chưa có tự kiểm: repo mới clone phải "đạt", script lỗi thật phải "trượt" [tools/test.sh:105] — deferred: cùng loại với các mục tự kiểm `test.sh` đã hoãn; chưa có khung mẫu cho repo mới clone
- [x] [Review][Defer] `config/name` vẫn viết cứng "Chống Nguyên Mông" (Task 4.2 bảo giữ): sửa `app.title` trong CSV thì tên app trên Dock macOS và tiêu đề cửa sổ trước `_ready()` vẫn là tên cũ [game/project.godot:8] — deferred: đổi thì phải sửa spec; tác giả quyết ở Story 0.5 khi làm bản xuất

#### Rejected

- Label tự dịch lại chữ đã `tr()` (dịch hai lần), tiêu đề không đổi khi đổi ngôn ngữ — low: chữ tiếng Việt không trùng khóa nào nên không hại; nút đổi ngôn ngữ thuộc Giai đoạn 2.
- Nhãn phiên bản và chữ DEV vẫn qua bộ dịch tự động — low: chỉ đổi nếu có khóa đúng là "DEV" hoặc "v0.1.0 · ..."; không có.
- `_keys()` tách CSV bằng tay: khóa có ngoặc kép, giá trị nhiều dòng, dòng khóa rỗng — low: tác giả chỉ sửa giá trị; giá trị có dấu phẩy vẫn tách đúng khóa.
- CSV có BOM làm hỏng test — false: BOM chỉ nằm ở dòng tiêu đề, mà `_keys()` bỏ dòng 0.
- Excel lưu bằng dấu `;` — false: test trượt rõ ràng (khóa thành `app.title;...`), đúng hành vi.
- Dấu dạng tổ hợp (NFD) — maybe-false, nếu có cũng chỉ low: chưa có chữ NFD nào trong CSV.
- Sửa CSV làm `text.vi.translation` thành "đã sửa" — low: file sinh lại giống hệt khi CSV trả về như cũ (git status sạch sau các lần chạy).
- Thiếu `text.vi.translation` mà `test.sh` không bắt — false: `test_every_key_translates_on_english_machine` trượt vì `tr()` trả về tên khóa.
- Tiêu đề dài tràn hoặc đè chữ DEV — low: màn hình rộng 1280, cỡ 28 chứa được khoảng 60 chữ.
- Thiếu bản dịch thì không ghi log — low: test đã bắt.
- `theme.get_font` trả font mặc định nên thông báo lỗi chỉ sai đường dẫn — low: chỉ là chữ trong thông báo, test vẫn trượt đúng.
- Font không phải `FontFile` thì thông báo lẫn với "không nạp được" — low: test vẫn trượt.
- Lần quét đầu thoát mã khác 0 không được quét lại — false: Debug Log ghi bản sao mới clone ra "đạt".
- `chay.sh` trên repo mới clone gặp lỗi oan mà im lặng — maybe-false, nếu có cũng chỉ low: Theme được nạp lúc game chạy, khi font đã quét xong.
- Dòng mẫu "Ultimate context engine analysis completed" trong Completion Notes; hướng dẫn sửa CSV chưa cảnh báo Excel — sửa chính file story đang review.

## Dev Notes

### Bối cảnh

- Story 0.1–0.3 đã xong (commit `bec53eb`).
- Màn hình chính (`main.gd`) hiện có:
  - bàn cờ 7×7 giữa màn hình (x 332–948, y 52–668);
  - nhãn phiên bản ở góc dưới phải (cỡ 14);
  - chữ "DEV" đỏ ở góc trên trái khi bật dev (`DevTools`, cỡ 20).
- Tất cả đang dùng font mặc định của Godot. Font này có dấu tiếng Việt nhưng không phải font OFL đã chọn.
- Repo **chưa có** `game/i18n/`, `game/assets/`, mục `[gui]` hay `[internationalization]` trong `project.godot`.
- Có `AppState` (autoload) và `Log`. Story này **không cần** sửa hai file đó.
- Ngân sách E0 khoảng 12 giờ cho 6 story. Story này khoảng 1–2 giờ.

### File sẽ sửa (đọc trước khi sửa)

**`game/src/app/main.gd`**: `extends Node2D`. `_ready()` lần lượt làm ba việc:
1. tạo `BoardView` rồi `add_child`;
2. tạo nhãn phiên bản: `Label`, text `"v%s · %s"`, `add_theme_font_size_override("font_size", 14)`, canh phải và dưới, `size (400, 40)`, đặt ở góc dưới phải;
3. tạo `DevTools`, gọi `setup(AppState.launch.dev)` rồi `add_child`.

Có hằng `BUILD_INFO_PATH`, `VERSION_FONT_SIZE`, `VERSION_MARGIN`, và hàm `_read_version()`.
- **Thay đổi:** thêm nhãn tiêu đề (trước bàn cờ) và đặt tiêu đề cửa sổ.
- **Giữ nguyên:** mọi thứ còn lại.

**`game/project.godot`** (viết tay): có các mục `[application]`, `[autoload]`, `[debug]`, `[display]`, `[rendering]`.
- **Thay đổi:** thêm `[gui]` và `[internationalization]`. Godot xếp các mục theo thứ tự chữ cái (`[gui]` sau `[display]`, `[internationalization]` sau `[gui]`), nên đặt đúng chỗ để `--import` không tự viết lại file.
- Sau khi sửa, chạy `--import` rồi `git diff game/project.godot`: chỉ có các dòng mình thêm.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Thêm cột tiếng Anh | Giai đoạn 2 |
| Chọn ngôn ngữ trong game | Giai đoạn 2 |
| Chữ của HUD, menu, màn lỗi (khóa `hud.*`, `error.*`...) | Story tạo ra chữ đó thêm khóa vào `text.csv` |
| Preset export, kiểm bản web | 0.5 (xem Task 6) |
| Màn hình credit ghi giấy phép font | Chưa lên lịch; tạm thời `OFL.txt` đi kèm |
| Dịch log | Không làm. Log là cho AI và tester, không phải chữ hiển thị |

### Luật kiến trúc phải theo

- **Bản địa hóa:** file CSV dịch `i18n/text.csv` (cột `keys`, `vi`, sau này thêm `en`). Mọi chữ hiển thị đi qua `tr()`. Khóa dạng `<man>.<muc>` (`app.title`, `hud.end_turn`). [Source: game-architecture.md quyết định #20; #Cây thư mục; #Quy ước đặt tên]
- **Font:** tiếng Việt đủ dấu, giấy phép OFL (Be Vietnam Pro hoặc Noto Sans). [Source: game-architecture.md quyết định #18]
  - Chọn **Be Vietnam Pro**: thiết kế cho tiếng Việt, đã kiểm đủ ký tự, hai file chỉ khoảng 270 KB.
- **UI:** Control node, **một Theme dùng chung** (`assets/theme/main_theme.tres`), HUD dựng bằng code. [Source: game-architecture.md quyết định #17; #Cây thư mục]
- **Đặt tên asset:** tiền tố theo loại, `snake_case`. Ví dụ đúng: `font_be_vietnam_pro_bold.ttf`. [Source: game-architecture.md#Quy ước đặt tên → File]
- **Chữ hiển thị chỉ qua `tr()`** (kiểm bằng review). Ngoại lệ đã chốt: nhãn phiên bản và chữ DEV. [Source: game-architecture.md#Luật nhất quán; Story 0.3]
- **Scene nhỏ và phẳng:** không thêm node vào `main.tscn`, tạo nhãn bằng code. **Không** việc nào đòi mở editor. [Source: project-context.md]
- **Dung lượng web** ≤ 25 MB bản nén: hai font khoảng 270 KB, không đáng kể. [Source: project-context.md#Hiệu năng]
- **Gõ kiểu tĩnh mọi nơi**, kể cả test. `load()` trả `Resource`: ép bằng `as FontFile` / `as Theme`. [Source: project-context.md]

### Ghi chú kỹ thuật (đã kiểm trên Godot 4.7.2, ngày 2026-10-17, trên bản sao tạm)

- Bộ import CSV (`csv_translation`) mặc định `compress=1`, `delimiter=0` (dấu phẩy), `unescape_translations=true`. Giữ mặc định. Bộ này sinh `text.vi.translation` **cạnh** CSV.
- `TranslationServer.get_locale()` trên máy tác giả là `vi_VN`. `tr()` khớp `vi` nhờ cơ chế khớp theo mã ngôn ngữ.
- Không có `locale/fallback="vi"` thì locale `en` trả về chính khóa (`app.title`). Có thì trả tiếng Việt.
- Thiếu `text.vi.translation` khi `--import` lần đầu sẽ in 2 cặp `ERROR: Cannot open file` / `Failed loading resource`. Lệnh vẫn thoát mã 0, và `tools/test.sh` không bắt lỗi này (chỉ bắt `SCRIPT ERROR|Parse Error`). Commit file `.translation` để tránh.
- `FontFile.has_char(int)` dùng được trên font nạp bằng `load()`. Không cần mở editor.
- `tr()` là hàm của `Object`, nên gọi được trong `GutTest`.

### Cấu trúc file sau story

```
game/
├── project.godot                       # + [gui] theme/custom, + [internationalization]
├── assets/
│   ├── fonts/
│   │   ├── font_be_vietnam_pro_regular.ttf (+ .import)
│   │   ├── font_be_vietnam_pro_bold.ttf    (+ .import)
│   │   └── OFL.txt
│   └── theme/
│       └── main_theme.tres
├── i18n/
│   ├── text.csv
│   ├── text.csv.import                 # Godot sinh, commit
│   └── text.vi.translation             # Godot sinh, commit
├── src/app/main.gd                     # + tiêu đề, + tiêu đề cửa sổ
└── tests/
    ├── test_i18n.gd                    # MỚI
    └── test_font.gd                    # MỚI
```

Kèm theo các file `.uid` do Godot sinh.

### Testing

- Test GUT: `test_i18n.gd`, `test_font.gd`. Chạy không cần màn hình.
- Hình ảnh (tiêu đề đậm ở giữa, font mới) kiểm bằng khung hình `--write-movie` và bằng mắt tác giả.
- **Hướng dẫn tác giả tự test** (ghi vào Completion Notes):
  1. Gõ `tools/test.sh` → dòng cuối là `✅ N/N test đạt`.
  2. Gõ `tools/chay.sh` → phía trên bàn cờ có tiêu đề **Chống Nguyên Mông**, chữ đậm. Thanh tiêu đề cửa sổ cũng ghi như vậy.
  3. Mở `game/i18n/text.csv` bằng trình soạn thảo bất kỳ. Sửa dòng `app.title` thành `app.title,"Thử dấu: ữ, ặ, ượ"`, lưu, gõ lại `tools/chay.sh` → tiêu đề đổi theo, đủ dấu. Sửa lại như cũ (hoặc nhờ AI trả lại).
  4. Gõ `tools/chay.sh --dev` → chữ DEV và nhãn phiên bản cùng kiểu chữ với tiêu đề (chữ thường, không đậm).

### Previous Story Intelligence (Story 0.3 và review)

- `test.sh` báo trượt nếu một test không có assert, hoặc nếu số file `test_*.gd` khác số file thật sự chạy.
- `check_boundaries.sh` cấm mọi lệnh `print*()`, `push_error`, `push_warning` trong `src/` ngoài `src/debug/log.gd`. Muốn báo gì thì dùng `Log`.
- Biến static (`Log`) và trạng thái toàn cục (`InputMap`, và từ story này là `TranslationServer` locale) **sống qua các file test**. Test nào đổi thì phải trả lại trong `after_each`.
- Godot tự bật lại `set_process_*` khi node vào cây. Đây là bài học từ review 0.3; story này không gặp.
- Tham số khởi động phải đặt **sau** `--`. `--write-movie` thì đặt **trước** `--`.
- Chụp màn hình: dùng `--write-movie`, không dùng `screencapture`. Nhãn phiên bản chỉ đúng mã commit khi chạy qua `tools/chay.sh`, vì `chay.sh` ghi `build_info.json`. Chạy Godot trực tiếp thì nhãn hiện mã cũ, không phải lỗi.
- Thay đổi trạng thái chung trên bản sao tạm (`git archive HEAD game | tar -x`), không trên repo thật.

### Git Intelligence

- 5 commit gần nhất:
  - `bec53eb Sửa theo code review Story 0.3`
  - `e460c96 Thêm Log, cờ dev và tham số khởi động (Story 0.3)`
  - `bedf0fe Tạo story 0.3`
  - `747f150 Sửa theo code review Story 0.2`
  - `271e529 Thêm tools/test.sh, GUT 9.7.1 và kiểm ranh giới (Story 0.2)`
- Mẫu đã có:
  - GDScript: tên tiếng Anh, chú thích `##` tiếng Việt ở đầu file, hằng `UPPER_SNAKE_CASE`, gõ kiểu đủ.
  - Tài nguyên bên ngoài: ghim phiên bản và kiểm SHA-256, như GUT ở Story 0.2.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- Godot **4.7.2.stable**, GUT **v9.7.1**. Không tự nâng phiên bản.
- Mọi chữ hiển thị đi qua `tr()`, khóa dạng `<man>.<muc>`.
- Font tiếng Việt đủ dấu (OFL). Một Theme dùng chung.
- Scene nhỏ và phẳng; không việc nào đòi mở editor.
- Gõ kiểu tĩnh mọi nơi; `untyped_declaration` là error, áp cả lên `game/tests/`.
- Không `print()`: dùng `Log`.
- "Xong" nghĩa là `tools/test.sh` xanh rồi commit. Lời commit tiếng Việt.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### Quyết định của tác giả (2026-10-17)

1. **Font Be Vietnam Pro** (không phải Noto Sans): làm riêng cho tiếng Việt, đã kiểm đủ dấu.
2. **Vị trí tiêu đề:** giữa phía trên bàn cờ, chữ đậm cỡ 28. Tiêu đề cửa sổ cũng lấy từ `text.csv`.

### References

- `_bmad-output/planning-artifacts/epics.md#Story 0.4`
- `_bmad-output/planning-artifacts/game-architecture.md`: quyết định #17, #18, #20; #Cây thư mục; #Quy ước đặt tên; #Luật nhất quán
- `_bmad-output/project-context.md`: #Luật riêng của Godot, #Tổ chức code, #Nền tảng và build
- `_bmad-output/implementation-artifacts/0-3-log-co-dev-va-tham-so-khoi-dong.md`: Dev Notes, Review Findings
- Font: `https://github.com/google/fonts/tree/c13390277dfb1fcc7415d84ef7ef9cfc1e52f8c1/ofl/bevietnampro`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Đỏ trước khi viết code: `❌ trượt: 6 test trượt` (3 test i18n, 3 test font), mã 1.
- Font tải theo commit `c13390277dfb…`, `shasum -a 256 -c` đều OK cho cả 3 file.
- **Phát hiện khi làm:** lần `--import` đầu trên repo vừa clone (chưa có `game/.godot/`), Godot nạp Theme của project **trước** khi quét font, nên in `Parse Error: [ext_resource] referenced non-existent resource` (10 dòng ERROR). Lần quét thứ hai sạch, 0 ERROR. Bước 3 của `tools/test.sh` (thêm ở review 0.2) bắt `Parse Error` nên báo đỏ oan.
  - Sửa: nếu lần quét đầu có `SCRIPT ERROR|Parse Error` thì quét lại một lần, chỉ xét log lần hai.
  - Kiểm trên bản sao như repo vừa clone: `✅ 46/46`. Cùng bản sao, thêm dòng hỏng vào `main.gd` → `[3/4] Quét project: trượt`, chỉ `main.gd:48`, `❌ trượt: có script game lỗi`.
- Sau khi viết code: `✅ 46/46 test đạt`, mã 0 (40 cũ + 3 i18n + 3 font).
- `git diff game/project.godot` sau `--import`: chỉ có các dòng `[gui]` và `[internationalization]` đã thêm.
- Khung hình `--write-movie` (khung thứ 3):
  - không dev: tiêu đề "Chống Nguyên Mông" đậm ở giữa trên bàn cờ; bàn cờ đúng chỗ; nhãn phiên bản dùng Be Vietnam Pro;
  - có dev: thêm chữ DEV đỏ, cùng font.
- AC 2 trên bản sao: đổi `app.title` thành `"Thử dấu: ữ, ặ, ượ"` → tiêu đề hiện `Thử dấu: ữ, ặ, ượ` đủ dấu.
- AC 4 trên bản sao: đặt `locale/fallback="en"` → `test_every_key_translates_on_english_machine` và `test_fallback_locale_is_vietnamese` trượt, mã 1.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Font Be Vietnam Pro Regular và Bold (OFL), kèm `OFL.txt`, trong `game/assets/fonts/`. Theme `main_theme.tres` dùng font Regular cỡ 16, có kiểu `TitleLabel` chữ đậm cỡ 28. Theme đặt làm theme của cả project (`gui/theme/custom`).
- `game/i18n/text.csv` có khóa `app.title`. Thêm `locale/fallback="vi"` để máy tiếng Anh vẫn ra tiếng Việt. Commit cả `text.vi.translation` và `text.csv.import` do Godot sinh.
- `main.gd`: tiêu đề `tr("app.title")` ở giữa phía trên bàn cờ, và đặt tiêu đề cửa sổ.
- **Lệch so với story:** sửa thêm `tools/test.sh` bước 3 (quét lại một lần khi lần đầu có lỗi). Không sửa thì repo vừa clone báo đỏ oan ngay lần đầu. Xem Debug Log.
- **Hướng dẫn tác giả tự test:**
  1. Gõ `tools/test.sh` → dòng cuối `✅ 46/46 test đạt`.
  2. Gõ `tools/chay.sh` → phía trên bàn cờ có tiêu đề **Chống Nguyên Mông**, chữ đậm. Thanh tiêu đề cửa sổ cũng ghi như vậy.
  3. Mở `game/i18n/text.csv`, sửa dòng `app.title` thành `app.title,"Thử dấu: ữ, ặ, ượ"`, lưu, gõ lại `tools/chay.sh` → tiêu đề đổi theo, đủ dấu. Rồi sửa lại như cũ (hoặc nhờ AI trả lại).
  4. Gõ `tools/chay.sh --dev` → chữ DEV và nhãn phiên bản cùng kiểu chữ với tiêu đề (chữ thường).

### File List

- `game/assets/fonts/font_be_vietnam_pro_regular.ttf` (+ `.import`) (mới)
- `game/assets/fonts/font_be_vietnam_pro_bold.ttf` (+ `.import`) (mới)
- `game/assets/fonts/OFL.txt` (mới)
- Hai file `.ttf.import`: sau code review đặt `allow_system_fallback=false`
- `game/assets/theme/main_theme.tres` (mới)
- `game/i18n/text.csv`, `text.csv.import`, `text.vi.translation` (mới; hai file sau do Godot sinh)
- `game/project.godot` (sửa: `[gui]`, `[internationalization]`)
- `game/src/app/main.gd` (sửa: tiêu đề, tiêu đề cửa sổ)
- `game/tests/test_i18n.gd`, `.uid` (mới)
- `game/tests/test_font.gd`, `.uid` (mới)
- `game/tests/test_main.gd`, `.uid` (mới, sau code review)
- `tools/test.sh` (sửa: bước 3 quét lại khi lần đầu có lỗi)
- `_bmad-output/implementation-artifacts/deferred-work.md` (thêm 2 mục cho Story 0.5)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (trạng thái)
- `_bmad-output/implementation-artifacts/0-4-chu-tieng-viet-va-font.md` (story này)

### Change Log

- 2026-10-17: Thêm font Be Vietnam Pro, Theme chung, file dịch `text.csv` (fallback `vi`), tiêu đề màn hình và cửa sổ; 6 test mới (tổng 46). `tools/test.sh` quét project lại một lần khi lần đầu có lỗi (repo vừa clone).
- 2026-10-17: Sửa theo code review: tắt mượn font hệ thống (tác giả chốt); thêm `test_main.gd` (4 test: chữ tiêu đề, kiểu chữ đậm, nằm trên bàn cờ, tiêu đề cửa sổ); test Theme kiểm cỡ chữ 16/28; test font kiểm chữ số và dấu; `tools/test.sh` giữ log lần quét đầu (`import.lan1.log`) và báo "đã quét lại". Tổng 50 test.
