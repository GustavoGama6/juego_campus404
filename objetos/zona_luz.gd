extends Node2D
# ZONA DE LUZ: rayos de sol o luz de farola. Los enemigos de ruido se quedan
# quietos dentro. forma = "rayo" (rectángulo inclinado) o "circulo".
# La posición es la esquina superior izquierda (rayo) o el centro (círculo).

var forma: String = "rayo"
var tamano: Vector2 = Vector2(50, 280)
var radio: float = 56.0
var activa: bool = true
var tiempo: float = 0.0

func _ready() -> void:
	add_to_group("luz")
	z_index = -1

func contiene(p: Vector2) -> bool:
	if not activa:
		return false
	var local: Vector2 = p - global_position
	if forma == "circulo":
		return local.length() <= radio
	return Rect2(Vector2.ZERO, tamano).has_point(local)

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	if not activa:
		return
	var brillo: float = 0.16 + 0.03 * sin(tiempo * 2.0)
	if forma == "circulo":
		draw_circle(Vector2.ZERO, radio, Color(1.0, 0.9, 0.55, brillo * 0.7))
		draw_circle(Vector2.ZERO, radio * 0.6, Color(1.0, 0.92, 0.6, brillo))
	else:
		var inclinacion: float = tamano.y * 0.25
		var poli := PackedVector2Array([
			Vector2(inclinacion, 0), Vector2(inclinacion + tamano.x, 0),
			Vector2(tamano.x, tamano.y), Vector2(0, tamano.y)])
		draw_colored_polygon(poli, Color(1.0, 0.93, 0.6, brillo))
		# Polvito flotando en el rayo
		for k in range(6):
			var y: float = fmod(tiempo * 10.0 + float(k) * 47.0, tamano.y)
			var x: float = (1.0 - y / tamano.y) * inclinacion + fmod(float(k) * 13.0, tamano.x)
			draw_rect(Rect2(x, y, 1, 1), Color(1, 1, 0.9, 0.6))
