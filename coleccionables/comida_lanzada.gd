extends Area2D
# Pescado lanzado por el jugador (lo crea yeshua.gd al presionar F).
# Vuela casi recto (cae muy poco). Si toca algo que tenga la función recibir_comida()
# (cocodrilos y el Rey Cocodrilo), se la da. Si choca con un bloque, se pierde.

var velocidad: Vector2 = Vector2(280, -10)
var gravedad: float = 40.0
var vida: float = 1.2      # segundos antes de desaparecer (alcance de unos 300 px)
var giro: float = 0.0
var arte: Node2D = null   # usa la misma imagen: res://arte/comida.png

const ARTE := preload("res://objetos/arte.gd")

func _ready() -> void:
	arte = ARTE.poner(self, "comida", false)
	var colision := CollisionShape2D.new()
	var forma := CircleShape2D.new()
	forma.radius = 6.0
	colision.shape = forma
	add_child(colision)
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	velocidad.y += gravedad * delta
	position += velocidad * delta
	giro += delta
	rotation = velocidad.angle() + sin(giro * 25.0) * 0.3
	vida -= delta
	if vida <= 0.0 or global_position.y > 400.0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("recibir_comida"):
		if area.call("recibir_comida"):
			queue_free()

func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		return
	queue_free()

func _draw() -> void:
	if arte:
		return
	var cuerpo := PackedVector2Array()
	for k in range(10):
		var a: float = TAU * float(k) / 10.0
		cuerpo.append(Vector2(cos(a) * 5.0, sin(a) * 3.0))
	draw_colored_polygon(cuerpo, Color("#F2994A"))
	draw_colored_polygon(PackedVector2Array([Vector2(-4, 0), Vector2(-8, -3), Vector2(-8, 3)]), Color("#E07B2A"))
	draw_rect(Rect2(2, -1.5, 1.5, 1.5), Color("#0B0B14"))
