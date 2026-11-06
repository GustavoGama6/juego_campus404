extends Node2D
# Fondo ambientado de selva y lago, dibujado todo con código (sin imágenes).
#   - Cielo fijo con sol y nubes (no se mueve con la cámara).
#   - 3 capas con efecto parallax: entre más lejos, más lento se mueven.
#       lejana  (0.15): cerros y pirámides mayas
#       media   (0.35): copas de la selva y palmeras
#       cercana (0.60): troncos, lianas, arbustos y luciérnagas
# Para usar imágenes propias guarda en res://arte/ (igual que el campus):
#   fondo_selva_cielo.png, fondo_selva_lejana.png, fondo_selva_media.png, fondo_selva_cercana.png

const ARTE := preload("res://objetos/arte.gd")

@export var ancho_nivel: float = 4400.0

func _ready() -> void:
	# Cielo fijo detrás de todo
	var capa_cielo := CanvasLayer.new()
	capa_cielo.layer = -10
	add_child(capa_cielo)
	var tex_cielo := ARTE.textura("fondo_selva_cielo")
	if tex_cielo:
		var img := TextureRect.new()
		img.texture = tex_cielo
		img.stretch_mode = TextureRect.STRETCH_SCALE
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		capa_cielo.add_child(img)
	else:
		capa_cielo.add_child(Cielo.new())

	_crear_capa("lejana", 0.15)
	_crear_capa("media", 0.35)
	_crear_capa("cercana", 0.6)

func _crear_capa(tipo: String, velocidad: float) -> void:
	var p := Parallax2D.new()
	p.scroll_scale = Vector2(velocidad, velocidad)
	add_child(p)
	var tex := ARTE.textura("fondo_selva_" + tipo)
	if tex:
		var s := Sprite2D.new()
		s.texture = tex
		s.centered = false
		s.position = Vector2(0, 360.0 - tex.get_height())
		p.repeat_size = Vector2(tex.get_width(), 0)
		p.repeat_times = 4
		p.add_child(s)
		return
	var c := Capa.new()
	c.tipo = tipo
	# Ancho necesario para que la capa nunca se acabe al recorrer el nivel
	c.ancho = 700.0 + ancho_nivel * velocidad
	p.add_child(c)

# ======================================================================
#  CIELO
# ======================================================================
class Cielo extends Node2D:
	var tiempo: float = 0.0

	func _process(delta: float) -> void:
		tiempo += delta
		queue_redraw()

	func _draw() -> void:
		var arriba := Color("#5FAFDD")
		var horizonte := Color("#D9F1DA")
		for k in range(36):
			var t: float = clampf(float(k) / 26.0, 0.0, 1.0)
			draw_rect(Rect2(0, k * 10, 640, 10), arriba.lerp(horizonte, t))
		# Sol
		draw_circle(Vector2(510, 62), 34.0, Color(1.0, 0.97, 0.75, 0.25))
		draw_circle(Vector2(510, 62), 22.0, Color("#FFF2B8"))
		# Nubes que avanzan lento
		for k in range(5):
			var x: float = fmod(80.0 + float(k) * 170.0 + tiempo * (4.0 + float(k)), 820.0) - 90.0
			var y: float = 40.0 + float(k % 3) * 26.0
			var blanco := Color(1, 1, 1, 0.85)
			draw_circle(Vector2(x, y), 12.0, blanco)
			draw_circle(Vector2(x + 14, y - 5), 15.0, blanco)
			draw_circle(Vector2(x + 30, y), 11.0, blanco)
			draw_rect(Rect2(x, y, 30, 10), blanco)


# ======================================================================
#  CAPAS CON PARALLAX
# ======================================================================
class Capa extends Node2D:
	var tipo: String = "lejana"
	var ancho: float = 1400.0
	var tiempo: float = 0.0

	# Número "al azar" pero siempre igual para la misma i (así no parpadea)
	func azar(i: int) -> float:
		return absf(fmod(sin(float(i) * 12.9898) * 43758.5453, 1.0))

	func _process(delta: float) -> void:
		# Solo la capa cercana tiene cosas que se mueven
		if tipo == "cercana":
			tiempo += delta
			queue_redraw()

	func _draw() -> void:
		match tipo:
			"lejana":
				_lejana()
			"media":
				_media()
			_:
				_cercana()

	# ---------- Cerros y pirámides mayas ----------
	func _lejana() -> void:
		var x0: float = -220.0
		var cerros := PackedVector2Array()
		cerros.append(Vector2(x0, 440))
		var x: float = x0
		while x <= ancho:
			var y: float = 205.0 + 22.0 * sin(x * 0.004) + 12.0 * sin(x * 0.013 + 1.3)
			cerros.append(Vector2(x, y))
			x += 20.0
		cerros.append(Vector2(ancho, 440))
		draw_colored_polygon(cerros, Color("#9CCDB9"))

		# Pirámides escalonadas
		var px: float = 180.0
		while px < ancho:
			_piramide(px, 238.0, Color("#86B9A5"))
			px += 640.0

		# Lago a lo lejos
		draw_rect(Rect2(x0, 268, ancho - x0, 180), Color("#7CC3C6"))
		draw_line(Vector2(x0, 268), Vector2(ancho, 268), Color("#B6E3E0"), 1.0)

	func _piramide(cx: float, base_y: float, c: Color) -> void:
		var ancho_base: float = 150.0
		for k in range(6):
			var w: float = ancho_base - float(k) * 22.0
			draw_rect(Rect2(cx - w / 2.0, base_y - float(k + 1) * 12.0, w, 12.0), c)
		# Templo de arriba
		draw_rect(Rect2(cx - 14, base_y - 86, 28, 14), c)
		draw_rect(Rect2(cx - 5, base_y - 80, 10, 8), c.darkened(0.15))
		# Escalinata
		draw_rect(Rect2(cx - 7, base_y - 72, 14, 72), c.lightened(0.08))

	# ---------- Copas de la selva y palmeras ----------
	func _media() -> void:
		var verde := Color("#4F9A68")
		var oscuro := Color("#3F865A")
		draw_rect(Rect2(-220, 262, ancho + 220, 200), verde)
		var x: float = -220.0
		var i: int = 0
		while x < ancho:
			var r: float = 26.0 + azar(i) * 18.0
			draw_circle(Vector2(x, 262.0 + 6.0 * sin(float(i) * 0.9)), r, verde if i % 2 == 0 else oscuro)
			x += 34.0
			i += 1
		# Palmeras
		var p: float = 60.0
		var j: int = 0
		while p < ancho:
			_palmera(p, 250.0, 80.0 + azar(j + 30) * 30.0)
			p += 190.0 + azar(j) * 120.0
			j += 1

	func _palmera(x: float, base_y: float, alto: float) -> void:
		var tronco := Color("#6E5A3C")
		var hoja := Color("#3C7F52")
		var punta := Vector2(x + 10.0, base_y - alto)
		draw_line(Vector2(x, base_y), Vector2(x + 6.0, base_y - alto * 0.5), tronco, 4.0)
		draw_line(Vector2(x + 6.0, base_y - alto * 0.5), punta, tronco, 3.0)
		for k in range(6):
			var a: float = -PI + float(k) * PI / 5.0
			var fin := punta + Vector2(cos(a) * 26.0, sin(a) * 10.0 + 10.0)
			draw_colored_polygon(PackedVector2Array([punta, fin + Vector2(0, -3), fin + Vector2(0, 3)]), hoja)

	# ---------- Troncos, lianas, arbustos y luciérnagas ----------
	func _cercana() -> void:
		var hojas := Color("#2E6B45")
		var tronco := Color("#4A3524")
		var liana := Color("#3A8A4B")
		# Árboles grandes
		var x: float = -100.0
		var i: int = 0
		while x < ancho:
			draw_rect(Rect2(x, -120, 22, 560), tronco)
			draw_line(Vector2(x + 6, -120), Vector2(x + 6, 440), tronco.darkened(0.2), 2.0)
			for k in range(5):
				draw_circle(Vector2(x + 11 + (float(k) - 2.0) * 22.0, -60.0 + azar(i * 5 + k) * 30.0), 30.0, hojas)
			x += 300.0 + azar(i) * 140.0
			i += 1
		# Lianas colgando (se mecen un poco)
		var v: float = -60.0
		var n: int = 0
		while v < ancho:
			var largo: float = 60.0 + azar(n + 77) * 110.0
			var mece: float = sin(tiempo * 1.5 + float(n)) * 3.0
			var fin := Vector2(v + mece, -40.0 + largo)
			draw_line(Vector2(v, -40), fin, liana, 2.0)
			var y: float = -30.0
			while y < -40.0 + largo:
				var t: float = (y + 40.0) / largo
				var lx: float = v + mece * t
				draw_colored_polygon(PackedVector2Array([Vector2(lx, y), Vector2(lx + 5, y - 2), Vector2(lx + 2, y + 3)]), liana)
				y += 16.0
			v += 70.0 + azar(n) * 90.0
			n += 1
		# Arbustos al fondo de la orilla
		var b: float = -220.0
		var m: int = 0
		while b < ancho:
			draw_circle(Vector2(b, 318.0 + azar(m) * 6.0), 22.0 + azar(m + 3) * 10.0, hojas)
			b += 36.0
			m += 1
		# Luciérnagas
		for k in range(40):
			var fx: float = azar(k) * ancho + sin(tiempo * 0.8 + float(k)) * 12.0
			var fy: float = 120.0 + azar(k + 200) * 170.0 + cos(tiempo * 1.1 + float(k)) * 8.0
			var brillo: float = 0.35 + 0.35 * sin(tiempo * 3.0 + float(k) * 1.7)
			draw_circle(Vector2(fx, fy), 2.5, Color(1.0, 0.95, 0.5, brillo * 0.4))
			draw_circle(Vector2(fx, fy), 1.0, Color(1.0, 1.0, 0.7, brillo + 0.2))
