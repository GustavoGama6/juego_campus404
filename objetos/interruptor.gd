extends Area2D
# INTERRUPTOR / PALANCA. Al activarlo (E cerca, o pisándolo si es "placa")
# emite la señal "activado". El nivel lo conecta a una puerta.
#   tipo = "palanca" (se usa con E) o "placa" (se activa al pisarla)
#   duracion = 0 -> se queda encendido para siempre; > 0 -> se apaga después
# El origen está en la base. Arte: res://arte/palanca.png / placa.png

signal activado
signal desactivado

const ARTE := preload("res://objetos/arte.gd")

var tipo: String = "palanca"
var duracion: float = 0.0
var encendido: bool = false
var timer: float = 0.0
var tiempo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(16, 16)
	c.shape = f
	c.position = Vector2(0, -8)
	add_child(c)
	if tipo == "palanca":
		add_to_group("interactuable")
	else:
		body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, tipo)

func puede_interactuar(_j) -> bool:
	return not encendido

func interactuar(_j) -> void:
	_encender()

func _on_body_entered(b: Node2D) -> void:
	if b.is_in_group("jugador") and not encendido:
		_encender()

func _encender() -> void:
	encendido = true
	timer = duracion
	Sonido.sfx("interruptor")
	activado.emit()

func _process(delta: float) -> void:
	tiempo += delta
	if encendido and duracion > 0.0:
		timer -= delta
		if timer <= 0.0:
			encendido = false
			desactivado.emit()
	if arte:
		ARTE.animar(arte, "encendido" if encendido else "apagado")
	queue_redraw()

func _draw() -> void:
	var j = get_tree().get_first_node_in_group("jugador")
	var cerca: bool = j != null and j.get("objeto_cercano") == self
	if arte == null:
		if tipo == "placa":
			draw_rect(Rect2(-10, -3, 20, 3), Color("#F5C242") if encendido else Color("#9AA5A8"))
			draw_rect(Rect2(-12, -1, 24, 1), Color("#4C5A63"))
		else:
			draw_rect(Rect2(-7, -6, 14, 6), Color("#4C5A63"))
			var a: float = 0.6 if encendido else -0.6
			var punta := Vector2(sin(a) * 12.0, -6.0 - cos(a) * 12.0)
			draw_line(Vector2(0, -6), punta, Color("#9AA5A8"), 2.0)
			draw_circle(punta, 3.0, Color("#7CFFB2") if encendido else Color("#D81B8C"))
	# Brillo amarillo: "se puede usar"
	if not encendido and tipo == "palanca":
		var b: float = 0.25 + 0.2 * sin(tiempo * 6.0)
		draw_circle(Vector2(0, -10), 14.0, Color(0.96, 0.76, 0.26, b * 0.5))
	if encendido and duracion > 0.0:
		draw_rect(Rect2(-10, -24, 20.0 * timer / duracion, 2), Color("#F5C242"))
	if cerca:
		_dibujar_tecla(self, Vector2(0, -34))

static func _dibujar_tecla(nodo: CanvasItem, pos: Vector2) -> void:
	var t: String = "[" + Juego.tecla("interactuar") + "]"
	nodo.draw_rect(Rect2(pos + Vector2(-10, -9), Vector2(20, 12)), Color(0, 0, 0, 0.7))
	nodo.draw_string(ThemeDB.fallback_font, pos + Vector2(-10, 0), t, HORIZONTAL_ALIGNMENT_CENTER, 20, 9, Color("#F5C242"))
