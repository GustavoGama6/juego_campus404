extends Area2D
# PISO MOJADO: suelo resbaloso (poca fricción). Tiene un letrero amarillo
# al inicio. La posición es la esquina izquierda sobre el piso.
# Arte: res://arte/letrero_mojado.png

const ARTE := preload("res://objetos/arte.gd")

var ancho: float = 200.0
var tiempo: float = 0.0
var arte: Node2D = null

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(ancho, 12)
	c.shape = f
	c.position = Vector2(ancho / 2.0, -6)
	add_child(c)
	body_entered.connect(_on_entra)
	body_exited.connect(_on_sale)
	arte = ARTE.poner(self, "letrero_mojado")
	if arte:
		arte.position.x = -12.0

func _on_entra(b: Node2D) -> void:
	if b.is_in_group("jugador"):
		b.set("piso_mojado", int(b.get("piso_mojado")) + 1)

func _on_sale(b: Node2D) -> void:
	if b.is_in_group("jugador"):
		b.set("piso_mojado", maxi(int(b.get("piso_mojado")) - 1, 0))

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _draw() -> void:
	# Brillos de agua en el piso
	for k in range(int(ancho / 20.0)):
		var x: float = float(k) * 20.0 + fmod(tiempo * 8.0 + float(k) * 7.0, 14.0)
		draw_line(Vector2(x, -1), Vector2(x + 6.0, -1), Color(0.75, 0.95, 1.0, 0.8), 1.0)
	draw_rect(Rect2(0, -1, ancho, 1), Color(0.4, 0.75, 0.9, 0.35))
	if arte:
		return
	# Letrero amarillo con triángulo
	var o := Vector2(-12, 0)
	draw_colored_polygon(PackedVector2Array([o + Vector2(-7, 0), o + Vector2(0, -18), o + Vector2(7, 0)]), Color("#F5C242"))
	draw_rect(Rect2(o + Vector2(-1, -12), Vector2(2, 6)), Color("#0B0B14"))
	draw_rect(Rect2(o + Vector2(-1, -4), Vector2(2, 2)), Color("#0B0B14"))
