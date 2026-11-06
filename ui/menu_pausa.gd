extends CanvasLayer
# MENÚ DE PAUSA (Esc / Start). Continuar, Reiniciar nivel, Opciones, Volver al menú.
# Lo crea nivel_base.gd. Mientras está abierto, el juego se congela.

const TEMA := preload("res://ui/tema.gd")
const OPCIONES := preload("res://ui/opciones.gd")

var nivel: Node = null
var fondo: ColorRect
var panel: Panel
var opciones: Panel
var boton_continuar: Button

func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.55)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	panel = Panel.new()
	panel.theme = TEMA.crear()
	panel.position = Vector2(210, 70)
	panel.size = Vector2(220, 200)
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.position = Vector2(20, 12)
	caja.size = Vector2(180, 180)
	caja.add_theme_constant_override("separation", 8)
	panel.add_child(caja)
	caja.add_child(TEMA.titulo("PAUSA", 20))
	boton_continuar = TEMA.boton("Continuar", cerrar)
	caja.add_child(boton_continuar)
	caja.add_child(TEMA.boton("Reiniciar nivel", _reiniciar))
	caja.add_child(TEMA.boton("Opciones", _opciones))
	caja.add_child(TEMA.boton("Volver al menú", _menu))

	opciones = OPCIONES.new()
	opciones.visible = false
	opciones.cerrado.connect(_al_cerrar_opciones)
	add_child(opciones)
	visible = false

func _process(_delta: float) -> void:
	if not Input.is_action_just_pressed("pausa"):
		return
	if Juego.en_transicion() or opciones.visible:
		return
	if nivel and bool(nivel.get("terminado")):
		return
	if visible:
		cerrar()
	else:
		abrir()

func abrir() -> void:
	visible = true
	panel.visible = true
	get_tree().paused = true
	boton_continuar.grab_focus()

func cerrar() -> void:
	visible = false
	get_tree().paused = false

func _reiniciar() -> void:
	var ruta: String = get_tree().current_scene.scene_file_path
	Juego.cambiar_escena(ruta)

func _opciones() -> void:
	panel.visible = false
	opciones.abrir()

func _al_cerrar_opciones() -> void:
	panel.visible = true
	boton_continuar.grab_focus()

func _menu() -> void:
	Juego.ir_menu()
