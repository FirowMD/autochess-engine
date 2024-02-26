class_name AcCraftSystem
extends Node

@export_group("General")
## The path to the json file that contains the craft system initial data
@export var json_path: String = "res://craft_system.json"

@export_group("Advanced")
@export var game_controller: AcGameController = null
@export var ac_tree: AcTree = null

# func add_craft_item(item: AcCombatUnit) -> void:
