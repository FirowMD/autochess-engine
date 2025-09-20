class_name AcWaveController
extends Node
## Class for controlling waves of enemies
## This class keeps info about passed waves
## And generates new waves according to known info

@export_group("General")
## Current wave index (starting from 1)
@export var wave_idx: int = 1
## You have to add waves manually. They will appear in specified order
@export var waves: Array[PackedScene]

@export_group("Advanced")
@export var game_controller: AcGameController = null

var current_wave: AcWave = null

signal wctrl_wave_generated(enemies)
signal wctrl_wave_ended(is_victory)
signal wctrl_state_changed(state)


func _ready() -> void:
	setup_references()


func setup_references() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return
	game_controller = AcPctrl.get_game_controller(get_tree())




func get_current_wave() -> int:
	return wave_idx


func get_wave_count() -> int:
	return waves.size()


func start_wave() -> void:
	if current_wave != null and current_wave.is_active:
		return
	
	if wave_idx > waves.size():
		push_error("no more waves")
		return
	
	current_wave = waves[wave_idx - 1].instantiate()
	add_child(current_wave)
	
	current_wave.wave_completed.connect(handler_wave_completed)
	current_wave.wave_failed.connect(handler_wave_failed)
	current_wave.wave_state_changed.connect(handler_wave_state_changed)
	
	current_wave.start()
	wctrl_wave_generated.emit(current_wave.get_spawn_data())


func end_wave(is_victory: bool) -> void:
	if current_wave == null:
		return
	current_wave.end(false)
	wctrl_wave_ended.emit(is_victory)


func handler_wave_completed() -> void:
	if current_wave == null:
		return
	print("WaveController: Wave completed! Moving from wave ", wave_idx, " to wave ", wave_idx + 1)
	wave_idx += 1
	current_wave = null
	wctrl_wave_ended.emit(true)


func handler_wave_failed() -> void:
	if current_wave == null:
		return
	wave_idx += 1
	current_wave = null
	wctrl_wave_ended.emit(false)


func handler_wave_state_changed(state) -> void:
	wctrl_state_changed.emit(state)
