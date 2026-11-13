extends CanvasLayer
# =====================================================================
#  HUD del GDD: energía (3 vasos de café), fragmento, apuntes, tiempo,
#  nombre del nivel, habilidades (dash / planeo), avisos y barra del jefe.
#  Lo crea nivel_base.gd. Lee los datos del nivel y del jugador cada frame.
# =====================================================================

var nivel: Node = null
var jugador = null   # el jugador (sin tipo para poder leer sus variables)

var dibujo: Control
var lbl_apuntes: Label
var lbl_tiempo: Label
var lbl_nivel: Label
var lbl_fragmento: Label
var lbl_mision: Label
var lbl_interaccion: Label
var lbl_comida: Label
var lbl_aviso: Label
var lbl_anuncio: Label
var caja_jefe: Control
var lbl_jefe: Label
var barra_jefe: ColorRect
var flash: ColorRect

var lbl_debug: Label          # F3: muestra la posición de Yoshua (para diseñar niveles)

var aviso_timer: float = 0.0
var anuncio_timer: float = 0.0

func _ready() -> void:
	layer = 10
	dibujo = Dibujo.new()
	dibujo.hud = self
	dibujo.set_anchors_preset(Control.PRESET_FULL_RECT)
	dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dibujo)

	_etiqueta("ENERGÍA", Vector2(8, 4), 11, Color("#F4F1EA"))
	lbl_fragmento = _etiqueta("FRAGMENTO 0/1", Vector2(8, 40), 11, Color("#F4F1EA"))
	lbl_mision = _etiqueta("", Vector2(8, 72), 10, Color("#7CFFB2"))
	lbl_interaccion = _etiqueta("", Vector2(190, 298), 11, Color("#F5C242"))
	lbl_comida = _etiqueta("", Vector2(8, 290), 11, Color("#F2994A"))

	lbl_apuntes = _etiqueta("", Vector2(0, 4), 12, Color("#F5C242"))
	lbl_tiempo = _etiqueta("", Vector2(0, 20), 12, Color("#F4F1EA"))
	lbl_nivel = _etiqueta("", Vector2(0, 36), 10, Color("#F4F1EA"))
	for l in [lbl_apuntes, lbl_tiempo, lbl_nivel]:
		l.size = Vector2(632, 16)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	lbl_debug = _etiqueta("", Vector2(8, 60), 10, Color("#7CFFB2"))
	lbl_debug.visible = false

	lbl_aviso = _etiqueta("", Vector2(0, 92), 14, Color("#F5C242"))
	lbl_aviso.size = Vector2(640, 20)
	lbl_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_anuncio = _etiqueta("", Vector2(20, 116), 15, Color("#7CFFB2"))
	lbl_anuncio.size = Vector2(600, 80)
	lbl_anuncio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_anuncio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_anuncio.add_theme_constant_override("outline_size", 6)

	# Barra del jefe
	caja_jefe = Control.new()
	caja_jefe.position = Vector2(220, 322)       # abajo al centro, para no tapar al jefe
	caja_jefe.visible = false
	add_child(caja_jefe)
	lbl_jefe = _etiqueta("", Vector2.ZERO, 11, Color("#D81B8C"), caja_jefe)
	lbl_jefe.size = Vector2(200, 14)
	lbl_jefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var borde := ColorRect.new()                 # marco de la barra
	borde.position = Vector2(-2, 14)
	borde.size = Vector2(204, 12)
	borde.color = Color("#F4F1EA")
	caja_jefe.add_child(borde)
	var fondo := ColorRect.new()
	fondo.position = Vector2(0, 16)
	fondo.size = Vector2(200, 8)
	fondo.color = Color("#0B0B14")
	caja_jefe.add_child(fondo)
	barra_jefe = ColorRect.new()                 # relleno (cambia de ancho)
	barra_jefe.position = Vector2(0, 16)
	barra_jefe.size = Vector2(200, 8)
	barra_jefe.color = Color("#D81B8C")
	caja_jefe.add_child(barra_jefe)

	flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	if jugador:
		jugador.danado.connect(_on_danado)

func _etiqueta(texto: String, pos: Vector2, tam: int, col: Color, padre: Node = null) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = pos
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color("#0B0B14"))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if padre == null:
		add_child(l)
	else:
		padre.add_child(l)
	return l

func _process(delta: float) -> void:
	if nivel == null or jugador == null:
		return
	lbl_apuntes.text = "APUNTES %d/%d" % [int(nivel.get("apuntes_recogidos")), int(nivel.get("apuntes_total"))]
	lbl_tiempo.text = "TIEMPO " + Juego.formato_tiempo(float(nivel.get("tiempo")))
	var info: Dictionary = nivel.get("info")
	lbl_nivel.text = ("NIVEL %d: %s" % [int(info["numero"]), str(info["nombre"]).to_upper()]) if info["acto"] != "EXTRA" else "EXTRA: " + str(info["nombre"]).to_upper()
	if Juego.extraordinario():
		lbl_nivel.text += "\n[EXTRAORDINARIO]"
	lbl_fragmento.text = "Fragmentos recuperados: %d/%d" % [Juego.fragmentos_recuperados(info["id"], bool(nivel.get("fragmento_obtenido"))), Juego.NIVELES.size()]
	lbl_mision.text = "MISIÓN: " + nivel.mision_actual()
	lbl_interaccion.text = "[%s] Interactuar" % Juego.tecla("interactuar") if is_instance_valid(jugador.objeto_cercano) and jugador.is_on_floor() else ""
	lbl_fragmento.visible = bool(nivel.get("usa_fragmento"))
	lbl_comida.visible = jugador.lanzar_habilitado and jugador.comida_vista
	lbl_comida.text = "COMIDA x%d   [%s] lanzar" % [jugador.comida, Juego.tecla("lanzar")]
	if aviso_timer > 0.0:
		aviso_timer -= delta
		if aviso_timer <= 0.0:
			lbl_aviso.text = ""
	if anuncio_timer > 0.0:
		anuncio_timer -= delta
		if anuncio_timer <= 0.0:
			lbl_anuncio.text = ""
	if flash.color.a > 0.0:
		flash.color.a = maxf(flash.color.a - delta * 3.0, 0.0)
	if lbl_debug.visible:
		var p: Vector2 = jugador.global_position
		lbl_debug.text = "x: %d   y: %d   (pantalla %d)" % [int(p.x), int(p.y), int(p.x / 640.0) + 1]
	dibujo.queue_redraw()

# F3 muestra / oculta la posición de Yoshua. Sirve para saber qué números
# poner en construir() cuando diseñen o muevan cosas del nivel.
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		lbl_debug.visible = not lbl_debug.visible

func aviso(texto: String, duracion: float = 1.4) -> void:
	lbl_aviso.text = texto
	aviso_timer = duracion

func anuncio(texto: String, duracion: float = 3.5) -> void:
	lbl_anuncio.text = texto
	anuncio_timer = duracion

func mostrar_jefe(nombre: String, vida: int, maxima: int) -> void:
	caja_jefe.visible = true
	lbl_jefe.text = nombre
	vida_jefe(vida, maxima)

func vida_jefe(vida: int, maxima: int) -> void:
	barra_jefe.size.x = 200.0 * float(vida) / float(maxi(maxima, 1))

func ocultar_jefe() -> void:
	caja_jefe.visible = false

func _on_danado() -> void:
	flash.color = Color(1, 1, 1, 0.55)


# ----------------- Íconos dibujados -----------------
class Dibujo extends Control:
	var hud = null

	func _draw() -> void:
		var j = hud.jugador
		var n = hud.nivel
		if j == null or n == null:
			return
		draw_rect(Rect2(0, 0, 640, 88), Color(0.025, 0.04, 0.07, 0.82))
		draw_line(Vector2(0, 87), Vector2(640, 87), Color(0.12, 0.71, 0.76, 0.5))
		# Vasos de café (energía)
		for i in range(j.energia_maxima):
			var x: float = 8.0 + i * 18.0
			var lleno: bool = i < j.energia
			draw_rect(Rect2(x, 20, 12, 15), Color("#F4F1EA"))
			draw_rect(Rect2(x + 1, 22, 10, 12), Color("#6B3E1F") if lleno else Color("#2A2A33"))
			draw_rect(Rect2(x + 12, 24, 3, 6), Color("#F4F1EA"), false, 1.0)
			if lleno:
				draw_rect(Rect2(x + 3, 26, 6, 2), Color("#F2C08A"))
		# Fragmento del Códice
		if n.get("usa_fragmento"):
			var tiene: bool = n.get("fragmento_obtenido")
			var c: Color = Color("#29E7FF") if tiene else Color("#5A6366")
			var o := Vector2(210, 42)
			draw_rect(Rect2(o, Vector2(12, 12)), c, false, 1.0)
			draw_rect(Rect2(o + Vector2(3, 3), Vector2(6, 6)), c)
			draw_rect(Rect2(o + Vector2(5, 5), Vector2(2, 2)), Color("#0B0B14"))
		# Credencial
		if j.tiene_credencial:
			draw_rect(Rect2(8, 58, 18, 12), Color("#F5C242"))
			draw_rect(Rect2(10, 60, 6, 8), Color("#F4F1EA"))
			draw_rect(Rect2(18, 61, 6, 2), Color("#0B0B14"))
			draw_rect(Rect2(18, 65, 4, 2), Color("#0B0B14"))
		# Habilidades (abajo a la izquierda)
		var fuente := ThemeDB.fallback_font
		var x0: float = 8.0
		if j.dash_habilitado:
			var listo: bool = j.dash_disponible and j.dash_tiempo <= 0.0
			_caja(Rect2(x0, 322, 58, 30), "DASH", "[%s]" % Juego.tecla("dash"), Color("#1FB6C1") if listo else Color("#3A4A50"), fuente)
			x0 += 64.0
		if j.planeo_habilitado:
			var col: Color = Color("#F5C242")
			var llenado: float = 1.0
			if j.planeando:
				col = Color("#29E7FF")
				llenado = j.planeo_restante / j.duracion_planeo
			elif j.planeo_en_recarga:
				col = Color("#6E5A2A")
				llenado = 1.0 - j.planeo_recarga_restante / j.recarga_planeo
			_caja(Rect2(x0, 322, 70, 30), "PLANEO", "[%s]" % Juego.tecla("planear"), col, fuente)
			draw_rect(Rect2(x0 + 4, 346, 62.0 * clampf(llenado, 0.0, 1.0), 3), Color("#F4F1EA"))

	func _caja(r: Rect2, titulo: String, tecla: String, c: Color, fuente: Font) -> void:
		draw_rect(r, Color(0, 0, 0, 0.55))
		draw_rect(r, c, false, 2.0)
		draw_string(fuente, r.position + Vector2(4, 12), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, c)
		draw_string(fuente, r.position + Vector2(4, 24), tecla, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#F4F1EA"))
