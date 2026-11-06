extends StaticBody2D
# PLATAFORMA GLITCH: al pararte encima parpadea 0.6 s, desaparece 1.5 s
# y vuelve a aparecer. La posición es el centro.
# Arte: res://arte/plataforma_glitch.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(40, 12)
var tiempo_aviso: float = 0.6
var tiempo_fuera: float = 1.5

enum { NORMAL, AVISO, FUERA }
var estado: int = NORMAL
var timer: float = 0.0
var tiempo: float = 0.0
var colision: CollisionShape2D
var arte: Node2D = null

func _ready() -> void:
	# Normal: parpadea 0.5 s antes de desaparecer. Extraordinario: 0.3 s y tarda más en volver
	tiempo_aviso = 0.3 if Juego.extraordinario() else 0.5
	if Juego.extraordinario():
		tiempo_fuera = 2.0
	colision = CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	colision.shape = f
	add_child(colision)
	arte = ARTE.poner(self, "plataforma_glitch", false)
	ARTE.ajustar(arte, tamano)

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	match estado:
		NORMAL:
			var j = get_tree().get_first_node_in_group("jugador")
			if j and j.is_on_floor():
				var d: Vector2 = j.global_position - global_position
				if absf(d.x) < tamano.x / 2.0 + 6.0 and absf(d.y + tamano.y / 2.0) < 3.0:
					estado = AVISO
					timer = tiempo_aviso
					Sonido.sfx("glitch")
		AVISO:
			timer -= delta
			if timer <= 0.0:
				estado = FUERA
				timer = tiempo_fuera
				colision.set_deferred("disabled", true)
		FUERA:
			timer -= delta
			if timer <= 0.0 and not _jugador_adentro():
				estado = NORMAL
				colision.set_deferred("disabled", false)
	if arte:
		arte.visible = estado != FUERA and (estado != AVISO or int(tiempo * 20.0) % 2 == 0)

func _jugador_adentro() -> bool:
	var j = get_tree().get_first_node_in_group("jugador")
	if j == null:
		return false
	var d: Vector2 = j.global_position - global_position
	return absf(d.x) < tamano.x / 2.0 + 7.0 and d.y > -tamano.y / 2.0 and d.y - 24.0 < tamano.y / 2.0

func _draw() -> void:
	if arte:
		return
	var r := Rect2(-tamano / 2.0, tamano)
	if estado == FUERA:
		# Solo queda el contorno punteado
		var x: float = r.position.x
		while x < r.end.x:
			draw_rect(Rect2(x, r.position.y, 3, 1), Color(0.16, 0.9, 1.0, 0.4))
			x += 6.0
		return
	if estado == AVISO and int(tiempo * 20.0) % 2 == 0:
		return
	draw_rect(r, Color("#29E7FF"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#F4F1EA"))
	var semilla: int = int(tiempo * 8.0)
	for k in range(5):
		var h: int = (k * 17 + semilla * 7) % 97
		draw_rect(Rect2(r.position.x + float(h % int(r.size.x - 3.0)), r.position.y + 3.0 + float(h % 5), 3, 2), Color("#D81B8C"))
