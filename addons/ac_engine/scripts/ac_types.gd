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
}

enum CombatUnitPower {
	STANDARD = 0,
	ADVANCED = 1,
	ELITE = 2,
}

enum CombatUnitState {
	IDLE = 0,
	WALK = 1,
	ATTACK = 2,
}

const CombatUnitStateNames = {
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
