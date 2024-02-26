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


const NAME_PLAYER_MANAGER = "PlayerManager"
const NAME_GROUP_MANAGER = "GroupManager"
const NAME_GAME_TIMER = "GameTimer"
const NAME_COMBAT_MAP = "CombatMap"
const NAME_COMBAT_INTERFACE = "CombatInterface"


@export_group("General")
@export var game_wave: int = 1
@export_enum("combat", "preparation") var game_state: String = "preparation"

@export_group("Player settings")
## Currently active player
@export var player_id: AcGamePlayer = null

@export_group("Advanced")
@export var game_timer: AcGameTimer = null
@export var game_map: AcCombatMap = null
@export var group_manager: AcGroupManager = null
@export var player_manager: AcPlayerManager = null
@export var combat_interface: AcCombatInterface = null


# var combat_unit: AcCombatUnit = load("res://scenes/combat_units/combat_unit.tscn").instantiate()
var combat_unit: AcCombatUnit = load("res://addons/ac_engine/nodes/combat_unit.tscn").instantiate()
var selected_unit: AcCombatUnit = null


func create_unit(unit: AcCombatUnit, group: AcGameGroup, pos: Vector2, player: AcGamePlayer):
	var unit_instance = unit.instantiate()
	unit_instance.position = pos
	unit_instance.player = player
	unit_instance.group = group
	unit_instance.unit_pos = pos
	add_child(unit_instance)
	unit_instance.add_to_group(group.group_name)

	player.set_unit_count(player.get_unit_count() + 1)

	return unit_instance


func create_unit_serialized(this, args) -> void:
	return create_unit(args[0], args[1], args[2], args[3])


func get_enemy_groups(your_group) -> Array:
	return group_manager.get_enemy_groups(your_group)


func get_selected_unit() -> AcCombatUnit:
	return selected_unit


func set_selected_unit(unit_id: AcCombatUnit) -> void:
	selected_unit = unit_id
	print("Chosen unit: ", selected_unit)


func get_current_time() -> String:
	return game_timer.get_pretty_time_string()


func unset_selected_unit() -> void:
	selected_unit = null
	print("Unset chosen unit")


func auto_setup() -> void:
	var children = get_children()
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
	
	return true


func set_game_state(state: String) -> void:
	game_state = state


func get_game_state() -> String:
	return game_state


func print_log(text: String, color: Color = Color(1, 1, 1)) -> void:
	if color == Color(1, 1, 1):
		combat_interface.combat_logger.print_log(text)
	else:
		combat_interface.combat_logger.print_log_ext(text, color)


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	
	# Create 1 player unit using timer `add_alarm_event` method
	var player_1 = player_manager.get_player_by_id(0)
	var player_2 = player_manager.get_player_by_id(1)
	var allies = group_manager.get_groups_by_type(2)
	var enemies = group_manager.get_groups_by_type(1)
	var group_player = allies[0]
	var group_enemy = enemies[0]

	# game_timer.add_alarm_event(self, create_unit_serialized, 1, [combat_unit, group_player, Vector2(1, 0), player_1])
	# game_timer.add_alarm_event(self, create_unit_serialized, 2, [combat_unit, group_enemy, Vector2(6, 6), player_2])

	create_unit_serialized(self, [combat_unit, group_player, Vector2(1, 0), player_1])
	create_unit_serialized(self, [combat_unit, group_enemy, Vector2(6, 6), player_2])

	# var all_comunits = AcPctrl.get_combat_unit_list_all()
	# print(all_comunits)

	game_timer.add_alarm_event(self, generate_units, 2, [])
	

#! Test function
func generate_units(this, args) -> void:
	var count = 2
	for i in range(count):
		var player = player_manager.get_player_by_id(0)
		var group = group_manager.get_groups_by_type(2)[0]
		var pos = game_map.get_random_free_place()

		if pos != Vector2i(-1, -1):
			print("Spawn player unit at: ", pos)
			create_unit(combat_unit, group, pos, player)
	
	for i in range(count):
		var player = player_manager.get_player_by_id(1)
		var group = group_manager.get_groups_by_type(1)[0]
		var pos = game_map.get_random_free_place()

		if pos != Vector2i(-1, -1):
			print("Spawn enemy unit at: ", pos)
			create_unit(combat_unit, group, pos, player)
	

	game_timer.add_alarm_event(self, generate_units, 2, [])
