extends CanvasLayer
@onready var health_bar = $TopHUD/Bars/Health
@onready var mana_bar = $TopHUD/Bars/Mana
@onready var player = $"../Player"


func _ready() -> void:
	var fill = health_bar.get_theme_stylebox("fill").duplicate()
	if fill is StyleBoxFlat:
		fill.bg_color = Color(1, 0, 0)
	health_bar.add_theme_stylebox_override("fill", fill)
	health_bar.custom_minimum_size = Vector2(500, 70)
	fill = mana_bar.get_theme_stylebox("fill").duplicate()
	if fill is StyleBoxFlat:
		fill.bg_color = Color(0, 0, 1)
	mana_bar.add_theme_stylebox_override("fill", fill)
	mana_bar.custom_minimum_size = Vector2(300, 70)
	#mana_bar.custom_minimum_size   = Vector2(300, 70)
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.mana_changed.connect(_on_player_mana_changed)
		_on_player_health_changed(player.currentHP, player.HPmax)
		_on_player_mana_changed(player.currentMN, player.MNmax)
		
		
func _on_player_health_changed(current: int, max_value: int) -> void:
	health_bar.max_value = max_value
	health_bar.value = current

func _on_player_mana_changed(current: int, max_value: int) -> void:
	#print(current, max_value)
	mana_bar.max_value = max_value
	mana_bar.value = current
