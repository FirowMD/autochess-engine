class_name AcCombatShopButton
extends Button
## This is a button that will be used in the shop
## To present the item that can be bought, especially combat unit


const NAME_LABEL_NAME: String = "Name"
const NAME_LABEL_PRICE: String = "Price"
const NAME_ICON_ANIMATED: String = "IconAnimated"
const NAME_ICON_STATIC: String = "IconStatic"


@export_group("General")
@export var item_id: int = -1
@export var item_name: String = ""
@export var item_price: int = 0
@export var item_description: String = ""
@export var use_animated_icon: bool = true

@export_group("Transform")
## Need to specify the minimum size of the button
## For container where the button will be placed
@export var button_size: Vector2 = Vector2(304, 192)

@export_group("Advanced")
@export var combat_shop: AcCombatShop = null
@export var label_name: Label = null
@export var label_price: Label = null
@export var icon_animated: AnimatedSprite2D = null
@export var icon_static: Sprite2D = null

func _ready():
	setup_references()
	setup_shop_button()
	connect("button_down", btn_buy_down)

func setup_references() -> void:
	setup_controllers()
	setup_child_nodes()

func setup_controllers() -> void:
	if not is_inside_tree():
		push_error("not inside tree")
		return

func setup_child_nodes() -> void:
	const NODE_MAPPINGS = {
		NAME_LABEL_NAME: "label_name",
		NAME_LABEL_PRICE: "label_price",
		NAME_ICON_ANIMATED: "icon_animated",
		NAME_ICON_STATIC: "icon_static"
	}
	
	for node in get_children():
		if node.name in NODE_MAPPINGS:
			set(NODE_MAPPINGS[node.name], node)

func setup_shop_button() -> void:
	update_custom_min_size()
	if not check_setup():
		push_error("setup is not complete")
	
	setup_icon()
	setup_name()
	setup_price()

func check_setup() -> bool:
	if label_name == null:
		push_error("label_name not set")
		return false
	elif label_price == null:
		push_error("label_price not set")
		return false
	elif icon_animated == null:
		push_error("icon_animated not set")
		return false
	elif icon_static == null:
		push_error("icon_static not set")
		return false
	return true

func update_custom_min_size():
	custom_minimum_size = button_size


func setup_icon() -> void:
	if icon_animated == null or icon_static == null:
		return

	if use_animated_icon:
		icon_animated.visible = true
		icon_static.visible = false

		# Play
		icon_animated.play("idle")
	else:
		icon_animated.visible = false
		icon_static.visible = true


func setup_name():
	label_name.text = item_name


func setup_price():
	label_price.text = str(item_price)


func change_icon_animated(anisprite: AnimatedSprite2D):
	icon_animated = anisprite
	setup_icon()


func change_icon_static(sprite: Sprite2D):
	icon_static = sprite
	setup_icon()


func set_item_name(name: String):
	item_name = name
	setup_name()


func set_item_price(price: int):
	item_price = price
	setup_price()


func set_item_description(description: String):
	item_description = description


func btn_buy_down():
	var game_controller = AcPctrl.get_game_controller(get_tree())
	game_controller.player_id.buy_shop_item(item_id)
