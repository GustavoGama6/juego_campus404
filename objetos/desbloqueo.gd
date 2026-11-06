extends Area2D
# Tótem maya que enseña una habilidad. Al tocarlo, el jugador la desbloquea.
# "habilidad" puede ser: "pared", "planeo" o "lanzar".
# El origen (position) está en la base del tótem.

signal activado(habilidad: String)

@export var habilidad: String = "pared"

var usado: bool = false
var tiempo: float = 0.0
var arte: Node2D = null   # res://arte/totem_<habilidad>.png  (totem_pared, totem_planeo)

const ARTE := preload("res://objetos/arte.gd")

func _ready() -> void:
	arte = ARTE.poner(self, "totem_" + habilidad)
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(24, 44)
	colision.shape = forma
	colision.position = Vector2(0, -22)
	add_child(colision)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()

func _on_body_entered(cuerpo: Node2D) -> void:
	if usado or not cuerpo.is_in_group("jugador"):
		return
	usado = true
	cuerpo.call("desbloquear", habilidad)
	activado.emit(habilidad)

func _color() -> Color:
	match habilidad:
		"planeo":
			return Color("#F5C242")
		"lanzar":
			return Color("#F2994A")
	return Color("#29E7FF")

func _draw() -> void:
	if arte:
		arte.modulate = Color(0.6, 0.6, 0.6) if usado else Color.WHITE
		return
	var c := _color()
	# Pedestal de piedra con grabados
	draw_rect(Rect2(-10, -16, 20, 16), Color("#8C8677"))
	draw_rect(Rect2(-12, -18, 24, 3), Color("#A9A392"))
	draw_rect(Rect2(-6, -12, 4, 4), Color("#6E695C"))
	draw_rect(Rect2(2, -12, 4, 4), Color("#6E695C"))
	draw_rect(Rect2(-4, -6, 8, 2), Color("#6E695C"))
	if usado:
		# Ya se usó: solo queda el grabado brillando
		draw_rect(Rect2(-4, -6, 8, 2), c)
		return
	# Orbe flotando con el dibujo de la habilidad
	var centro := Vector2(0, -30 + sin(tiempo * 3.0) * 2.0)
	draw_circle(centro, 12.0 + sin(tiempo * 5.0), Color(c.r, c.g, c.b, 0.22))
	draw_circle(centro, 7.0, c)
	draw_circle(centro, 5.0, Color("#0B0B14"))
	match habilidad:
		"planeo":
			# Ala
			draw_line(centro + Vector2(-4, -1), centro + Vector2(4, -1), c, 2.0)
			draw_line(centro + Vector2(-3, 0), centro + Vector2(0, 3), c, 1.0)
			draw_line(centro + Vector2(3, 0), centro + Vector2(0, 3), c, 1.0)
		"lanzar":
			draw_circle(centro, 2.5, c)
		_:
			# Flecha hacia arriba junto a una pared
			draw_line(centro + Vector2(-3, -4), centro + Vector2(-3, 4), c, 1.0)
			draw_line(centro + Vector2(2, 4), centro + Vector2(2, -3), c, 1.0)
			draw_line(centro + Vector2(2, -3), centro + Vector2(0, -1), c, 1.0)
			draw_line(centro + Vector2(2, -3), centro + Vector2(4, -1), c, 1.0)
