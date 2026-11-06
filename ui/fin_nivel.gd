extends CanvasLayer
# PANTALLA DE FIN DE NIVEL: apuntes, sellos, tiempo y calificación del 0 al 10.
# Botones: Siguiente nivel, Repetir y Menú. La crea nivel_base.gd.

const TEMA := preload("res://ui/tema.gd")

var id_nivel: String = ""
var siguiente: String = ""

func _ready() -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS

func mostrar(info: Dictionary, stats: Dictionary, r: Dictionary) -> void:
	id_nivel = info["id"]
	siguiente = r["siguiente"]
	get_tree().paused = true
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.7)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var panel := Panel.new()
	panel.theme = TEMA.crear()
	panel.position = Vector2(140, 14)
	panel.size = Vector2(360, 332)
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.position = Vector2(16, 10)
	caja.size = Vector2(328, 312)
	caja.add_theme_constant_override("separation", 3)
	panel.add_child(caja)

	caja.add_child(TEMA.titulo("¡NIVEL COMPLETADO!", 20))
	var sub := TEMA.titulo(str(info["acto"]) + " · " + str(info["nombre"]).to_upper() + ("  ·  EXTRAORDINARIO" if Juego.extraordinario() else ""), 12, TEMA.BLANCO)
	caja.add_child(sub)
	if bool(stats.get("usa_fragmento", true)):
		caja.add_child(_linea("Fragmento del Códice %d/3 recuperado" % int(info["numero"]), TEMA.TURQUESA))

	var c: Dictionary = r["calificacion"]
	caja.add_child(_fila("Apuntes", "%d/%d" % [stats["apuntes"], stats["apuntes_total"]], c["apuntes"], 4.0))
	caja.add_child(_fila("Sellos de honor", "%d/%d" % [stats["sellos"], stats["sellos_total"]], c["sellos"], 3.0))
	caja.add_child(_fila("Tiempo", "%s (meta %s)" % [Juego.formato_tiempo(stats["tiempo"]), Juego.formato_tiempo(info["tiempo_objetivo"])], c["tiempo"], 3.0))
	caja.add_child(_linea("Reapariciones: %d" % int(stats["muertes"]), TEMA.BLANCO))

	var cal := TEMA.titulo("CALIFICACIÓN: %.1f / 10  ·  %s" % [c["total"], r["etiqueta"]], 15, TEMA.AMARILLO)
	caja.add_child(cal)

	match str(r["premio"]):
		"dash":
			caja.add_child(_linea("¡DASH DESBLOQUEADO! Presiona %s para impulsarte." % Juego.tecla("dash"), Color("#7CFFB2")))
		"planeo":
			caja.add_child(_linea("¡PLANEO DESBLOQUEADO! En el aire presiona %s." % Juego.tecla("planear"), Color("#7CFFB2")))
	for logro in r["logros_nuevos"]:
		caja.add_child(_linea("Logro: " + str(logro), TEMA.MAGENTA))

	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 6)
	caja.add_child(botones)
	var primero: Button = null
	if siguiente != "":
		primero = TEMA.boton("Siguiente nivel", _siguiente, 110)
		botones.add_child(primero)
	var rep := TEMA.boton("Repetir", _repetir, 90)
	botones.add_child(rep)
	botones.add_child(TEMA.boton("Menú", _menu, 80))
	if primero == null:
		primero = rep
	primero.grab_focus()

func _linea(texto: String, color: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(328, 0)
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", color)
	return l

func _fila(nombre: String, valor: String, puntos: float, maximo: float) -> HBoxContainer:
	var f := HBoxContainer.new()
	var a := Label.new()
	a.text = nombre
	a.custom_minimum_size = Vector2(110, 0)
	a.add_theme_font_size_override("font_size", 11)
	f.add_child(a)
	var b := Label.new()
	b.text = valor
	b.custom_minimum_size = Vector2(140, 0)
	b.add_theme_font_size_override("font_size", 11)
	f.add_child(b)
	var p := Label.new()
	p.text = "+%.1f / %d" % [puntos, int(maximo)]
	p.add_theme_font_size_override("font_size", 11)
	p.add_theme_color_override("font_color", TEMA.AMARILLO)
	f.add_child(p)
	return f

func _siguiente() -> void:
	Juego.jugar_nivel(siguiente)

func _repetir() -> void:
	Juego.jugar_nivel(id_nivel)

func _menu() -> void:
	Juego.ir_menu()
