extends Area2D
# =====================================================================
#  RAYO 404 (ataque del jefe).
#  Primero AVISA con una línea delgada que parpadea; luego dispara un rayo
#  grueso que daña. vertical = true: columna de techo a piso (muévete).
#  vertical = false: rayo horizontal a ras de piso (sáltalo) o a media
#  altura (quédate en el piso).
# =====================================================================

var vertical: bool = true
var desde: float = 0.0      # vertical: y de arriba / horizontal: x izquierda
var hasta: float = 320.0    # vertical: y de abajo / horizontal: x derecha
var grosor: float = 18.0
var aviso: float = 0.8
var duracion: float = 0.35
var tiempo: float = 0.0
var forma: RectangleShape2D

func _ready() -> void:
	var c := CollisionShape2D.new()
	forma = RectangleShape2D.new()
	if vertical:
		forma.size = Vector2(grosor - 4.0, hasta - desde)
		c.position = Vector2(0, (desde + hasta) / 2.0 - position.y)
	else:
		forma.size = Vector2(hasta - desde, grosor - 4.0)
		c.position = Vector2((desde + hasta) / 2.0 - position.x, 0)
	c.shape = forma
	add_child(c)
	Sonido.sfx("chispa")

func activo() -> bool:
	return tiempo >= aviso and tiempo < aviso + duracion

func _physics_process(delta: float) -> void:
	var antes: bool = activo()
	tiempo += delta
	queue_redraw()
	if activo() and not antes:
		Sonido.sfx("glitch")
	if tiempo >= aviso + duracion:
		queue_free()
		return
	if activo():
		for b in get_overlapping_bodies():
			if b.is_in_group("jugador"):
				b.call("danar", 1, global_position)

func _draw() -> void:
	var r: Rect2
	if vertical:
		r = Rect2(-grosor / 2.0, desde - position.y, grosor, hasta - desde)
	else:
		r = Rect2(desde - position.x, -grosor / 2.0, hasta - desde, grosor)
	if not activo():
		# Aviso: línea delgada que parpadea cada vez más rápido
		var vel: float = 10.0 + tiempo / aviso * 30.0
		var a: float = 0.35 + 0.35 * sin(tiempo * vel)
		var linea: Rect2 = r
		if vertical:
			linea = Rect2(-1.5, r.position.y, 3, r.size.y)
		else:
			linea = Rect2(r.position.x, -1.5, r.size.x, 3)
		draw_rect(linea, Color(0.85, 0.1, 0.55, a))
		draw_rect(r, Color(0.85, 0.1, 0.55, 0.08), false, 1.0)
		return
	draw_rect(r, Color(0.85, 0.1, 0.55, 0.85))
	var nucleo: Rect2 = r.grow_individual(-grosor * 0.3, 0, -grosor * 0.3, 0) if vertical else r.grow_individual(0, -grosor * 0.3, 0, -grosor * 0.3)
	draw_rect(nucleo, Color("#29E7FF"))
