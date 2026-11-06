extends Area2D
# VACÍO GLITCH: hueco lleno de ruido. Si Kin cae aquí, vuelve a la última
# farola con la energía llena. La posición es la esquina superior izquierda.

var tamano: Vector2 = Vector2(60, 80)
var tiempo: float = 0.0

func _ready() -> void:
	z_index = 1
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(tamano.x, tamano.y - 10.0)
	c.shape = f
	c.position = Vector2(tamano.x / 2.0, 10.0 + (tamano.y - 10.0) / 2.0)
	add_child(c)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(b: Node2D) -> void:
	if b.is_in_group("jugador"):
		b.call_deferred("caer_al_vacio")

# Los enemigos que caen (o son empujados) al vacío desaparecen
func _on_area_entered(a: Area2D) -> void:
	if a.is_in_group("enemigo") and a.get("muere_con_trampas") and not a.get("muerto"):
		a.call_deferred("morir")

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, tamano), Color(0.04, 0.04, 0.08, 0.95))
	var semilla: int = int(tiempo * 10.0)
	var n: int = int(tamano.x * 0.6)
	for k in range(n):
		var h: int = (k * 97 + semilla * 23) % 1999
		var x: float = float(h % int(maxf(tamano.x - 3.0, 1.0)))
		var y: float = float((h * 3) % int(maxf(tamano.y - 3.0, 1.0)))
		draw_rect(Rect2(x, y, 3, 2), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
	draw_rect(Rect2(0, 0, tamano.x, 2), Color(0.85, 0.1, 0.55, 0.6 + 0.3 * sin(tiempo * 6.0)))
