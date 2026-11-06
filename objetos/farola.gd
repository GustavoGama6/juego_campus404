extends Area2D
# FAROLA (checkpoint). Al tocarla: guarda el punto de reaparición, se enciende
# (su luz congela al ruido) y aparece Chicle, el coatí, con una pista.
# El origen está en la base del poste.
# Arte: res://arte/farola.png (o .tres con "apagada" y "encendida"),
#       res://arte/chicle.png (o .tres con "sentado" y "senalar")

signal activada

const ARTE := preload("res://objetos/arte.gd")
const LUZ := preload("res://objetos/zona_luz.gd")

var mensaje_chicle: String = ""
var lado_chicle: float = 1.0        # 1 = Chicle a la derecha de la farola
var senala: float = 0.0             # -1 izquierda, 1 derecha, 0 no señala
var activa: bool = false
var tiempo: float = 0.0
var globo_timer: float = 0.0
var luz: Node2D
var arte: Node2D = null
var arte_chicle: Node2D = null
var globo: Label

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(20, 44)
	c.shape = f
	c.position = Vector2(0, -22)
	add_child(c)
	body_entered.connect(_on_body_entered)
	luz = LUZ.new()
	luz.forma = "circulo"
	luz.radio = 52.0
	luz.position = Vector2(0, -30)
	luz.activa = false
	add_child(luz)
	arte = ARTE.poner(self, "farola")
	globo = Label.new()
	globo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	globo.custom_minimum_size = Vector2(150, 0)
	globo.size = Vector2(150, 10)
	globo.add_theme_font_size_override("font_size", 9)
	globo.add_theme_color_override("font_color", Color("#0B0B14"))
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color("#F4F1EA")
	caja.border_color = Color("#8B5A2B")
	caja.set_border_width_all(1)
	caja.set_corner_radius_all(4)
	caja.set_content_margin_all(4)
	globo.add_theme_stylebox_override("normal", caja)
	globo.visible = false
	globo.z_index = 5
	add_child(globo)

func _on_body_entered(cuerpo: Node2D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return
	# Extraordinario: cada farola es un descanso, te llena los vasos al pasar
	if Juego.extraordinario() and int(cuerpo.get("energia")) < int(cuerpo.get("energia_maxima")):
		cuerpo.call("curar", 99)
		Sonido.sfx("cafe")
	if activa:
		return
	activa = true
	luz.activa = true
	cuerpo.call("establecer_checkpoint", global_position + Vector2(0, -2))
	Sonido.sfx("farola")
	activada.emit()
	if mensaje_chicle != "":
		arte_chicle = ARTE.poner(self, "chicle")
		if arte_chicle:
			arte_chicle.position.x = lado_chicle * 16.0
		globo.text = "CHICLE: " + mensaje_chicle
		globo.visible = true
		globo_timer = 6.0
		await get_tree().process_frame
		globo.position = Vector2(lado_chicle * 16.0 - 75.0, -60.0 - globo.size.y)

func _process(delta: float) -> void:
	tiempo += delta
	if globo_timer > 0.0:
		globo_timer -= delta
		if globo_timer <= 0.0:
			globo.visible = false
	if arte:
		ARTE.animar(arte, "encendida" if activa else "apagada")
	if arte_chicle:
		ARTE.animar(arte_chicle, "senalar" if globo_timer > 0.0 and senala != 0.0 else "sentado")
		ARTE.voltear(arte_chicle, senala < 0.0)
	queue_redraw()

func _draw() -> void:
	if arte == null:
		draw_rect(Rect2(-2, -36, 4, 36), Color("#9AA5A8"))
		draw_rect(Rect2(-5, -2, 10, 2), Color("#9AA5A8"))
		draw_rect(Rect2(-6, -44, 12, 9), Color("#F5C242") if activa else Color("#5A6366"))
		if not activa:
			draw_rect(Rect2(-6, -44, 12, 2), Color("#3A4045"))
	# Chicle, el coatí
	if activa and mensaje_chicle != "" and arte_chicle == null:
		_dibujar_chicle(Vector2(lado_chicle * 16.0, 0))

func _dibujar_chicle(o: Vector2) -> void:
	var d: float = senala if senala != 0.0 else -lado_chicle
	var cafe := Color("#9B6A3C")
	var claro := Color("#D8B28A")
	var cola_mueve: float = sin(tiempo * 4.0) * 2.0
	# Cola anillada
	for k in range(4):
		draw_rect(Rect2(o.x - d * (8.0 + k * 3.0) - 1.5, o.y - 10.0 - k * 3.0 + cola_mueve * 0.3 * k, 3, 3), cafe if k % 2 == 0 else Color("#3A2A1A"))
	# Cuerpo
	draw_rect(Rect2(o.x - 6, o.y - 9, 12, 7), cafe)
	draw_rect(Rect2(o.x - 5, o.y - 3, 3, 3), Color("#3A2A1A"))
	draw_rect(Rect2(o.x + 2, o.y - 3, 3, 3), Color("#3A2A1A"))
	# Cabeza con hocico largo
	draw_rect(Rect2(o.x + d * 5.0 - 3.0, o.y - 13, 7, 6), cafe)
	draw_rect(Rect2(o.x + d * 10.0 - 2.0, o.y - 10, 5, 2), claro)
	draw_rect(Rect2(o.x + d * 8.0 - 1.0, o.y - 12, 2, 2), Color("#0B0B14"))
	# Patita señalando
	if senala != 0.0 and globo_timer > 0.0:
		draw_line(Vector2(o.x + d * 4.0, o.y - 7), Vector2(o.x + d * 12.0, o.y - 9 + sin(tiempo * 8.0)), cafe, 2.0)
