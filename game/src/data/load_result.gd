class_name LoadResult
extends RefCounted
## Kết quả nạp một file dữ liệu: {ok, data, errors}. Không bao giờ làm sập game.
## Mỗi lỗi là một câu tiếng Việt có file, vị trí và giá trị sai. Cảnh báo không chặn việc nạp.

## Stats hoặc LevelData; null khi có lỗi.
var data: RefCounted = null
var errors: Array[String] = []
var warnings: Array[String] = []
var ok: bool:
	get:
		return errors.is_empty()


func add_error(message: String) -> void:
	errors.append(message)


func add_warning(message: String) -> void:
	warnings.append(message)
