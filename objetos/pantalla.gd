extends Node2D
# PANTALLA DEL CAMPUS: la Profe Ixchel habla por aquí. Cuando Kin se acerca,
# aparece el mensaje letra por letra. El origen está en la base del poste.
# Arte: res://arte/pantalla.png

const ARTE := preload("res://objetos/arte.gd")

var mensaje: String = ""
var distancia: float = 90.0
var visto: bool = false
var letras: float = 0.0
var tiempo: float = 0.0
var texto: Label
var arte: Node2D = null

func _ready() -> void:
	arte = ARTE.poner(self, "pantalla")
	texto = Label.new()
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size = Vector2(200, 10)
	texto.custom_minimum_size = Vector2(200, 0)
	texto.position = Vector2(-100, -150)
	texto.add_theme_font_size_override("font_size", 9)
	texto.add_theme_color_override("font_color", Color("#7CFFB2"))
	var caja := StyleBoxFlat.new()
	caja.bg_color = Color(0.04, 0.08, 0.1, 0.92)
	caja.border_color = Color("#1FB6C1")
	caja.set_border_width_all(1)
	caja.set_content_margin_all(5)
	texto.add_theme_stylebox_override("normal", caja)
	texto.visible = false
	texto.z_index = 5
	add_child(texto)

func _process(delta: float) -> void:
	tiempo += delta
	var j := get_tree().get_first_node_in_group("jugador") as Node2D
	var cerca: bool = j != null and j.global_position.distance_to(global_position) < distancia
	if cerca:
		if not visto:
			visto = true
			Sonido.sfx("menu")
		letras = minf(letras + delta * 45.0, float(mensaje.length()) + 1.0)
	texto.visible = cerca and mensaje != ""
	if texto.visible:
		texto.text = "PROFE IXCHEL:\n" + mensaje.substr(0, int(letras))
		texto.position.y = -52.0 - texto.size.y
		# Que el globo no se salga de la pantalla por los lados
		var ct := get_viewport().get_canvas_transform()
		var izq: float = -ct.origin.x / ct.get_scale().x
		var ancho_vista: float = get_viewport_rect().size.x / ct.get_scale().x
		var gx: float = clampf(global_position.x - 100.0, izq + 4.0, izq + ancho_vista - 204.0)
		texto.position.x = gx - global_position.x
	queue_redraw()

func _draw() -> void:
	if arte:
		return
	draw_rect(Rect2(-2, -30, 4, 30), Color("#4C5A63"))
	draw_rect(Rect2(-14, -46, 28, 18), Color("#2A2A33"))
	var brillo: Color = Color("#1FB6C1") if int(tiempo * 2.0) % 2 == 0 or visto else Color("#0E5F66")
	draw_rect(Rect2(-12, -44, 24, 14), brillo)
	draw_rect(Rect2(-8, -40, 6, 2), Color("#F4F1EA"))
	draw_rect(Rect2(-8, -36, 12, 2), Color("#F4F1EA"))
