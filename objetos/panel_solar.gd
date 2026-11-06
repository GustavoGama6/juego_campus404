extends StaticBody2D
# PANEL SOLAR BASCULANTE: se inclina hacia el lado donde está Kin y lo hace
# resbalar hacia el extremo bajo. ¡Sigue avanzando! La posición es el centro.
# Arte: res://arte/panel_solar.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(64, 8)
var fuerza_resbalon: float = 75.0
var angulo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	if Juego.extraordinario():
		fuerza_resbalon = 105.0   # se inclinan más rápido
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	c.shape = f
	add_child(c)
	arte = ARTE.poner(self, "panel_solar", false)
	ARTE.ajustar(arte, tamano)

func _physics_process(delta: float) -> void:
	var objetivo: float = 0.0
	var j = get_tree().get_first_node_in_group("jugador")
	if j and j.is_on_floor():
		var d: Vector2 = j.global_position - global_position
		if absf(d.x) < tamano.x / 2.0 + 6.0 and absf(d.y + tamano.y / 2.0) < 3.0:
			var lado: float = 1.0 if d.x >= 0.0 else -1.0
			objetivo = lado * 0.21
			j.call("empujar_lateral", lado * fuerza_resbalon)
	angulo = move_toward(angulo, objetivo, delta * 1.5)
	if arte:
		arte.rotation = angulo
	queue_redraw()

func _draw() -> void:
	# Soporte
	draw_rect(Rect2(-3, tamano.y / 2.0, 6, 14), Color("#4C5A63"))
	if arte:
		return
	draw_set_transform(Vector2.ZERO, angulo, Vector2.ONE)
	var r := Rect2(-tamano / 2.0, tamano)
	draw_rect(r, Color("#1E3A5F"))
	var x: float = r.position.x + 8.0
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color("#6FA8DC"), 1.0)
		x += 8.0
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#BFE3FF"))
	draw_rect(r, Color("#9AA5A8"), false, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
