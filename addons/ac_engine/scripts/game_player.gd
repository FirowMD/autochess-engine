class_name AcGamePlayer
extends Node
## Class which represents the player in the game
## It contains the player's name, id, hp, exp, gold, and score.
## (!) All interacts should be done through setters and getters


@export_group("General")
@export var player_name: String = "player_name"
@export var player_id: int = -1
@export var player_group: AcGameGroup = null

@export_group("Game Data")
@export var player_hp: int = 1
@export var player_exp: int = 0
@export var player_gold: int = 100
@export var player_score: int = 0

@export_group("Player shop")
## If you want to load available shop items from tscn files automatically
## You can specify directories where to find them
@export var path_shop_items: Array[String] = [
	"res://addons/ac_engine/test_project/combat_units"
]


signal gameplayer_out_of_units
signal gameplayer_out_of_hp
signal gameplayer_unit_count_changed
signal gameplayer_hp_changed
signal gameplayer_exp_changed
signal gameplayer_gold_changed
signal gameplayer_score_changed
signal gameplayer_name_changed


var unit_count = 0
var shop_items = []


func get_player_id():
	return player_id


func get_player_name():
	return player_name


func get_player_hp():
	return player_hp


func get_player_exp():
	return player_exp


func get_player_gold():
	return player_gold


func get_player_score():
	return player_score


func get_unit_count():
	return unit_count


func get_shop_items():
	return shop_items


func set_player_name(name: String):
	player_name = name
	gameplayer_name_changed.emit()


func set_player_hp(hp: int):
	player_hp = hp
	gameplayer_hp_changed.emit()


func set_player_exp(exp: int):
	player_exp = exp
	gameplayer_exp_changed.emit()


func set_player_gold(gold: int):
	player_gold = gold
	gameplayer_gold_changed.emit()


func set_player_score(score: int):
	player_score = score
	gameplayer_score_changed.emit()


func set_unit_count(count: int):
	unit_count = count
	gameplayer_unit_count_changed.emit()


func setup_shop(paths: Array[String]):
	shop_items = []
	for path in path_shop_items:
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.get_extension() == "tscn":
						var scene_path = path + "/" + file_name
						if AcPctrl.scene_has_combat_unit(scene_path):
							var unit = load(scene_path)
							shop_items.append(unit)
				file_name = dir.get_next()
			
			dir.list_dir_end()


func _ready():
	setup_shop(path_shop_items)
