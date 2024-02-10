extends Node
## A singleton node that stores persistent data and functions.
## This node is used to store data that needs to be accessed from multiple scenes.


const NAME_GAME_CONTROLLER = "GameController"


@export_group("Project paths")
## The path to the directory containing combat unit scenes
@export var path_combat_units: Array[String] = [ "res://scenes/combat_units"]


var combat_units: Array[String] = []


# Called when the node enters the scene tree for the first time
func _ready():
	print("Persistent controller initializing...")
	load_combat_units()
	print("Combat units loaded: ", combat_units)


func get_game_controller(scn_tree):
	return scn_tree.get_root().get_node(NAME_GAME_CONTROLLER)


func get_scene_list(scr_dir):
	var res_lst = []
	var dir = DirAccess.open(scr_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "tscn":
					res_lst.append(file_name)
			file_name = dir.get_next()
	
	return res_lst


func get_combat_unit_list(dir_path):
	var res_lst = []
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "tscn":
					var scene_path = dir_path + "/" + file_name
					if scene_has_combat_unit(scene_path):
						res_lst.append(file_name)
			file_name = dir.get_next()
	
	return res_lst


## Check if a root node of a scene is a combat unit
## Otherwise the scene is ignored - returns false
func scene_has_combat_unit(scene_path):
	var packed_scene = load(scene_path)
	var scene = packed_scene.instantiate()
	var children = scene.get_children()

	if scene is AcCombatUnit:
		return true
	
	return false


func load_combat_units():
	combat_units = []
	for path in path_combat_units:
		var lst = get_combat_unit_list(path)
		for item in lst:
			combat_units.append(item)


func get_combat_unit_list_all():
	return combat_units