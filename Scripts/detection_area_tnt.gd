extends Line2D

@export var flicker_hz: float = 8.0 
var time_acc: float = 0.0
@export var base_radius: float = 250.0
@export var angle_deg: float = 90.0
@export var segments = 32
@onready var pol = $"../CollisionShape2D"
#var segments: int = 64
var base_width: float = 16.0
var flicker_radius: float = 3
var flicker_alpha: float = 0.1
var flicker_width: float = 1.0

#var rng := RandomNumberGenerator.new()

func _ready():
	#rng.randomize()
	default_color = Color(1.0, 0.75, 0.3, 0.2) # torch color
	width = base_width
	draw_sector(base_radius)

func _process(delta):
	#$Line2D.global_transform = pol.global_transform
	time_acc += delta
	if time_acc < 1.0 / flicker_hz:
		return
	time_acc = 0.0
	var r = base_radius + randf_range(-flicker_radius, flicker_radius)
	draw_sector(r)
	var c = default_color
	c.a = clamp(0.4 + randf_range(-flicker_alpha, flicker_alpha), 0.15, 0.5)
	default_color = c
	width = base_width + randf_range(-flicker_width, flicker_width)

func draw_sector(radius):
	clear_points()
	#var pts: PackedVector2Array = PackedVector2Array()
	var center := Vector2.ZERO
	var half := deg_to_rad(angle_deg / 2.0)
	var start_angle := -half
	var end_angle := half
	add_point(center)
	var first_point = Vector2(cos(start_angle), sin(start_angle)) * radius
	add_point(first_point)
	for i in range(1, segments):
		var t := float(i) / float(segments)
		var ang = lerp(start_angle, end_angle, t)
		var p = Vector2(cos(ang), sin(ang)) * radius
		add_point(p)
	var last_point = Vector2(cos(end_angle), sin(end_angle)) * radius
	add_point(last_point)
	add_point(center)
