extends Panel
# =====================================================================
#  PANEL DE OPCIONES (se usa desde el menú principal y desde la pausa):
#  volumen de música y efectos, pantalla completa, cambiar controles,
#  restablecer controles y borrar el progreso.
# =====================================================================

signal cerrado

const TEMA := preload("res://ui/tema.gd")

var esperando_accion: String = ""
var botones_teclas: Dictionary = {}
var boton_borrar: Button
var confirmar_borrar: bool = false
var primer_foco: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = TEMA.crear()
	position = Vector2(110, 14)
	size = Vector2(420, 332)

	var raiz := VBoxContainer.new()
	raiz.position = Vector2(14, 10)
	raiz.size = Vector2(392, 312)
	raiz.add_theme_constant_override("separation", 6)
	add_child(raiz)

	var t := TEMA.titulo("OPCIONES", 18)
	raiz.add_child(t)

	raiz.add_child(_fila_slider("Música", "musica"))
	raiz.add_child(_fila_slider("Efectos", "efectos"))

	var pc := CheckButton.new()
	pc.text = "Pantalla completa"
	pc.button_pressed = bool(Juego.datos["opciones"]["pantalla_completa"])
	pc.toggled.connect(func(v: bool): Juego.set_pantalla_completa(v))
	raiz.add_child(pc)

	var lc := Label.new()
	lc.text = "CONTROLES (haz clic y presiona una tecla nueva)"
	lc.add_theme_color_override("font_color", TEMA.AMARILLO)
	lc.add_theme_font_size_override("font_size", 10)
	raiz.add_child(lc)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(392, 112)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	raiz.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lista)
	for accion in Juego.CONTROLES_DEFECTO.keys():
		var fila := HBoxContainer.new()
		var l := Label.new()
		l.text = Juego.NOMBRES_ACCIONES[accion]
		l.custom_minimum_size = Vector2(220, 0)
		l.add_theme_font_size_override("font_size", 10)
		fila.add_child(l)
		var b := Button.new()
		b.custom_minimum_size = Vector2(140, 20)
		b.add_theme_font_size_override("font_size", 10)
		b.pressed.connect(_esperar_tecla.bind(accion))
		fila.add_child(b)
		botones_teclas[accion] = b
		lista.add_child(fila)
	_refrescar_teclas()

	var abajo := HBoxContainer.new()
	abajo.add_theme_constant_override("separation", 6)
	raiz.add_child(abajo)
	abajo.add_child(TEMA.boton("Restablecer", _restablecer, 120))
	boton_borrar = TEMA.boton("Borrar progreso", _borrar, 130)
	abajo.add_child(boton_borrar)
	var volver := TEMA.boton("Volver", _cerrar, 110)
	abajo.add_child(volver)
	primer_foco = volver

func abrir() -> void:
	visible = true
	confirmar_borrar = false
	boton_borrar.text = "Borrar progreso"
	_refrescar_teclas()
	primer_foco.grab_focus()

func _fila_slider(texto: String, clave: String) -> HBoxContainer:
	var fila := HBoxContainer.new()
	var l := Label.new()
	l.text = texto
	l.custom_minimum_size = Vector2(90, 0)
	fila.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = float(Juego.datos["opciones"][clave])
	s.custom_minimum_size = Vector2(280, 16)
	s.value_changed.connect(_cambiar_volumen.bind(clave))
	fila.add_child(s)
	return fila

func _cambiar_volumen(valor: float, clave: String) -> void:
	Juego.set_volumen(clave, valor)
	if clave == "efectos":
		Sonido.sfx("apunte")

func _refrescar_teclas() -> void:
	for accion in botones_teclas.keys():
		var b: Button = botones_teclas[accion]
		b.text = "Presiona una tecla..." if accion == esperando_accion else Juego.tecla(accion)

func _esperar_tecla(accion: String) -> void:
	esperando_accion = accion
	_refrescar_teclas()

func _input(event: InputEvent) -> void:
	if esperando_accion == "" or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: InputEventKey = event
		var codigo: int = k.physical_keycode if k.physical_keycode != 0 else k.keycode
		if codigo == KEY_ESCAPE and esperando_accion != "pausa":
			esperando_accion = ""
		else:
			Juego.remapear(esperando_accion, codigo)
			esperando_accion = ""
		_refrescar_teclas()
		get_viewport().set_input_as_handled()

func _restablecer() -> void:
	Juego.restablecer_controles()
	_refrescar_teclas()

func _borrar() -> void:
	if not confirmar_borrar:
		confirmar_borrar = true
		boton_borrar.text = "¿Seguro? Clic otra vez"
		return
	Juego.borrar_progreso()
	confirmar_borrar = false
	boton_borrar.text = "Progreso borrado"

func _cerrar() -> void:
	esperando_accion = ""
	visible = false
	cerrado.emit()
