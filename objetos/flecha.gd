extends Node2D
# Flecha que parpadea (nivel 1): indica hacia dónde avanza el nivel.

var direccion: float = 1.0
var tiempo: float = 0.0

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	if fmod(tiempo, 1.0) > 0.65:
		return
	var d: float = direccion
	var c := Color(0.96, 0.76, 0.26, 0.9)
	draw_rect(Rect2(-8 if d > 0 else -4, -3, 12, 6), c)
	draw_colored_polygon(PackedVector2Array([Vector2(8 * d, -8), Vector2(16 * d, 0), Vector2(8 * d, 8)]), c)
