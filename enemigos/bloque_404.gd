extends Area2D
# Bloque "404" que cae del techo (ataque del jefe). Primero avisa con una
# sombra en el piso y luego cae. Daña al tocarlo.

var piso_y: float = 320.0
var techo_y: float = 0.0
var aviso: float = 0.7
var vel: float = 0.0
var cayendo: bool = false
var choco: float = -1.0
var tiempo: float = 0.0

func _ready() -> void:
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = Vector2(22, 16)
	c.shape = f
	add_child(c)
	position.y = techo_y

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	if choco >= 0.0:
		choco -= delta
		if choco < 0.0:
			queue_free()
		return
	if not cayendo:
		aviso -= delta
		if aviso <= 0.0:
			cayendo = true
		return
	vel += 900.0 * delta
	position.y += vel * delta
	if position.y >= piso_y - 8.0:
		position.y = piso_y - 8.0
		choco = 0.15
		Sonido.sfx("glitch")
		set_deferred("monitoring", false)
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("danar", 1, global_position)

func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	if not cayendo:
		# Sombra de aviso en el piso
		var sombra_y: float = piso_y - position.y
		var parpadeo: float = 0.35 + 0.35 * sin(tiempo * 30.0)
		draw_rect(Rect2(-12, sombra_y - 3, 24, 3), Color(0.85, 0.1, 0.55, parpadeo))
	var alfa: float = 1.0 if choco < 0.0 else choco / 0.15
	draw_rect(Rect2(-11, -8, 22, 16), Color(0.04, 0.04, 0.08, alfa))
	draw_rect(Rect2(-11, -8, 22, 16), Color(0.85, 0.1, 0.55, alfa), false, 1.0)
	draw_string(fuente, Vector2(-10, 4), "404", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.16, 0.9, 1.0, alfa))
