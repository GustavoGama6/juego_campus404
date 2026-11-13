extends Control
# =====================================================================
#  VIÑETAS DE LA HISTORIA: 3 al inicio y 1 al final (GDD).
#  Espacio / Enter / clic = siguiente. Esc = saltar.
#  Para usar ilustraciones propias: res://arte/vineta_intro_1.png,
#  vineta_intro_2.png, vineta_intro_3.png y vineta_final_1.png (560 x 210 px).
#  Los textos se editan aquí abajo.
# =====================================================================

const TEMA := preload("res://ui/tema.gd")
const ARTE := preload("res://objetos/arte.gd")

const INTRO := [
	{"titulo": "ERROR 404: El Código Perdido", "dibujo": "campus",
		"texto": "Eres Yoshua, un estudiante de la Universidad del Caribe, en Cancún. Lo que parecía un día normal de clases se convierte en una aventura inesperada cuando un misterioso ERROR 404 comienza a afectar los sistemas digitales de la universidad."},
	{"titulo": "ARCHIVOS DESAPARECIDOS", "dibujo": "glitch",
		"texto": "Los archivos desaparecen, los sistemas dejan de funcionar y un código esencial ha quedado fragmentado y disperso por diferentes puntos del campus. Tu misión será explorar la Universidad del Caribe, superar desafíos y recolectar todas las piezas del código perdido."},
	{"titulo": "RECONSTRUYE EL CÓDIGO", "dibujo": "codice",
		"texto": "Cada fragmento recuperado te acercará a descubrir el origen del error y restaurar el sistema. Pero ten cuidado: el camino no será tan sencillo como parece. Tres actos, tres fragmentos. ¿Estás listo para encontrar el código perdido y solucionar el ERROR 404?"},
]
const FINAL := [
	{"titulo": "¡SISTEMA RESTAURADO!", "dibujo": "final",
		"texto": "¡Felicidades, Yoshua! Has recuperado todos los fragmentos del código y solucionado el ERROR 404. Gracias a tu esfuerzo, los sistemas de la Universidad del Caribe vuelven a funcionar correctamente. MISIÓN COMPLETADA."},
]

var vinetas: Array = []
var indice: int = 0
var letras: float = 0.0
var lbl_titulo: Label
var lbl_texto: Label
var lbl_ayuda: Label
var dibujo: Dibujo
var imagen: TextureRect

func _ready() -> void:
	theme = TEMA.crear()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var negro := ColorRect.new()
	negro.color = TEMA.NEGRO
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(negro)
	vinetas = FINAL if Juego.historia_pendiente == "final" else INTRO

	dibujo = Dibujo.new()
	dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dibujo.position = Vector2(40, 12)
	dibujo.size = Vector2(560, 210)
	dibujo.scale.y = 0.8
	add_child(dibujo)
	imagen = TextureRect.new()
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	imagen.position = Vector2(40, 12)
	imagen.size = Vector2(560, 170)
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(imagen)

	lbl_titulo = TEMA.titulo("", 16)
	lbl_titulo.position = Vector2(0, 190)
	lbl_titulo.size = Vector2(640, 20)
	add_child(lbl_titulo)
	lbl_texto = Label.new()
	lbl_texto.position = Vector2(50, 216)
	lbl_texto.size = Vector2(540, 88)
	lbl_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_texto.add_theme_font_size_override("font_size", 12)
	add_child(lbl_texto)
	lbl_ayuda = Label.new()
	lbl_ayuda.position = Vector2(0, 344)
	lbl_ayuda.size = Vector2(630, 14)
	lbl_ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_ayuda.add_theme_font_size_override("font_size", 9)
	lbl_ayuda.add_theme_color_override("font_color", TEMA.AMARILLO)
	lbl_ayuda.text = "ESPACIO / CLIC EN EL FONDO: siguiente   ENTER / ESC: comenzar"
	add_child(lbl_ayuda)
	var comenzar := TEMA.boton("CONTINUAR" if Juego.historia_pendiente == "final" else "COMENZAR AVENTURA", _terminar, 240)
	comenzar.position = Vector2(200, 310)
	add_child(comenzar)
	comenzar.grab_focus()
	_mostrar()
	Sonido.musica("menu" if Juego.historia_pendiente != "final" else "victoria")

func _mostrar() -> void:
	var v: Dictionary = vinetas[indice]
	lbl_titulo.text = v["titulo"]
	letras = 0.0
	lbl_texto.text = ""
	dibujo.tipo = v["dibujo"]
	dibujo.modulate.a = 0.0
	create_tween().tween_property(dibujo, "modulate:a", 1.0, 0.3)
	var nombre_img: String = "vineta_%s_%d" % [Juego.historia_pendiente if Juego.historia_pendiente != "" else "intro", indice + 1]
	var tex := ARTE.textura(nombre_img)
	imagen.texture = tex
	dibujo.visible = tex == null
	Sonido.sfx("menu")

func _process(delta: float) -> void:
	var texto: String = vinetas[indice]["texto"]
	letras = minf(letras + delta * 40.0, float(texto.length()))
	lbl_texto.text = texto.substr(0, int(letras))

# La tecla de salto avanza la historia incluso con el botón enfocado.
func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not Juego.en_transicion() and event.is_action_pressed("saltar"):
		get_viewport().set_input_as_handled()
		_avanzar_vineta()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or Juego.en_transicion():
		return
	if event.is_action_pressed("pausa") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		_terminar()
		get_viewport().set_input_as_handled()
		return
	var avanzar: bool = event.is_action_pressed("ui_accept") or event.is_action_pressed("saltar")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		avanzar = true
	if not avanzar:
		return
	get_viewport().set_input_as_handled()
	_avanzar_vineta()

func _avanzar_vineta() -> void:
	var texto: String = vinetas[indice]["texto"]
	if letras < float(texto.length()):
		letras = float(texto.length())
		return
	indice += 1
	if indice >= vinetas.size():
		_terminar()
	else:
		_mostrar()

func _terminar() -> void:
	if Juego.en_transicion():
		return
	set_process_unhandled_input(false)
	set_process(false)
	indice = vinetas.size() - 1
	if Juego.historia_pendiente == "intro":
		Juego.datos["intro_vista"] = true
		Juego.guardar()
		Juego.jugar_nivel(0)
	else:
		Juego.cambiar_escena(Juego.destino_tras_historia if Juego.destino_tras_historia != "" else Juego.MENU_PRINCIPAL)


# ----------------- Ilustraciones provisionales -----------------
class Dibujo extends Control:
	var tipo: String = "campus":
		set(v):
			tipo = v
			queue_redraw()
	var tiempo: float = 0.0

	func _process(delta: float) -> void:
		tiempo += delta
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("#5FAFDD") if tipo != "final" else Color("#3B1E6D"))
		match tipo:
			"campus":
				_edificio(false)
				_kin(Vector2(150, 200), false)
				draw_circle(Vector2(480, 40), 18.0, Color("#FFF2B8"))
			"glitch":
				_edificio(true)
				for k in range(40):
					var h: int = (k * 97 + int(tiempo * 10.0) * 23) % 2003
					draw_rect(Rect2(float(h % 560), float((h * 7) % 210), 6, 4), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
				_kin(Vector2(150, 200), false)
			"codice":
				draw_rect(r, Color("#0B0B14"))
				var c := Vector2(280, 105)
				var sep: float = 20.0 + sin(tiempo * 2.0) * 6.0
				for k in range(3):
					var a: float = -PI / 2.0 + float(k) * TAU / 3.0
					var p := c + Vector2(cos(a), sin(a)) * sep
					draw_rect(Rect2(p - Vector2(18, 18), Vector2(36, 36)), Color("#29E7FF"), false, 2.0)
					draw_rect(Rect2(p - Vector2(8, 8), Vector2(16, 16)), Color("#29E7FF"))
				draw_circle(c, 70.0, Color(0.16, 0.9, 1.0, 0.08))
			"final":
				for k in range(40):
					draw_rect(Rect2(fmod(k * 97.0, 560.0), fmod(k * 53.0, 120.0), 1, 1), Color(1, 1, 1, 0.7))
				_edificio(false)
				_kin(Vector2(250, 200), true)
				draw_circle(Vector2(320, 70), 26.0 + sin(tiempo * 3.0) * 3.0, Color(0.16, 0.9, 1.0, 0.25))
				draw_rect(Rect2(306, 56, 28, 28), Color("#29E7FF"), false, 2.0)
		draw_rect(r, Color("#1FB6C1"), false, 2.0)

	func _edificio(roto: bool) -> void:
		draw_rect(Rect2(40, 60, 480, 140), Color("#EDE8DC"))
		for piso in range(3):
			draw_rect(Rect2(40, 74 + piso * 42, 480, 20), Color("#C9D1D3"))
		var x: float = 50.0
		while x < 510.0:
			draw_rect(Rect2(x, 60, 10, 140), Color("#F7F4EC") if not roto else Color("#F7F4EC").lerp(Color("#D81B8C"), 0.3 * absf(sin(tiempo * 9.0 + x))))
			x += 40.0
		draw_rect(Rect2(0, 200, 560, 10), Color("#9AA5A8"))

	func _kin(o: Vector2, feliz: bool) -> void:
		var salto: float = absf(sin(tiempo * 4.0)) * 8.0 if feliz else 0.0
		o.y -= salto
		draw_rect(Rect2(o.x - 16, o.y - 34, 10, 18), Color("#9AA5A8"))
		draw_rect(Rect2(o.x - 8, o.y - 14, 6, 14), Color("#1E2229"))
		draw_rect(Rect2(o.x + 2, o.y - 14, 6, 14), Color("#1E2229"))
		draw_rect(Rect2(o.x - 10, o.y - 32, 20, 18), Color("#1FB6C1"))
		draw_rect(Rect2(o.x - 4, o.y - 32, 8, 18), Color("#F4F1EA"))
		draw_rect(Rect2(o.x - 8, o.y - 46, 16, 14), Color("#E5A87E"))
		draw_rect(Rect2(o.x - 10, o.y - 48, 20, 6), Color("#2B1E16"))
		draw_rect(Rect2(o.x + 2, o.y - 40, 4, 4), Color("#0B0B14"))
		if feliz:
			draw_line(Vector2(o.x + 10, o.y - 28), Vector2(o.x + 20, o.y - 44), Color("#E5A87E"), 3.0)
