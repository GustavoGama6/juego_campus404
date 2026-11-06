extends Area2D
# SALIDA DEL NIVEL. Está cerrada hasta que Kin toma el Fragmento del Códice.
# estilo = "puerta" (entrada del edificio) o "escalera" (escalera a la azotea).
# El origen está en la base. Arte: res://arte/salida_<estilo>.png

signal entrada

const ARTE := preload("res://objetos/arte.gd")

var estilo: String = "puerta"
var abierta: bool = false
var usada: bool = false
var tiempo: float = 0.0
var aviso_mostrado: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(24, 48)
	c.shape = f
	c.position = Vector2(0, -24)
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "salida_" + estilo)

func abrir() -> void:
	abierta = true

func _on_body_entered(b: Node2D) -> void:
	if not b.is_in_group("jugador") or usada:
		return
	if abierta:
		usada = true
		entrada.emit()
	else:
		aviso_mostrado = 2.0

func _process(delta: float) -> void:
	tiempo += delta
	aviso_mostrado -= delta
	if arte:
		ARTE.animar(arte, "abierta" if abierta else "cerrada")
	queue_redraw()

func _draw() -> void:
	if aviso_mostrado > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(-60, -60), "NECESITAS EL FRAGMENTO", HORIZONTAL_ALIGNMENT_CENTER, 120, 9, Color("#F5C242"))
	if arte:
		return
	if estilo == "escalera":
		for k in range(6):
			draw_rect(Rect2(-14 + k * 4, -8 - k * 8, 18, 8), Color("#C8A97E") if abierta else Color("#6E6A70"))
		if not abierta:
			draw_rect(Rect2(-16, -50, 32, 4), Color("#D81B8C"))
			draw_rect(Rect2(-16, -30, 32, 4), Color("#D81B8C"))
	else:
		draw_rect(Rect2(-14, -50, 28, 50), Color("#F4F1EA"))
		var luz: Color = Color("#F5C242") if abierta else Color("#2A2A33")
		draw_rect(Rect2(-10, -46, 20, 46), luz)
		if abierta:
			draw_circle(Vector2(0, -24), 24.0 + sin(tiempo * 3.0) * 2.0, Color(1, 0.9, 0.5, 0.18))
		else:
			draw_rect(Rect2(-10, -26, 20, 3), Color("#D81B8C"))
	if abierta and fmod(tiempo, 1.0) < 0.6:
		draw_string(ThemeDB.fallback_font, Vector2(-30, -60), "SALIDA", HORIZONTAL_ALIGNMENT_CENTER, 60, 9, Color("#7CFFB2"))
