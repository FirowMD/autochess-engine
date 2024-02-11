class_name AcCombatInterface
extends Node
## Combat Interface is a class that provides an opportunity to communicate with
## game as a player
## It contains and shows all the necessary information about the player's
## stats, units, resources, etc.


const NAME_UI = "UserInterface"
const NAME_DATA_CONTAINER = "DataContainer"
const NAME_COMBAT_SHOP = "CombatShop"

@export_group("General")
## The player to whom the combat interface belongs
@export var player: AcGamePlayer = null
## The main panel which represents the combat interface
## It includes DataContainer and CombatShop
## So it's a parent for all the other UI elements of the combat interface
@export var user_interface: CanvasItem = null
## Container where all the player data is placed
@export var data_container: Container = null
## The shop where the player can buy units and upgrades
@export var combat_shop: AcCombatShop = null

@export_group("Advanced")
@export var game_controller: AcGameController = null


signal cominterface_hidden
signal cominterface_shown
signal cominterface_hidden_interface
signal cominterface_shown_interface
signal cominterface_hidden_shop
signal cominterface_shown_shop


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")
	
	var children = get_children()
	
	for child in children:
		if child.name == NAME_UI:
			user_interface = child
		elif child.name == NAME_DATA_CONTAINER:
			data_container = child
		elif child.name == NAME_COMBAT_SHOP:
			combat_shop = child		


func check_setup():
	if user_interface == null:
		push_error("user_interface not set")
		return false
	elif data_container == null:
		push_error("data_container not set")
		return false
	elif combat_shop == null:
		push_error("combat_shop not set")
		return false
	elif game_controller == null:
		push_error("game_controller not set")
		return false
	elif player == null:
		push_error("player not set")
		return false
	
	return true


func hide():
	if user_interface == null:
		return
	
	user_interface.hide()
	cominterface_hidden.emit()


func show():
	if user_interface == null:
		return
	
	user_interface.show()
	cominterface_shown.emit()


func hide_container():
	if data_container == null:
		return
	
	data_container.hide()
	cominterface_hidden_interface.emit()


func show_container():
	if data_container == null:
		return
	
	data_container.show()
	cominterface_shown_interface.emit()


func hide_shop():
	if combat_shop == null:
		return
	
	combat_shop.hide()
	cominterface_hidden_shop.emit()


func show_shop():
	if combat_shop == null:
		return
	
	combat_shop.show()
	cominterface_shown_shop.emit()


func store_data():
	var data = {
		"player_id": player.get_player_id(),
		"player_name": player.get_player_name(),
		"player_hp": player.get_player_hp(),
		"player_exp": player.get_player_exp(),
		"player_gold": player.get_player_gold(),
		"player_score": player.get_player_score()
	}
	
	return data


func show_data():
	# Add labels to the data container
	var data = store_data()

	for key in data:
		var label = Label.new()
		label.text = key + ": " + str(data[key])
		data_container.add_child(label)


func handler_cominterface_hidden_shop():
	show_container()


func handler_cominterface_shown_shop():
	hide_container()


func handler_comshop_hidden():
	show_container()


func handler_comshop_shown():
	hide_container()


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	show_data()

	connect("cominterface_hidden_shop", handler_cominterface_hidden_shop)
	connect("cominterface_shown_shop", handler_cominterface_shown_shop)

	if combat_shop != null:
		combat_shop.connect("comshop_hidden", handler_comshop_hidden)
		combat_shop.connect("comshop_shown", handler_comshop_shown)
