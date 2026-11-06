extends Node
# =====================================================================
#  JUEGO (autoload). Siempre existe, en cualquier escena.
#  Guarda el progreso, las opciones, las habilidades ganadas, los logros,
#  y hace las transiciones (fundido a negro) entre escenas.
#  Desde cualquier script se usa así:  Juego.jugar_nivel(0)
# =====================================================================

# ---------- Datos del juego (edítalos aquí) ----------
const NOMBRE_JUEGO := "CAMPUS 404"
const PROTAGONISTA := "Kin"
const CREADORES := [
	"Brandon Alexis Castillo Hernández",
	"JADE MABEL JUAREZ ARVIZU",
	"JONATHAN ISAI CHI CHAN",
	"YESHUA DAVID ESTRADA CHERRES",
	"GUSTAVO ANGEL GAMA CRUZ",
	"DYLAN ALDAIR MARMOLEJO SANCHEZ",
]
const MATERIA := "Proyecto de clase · Universidad del Caribe"

const NIVELES := [
	{"id": "nivel_1", "numero": 1, "nombre": "Plaza de Acceso", "acto": "ACTO 1", "hora": "Mañana",
		"escena": "res://niveles/nivel_1_plaza.tscn", "tiempo_objetivo": 150.0, "premio": "dash"},
	{"id": "nivel_2", "numero": 2, "nombre": "Biblioteca", "acto": "ACTO 2", "hora": "Mediodía",
		"escena": "res://niveles/nivel_2_biblioteca.tscn", "tiempo_objetivo": 210.0, "premio": "planeo"},
	{"id": "nivel_3", "numero": 3, "nombre": "Azotea y Núcleo", "acto": "ACTO 3", "hora": "Atardecer",
		"escena": "res://niveles/nivel_3_azotea.tscn", "tiempo_objetivo": 270.0, "premio": ""},
]
# Nivel extra (se desbloquea al terminar el juego)
const NIVEL_EXTRA := {"id": "extra_lago", "numero": 4, "nombre": "El Lago", "acto": "EXTRA", "hora": "Tarde",
	"escena": "res://niveles/nivel_extra_lago.tscn", "tiempo_objetivo": 180.0, "premio": ""}

const MENU_PRINCIPAL := "res://menus/menu_principal.tscn"
const SELECCION := "res://menus/seleccion_nivel.tscn"
const HISTORIA := "res://menus/historia.tscn"
const FIN_JUEGO := "res://menus/fin_juego.tscn"
const RUTA_GUARDADO := "user://savegame.json"

# Controles: acción -> teclas por defecto. La primera tecla se puede cambiar en Opciones.
const CONTROLES_DEFECTO := {
	"izquierda": [KEY_A, KEY_LEFT],
	"derecha": [KEY_D, KEY_RIGHT],
	"saltar": [KEY_SPACE, KEY_W, KEY_UP],
	"dash": [KEY_SHIFT],
	"planear": [KEY_E],
	"interactuar": [KEY_E],
	"lanzar": [KEY_F],
	"pausa": [KEY_ESCAPE, KEY_P],
}
# Control (gamepad), como en la tabla del GDD. Botones con nombre de Xbox:
# A = abajo, B = derecha, X = izquierda, Y = arriba.
const CONTROL_DEFECTO := {
	"izquierda": [JOY_BUTTON_DPAD_LEFT],
	"derecha": [JOY_BUTTON_DPAD_RIGHT],
	"saltar": [JOY_BUTTON_A],
	"dash": [JOY_BUTTON_X],
	"planear": [JOY_BUTTON_Y],
	"interactuar": [JOY_BUTTON_Y],
	"lanzar": [JOY_BUTTON_B],
	"pausa": [JOY_BUTTON_START],
}
const NOMBRES_ACCIONES := {
	"izquierda": "Mover a la izquierda",
	"derecha": "Mover a la derecha",
	"saltar": "Saltar",
	"dash": "Dash",
	"planear": "Planear",
	"interactuar": "Interactuar",
	"lanzar": "Lanzar comida (nivel extra)",
	"pausa": "Pausa",
}

# ---------- Estado ----------
var datos: Dictionary = {}
# Dificultad: "normal" o "extraordinario" (muy difícil; se desbloquea al terminar el juego)
var dificultad: String = "normal"
var historia_pendiente: String = ""     # "intro" o "final"
var ultimo_resultado: Dictionary = {}   # resultado del nivel 3 para la pantalla final
var destino_tras_historia: String = ""

var _capa_transicion: CanvasLayer
var _negro: ColorRect
var _titulo: Label
var _subtitulo: Label
var _en_transicion: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_crear_buses()
	_crear_transicion()
	datos = _datos_nuevos()
	cargar()
	_aplicar_controles()
	_aplicar_opciones()

# ======================================================================
#  NIVELES Y PROGRESO
# ======================================================================
#  DIFICULTAD
# ======================================================================
func extraordinario() -> bool:
	return dificultad == "extraordinario"

func extraordinario_desbloqueado() -> bool:
	return bool(datos["juego_terminado"])

func set_dificultad(d: String) -> void:
	if d == "extraordinario" and not extraordinario_desbloqueado():
		d = "normal"
	dificultad = d

func nombre_dificultad() -> String:
	return "EXTRAORDINARIO" if extraordinario() else "NORMAL"

# Cada dificultad guarda su propio progreso
func _clave_niveles() -> String:
	return "niveles_ext" if extraordinario() else "niveles"

# ======================================================================
func todos_los_niveles() -> Array:
	var lista: Array = NIVELES.duplicate()
	lista.append(NIVEL_EXTRA)
	return lista

func nivel_info(id: String) -> Dictionary:
	for n in todos_los_niveles():
		if n["id"] == id:
			return n
	return NIVELES[0]

func indice_de(id: String) -> int:
	for i in range(NIVELES.size()):
		if NIVELES[i]["id"] == id:
			return i
	return -1

func progreso(id: String) -> Dictionary:
	var clave := _clave_niveles()
	if not datos[clave].has(id):
		datos[clave][id] = {"completado": false, "apuntes": 0, "sellos": 0, "sellos_ids": [],
			"mejor_tiempo": 0.0, "calificacion": 0.0}
	return datos[clave][id]

# MODO PRUEBA (F12 en el menú principal): abre todos los niveles, las
# habilidades y el modo Extraordinario. Sirve para probar o para presentar.
func modo_prueba() -> void:
	datos["todo_abierto"] = true
	datos["juego_terminado"] = true
	datos["intro_vista"] = true
	datos["habilidades"]["dash"] = true
	datos["habilidades"]["planeo"] = true
	guardar()

func nivel_desbloqueado(id: String) -> bool:
	if bool(datos.get("todo_abierto", false)):
		return id != NIVEL_EXTRA["id"] or not extraordinario()
	if id == NIVEL_EXTRA["id"]:
		return bool(datos["juego_terminado"]) and not extraordinario()
	var i := indice_de(id)
	if i <= 0:
		return true
	return bool(progreso(NIVELES[i - 1]["id"])["completado"])

func tiene_habilidad(nombre: String) -> bool:
	return bool(datos["habilidades"].get(nombre, false))

func desbloquear_habilidad(nombre: String) -> void:
	if nombre == "":
		return
	datos["habilidades"][nombre] = true
	guardar()

# Juega un nivel por id ("nivel_1") o por índice (0, 1, 2)
func jugar_nivel(cual) -> void:
	var info: Dictionary = NIVELES[cual] if typeof(cual) == TYPE_INT else nivel_info(str(cual))
	var sub: String = info["hora"] + ("   ·   MODO EXTRAORDINARIO" if extraordinario() else "")
	cambiar_escena(info["escena"], info["acto"] + " · " + info["nombre"].to_upper(), sub)

# "Jugar" del menú: la primera vez muestra la historia; después, el primer nivel pendiente
func jugar_desde_menu() -> void:
	set_dificultad("normal")
	if not bool(datos["intro_vista"]):
		ver_historia("intro", NIVELES[0]["escena"])
		return
	for n in NIVELES:
		if not bool(progreso(n["id"])["completado"]):
			jugar_nivel(n["id"])
			return
	cambiar_escena(SELECCION)

func siguiente_de(id: String) -> String:
	var i := indice_de(id)
	if i >= 0 and i + 1 < NIVELES.size():
		return NIVELES[i + 1]["id"]
	return ""

func ver_historia(cual: String, destino: String) -> void:
	historia_pendiente = cual
	destino_tras_historia = destino
	cambiar_escena(HISTORIA)

func ir_menu() -> void:
	cambiar_escena(MENU_PRINCIPAL)

# ======================================================================
#  CALIFICACIÓN (GDD: apuntes 0-4, sellos 0-3, tiempo 0-3)
# ======================================================================
func calcular_calificacion(apuntes: int, apuntes_total: int, sellos: int, tiempo: float, objetivo: float) -> Dictionary:
	var pa: float = 4.0 * float(apuntes) / float(maxi(apuntes_total, 1))
	var ps: float = minf(float(sellos), 3.0)
	var pt: float = clampf(3.0 * (2.0 - tiempo / objetivo), 0.0, 3.0)
	return {"apuntes": pa, "sellos": ps, "tiempo": pt, "total": snappedf(pa + ps + pt, 0.1)}

func etiqueta(total: float) -> String:
	if total >= 9.0:
		return "Excelente"
	if total >= 7.0:
		return "Notable"
	if total >= 6.0:
		return "Aprobado"
	return "Para recuperar"

# El nivel llama esto al terminar. Devuelve todo lo que la pantalla final necesita.
func registrar_resultado(id: String, r: Dictionary) -> Dictionary:
	var info := nivel_info(id)
	var cal := calcular_calificacion(r["apuntes"], r["apuntes_total"], r["sellos"], r["tiempo"], info["tiempo_objetivo"])
	var p := progreso(id)
	var primera_vez: bool = not bool(p["completado"])
	p["completado"] = true
	p["apuntes"] = maxi(int(p["apuntes"]), int(r["apuntes"]))
	p["apuntes_total"] = int(r["apuntes_total"])
	p["sellos_total"] = int(r["sellos_total"])
	# Sellos: se juntan los de todas las partidas (sin repetir). JSON guarda
	# los números como decimales, por eso se convierten a int.
	var ids: Array = []
	for s in p["sellos_ids"] + r["sellos_ids"]:
		if not ids.has(int(s)):
			ids.append(int(s))
	p["sellos_ids"] = ids
	p["sellos"] = ids.size()
	if float(p["mejor_tiempo"]) <= 0.0 or float(r["tiempo"]) < float(p["mejor_tiempo"]):
		p["mejor_tiempo"] = float(r["tiempo"])
	p["calificacion"] = maxf(float(p["calificacion"]), float(cal["total"]))

	# Premio del nivel (habilidad)
	var premio: String = info.get("premio", "") if not extraordinario() else ""
	if premio != "":
		datos["habilidades"][premio] = true

	# Logros
	var nuevos: Array = []
	if float(cal["total"]) >= 10.0 and not datos["logros"]["entrega_perfecta"]:
		datos["logros"]["entrega_perfecta"] = true
		nuevos.append("Entrega perfecta")
	if int(r["muertes"]) == 0 and not datos["logros"]["sin_tropiezos"]:
		datos["logros"]["sin_tropiezos"] = true
		nuevos.append("Sin tropiezos")
	if total_sellos("niveles") >= 9 and not datos["logros"]["coleccionista"]:
		datos["logros"]["coleccionista"] = true
		nuevos.append("Coleccionista")

	if id == NIVELES[NIVELES.size() - 1]["id"]:
		if extraordinario():
			datos["extraordinario_terminado"] = true
			if not datos["logros"]["extraordinario"]:
				datos["logros"]["extraordinario"] = true
				nuevos.append("Extraordinario aprobado")
		else:
			datos["juego_terminado"] = true
	guardar()
	return {"calificacion": cal, "etiqueta": etiqueta(cal["total"]), "logros_nuevos": nuevos,
		"premio": premio, "primera_vez": primera_vez, "siguiente": siguiente_de(id)}

func total_sellos(clave: String = "") -> int:
	if clave == "":
		clave = _clave_niveles()
	var t := 0
	for n in NIVELES:
		if datos[clave].has(n["id"]):
			t += int(datos[clave][n["id"]]["sellos"])
	return t

# Promedio de las mejores calificaciones de los 3 niveles
func calificacion_final() -> float:
	var suma := 0.0
	for n in NIVELES:
		suma += float(progreso(n["id"])["calificacion"])
	return snappedf(suma / float(NIVELES.size()), 0.1)

func formato_tiempo(segundos: float) -> String:
	var s: int = int(segundos)
	return "%02d:%02d" % [floori(s / 60.0), s % 60]

# ======================================================================
#  GUARDADO  (user://savegame.json)
# ======================================================================
func _datos_nuevos() -> Dictionary:
	return {
		"version": 1,
		"niveles": {},
		"niveles_ext": {},
		"habilidades": {"dash": false, "planeo": false},
		"opciones": {"musica": 0.8, "efectos": 1.0, "pantalla_completa": false, "controles": {}},
		"logros": {"entrega_perfecta": false, "sin_tropiezos": false, "coleccionista": false, "extraordinario": false},
		"intro_vista": false,
		"juego_terminado": false,
		"extraordinario_terminado": false,
		"todo_abierto": false,
	}

func guardar() -> void:
	var f := FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo guardar la partida.")
		return
	f.store_string(JSON.stringify(datos, "  "))

func cargar() -> void:
	if not FileAccess.file_exists(RUTA_GUARDADO):
		return
	var f := FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	if f == null:
		return
	var leido = JSON.parse_string(f.get_as_text())
	if typeof(leido) != TYPE_DICTIONARY:
		return
	# Mezclar con los datos nuevos por si faltan campos de versiones anteriores
	var base := _datos_nuevos()
	for k in base.keys():
		if leido.has(k):
			if typeof(base[k]) == TYPE_DICTIONARY and typeof(leido[k]) == TYPE_DICTIONARY:
				for k2 in leido[k].keys():
					base[k][k2] = leido[k][k2]
			else:
				base[k] = leido[k]
	datos = base

func borrar_progreso() -> void:
	var opciones: Dictionary = datos["opciones"].duplicate(true)
	datos = _datos_nuevos()
	datos["opciones"] = opciones
	dificultad = "normal"
	guardar()

# ======================================================================
#  OPCIONES: volumen, pantalla completa, controles
# ======================================================================
func _crear_buses() -> void:
	for nombre in ["Musica", "Efectos"]:
		if AudioServer.get_bus_index(nombre) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, nombre)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")

func _aplicar_opciones() -> void:
	set_volumen("musica", float(datos["opciones"]["musica"]), false)
	set_volumen("efectos", float(datos["opciones"]["efectos"]), false)
	set_pantalla_completa(bool(datos["opciones"]["pantalla_completa"]), false)

func set_volumen(cual: String, valor: float, guardar_ya: bool = true) -> void:
	datos["opciones"][cual] = clampf(valor, 0.0, 1.0)
	var bus := AudioServer.get_bus_index("Musica" if cual == "musica" else "Efectos")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(valor, 0.0001)))
		AudioServer.set_bus_mute(bus, valor <= 0.001)
	if guardar_ya:
		guardar()

func set_pantalla_completa(activar: bool, guardar_ya: bool = true) -> void:
	datos["opciones"]["pantalla_completa"] = activar
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if activar else DisplayServer.WINDOW_MODE_WINDOWED)
	if guardar_ya:
		guardar()

func _aplicar_controles() -> void:
	for accion in CONTROLES_DEFECTO.keys():
		if not InputMap.has_action(accion):
			InputMap.add_action(accion)
		InputMap.action_erase_events(accion)
		var teclas: Array = CONTROLES_DEFECTO[accion].duplicate()
		var personal: Dictionary = datos["opciones"]["controles"]
		if personal.has(accion):
			teclas[0] = int(personal[accion])
		for t in teclas:
			var ev := InputEventKey.new()
			ev.physical_keycode = t
			InputMap.action_add_event(accion, ev)
		# Control: botones y stick izquierdo
		for b in CONTROL_DEFECTO.get(accion, []):
			var evb := InputEventJoypadButton.new()
			evb.button_index = b
			InputMap.action_add_event(accion, evb)
		if accion == "izquierda" or accion == "derecha":
			var eje := InputEventJoypadMotion.new()
			eje.axis = JOY_AXIS_LEFT_X
			eje.axis_value = -1.0 if accion == "izquierda" else 1.0
			InputMap.action_add_event(accion, eje)

func remapear(accion: String, tecla: int) -> void:
	datos["opciones"]["controles"][accion] = tecla
	_aplicar_controles()
	guardar()

func restablecer_controles() -> void:
	datos["opciones"]["controles"] = {}
	_aplicar_controles()
	guardar()

# Texto de la tecla principal de una acción ("E", "Shift"...)
func tecla(accion: String) -> String:
	var personal: Dictionary = datos["opciones"]["controles"]
	var codigo: int = int(personal[accion]) if personal.has(accion) else int(CONTROLES_DEFECTO[accion][0])
	return OS.get_keycode_string(codigo)

# ======================================================================
#  TRANSICIONES (fundido a negro con título opcional)
# ======================================================================
func _crear_transicion() -> void:
	_capa_transicion = CanvasLayer.new()
	_capa_transicion.layer = 100
	add_child(_capa_transicion)
	_negro = ColorRect.new()
	_negro.color = Color(0.04, 0.04, 0.08, 1.0)
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_negro.modulate.a = 0.0
	_capa_transicion.add_child(_negro)
	_titulo = Label.new()
	_titulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_titulo.add_theme_font_size_override("font_size", 22)
	_titulo.add_theme_color_override("font_color", Color("#F5C242"))
	_negro.add_child(_titulo)
	_subtitulo = Label.new()
	_subtitulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_subtitulo.offset_top = 46
	_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_subtitulo.add_theme_font_size_override("font_size", 14)
	_subtitulo.add_theme_color_override("font_color", Color("#F4F1EA"))
	_negro.add_child(_subtitulo)

func cambiar_escena(ruta: String, titulo: String = "", subtitulo: String = "") -> void:
	if _en_transicion:
		return
	_en_transicion = true
	_negro.mouse_filter = Control.MOUSE_FILTER_STOP
	_titulo.text = ""
	_subtitulo.text = ""
	var t := create_tween()
	t.tween_property(_negro, "modulate:a", 1.0, 0.35)
	await t.finished
	get_tree().paused = false
	if titulo != "":
		_titulo.text = titulo
		_subtitulo.text = subtitulo
		await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file(ruta)
	await get_tree().process_frame
	await get_tree().process_frame
	_titulo.text = ""
	_subtitulo.text = ""
	var t2 := create_tween()
	t2.tween_property(_negro, "modulate:a", 0.0, 0.35)
	await t2.finished
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_en_transicion = false

func en_transicion() -> bool:
	return _en_transicion

# Destello blanco (lo usa el final del jefe)
func destello(duracion: float = 0.6) -> void:
	var blanco := ColorRect.new()
	blanco.color = Color(1, 1, 1, 0.9)
	blanco.set_anchors_preset(Control.PRESET_FULL_RECT)
	blanco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa_transicion.add_child(blanco)
	var t := create_tween()
	t.tween_property(blanco, "modulate:a", 0.0, duracion)
	t.tween_callback(blanco.queue_free)
