extends Node

# PLAYER STATS PERSIST BETWEEN LEVELS
var levelsCompleted: int = 0
var enemiesKilled: int = 0
var itemsPickedUp: int = 0


# PLAYER INVENTORY
var inventory: Dictionary = {}
var inventorySize: int = 0

# ACTIVE PLAYER REFERENCE
var player: Player = null

# --- Persistent Player Vital Stats ---
var currentHP: int = 300
var HPmax: int = 300

var currentMN: int = 100
var MNmax: int = 100
