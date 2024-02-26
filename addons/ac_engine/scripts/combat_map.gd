class_name AcCombatMap
extends TileMap


@export var map_width: int = 12
@export var map_height: int = 14
@export var areas: Array = []


#
# Internal map logic
#

var map_2d: AStarGrid2D = AStarGrid2D.new()
var tile_size: Vector2i = Vector2i(128, 128)

func init_map():
	map_2d.size = Vector2i(map_width, map_height)
	map_2d.cell_size = Vector2(1, 1)
	map_2d.offset = Vector2(0, 0)
	map_2d.update()

	# Set the whole map walkable
	for x in range(map_width):
		for y in range(map_height):
			map_2d.set_point_solid(Vector2i(x, y), false)


func is_map_place_free(pos) -> bool:
	return !map_2d.is_point_solid(Vector2i(pos.x, pos.y))


func take_map_place(pos) -> bool:
	if map_2d.is_point_solid(Vector2i(pos.x, pos.y)):
		return false
	
	map_2d.set_point_solid(Vector2i(pos.x, pos.y), true)
	return true


func free_map_place(pos):
	var was_solid: bool = map_2d.is_point_solid(Vector2i(pos.x, pos.y))
	map_2d.set_point_solid(Vector2i(pos.x, pos.y), false)

	return was_solid


func convert_to_map_pos(pos) -> Vector2i:
	var tmp_pos: Vector2 = Vector2(pos) - (position + Vector2(tile_size.x / 2, tile_size.y / 2))
	var ret: Vector2i = Vector2i(floor(tmp_pos.x / tile_size.x), floor(tmp_pos.y / tile_size.y))
	return ret


func convert_from_map_pos(pos) -> Vector2i:
	# return Vector2i(pos.x * tile_size.x + position.x, pos.y * tile_size.y + position.y)
	return Vector2i(pos.x * tile_size.x + position.x + tile_size.x / 2,
		pos.y * tile_size.y + position.y + tile_size.y / 2)


func move_map_place(start, end) -> bool:
	if map_2d.is_point_solid(Vector2i(start.x, start.y)):
		map_2d.set_point_solid(Vector2i(start.x, start.y), false)
		map_2d.set_point_solid(Vector2i(end.x, end.y), true)
		return true
	
	return false


func find_map_path(start: Vector2i, end: Vector2i) -> Array[Variant]:
	var res_path: Array[Variant] = []
	var is_end_solid = free_map_place(end)

	for point in map_2d.get_point_path(start, end):
		if (point.x == start.x and point.y == start.y or
			point.x == end.x and point.y == end.y):
			continue
		res_path.append(Vector2i(floor(point.x), floor(point.y)))
	
	if is_end_solid:
		take_map_place(end)

	return res_path


func find_map_path_full_scale(start: Vector2i, end: Vector2i):
	var map_start = convert_to_map_pos(start)
	var map_end = convert_to_map_pos(end)

	var res_path = find_map_path(map_start, map_end)

	for i in range(res_path.size()):
		res_path[i] = convert_from_map_pos(res_path[i])
	
	return res_path


#
# General
#

func get_atlas_tiles(id):
	var atlas_source: TileSetSource = tile_set.get_source(id)
	var atlas_grid_size = atlas_source.get_atlas_grid_size()
	var res: Array[Variant] = []

	for x in range(atlas_grid_size.x):
		for y in range(atlas_grid_size.y):
			var tile = atlas_source.get_tile_at_coords(Vector2i(x, y))
			if tile != Vector2i(-1, -1):
				res.append(tile) 
	
	return res


func get_tile_size() -> Vector2i:
	return tile_size


func setup_tile_size():
	tile_size = tile_set.tile_size


func get_random_free_place() -> Vector2i:
	var empty_places: Array[Variant] = []

	for x in range(map_width):
		for y in range(map_height):
			if !map_2d.is_point_solid(Vector2i(x, y)):
				empty_places.append(Vector2i(x, y))
	
	if empty_places.size() == 0:
		return Vector2i(-1, -1)
	
	return empty_places[randi() % empty_places.size()]


#! Just a test function
#! You have to use your own one
func generate_random_map():
	var acells = get_atlas_tiles(0)

	for x in range(map_width):
		for y in range(map_height):
			var acell = acells[randi() % acells.size()]
			set_cell(0, Vector2(x, y), 0, acell, 0)


func generate_default_map():
	# Black & white board for chess
	var acells = get_atlas_tiles(0)
	
	for x in range(map_width):
		for y in range(map_height):
			var acell = acells[(x + y) % 2]
			set_cell(0, Vector2(x, y), 0, acell, 0)


func _ready():
	randomize()
	setup_tile_size()

	#! Just a test function
	#! You have to use your own one
	# generate_random_map()

	# generate_default_map()

	init_map()


func _process(delta):
	pass
