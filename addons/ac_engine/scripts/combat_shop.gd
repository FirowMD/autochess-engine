class_name AcCombatShop
extends Node


const NAME_UI = "UserInterface"
const NAME_BTN_SHOW = "BtnShow"
const NAME_BTN_HIDE = "BtnHide"
const NAME_ITEM_CONTAINER = "ItemContainer"


@export_group("General")
## The main panel which represents the shop
## It will show and hide by the buttons specified below
@export var user_interface: CanvasItem = null
## The button which will show the shop
@export var btn_show: Button = null
## The button which will hide the shop
@export var btn_hide: Button = null
## The container which will hold the items
@export var item_container: Container = null

@export_group("Advanced")
@export var game_controller: AcGameController = null


## Scenes containing CombatUnits
var combat_unit_list: Array = []

## Current items in shop
var combat_current_items: Array = []
var combat_previous_items: Array = []


signal comshop_hidden
signal comshop_shown


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


## Generates 5 items from the item pull
## These items can be bought by the player
func generate_current_items(item_pull):
	combat_previous_items = combat_current_items.duplicate()
	combat_current_items = []
	for i in range(5):
		var item = item_pull[randi() % item_pull.size()]
		combat_current_items.append(item)


func hide_shop_if_click_outside(event):
	if event is InputEventMouseButton:
		if (event.button_index == MouseButton.MOUSE_BUTTON_LEFT and
			event.pressed == false):
			
			if (user_interface.is_visible() and
				not user_interface.get_global_rect().has_point(event.global_position)):

				hide_shop()


func show():
	if user_interface == null:
		push_error("user_interface not set")
		return
	
	btn_show.hide()
	user_interface.show()
	comshop_shown.emit()

func hide_shop():
	if user_interface == null:
		push_error("user_interface not set")
		return
	
	user_interface.hide()
	btn_show.show()
	comshop_hidden.emit()


func btn_hide_down():
	hide_shop()


func btn_show_down():
	show()


func setup_btn_hide():
	if btn_hide == null:
		push_error("btn_hide not set")
		return
	
	btn_hide.connect("pressed", btn_hide_down)


func setup_btn_show():
	if btn_show == null:
		push_error("btn_show not set")
		return
	
	btn_show.connect("pressed", btn_show_down)


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")
	combat_unit_list = AcPctrl.get_combat_unit_list_all()

	if combat_unit_list.size() != 0:
		generate_current_items(combat_unit_list)
	
	setup_btn_show()
	setup_btn_hide()

	# Initialize shop as hidden
	hide_shop()


#! Need to remove and add as `action` to make compatible with all platforms:
# PC, Android, iOS
# func _input(event):
# 	hide_shop_if_click_outside(event)
