@tool
extends Node
## A singleton node that stores persistent data and functions.
## This node is used to store data that needs to be accessed from multiple scenes.


const NAME_GAME_CONTROLLER: String = "GameController"


@export_group("Project paths")
## The path to the directory containing combat unit scenes
@export var path_combat_units: Array[String] = [
	"res://addons/ac_engine/test_project/combat_units/"
]


@export var combat_units: Array[String] = []
@export var combat_unit_names: Array[String] = []
@export var combat_unit_instances: Array[AcCombatUnit] = []


# Called when the node enters the scene tree for the first time
func _ready():
	print("Persistent controller initializing...")
	load_combat_units()
	print("Combat units loaded: ", combat_units)
	print("Combat unit names: ", combat_unit_names)


func get_game_controller(scn_tree) -> Node:
	return scn_tree.get_root().get_node(NAME_GAME_CONTROLLER)


func get_scene_list(scr_dir) -> Array[Variant]:
	var res_lst: Array[Variant] = []
	var dir: DirAccess = DirAccess.open(scr_dir)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "tscn":
					res_lst.append(file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return res_lst


func get_combat_unit_list(dir_path) -> Array[Variant]:
	var res_lst: Array[Variant] = []
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "tscn":
					var scene_path = dir_path + "/" + file_name
					if scene_has_combat_unit(scene_path):
						res_lst.append(scene_path)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return res_lst


## Check if a root node of a scene is a combat unit
## Otherwise the scene is ignored - returns false
func scene_has_combat_unit(scene_path) -> bool:
	var packed_scene = load(scene_path)
	var scene = packed_scene.instantiate()
	var children = scene.get_children()

	if scene is AcCombatUnit:
		return true
	
	return false


func load_combat_units():
	combat_units = []
	for path in path_combat_units:
		var lst: Array[Variant] = get_combat_unit_list(path)
		for item in lst:
			combat_units.append(item)

			var packed_scene = load(item)
			var scene = packed_scene.instantiate()
			if scene is AcCombatUnit:
				combat_unit_names.append(scene.base_name)
				combat_unit_instances.append(scene)


func get_combat_unit_paths() -> Array[String]:
	return combat_units


func get_combat_unit_names() -> Array[String]:
	return combat_unit_names


func get_combat_unit_by_name(name) -> AcCombatUnit:
	for unit in combat_unit_instances:
		if unit.base_name == name:
			return unit
	
	return null


func get_combat_units() -> Array[AcCombatUnit]:
	return combat_unit_instances


func get_combat_unit_by_id(id: int) -> AcCombatUnit:
	# Ensure id is within valid range
	if id >= 0 and id < combat_unit_instances.size():
		return combat_unit_instances[id]
	return null
