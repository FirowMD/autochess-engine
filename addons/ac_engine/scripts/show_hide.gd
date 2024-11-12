class_name AcShowHide
extends Node


const NAME_UI: String = "UserInterface"
const NAME_BTN_SHOW: String = "BtnShow"
const NAME_BTN_HIDE: String = "BtnHide"
const NAME_CONTAINER: String = "Container"


@export_group("General")
## Main panel which will be shown and hidden
@export var user_interface: CanvasItem = null
## The button which will show main panel
@export var btn_show: Button = null
## The button which will hide main panel
@export var btn_hide: Button = null
## Container for internal elements
@export var container: Container = null

@export_group("Advanced")
@export var game_controller: AcGameController = null
@export var combat_interface: AcCombatInterface = null


signal ui_shown
signal ui_hidden


func _ready() -> void:
	ac_show_hide_ready()

func ac_show_hide_ready() -> void:
	setup_references()
	
	if not _validate_setup():
		push_error("Setup validation failed")
		return
	
	setup_interface()
	setup_signals()
	initialize_state()

# Virtual method for child classes to implement their validation
func _validate_setup() -> bool:
	return check_setup()

func setup_references() -> void:
	setup_controllers()
	setup_child_nodes()

func setup_controllers() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return
	game_controller = AcPctrl.get_game_controller(get_tree())
	combat_interface = game_controller.combat_interface

func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_UI: "user_interface",
		NAME_BTN_SHOW: "btn_show",
		NAME_BTN_HIDE: "btn_hide",
		NAME_CONTAINER: "container"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)

func setup_interface() -> void:
	if not check_setup():
		push_error("setup is not complete")
		return

func setup_signals() -> void:
	setup_btn_show()
	setup_btn_hide()

func initialize_state() -> void:
	hide()  # Initialize as hidden


func check_setup() -> bool:
	if game_controller == null:
		push_error("game_controller not set")
		return false
	if combat_interface == null:
		push_error("combat_interface not set")
		return false
	elif user_interface == null:
		push_error("user_interface not set")
		return false
	elif btn_show == null:
		push_error("btn_show not set")
		return false
	elif btn_hide == null:
		push_error("btn_hide not set")
		return false

	return true


func hide_if_click_outside(event) -> void:
	if event.is_action_released("app_click"):
		if (user_interface.is_visible() and
			not user_interface.get_global_rect().has_point(event.global_position)):

			hide()


func show() -> void:
	btn_show.hide()
	user_interface.show()
	ui_shown.emit()

func hide() -> void:
	user_interface.hide()
	btn_show.show()
	ui_hidden.emit()


func btn_hide_down() -> void:
	hide()


func btn_show_down() -> void:
	show()


func setup_btn_hide() -> void:
	btn_hide.connect("pressed", btn_hide_down)


func setup_btn_show() -> void:
	btn_show.connect("pressed", btn_show_down)


func clear_container() -> void:
	var container_children: Array[Node] = container.get_children()
	for child in container_children:
		child.queue_free()


func ac_show_hide_input(event: InputEvent) -> void:
	hide_if_click_outside(event)


func _input(event):
	ac_show_hide_input(event)
