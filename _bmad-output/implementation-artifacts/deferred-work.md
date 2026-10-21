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

- Story 2.8 (đòn địch): phải gọi `RulesVictory.check(state, events)` **sau từng đòn địch** (truyền danh sách sự kiện của riêng đòn đó) và dừng pha địch khi `phase` là `WON`/`LOST`, để quân địch còn lại không đánh tiếp khi trận đã hết. Hiện `check` chỉ gọi ở cuối `Rules.resolve`.
- Khi Story 2.8 hoặc 3.4 (hầm chông) cho tướng cuối gục thật bằng một lệnh, thêm kịch bản "thua" và "thắng thua cùng lúc" vào `tests/kich_ban/ket_thuc/` (hiện chỉ có test GUT dựng bằng `Effects.damage`).
- `RulesVictory._someone_fell` dựa vào `DIED`/`DROWNED`: loại sự kiện gục mới thêm sau này (ví dụ quân tiếp viện, 3.10) phải cập nhật hàm này.
- Nút "Chơi lại trận" của `ResultBanner` bỏ khi có menu ở Story 4.2.

## Deferred from: code review of 2-5-mau-guc-thang-va-thua-tieu-diet (2026-10-20)

- `ResultBanner` (`game/src/ui/result_banner.gd`) chép lại hằng màu nền và viền của `error_screen.gd` thay vì dùng chung; gom vào theme khi có màn thứ ba cần dùng.
- Trận Tiêu diệt còn `tiep_vien` chưa vào bàn: luật hiện tại cho thắng khi quân Nguyên trên bàn gục hết, kể cả khi còn tiếp viện. Story 3.10 (tiếp viện) phải xét điều kiện thắng cùng tiếp viện. Trận không có quân Nguyên nào thì đã có lỗi nạp (quyết định 1a).

## Deferred from: dev of 2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu (2026-10-21)

- Story 2.7 (vẽ báo đòn): vẽ từ `BattleState.telegraphs` của bản chụp (`Telegraph.target_cell` cho đòn vào ô; Kỵ binh `kind == DIRECTION`, `offset` là hướng). Sự kiện `TELEGRAPHED` có sẵn cho hoạt ảnh (2.11).
- Story 2.8 (ra đòn): chèn ra đòn vào đầu `RulesEnemyPhase.end_player_turn` (đã có chú thích), trước khi sang hiệp; `prepare` đang xóa đòn cũ ở đầu pha nên đòn chưa đánh thì mất. Kịch bản `ai/` có `truoc` không có đòn nên vẫn đúng sau 2.8. Có thể cần `truoc.bao_don` để dựng đòn sẵn.
- Story 2.9: chủ đòn gục thì `Telegraph.target_cell` trả `NO_CELL` (chưa hủy đòn); bảng F3 đã ghi "(đã gục)". Hủy đòn và `TELEGRAPHED`/`TELEGRAPH_CANCELLED` làm ở 2.9.
- Bố cục các trận thử `thu_lao`, `thu_keo`, `thu_thang`, `thu_co_lon` (và bản chép trong `test_battle_view.gd`) đã đổi để pha địch lúc mở trận không dời quân nào (thêm sông vây góc, đặt tướng kề quân Nguyên). `test_loaders.gd` kiểm điều đó (`_assert_enemies_stay_on_begin`). Khi 2.8 có đòn địch thật, các trận thử này sẽ bị đánh sau Kết thúc lượt: xem lại nếu hướng dẫn tự test cần nhiều hiệp.
- Ca "hòa ô gần nhất thì ít bước đi hơn" (AC 8) chỉ xảy ra khi có quân cùng phe chiếm ô (tìm 200.000 bàn chỉ có sông thì không ra ca nào); test có ở `test_enemy_ai.gd::test_walks_through_ally_but_never_stops_on_it`.

## Deferred from: code review of story 2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu (2026-10-21)

- `AiIntentOverlay.line_for` tra tướng bằng `UnitType.GENERALS[intent.target_id - 1]`; Story 3.7 (nhắm làng) phải đổi sang tra theo loại mục tiêu.
- `AiIntentOverlay` mượn khóa `scenario.unit.*` của công cụ duyệt kịch bản để gọi tên quân; gom về một nhóm khóa `unit.*` khi dọn i18n.
- `main._start_battle` bỏ qua kết quả của `BattleController.begin()`; nếu lệnh mở trận bị từ chối thì chưa báo lỗi. Xử lý cùng màn lỗi ở E4.
