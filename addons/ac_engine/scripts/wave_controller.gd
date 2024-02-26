class_name AcWaveController
extends Node
## Class for controlling waves of enemies
## 


@export_group("General")
## Current wave index (starting from 1)
@export var wave_idx: int = 1
## How much waves are there in total
@export var wave_count: int = 10

@export_group("Current wave")
@export var wave_type: AcTypes.WaveType = AcTypes.WaveType.DEFAULT
@export var wave_duration: float = 60
## This number will affect on how many enemies will spawn
## And how strong they will be
@export var wave_difficulty: AcTypes.WaveDifficulty = AcTypes.WaveDifficulty.EASY
@export var wave_reward: int = 5
@export var wave_enemy_reward: int = 1

@export_group("Basic properties")
@export var wave_base_duration: float = 60
## This number will affect on how many enemies will spawn
## And how strong they will be
@export var wave_base_difficulty: int = 1
@export var wave_base_reward: int = 5
@export var wave_base_enemy_reward: int = 1

@export_group("Advanced")
@export var game_controller: AcGameController = null
@export var group_neutral: AcGameGroup = null

var time_start: int = 0
var time_end: int = 0


func get_current_wave() -> int:
	return wave_idx


## Returns dictionary of combat units and their count
## Example: {"combat_unit_A": 5, "combat_unit_B": 3}
func generate_wave(difficulty: AcTypes.WaveDifficulty) -> Array[Variant]:
	var cunits: Array[String] = AcPctrl.get_combat_unit_list_all()
	var chosen_cunits: Array[Variant] = []
	var generated_cunits: Array[Variant] = []
	var max_amount_per_unit: int = 5

	for cunit in cunits:
		if cunit.difficulty == difficulty:
			chosen_cunits.append(cunit)
	
	for cunit in chosen_cunits:
		var num: int = randi() % max_amount_per_unit
		generated_cunits.append({cunit: num})
	
	return generated_cunits


func update_time():
	time_start = game_controller.game_timer.get_time()
	time_end = time_start + wave_duration


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")
	
	var game_groups: Array[Variant] = game_controller.group_manager.get_groups_by_type(
		AcTypes.GameGroupType.NEUTRAL)


func check_setup() -> bool:
	if game_controller == null:
		push_error("game_controller is not set")
		return false
	
	return true


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
