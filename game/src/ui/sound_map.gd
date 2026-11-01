class_name SoundMap
extends RefCounted
## Bảng tiếng và nhạc của game (Story 8.7). Tên file và "sự kiện nào kêu tiếng nào" nằm ở đây để tác giả đổi ở một chỗ.
## Hàm thuần, không phát gì. File nằm trong assets/audio/ (đã có dòng CREDITS, CC0).

const SFX_DIR: String = "res://assets/audio/sfx/"
const MUSIC_DIR: String = "res://assets/audio/music/"

const CHEM: String = "sfx_chem.wav"
const PHONG_LAO: String = "sfx_phong_lao.wav"
const KEO_DICH: String = "sfx_keo_dich.wav"
const DAP_KHIENG: String = "sfx_dap_khieng.wav"
const NGUA_PHI: String = "sfx_ngua_phi.wav"
const BAN_CUNG: String = "sfx_ban_cung.wav"
const VA_CHAM: String = "sfx_va_cham.wav"
const CHONG_DAM: String = "sfx_chong_dam.wav"
const GUC_NGA: String = "sfx_guc_nga.wav"
const ROI_SONG: String = "sfx_roi_song.wav"
const LANG_TRUNG_DON: String = "sfx_lang_trung_don.wav"
const HOI_MAU: String = "sfx_hoi_mau.wav"
const TIEP_VIEN: String = "sfx_tiep_vien.wav"
const LUA_CHAY: String = "sfx_lua_chay.wav"
const SAT_THAT: String = "sfx_sat_that.wav"
const THANG: String = "sfx_thang.wav"
const THUA: String = "sfx_thua.wav"
const HUY_NUOC: String = "sfx_huy_nuoc.wav"
const RE_CHUOT: String = "sfx_re_chuot.wav"
const BAM_NUT: String = "sfx_bam_nut.wav"

const MUSIC_MENU: String = "bgm_menu.ogg"
const MUSIC_BATTLE: String = "bgm_tran_dau.ogg"
const MUSIC_TENSION: String = "bgm_cang_thang.ogg"
const MUSIC_CAMPAIGN_END: String = "bgm_thang_chien_dich.ogg"

## Trận nào dùng nhạc căng (còn lại dùng nhạc trận). Trận cuối của chuỗi.
const TENSION_LEVELS: Array[String] = ["tran_06"]

## Loại sự kiện cố ý im (test bắt loại sự kiện mới mà quên khai báo ở đây hoặc ở sfx_for_event).
const SILENT_TYPES: Array[int] = [
	BattleEvent.Type.MOVED,
	BattleEvent.Type.REJECTED,
	BattleEvent.Type.ROUND_STARTED,
	BattleEvent.Type.DAMAGED,
	BattleEvent.Type.TELEGRAPHED,
	BattleEvent.Type.TELEGRAPH_CANCELLED,
	BattleEvent.Type.REINFORCEMENT_WARNED,
	BattleEvent.Type.REINFORCEMENT_BLOCKED,
]


static func sfx_path(file: String) -> String:
	return SFX_DIR + file


static func music_path(file: String) -> String:
	return MUSIC_DIR + file


## Mọi file tiếng bảng này dùng (để nạp sẵn và để test).
static func all_sfx() -> Array[String]:
	return [CHEM, PHONG_LAO, KEO_DICH, DAP_KHIENG, NGUA_PHI, BAN_CUNG, VA_CHAM, CHONG_DAM, GUC_NGA, ROI_SONG,
		LANG_TRUNG_DON, HOI_MAU, TIEP_VIEN, LUA_CHAY, SAT_THAT, THANG, THUA, HUY_NUOC, RE_CHUOT, BAM_NUT]


static func all_music() -> Array[String]:
	return [MUSIC_MENU, MUSIC_BATTLE, MUSIC_TENSION, MUSIC_CAMPAIGN_END]


## Tiếng (tên file) cho một sự kiện, "" nếu im. unit_type là loại quân ra đòn (-1 nếu không biết).
static func sfx_for_event(event: BattleEvent, unit_type: int = -1) -> String:
	match event.type:
		BattleEvent.Type.ATTACKED:
			return _attack_sfx(unit_type)
		BattleEvent.Type.COLLIDED:
			return VA_CHAM
		BattleEvent.Type.DAMAGED:
			return CHONG_DAM if event.cause == BattleEvent.Cause.SPIKES else ""
		BattleEvent.Type.DIED:
			return GUC_NGA
		BattleEvent.Type.DROWNED:
			return ROI_SONG
		BattleEvent.Type.VILLAGE_DAMAGED:
			return LANG_TRUNG_DON
		BattleEvent.Type.HEALED:
			return HOI_MAU
		BattleEvent.Type.REINFORCEMENT_SPAWNED:
			return TIEP_VIEN
		BattleEvent.Type.GRANARY_BURNED:
			return LUA_CHAY
		BattleEvent.Type.STRATAGEM_USED:
			return SAT_THAT if event.amount == Stratagem.Kind.SAT_THAT else ""
		BattleEvent.Type.VICTORY:
			return THANG
		BattleEvent.Type.DEFEAT:
			return THUA
	return ""


static func _attack_sfx(unit_type: int) -> String:
	match unit_type:
		UnitType.NGUYEN_KHOAI:
			return CHEM
		UnitType.PHAM_NGU_LAO:
			return PHONG_LAO
		UnitType.TRAN_KHANH_DU:
			return KEO_DICH
		UnitType.BO_BINH:
			return DAP_KHIENG
		UnitType.KY_BINH:
			return NGUA_PHI
		UnitType.CUNG_KY:
			return BAN_CUNG
	return ""


## Nhạc nền của trận. Id lạ dùng nhạc trận thường.
static func music_for_level(level_id: String) -> String:
	return MUSIC_TENSION if TENSION_LEVELS.has(level_id) else MUSIC_BATTLE
