class_name AcGamePlayer
extends Node
## Class which represents the player in the game
## It contains the player's name, id, hp, exp, gold, and score.
## (!) All interacts should be done through setters and getters


@export_group("General")
@export var player_name: String = "player_name"
@export var player_id: int = -1

@export_group("Game Data")
@export var player_hp: int = 1
@export var player_exp: int = 0
@export var player_gold: int = 0
@export var player_score: int = 0


func get_player_id():
	return player_id


func get_player_name():
	return player_name


func get_player_hp():
	return player_hp


func get_player_exp():
	return player_exp


func get_player_gold():
	return player_gold


func get_player_score():
	return player_score


func set_player_name(name: String):
	player_name = name


func set_player_hp(hp: int):
	player_hp = hp


func set_player_exp(exp: int):
	player_exp = exp


func set_player_gold(gold: int):
	player_gold = gold


func set_player_score(score: int):
	player_score = score
