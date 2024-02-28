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


## Load the data from the json file
## If `fpath` is empty, it will use the `json_path` variable
func load_data_from_file(fpath: String = "") -> void:
	if fpath == "":
		fpath = json_path

	var file_json = FileAccess.open(fpath, FileAccess.READ)
	if file_json == null:
		print("Error: Could not open file: " + fpath)
		return
	
	var json_data = file_json.get_as_text()
	craft_graph.from_json(json_data)


## Save the data to the json file
## If `fpath` is empty, it will use the `json_path` variable
func save_data_to_file(fpath: String = "") -> void:
	if fpath == "":
		fpath = json_path

	var file_json = FileAccess.open(fpath, FileAccess.WRITE)
	if file_json == null:
		print("Error: Could not open file: " + fpath)
		return

	file_json.store_string(craft_graph.to_json())


## Add item, which builds from `parts` (which are parents)
func add_craft_item(item: Variant, parts: Array[Variant]) -> void:
	var item_node = craft_graph.add_node(item, parts)

## Load craft system from directory containing `Combat Unit`s
## Generates a graph based on `Combat Unit`'s properties:
## `base_power` - crafting level of the unit
## `base_crafting` - units necessary to craft the unit
func load_from_comunit_dir():
	var combat_units: Array[AcCombatUnit] = AcPctrl.get_combat_units()

	for level_power in range(AcTypes.CombatUnitPowerSize):
		for comunit in combat_units:
			if comunit.base_power == level_power:
				add_craft_item(comunit.base_name, comunit.base_crafting)
	

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

	craft_graph.print_graph()


func _ready():
	# test_data_load()
	# save_data_to_file()
	# load_data_from_file()
	# craft_graph.print_graph()
	load_from_comunit_dir()
	craft_graph.print_graph()
	pass
