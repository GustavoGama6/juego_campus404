extends Control
# =====================================================================
#  MENÚ PRINCIPAL: Jugar, Seleccionar nivel, Opciones, Créditos y Salir.
#  Muestra el nombre del juego y a sus creadores (edítalos en autoload/juego.gd).
#  Fondo: la plaza de acceso con Kin y Chicle.
# =====================================================================

const TEMA := preload("res://ui/tema.gd")
const FONDO := preload("res://fondos/fondo_campus.gd")
const OPCIONES := preload("res://ui/opciones.gd")
const ARTE := preload("res://objetos/arte.gd")

var botones: VBoxContainer
var opciones: Panel
var boton_jugar: Button

func _ready() -> void:
	theme = TEMA.crear()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo = FONDO.new()
	fondo.variante = "plaza"
	fondo.ancho_nivel = 640.0
	add_child(fondo)
	var escena := Escenita.new()
	add_child(escena)
	# Si hay una imagen de título propia, se usa (res://arte/titulo.png)
	var tex_titulo := ARTE.textura("titulo")
	if tex_titulo:
		var tr2 := TextureRect.new()
		tr2.texture = tex_titulo
		tr2.position = Vector2(320 - tex_titulo.get_width() / 2.0, 14)
		add_child(tr2)
	else:
		var t := TEMA.titulo(Juego.NOMBRE_JUEGO, 40)
		t.position = Vector2(0, 16)
		t.size = Vector2(640, 50)
		add_child(t)
		var sub := TEMA.titulo("Reinicia el Núcleo antes de que cierre la entrega", 11, TEMA.BLANCO)
		sub.position = Vector2(0, 66)
		sub.size = Vector2(640, 16)
		add_child(sub)

	botones = VBoxContainer.new()
	botones.position = Vector2(400, 96)
	botones.size = Vector2(190, 200)
	botones.add_theme_constant_override("separation", 7)
	add_child(botones)
	var texto_jugar: String = "Jugar" if not bool(Juego.datos["intro_vista"]) else "Continuar"
	boton_jugar = TEMA.boton(texto_jugar, _jugar, 190)
	botones.add_child(boton_jugar)
	botones.add_child(TEMA.boton("Seleccionar nivel", _seleccion, 190))
	if Juego.extraordinario_desbloqueado():
		var b_ext := TEMA.boton("Modo Extraordinario", _extraordinario, 190)
		b_ext.add_theme_color_override("font_color", TEMA.MAGENTA)
		botones.add_child(b_ext)
	botones.add_child(TEMA.boton("Opciones", _opciones, 190))
	botones.add_child(TEMA.boton("Créditos", _creditos, 190))
	if OS.get_name() != "Web":
		botones.add_child(TEMA.boton("Salir", _salir, 190))

		# Los nombres se reparten en 2 renglones para que quepan en pantalla
	var lista: Array = Juego.CREADORES
	var mitad: int = ceili(float(lista.size()) / 2.0)
	var linea1 := " · ".join(PackedStringArray(lista.slice(0, mitad)))
	var linea2 := " · ".join(PackedStringArray(lista.slice(mitad)))
	var creadores := TEMA.titulo("Creado por: " + linea1 + ("\n" + linea2 if linea2 != "" else ""), 9, TEMA.BLANCO)
	creadores.position = Vector2(0, 304)
	creadores.size = Vector2(640, 30)
	creadores.clip_text = true
	add_child(creadores)
	var materia := TEMA.titulo(Juego.MATERIA, 9, TEMA.AMARILLO)
	materia.position = Vector2(0, 342)
	materia.size = Vector2(640, 12)
	add_child(materia)

	if bool(Juego.datos.get("todo_abierto", false)):
		var prueba := TEMA.titulo("MODO PRUEBA: todo desbloqueado (Opciones > Borrar progreso para quitarlo)", 9, TEMA.MAGENTA)
		prueba.position = Vector2(10, 4)
		prueba.size = Vector2(620, 12)
		prueba.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		add_child(prueba)

	opciones = OPCIONES.new()
	opciones.visible = false
	opciones.cerrado.connect(func(): boton_jugar.grab_focus())
	add_child(opciones)

	Sonido.musica("menu")
	boton_jugar.grab_focus()

# F12: modo prueba (todo desbloqueado), para probar o presentar el juego
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F12:
		Juego.modo_prueba()
		Sonido.sfx("sello")
		get_tree().reload_current_scene()

func _jugar() -> void:
	Juego.jugar_desde_menu()

func _seleccion() -> void:
	Juego.set_dificultad("normal")
	Juego.cambiar_escena(Juego.SELECCION)

# Se desbloquea al terminar el juego en Normal
func _extraordinario() -> void:
	Juego.set_dificultad("extraordinario")
	Juego.cambiar_escena(Juego.SELECCION, "MODO EXTRAORDINARIO", "2 vasos de café · pinchos · enemigos con más ataques")

func _opciones() -> void:
	opciones.abrir()

func _creditos() -> void:
	Juego.cambiar_escena("res://menus/creditos.tscn")

func _salir() -> void:
	get_tree().quit()


# Kin y Chicle parados en la plaza (dibujo provisional)
class Escenita extends Node2D:
	var tiempo: float = 0.0

	func _process(delta: float) -> void:
		tiempo += delta
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(0, 300, 640, 60), Color("#9AA5A8"))
		draw_rect(Rect2(0, 300, 640, 3), Color("#C9D1D3"))
		# Kin
		var o := Vector2(150, 300)
		var resp: float = sin(tiempo * 2.0)
		draw_rect(Rect2(o.x - 8, o.y - 17, 5, 9), Color("#9AA5A8"))
		draw_rect(Rect2(o.x - 7, o.y - 15, 3, 3), Color("#F5C242"))
		draw_rect(Rect2(o.x - 4, o.y - 7, 3, 7), Color("#1E2229"))
		draw_rect(Rect2(o.x + 1, o.y - 7, 3, 7), Color("#1E2229"))
		draw_rect(Rect2(o.x - 5, o.y - 16 + resp * 0.5, 10, 9), Color("#1FB6C1"))
		draw_rect(Rect2(o.x - 2, o.y - 16 + resp * 0.5, 4, 9), Color("#F4F1EA"))
		draw_rect(Rect2(o.x - 4, o.y - 23 + resp * 0.5, 8, 7), Color("#E5A87E"))
		draw_rect(Rect2(o.x - 5, o.y - 24 + resp * 0.5, 10, 3), Color("#2B1E16"))
		draw_rect(Rect2(o.x + 1, o.y - 20 + resp * 0.5, 2, 2), Color("#0B0B14"))
		# Chicle
		var c := Vector2(186, 300)
		var cola: float = sin(tiempo * 4.0) * 2.0
		for k in range(4):
			draw_rect(Rect2(c.x - 8.0 - k * 3.0, c.y - 10.0 - k * 3.0 + cola * 0.3 * k, 3, 3), Color("#9B6A3C") if k % 2 == 0 else Color("#3A2A1A"))
		draw_rect(Rect2(c.x - 6, c.y - 9, 12, 7), Color("#9B6A3C"))
		draw_rect(Rect2(c.x + 3, c.y - 13, 7, 6), Color("#9B6A3C"))
		draw_rect(Rect2(c.x + 8, c.y - 10, 5, 2), Color("#D8B28A"))
		draw_rect(Rect2(c.x + 6, c.y - 12, 2, 2), Color("#0B0B14"))
		# Píxeles de glitch flotando
		for k in range(12):
			var x: float = fmod(float(k) * 53.0 + tiempo * (10.0 + k), 640.0)
			var y: float = 120.0 + fmod(float(k) * 37.0, 160.0) + sin(tiempo * 3.0 + k) * 6.0
			draw_rect(Rect2(x, y, 3, 3), Color(0.85, 0.1, 0.55, 0.6) if k % 2 == 0 else Color(0.16, 0.9, 1.0, 0.6))
