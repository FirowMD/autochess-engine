# todo: class name does not match filename
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


func auto_setup() -> void:
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
		combat_interface = game_controller.combat_interface
	else:
		push_error("not inside tree")
	
	var child_nodes: Array[Node] = get_children()

	for node in child_nodes:
		if node.name == NAME_UI:
			user_interface = node
		elif node.name == NAME_BTN_SHOW:
			btn_show = node
		elif node.name == NAME_BTN_HIDE:
			btn_hide = node
		elif node.name == NAME_CONTAINER:
			container = node


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
			# todo: fix reference [get_global_rect] not found
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


func ac_show_hide_ready() -> void:
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")

	setup_btn_show()
	setup_btn_hide()

	# Initialize as hidden
	hide()


func ac_show_hide_input(event: InputEvent) -> void:
	hide_if_click_outside(event)


func _ready():
	ac_show_hide_ready()


func _input(event):
	ac_show_hide_input(event)
