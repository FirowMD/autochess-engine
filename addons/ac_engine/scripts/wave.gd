class_name AcWave
extends Node2D

@export_group("General")
## Wave identifier
@export var wave_id: int = 0
## Wave name for display
@export var wave_name: String = "Wave"
## Wave type (normal, boss, etc)
@export var wave_type: AcTypes.WaveType = AcTypes.WaveType.DEFAULT
## Wave difficulty
@export var difficulty: AcTypes.WaveDifficulty = AcTypes.WaveDifficulty.EASY
## Duration in seconds
@export var duration: float = 60.0
## Preparation time before wave
@export var prep_time: float = 20.0
## Base reward for completing the wave
@export var base_reward: int = 5
## Reward per enemy defeated
@export var enemy_reward: int = 1
## Choose current wave state. If set to "combat", the wave will start immediately
@export_enum("combat", "preparation") var wave_state: String = "preparation":
	set(new_value):
		wave_state = new_value
		wave_state_changed.emit(new_value)
	get:
		return wave_state

@export_group("Enemy Spawning")
## Maximum enemies that can be spawned
@export var max_enemies: int = 10
## Enemies that will be spawned
@export var spawn_data: Array[AcCombatUnit] = []

@export_group("Advanced")
@export var game_controller: AcGameController = null

# Wave state management
var is_active: bool = false
var time_remaining: float = 0.0
var enemies_spawned: int = 0
var enemies_defeated: int = 0

signal wave_started
signal wave_completed
signal wave_state_changed(state: String)
signal wave_failed
signal wave_enemy_defeated

func _ready() -> void:
	if not is_inside_tree():
		return
	game_controller = AcPctrl.get_game_controller(get_tree())


func autofill_spawn_data() -> void:
	# Take child nodes
	var children = get_children()
	var spawn_data = []
	for child in children:
		if child.is_class("AcCombatUnit"):
			spawn_data.push(child)


func start() -> void:
	is_active = true
	time_remaining = duration
	enemies_spawned = 0
	enemies_defeated = 0
	wave_started.emit()
	wave_state_changed.emit(wave_state)

func end(completed: bool = true) -> void:
	is_active = false
	if completed:
		wave_completed.emit()
	else:
		wave_failed.emit()

func get_spawn_data() -> Array[AcCombatUnit]:
	return spawn_data

func add_enemy_defeated() -> void:
	enemies_defeated += 1
	wave_enemy_defeated.emit()
	
	if enemies_defeated >= enemies_spawned:
		end(true)
