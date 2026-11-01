---
baseline_commit: 888c558
---

# Story 8.7: Âm thanh

Status: review

## Story

Là người chơi,
tôi muốn nghe tiếng đánh, đẩy, nước, và nhạc nền,
để trận đánh có sức nặng.

_Chốt 2026-11-01 (tác giả): Epic 8 chỉ đổi hình và tiếng, **không đổi luật**. Story này gắn **20 file SFX và 4 bản nhạc đã có sẵn** trong `game/assets/audio/` vào game, thêm **nút tắt tiếng** và **nhạc nền**. Không thêm file âm thanh mới (thiếu tiếng nào thì báo tác giả, đừng tự tải)._

> **Điều kiện:** 8.1 đến 8.6 đã xong (commit `888c558`). File âm thanh đã nằm trong `assets/audio/sfx/` và `assets/audio/music/`, đã có `.import`, đã có 2 dòng trong `CREDITS.md` (mục "Âm thanh và nhạc", CC0, Pixel-boy & AAA). **Hiện chưa có dòng code nào phát tiếng** (không có `AudioStreamPlayer` trong `src/`).

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.7; `game-architecture.md` dòng 140, 199, 257 (2 bus Nhạc và Hiệu ứng, chỉ phát sau lần bấm đầu); `project-context.md` ("Âm thanh chỉ phát sau lần bấm đầu tiên"). Mục **[Đã chốt mặc định]** có câu hỏi ở "Câu hỏi cho tác giả"; dev làm theo mặc định, tác giả đổi sau khi nghe.)

### A. Tiếng trong trận

1. **Tiếng theo sự kiện. [Đã chốt mặc định: Câu hỏi 2]** Mỗi `BattleEvent` mà `EventPlayer` phát lại có tiếng tương ứng, lúc hoạt ảnh của sự kiện đó bắt đầu (cùng chỗ `_spawn_fx`/`_start_clip`), theo bảng ở Dev Notes ("Bảng tiếng"). Đủ các việc tiêu chí gốc nêu: **đẩy/kéo** (kéo của Dư, va chạm), **phóng lao**, **va chạm**, **rơi sông**, **trúng chông**, **thắng**, **thua**.
2. **Bảng tiếng ở một chỗ.** Tên file và bảng "sự kiện → tiếng" nằm trong một class thuần mới (gợi ý `SoundMap`, `src/ui/sound_map.gd`, hàm tĩnh, theo khuôn `ScreenArt`/`UiStyle`), có hàm thuần `sfx_for_event(event, unit_type) -> String` (trả "" nếu sự kiện không có tiếng). Đổi tiếng cho sự kiện nào chỉ sửa một bảng. Không đưa chữ hay con số cân bằng vào đây.
3. **Không đổi hoạt ảnh, thời lượng, luật.** Tiếng chỉ *đi kèm* sự kiện đã phát: không đổi `SECONDS_PER_EVENT`, `MAX_PHASE_SECONDS` (3 giây/pha địch), không đọc trạng thái sống ngoài `snapshot` mà `EventPlayer` đang nhận, không thêm sự kiện mới vào `src/core/`.
4. **Tua nhanh và phát tức thì.** Khi tua nhanh (T), vẫn có tiếng nhưng **không chồng thành tiếng ồn**: cùng một tiếng không phát lại trong khoảng ngắn (mặc định 0,05 giây), tối đa 8 tiếng cùng lúc (tiếng mới quá hạn thì bỏ, không dồn hàng đợi). Khi `EventPlayer.instant` (headless, `play_now`) **không phát tiếng** (không có hoạt ảnh thì không có tiếng).

### B. Giao diện

5. **Tiếng nút. [Đã chốt mặc định: Câu hỏi 4]** Rê chuột vào nút: `sfx_re_chuot`; bấm nút: `sfx_bam_nut`; bấm Hủy nước đi (Z, nút Hủy) thành công: `sfx_huy_nuoc`. Áp cho mọi nút làm bằng `UiStyle.apply_button` (menu, HUD, bảng thắng/thua, bảng gợi ý, màn chuyển trận), không sửa từng nút.
6. **Nút tắt tiếng. [Đã chốt mặc định: Câu hỏi 3]** Một nút "Âm thanh: bật/tắt" (phím tắt **M** khai báo trong InputMap, như T) nằm cố định ở **góc trên phải** cửa sổ, hiện ở **mọi màn hình** (menu, trận, chuyển trận). Bấm một cú là tắt hoặc bật **cả nhạc lẫn tiếng**. Nút nằm ngoài khung `Hud`, không làm khung HUD cao thêm (đang vừa 720 px). Chữ qua `tr()` (khóa mới trong `text.csv`, khóa khóa `da_duyet`/test khóa i18n phải xanh).
7. **Nhớ lựa chọn.** Tắt/bật được lưu trong `user://settings.cfg`, mục mới `[am_thanh] tat_tieng = true/false` (`PlayerSettings`, cùng khuôn `toc_do`): mở lại game vẫn giữ. File cũ không có mục này vẫn nạp được (mặc định bật tiếng). Giá trị lạ → cảnh báo tiếng Việt, dùng mặc định, **không chặn game**.
8. **Tắt tiếng là im thật.** Khi tắt: không có tiếng nào, nhạc dừng hẳn (không chỉ nhỏ); bật lại thì nhạc đúng màn hiện tại phát lại. Dùng `AudioServer.set_bus_mute` trên hai bus, không sửa từng player.

### C. Nhạc nền

9. **Nhạc theo màn. [Đã chốt mặc định: Câu hỏi 1, 5]** Menu: `bgm_menu.ogg`. Trận: `bgm_tran_dau.ogg` (trận cuối `tran_06` dùng `bgm_cang_thang.ogg`). Màn chuyển trận: giữ im lặng. Thắng cả chiến dịch: `bgm_thang_chien_dich.ogg`. Về menu từ trận: nhạc menu. Chọn nhạc bằng bảng trong `SoundMap` (id trận → bản nhạc, id lạ → `bgm_tran_dau`).
10. **Nhạc lặp, đổi nhạc mượt.** Nhạc nền lặp vô hạn (file `.ogg` đang `loop=false`: bật lặp bằng code khi nạp, đừng sửa nhạc). Đổi bản nhạc thì nhạc cũ nhỏ dần rồi tắt (mặc định 0,5 giây), nhạc mới vào; nhạc đang phát đúng bản đó thì **không** phát lại từ đầu. Thắng/thua trận: nhạc nền nhỏ dần tắt, kèn `sfx_thang`/`sfx_thua` vang lên; trận kế bắt đầu thì nhạc trận vào lại.
11. **Chỉ phát sau lần bấm đầu tiên.** (`project-context.md`) Trước khi người chơi bấm chuột hoặc nhấn phím lần đầu, **không phát** nhạc và tiếng: yêu cầu phát nhạc được nhớ lại (nhạc của màn hiện tại), tới lần bấm đầu thì nhạc đó mới vào. Rê chuột không tính là bấm. Kiểm trên bản web (Chrome), không chỉ trên máy.
12. **Hai bus.** Tạo bằng code lúc mở game bus "Nhạc" và "Hiệu ứng" (không cần mở editor, không thêm `default_bus_layout.tres` nếu tránh được); mỗi player gắn đúng bus. Âm lượng mặc định: nhạc **-12 dB**, hiệu ứng **-4 dB** (chỉnh khi nghe thử, ghi giá trị cuối vào Completion Notes). Không thêm thanh trượt âm lượng (ngoài phạm vi).

### D. Không phá gì

13. **Luật, dữ liệu, hoạt ảnh không đổi.** `src/core/` không bị sửa (ranh giới `check_boundaries.sh` giữ xanh: `AudioStreamPlayer` là `Node`, không được đặt trong core). Kịch bản luật, `Rules.resolve`, hoạt ảnh, thời lượng pha địch như cũ.
14. **Thiếu file không làm game sập.** Tiếng/nhạc nạp thiếu hoặc hỏng → một dòng `Log.error("am_thanh", ...)` (mỗi đường dẫn một lần, theo khuôn `Art.tex`) và im lặng ở chỗ đó; game vẫn chạy.
15. **Dung lượng và web.** Bản nén web vẫn ≤ 25 MB (`tools/build_web.sh` tự kiểm; bản build 8.6 là 11,0 MB: **build lại sau khi xong** và ghi con số vào Completion Notes). Không `Thread`, không `WorkerThreadPool`. Nạp sẵn, không nạp động (luật dự án): nạp toàn bộ khi mở game, không nạp mỗi lần phát.
16. **Test.** `tools/test.sh` xanh. Test mới cho: bảng sự kiện → tiếng (đủ mọi loại sự kiện ở Dev Notes, kể cả loại không có tiếng); đường dẫn mọi tiếng/nhạc trong bảng tồn tại và nạp được thành `AudioStream`; lưu/nạp `tat_tieng` (gồm file cũ, giá trị lạ); tắt tiếng đặt đúng trạng thái mute của 2 bus; chống chồng tiếng (cùng tiếng trong 0,05 giây chỉ phát một lần; tối đa 8); không phát trước lần bấm đầu; bảng nhạc theo trận; `EventPlayer` phát đúng chuỗi tên tiếng cho một chuỗi sự kiện mẫu. **Không** test chất lượng âm thanh (tác giả nghe bằng tai).
17. **Tác giả nghe và duyệt.** Chạy bản web (`tools/build_web.sh` rồi `tools/chay_web.sh`) hoặc `tools/chay.sh`; ghi vào báo cáo cuối "Cách tác giả thử" các bước nghe. Không cần ảnh chụp (đây là tiếng), nhưng **chụp nút Âm thanh ở góc trên phải** trên 3 màn (menu, trận, chuyển trận) bằng GoPeak `capture_screenshot`, lưu `_bmad-output/implementation-artifacts/anh/8-7-*.png`, để xem nút không che chữ.

## Tasks / Subtasks

- [x] Task 1: Bảng tiếng và nhạc (AC: 2, 9, 14)
  - [x] 1.1 Tạo `game/src/ui/sound_map.gd` (`class_name SoundMap`, `extends RefCounted`, hàm tĩnh): hằng đường dẫn 20 SFX và 4 nhạc; `sfx_for_event(event: BattleEvent, unit_type: int) -> String`; `music_for_level(level_id: String) -> String`; `MUSIC_MENU`, `MUSIC_CAMPAIGN_END`.
  - [x] 1.2 Test `tests/test_sound_map.gd`: mọi loại `BattleEvent.Type` có mặt trong bảng hoặc nằm trong danh sách "cố ý im" (thêm loại sự kiện mới mà quên bảng thì test trượt); mọi đường dẫn tồn tại (`ResourceLoader.exists`) và `load()` ra `AudioStream`.
- [x] Task 2: Bộ phát (AC: 4, 8, 10, 11, 12, 14)
  - [x] 2.1 Tạo `game/src/ui/sound.gd` (hoặc tên gợi ý khác): `Node` do `main.gd` dựng và gắn vào cây (theo khuôn `Notice`, đi xuống bằng gọi hàm). **Không thêm autoload** (luật: `AppState` là autoload duy nhất). Hàm tĩnh `Sound.ui_hover()/ui_click()` cho `UiStyle.apply_button` gọi tới một tham chiếu tĩnh `Sound.host` (đặt lúc `setup`, null thì không làm gì, giống `Art._cache`). Nếu thấy cách này vi phạm luật kiến trúc thì **hỏi tác giả** trước khi đổi.
  - [x] 2.2 Tạo hai bus "Nhạc" và "Hiệu ứng" bằng `AudioServer.add_bus` lúc `setup` (nếu chưa có), đặt âm lượng mặc định; `set_muted(bool)` đặt mute cả hai bus.
  - [x] 2.3 `play_sfx(name)`: chặn trước lần bấm đầu, chống trùng 0,05 giây, tối đa 8 tiếng; mỗi lần phát tạo một `AudioStreamPlayer` rồi `queue_free()` ở `finished` (**không object pool**, luật dự án).
  - [x] 2.4 `play_music(path)`: bật `loop` lên stream `.ogg` khi nạp; một `AudioStreamPlayer` nhạc; cùng bản đang phát thì bỏ qua; đổi bản bằng `Tween` hạ âm lượng 0,5 giây; ghi nhớ nhạc cần phát nếu chưa mở khóa.
  - [x] 2.5 `unlock()`: gọi ở lần `InputEventMouseButton` hoặc `InputEventKey` pressed đầu tiên (bắt trong `main.gd._input`); sau đó phát nhạc đang chờ.
- [x] Task 3: Gắn vào trận (AC: 1, 3, 4)
  - [x] 3.1 `EventPlayer.setup(board, notice, sound)` (thêm tham số tùy chọn cuối, test cũ giữ nguyên). Trong `_play_one`, gọi tiếng ngay đầu mỗi nhánh có tiếng; **không** gọi ở nhánh `instant`/`_apply_instant`.
  - [x] 3.2 Lấy loại quân từ `snapshot.unit_by_id(event.unit_id)` (cách `_play_one` đã làm cho tiếp viện). Quân đã gục khỏi snapshot hoặc `snapshot == null` thì dùng tiếng mặc định theo bảng, không lỗi.
  - [x] 3.3 `main.gd._start_battle` đổi nhạc theo `SoundMap.music_for_level(_level_id)`; `_show_transition` im nhạc (trừ thắng chiến dịch); `_show_menu` phát nhạc menu; kết quả thắng/thua đã có tín hiệu thì nhạc nền nhỏ dần.
- [x] Task 4: Nút âm thanh và cài đặt (AC: 5, 6, 7, 8)
  - [x] 4.1 `PlayerSettings`: thêm `muted: bool` và mục `[am_thanh] tat_tieng`; nạp/ghi giữ tương thích file cũ; giá trị lạ → `add_warning`.
  - [x] 4.2 Nút `SoundButton` (hoặc dựng trực tiếp trong `main.gd`): góc trên phải, mọi màn; phím M qua InputMap (bảng phím theo khuôn `FAST_FORWARD_ACTION` ở `battle_input.gd`); bấm → `Sound.set_muted`, ghi `AppState.settings`, `Log.info("settings", ...)`, lưu như `_on_fast_forward_changed` (lỗi ghi → `Log.error`).
  - [x] 4.3 Khóa chữ mới vào `i18n/text.csv` (`hud.sound.on`, `hud.sound.off` hoặc tên khác cùng khuôn `hud.fast.*`). Chạy test khóa i18n.
  - [x] 4.4 `UiStyle.apply_button` nối `mouse_entered` → `Sound.ui_hover`, `pressed` → `Sound.ui_click` (không đổi 4 trạng thái nút của 8.5).
- [x] Task 5: Test và nghe (AC: 13 đến 17)
  - [x] 5.1 Viết các test ở AC 16 (`test_sound_map.gd`, `test_sound.gd`, thêm vào `test_player_settings`/`test_event_player.gd`/`test_main.gd`). Test kiểm trạng thái (tên tiếng đã yêu cầu phát, mute của bus) qua một danh sách ghi lại, không cần nghe.
  - [x] 5.2 `tools/test.sh` xanh (gồm `check_boundaries.sh`, `test_assets.gd`, `test_export_preset.gd`, khóa `text.csv`).
  - [x] 5.3 `tools/build_web.sh`, ghi dung lượng nén; chạy `tools/chay_web.sh` và thử các bước ở "Cách tác giả thử" trên Chrome.
  - [x] 5.4 Chụp nút Âm thanh trên 3 màn (AC 17); ghi vào Completion Notes: âm lượng cuối, bảng tiếng đã nghe có chỗ nào chói hoặc lệch.

## Dev Notes

### Hiện trạng cần đọc trước khi code (kiểm 2026-11-01, commit `888c558`)

- **Chưa có code âm thanh.** `grep Audio src/` không ra gì. `project.godot` chưa có bus riêng. `assets/audio/sfx/*.wav` (20 file), `assets/audio/music/bgm_*.ogg` (4 file), đều có `.import`; `bgm_*.ogg.import` đang `loop=false`.
- `src/battle/event_player.gd` (~435 dòng): `play(events, snapshot)` phát từng `BattleEvent`; `_play_one(event, seconds, snapshot)` (dòng ~154) có `match event.type` cho từng loại; `_apply_instant` (dòng ~224) dùng khi `instant` (headless/`play_now`); `_spawn_fx` dựng hiệu ứng (8.4). `setup(board, notice)` nhận phụ thuộc kiểu "đi xuống gọi hàm". Tua nhanh = `set_speed`, không bỏ sự kiện.
- `src/app/main.gd` (~494 dòng): dựng mọi màn một lần trong `_ready()`, `_screen` là `MENU/BATTLE/TRANSITION/ERROR`; `_start_battle` (dòng ~185), `_show_transition` (~296), `_show_menu` (~344), `_load_settings` (~355), `_on_fast_forward_changed` (~364, mẫu lưu cài đặt), `_on_playback_finished` (~281).
- `src/data/player_settings.gd`: `ConfigFile`, mục `[hoat_anh] toc_do`; `PlayerSettings.path` (test đổi sang `user://test_cai_dat.cfg` ở `tests/pre_run.gd`). Mẫu nạp có cảnh báo, không chặn game.
- `src/ui/ui_style.gd`: `apply_button(button)` là chỗ chung của mọi nút (8.5).
- `src/ui/hud.gd`: nút Hủy (`undo_pressed`), Chơi lại, mưu kế, Kết thúc lượt, Tua nhanh, "? Thao tác". Khung HUD đã cao gần hết màn: **đừng** thêm nút vào đây.
- `battle_input.gd`: phím khai báo bằng code vào InputMap (`FAST_FORWARD_ACTION`); `_unhandled_input` để nút UI nhận chuột trước.
- `project-context.md`: "Âm thanh chỉ phát sau lần bấm đầu tiên"; "Hoạt ảnh chỉ phát lại `BattleEvent`"; **không object pool**; `src/core/` cấm `Node`.
- `game-architecture.md` dòng 199 và 257: `AudioStreamPlayer` có sẵn, **2 bus (Nhạc, Hiệu ứng)**, chỉ bật sau lần bấm đầu.
- Export preset `export_filter="all_resources"`: file `.wav`/`.ogg` tự vào bản web. `exclude_filter` không loại audio.

### Bảng tiếng (mặc định, đổi ở `SoundMap`)

| Sự kiện (`BattleEvent.Type`, điều kiện) | Tiếng |
|---|---|
| `ATTACKED` của Nguyễn Khoái | `sfx_chem` |
| `ATTACKED` của Phạm Ngũ Lão (phóng lao) | `sfx_phong_lao` |
| `ATTACKED` của Trần Khánh Dư (kéo) | `sfx_keo_dich` |
| `ATTACKED` của Bộ binh Nguyên | `sfx_dap_khieng` |
| `ATTACKED` của Kỵ binh Nguyên | `sfx_ngua_phi` |
| `ATTACKED` của Cung kỵ Nguyên | `sfx_ban_cung` |
| `COLLIDED` | `sfx_va_cham` |
| `DAMAGED` với `cause == SPIKES` | `sfx_chong_dam` |
| `DIED` | `sfx_guc_nga` |
| `DROWNED` | `sfx_roi_song` |
| `VILLAGE_DAMAGED` | `sfx_lang_trung_don` |
| `HEALED` | `sfx_hoi_mau` |
| `REINFORCEMENT_SPAWNED` | `sfx_tiep_vien` |
| `GRANARY_BURNED` | `sfx_lua_chay` |
| `STRATAGEM_USED` loại `SAT_THAT` | `sfx_sat_that` |
| `STRATAGEM_USED` loại `VUON_KHONG_NHA_TRONG` | (im; tiếng lửa đã phát ở `GRANARY_BURNED`) |
| `VICTORY` | `sfx_thang` |
| `DEFEAT` | `sfx_thua` |
| Hủy nước đi thành công (lệnh, không phải sự kiện) | `sfx_huy_nuoc` |
| Rê/bấm nút | `sfx_re_chuot` / `sfx_bam_nut` |
| `MOVED`, `DAMAGED` (nguyên nhân khác chông), `TELEGRAPHED`, `TELEGRAPH_CANCELLED`, `REINFORCEMENT_WARNED`, `REINFORCEMENT_BLOCKED`, `ROUND_STARTED`, `REJECTED` | cố ý im |

Ghi chú: `DAMAGED` sau `ATTACKED`/`COLLIDED` thường đã có tiếng của đòn rồi nên mặc định im để không đập hai tiếng một lúc; riêng chông có tiếng riêng vì đi ngang chông không có `ATTACKED`. Nếu nghe thấy thiếu lực thì báo tác giả, đừng tự thêm.

### Rủi ro cần nghe và thử (báo tác giả)

- **Web chặn âm thanh tự phát.** Kiểm trên Chrome thật (không chỉ máy). Nếu trong iframe itch.io khác trên `127.0.0.1`, ghi lại để thử khi tác giả deploy riêng tư.
- **Nhiều đòn một pha địch** (tối đa 3 giây, có thể tới nhiều sự kiện) có thể thành tiếng ồn: chống chồng ở AC 4. Nghe pha địch ở trận 5, 6 (nhiều quân) cả thường và tua nhanh.
- **`sfx_bam_nut.wav` và `sfx_thua.wav` ~350 KB**, dài hơn các tiếng khác (~2 giây): kiểm không cắt cụt, không chặn tiếng khác.
- **Nhạc `.ogg` lặp có tiếng "tách"** ở chỗ nối: nghe thử; nếu có, báo tác giả (không tự cắt nhạc).
- **Lần bấm đầu = lần bấm "Chơi mới"/"Chơi tiếp"**: nhạc menu chỉ nghe được nếu người chơi bấm vào chỗ trống trước. Xem Câu hỏi 1.
- Test headless: `AudioServer` dùng driver "Dummy", `AudioStreamPlayer.play()` không lỗi nhưng không ra tiếng. Test kiểm *yêu cầu phát*, không kiểm tiếng thật.

### Cách tác giả thử (cho báo cáo cuối của dev)

1. `tools/chay.sh` hoặc `tools/chay_web.sh`: lúc mới mở **chưa có tiếng**; bấm chuột vào chỗ trống (hoặc nhấn phím bất kỳ) thì **nghe** nhạc menu.
2. Góc trên phải có nút "Âm thanh: bật". Bấm hoặc nhấn M: nhạc **tắt hẳn**, nút đổi thành "tắt". Bấm lại: nhạc vào lại. Đóng rồi mở lại game: vẫn giữ lựa chọn vừa chọn.
3. Rê chuột vào nút: tiếng nhỏ; bấm nút: tiếng bấm. Bấm "Chơi mới": nhạc đổi sang nhạc trận (mượt, không đứt).
4. Trong trận: đi tướng (im), đánh Khoái ("chém"), Lão ("phóng lao"), Dư ("kéo"); đẩy quân vào quân khác ("va chạm"), xuống sông ("rơi sông"), vào hầm chông ("chông"); quân gục ("gục ngã"). Bấm Kết thúc lượt: nghe tiếng quân Nguyên đánh, tua nhanh (T) vẫn nghe nhưng không ồn hơn.
5. Thắng trận: nhạc nhỏ dần, nghe kèn thắng. Thua (để hết hiệp): kèn thua. Qua màn chuyển trận: im lặng; vào trận kế: nhạc trận vào lại. Trận 6: nhạc căng hơn (`bgm_cang_thang`).
6. Thắng cả chiến dịch: nhạc khải hoàn. Về menu: nhạc menu.

### Việc thuộc story khác (đừng làm ở đây)

- Thanh trượt âm lượng, tách tắt riêng nhạc/tiếng, âm 3D theo vị trí ô.
- Tiếng bước chân, tiếng riêng từng loại địa hình, giọng nói/lời dẫn truyện (cần file mới và chữ của tác giả).
- Ghi công trong game (màn hình chính): story phát hành. Chỉ cần `CREDITS.md` đã có đủ dòng (AC "giấy phép từng file ghi ở `CREDITS.md`" **đã thỏa**, kiểm lại không thiếu file nào; **không** thêm dòng trùng).

### Project Structure Notes

- File mới: `game/src/ui/sound_map.gd`, `game/src/ui/sound.gd` (+ `.uid` mỗi file, do Godot sinh), `game/tests/test_sound_map.gd`, `game/tests/test_sound.gd` (+ `.uid`). File sửa: `src/battle/event_player.gd`, `src/app/main.gd`, `src/data/player_settings.gd`, `src/ui/ui_style.gd`, `i18n/text.csv`, `tests/test_event_player.gd`, `tests/test_main.gd`, test của `PlayerSettings`.
- Không sửa `src/core/`, không sửa `assets/audio/` (kể cả `.import`).

### Previous Story Intelligence (8.1 đến 8.6)

- 8.1: đặt hình vào kho và `Art.tex()` (nạp có nhớ, thiếu thì báo một lần); lấy làm khuôn cho nạp âm thanh.
- 8.4: `EventPlayer` đã có điểm gắn cho từng loại sự kiện (`_spawn_fx` theo `cause`/loại quân); gắn tiếng ở đúng chỗ đó, đừng dựng đường phát lại thứ hai.
- 8.5: `UiStyle.apply_button` là chỗ chung của nút; 4 trạng thái nút và màu chữ đã có test, đừng phá.
- 8.6: review bắt được "test xanh giả" (chờ `_draw` mà headless không vẽ) và "công tắc `UiStyle.ENABLED` không nhất quán": ở đây cũng dễ gặp, test phải kiểm thật thứ cần kiểm, và mọi thành phần mới theo cùng công tắc nếu có.
- Tác giả duyệt bằng mắt/tai; mỗi story `tools/test.sh` xanh.

### Git Intelligence

- 5 commit gần nhất là Story 8.2 đến 8.6 (hình và giao diện). 8.6: `888c558`. Tệp `img/pixellab-thu/cong-cu/chup.gd` có sửa chưa commit và **không thuộc story**: commit theo từng đường dẫn, đừng add cả thư mục.
- Lời commit tiếng Việt, kết thúc bằng dòng `(Story 8.7)`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story-8.7]
- [Source: _bmad-output/planning-artifacts/game-architecture.md (Âm thanh, dòng 140, 199, 257)]
- [Source: _bmad-output/project-context.md (Hiệu năng, Nền tảng và build, luật Godot)]
- [Source: game/src/battle/event_player.gd, game/src/app/main.gd, game/src/data/player_settings.gd, game/src/ui/ui_style.gd, game/src/ui/art.gd]
- [Source: game/assets/CREDITS.md (mục Âm thanh và nhạc)]

## Câu hỏi cho tác giả

Dev làm theo mặc định; tác giả đổi sau khi nghe.

1. **Nhạc menu khi chưa bấm gì.** Luật dự án: không phát trước lần bấm đầu (trình duyệt chặn). Mặc định: nhạc menu vào ở lần bấm/nhấn phím đầu tiên (kể cả bấm vào chỗ trống). Hệ quả: người bấm thẳng "Chơi mới" sẽ không nghe nhạc menu. Cách khác: thêm một dòng "Bấm để bắt đầu" trước menu (đổi thêm một màn).
2. **Tiếng nào cho sự kiện nào.** Bảng ở Dev Notes là phỏng đoán theo tên file (ví dụ "dập khiên" cho Bộ binh, "ngựa phi" cho Kỵ binh). Nghe thử rồi đổi một bảng.
3. **Nút tắt tiếng.** Mặc định: một nút cho cả nhạc và tiếng, góc trên phải mọi màn, phím M. Cách khác: hai nút (nhạc, tiếng) hoặc đặt trong bảng "? Thao tác".
4. **Tiếng rê và bấm nút.** Mặc định: có (`sfx_re_chuot`, `sfx_bam_nut`) trên mọi nút. Cách khác: chỉ tiếng bấm, bỏ tiếng rê cho đỡ ồn.
5. **Nhạc căng (`bgm_cang_thang`).** Mặc định: dùng cho trận 6 (trận cuối). Cách khác: dùng khi Lòng dân chỉ còn 1 hoặc hiệp cuối (cần thêm điều kiện, và là luật hiển thị, hỏi lại trước khi làm), hoặc không dùng.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5

### Debug Log References

- Chụp nút Âm thanh bằng script tạm (`--script`); script đã xóa. Lần chụp bấm thử nút tắt tiếng đã ghi nhầm `tat_tieng=true` vào `settings.cfg` thật của tác giả; đã trả về `false` ngay.

### Completion Notes List

- **Làm xong:** `SoundMap` (bảng sự kiện → tiếng, nhạc theo trận, danh sách loại sự kiện cố ý im; test bắt loại sự kiện mới thiếu khai báo). `Sound` (Node do `main.gd` dựng, `Sound.host` tĩnh như `Art`, không autoload): bus "Music" và "SFX" tạo bằng code, chỉ phát sau lần bấm/nhấn phím đầu (`unlock`), chống chồng tiếng 0,05 giây và tối đa 8 tiếng, mỗi tiếng một `AudioStreamPlayer` tự hủy (không object pool), nhạc `.ogg` lặp bằng code, đổi nhạc mờ dần 0,25 + 0,25 giây, thiếu file chỉ một dòng ERROR. `EventPlayer._cue` phát tiếng ở `_play_one` và `_apply_instant`, im khi `instant`. `UiStyle.apply_button` nối tiếng rê/bấm cho mọi nút (không đổi 4 trạng thái nút). Hủy nước đi thành công có `sfx_huy_nuoc`. `PlayerSettings` thêm `[am_thanh] tat_tieng` (file cũ vẫn nạp, giá trị lạ → cảnh báo). Nút "Âm thanh (M)" góc trên phải mọi màn, phím M, lưu ngay.
- **Khác story một chút (đã cân nhắc):** `EventPlayer` và `BattleView` gọi qua `Sound.host` thay vì thêm tham số `sound` vào `setup()` (ít sửa hơn, test cũ giữ nguyên). Tắt tiếng dùng mute của hai bus: nhạc vẫn chạy ngầm nhưng im hẳn, bật lại nghe tiếp đúng nhạc màn đó.
- **Hết ngân sách pha (3 giây):** sự kiện bị áp ngay không có hoạt ảnh thì vẫn có tiếng (đi qua `_apply_instant`), trừ khi `instant`.
- **Âm lượng:** nhạc -12 dB, tiếng -4 dB (mặc định theo story, chưa chỉnh vì tác giả chưa nghe).
- **Dung lượng:** bản nén web 15,3 MB (giới hạn 25 MB), tăng từ 11,0 MB vì có âm thanh.
- **Test:** 1037/1037 (trước story: 1011). Mới: `test_sound_map.gd`, `test_sound.gd`, thêm vào `test_player_settings.gd`, `test_event_player.gd`, `test_main.gd`.
- **Ảnh duyệt:** nút Âm thanh trên menu, trận, màn chuyển trận, và khi tắt: `anh/8-7-nut-am-thanh-*.png`. Nút nằm sát phía trên khung HUD nhưng không chạm.
- **Chưa kiểm được bằng máy:** chất lượng tiếng, độ lớn, chỗ nối lặp nhạc, hành vi chặn âm thanh của trình duyệt trong iframe itch.io. Tác giả nghe và duyệt.
- **CREDITS:** hai dòng âm thanh và nhạc đã có (thêm cùng lúc với file âm thanh, chưa commit), đủ 20 SFX + 4 nhạc; không thêm dòng.

### File List

- game/src/ui/sound_map.gd (+ .uid), game/src/ui/sound.gd (+ .uid), game/src/ui/ui_style.gd, game/src/battle/event_player.gd, game/src/battle/battle_view.gd, game/src/data/player_settings.gd, game/src/app/main.gd, game/i18n/text.csv, game/i18n/text.vi.translation
- game/tests/test_sound_map.gd (+ .uid), game/tests/test_sound.gd (+ .uid), game/tests/test_player_settings.gd, game/tests/test_event_player.gd, game/tests/test_main.gd
- game/assets/audio/ (20 SFX, 4 nhạc, `.import`), game/assets/CREDITS.md
- _bmad-output/implementation-artifacts/anh/8-7-nut-am-thanh-*.png (4 ảnh), 8-7-am-thanh.md, sprint-status.yaml

## Change Log

- 2026-11-01: Tạo story 8.7 (create-story), `ready-for-dev`.
- 2026-11-01: Triển khai 8.7: tiếng theo sự kiện, tiếng nút, nhạc theo màn, nút Âm thanh (M), lưu `tat_tieng`; `review`.
