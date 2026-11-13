extends Area2D
# APUNTE (+1, cuentan para la calificación) o SELLO DE HONOR (es_sello = true,
# escondidos, 3 por nivel). El origen está en el centro.
# Arte: res://arte/apunte.png y res://arte/sello.png

signal recogido(es_sello: bool, id: int)

const ARTE := preload("res://objetos/arte.gd")

var es_sello: bool = false
var id: int = 0
var recogido_ya: bool = false
var tiempo: float = 0.0
var base_y: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	base_y = position.y
	tiempo = fmod(position.x * 0.05, TAU)
	var c := CollisionShape2D.new()
	var f := CircleShape2D.new()
	f.radius = 7.0
	c.shape = f
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "sello" if es_sello else "apunte", false)

func _process(delta: float) -> void:
	tiempo += delta
	position.y = base_y + sin(tiempo * 3.0) * 2.0
	if es_sello:
		queue_redraw()

func _on_body_entered(b: Node2D) -> void:
	if recogido_ya or not b.is_in_group("jugador"):
		return
	recogido_ya = true
	set_deferred("monitoring", false)
	Sonido.sfx("sello" if es_sello else "apunte")
	recogido.emit(es_sello, id)
	queue_free()

func _draw() -> void:
	if arte:
		return
	if es_sello:
		draw_circle(Vector2.ZERO, 11.0 + sin(tiempo * 4.0), Color(0.16, 0.9, 1.0, 0.18))
		var puntos := PackedVector2Array([
			Vector2(0, -9), Vector2(3, -3), Vector2(9, 0), Vector2(3, 3),
			Vector2(0, 9), Vector2(-3, 3), Vector2(-9, 0), Vector2(-3, -3)])
		draw_colored_polygon(puntos, Color("#29E7FF"))
		draw_circle(Vector2.ZERO, 2.5, Color("#F4F1EA"))
	else:
		draw_rect(Rect2(-4, -5, 8, 10), Color("#F5C242"))
		draw_rect(Rect2(-4, -5, 2, 10), Color("#C99A1E"))
		draw_line(Vector2(-1, -2), Vector2(3, -2), Color("#F4F1EA"), 1.0)
		draw_line(Vector2(-1, 1), Vector2(3, 1), Color("#F4F1EA"), 1.0)
