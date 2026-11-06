extends Area2D
# =====================================================================
#  PINCHOS GLITCH (sobre todo en el modo Extraordinario).
#  Si Kin los toca: pierde 1 vaso y regresa al último piso firme donde estuvo.
#  Si se queda sin vasos, regresa a la farola.
#  Los enemigos que caen o embisten contra ellos se destruyen (¡úsalo!).
#  (x, y) = esquina superior izquierda del espacio que ocupan.
#  orientacion: "arriba" (en el piso), "abajo" (en el techo),
#               "izquierda" o "derecha" (en una pared; apuntan hacia ese lado)
#  La hitbox es un poco más chica que el dibujo: las puntas perdonan 3 px.
#  Arte: res://arte/pinchos.png = UN pincho de 8 x 8 apuntando hacia arriba
#  (se repite y se gira solo).
# =====================================================================

const ARTE := preload("res://objetos/arte.gd")
const ALTO := 8.0

var largo: float = 32.0
var orientacion: String = "arriba"
var tiempo: float = 0.0
var textura: Texture2D = null

func _ready() -> void:
	add_to_group("trampa")
	z_index = 1
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	match orientacion:
		"arriba":
			f.size = Vector2(largo - 4.0, 5.0)
			c.position = Vector2(largo / 2.0, ALTO - 2.5)
		"abajo":
			f.size = Vector2(largo - 4.0, 5.0)
			c.position = Vector2(largo / 2.0, 2.5)
		"izquierda":
			f.size = Vector2(5.0, largo - 4.0)
			c.position = Vector2(ALTO - 2.5, largo / 2.0)
		_:
			f.size = Vector2(5.0, largo - 4.0)
			c.position = Vector2(2.5, largo / 2.0)
	c.shape = f
	add_child(c)
	textura = ARTE.textura("pinchos")

func _physics_process(delta: float) -> void:
	tiempo += delta
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.call("golpe_trampa")
	for a in get_overlapping_areas():
		if a.is_in_group("enemigo") and a.get("muere_con_trampas") and not a.get("muerto"):
			a.call("morir")
	if int(tiempo * 10.0) % 3 == 0:
		queue_redraw()

# u = a lo largo de los pinchos, v = altura desde la base hacia la punta
func _p(u: float, v: float) -> Vector2:
	match orientacion:
		"arriba":
			return Vector2(u, ALTO - v)
		"abajo":
			return Vector2(u, v)
		"izquierda":
			return Vector2(ALTO - v, u)
	return Vector2(v, u)

func _draw() -> void:
	var n: int = maxi(int(largo / 8.0), 1)
	var paso: float = largo / float(n)
	for k in range(n):
		var u0: float = float(k) * paso
		if textura:
			var angulo: float = {"arriba": 0.0, "abajo": PI, "izquierda": -PI / 2.0, "derecha": PI / 2.0}.get(orientacion, 0.0)
			var centro: Vector2 = _p(u0 + paso / 2.0, ALTO / 2.0)
			draw_set_transform(centro, angulo, Vector2(paso / 8.0, 1.0))
			draw_texture_rect(textura, Rect2(-4, -4, 8, 8), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			continue
		# Pincho provisional: triángulo magenta con punta cian (colores de "daño" del GDD)
		var tri := PackedVector2Array([_p(u0, 0.0), _p(u0 + paso, 0.0), _p(u0 + paso / 2.0, ALTO)])
		draw_colored_polygon(tri, Color("#D81B8C"))
		var punta := PackedVector2Array([_p(u0 + paso * 0.3, ALTO * 0.6), _p(u0 + paso * 0.7, ALTO * 0.6), _p(u0 + paso / 2.0, ALTO)])
		draw_colored_polygon(punta, Color("#29E7FF"))
	# Base oscura
	var b0: Vector2 = _p(0.0, 0.0)
	var b1: Vector2 = _p(largo, 1.5)
	draw_rect(Rect2(Vector2(minf(b0.x, b1.x), minf(b0.y, b1.y)), (b1 - b0).abs()), Color("#0B0B14"))
	# Brillo de glitch que recorre los pinchos
	var brillo: float = fmod(tiempo * 40.0, largo)
	draw_circle(_p(brillo, ALTO * 0.5), 1.5, Color(1, 1, 1, 0.6))
