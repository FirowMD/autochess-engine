class_name AcPlayerManager
extends Node
## Player manager handles info about all in-game players
## Group manager must have at least 1 child node of type `AcGamePlayer`


@export_group("Advanced")
@export var game_players: Array[AcGamePlayer] = []


func auto_setup():
	for child in get_children():
		if child is AcGamePlayer:
			game_players.append(child)
			print("added player: ", child.name)
	print("player manager has ", game_players.size(), " players")


func get_player_by_id(id: int) -> AcGamePlayer:
	for player in game_players:
		if player.get_player_id() == id:
			return player

	return null


func check_setup() -> bool:
	if game_players.size() == 0:
		push_error("no players found")
		return false
	
	return true


func _ready():
	auto_setup()
	check_setup()
