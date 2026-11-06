extends Control
# CRÉDITOS. Edita los nombres en autoload/juego.gd (CREADORES).
# Agrega aquí las licencias de los recursos que descarguen (sprites, música, fuentes).

const TEMA := preload("res://ui/tema.gd")
const FONDO := preload("res://fondos/fondo_campus.gd")

const LICENCIAS := [
	"Motor: Godot Engine 4 (licencia MIT)",
	"Arte y sonido provisionales: generados por código",
	"(Agreguen aquí los créditos y licencias de sus sprites, música y fuentes)",
]

func _ready() -> void:
	theme = TEMA.crear()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo = FONDO.new()
	fondo.variante = "azotea"
	fondo.ancho_nivel = 640.0
	add_child(fondo)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.55)
	oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(oscuro)

	var caja := VBoxContainer.new()
	caja.position = Vector2(60, 14)
	caja.size = Vector2(520, 300)
	caja.add_theme_constant_override("separation", 4)
	add_child(caja)
	caja.add_child(TEMA.titulo(Juego.NOMBRE_JUEGO, 26))
	caja.add_child(TEMA.titulo("CRÉDITOS", 14, TEMA.TURQUESA))
	caja.add_child(TEMA.titulo("Un juego creado por:", 11, TEMA.BLANCO))
	for nombre in Juego.CREADORES:
		caja.add_child(TEMA.titulo(str(nombre), 11, TEMA.AMARILLO))
	caja.add_child(TEMA.titulo(Juego.MATERIA, 10, TEMA.BLANCO))
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(0, 6)
	caja.add_child(sep)
	for l in LICENCIAS:
		caja.add_child(TEMA.titulo(str(l), 9, Color("#C9D1D3")))
	caja.add_child(TEMA.titulo("El campus es inspiración; los personajes y la historia son ficticios.", 9, Color("#C9D1D3")))
	caja.add_child(TEMA.titulo("¡Gracias por jugar!", 13, Color("#7CFFB2")))

	var volver := TEMA.boton("Volver", func(): Juego.ir_menu(), 140)
	volver.position = Vector2(250, 322)
	add_child(volver)
	volver.grab_focus()
	Sonido.musica("menu")
