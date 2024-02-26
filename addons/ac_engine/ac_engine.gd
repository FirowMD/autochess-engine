@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("AcCombatCollection", "Node", preload("res://addons/ac_engine/scripts/combat_collection.gd"), preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatCollectionButton", "Button", preload("res://addons/ac_engine/scripts/combat_collection_button.gd"), preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatEsc", "Node", preload("res://addons/ac_engine/scripts/combat_esc.gd"), preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatInterface", "Node", preload("res://addons/ac_engine/scripts/combat_interface.gd"), preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatLogger","AcShowHide",preload("res://addons/ac_engine/scripts/combat_logger.gd"),preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatMap","TileMap",preload("res://addons/ac_engine/scripts/combat_map.gd"),preload("res://addons/ac_engine/images/icon_map.png"))
	add_custom_type("AcCombatShop","Node",preload("res://addons/ac_engine/scripts/combat_shop.gd"),preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatShopButton","Button",preload("res://addons/ac_engine/scripts/combat_shop_button.gd"),preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcCombatUnit","CharacterBody2D",preload("res://addons/ac_engine/scripts/combat_unit.gd"),preload("res://addons/ac_engine/images/icon_char.png"))
	add_custom_type("AcGameController","Node",preload("res://addons/ac_engine/scripts/game_controller.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcGameGroup","Node",preload("res://addons/ac_engine/scripts/game_group.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcGamePlayer","Node",preload("res://addons/ac_engine/scripts/game_player.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcGameTimer","Node",preload("res://addons/ac_engine/scripts/game_timer.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcGroupManager","Node",preload("res://addons/ac_engine/scripts/group_manager.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcPlayerManager","Node",preload("res://addons/ac_engine/scripts/player_manager.gd"),preload("res://addons/ac_engine/images/icon.png"))
	add_custom_type("AcShowHide","Node",preload("res://addons/ac_engine/scripts/show_hide.gd"),preload("res://addons/ac_engine/images/icon_ctrl.png"))
	add_custom_type("AcWaveController", "Node", preload("res://addons/ac_engine/scripts/wave_controller.gd"), preload("res://addons/ac_engine/images/icon.png"))
	add_autoload_singleton("AcTypes","res://addons/ac_engine/scripts/ac_types.gd")
	add_autoload_singleton("AcPctrl","res://addons/ac_engine/nodes/persistent_controller.tscn")
	pass

func _exit_tree():
	remove_custom_type("AcCombatCollection")
	remove_custom_type("AcCombatCollectionButton")
	remove_custom_type("AcCombatEsc")
	remove_custom_type("AcCombatInterface")
	remove_custom_type("AcCombatLogger")
	remove_custom_type("AcCombatMap")
	remove_custom_type("AcCombatShop")
	remove_custom_type("AcCombatShopButton")
	remove_custom_type("AcCombatUnit")
	remove_custom_type("AcGameController")
	remove_custom_type("AcGameGroup")
	remove_custom_type("AcGamePlayer")
	remove_custom_type("AcGameTimer")
	remove_custom_type("AcGroupManager")
	remove_custom_type("AcPlayerManager")
	remove_custom_type("AcShowHide")
	remove_custom_type("AcWaveController")
	remove_autoload_singleton("AcTypes")
	remove_autoload_singleton("AcPctrl")
	pass
