extends Control
# =====================================================================
#  SELECCIÓN DE NIVEL: una tarjeta por nivel con calificación, apuntes,
#  mejor tiempo y sellos. Los niveles bloqueados se ven cubiertos de ruido.
# =====================================================================

const TEMA := preload("res://ui/tema.gd")
const FONDO := preload("res://fondos/fondo_campus.gd")

var primero: Button = null

func _ready() -> void:
	theme = TEMA.crear()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo = FONDO.new()
	fondo.variante = "biblioteca"
	fondo.ancho_nivel = 640.0
	add_child(fondo)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.45)
	oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(oscuro)

	var ext: bool = Juego.extraordinario()
	var t := TEMA.titulo("SELECCIONA UN NIVEL" + ("  ·  EXTRAORDINARIO" if ext else ""), 18, TEMA.MAGENTA if ext else TEMA.AMARILLO)
	t.position = Vector2(0, 10)
	t.size = Vector2(640, 26)
	add_child(t)
	if ext:
		var aviso := TEMA.titulo("2 vasos · sin cafés (las farolas curan) · pinchos · enemigos con más ataques · jefe con 2.ª y 3.ª fase", 9, TEMA.BLANCO)
		aviso.position = Vector2(0, 30)
		aviso.size = Vector2(640, 12)
		add_child(aviso)

	var fila := HBoxContainer.new()
	fila.position = Vector2(16, 44)
	fila.size = Vector2(608, 220)
	fila.add_theme_constant_override("separation", 8)
	add_child(fila)
	var lista: Array = Juego.NIVELES if ext else Juego.todos_los_niveles()
	if ext:
		fila.position.x = 90.0
	for info in lista:
		fila.add_child(_tarjeta(info))

	var l: Dictionary = Juego.datos["logros"]
	var logros := Label.new()
	logros.text = "LOGROS:  %s Entrega perfecta   %s Sin tropiezos   %s Coleccionista (%d/9)   %s Extraordinario" % [
		"[X]" if l["entrega_perfecta"] else "[ ]", "[X]" if l["sin_tropiezos"] else "[ ]",
		"[X]" if l["coleccionista"] else "[ ]", Juego.total_sellos("niveles"), "[X]" if l["extraordinario"] else "[ ]"]
	logros.position = Vector2(0, 276)
	logros.size = Vector2(640, 14)
	logros.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logros.add_theme_font_size_override("font_size", 10)
	logros.add_theme_color_override("font_color", TEMA.AMARILLO)
	add_child(logros)

	var volver := TEMA.boton("Volver", func(): Juego.ir_menu(), 140)
	volver.position = Vector2(250, 304)
	add_child(volver)
	# Cambiar de dificultad (solo si ya se desbloqueó el Extraordinario)
	if Juego.extraordinario_desbloqueado():
		var cambio := TEMA.boton("Ir a Normal" if ext else "Ir a Extraordinario", _cambiar_dificultad, 150)
		cambio.position = Vector2(470, 304)
		add_child(cambio)
	if primero == null:
		primero = volver
	primero.grab_focus()
	Sonido.musica("menu")

func _cambiar_dificultad() -> void:
	Juego.set_dificultad("normal" if Juego.extraordinario() else "extraordinario")
	get_tree().reload_current_scene()

func _tarjeta(info: Dictionary) -> Control:
	var abierto := Juego.nivel_desbloqueado(info["id"])
	var p := Juego.progreso(info["id"])
	var panel := Panel.new()
	if Juego.extraordinario():
		var borde := StyleBoxFlat.new()
		borde.bg_color = Color(0.08, 0.03, 0.08, 0.94)
		borde.border_color = TEMA.MAGENTA
		borde.set_border_width_all(2)
		borde.set_corner_radius_all(3)
		panel.add_theme_stylebox_override("panel", borde)
	panel.custom_minimum_size = Vector2(146, 220)
	var caja := VBoxContainer.new()
	caja.position = Vector2(8, 8)
	caja.size = Vector2(130, 204)
	caja.add_theme_constant_override("separation", 3)
	panel.add_child(caja)

	var titulo := Label.new()
	titulo.text = str(info["acto"])
	titulo.add_theme_color_override("font_color", TEMA.TURQUESA)
	titulo.add_theme_font_size_override("font_size", 10)
	caja.add_child(titulo)
	var nombre := Label.new()
	nombre.text = str(info["nombre"]).to_upper()
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nombre.custom_minimum_size = Vector2(130, 30)
	nombre.add_theme_font_size_override("font_size", 13)
	nombre.add_theme_color_override("font_color", TEMA.AMARILLO)
	caja.add_child(nombre)
	caja.add_child(_dato("Hora: " + str(info["hora"])))
	if bool(p["completado"]):
		var cal := float(p["calificacion"])
		caja.add_child(_dato("Calificación: %.1f" % cal))
		caja.add_child(_dato(Juego.etiqueta(cal)))
		caja.add_child(_dato("Apuntes: %d/%d" % [int(p["apuntes"]), int(p.get("apuntes_total", 40))]))
		caja.add_child(_dato("Mejor tiempo: " + Juego.formato_tiempo(float(p["mejor_tiempo"]))))
		caja.add_child(_dato("Sellos: %d/%d" % [int(p["sellos"]), int(p.get("sellos_total", 3))]))
	else:
		caja.add_child(_dato("Sin completar"))
		caja.add_child(_dato("Meta: " + Juego.formato_tiempo(float(info["tiempo_objetivo"]))))
	var espacio := Control.new()
	espacio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	caja.add_child(espacio)
	var b := TEMA.boton("Jugar" if abierto else "Bloqueado", func(): Juego.jugar_nivel(info["id"]), 130)
	b.disabled = not abierto
	caja.add_child(b)
	if abierto and primero == null:
		primero = b
	if not abierto:
		var ruido := Ruido.new()
		ruido.size = Vector2(146, 190)
		ruido.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(ruido)
		var aviso := Label.new()
		aviso.text = "BLOQUEADO"
		aviso.position = Vector2(0, 80)
		aviso.size = Vector2(146, 20)
		aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		aviso.add_theme_color_override("font_color", TEMA.BLANCO)
		aviso.add_theme_color_override("font_outline_color", TEMA.NEGRO)
		aviso.add_theme_constant_override("outline_size", 5)
		panel.add_child(aviso)
	return panel

func _dato(texto: String) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", 10)
	return l


# Ruido de glitch encima de los niveles bloqueados
class Ruido extends Control:
	var tiempo: float = 0.0

	func _process(delta: float) -> void:
		tiempo += delta
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.04, 0.08, 0.85))
		var semilla: int = int(tiempo * 10.0)
		for k in range(120):
			var h: int = (k * 97 + semilla * 23) % 4001
			draw_rect(Rect2(float(h % int(size.x)), float((h * 7) % int(size.y)), 3, 2), Color(0.85, 0.1, 0.55, 0.7) if k % 2 == 0 else Color(0.16, 0.9, 1.0, 0.7))
