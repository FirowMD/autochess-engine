class_name AcCombatInterface
extends Node
## Combat Interface is a class that provides an opportunity to communicate with
## game as a player
## It contains and shows all the necessary information about the player's
## stats, units, resources, etc.


const NAME_UI: String = "UserInterface"
const NAME_DATA_CONTAINER: String = "DataContainer"
const NAME_COMBAT_SHOP: String = "CombatShop"
const NAME_COMBAT_COLLECTION: String = "CombatCollection"
const NAME_COMBAT_LOGGER: String = "CombatLogger"
const NAME_COMBAT_ESC: String = "CombatEsc"
const NAME_UNIT_SELECTION: String= "UnitSelection"
const NAME_LABEL_DEBUG: String = "LabelDebug"
const NAME_LABEL_TIMER: String = "LabelTimer"
const NAME_LABEL_WAVE: String = "LabelWave"


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
## The collection of units that the player has
@export var combat_collection: AcCombatCollection = null
## The logger that will show the debug information to player
@export var combat_logger: AcCombatLogger = null
## The escape menu, which will pause the game and show the menu
@export var combat_esc: AcCombatEsc = null
## Unit selection box
## It will draw around the selected unit
@export var unit_selection: Control = null
@export var show_fps: bool = false

@export_group("Advanced")
@export var game_controller: AcGameController = null
@export var label_debug: Label = null
@export var label_timer: Label = null
@export var label_wave: Label = null

signal cominterface_hidden
signal cominterface_shown


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")
	
	var children: Array[Node] = get_children()
	
	for child in children:
		if child.name == NAME_UI:
			user_interface = child
		elif child.name == NAME_DATA_CONTAINER:
			data_container = child
		elif child.name == NAME_COMBAT_SHOP:
			combat_shop = child	
		elif child.name == NAME_COMBAT_COLLECTION:
			combat_collection = child
		elif child.name == NAME_COMBAT_LOGGER:
			combat_logger = child
		elif child.name == NAME_COMBAT_ESC:
			combat_esc = child
		elif child.name == NAME_UNIT_SELECTION:
			unit_selection = child
		elif child.name == NAME_LABEL_DEBUG:
			label_debug = child
		elif child.name == NAME_LABEL_TIMER:
			label_timer = child
		elif child.name == NAME_LABEL_WAVE:
			label_wave = child


func check_setup() -> bool:
	if user_interface == null:
		push_error("user_interface not set")
		return false
	elif data_container == null:
		push_error("data_container not set")
		return false
	elif combat_shop == null:
		push_error("combat_shop not set")
		return false
	elif combat_collection == null:
		push_error("combat_collection not set")
		return false
	elif combat_logger == null:
		push_error("combat_logger not set")
		return false
	elif combat_esc == null:
		push_error("combat_esc not set")
		return false
	elif unit_selection == null:
		push_error("unit_selection not set")
		return false
	elif game_controller == null:
		push_error("game_controller not set")
		return false
	elif player == null:
		push_error("player not set")
		return false
	elif label_debug == null:
		push_error("label_debug not set")
		return false
	elif label_timer == null:
		push_error("label_timer not set")
		return false
	elif label_wave == null:
		push_error("label_wave not set")
		return false
	
	return true


func hide():
	user_interface.hide()
	cominterface_hidden.emit()


func show():
	user_interface.show()
	cominterface_shown.emit()


func hide_container():
	data_container.hide()


func show_container():
	data_container.show()


func store_data() -> Dictionary:
	var data: Dictionary = {
		"player_id": player.player_id,
		"player_name": player.player_name,
		"player_hp": player.player_hp,
		"player_exp": player.player_exp,
		"player_gold": player.player_gold,
		"player_score": player.player_score,
	}
	
	return data


func update_data_container():
	# Add labels to the data container
	var data: Dictionary = store_data()

	# Remove previous labels if they exist
	for child in data_container.get_children():
		data_container.remove_child(child)

	for key in data:
		var label: Label = Label.new()
		label.text = key + ": " + str(data[key])
		data_container.add_child(label)


func handler_com_hidden():
	show_container()
	combat_shop.btn_show.show()
	combat_collection.btn_show.show()
	combat_logger.btn_show.show()


func handler_comshop_shown():
	hide_container()
	combat_collection.btn_show.hide()
	combat_logger.btn_show.hide()


func handler_comcollection_shown():
	hide_container()
	combat_shop.btn_show.hide()
	combat_logger.btn_show.hide()


func handler_comlogger_shown():
	hide_container()
	combat_shop.btn_show.hide()
	combat_collection.btn_show.hide()


func setup_combat_shop():
	combat_shop.connect("ui_shown", handler_comshop_shown)
	combat_shop.connect("ui_hidden", handler_com_hidden)


func setup_combat_collection():
	combat_collection.connect("ui_shown", handler_comcollection_shown)
	combat_collection.connect("ui_hidden", handler_com_hidden)


func setup_combat_logger():
	combat_logger.connect("ui_shown", handler_comlogger_shown)
	combat_logger.connect("ui_hidden", handler_com_hidden)


func setup_unit_selection():
	var align_size: Vector2i = game_controller.game_map.get_tile_size()
	unit_selection.scale = Vector2(align_size) / unit_selection.get_size()

	var group_color: Color = player.player_group.get_group_color()
	unit_selection.modulate = group_color

	unit_selection.hide()


func setup_wave_controller():
	game_controller.wave_controller.connect("wctrl_wave_generated", handler_wctrl_wave_generated)


func setup_gametimer():
	game_controller.game_timer.connect("gametimer_updated", handler_gametimer_updated)


func show_unit_selection():
	unit_selection.show()


func hide_unit_selection():
	unit_selection.hide()


func set_unit_selection_color(color: Color):
	unit_selection.modulate = color


func set_unit_selection_pos(pos: Vector2):
	var align_size: Vector2i = game_controller.game_map.get_tile_size()
	unit_selection.set_position(pos - Vector2(align_size / 2))


func get_unit_selection_pos() -> Vector2:
	var align_size: Vector2i = game_controller.game_map.get_tile_size()
	return unit_selection.get_position() + Vector2(align_size / 2)


func handler_wctrl_wave_generated():
	if label_wave != null:
		var tmp_text = "Wave: {current}/{total}".format({
			"current": game_controller.wave_controller.get_current_wave(),
			"total": game_controller.wave_controller.get_wave_count()})

		label_wave.text = tmp_text


func handler_gametimer_updated():
	if label_timer != null:
		var tmp_text = "{time}".format({
			"time": game_controller.game_timer.get_pretty_time_string_minutes()})
		
		label_timer.text = tmp_text


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	setup_combat_shop()
	setup_combat_collection()
	setup_combat_logger()
	setup_unit_selection()
	setup_wave_controller()
	setup_gametimer()

	update_data_container()
	show_container()

func _process(delta):
	update_data_container()
	if show_fps:
		label_debug.text = "FPS: " + str(Engine.get_frames_per_second())
	else:
		label_debug.text = ""
