class_name AcCombatEsc
extends Control
## Class that represents the escape menu


const NAME_UI = "UserInterface"
const NAME_BTN_ESC = "BtnEsc"
const NAME_BTN_RESUME = "BtnResume"
const NAME_BTN_EXIT = "BtnExit"
const NAME_CONTAINER = "Container"


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
@export var container: CanvasItem = null

@export_group("Advanced")
@export var game_controller: AcGameController = null


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
	else:
		push_error("not inside tree")
	
	var child_nodes = get_children()

	for node in child_nodes:
		if node.name == NAME_UI:
			user_interface = node
		if node.name == NAME_BTN_ESC:
			btn_esc = node
		elif node.name == NAME_BTN_RESUME:
			btn_resume = node
		elif node.name == NAME_BTN_EXIT:
			btn_exit = node
		elif node.name == NAME_CONTAINER:
			container = node


func check_setup():
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


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	set_position(Vector2(0, 0))
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	init_visibility()

	btn_esc.connect("button_down", btn_esc_down)
	btn_resume.connect("button_down", btn_resume_down)
	btn_exit.connect("button_down", btn_exit_down)
