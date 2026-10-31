class_name PlayerSettings
extends RefCounted
## Cài đặt người chơi (Story 4.4): user://settings.cfg (ConfigFile), riêng với file lưu tiến độ (kiến trúc "Lưu game").
## Hiện chỉ có tốc độ hoạt ảnh pha địch: [hoat_anh] toc_do = 1.0 (thường) hoặc 3.0 (tua nhanh).
## File hỏng không bao giờ chặn game: dùng mặc định, chỉ có cảnh báo. Không ghi log: bên gọi ghi.

const DEFAULT_PATH: String = "user://settings.cfg"
const SECTION: String = "hoat_anh"
const SPEED_KEY: String = "toc_do"
const NORMAL_SPEED: float = 1.0
## Bằng EventPlayer.FAST_SPEED; các giá trị khác trong file là lạ.
const FAST_SPEED: float = 3.0

## File main.gd dùng. Test (và hook tests/pre_run.gd) đặt đường dẫn khác để không đụng cài đặt thật.
static var path: String = DEFAULT_PATH

## Tốc độ hoạt ảnh pha địch: NORMAL_SPEED hoặc FAST_SPEED.
var animation_speed: float = NORMAL_SPEED


func is_fast() -> bool:
	return animation_speed == FAST_SPEED


## Luôn ok và luôn có data (PlayerSettings); file không đọc được hoặc giá trị lạ thì là cảnh báo, dùng mặc định.
static func load_settings() -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var settings: PlayerSettings = PlayerSettings.new()
	result.data = settings
	if not FileAccess.file_exists(path):
		return result
	var file: String = JsonFile.label(path)
	var config: ConfigFile = ConfigFile.new()
	var error: Error = config.load(path)
	if error != OK:
		result.add_warning("%s: không đọc được file cài đặt (mã lỗi %d), dùng mặc định" % [file, error])
		return result
	if not config.has_section_key(SECTION, SPEED_KEY):
		return result
	var value: Variant = config.get_value(SECTION, SPEED_KEY)
	if (value is float or value is int) and float(value) in [NORMAL_SPEED, FAST_SPEED]:
		settings.animation_speed = float(value)
	else:
		result.add_warning('%s: "%s" là %s, dùng %d' % [file, SPEED_KEY, JsonFile.show(value), int(NORMAL_SPEED)])
	return result


## Ghi cả file (ghi đè file hỏng). Trả OK hoặc mã lỗi.
func save() -> Error:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(SECTION, SPEED_KEY, animation_speed)
	return config.save(path)
