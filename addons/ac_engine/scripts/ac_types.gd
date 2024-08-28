extends Node
## Singleton that defines all the types used in the game
## This is a good place to define your own enums, dictionaries, etc.


#
# Game
#

enum GameGroupType {
	NEUTRAL = 0,
	ENEMY = 1,
	ALLIE = 2,
}


#
# Combat unit
#

enum CombatUnitLabel {
	NONE = 0,
	FIRE = 1,
	WATER = 2,
	EARTH = 3,
	AIR = 4,
	LIGHT = 5,
	DARK = 6,
	IRON = 7,
}

enum CombatUnitPower {
	STANDARD = 0,
	ADVANCED = 1,
	ELITE = 2,
	RARE = 3,
	LEGENDARY = 4,
}

const CombatUnitPowerSize: int = 5

enum CombatUnitState {
	UNKNOWN = -1,
	IDLE = 0,
	WALK = 1,
	ATTACK = 2,
}

const CombatUnitStateNames: Dictionary = {
	CombatUnitState.IDLE: "idle",
	CombatUnitState.WALK: "walk",
	CombatUnitState.ATTACK: "attack",
}


#
# Wave
#

enum WaveType {
	DEFAULT = 0,
	BOSS = 1,
}

enum WaveDifficulty {
	EASY = 0,
	NORMAL = 1,
	HARD = 2,
}


#
# Common methods
#

## Convert list of scene paths to list of scene nodes (root of those scenes)
func scnpaths_to_scnnodes(paths: Array[String]) -> Array[Node]:
	var tmp_lst: Array[PackedScene] = []
	for path in paths:
		var scene = load(path)
		tmp_lst.append(scene)
	
	# instantiate scenes to get the root nodes
	var root_nodes: Array[Node] = []
	for scene in tmp_lst:
		var root = scene.instantiate()
		root_nodes.append(root)
	
	return root_nodes