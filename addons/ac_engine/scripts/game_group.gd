class_name AcGameGroup
extends Node


@export var group_name: String = "group_name"
@export var group_type: int = AcTypes.GameGroupType.NEUTRAL
@export var group_color: Color = Color(1, 1, 1, 1)


func get_group_name():
	return group_name


func get_group_type():
	return group_type


func get_group_color():
	return group_color