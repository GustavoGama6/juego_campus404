extends Area2D
# CAFÉ: devuelve 1 vaso de energía. El origen está en el centro.
# Arte: res://arte/cafe.png

const ARTE := preload("res://objetos/arte.gd")

var tiempo: float = 0.0
var base_y: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	base_y = position.y
	var c := CollisionShape2D.new()
	var f := CircleShape2D.new()
	f.radius = 8.0
	c.shape = f
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "cafe", false)

func _process(delta: float) -> void:
	tiempo += delta
	position.y = base_y + sin(tiempo * 3.0) * 2.0
	queue_redraw()

func _on_body_entered(b: Node2D) -> void:
	if not b.is_in_group("jugador"):
		return
	if int(b.get("energia")) >= int(b.get("energia_maxima")):
		return   # con energía llena no se gasta
	b.call("curar", 1)
	Sonido.sfx("cafe")
	queue_free()

func _draw() -> void:
	if arte:
		return
	draw_circle(Vector2.ZERO, 10.0, Color(1, 0.8, 0.5, 0.15))
	draw_rect(Rect2(-5, -6, 10, 12), Color("#F4F1EA"))
	draw_rect(Rect2(-4, -4, 8, 9), Color("#6B3E1F"))
	draw_rect(Rect2(5, -3, 3, 5), Color("#F4F1EA"), false, 1.0)
	# Vapor
	for k in range(2):
		var y: float = -9.0 - fmod(tiempo * 8.0 + k * 4.0, 6.0)
		draw_rect(Rect2(-2 + k * 3, y, 1, 2), Color(1, 1, 1, 0.6))
