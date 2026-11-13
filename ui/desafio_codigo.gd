extends CanvasLayer
# Diagnóstico del Núcleo. Reutiliza el tema y la pausa del proyecto.
signal resuelto
signal cancelado
const TEMA := preload("res://ui/tema.gd")
const PREGUNTAS := [
	{"codigo": "fragmentos = 0\nfragmentos = fragmentos + 1", "pregunta": "¿Cuánto vale fragmentos?", "opciones": ["0", "1", "3"], "correcta": 1, "pista": "La asignación suma uno al valor anterior."},
	{"codigo": "if fragmentos == 3 and terminal_activa:\n    restaurar()", "pregunta": "¿Cuándo se ejecuta restaurar()?", "opciones": ["Con cualquier fragmento", "Solo con la terminal activa", "Con 3 fragmentos y la terminal activa"], "correcta": 2, "pista": "AND exige que ambas condiciones sean verdaderas."},
	{"codigo": "codigo = [\"acceso\", \"biblioteca\", \"nucleo\"]", "pregunta": "Los índices empiezan en 0. ¿Qué devuelve codigo[2]?", "opciones": ["nucleo", "biblioteca", "acceso"], "correcta": 0, "pista": "El índice 0 es acceso; el índice 2 es el tercer elemento."},
]
var paso: int = 0
var titulo: Label
var codigo: Label
var pregunta: Label
var mensaje: Label
var opciones: VBoxContainer
var cerrado: bool = false

func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.03, 0.06, 0.94)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	var panel := Panel.new()
	panel.theme = TEMA.crear()
	panel.position = Vector2(60, 18)
	panel.size = Vector2(520, 324)
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.position = Vector2(16, 10)
	caja.size = Vector2(488, 304)
	caja.add_theme_constant_override("separation", 6)
	panel.add_child(caja)
	titulo = TEMA.titulo("", 18, TEMA.TURQUESA)
	caja.add_child(titulo)
	codigo = TEMA.titulo("", 14, TEMA.AMARILLO)
	codigo.custom_minimum_size.y = 62
	caja.add_child(codigo)
	pregunta = TEMA.titulo("", 12, TEMA.BLANCO)
	caja.add_child(pregunta)
	opciones = VBoxContainer.new()
	caja.add_child(opciones)
	mensaje = TEMA.titulo("", 11, TEMA.AMARILLO)
	mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mensaje.custom_minimum_size.y = 30
	caja.add_child(mensaje)
	caja.add_child(TEMA.boton("Volver al Núcleo", _cancelar, 200))
	get_tree().paused = true
	_mostrar()

func _mostrar() -> void:
	for b in opciones.get_children():
		opciones.remove_child(b)
		b.queue_free()
	var p: Dictionary = PREGUNTAS[paso]
	titulo.text = "RECONSTRUIR CÓDIGO · %d/%d" % [paso + 1, PREGUNTAS.size()]
	codigo.text = p["codigo"]
	pregunta.text = p["pregunta"]
	mensaje.text = "Selecciona con ratón o flechas y Enter. Puedes reintentar."
	for i in range(p["opciones"].size()):
		var b := TEMA.boton(p["opciones"][i], _responder.bind(i), 480)
		opciones.add_child(b)
	opciones.get_child(0).grab_focus()

func _responder(indice: int) -> void:
	if cerrado:
		return
	if indice != int(PREGUNTAS[paso]["correcta"]):
		mensaje.text = PREGUNTAS[paso]["pista"]
		return
	paso += 1
	if paso < PREGUNTAS.size():
		_mostrar()
	else:
		cerrado = true
		get_tree().paused = false
		resuelto.emit()
		queue_free()

func _cancelar() -> void:
	if cerrado:
		return
	cerrado = true
	get_tree().paused = false
	cancelado.emit()
	queue_free()
