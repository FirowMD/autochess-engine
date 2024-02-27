class_name AcCraftSystem
extends Node
## An abstract class that represents a craft system
## Here you can add items and their parts, and save/load the data to/from a json file


@export_group("General")
## The path to the json file that contains the craft system initial data
@export var json_path: String = "res://craft_system.json"

@export_group("Advanced")
@export var game_controller: AcGameController = null
@export var craft_graph: AcCraftGraph = null


## Add item, which builds from `parts` (which are parents)
func add_craft_item(item: Variant, parts: Array[Variant]) -> void:
	var item_node = craft_graph.add_node(item, parts)


## An example of how to add items to the craft system
func test_data_load():
	add_craft_item("Ore", [])
	add_craft_item("Coal", ["Ore"])
	add_craft_item("Copper", ["Ore"])
	add_craft_item("Tin", ["Ore"])
	add_craft_item("Iron", ["Ore"])
	add_craft_item("Carbon", ["Coal"])
	add_craft_item("Bronze", ["Copper", "Tin"])
	add_craft_item("Steel", ["Iron", "Carbon"])

	# # Save json data to file
	# var file_json = FileAccess.open(json_path, FileAccess.WRITE)
	# file_json.store_string(craft_graph.to_json())

	# # Load json data from file
	# var file_json = FileAccess.open(json_path, FileAccess.READ)
	# var json_data = file_json.get_as_text()
	# craft_graph.from_json(json_data)

	craft_graph.print_graph()


func _ready():
	test_data_load()
	pass
