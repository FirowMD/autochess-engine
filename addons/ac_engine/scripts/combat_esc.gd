class_name AcCombatEsc
extends Node
## Class that represents the escape menu


const NAME_UI: String = "UserInterface"
const NAME_BTN_ESC: String = "BtnEsc"
const NAME_BTN_RESUME: String = "BtnResume"
const NAME_BTN_EXIT: String = "BtnExit"
const NAME_CONTAINER: String = "Container"


@export_group("General")
## The main panel which represents the escape menu
## It will show and hide by the buttons: resume and exit
@export var user_interface: CanvasItem = null
## The button which will be active during the game
## When it's pressed, the escape menu will appear
@export var btn_esc: Button = null
## The button which will resume the game
@export var btn_resume: Button = null
## The button which will exit the game
@export var btn_exit: Button = null
## New buttons which you want to add to the escape menu
## Should be placed inside this container
@export var container: Container = null
## Auto setup for z index (set as `100`)
@export var auto_z_index: bool = true

@export_group("Advanced")
@export var game_controller: AcGameController = null


func _ready() -> void:
	setup_references()
	setup_escape_menu()
	setup_signals()
	initialize_state()

func setup_references() -> void:
	setup_controllers()
	setup_child_nodes()

func setup_controllers() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return
	
	game_controller = AcPctrl.get_game_controller(get_tree())

func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_UI: "user_interface",
		NAME_BTN_ESC: "btn_esc",
		NAME_BTN_RESUME: "btn_resume",
		NAME_BTN_EXIT: "btn_exit",
		NAME_CONTAINER: "container"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)

func setup_escape_menu() -> void:
	if not check_setup():
		push_error("setup is not complete")
	
	if auto_z_index:
		change_z_index_if_need()

func setup_signals() -> void:
	btn_esc.connect("button_down", btn_esc_down)
	btn_resume.connect("button_down", btn_resume_down)
	btn_exit.connect("button_down", btn_exit_down)

func initialize_state() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	init_visibility()


func check_setup() -> bool:
	if game_controller == null:
		push_error("game_controller not set")
		return false
	elif user_interface == null:
		push_error("user_interface not set")
		return false
	elif btn_esc == null:
		push_error("btn_esc not set")
		return false
	elif btn_resume == null:
		push_error("btn_resume not set")
		return false
	elif btn_exit == null:
		push_error("btn_exit not set")
		return false
	elif container == null:
		push_error("container not set")
		return false

	return true


func btn_esc_down():
	switch_visibility()


func btn_resume_down():
	switch_visibility()


func btn_exit_down():
	get_tree().quit()


func switch_visibility():
	user_interface.set_visible(not user_interface.is_visible())
	btn_esc.set_visible(not btn_esc.is_visible())

	if user_interface.is_visible():
		get_tree().paused = true
	else:
		get_tree().paused = false


func init_visibility():
	user_interface.set_visible(false)
	btn_esc.set_visible(true)


func change_z_index_if_need():
	if auto_z_index:
		user_interface.set_z_index(100)


func _input(event):
	if event.is_action_released("app_cancel"):
		switch_visibility()
