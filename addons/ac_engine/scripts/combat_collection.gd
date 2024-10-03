class_name AcCombatCollection
extends AcShowHide


@export_group("General")
## Button AcCombatCollectionButton, which will be used to place pieces
@export var item_button: PackedScene = null


func check_collection_setup() -> bool:
	if item_button == null:
		push_error("item_button not set")
		return false

	return true


## Update item container according to the current items
func update_container(current_items: Array[Node]) -> void:
	clear_container()

	for item in current_items:
		var new_item = item_button.instantiate()
		new_item._ready()
		new_item.set_item_name(item.base_name)
		var stats: String = "HP: {hp}\nDMG: {dmg}\nAS: {as}\nMS: {ms}".format({
			"hp": item.base_hp,
			"dmg": item.base_damage,
			"as": item.base_attack_speed,
			"ms": item.base_move_speed})
		new_item.set_item_description(stats)
		new_item.change_icon_animated(item.sprite)
		container.add_child(new_item)


func update_collection_items(items: Array[Node]) -> void:
	update_container(items)


func _ready():
	ac_show_hide_ready()

	game_controller.player_id.connect(
		"gameplayer_collection_items_changed",
		update_collection_items)
