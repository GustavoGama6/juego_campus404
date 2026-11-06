extends Area2D
# Agua del lago. Se dibuja con olas y, si el jugador se hunde,
# regresa a la última farola. La posición es la esquina superior izquierda.

@export var tamano: Vector2 = Vector2(4000, 70)
@export var profundidad_peligro: float = 8.0   # cuántos px bajo la superficie empieza a "ahogar"

var tiempo: float = 0.0

func _ready() -> void:
	z_index = 1   # se dibuja encima de lo que se hunde (cocodrilos, orillas)
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	var alto: float = maxf(tamano.y - profundidad_peligro, 4.0)
	forma.size = Vector2(tamano.x, alto)
	colision.shape = forma
	colision.position = Vector2(tamano.x / 2.0, profundidad_peligro + alto / 2.0)
	add_child(colision)
	body_entered.connect(_on_body_entered)

func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		cuerpo.call_deferred("caer_al_vacio")

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	# Cuerpo del agua (un poco transparente para ver la orilla sumergida)
	draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color(0.11, 0.42, 0.47, 0.88))
	draw_rect(Rect2(0, 10, tamano.x, tamano.y - 10), Color(0.07, 0.30, 0.36, 0.6))
	# Superficie
	draw_rect(Rect2(0, 0, tamano.x, 3), Color("#4FC3C2"))
	# Brillos que se mueven como olas
	var x: float = 0.0
	var i: int = 0
	while x < tamano.x:
		var ola: float = sin(tiempo * 2.0 + float(i) * 0.7) * 3.0
		draw_line(Vector2(x + ola, 6 + (i % 3) * 5), Vector2(x + ola + 10.0, 6 + (i % 3) * 5), Color(0.75, 0.95, 0.95, 0.45), 1.0)
		x += 26.0
		i += 1
