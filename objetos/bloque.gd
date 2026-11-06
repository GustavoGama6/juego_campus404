extends StaticBody2D
# =====================================================================
#  BLOQUE SÓLIDO. La colisión siempre mide lo mismo que el dibujo.
#  Estilos: "concreto", "escalon", "columna", "pasillo", "piso", "estante",
#           "mesa", "azotea", "metal", "nucleo", "tierra", "piedra", "tronco", "hojas"
#  Arte: res://arte/bloque_<estilo>.png se repite como mosaico (ej. bloque_concreto.png)
#  La posición (position) es el CENTRO del bloque.
# =====================================================================

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(160, 40)
var estilo: String = "concreto"
var textura: Texture2D = null

func _ready() -> void:
	add_to_group("suelo_seguro")   # piso firme: aquí regresas si caes en una trampa
	var c := CollisionShape2D.new()
	c.name = "CollisionShape2D"
	var f := RectangleShape2D.new()
	f.size = tamano
	c.shape = f
	add_child(c)
	textura = ARTE.textura("bloque_" + estilo)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func _draw() -> void:
	var r := Rect2(-tamano / 2.0, tamano)
	if textura:
		draw_texture_rect(textura, r, true)
		return
	match estilo:
		"columna":
			_columna(r)
		"pasillo":
			_pasillo(r)
		"piso":
			_piso(r)
		"estante":
			_estante(r)
		"mesa":
			_mesa(r)
		"azotea":
			_azotea(r)
		"metal":
			_metal(r)
		"nucleo":
			_nucleo(r)
		"tierra":
			_tierra(r)
		"piedra":
			_piedra(r)
		"tronco":
			_tronco(r)
		"hojas":
			_hojas(r)
		"escalon":
			_concreto(r)
			draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), Color("#F4F1EA"))
		_:
			_concreto(r)

func _azar(i: int) -> float:
	return absf(fmod(sin(float(i) * 12.9898 + position.x * 0.013) * 43758.5453, 1.0))

func _concreto(r: Rect2) -> void:
	draw_rect(r, Color("#9AA5A8"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#C9D1D3"))
	var x: float = r.position.x + 32.0
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y + 2), Vector2(x, r.end.y), Color("#8A9598"), 1.0)
		x += 32.0
	for i in range(int(r.size.x / 14.0)):
		draw_rect(Rect2(r.position.x + 5.0 + i * 14.0, r.position.y + 6.0 + _azar(i) * maxf(r.size.y - 10.0, 1.0), 2, 1), Color("#8A9598"))

func _columna(r: Rect2) -> void:
	draw_rect(r, Color("#F4F1EA"))
	draw_rect(Rect2(r.position, Vector2(3, r.size.y)), Color("#FFFFFF"))
	draw_rect(Rect2(r.end.x - 4.0, r.position.y, 4, r.size.y), Color("#D9D4C8"))
	var x: float = r.position.x + 8.0
	while x < r.end.x - 6.0:
		draw_line(Vector2(x, r.position.y + 4), Vector2(x, r.end.y - 4), Color("#E2DDD0"), 1.0)
		x += 8.0

func _pasillo(r: Rect2) -> void:
	draw_rect(r, Color("#F4F1EA"))
	draw_rect(Rect2(r.position.x, r.position.y + 3, r.size.x, 2), Color("#C9D1D3"))
	draw_rect(Rect2(r.position.x, r.end.y - 3, r.size.x, 3), Color("#B8B2A6"))
	# Barandal metálico (frente del pasillo)
	var x: float = r.position.x + 6.0
	while x < r.end.x:
		draw_rect(Rect2(x, r.position.y + 5, 1, r.size.y - 8), Color("#9AA5A8"))
		x += 12.0

func _piso(r: Rect2) -> void:
	draw_rect(r, Color("#C8A97E"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 3)), Color("#E3C99E"))
	var x: float = r.position.x
	var i: int = 0
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y + 3), Vector2(x, r.end.y), Color("#A88B62"), 1.0)
		x += 24.0 + (8.0 if i % 2 == 0 else 0.0)
		i += 1

func _estante(r: Rect2) -> void:
	draw_rect(r, Color("#6B4423"))
	var y: float = r.position.y + 4.0
	var fila: int = 0
	while y < r.end.y - 4.0:
		var x: float = r.position.x + 3.0
		var k: int = 0
		while x < r.end.x - 4.0:
			var ancho: float = 3.0 + _azar(k + fila * 17) * 3.0
			var alto: float = 9.0 + _azar(k + fila * 31 + 5) * 4.0
			var colores := [Color("#B03A2E"), Color("#1FB6C1"), Color("#F5C242"), Color("#2F7D4F"), Color("#F4F1EA")]
			draw_rect(Rect2(x, y + 14.0 - alto, ancho, alto), colores[(k + fila) % colores.size()])
			x += ancho + 1.0
			k += 1
		draw_rect(Rect2(r.position.x, y + 14.0, r.size.x, 2), Color("#4A2E15"))
		y += 16.0
		fila += 1

func _mesa(r: Rect2) -> void:
	draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), Color("#8B5A2B"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#B07D46"))
	draw_rect(Rect2(r.position.x + 3, r.position.y + 5, 3, r.size.y - 5), Color("#5E3718"))
	draw_rect(Rect2(r.end.x - 6, r.position.y + 5, 3, r.size.y - 5), Color("#5E3718"))

func _azotea(r: Rect2) -> void:
	draw_rect(r, Color("#8E8A8F"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 4)), Color("#B9B4BB"))
	draw_rect(Rect2(r.position.x, r.position.y + 4, r.size.x, 2), Color("#6E6A70"))
	var x: float = r.position.x + 40.0
	while x < r.end.x:
		draw_rect(Rect2(x, r.position.y + 10, 2, r.size.y - 10), Color("#7C787E"))
		x += 40.0

func _metal(r: Rect2) -> void:
	draw_rect(r, Color("#4C5A63"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#8FA3AE"))
	var x: float = r.position.x + 3.0
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y + 2), Vector2(x + 3, r.end.y), Color("#3A464D"), 1.0)
		x += 6.0

func _nucleo(r: Rect2) -> void:
	draw_rect(r, Color("#14141F"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#29E7FF"))
	var x: float = r.position.x + 20.0
	while x < r.end.x:
		draw_rect(Rect2(x, r.position.y + 8, 10, 1), Color(0.16, 0.9, 1.0, 0.5))
		x += 40.0

func _tierra(r: Rect2) -> void:
	draw_rect(r, Color("#6B4423"))
	for i in range(int(r.size.x / 10.0)):
		draw_rect(Rect2(r.position.x + 4.0 + i * 10.0, r.position.y + 10.0 + _azar(i + 50) * maxf(r.size.y - 14.0, 1.0), 3, 2), Color("#56351A"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), Color("#3F9B48"))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#7BD07A"))
	var x: float = r.position.x
	var i2: int = 0
	while x < r.end.x - 4.0:
		var alto: float = 2.0 + _azar(i2 + 100) * 3.0
		draw_colored_polygon(PackedVector2Array([Vector2(x, r.position.y), Vector2(x + 2, r.position.y - alto), Vector2(x + 4, r.position.y)]), Color("#3F9B48"))
		x += 6.0
		i2 += 1

func _piedra(r: Rect2) -> void:
	draw_rect(r, Color("#8C8677"))
	var fila: int = 0
	var y: float = r.position.y
	while y < r.end.y:
		draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color("#6E695C"), 1.0)
		var x: float = r.position.x + (12.0 if fila % 2 == 1 else 0.0)
		while x < r.end.x:
			draw_line(Vector2(x, y), Vector2(x, minf(y + 16.0, r.end.y)), Color("#6E695C"), 1.0)
			x += 24.0
		y += 16.0
		fila += 1
	draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#A9A392"))
	draw_rect(Rect2(r.position, Vector2(minf(r.size.x, 20.0), 3)), Color("#4E7A3A"))

func _tronco(r: Rect2) -> void:
	draw_rect(r, Color("#7A4A22"))
	if r.size.y > r.size.x * 1.2:
		var x: float = r.position.x + 5.0
		while x < r.end.x - 2.0:
			draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color("#5E3718"), 1.0)
			x += 7.0
		draw_rect(Rect2(r.position, Vector2(r.size.x, 4)), Color("#9C6533"))
	else:
		var y: float = r.position.y + 4.0
		while y < r.end.y - 1.0:
			draw_line(Vector2(r.position.x, y), Vector2(r.end.x, y), Color("#5E3718"), 1.0)
			y += 5.0
		draw_rect(Rect2(r.position, Vector2(r.size.x, 2)), Color("#9C6533"))
		var radio: float = minf(r.size.y / 2.0, 10.0)
		draw_circle(Vector2(r.position.x + 1.0, r.get_center().y), radio * 0.6, Color("#B07D46"))
		draw_circle(Vector2(r.end.x - 1.0, r.get_center().y), radio * 0.6, Color("#B07D46"))

func _hojas(r: Rect2) -> void:
	draw_rect(Rect2(r.position.x, r.position.y + 6.0, r.size.x, r.size.y - 6.0), Color("#5E3718"))
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 8.0), Color("#2F7D3A"))
	var x: float = r.position.x + 5.0
	var i: int = 0
	while x < r.end.x - 2.0:
		draw_circle(Vector2(x, r.position.y + 2.0), 5.0 + _azar(i) * 1.5, Color("#3E934A"))
		x += 9.0
		i += 1
