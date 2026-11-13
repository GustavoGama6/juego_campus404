extends Area2D
# FRAGMENTO DEL CÓDICE: al final de cada nivel. Abre la salida y reactiva
# una habilidad. Glifo original inspirado en la escritura maya (no es el logo
# de la universidad). El origen está en el centro.
# Arte: res://arte/fragmento.png (o .tres)

signal tomado

const ARTE := preload("res://objetos/arte.gd")

var recogido_ya: bool = false
var tiempo: float = 0.0
var base_y: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	base_y = position.y
	var c := CollisionShape2D.new()
	var f := CircleShape2D.new()
	f.radius = 12.0
	c.shape = f
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "fragmento", false)

func _process(delta: float) -> void:
	tiempo += delta
	position.y = base_y + sin(tiempo * 2.0) * 4.0
	queue_redraw()

func _on_body_entered(b: Node2D) -> void:
	if recogido_ya or not b.is_in_group("jugador"):
		return
	recogido_ya = true
	set_deferred("monitoring", false)
	Sonido.sfx("fragmento")
	tomado.emit()
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 20.0 + sin(tiempo * 4.0) * 3.0, Color(0.16, 0.9, 1.0, 0.15))
	if arte:
		return
	var c := Color("#29E7FF")
	draw_rect(Rect2(-10, -10, 20, 20), Color("#0B0B14"))
	draw_rect(Rect2(-10, -10, 20, 20), c, false, 2.0)
	# Glifo: espiral cuadrada
	draw_line(Vector2(-6, -6), Vector2(6, -6), c, 2.0)
	draw_line(Vector2(6, -6), Vector2(6, 6), c, 2.0)
	draw_line(Vector2(6, 6), Vector2(-3, 6), c, 2.0)
	draw_line(Vector2(-3, 6), Vector2(-3, -2), c, 2.0)
	draw_line(Vector2(-3, -2), Vector2(2, -2), c, 2.0)
	draw_rect(Rect2(-1, 1, 3, 3), Color("#F5C242"))
