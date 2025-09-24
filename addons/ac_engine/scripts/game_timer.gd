class_name AcGameTimer
extends Node


const NAME_TIMER: String = "Timer"


@export var game_time_sec: int = 0
@export var timer: Timer = null

var alarm_list: Array = []


signal gametimer_updated


func setup_counting_up() -> void:
	timer.connect("timeout", update_time)
	timer.start()


func get_pretty_time_string() -> String:
	var hours = floor(game_time_sec / 3600.0)
	var minutes = floor((game_time_sec - hours * 3600) / 60.0)
	var seconds = game_time_sec - hours * 3600 - minutes * 60
	var time_string: String = "%02d:%02d:%02d" % [hours, minutes, seconds]

	return time_string


func get_pretty_time_string_minutes() -> String:
	var minutes = floor(game_time_sec / 60.0)
	var seconds = game_time_sec - minutes * 60
	var time_string: String = "%02d:%02d" % [minutes, seconds]

	return time_string


func get_time() -> int:
	return game_time_sec


func update_time() -> void:
	game_time_sec += 1

	for alarm in alarm_list:
		if alarm["time"] == game_time_sec:
			alarm["function"].call(alarm["object"], alarm["args"])
			alarm_list.erase(alarm)
	
	gametimer_updated.emit()


# Pass `foo` - function, and `time` - how many seconds to wait to call `foo`
func add_alarm_event(obj: Object, foo: Callable, wait_time: int, ...args: Array) -> void:
	var alarm: Dictionary = Dictionary()
	alarm["object"] = obj
	alarm["function"] = foo
	alarm["time"] = wait_time + game_time_sec
	alarm["args"] = args
	alarm_list.append(alarm)


func _ready() -> void:
	setup_references()
	setup_timer()
	setup_signals()
	initialize_state()


func setup_references() -> void:
	setup_child_nodes()


func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_TIMER: "timer"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)


func setup_timer() -> void:
	if not check_setup():
		push_error("setup is not complete")
		return


func setup_signals() -> void:
	timer.connect("timeout", update_time)
	timer.start()


func initialize_state() -> void:
	game_time_sec = 0


func check_setup() -> bool:
	if timer == null:
		push_error("timer is not set")
		return false
	
	return true
