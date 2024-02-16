class_name AcCombatCollection
extends Node


const NAME_UI = "UserInterface"
const NAME_BTN_SHOW = "BtnShow"
const NAME_BTN_HIDE = "BtnHide"
const NAME_ITEM_CONTAINER = "ItemContainer"


@export_group("General")
## The main panel which represents the collection
## It will show and hide by the buttons specified below
@export var user_interface: CanvasItem = null
## The button which will show the collection
@export var btn_show: Button = null
## The button which will hide the collection
@export var btn_hide: Button = null
## The container which will hold the items
@export var item_container: Container = null

@export_group("Advanced")
@export var game_controller: AcGameController = null


signal comcollection_hidden
signal comcollection_shown


func auto_setup():
	if is_inside_tree():
		game_controller = AcPctrl.get_game_controller(get_tree())
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
		elif node.name == NAME_ITEM_CONTAINER:
			item_container = node


func check_setup():
	if game_controller == null:
		push_error("game_controller not set")
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
	elif item_container == null:
		push_error("item_container not set")
		return false

	return true


func hide_collection_if_click_outside(event):
	if event is InputEventMouseButton:
		if (event.button_index == MouseButton.MOUSE_BUTTON_LEFT and
			event.pressed == false):
			
			if (user_interface.is_visible() and
				not user_interface.get_global_rect().has_point(event.global_position)):

				hide_collection()


func collection_show():
	btn_show.hide()
	user_interface.show()
	comcollection_shown.emit()

func hide_collection():
	user_interface.hide()
	btn_show.show()
	comcollection_hidden.emit()


func btn_hide_down():
	print("hiding collection")
	hide_collection()


func btn_show_down():
	print("showing collection")
	collection_show()


func setup_btn_hide():
	btn_hide.connect("pressed", btn_hide_down)


func setup_btn_show():
	btn_show.connect("pressed", btn_show_down)


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	
	setup_btn_show()
	setup_btn_hide()

	# Initialize collection as hidden
	hide_collection()

