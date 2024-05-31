class_name UnitPath
extends TileMap

@export var grid: Grid
var current_path := PackedVector2Array()
var _pathfinder: Pathfinder

func initialize(walkable_cells: Array) -> void:
	_pathfinder = Pathfinder.new(grid, walkable_cells)

func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(0,0))

func display_attack_range(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(2,0))

## Finds and draws the path between `cell_start` and `cell_end`
func get_walk_path(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	current_path = _pathfinder.calculate_point_paths(cell_start, cell_end)

func get_walkable_cells() -> Array:
	var map_rect = Rect2i(grid.start_rect, grid.tilemap_size)
	var vectors_inside :Array = []
	 # Iterate over each point inside the rectangle
	for x in range(map_rect.position.x, map_rect.position.x + map_rect.size.x):
		for y in range(map_rect.position.y, map_rect.position.y + map_rect.size.y):
			vectors_inside.append(Vector2i(x, y))
	return vectors_inside

func clear_cells(grid_data: Grid) -> void:
	var cells = []
	for x in range(grid_data.start_rect.x, grid_data.start_rect.x + grid_data.tilemap_size.x):
		for y in range(grid_data.start_rect.y, grid_data.start_rect.y + grid_data.tilemap_size.y):
			cells.append(Vector2(x, y))
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(2,0))
