extends Control
# =====================================================================
#  FIN DEL JUEGO: calificación total (promedio de los 3 niveles),
#  calificación de cada nivel, logros y botones de Créditos y Menú.
# =====================================================================

const TEMA := preload("res://ui/tema.gd")
const FONDO := preload("res://fondos/fondo_campus.gd")

func _ready() -> void:
	theme = TEMA.crear()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo = FONDO.new()
	fondo.variante = "plaza"
	fondo.ancho_nivel = 640.0
	add_child(fondo)
	var oscuro := ColorRect.new()
	oscuro.color = Color(0, 0, 0, 0.6)
	oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(oscuro)

	var caja := VBoxContainer.new()
	caja.position = Vector2(80, 12)
	caja.size = Vector2(480, 300)
	caja.add_theme_constant_override("separation", 4)
	add_child(caja)
	var ext: bool = Juego.extraordinario()
	caja.add_child(TEMA.titulo("¡EXTRAORDINARIO APROBADO!" if ext else "¡SISTEMA RESTAURADO!", 26 if ext else 26, TEMA.MAGENTA if ext else TEMA.AMARILLO))
	caja.add_child(TEMA.titulo("Sobreviviste al modo más difícil del campus." if ext else "¡Felicidades, Yoshua! Código recuperado. MISIÓN COMPLETADA.", 11, TEMA.BLANCO))
	var total := Juego.calificacion_final()
	caja.add_child(TEMA.titulo("CALIFICACIÓN FINAL: %.1f / 10  ·  %s" % [total, Juego.etiqueta(total)], 16, TEMA.AMARILLO))

	for n in Juego.NIVELES:
		var p := Juego.progreso(n["id"])
		var linea := "%s · %s:   %.1f   (sellos %d/3, mejor tiempo %s)" % [n["acto"], n["nombre"], float(p["calificacion"]),
			int(p["sellos"]), Juego.formato_tiempo(float(p["mejor_tiempo"]))]
		caja.add_child(TEMA.titulo(linea, 11, TEMA.BLANCO))

	var l: Dictionary = Juego.datos["logros"]
	var logros := "Logros:  %s Entrega perfecta   %s Sin tropiezos   %s Coleccionista   %s Extraordinario" % [
		"[X]" if l["entrega_perfecta"] else "[ ]", "[X]" if l["sin_tropiezos"] else "[ ]", "[X]" if l["coleccionista"] else "[ ]",
		"[X]" if l["extraordinario"] else "[ ]"]
	caja.add_child(TEMA.titulo(logros, 11, TEMA.MAGENTA))
	if not Juego.ultimo_resultado.is_empty():
		var s: Dictionary = Juego.ultimo_resultado["stats"]
		caja.add_child(TEMA.titulo("Nivel 3 en esta partida: %d/%d apuntes, %d/%d sellos, %s" % [
			s["apuntes"], s["apuntes_total"], s["sellos"], s["sellos_total"], Juego.formato_tiempo(s["tiempo"])], 10, Color("#C9D1D3")))
	if not ext:
		caja.add_child(TEMA.titulo("¡Desbloqueaste el MODO EXTRAORDINARIO y el nivel extra EL LAGO!", 11, Color("#7CFFB2")))
	else:
		caja.add_child(TEMA.titulo("Ya puedes presumir que pasaste el Extraordinario.", 11, Color("#7CFFB2")))

	var botones := HBoxContainer.new()
	botones.position = Vector2(160, 316)
	botones.size = Vector2(320, 28)
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 10)
	add_child(botones)
	var cred := TEMA.boton("Créditos", func(): Juego.cambiar_escena("res://menus/creditos.tscn"), 140)
	botones.add_child(cred)
	botones.add_child(TEMA.boton("Menú", func(): Juego.ir_menu(), 140))
	cred.grab_focus()
	Sonido.musica("victoria")
