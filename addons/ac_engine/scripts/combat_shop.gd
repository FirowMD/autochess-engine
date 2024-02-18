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
## Button AcCombatShopButton, which will be used to buy items
@export var item_button: PackedScene = null

@export_group("Advanced")
@export var game_controller: AcGameController = null


## Current items in shop
var combat_current_items: Array[Node] = []
var combat_previous_items: Array[Node] = []


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
	elif item_button == null:
		push_error("item_button not set")
		return false

	return true


func hide_shop_if_click_outside(event):
	if event.is_action_released("app_click"):
		if (user_interface.is_visible() and
			not user_interface.get_global_rect().has_point(event.global_position)):

			hide_shop()


func show():
	btn_show.hide()
	user_interface.show()
	comshop_shown.emit()

func hide_shop():
	user_interface.hide()
	btn_show.show()
	comshop_hidden.emit()


func btn_hide_down():
	hide_shop()


func btn_show_down():
	show()


func setup_btn_hide():
	btn_hide.connect("pressed", btn_hide_down)


func setup_btn_show():
	btn_show.connect("pressed", btn_show_down)


func clear_item_container():
	var ic_children = item_container.get_children()
	for child in ic_children:
		if child is AcCombatShopButton:
			child.queue_free()


## Update item container according to the current items
func update_item_container():
	clear_item_container()

	for item in combat_current_items:
		var new_item = item_button.instantiate()
		new_item._ready()
		new_item.set_item_name(item.base_name)
		new_item.set_item_price(item.base_cost)
		# var stats = "HP: " + str(item.base_hp) + "\n" +
		# 	"DMG: " + str(item.base_damage) + "\n" +
		# 	"AS: " + str(item.base_attack_speed) + "\n" +
		# 	"MS: " + str(item.base_move_speed)
		var stats = "HP: {}\nDMG: {}\nAS: {}\nMS: {}".format([
			item.base_hp,
			item.base_damage,
			item.base_attack_speed,
			item.base_move_speed])
		new_item.set_item_description(stats)
		new_item.change_icon_animated(item.sprite)
		item_container.add_child(new_item)


func extract_roots_from_items(items: Array[String]) -> Array[Node]:
	var tmp_lst: Array[PackedScene] = []
	for item in items:
		var scene = load(item)
		tmp_lst.append(scene)
	
	# instantiate scenes to get the root nodes
	var root_nodes: Array[Node] = []
	for scene in tmp_lst:
		var root = scene.instantiate()
		root_nodes.append(root)
	
	return root_nodes


func update_shop_items(items: Array[String]):
	combat_previous_items = combat_current_items
	combat_current_items = extract_roots_from_items(items)

	update_item_container()


func _ready():
	auto_setup()
	if not check_setup():
		push_error("setup is not complete")

	setup_btn_show()
	setup_btn_hide()

	game_controller.player_id.connect(
		"gameplayer_shop_items_changed",
		update_shop_items)

	# Initialize shop as hidden
	hide_shop()


func _input(event):
	hide_shop_if_click_outside(event)
