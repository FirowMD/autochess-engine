class_name AcCombatShop
extends AcShowHide


@export_group("General")
## Button AcCombatShopButton, which will be used to buy items
@export var item_button: PackedScene = null


## Current items in shop
var combat_current_items: Array[Node] = []
var combat_previous_items: Array[Node] = []


func check_shop_setup() -> bool:
	if item_button == null:
		push_error("item_button not set")
		return false

	return true


## Update item container according to the current items
func update_container() -> void:
	clear_container()

	for item in combat_current_items:
		var new_item = item_button.instantiate()
		new_item._ready()
		new_item.set_item_name(item.base_name)
		new_item.set_item_price(item.base_cost)
		var stats: String = "HP: {hp}\nDMG: {dmg}\nAS: {as}\nMS: {ms}".format({
			"hp": item.base_hp,
			"dmg": item.base_damage,
			"as": item.base_attack_speed,
			"ms": item.base_move_speed})
		new_item.set_item_description(stats)
		new_item.change_icon_animated(item.sprite)
		container.add_child(new_item)


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


func update_shop_items(items: Array[String]) -> void:
	combat_previous_items = combat_current_items
	combat_current_items = extract_roots_from_items(items)

	update_container()


func _ready():
	ac_show_hide_ready()

	game_controller.player_id.connect(
		"gameplayer_shop_items_changed",
		update_shop_items)
