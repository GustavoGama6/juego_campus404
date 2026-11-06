extends AnimatableBody2D
# PLATAFORMA MÓVIL (carrito de libros, tronco, elevador). Va y viene.
# estilo: "carrito", "tronco", "metal". La posición es el centro.
# desfase: 0 = empieza en el inicio del recorrido, 1 = empieza al final.
# Arte: res://arte/plataforma_<estilo>.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(48, 16)
var estilo: String = "carrito"
var recorrido: Vector2 = Vector2(88, 0)
var velocidad: float = 40.0
var desfase: float = 0.0
var dibujar_riel: bool = true

var origen: Vector2 = Vector2.ZERO
var progreso: float = 0.0
var arte: Node2D = null
var tiempo: float = 0.0

func _ready() -> void:
	sync_to_physics = true
	if Juego.extraordinario():
		velocidad *= 1.3      # Extraordinario: más rápidas
	origen = position
	progreso = desfase
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	c.shape = f
	add_child(c)
	arte = ARTE.poner(self, "plataforma_" + estilo, false)
	ARTE.ajustar(arte, tamano)
	_mover()

func _physics_process(delta: float) -> void:
	tiempo += delta
	var largo: float = recorrido.length()
	if largo <= 0.0:
		return
	progreso += delta * velocidad / largo
	_mover()
	queue_redraw()

func _mover() -> void:
	var fase: float = fmod(progreso, 2.0)
	var f: float = fase if fase <= 1.0 else 2.0 - fase
	position = origen + recorrido * f

func _draw() -> void:
	var r := Rect2(-tamano / 2.0, tamano)
	# Riel (se dibuja desde el origen del recorrido)
	if dibujar_riel and recorrido.length() > 0.0:
		var ini: Vector2 = origen - position + Vector2(0, tamano.y / 2.0 + 4.0)
		draw_line(ini - recorrido.normalized() * 30.0, ini + recorrido + recorrido.normalized() * 30.0, Color(0.6, 0.6, 0.65, 0.5), 2.0)
	if arte:
		return
	match estilo:
		"carrito":
			draw_rect(r, Color("#5E3718"))
			draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), Color("#8B5A2B"))
			# Libros encima del carrito (decoración baja)
			var x: float = r.position.x + 4.0
			var k: int = 0
			while x < r.end.x - 6.0:
				var cols := [Color("#B03A2E"), Color("#1FB6C1"), Color("#F5C242")]
				draw_rect(Rect2(x, r.position.y + 4, 4, r.size.y - 8), cols[k % 3])
				x += 6.0
				k += 1
			var giro: float = tiempo * 6.0
			for rx in [r.position.x + 7.0, r.end.x - 7.0]:
				draw_circle(Vector2(rx, r.end.y + 2.0), 3.0, Color("#2A2A33"))
				draw_line(Vector2(rx, r.end.y + 2.0), Vector2(rx + cos(giro) * 2.5, r.end.y + 2.0 + sin(giro) * 2.5), Color("#9AA5A8"), 1.0)
		"tronco":
			draw_rect(r, Color("#8B5A2B"))
			draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#B07D46"))
			draw_line(Vector2(r.position.x, r.get_center().y), Vector2(r.end.x, r.get_center().y), Color("#5E3718"), 1.0)
		_:
			draw_rect(r, Color("#4C5A63"))
			draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#F5C242"))
