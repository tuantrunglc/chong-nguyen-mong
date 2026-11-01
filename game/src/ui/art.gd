class_name Art
extends RefCounted
## Chỗ gọi hình duy nhất của game (Story 8.1). Mọi nơi cần hình trong assets/textures đều gọi Art.tex(), không load() riêng.
## Nạp một lần rồi nhớ. Thiếu hoặc hỏng thì ghi một dòng ERROR bằng tiếng Việt và trả ô hồng đậm 64×64:
## game không kẹt, và chỗ thiếu hình hiện ngay trên màn hình.

const BASE_DIR: String = "res://assets/textures/"
const PLACEHOLDER_SIZE: int = 64
const PLACEHOLDER_COLOR: Color = Color(1.0, 0.0, 0.6)

static var _cache: Dictionary = {}
static var _reported: Dictionary = {}
static var _placeholder: Texture2D = null


## path tính từ assets/textures/, ví dụ "quan/tex_khoai_south.png".
static func tex(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path] as Texture2D
	var full: String = BASE_DIR + path
	var loaded: Texture2D = null
	if ResourceLoader.exists(full):
		loaded = load(full) as Texture2D
	if loaded == null:
		if not _reported.has(path):
			_reported[path] = true
			Log.error("hinh", "Không nạp được hình %s (%s): file không có hoặc hỏng" % [path, full])
		return _get_placeholder()
	_cache[path] = loaded
	return loaded


## Xóa bộ nhớ và danh sách lỗi đã báo (cho test).
static func reset_for_test() -> void:
	_cache.clear()
	_reported.clear()


static func _get_placeholder() -> Texture2D:
	if _placeholder == null:
		var img: Image = Image.create(PLACEHOLDER_SIZE, PLACEHOLDER_SIZE, false, Image.FORMAT_RGBA8)
		img.fill(PLACEHOLDER_COLOR)
		_placeholder = ImageTexture.create_from_image(img)
	return _placeholder
