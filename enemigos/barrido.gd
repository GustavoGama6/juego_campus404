extends Area2D
# Barrido horizontal de ruido (ataque del jefe). Avanza a ras de piso de un
# lado al otro de la arena. Se esquiva saltándolo.

signal terminado

var x_final: float = 0.0
var velocidad: float = 170.0
var alto: float = 18.0
var tiempo: float = 0.0

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(20, alto)
	c.shape = f
	c.position = Vector2(0, -alto / 2.0)
	add_child(c)

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	var d: float = signf(x_final - position.x)
	position.x += d * velocidad * delta
	if (d > 0.0 and position.x >= x_final) or (d < 0.0 and position.x <= x_final) or d == 0.0:
		terminado.emit()
		queue_free()
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("danar", 1, global_position)

func _draw() -> void:
	var semilla: int = int(tiempo * 20.0)
	for k in range(18):
		var h: int = (k * 37 + semilla * 13) % 101
		var x: float = float(h % 20) - 10.0
		var y: float = -float((h * 7) % int(alto)) - 3.0
		draw_rect(Rect2(x, y, 3, 3), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
	draw_rect(Rect2(-10, -alto, 20, alto), Color(0.85, 0.1, 0.55, 0.18))
