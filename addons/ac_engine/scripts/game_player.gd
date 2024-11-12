class_name AcGamePlayer
extends Node
## Class which represents the player in the game
## It contains the player's name, id, hp, exp, gold, and score.
## (!) All interacts should be done through setters and getters


@export_group("General")
@export var player_name: String = "player_name":
	set(new_value):
		player_name = new_value
		gameplayer_name_changed.emit()
	get:
		return player_name

@export var player_id: int = -1
@export var player_group: AcGameGroup = null

@export_group("Game Data")
@export var player_hp: int = 1:
	set(new_value):
		player_hp = new_value
		gameplayer_hp_changed.emit()
	get:
		return player_hp

@export var player_exp: int = 0:
	set(new_value):
		player_exp = new_value
		gameplayer_exp_changed.emit()
	get:
		return player_exp

@export var player_gold: int = 100:
	set(new_value):
		player_gold = new_value
		gameplayer_gold_changed.emit()
	get:
		return player_gold

@export var player_score: int = 0:
	set(new_value):
		player_score = new_value
		gameplayer_score_changed.emit()
	get:
		return player_score

@export_group("Player shop")
@export var current_shop_items: Array[Node] = []

@export_group("Player collection")
@export var current_collection_items: Array[Node] = []

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
signal gameplayer_shop_items_changed(items: Array[Node])
signal gameplayer_shop_items_bought(item: Array[Node])
signal gameplayer_collection_items_changed(items: Array[Node])


var unit_count: int = 0:
	set(new_value):
		unit_count = new_value
		if unit_count == 0:
			gameplayer_out_of_units.emit()
		gameplayer_unit_count_changed.emit()
	get:
		return unit_count
	
## All available shop items
var shop_items: Array[Node] = []
var previous_shop_items: Array[Node] = []
var previous_collection_items: Array[Node] = []


func _ready() -> void:
	setup_references()
	setup_player()
	
	if not check_setup():
		push_error("Game player setup failed")
		return

func setup_references() -> void:
	setup_controllers()

func setup_controllers() -> void:
	if not is_inside_tree():
		push_error("Cannot setup game player: Node is not inside scene tree")
		return
	
	game_controller = AcPctrl.get_game_controller(get_tree())
	if game_controller == null:
		push_error("Cannot setup game player: Failed to get game controller")

func setup_player() -> void:
	setup_shop_items()

## Default system for shop items
## It will fill the shop with all available items (1 piece of each kind)
func setup_shop_items():
	shop_items = AcTypes.scnpaths_to_scnnodes(AcPctrl.get_combat_unit_paths())
	set_shop_items(shop_items)

func check_setup() -> bool:
	if game_controller == null:
		push_error("game_controller not set")
		return false
	
	return true

## Generate random shop items (took from the shop_items array)
## count - how many items to generate
func set_random_shop_items(count: int):
	var items: Array[Node] = []
	for i in range(count):
		var index: int = randi() % shop_items.size()
		items.append(shop_items[index])
	
	set_shop_items(items)

func set_shop_items(items: Array[Node]):
	previous_shop_items = current_shop_items
	current_shop_items = items
	gameplayer_shop_items_changed.emit(items)

func set_collection_items(items: Array[Node]):
	previous_collection_items = current_collection_items
	current_collection_items = items
	gameplayer_collection_items_changed.emit(items)

func find_shop_item(item_id: int) -> Node:
	for item in current_shop_items:
		if item.item_id == item_id:
			return item
	
	return null

func buy_shop_item(item_id: int) -> void:
	var found_item = find_shop_item(item_id)
	if found_item == null:
		push_error("item not found")
		return

	if player_gold < found_item.base_cost:
		return
	
	player_gold -= found_item.base_cost
	current_collection_items.append(found_item)
	set_collection_items(current_collection_items)
	gameplayer_shop_items_bought.emit(found_item)
