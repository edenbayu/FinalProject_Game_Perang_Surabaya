class_name Pathfinder
extends Resource

var _grid: Resource
var _astar := AStarGrid2D.new()

##Init untuk AstartGrid2D's Grid 
func _init(grid: Grid, walkable_cells: Array) -> void:
	_grid = grid
	var map_rect = Rect2i(_grid.start_rect, _grid.tilemap_size)
	_astar.region = map_rect
	_astar.cell_size = _grid.cell_size
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	_astar.update()
	
	var vectors_inside = []
	 # Iterate over each point inside the rectangle
	for x in range(_astar.region.position.x, _astar.region.position.x + _astar.region.size.x):
		for y in range(_astar.region.position.y, _astar.region.position.y + _astar.region.size.y):
			vectors_inside.append(Vector2(x, y))

	##Iterasi untuk seluruh points dalam grid yang bukan termasuk walkable 
	##PR BENARKAN KODINGAN DIBAWAH INI##
	#for cell in vectors_inside:
		#if cell not in walkable_cells:
			#_astar.set_point_solid(cell)
	#print("pathfinder initialized!")
	#
	###This is a code to check the solid points inside used cells
	#for cell in vectors_inside:
		#if not _astar.is_point_solid(cell):
			#print("Non solid-cell:", cell)

func calculate_point_paths(start: Vector2, end: Vector2)-> PackedVector2Array:
	return _astar.get_id_path(start, end)
