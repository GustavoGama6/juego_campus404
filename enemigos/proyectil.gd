extends Area2D
# =====================================================================
#  PROYECTIL DE RUIDO: lo disparan los drones (Extraordinario) y Error 404.
#  Daña a Kin al tocarlo. Se destruye al chocar con un bloque, al entrar
#  a una zona de luz (farolas y rayos de sol) o después de unos segundos.
#  Arte: res://arte/proyectil.png (centrado, unos 8 x 8)
# =====================================================================

const ARTE := preload("res://objetos/arte.gd")

var velocidad: Vector2 = Vector2(110, 0)
var vida: float = 3.0
var radio: float = 4.0
var tiempo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	add_to_group("proyectil")
	var c := CollisionShape2D.new()
	var f := CircleShape2D.new()
	f.radius = radio
	c.shape = f
	add_child(c)
	body_entered.connect(_on_body_entered)
	arte = ARTE.poner(self, "proyectil", false)

func _physics_process(delta: float) -> void:
	tiempo += delta
	vida -= delta
	position += velocidad * delta
	queue_redraw()
	if vida <= 0.0:
		queue_free()
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("danar", 1, global_position)
			queue_free()
			return
	for z in get_tree().get_nodes_in_group("luz"):
		if z.call("contiene", global_position):
			queue_free()
			return

func _on_body_entered(b: Node2D) -> void:
	if b.is_in_group("jugador"):
		return
	queue_free()   # chocó con un bloque o una puerta

func _draw() -> void:
	if arte:
		return
	# Estela
	var atras: Vector2 = -velocidad.normalized()
	for k in range(3):
		draw_rect(Rect2(atras * float(k + 1) * 4.0 - Vector2(1.5, 1.5), Vector2(3, 3)), Color(0.85, 0.1, 0.55, 0.5 - k * 0.15))
	draw_rect(Rect2(-radio, -radio, radio * 2.0, radio * 2.0), Color("#D81B8C"))
	var c: Color = Color("#29E7FF") if int(tiempo * 20.0) % 2 == 0 else Color("#F4F1EA")
	draw_rect(Rect2(-1.5, -1.5, 3, 3), c)
