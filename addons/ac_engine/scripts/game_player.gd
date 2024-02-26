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
@export var shop_item_count: int = 4

@export_group("Advanced")
@export var game_controller: AcGameController = null


signal gameplayer_out_of_units
signal gameplayer_out_of_hp
signal gameplayer_unit_count_changed
signal gameplayer_hp_changed
signal gameplayer_exp_changed
signal gameplayer_gold_changed
signal gameplayer_score_changed
signal gameplayer_name_changed
signal gameplayer_shop_items_changed(items: Array[String])


var unit_count: int = 0
## All available shop items
var shop_items: Array[String] = []
## Currently presented shop items
var current_shop_items: Array[String] = []
var previous_shop_items: Array[String] = []


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")


func check_setup() -> bool:
	if game_controller == null:
		push_error("game_controller not set")
		return false
	
	return true


func get_player_id() -> int:
	return player_id


func get_player_name() -> String:
	return player_name


func get_player_hp() -> int:
	return player_hp


func get_player_exp() -> int:
	return player_exp


func get_player_gold() -> int:
	return player_gold


func get_player_score() -> int:
	return player_score


func get_unit_count() -> int:
	return unit_count


func get_shop_items() -> Array[String]:
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


## Default system for shop items
## It will fill the shop with all available items (1 piece of each kind)
func setup_shop_items():
	shop_items = AcPctrl.get_combat_unit_list_all().duplicate()
	set_shop_items(shop_items)


## Generate random shop items (took from the shop_items array)
## count - how many items to generate
func set_random_shop_items(count: int):
	var items: Array[Variant] = []
	for i in range(count):
		var index: int = randi() % shop_items.size()
		items.append(shop_items[index])
	
	set_shop_items(items)


func set_shop_items(items: Array[String]):
	previous_shop_items = current_shop_items
	current_shop_items = items
	gameplayer_shop_items_changed.emit(items)


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	setup_shop_items()
