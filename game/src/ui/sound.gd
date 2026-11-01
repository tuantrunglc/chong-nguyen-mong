class_name Sound
extends Node
## Bộ phát tiếng và nhạc (Story 8.7). main.gd dựng một cái và đặt Sound.host; chỗ khác gọi qua host (như Art: không phải
## autoload). Hai bus "Music" và "SFX" tạo bằng code. Chỉ phát sau lần bấm đầu tiên (trình duyệt chặn âm thanh tự phát):
## nhạc yêu cầu trước đó được nhớ rồi vào ở unlock(). Thiếu file thì một dòng ERROR, game vẫn chạy.

const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"
const MUSIC_VOLUME_DB: float = -12.0
const SFX_VOLUME_DB: float = -4.0
const SILENT_DB: float = -60.0
## Cùng một tiếng không phát lại trong khoảng này (tua nhanh không thành tiếng ồn).
const DEDUPE_MSEC: int = 50
const MAX_VOICES: int = 8
const FADE_SECONDS: float = 0.25
const LOG_LIMIT: int = 64

## Bộ phát đang dùng (do main.gd đặt). Null thì mọi lệnh phát là không làm gì.
static var host: Sound = null

static var _streams: Dictionary = {}
static var _reported: Dictionary = {}

## Tên các tiếng đã thực sự phát (để test), giữ LOG_LIMIT cái cuối.
var played_log: Array[String] = []

var _unlocked: bool = false
var _muted: bool = false
var _voices: int = 0
var _last_play: Dictionary = {}
## Nhạc đang được yêu cầu (tên file); "" là im. Phát thật khi đã mở khóa.
var _wanted_music: String = ""
var _playing_music: String = ""
## Bản nhạc mà lần đổi nhạc gần nhất đang hướng tới (có thể còn đang mờ dần).
var _applied_music: String = ""
var _music_player: AudioStreamPlayer = null
var _music_tween: Tween = null


static func reset_for_test() -> void:
	_streams.clear()
	_reported.clear()
	host = null


## Phát tiếng giao diện (rê, bấm nút). Không làm gì nếu chưa có bộ phát.
static func ui_hover() -> void:
	if host != null:
		host.play_sfx(SoundMap.RE_CHUOT)


static func ui_click() -> void:
	if host != null:
		host.play_sfx(SoundMap.BAM_NUT)


func _ready() -> void:
	_ensure_bus(BUS_MUSIC, MUSIC_VOLUME_DB)
	_ensure_bus(BUS_SFX, SFX_VOLUME_DB)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	# Nạp sẵn toàn bộ (luật dự án: không nạp động).
	for file: String in SoundMap.all_sfx():
		_stream(SoundMap.sfx_path(file))
	for file: String in SoundMap.all_music():
		_stream(SoundMap.music_path(file))


func _exit_tree() -> void:
	if host == self:
		host = null


func is_unlocked() -> bool:
	return _unlocked


func is_muted() -> bool:
	return _muted


## Nhạc đang được yêu cầu (có thể chưa phát vì chưa mở khóa).
func wanted_music() -> String:
	return _wanted_music


func playing_music() -> String:
	return _playing_music


## Lần bấm hoặc nhấn phím đầu tiên của người chơi: từ đây mới có tiếng; nhạc đang chờ vào luôn.
func unlock() -> void:
	if _unlocked:
		return
	_unlocked = true
	_apply_music()


## Tắt hoặc bật cả nhạc và tiếng (mute hai bus). Bật lại thì đúng nhạc của màn hiện tại nghe tiếp.
func set_muted(value: bool) -> void:
	_muted = value
	for bus_name: String in [BUS_MUSIC, BUS_SFX]:
		var index: int = AudioServer.get_bus_index(bus_name)
		if index >= 0:
			AudioServer.set_bus_mute(index, value)


## file là tên file trong SoundMap (ví dụ SoundMap.CHEM). Trả true nếu thật sự phát.
func play_sfx(file: String) -> bool:
	if file.is_empty() or not _unlocked:
		return false
	var now: int = Time.get_ticks_msec()
	if _last_play.has(file) and now - int(_last_play[file]) < DEDUPE_MSEC:
		return false
	if _voices >= MAX_VOICES:
		return false
	_last_play[file] = now
	played_log.append(file)
	if played_log.size() > LOG_LIMIT:
		played_log.pop_front()
	var stream: AudioStream = _stream(SoundMap.sfx_path(file))
	if stream == null:
		return false
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = BUS_SFX
	player.stream = stream
	_voices += 1
	player.finished.connect(func() -> void:
		_voices -= 1
		player.queue_free())
	add_child(player)
	player.play()
	return true


## Đổi nhạc nền. Cùng bản đang yêu cầu thì không làm gì (không phát lại từ đầu).
func play_music(file: String) -> void:
	if file == _wanted_music:
		return
	_wanted_music = file
	_apply_music()


## Nhạc nhỏ dần rồi tắt.
func stop_music() -> void:
	play_music("")


func _apply_music() -> void:
	if not _unlocked or _music_player == null or _wanted_music == _applied_music:
		return
	if _music_tween != null:
		_music_tween.kill()
	var target: String = _wanted_music
	_applied_music = target
	_music_tween = create_tween()
	if _music_player.playing:
		_music_tween.tween_property(_music_player, "volume_db", SILENT_DB, FADE_SECONDS)
	_music_tween.tween_callback(_start_music.bind(target))
	if not target.is_empty():
		_music_tween.tween_property(_music_player, "volume_db", 0.0, FADE_SECONDS)


func _start_music(file: String) -> void:
	_playing_music = file
	_music_player.stop()
	if file.is_empty():
		return
	var stream: AudioStream = _stream(SoundMap.music_path(file))
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = SILENT_DB
	_music_player.play()


static func _stream(path: String) -> AudioStream:
	if _streams.has(path):
		return _streams[path] as AudioStream
	var loaded: AudioStream = null
	if ResourceLoader.exists(path):
		loaded = load(path) as AudioStream
	if loaded == null:
		if not _reported.has(path):
			_reported[path] = true
			Log.error("am_thanh", "Không nạp được âm thanh %s: file không có hoặc hỏng" % path)
		return null
	if loaded is AudioStreamOggVorbis:
		(loaded as AudioStreamOggVorbis).loop = true
	_streams[path] = loaded
	return loaded


static func _ensure_bus(bus_name: String, volume_db: float) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_volume_db(index, volume_db)
