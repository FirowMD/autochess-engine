class_name AcGameGroup
extends Node


@export var group_name: String = "group_name"
@export var group_type: AcTypes.GameGroupType = AcTypes.GameGroupType.NEUTRAL
@export var group_color: Color = Color(1, 1, 1, 1)


func get_group_name() -> String:
	return group_name


func get_group_type() -> AcTypes.GameGroupType:
	return group_type


func get_group_color() -> Color:
	return group_color