extends RefCounted
# Estilo de los menús (botones, paneles, letras). Cámbialo aquí para todo el juego.
# Si pones una fuente en res://arte/fuente.ttf (o .otf), se usa en todos los menús.

const TURQUESA := Color("#1FB6C1")
const AMARILLO := Color("#F5C242")
const BLANCO := Color("#F4F1EA")
const NEGRO := Color("#0B0B14")
const MAGENTA := Color("#D81B8C")

static func crear() -> Theme:
	var t := Theme.new()
	for ext in ["ttf", "otf"]:
		var r := "res://arte/fuente.%s" % ext
		if ResourceLoader.exists(r):
			t.default_font = load(r)
			break
	t.default_font_size = 12
	t.set_color("font_color", "Label", BLANCO)

	var normal := _caja(Color(0.08, 0.12, 0.16, 0.92), TURQUESA, 1)
	var encima := _caja(Color(0.12, 0.22, 0.27, 0.95), AMARILLO, 1)
	var presionado := _caja(AMARILLO, AMARILLO, 1)
	var foco := _caja(Color(0.12, 0.22, 0.27, 0.95), AMARILLO, 2)
	var apagado := _caja(Color(0.1, 0.1, 0.12, 0.8), Color("#3A4045"), 1)
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", encima)
	t.set_stylebox("pressed", "Button", presionado)
	t.set_stylebox("focus", "Button", foco)
	t.set_stylebox("disabled", "Button", apagado)
	t.set_color("font_color", "Button", BLANCO)
	t.set_color("font_hover_color", "Button", AMARILLO)
	t.set_color("font_focus_color", "Button", AMARILLO)
	t.set_color("font_pressed_color", "Button", NEGRO)
	t.set_color("font_disabled_color", "Button", Color("#5A6366"))
	t.set_stylebox("panel", "Panel", _caja(Color(0.04, 0.05, 0.09, 0.94), TURQUESA, 2))
	t.set_stylebox("panel", "PanelContainer", _caja(Color(0.04, 0.05, 0.09, 0.94), TURQUESA, 2))
	t.set_color("font_color", "CheckButton", BLANCO)
	t.set_color("font_hover_color", "CheckButton", AMARILLO)
	t.set_color("font_focus_color", "CheckButton", AMARILLO)
	return t

static func _caja(fondo: Color, borde: Color, grosor: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.border_color = borde
	s.set_border_width_all(grosor)
	s.set_corner_radius_all(3)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	return s

# Etiqueta con contorno, para títulos sobre fondos de colores
static func titulo(texto: String, tam: int, color: Color = AMARILLO) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", NEGRO)
	l.add_theme_constant_override("outline_size", 5)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

static func boton(texto: String, accion: Callable, ancho: float = 180.0) -> Button:
	var b := Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(ancho, 24)
	b.pressed.connect(Sonido.sfx.bind("menu"))
	b.pressed.connect(accion)
	return b
