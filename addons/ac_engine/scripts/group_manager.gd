class_name AcGroupManager
extends Node
## Group manager handles game groups and determines who is who's enemy
## Group manager must have at least 1 child node of type `AcGameGroup`


@export_group("Advanced")
@export var game_groups: Array[AcGameGroup] = []


func get_enemy_groups(your_group):
	var gtype = your_group.get_group_type()
	var enemy_groups = []

	for g in game_groups:
		if g.get_group_type() != gtype:
			enemy_groups.append(g)
	
	return enemy_groups


func get_groups_by_type(gtype):
	var groups = []

	for g in game_groups:
		if g.get_group_type() == gtype:
			groups.append(g)
	
	return groups


func auto_setup():
	for child in get_children():
		if child is AcGameGroup:
			game_groups.append(child)
			print("added group: ", child.name)
	print("group manager has ", game_groups.size(), " groups")


func check_setup():
	if game_groups.size() == 0:
		push_error("no groups found")
		return false
	
	return true


func _ready():
	auto_setup()
	check_setup()
