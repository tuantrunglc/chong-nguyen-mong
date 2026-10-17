class_name BoardView
extends Node2D
## Vẽ bàn cờ trống bằng code, đặt giữa khung 1280×720. Chưa có địa hình, chưa có quân.

const CELL_SIZE: int = 88
const VIEWPORT_SIZE: Vector2 = Vector2(1280, 720)
const CELL_COLOR: Color = Color(0.93, 0.87, 0.73)
const LINE_COLOR: Color = Color(0.36, 0.24, 0.14)
const LINE_WIDTH: float = 2.0
const BORDER_WIDTH: float = 4.0

var cols: int = 7
var rows: int = 7


func setup(new_cols: int = 7, new_rows: int = 7) -> void:
	cols = new_cols
	rows = new_rows
	var board_size: Vector2 = Vector2(cols * CELL_SIZE, rows * CELL_SIZE)
	position = (VIEWPORT_SIZE - board_size) / 2.0
	queue_redraw()


func _ready() -> void:
	setup(cols, rows)


func _draw() -> void:
	var board_size: Vector2 = Vector2(cols * CELL_SIZE, rows * CELL_SIZE)
	draw_rect(Rect2(Vector2.ZERO, board_size), CELL_COLOR)
	for c: int in range(1, cols):
		var x: float = c * CELL_SIZE
		draw_line(Vector2(x, 0), Vector2(x, board_size.y), LINE_COLOR, LINE_WIDTH)
	for r: int in range(1, rows):
		var y: float = r * CELL_SIZE
		draw_line(Vector2(0, y), Vector2(board_size.x, y), LINE_COLOR, LINE_WIDTH)
	draw_rect(Rect2(Vector2.ZERO, board_size), LINE_COLOR, false, BORDER_WIDTH)
