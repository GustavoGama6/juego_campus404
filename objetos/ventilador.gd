extends Area2D
# VENTILADOR: corriente de aire que empuja hacia arriba a Kin
# (más fuerte si está planeando). El origen es la base del ventilador.
# Arte: res://arte/ventilador.png

const ARTE := preload("res://objetos/arte.gd")

var ancho: float = 40.0
var alto: float = 200.0
var fuerza: float = 200.0
var tiempo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(ancho, alto)
	c.shape = f
	c.position = Vector2(0, -alto / 2.0)
	add_child(c)
	arte = ARTE.poner(self, "ventilador")

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("empujar_viento", fuerza)

func _draw() -> void:
	# Corrientes de aire subiendo
	for k in range(8):
		var x: float = -ancho / 2.0 + 4.0 + float(k % 4) * (ancho - 8.0) / 3.0
		var y: float = -fmod(tiempo * 120.0 + float(k) * 37.0, alto)
		draw_line(Vector2(x, y), Vector2(x, y - 10.0), Color(0.85, 0.95, 1.0, 0.45), 1.0)
	if arte:
		return
	draw_rect(Rect2(-ancho / 2.0, -8, ancho, 8), Color("#4C5A63"))
	draw_rect(Rect2(-ancho / 2.0, -8, ancho, 2), Color("#8FA3AE"))
	var giro: float = tiempo * 20.0
	for k in range(3):
		var a: float = giro + float(k) * TAU / 3.0
		draw_line(Vector2(0, -4), Vector2(cos(a) * (ancho / 2.0 - 3.0), -4.0 + sin(a) * 2.0), Color("#F4F1EA"), 2.0)
