extends Area2D
# CREDENCIAL (la llave del juego). Abre las puertas con candado (E).
# El origen está en el centro. Arte: res://arte/credencial.png

signal tomada

const ARTE := preload("res://objetos/arte.gd")

var tiempo: float = 0.0
var base_y: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	base_y = position.y
	var c := CollisionShape2D.new()
	var f := CircleShape2D.new()
	f.radius = 9.0
	c.shape = f
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "credencial", false)

func _process(delta: float) -> void:
	tiempo += delta
	position.y = base_y + sin(tiempo * 3.0) * 2.0
	queue_redraw()

func _on_body_entered(b: Node2D) -> void:
	if not b.is_in_group("jugador"):
		return
	b.set("tiene_credencial", true)
	Sonido.sfx("sello")
	tomada.emit()
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.96, 0.76, 0.26, 0.2 + 0.1 * sin(tiempo * 5.0)))
	if arte:
		return
	draw_rect(Rect2(-8, -6, 16, 12), Color("#F5C242"))
	draw_rect(Rect2(-6, -4, 5, 8), Color("#F4F1EA"))
	draw_rect(Rect2(1, -3, 5, 2), Color("#0B0B14"))
	draw_rect(Rect2(1, 1, 4, 2), Color("#0B0B14"))
	draw_line(Vector2(0, -6), Vector2(0, -11), Color("#1FB6C1"), 1.0)
