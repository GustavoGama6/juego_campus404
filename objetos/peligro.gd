extends Area2D
# PELIGRO GLITCH FIJO (barra de ruido). Daña al tocarla. Sirve para obligar a
# usar el salto corto. La posición es la esquina superior izquierda.

var tamano: Vector2 = Vector2(60, 14)
var tiempo: float = 0.0

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	c.shape = f
	c.position = tamano / 2.0
	add_child(c)

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("danar", 1, global_position + tamano / 2.0)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, tamano), Color("#0B0B14"))
	var semilla: int = int(tiempo * 12.0)
	for k in range(int(tamano.x * tamano.y / 20.0)):
		var h: int = (k * 61 + semilla * 19) % 997
		draw_rect(Rect2(float(h % int(tamano.x - 2.0)), float((h / 3) % int(tamano.y - 2.0)), 2, 2), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
	# Parpadeo de advertencia (magenta)
	draw_rect(Rect2(Vector2.ZERO, tamano), Color(0.85, 0.1, 0.55, 0.5 + 0.4 * sin(tiempo * 8.0)), false, 1.0)
