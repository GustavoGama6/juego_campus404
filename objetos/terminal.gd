extends Area2D
# TERMINAL DEL NÚCLEO (pelea con el jefe). Cuando el jefe queda aturdido
# frente a ella se enciende (amarilla). Kin la activa con E y el jefe
# recibe un golpe. Ya usada queda verde. El origen está en la base.
# Arte: res://arte/terminal.png (o .tres con "apagada", "encendida", "usada")

signal usada_signal

const ARTE := preload("res://objetos/arte.gd")

var activa: bool = false
var usada: bool = false
var jefe: Node = null
var tiempo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	add_to_group("interactuable")
	arte = ARTE.poner(self, "terminal")

# Extraordinario: la pelea empieza de cero
func reiniciar() -> void:
	usada = false
	activa = false

func activar(si: bool) -> void:
	if usada:
		return
	activa = si

func puede_interactuar(_j) -> bool:
	return activa and not usada

func interactuar(_j) -> void:
	if not activa or usada:
		return
	usada = true
	activa = false
	Sonido.sfx("interruptor")
	usada_signal.emit()
	if jefe and is_instance_valid(jefe):
		jefe.call("recibir_golpe")

func _process(delta: float) -> void:
	tiempo += delta
	if arte:
		ARTE.animar(arte, "usada" if usada else ("encendida" if activa else "apagada"))
	queue_redraw()

func _draw() -> void:
	if arte == null:
		draw_rect(Rect2(-10, -26, 20, 26), Color("#2A2A33"))
		draw_rect(Rect2(-12, -30, 24, 6), Color("#4C5A63"))
		var pantalla: Color = Color("#3A4A50")
		if usada:
			pantalla = Color("#7CFFB2")
		elif activa:
			pantalla = Color("#F5C242") if int(tiempo * 6.0) % 2 == 0 else Color("#FFE38A")
		draw_rect(Rect2(-8, -24, 16, 10), pantalla)
		draw_rect(Rect2(-6, -10, 12, 2), Color("#29E7FF"))
	if activa and not usada:
		draw_circle(Vector2(0, -16), 18.0 + sin(tiempo * 8.0) * 2.0, Color(0.96, 0.76, 0.26, 0.2))
	var j = get_tree().get_first_node_in_group("jugador")
	if j != null and j.get("objeto_cercano") == self:
		var t: String = "[" + Juego.tecla("interactuar") + "]"
		var p := Vector2(0, -40)
		draw_rect(Rect2(p + Vector2(-10, -9), Vector2(20, 12)), Color(0, 0, 0, 0.7))
		draw_string(ThemeDB.fallback_font, p + Vector2(-10, 0), t, HORIZONTAL_ALIGNMENT_CENTER, 20, 9, Color("#F5C242"))
