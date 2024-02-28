class_name AcGameController
extends Node
## Class for controlling the game state and game flow
## Game controller has access to all main objects such as:
## - PlayerManager
## - GroupManager
## - GameTimer
## - CombatMap
## Game controller is responsible for:
## - Creating units
## - Managing game state
## - Managing waves via WaveController
## - Managing game groups via GroupManager
## - Managing players via PlayerManager
## - Managing game timer via GameTimer
## - Managing game map via CombatMap
## - Managing all other in-game (combat) settings


const NAME_PLAYER_MANAGER: String = "PlayerManager"
const NAME_GROUP_MANAGER: String = "GroupManager"
const NAME_GAME_TIMER: String = "GameTimer"
const NAME_COMBAT_MAP: String = "CombatMap"
const NAME_COMBAT_INTERFACE: String = "CombatInterface"
const NAME_WAVE_CONTROLLER: String = "WaveController"


@export_group("General")
@export var game_wave: int = 1
@export_enum("combat", "preparation") var game_state: String = "preparation":
	set(new_value):
		game_state = new_value
		if combat_interface != null:
			print_log("Game state changed", Color(0, 1, 0))
		gctrl_game_state_changed.emit()
	get:
		return game_state

@export_group("Player settings")
## Currently active player
@export var player_id: AcGamePlayer = null

@export_group("Advanced")
@export var game_timer: AcGameTimer = null
@export var game_map: AcCombatMap = null
@export var group_manager: AcGroupManager = null
@export var player_manager: AcPlayerManager = null
@export var combat_interface: AcCombatInterface = null
@export var wave_controller: AcWaveController = null


signal gctrl_game_state_changed


# var combat_unit: AcCombatUnit = load("res://scenes/combat_units/combat_unit.tscn").instantiate()
var combat_unit: AcCombatUnit = load("res://addons/ac_engine/nodes/combat_unit.tscn").instantiate()
var selected_unit: AcCombatUnit = null:
	set(new_value):
		selected_unit = new_value
		print("Selected: ", selected_unit)
	get:
		return selected_unit

## Amount of units in the game
var unit_count: int = 0


func create_unit(unit: AcCombatUnit, group: AcGameGroup, pos: Vector2, player: AcGamePlayer) -> Variant:
	var unit_instance = unit.instantiate()
	unit_instance.position = pos
	unit_instance.player = player
	unit_instance.group = group
	unit_instance.unit_pos = pos
	add_child(unit_instance)
	unit_instance.add_to_group(group.group_name)

	return unit_instance


# todo: fix unused parameter [this]
func create_unit_serialized(this, args) -> Variant:
	return create_unit(args[0], args[1], args[2], args[3])


func get_enemy_groups(your_group) -> Array:
	return group_manager.get_enemy_groups(your_group)


func get_current_time() -> String:
	return game_timer.get_pretty_time_string()


func unset_selected_unit() -> void:
	selected_unit = null
	print("Unset chosen unit")


func auto_setup() -> void:
	var children: Array[Node] = get_children()
	for child in children:
		if child.name == NAME_GAME_TIMER:
			game_timer = child
		elif child.name == NAME_COMBAT_MAP:
			game_map = child
		elif child.name == NAME_GROUP_MANAGER:
			group_manager = child
		elif child.name == NAME_PLAYER_MANAGER:
			player_manager = child
		elif child.name == NAME_COMBAT_INTERFACE:
			combat_interface = child
		elif child.name == NAME_WAVE_CONTROLLER:
			wave_controller = child


func check_setup() -> bool:
	if game_timer == null:
		push_error("game_timer is not set")
		return false
	if game_map == null:
		push_error("game_map is not set")
		return false
	if group_manager == null:
		push_error("group_manager is not set")
		return false
	if player_manager == null:
		push_error("player_manager is not set")
		return false
	if combat_interface == null:
		push_error("combat_interface is not set")
		return false
	elif wave_controller == null:
		push_error("wave_controller is not set")
		return false
	
	return true


func print_log(text: String, color: Color = Color(1, 1, 1)) -> void:
	if color == Color(1, 1, 1):
		combat_interface.combat_logger.print_log(text)
	else:
		combat_interface.combat_logger.print_log_ext(text, color)


func wave_start() -> void:
	var enemies = wave_controller.generate_wave(game_wave)
	print("Wave start:\n", JSON.stringify(enemies))
	for enemy in enemies:
		for i in range(enemy["amount"]):
			var player = player_manager.get_player_by_id(1)
			var group = group_manager.get_groups_by_type(1)[0]
			var pos: Vector2i = game_map.get_random_free_place()

			if pos != Vector2i(-1, -1):
				print("Spawn enemy unit at: ", pos)
				create_unit(enemy["combat_unit"], group, pos, player)


func handler_gameplayer_out_of_units_winner():
	wave_controller.end_current_wave(true)
	game_state = "preparation"


func handler_gameplayer_out_of_units_loser():
	wave_controller.end_current_wave(false)
	game_state = "preparation"


func setup_players() -> void:
	var player_1 = player_manager.get_player_by_id(0)
	var player_2 = player_manager.get_player_by_id(1)

	player_1.connect("gameplayer_out_of_units", handler_gameplayer_out_of_units_winner)
	player_2.connect("gameplayer_out_of_units", handler_gameplayer_out_of_units_loser)


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	setup_players()
	
	# Create 1 player unit using timer `add_alarm_event` method
	var player_1 = player_manager.get_player_by_id(0)
	var player_2 = player_manager.get_player_by_id(1)
	var allies = group_manager.get_groups_by_type(2)
	var enemies = group_manager.get_groups_by_type(1)
	var group_player = allies[0]
	var group_enemy = enemies[0]

	# game_timer.add_alarm_event(self, create_unit_serialized, 1, [combat_unit, group_player, Vector2(1, 0), player_1])
	# game_timer.add_alarm_event(self, create_unit_serialized, 2, [combat_unit, group_enemy, Vector2(6, 6), player_2])

	create_unit_serialized(self, [combat_unit, group_player, Vector2(2, 2), player_1])
	# create_unit_serialized(self, [combat_unit, group_enemy, Vector2(6, 6), player_2])

	# var all_comunits = AcPctrl.get_combat_unit_paths()
	# print(all_comunits)

	# game_timer.add_alarm_event(self, generate_units, 2, [])
	
	wave_start()
	

#! Test function
# todo: fix unused parameter [this, args]
func generate_units(this, args) -> void:
	var count: int = 2
	for i in range(count):
		var player: AcGamePlayer = player_manager.get_player_by_id(0)
		var group = group_manager.get_groups_by_type(2)[0]
		var pos: Vector2i = game_map.get_random_free_place()

		if pos != Vector2i(-1, -1):
			print("Spawn player unit at: ", pos)
			create_unit(combat_unit, group, pos, player)
	
	for i in range(count):
		var player: AcGamePlayer = player_manager.get_player_by_id(1)
		var group = group_manager.get_groups_by_type(1)[0]
		var pos: Vector2i = game_map.get_random_free_place()

		if pos != Vector2i(-1, -1):
			print("Spawn enemy unit at: ", pos)
			create_unit(combat_unit, group, pos, player)
	

	game_timer.add_alarm_event(self, generate_units, 2, [])
