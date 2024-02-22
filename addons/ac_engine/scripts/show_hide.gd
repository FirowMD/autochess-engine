class_name AcShowHide
extends Node


const NAME_UI = "UserInterface"
const NAME_BTN_SHOW = "BtnShow"
const NAME_BTN_HIDE = "BtnHide"
const NAME_CONTAINER = "Container"


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


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
		combat_interface = game_controller.combat_interface
	else:
		push_error("not inside tree")
	
	var child_nodes = get_children()

	for node in child_nodes:
		if node.name == NAME_UI:
			user_interface = node
		elif node.name == NAME_BTN_SHOW:
			btn_show = node
		elif node.name == NAME_BTN_HIDE:
			btn_hide = node
		elif node.name == NAME_CONTAINER:
			container = node


func check_setup():
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


func hide_if_click_outside(event):
	if event.is_action_released("app_click"):
		if (user_interface.is_visible() and
			not user_interface.get_global_rect().has_point(event.global_position)):

			hide()


func show():
	btn_show.hide()
	user_interface.show()
	ui_shown.emit()

func hide():
	user_interface.hide()
	btn_show.show()
	ui_hidden.emit()


func btn_hide_down():
	hide()


func btn_show_down():
	show()


func setup_btn_hide():
	btn_hide.connect("pressed", btn_hide_down)


func setup_btn_show():
	btn_show.connect("pressed", btn_show_down)


func clear_container():
	var container_children = container.get_children()
	for child in container_children:
		child.queue_free()


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")

	setup_btn_show()
	setup_btn_hide()

	# Initialize as hidden
	hide()


func _input(event):
	hide_if_click_outside(event)
