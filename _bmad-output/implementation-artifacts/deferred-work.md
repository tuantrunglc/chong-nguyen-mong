## Deferred from: code review of 0-1-project-godot-trong-chay-duoc-tren-may (2026-10-17)

- Chưa có test tự động cho `_read_commit` trong `game/src/app/main.gd` (các trường hợp: thiếu file, JSON hỏng, không phải Dictionary, `commit` sai kiểu hoặc rỗng). Viết test GUT ở Story 0.2. → xong ở Story 0.2 (`BuildInfo.read_commit`, `game/tests/test_build_info.gd`).
- Chưa có test tự động cho việc canh giữa và kích thước trong `BoardView.setup` (7×7 cho vị trí (332, 52); bàn cờ không vuông). Story 0.2 không làm; làm khi có kích thước bàn thứ hai. → xong ở Story 1.7 (bàn nghiêng: `test_board_fits_left_of_hud_below_title`, `test_board_rect_covers_every_cell_and_token` trong `game/tests/test_board_view.gd`).
- Chưa có test cho logic commit/`-sua` trong `tools/chay.sh` và việc `kiem_tra` từ chối file sai checksum trong `tools/cai_dat.sh`. Xét lại khi có `tools/test.sh`.
- Chưa kiểm chứng: bản export có thể không chứa `res://build_info.json` (`.json` không nằm trong danh sách export mặc định), khi đó nhãn hiện `dev`. Story 0.5 cần thêm `*.json` vào bộ lọc include và kiểm tra lại.

## Deferred from: code review of 0-2-mot-lenh-de-chay-toan-bo-test (2026-10-17)

- Khóa `da_duyet` (bước 2 của `tools/test.sh`) chưa có tự kiểm tự động: nếu regex hoặc danh sách file hỏng thì vẫn ra "đạt (0 file)" giống hôm nay. Thêm khi có kịch bản đã duyệt đầu tiên (git repo tạm, commit file khóa, sửa, đòi trượt).
- Các nhánh chống xanh giả ở bước 4 của `tools/test.sh` (thiếu XML, lỗi cú pháp, lệch số file, 0 test, mã GUT ≠ 0) chỉ được kiểm bằng tay. Cần tách phần đọc XML/log thành hàm nhận file mẫu.
- Godot treo (import hoặc test `await` mãi) thì `tools/test.sh` không kết thúc. macOS không có sẵn `timeout`, cần cơ chế riêng.
- Luật core chưa chặn `OS.get_ticks_msec()`/`OS.get_unix_time()`, `Engine.get_main_loop()`, `rand_from_seed(`. Cần cập nhật luật trong game-architecture.md rồi mới thêm vào `tools/check_boundaries.sh`.

## Deferred from: Story 0.3 (2026-10-17)

- Chưa kiểm chứng: trên itch.io, game chạy trong iframe có địa chỉ riêng (`html5.itch.zone/...`). Thêm `?dev=1` vào link trang itch.io **có thể không** tới được game, vì `LaunchOptions` đọc `window.location.search` của chính iframe. Story 0.5 phải thử: (1) link trang + `?dev=1`; (2) mở thẳng địa chỉ iframe + `?dev=1`. Ghi lại cách nào chạy được.

## Deferred from: code review of 0-3-log-co-dev-va-tham-so-khoi-dong (2026-10-17)

- `LaunchOptions.read_current()` chưa có test: cả đường web (`JavaScriptBridge.eval("window.location.search")`) lẫn đường desktop. Story 0.5 kiểm cùng mục iframe itch.io ở trên. Nếu itch.io thêm khóa lạ vào URL của iframe thì mỗi lần mở game sẽ in một dòng WARN; khi đó cần quyết có bỏ qua các khóa đó không.
- Luật mới "lõi luật không được gọi `Log.`" (`check_boundaries.sh`) chưa ghi vào danh sách cấm của `src/core/` trong `project-context.md` và `game-architecture.md` (hai nơi vẫn chỉ ghi `print`). Cần tác giả duyệt rồi mới sửa tài liệu.
- Rủi ro cho Story 0.5 / 1.6: trên trình duyệt, F1 mở trợ giúp và F5 tải lại trang. Phím dev F1/F5 có thể không tới được game. Khi có bản web phải thử; nếu bị chiếm thì chặn mặc định của trình duyệt (qua `JavaScriptBridge`) hoặc hỏi tác giả đổi phím. → Story 1.6: tác giả chốt F5 chỉ dùng trên desktop, trình duyệt tải lại trang cũng chấp nhận, không chặn phím.

## Deferred from: Story 0.4 (2026-10-17)

- Story 0.5: bản web phải hiện tiêu đề tiếng Việt (không phải `app.title`); kiểm trên trình duyệt đặt ngôn ngữ tiếng Anh.
- Giấy phép OFL yêu cầu `OFL.txt` đi kèm font khi phát hành. Preset export (Story 0.5) phải gồm `assets/fonts/OFL.txt` (filter `*.txt` hoặc đúng file đó), hoặc ghi giấy phép ở chỗ người chơi thấy được.

## Deferred from: code review of 0-4-chu-tieng-viet-va-font (2026-10-17)

- Bước 3 của `tools/test.sh` (quét lại một lần khi lần đầu có lỗi oan trên repo mới clone) chưa có tự kiểm tự động. Cần hai ca: bản sao không có `game/.godot/` phải "đạt"; bản sao có script lỗi cú pháp thật phải "trượt" dù đã quét lại.
- `config/name` trong `game/project.godot` vẫn viết cứng "Chống Nguyên Mông" (Task 4.2 của Story 0.4 bảo giữ). Sửa `app.title` trong CSV thì tên app trên Dock macOS và tiêu đề cửa sổ lúc mới mở (trước `_ready()`) vẫn là tên cũ. Story 0.5 kiểm thêm tên trang/tab trên trình duyệt; tác giả quyết có cần đồng bộ không. → xong ở Story 0.5 (`config/name` = "Hào Khí Đông A", đồng bộ với `app.title`).

## Deferred from: Story 0.5 (2026-10-17)

- Đã trả lời mục iframe itch.io của Story 0.3: link trang + `?dev=1` **không** bật được dev (iframe có địa chỉ riêng). Chưa thử mở thẳng địa chỉ iframe + `?dev=1`. Vì vậy `SaveProbe` luôn ghi log, cả khi không bật dev (tác giả chốt).
- Chưa thử bản web trên Firefox và Edge (tác giả hoãn). Chỉ đã kiểm trên Chrome (macOS). Làm ở E4 khi đo đủ NFR4.
- Chưa đo thời gian tải ở 20 Mbps (tác giả hoãn). Cần biết itch.io có nén `index.wasm` khi gửi không; không nén thì ~16 giây, vượt NFR2. Đo ở E4 (hoặc sớm hơn nếu tác giả muốn).
- Chưa thử F1/F5 trên web khi bật dev (không bật được dev trong iframe). Story 1.6 kiểm khi làm F5. → Story 1.6: F5 trên desktop xong; web chờ tác giả thử trên bản build chạy ở máy (`http://localhost:8060/?dev=1`), chỉ để ghi lại kết quả.
- itch.io thêm `?v=<số>` vào URL của iframe, nên mỗi lần mở game Console có `[WARN][app] bỏ qua tham số lạ trên URL: "v"` (người chơi không thấy). Tác giả quyết có bỏ qua im lặng khóa `v` không.
- `SaveProbe` (`user://thu_luu.json`) ghi file mỗi lần mở game với mọi người chơi. Gỡ hoặc thay bằng lưu game thật ở E4 (FR46).

## Deferred from: code review of 0-5-ban-web-tren-itch-io-rieng-tu (2026-10-17)

- Các chốt mới trong script `tools/` chưa có test tự động, chỉ kiểm tay trong Debug Log: chốt 25 MB của `build_web.sh`, chống xanh giả khi export (grep `ERROR` trong log), `cai_dat.sh` từ chối butler sai SHA-256, `deploy_itch.sh` chặn chữ mẫu `ITCH_TARGET`, và `ghi_build_info` (chuyển từ `chay.sh` sang `_godot.sh`) cho kết quả giống hệt. Làm cùng các mục test script `tools/` đã hoãn ở trên.
- Ngoại lệ luật kiến trúc: `SaveProbe` nằm ở `src/debug/` nhưng chạy với mọi người chơi (luật 5 nói `src/debug/` luôn kiểm cờ dev). Tác giả chọn để nguyên tới khi gỡ ở E4. Lưu ý `Log` (cũng ở `src/debug/`) vốn đã chạy luôn; khi sửa tài liệu kiến trúc nên ghi rõ.
- AC 4/6 của Story 0.5 còn hai phần chưa kiểm (tác giả hoãn): tiêu đề trên itch.io khi Chrome đặt ngôn ngữ tiếng Anh; cột Transferred trong DevTools (itch.io có nén `index.wasm` không). Đo cùng Firefox/Edge và thời gian tải ở E4.

## Deferred from: code review of 0-6-cai-cong-cu-ai-mcp (2026-10-18)

- `tools/cai_dat.sh` xóa `.tools/mcp` trước khi `npm ci`: nâng phiên bản lúc mất mạng thì mất luôn GoPeak/Context7 đang chạy được. Sửa: cài vào thư mục tạm rồi đổi chỗ.
- `tools/mcp_context7.sh` source `_godot.sh` (theo mẫu Task 3.2) nên Context7 không chạy khi chưa cài Godot hoặc máy không hỗ trợ, dù Context7 không cần Godot.
- Script MCP không kiểm `node` lúc Claude Code khởi động (PATH khác khi mở từ app, `node_modules` bị xóa một phần): chỉ thấy "failed", không có lời nhắc tiếng Việt.
- `.mcp.json` dùng đường tương đối `tools/...`: phụ thuộc Claude Code khởi động ở gốc repo.

## Deferred from: code review of 1-1-nap-chi-so-va-tran-tu-file-bao-loi-bang-tieng-viet (2026-10-18)

- `LevelData.terrain_at` (`game/src/core/level_data.gd:30`) không kiểm ô ngoài bàn: x âm hoặc lớn hơn bề ngang thì đọc nhầm sang ô của dòng khác, y ngoài bàn thì engine báo lỗi. Thêm kiểm biên (hoặc `assert`) khi Story 1.2 dùng hàm này để tìm đường hay xét ô kề.
- `Stats.value` (`game/src/core/stats.gd:15`) trả 0 khi gõ sai khóa hoặc khi lính không có chỉ số đó: đòn đánh thành 0 sát thương mà không báo gì. Thêm `assert` hoặc ghi log khi Story 2.x bắt đầu đọc chỉ số.

## Deferred from: code review of 1-3-kich-ban-luat-va-cong-cu-duyet-tren-terminal (2026-10-18)

- Khóa `da_duyet` trong `tools/test.sh` chỉ chặn sửa chưa commit: AI sửa kịch bản đã duyệt rồi commit luôn thì lọt. Grep theo dòng bỏ sót `"da_duyet":` và `true` nằm khác dòng; khóa trùng (`true` rồi `false`) thì grep coi là khóa còn Godot lấy giá trị sau. Cân nhắc so với commit lúc duyệt hoặc đọc JSON thật.
- Định dạng kịch bản luôn dựng trận ELIMINATE, `tiep_vien`/`so_hiep_toi_da`/`long_dan`/`muu_ke_mo` để mặc định, chưa có khóa để đặt. Cần khi viết kịch bản kết thúc lượt, giữ ải, tiếp viện (Story 1.5 trở đi).

## Deferred from: code review of 1-4-chon-tuong-va-xem-cac-o-di-duoc (2026-10-18)

- `BattleView._cells` (ô sáng) tính một lần lúc chọn tướng, không làm mới khi trận đổi. Story 1.5 cho tướng đi thật thì phải chọn lại (hoặc bỏ chọn) sau mỗi lệnh, kẻo ô sáng và kiểm bấm dùng dữ liệu cũ. → xong ở Story 1.5 (`BattleView._on_events_resolved` chọn lại sau mỗi lệnh).
- `BattleView` và `BattleInput` là anh em dưới `main`, không phải con của `BattleView` như "Mẫu giao tiếp" trong kiến trúc. Đúng theo Task 7.4 của Story 1.4; dọn khi E2 thêm view.
- `BoardView.show_state(null)` tự xóa vòng chọn, còn `BattleView._selected` chỉ xóa khi gọi `stop()`. Hiện `main.gd` luôn gọi `stop()` trước; chỗ gọi mới mà quên thì hai bên lệch nhau và bấm vào ô "sáng" bị nuốt.

## Deferred from: Story 1.5 (2026-10-18)

- `BattleController.rolled_back` (lệnh làm hỏng bất biến, đã quay lại) chưa có chỗ hiện cho người chơi câu "Có lỗi, đã quay lại nước trước". Hiện chỉ ghi log ERROR. Làm cùng `src/ui/notice.gd` ở E2. Chỉ xảy ra khi có bug luật.
- Kịch bản có `ket_thuc_luot` (`hiep/`, Story 1.5) không có quân Nguyên trên bàn, để pha địch E2 không làm hỏng bàn sau. Nếu E2 chốt luật "bàn không còn quân Nguyên thì thắng ngay ở cuối hiệp" thay vì "kiểm sau sự kiện gục", hai kịch bản này phải xét lại với tác giả.

## Deferred from: code review of 1-5-di-huy-nuoc-di-ket-thuc-luot (2026-10-18)

- `BattleController.submit` (`game/src/battle/battle_controller.gd:37`): lệnh bị từ chối không khôi phục bản chụp `before`. An toàn chỉ vì luật hiện tại kiểm hết rồi mới sửa trận. Luật "đánh" (Story 2.1) mà sửa rồi mới từ chối thì trận lệch nửa chừng, không phát signal. Xét lại khi viết Story 2.1: hoặc `_state = before` khi từ chối, hoặc giữ luật "kiểm trước, sửa sau".
- `BattleView._on_end_turn` (`game/src/battle/battle_view.gd:97`) luôn bỏ chọn kể cả khi lệnh bị quay lại. Chưa gặp được tới khi pha địch E2 có luật; làm cùng thông báo `rolled_back`.
- `BattleController.undo` phát `events_resolved` với danh sách sự kiện rỗng, chưa có loại sự kiện "đã hủy". Người nghe sau này (EventPlayer, hoạt ảnh) coi "không có sự kiện" là "không đổi gì" thì bỏ sót lần hủy.
- Phím Z/Space/1-2-3 gán theo vị trí vật lý: bàn phím AZERTY thì nút ghi "(Z)" nhưng phím W mới hủy. Bàn phím Việt là QWERTY nên để sau.
- `main.gd` nối `events_resolved` trước `BattleView.start` để đồng quân vẽ lại trước ô sáng. Đúng thứ tự là nhờ chú thích, chưa có test giữ.

## Deferred from: code review of 1-6-f5-nap-lai-du-lieu (2026-10-18)

- Phím dev F1–F5 (`game/src/debug/dev_tools.gd:14`) trên macOS mặc định là phím hệ thống (độ sáng, đọc chính tả…): bấm F5 trần có thể không tới game. Hướng dẫn test cho tác giả nên ghi "Fn+F5", hoặc bật "Dùng F1, F2… như phím chức năng chuẩn" trong Cài đặt bàn phím. Có từ Story 0.3, không phải lỗi code.

## Deferred from: code review of 1-7-ban-co-nghieng-isometric-tam (2026-10-18)

- `BoardView.setup` (`game/src/battle/board_view.gd`) canh giữa bàn trong `AREA` nhưng không co giãn: bàn lớn hơn 7×7 (cot + hang > ~14) sẽ tràn dưới HUD và ra ngoài màn hình, màn hình lỗi tràn theo. File trận hiện khóa 7×7 nên chưa gặp; khi cho phép bàn khác cỡ thì thêm `scale` hoặc báo lỗi. **Đã làm ở Story 1.9** (canh theo cỡ bàn, thu theo bậc nguyên; bàn lớn nhất 10×8 vừa ở 1:1).
- Bệ ô ải vẽ trên mặt đất (`BoardView._draw`), không nằm trong lớp y-sort: khối rừng, kho lương, làng đứng ngay sau ô ải che dải 8px của bệ, nhưng `pick_cell` lại chọn ô ải; chữ "sông", "chông" của ô phía sau đè lên bệ ô ải. Trận hiện có chưa gặp. Tác giả chọn giữ cách vẽ này (2026-10-18); xem lại khi làm trận "Giữ ải" hoặc khi E8 thay tranh. Vẫn còn trên bàn nhìn chếch (khối ở hàng trên che dải 8 px của bệ ô ải ngay dưới), Story 1.8.

## Deferred from: code review of 2-1-nguyen-khoai-danh-day-va-va-cham (2026-10-18)

- `BattleView` (`game/src/battle/battle_view.gd:83`): đang chờ xác nhận đòn mà bấm hoặc gõ phím vào tướng đã đánh thì không bỏ chờ, gợi ý "Bấm lần nữa để đánh" vẫn còn (AC 10 của 2.1). Chưa gặp được vì chỉ Khoái có đòn; xem lại ở Story 2.3/2.4. **Đã làm ở Story 2.3** (bỏ chờ, giữ tướng đang chọn; cả chuột lẫn phím).
- `UnitToken.update` (`game/src/battle/unit_token.gd:82`): bỏ cờ đã đánh thì màu chữ tên về màu Đại Việt, không theo phe. Quân Nguyên chưa đánh tới 2.6+.
- `ForcedMove.OBSTACLES` (`game/src/core/forced_move.gd:10`) tách khỏi `Terrain.WALKABLE`: thêm loại ô không đi được mà quên thêm vào đây thì quân bị đẩy lên ô đó, `validate` quay lại cả đòn. Hiện hai danh sách khớp.
- Bộ chạy kịch bản (`game/tests/scenario_runner.gd:177`) bỏ qua tướng đã gục khi so `sau.da_danh`. Tướng chưa gục được trong kịch bản 2.1; xem lại khi va chạm làm tướng gục (2.2).
- `BattleView._on_target_clicked` không kiểm tướng đang chọn còn trên bàn. Tướng chưa gục được giữa hai cú bấm; xem lại khi pha địch có đòn.

## Deferred from: code review of 2-2-song-va-danh-trung-quan-minh (2026-10-19)

- Bộ chạy kịch bản (`game/tests/scenario_runner.gd:160`) vẫn bỏ qua tướng đã gục khi so `da_danh`/`da_di`. Kịch bản `va_cham/tuong_minh_guc_vi_va.json` là kịch bản đầu tiên có tướng gục; bàn sau (ô Lão trống) đủ bắt lỗi. Nên báo "tướng có trong `sau` mà không còn trên bàn" khi có kịch bản tướng gục phức tạp hơn (đòn địch, 2.8).

## Deferred from: code review of 2-3-pham-ngu-lao-phong-lao (2026-10-19)

- Bộ nạp kịch bản (`game/src/data/scenario_loader.gd:40`, `COMMAND_REJECTS`) kiểm mã `tu_choi` theo lệnh, không theo tướng: Khoái + `ngoai_tam` hay Lão + `khong_ke` vẫn nạp được, chỉ trượt lúc chạy với câu báo mã khác. `test_scenario_loader.gd:482` dùng đúng ca Khoái + `ngoai_tam`. Xem lại khi Dư có đòn (2.4) nếu tác giả muốn bộ nạp báo sớm.

## Deferred from: code review of 1-9-co-ban-theo-file-tran (2026-10-20)

- `BoardView.fit_scale` (`game/src/battle/board_view.gd:231`): thu 1/3 cho ô 21,33 px, không còn góc điểm ảnh nguyên như lời giải thích bậc nguyên. Nhánh thu không chạy ở 1280×720 với mọi cỡ hợp lệ (5..10 × 5..8); xem lại nếu đổi `TILE_SIZE` hoặc cho phép bàn lớn hơn.
- `test_board_view.gd`: chưa có test `setup` khi hệ số thu khác 1 (chỉ test `fit_scale` và đặt `scale` bằng tay). Làm cùng lúc với việc trên.
- `test_board_view.gd` (`_boards()`): dùng `AppState.launch` toàn cục, phụ thuộc thứ tự test; số `(262, 139)` chỉ đúng khi `tran` rỗng.

## Deferred from: code review of 2-4-tran-khanh-du-keo (2026-10-20)

- `RulesAttack._du_targets` (`game/src/core/rules_attack.gd:55-73`) bỏ qua địa hình: kéo qua rừng/kho lương/làng vẫn có viền và va chạm mất 1 máu. Test `test_pull_blocked_by_forest_collides_before_story_3_1` khóa hành vi tạm; sửa cả hai ở Story 3.1.
- `BattleEvent.attacked()` (`game/src/core/battle_event.gd:94`) luôn gắn `Cause.STRIKE`, kể cả đòn kéo không sát thương. Chưa nơi nào đọc cause của ATTACKED; xem lại khi có log, âm thanh hoặc hoạt ảnh theo cause.

## Deferred from: dev of 2-5-mau-guc-thang-va-thua-tieu-diet (2026-10-20)

- ~~Story 2.8 (đòn địch): phải gọi `RulesVictory.check(state, events)` **sau từng đòn địch** (truyền danh sách sự kiện của riêng đòn đó) và dừng pha địch khi `phase` là `WON`/`LOST`, để quân địch còn lại không đánh tiếp khi trận đã hết. Hiện `check` chỉ gọi ở cuối `Rules.resolve`.~~ (xong ở Story 2.8)
- Khi Story 2.8 hoặc 3.4 (hầm chông) cho tướng cuối gục thật bằng một lệnh, thêm kịch bản "thua" và "thắng thua cùng lúc" vào `tests/kich_ban/ket_thuc/` (hiện chỉ có test GUT dựng bằng `Effects.damage`).
- `RulesVictory._someone_fell` dựa vào `DIED`/`DROWNED`: loại sự kiện gục mới thêm sau này (ví dụ quân tiếp viện, 3.10) phải cập nhật hàm này.
- Nút "Chơi lại trận" của `ResultBanner` bỏ khi có menu ở Story 4.2.

## Deferred from: code review of 2-5-mau-guc-thang-va-thua-tieu-diet (2026-10-20)

- `ResultBanner` (`game/src/ui/result_banner.gd`) chép lại hằng màu nền và viền của `error_screen.gd` thay vì dùng chung; gom vào theme khi có màn thứ ba cần dùng.
- Trận Tiêu diệt còn `tiep_vien` chưa vào bàn: luật hiện tại cho thắng khi quân Nguyên trên bàn gục hết, kể cả khi còn tiếp viện. Story 3.10 (tiếp viện) phải xét điều kiện thắng cùng tiếp viện. Trận không có quân Nguyên nào thì đã có lỗi nạp (quyết định 1a).

## Deferred from: dev of 2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu (2026-10-21)

- Story 2.7 (vẽ báo đòn): vẽ từ `BattleState.telegraphs` của bản chụp (`Telegraph.target_cell` cho đòn vào ô; Kỵ binh `kind == DIRECTION`, `offset` là hướng). Sự kiện `TELEGRAPHED` có sẵn cho hoạt ảnh (2.11).
- ~~Story 2.8 (ra đòn): chèn ra đòn vào đầu `RulesEnemyPhase.end_player_turn` (đã có chú thích), trước khi sang hiệp; `prepare` đang xóa đòn cũ ở đầu pha nên đòn chưa đánh thì mất. Kịch bản `ai/` có `truoc` không có đòn nên vẫn đúng sau 2.8. Có thể cần `truoc.bao_don` để dựng đòn sẵn.~~ (xong ở Story 2.8)
- Story 2.9: chủ đòn gục thì `Telegraph.target_cell` trả `NO_CELL` (chưa hủy đòn); bảng F3 đã ghi "(đã gục)". Hủy đòn và `TELEGRAPHED`/`TELEGRAPH_CANCELLED` làm ở 2.9.
- Bố cục các trận thử `thu_lao`, `thu_keo`, `thu_thang`, `thu_co_lon` (và bản chép trong `test_battle_view.gd`) đã đổi để pha địch lúc mở trận không dời quân nào (thêm sông vây góc, đặt tướng kề quân Nguyên). `test_loaders.gd` kiểm điều đó (`_assert_enemies_stay_on_begin`). Khi 2.8 có đòn địch thật, các trận thử này sẽ bị đánh sau Kết thúc lượt: xem lại nếu hướng dẫn tự test cần nhiều hiệp.
- Ca "hòa ô gần nhất thì ít bước đi hơn" (AC 8) chỉ xảy ra khi có quân cùng phe chiếm ô (tìm 200.000 bàn chỉ có sông thì không ra ca nào); test có ở `test_enemy_ai.gd::test_walks_through_ally_but_never_stops_on_it`.

## Deferred from: dev of 2-7-hien-thi-bao-don (2026-10-21)

- ~~Story 2.8 (ra đòn): dùng `TelegraphMarks.hit_cell` để biết đòn trúng ô nào (Kỵ binh: vật đầu tiên hoặc trượt khi là ô sát mép trống), để ô đỏ và đòn thật không lệch nhau.~~ (xong ở Story 2.8)
- Story 2.9 (hủy đòn): chủ gục hoặc ô đích ngoài bàn thì `TelegraphMarks.cells` đã tự bỏ đòn đó; hủy hẳn trong `state.telegraphs` vẫn là việc của 2.9.
- Ba đòn trở lên trúng cùng một ô: chuỗi số (`1·2·4`, chữ 28 px) dài hơn một ô, lấn sang ô bên phải (`anh/2-7-hai-ky-binh-ba-so.png`). Vẫn đọc được; xem lại ở E8 nếu cần.
- Kỵ binh đứng kề mục tiêu: mũi tên vẽ trên mặt đất ở ô đầu đường, nên bị đồng quân ở ô đó che. Ô đỏ và số vẫn thấy.

## Deferred from: code review of story 2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu (2026-10-21)

- `AiIntentOverlay.line_for` tra tướng bằng `UnitType.GENERALS[intent.target_id - 1]`; Story 3.7 (nhắm làng) phải đổi sang tra theo loại mục tiêu.
- `AiIntentOverlay` mượn khóa `scenario.unit.*` của công cụ duyệt kịch bản để gọi tên quân; gom về một nhóm khóa `unit.*` khi dọn i18n.
- `main._start_battle` bỏ qua kết quả của `BattleController.begin()`; nếu lệnh mở trận bị từ chối thì chưa báo lỗi. Xử lý cùng màn lỗi ở E4.

## Deferred from: code review of story 2-7-hien-thi-bao-don (2026-10-21)

- `TelegraphView.numbers` do `BoardView` thêm vào cây; dùng `TelegraphView` riêng ngoài `BoardView` (chỉ trong test) thì `numbers` rò node.
- Số thứ tự chỉ nằm ở ô trúng; ô đỏ giữa đường xung phong không có số. Xem lại ở Story 2.10 (rê chuột xem thông tin).
- Đòn có ô đích ngoài bàn thì không vẽ gì; Story 2.9 xử lý cùng hủy đòn.
- `CoordOverlay.CELL_LABEL_OFFSET` đặt số cứng (18, 21), chưa dẫn xuất từ `TILE_SIZE` và `UnitToken.HP_OFFSET`, chưa có test vị trí nhãn F1.

## Deferred from: dev of 2-8-dich-ra-don-theo-thu-tu (2026-10-21)

- Story 2.9: đòn bị bỏ qua lúc ra đòn (chủ đã gục, ô đích ngoài bàn, Kỵ binh sát mép hướng ra ngoài: `TelegraphMarks.hit_cell` trả `NO_CELL`) chưa có sự kiện; thêm `TELEGRAPH_CANCELLED` ở `RulesEnemyPhase._strike_all` (nhánh `continue`) và kịch bản hủy đòn.
- Story 3.7: Kỵ binh trúng làng, Bộ binh đánh ô làng hiện chỉ phát `ATTACKED` vào ô làng, chưa trừ Lòng dân.
- Hết trận giữa pha địch: ô đỏ của đòn chưa ra vẫn vẽ theo bàn mới (ví dụ Kỵ binh có đường đỏ kéo qua ô tướng vừa gục, `anh/2-8-thua-sau.png`). Đúng với 2.7 AC 10 ("hết trận vẫn vẽ đòn còn lại"); xem lại khi làm hoạt ảnh 2.11 nếu gây hiểu nhầm.
- Kịch bản "thắng thua cùng lúc" và "thắng" giữa pha địch chưa dựng được: ở 2.8 quân ra đòn cuối luôn còn sống. Thêm khi có hầm chông (3.4) hoặc tiếp viện (3.10).

## Deferred from: code review of story 2-8-dich-ra-don-theo-thu-tu (2026-10-21)

- Công cụ duyệt kịch bản (`scenario_viewer.gd`): kịch bản có cả `truoc.bao_don` và `sau.o_do` thì tối đa 3 bàn cạnh nhau, cột có thể lệch vì `LEFT_WIDTH` cộng cứng; xem lại khi có kịch bản thật như vậy.
- Story 2.11 (hoạt ảnh): Kỵ binh xung phong không đổi ô lúc ra đòn (AC 5); hoạt ảnh tự suy đường lao từ `from_cell` tới `to_cell` của `ATTACKED`.
- Story 3.5 (giới hạn hiệp): điểm chèn kiểm hiệp cuối nằm sau `_strike_all` và trước `round_number += 1`, để đòn cuối hiệp vẫn ra.

## Deferred from: code review of story 2-10-re-chuot-xem-thong-tin (2026-10-22)

- Không test nào đọc kích thước/vị trí khung thông tin (chỉ test chuỗi), vì AC 8 cấm viết test cho phần chỉ nhìn thấy bằng mắt. Hệ quả: lỗi khung bị bóp còn 17 px (xem Review Findings) chỉ lộ ra khi đo hoặc nhìn; nếu sau này có test giao diện chạy được ở chế độ có cửa sổ thì thêm một assert `size.x` tối thiểu.
- Bốn dòng hiệu ứng địa hình trong khung thông tin đang dạy luật chưa có: hầm chông "Đi qua mất máu" (Story 3.4), kho lương "Quân Nguyên đứng kề thì hồi máu" (3.9), làng "Đánh vào làng thì mất Lòng dân" (3.7), ải "Quân Nguyên vào ải thì thua" (3.11 — `rules_victory.gd:35` mới chỉ xét `ELIMINATE`). Tác giả chốt 2026-10-22: giữ lời thiết kế, rà lại từng dòng khi luật tương ứng vào.
- Nhánh "Kỵ binh" (`Telegraph.Kind.DIRECTION`) của khung thông tin chưa có test: cần một trận có Kỵ binh bị đẩy cho ô xung phong ra ngoài bàn rồi rê chuột để khẳng định khung ghi "Không có đòn nào" (code đã sửa theo review 2026-10-22, nhưng chỉ kiểm bằng đọc code). Viết khi có kịch bản Kỵ binh bị đẩy.

## Deferred from: code review of story 2-12-xem-truoc-ket-qua-don (2026-10-22)

- Bóng mờ của quân bị đánh **tại chỗ** vẽ đè lên tên quân thật (cùng cỡ chữ, alpha 0.5) nên tên đậm hơn một chút; số máu đã được đẩy lên trên đồng nên không chồng số thật. Chưa sửa vì chưa biết tác giả thấy có khó đọc không — chờ tác giả nhìn `anh/2-12-2.png`, `anh/2-12-3.png`; nếu khó đọc thì bỏ tên trên bóng, chỉ giữ số máu. → **xong ở review vòng 2**: tác giả chốt bỏ tên trên bóng; số máu dời xuống góc dưới–trái trong ô (vị trí "trên đồng" cũ rơi hẳn sang ô bên trên).
- Chưa có test đọc vị trí nhãn của bóng (tên, số máu), vì đó là phần chỉ nhìn thấy bằng mắt: nếu sau này có test chạy được ở chế độ có cửa sổ thì thêm assert vị trí số máu khi `moved == false` (phải nằm trên đồng, không đè số thật). Đo pixel đã có trong Debug Log của story.

### Vòng 2 (sau `f10d5d3`)

- `BoardView.show_state` (`game/src/battle/board_view.gd:277`) xoá bóng xem trước nhưng không reset `BattleView._preview_cell`. Bất biến "memo == ô đang có bóng" hiện chỉ đúng nhờ `_finish_playback` reset memo ngay sau `playback_finished.emit()`; mọi chỗ gọi `show_state` giữa lượt thêm sau này sẽ làm bóng mất mà memo vẫn giữ ô → rê trong ô đó không hiện lại. Xử lý khi có lệnh gọi `show_state` ngoài luồng phát (hoặc khi BattleView nghe signal bàn-đổi).
- (đã xử lý ở review vòng 2) Vị trí số máu của bóng nay có test: `test_preview_hp_label_stays_inside_its_cell` đọc tâm `Label` và đòi nằm trong `cell_rect` — revert cách đặt `hp_center` là test trượt.

## Deferred from: code review of 2-13-f2-sao-chep-bao-loi (2026-10-22)

- AC 3 của story 2.13 (dán báo cáo F2 cho một AI ngoài game để nó chuyển thành kịch bản tái hiện lỗi) chưa có bằng chứng: phần dữ liệu đã kiểm tự động (JSON → bộ nạp → bộ chạy, kể cả ca cố tình đẩy 2 ô), nhưng chưa lần nào dán cho ChatGPT/Claude. Tác giả thử một lần và ghi lại.
- AC 1 chưa đọc lại clipboard thật: `_on_f2` đã chạy trong game thật (log "đã sao chép 2915 ký tự") nhưng máy không có `xclip`/`xdotool`, và công cụ bơm phím của GoPeak chỉ đặt `keycode` trong khi `DevTools` khớp `physical_keycode`. Kiểm trên máy có clipboard (hoặc dán tay) khi rảnh.
- Lệnh làm hỏng bất biến (đường `rolled_back` của `BattleController`) không vào `hanh_dong` của báo cáo F2: `submit` quay về trước khi `_record`, và định dạng kịch bản không có mã cho "rollback". Muốn tái hiện bằng kịch bản thì phải thêm khái niệm đó vào định dạng + bộ chạy; hiện chỉ log giữ dấu vết.

## Deferred from: code review of 2-14-hoan-thien-tran-1-va-moc-tu-choi-het-e2 (2026-10-22)

- Mẫu JSON "Trận 1" trong `game-architecture.md:304-313` còn bố cục cũ (Bộ binh `1,0`/`5,0`/`5,4`, `thu_tu_dich` cũ) và có tướng `3` — lệch có sẵn từ trước story 2.14 (trận thật chỉ 2 tướng), diff chỉ làm lệch thêm trường `thu_tu_dich`. Không ảnh hưởng test. Ghi rõ đây là ví dụ minh hoạ hoặc cập nhật khi có dịp sửa tài liệu kiến trúc.
- Bật `"da_duyet": true` cho `game/tests/kich_ban/tran/tran_01_loi_giai.json` sau khi tác giả đánh lại lời giải bằng tay và xác nhận. Tác giả chốt 2026-10-22: **dev bật cờ**, không bắt tác giả sửa JSON. Chừng nào cờ còn `false`, lời giải hỏng chỉ được liệt kê ("1 chưa duyệt, 1 chưa đạt") và `tools/test.sh` vẫn thoát 0 — chưa phải chốt chặn hồi quy.

## Deferred from: code review of story-2.15-cung-ky-cat-duoc-neu-tre (2026-10-23)

- `"huong"` (xung phong) trong `bao_don` không kiểm loại quân (`scenario_loader.gd`): Cung kỵ hoặc Bộ binh vẫn "xung phong" được nếu người viết kịch bản gõ vậy. Có sẵn từ Story 2.8, không do 2.15; nên thêm kiểm "chỉ `K` được `huong`" ở story dữ liệu/kịch bản sau. Mọi kịch bản hiện có dùng `huong` cho Kỵ binh nên sửa được an toàn.
- Thiếu kịch bản biên riêng cho Cung kỵ: (a) bị kéo làm ô đích ra ngoài bàn, (b) quân khác phe bị kéo vào ô đỏ, (c) tướng rời ô đỏ rồi kết thúc lượt. Đều dùng chung đường `CELL` đã có test cho Bộ binh. Làm khi tác giả chốt 2 câu hỏi cuối story 2.15 (ô đích trống; tướng mình đứng giữa) hoặc ở Story 3.1.
- `EnemyIntent.Reason.NO_ATTACK_RULE` vẫn giữ enum + chuỗi dịch `dev.ai.no_rule` nhưng từ Story 2.15 không loại quân nào dùng, nên không còn test. Giữ có chủ ý cho loại quân thêm sau; xoá khi chắc chắn không cần.

## Deferred from: code review of story-3-1-rung-va-vat-can-chan-don (2026-10-23)

- Kéo qua **làng**: `_du_targets` chỉ dừng ở `ATTACK_BLOCKERS` (rừng, kho lương), nên Dư vẫn kéo được quân đứng sau làng; quân bị kéo va vào làng và mất 1 máu (`ForcedMove.OBSTACLES` có `VILLAGE`). Trái GDD ("vật đầu tiên là làng thì không kéo được") nhưng đúng phạm vi 3.1 (làng để 3.7). Story 3.7 thêm làng vào chặn + Lòng dân sẽ xử lý; khi đó phải thêm test.
- Không có test khóa ranh giới "làng **không** chặn lao/tên/kéo" (AC 6 của 3.1): nếu ai thêm `VILLAGE` vào `Terrain.ATTACK_BLOCKERS` sớm, chỉ `test_archer_trial_level_begins_with_a_shot` bắt được (gián tiếp). Cố ý không thêm test vì 3.7 sẽ đổi hành vi.
- Nhánh va chạm khi kéo (`COLLIDED`/`DAMAGED COLLISION`) mất test trực tiếp sau 3.1: ca rừng đổi thành "không kéo được", chỉ còn làng chạm tới nhánh này. Làm lại cùng Story 3.7.

## Deferred from: code review of story-3-2-choi-lai-hiep (2026-10-23)

- **Báo cáo F2 không ghi dấu "đã chơi lại".** Sau khi chơi lại, `truoc` của báo cáo là bàn **giữa hiệp** (sau pha chuẩn bị) nên phát lại vẫn đúng, nhưng người đọc/AI tưởng đó là bàn mở hiệp; dấu vết duy nhất là log `chơi lại hiệp N`. Nếu tác giả muốn, thêm một dòng chú thích trong `current_section`/`meta` (chỉ là chữ, không thêm lệnh kịch bản).
- **AC 3 của 3.2 mới kiểm được phần "mọi trạng thái nằm trong `BattleState.clone()`".** Khi có **mưu kế** (Story 3.12–3.13) và **Lòng dân** (Story 3.7 — GDD yêu cầu chơi lại trả lại cả Lòng dân đã dùng), phải thêm test: dùng mưu kế/Lòng dân trong lượt → chơi lại → dùng lại được. Nhớ thêm cờ mưu kế vào `BattleState.clone()` và test `validate()` của `replay_round`.
