class_name AcWaveController
extends Node
## Class for controlling waves of enemies
## This class keeps info about passed waves
## And generates new waves according to known info


@export_group("General")
## Current wave index (starting from 1)
@export var wave_idx: int = 1
## How much waves are there in total
@export var wave_count: int = 10
## Maximum number of enemies that can be spawned at once
@export var max_enemies: int = 10

@export_group("Current wave")
@export var wave_type: AcTypes.WaveType = AcTypes.WaveType.DEFAULT
## How many time `combat` stage will last
## If enemies are not defeated in this time
## You can add some effects like losing health, penalties, etc.
@export var wave_duration: float = 60
## How many time `preparation` stage will last
@export var wave_wait_time: float = 20
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

var wave_template: Dictionary = {
	"name": "",
	"count": 0
}

var wave_generated_template: Dictionary = {
	"combat_unit": null, # AcCombatUnit
	"amount": 0
}


signal wctrl_wave_generated
signal wctrl_wave_ended


func get_current_wave() -> int:
	return wave_idx


func get_wave_count() -> int:
	return wave_count


func set_wave_count(count: int):
	wave_count = count


## Returns array of `wave_generated_template`s
## Each template contains info about combat unit node and amount to generate
func generate_wave(difficulty: AcTypes.WaveDifficulty) -> Array[Dictionary]:
	var cunits: Array[AcCombatUnit] = AcPctrl.get_combat_units()
	var chosen_cunits: Array[Variant] = []
	var generated_cunits: Array[Dictionary] = []
	var total_count: int = randi_range(1, max_enemies)

	# Choose combat units
	# That can be spawned in this wave
	for cunit in cunits:
		chosen_cunits.append(cunit)
	
	var i = 0
	while i < total_count:
		var possible_amount = total_count - i
		var amount = randi_range(0, possible_amount)
		var cunit: AcCombatUnit = chosen_cunits[randi() % chosen_cunits.size()]
		var generated_cunit: Dictionary = {
			"combat_unit": cunit,
			"amount": amount
		}
		generated_cunits.append(generated_cunit)
		i += amount

	wctrl_wave_generated.emit()
	
	return generated_cunits


func end_current_wave(goNext: bool = true):
	time_start = 0
	time_end = 0
	if goNext:
		wave_idx += 1
	
	wctrl_wave_ended.emit()


func update_time():
	time_start = game_controller.game_timer.get_time()
	time_end = time_start + wave_duration


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")

	#todo: fix unused method
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
