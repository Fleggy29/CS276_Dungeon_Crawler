extends Line2D

@export var flicker_hz: float = 8.0 
var time_acc: float = 0.0
@export var base_radius: float = 200.0
var segments: int = 64
var base_width: float = 16.0
var flicker_radius: float = 3.0
var flicker_alpha: float = 0.1
var flicker_width: float = 1.0

#var rng := RandomNumberGenerator.new()

func _ready():
	#rng.randomize()
	default_color = Color(1.0, 0.75, 0.3, 0.2) # torch color
	width = base_width
	_rebuild_circle(base_radius)

func _process(delta):
	time_acc += delta
	if time_acc < 1.0 / flicker_hz:
		return
	time_acc = 0.0
	var r = base_radius + randf_range(-flicker_radius, flicker_radius)
	_rebuild_circle(r)
	var c = default_color
	c.a = clamp(0.4 + randf_range(-flicker_alpha, flicker_alpha), 0.15, 0.5)
	default_color = c
	width = base_width + randf_range(-flicker_width, flicker_width)

func _rebuild_circle(radius):
	clear_points()
	for i in range(segments + 1):
		var angle := float(i) / segments * TAU
		var p = Vector2(cos(angle), sin(angle)) * radius
		add_point(p)
