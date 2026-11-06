extends Node2D
# =====================================================================
#  FONDO DEL CAMPUS con efecto parallax (3 capas + cielo fijo).
#  variante: "plaza" (mañana), "biblioteca" (mediodía, interior),
#            "azotea" (atardecer que se vuelve noche al avanzar)
#  Para usar imágenes propias, guarda en res://arte/:
#    fondo_<variante>_cielo.png    (se estira a toda la pantalla)
#    fondo_<variante>_lejana.png   (se mueve al 15 %)
#    fondo_<variante>_media.png    (se mueve al 35 %)
#    fondo_<variante>_cercana.png  (se mueve al 60 %)
#  Las capas se repiten a lo ancho. Recomendado: 640 x 360 px con fondo transparente.
# =====================================================================

const ARTE := preload("res://objetos/arte.gd")

var variante: String = "plaza"
var ancho_nivel: float = 4000.0

func _ready() -> void:
	z_index = -10
	var capa_cielo := CanvasLayer.new()
	capa_cielo.layer = -10
	add_child(capa_cielo)
	var tex_cielo := ARTE.textura("fondo_%s_cielo" % variante)
	if tex_cielo:
		var img := TextureRect.new()
		img.texture = tex_cielo
		img.stretch_mode = TextureRect.STRETCH_SCALE
		img.set_anchors_preset(Control.PRESET_FULL_RECT)
		capa_cielo.add_child(img)
	else:
		var cielo := Cielo.new()
		cielo.variante = variante
		cielo.ancho_nivel = ancho_nivel
		capa_cielo.add_child(cielo)
	_capa("lejana", 0.15)
	_capa("media", 0.35)
	_capa("cercana", 0.6)

func _capa(tipo: String, velocidad: float) -> void:
	var p := Parallax2D.new()
	p.scroll_scale = Vector2(velocidad, velocidad)
	add_child(p)
	var tex := ARTE.textura("fondo_%s_%s" % [variante, tipo])
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
	c.variante = variante
	c.tipo = tipo
	c.ancho = 700.0 + ancho_nivel * velocidad
	p.add_child(c)


# ======================================================================
class Cielo extends Node2D:
	var variante: String = "plaza"
	var ancho_nivel: float = 4000.0
	var tiempo: float = 0.0

	func _process(delta: float) -> void:
		tiempo += delta
		queue_redraw()

	# 0 al inicio del nivel, 1 al final (para el atardecer que se hace noche)
	func _avance() -> float:
		var izq: float = -get_viewport().get_canvas_transform().origin.x
		return clampf(izq / maxf(ancho_nivel - 640.0, 1.0), 0.0, 1.0)

	func _draw() -> void:
		match variante:
			"biblioteca":
				_interior()
			"azotea":
				_atardecer()
			_:
				_manana()

	func _degradado(arriba: Color, abajo: Color, hasta: float) -> void:
		for k in range(36):
			var t: float = clampf(float(k * 10) / hasta, 0.0, 1.0)
			draw_rect(Rect2(0, k * 10, 640, 10), arriba.lerp(abajo, t))

	func _nubes(color: Color, velocidad: float) -> void:
		for k in range(5):
			var x: float = fmod(80.0 + float(k) * 170.0 + tiempo * velocidad * (1.0 + float(k) * 0.3), 820.0) - 90.0
			var y: float = 36.0 + float(k % 3) * 24.0
			draw_circle(Vector2(x, y), 11.0, color)
			draw_circle(Vector2(x + 13, y - 5), 14.0, color)
			draw_circle(Vector2(x + 28, y), 10.0, color)
			draw_rect(Rect2(x, y, 28, 9), color)

	func _manana() -> void:
		_degradado(Color("#5FAFDD"), Color("#D9F1F5"), 260.0)
		draw_circle(Vector2(520, 58), 32.0, Color(1.0, 0.97, 0.75, 0.25))
		draw_circle(Vector2(520, 58), 20.0, Color("#FFF2B8"))
		_nubes(Color(1, 1, 1, 0.85), 4.0)

	func _interior() -> void:
		# Pared del vestíbulo de la biblioteca
		draw_rect(Rect2(0, 0, 640, 360), Color("#E9DCC0"))
		var x: float = 0.0
		while x < 640.0:
			draw_rect(Rect2(x, 0, 2, 360), Color("#DCCCAA"))
			x += 80.0
		draw_rect(Rect2(0, 0, 640, 26), Color("#F4F1EA"))
		draw_rect(Rect2(0, 26, 640, 3), Color("#C9B48E"))

	func _atardecer() -> void:
		var a: float = _avance()
		var arriba: Color = Color("#F2833B").lerp(Color("#0E1030"), a)
		var medio: Color = Color("#F5C242").lerp(Color("#3B1E6D"), a)
		_degradado(arriba, medio, 300.0)
		# Sol que baja
		var sol_y: float = 120.0 + a * 220.0
		draw_circle(Vector2(470, sol_y), 34.0, Color(1.0, 0.7, 0.3, 0.3 * (1.0 - a)))
		draw_circle(Vector2(470, sol_y), 22.0, Color(1.0, 0.75, 0.35, 1.0 - a * 0.8))
		# Estrellas que aparecen
		if a > 0.3:
			for k in range(40):
				var sx: float = fmod(float(k) * 97.0, 640.0)
				var sy: float = fmod(float(k) * 53.0, 220.0)
				var brillo: float = (a - 0.3) * (0.6 + 0.4 * sin(tiempo * 2.0 + float(k)))
				draw_rect(Rect2(sx, sy, 1, 1), Color(1, 1, 1, brillo))
		_nubes(Color(1.0, 0.8, 0.7, 0.35 * (1.0 - a)), 3.0)


# ======================================================================
class Capa extends Node2D:
	var variante: String = "plaza"
	var tipo: String = "lejana"
	var ancho: float = 1400.0
	var tiempo: float = 0.0

	func azar(i: int) -> float:
		return absf(fmod(sin(float(i) * 12.9898) * 43758.5453, 1.0))

	func _process(delta: float) -> void:
		if tipo == "cercana":
			tiempo += delta
			queue_redraw()

	func _draw() -> void:
		match variante + "_" + tipo:
			"plaza_lejana":
				_mar_y_selva(Color("#7CC8D6"), Color("#6FB08A"))
			"plaza_media":
				_edificios_universidad()
			"plaza_cercana":
				_palmeras_y_arbustos(Color("#2F7D4F"))
			"biblioteca_lejana":
				_ventanales()
			"biblioteca_media":
				_estantes_lejanos()
			"biblioteca_cercana":
				_columnas_y_lamparas()
			"azotea_lejana":
				_ciudad_lejana()
			"azotea_media":
				_techos()
			"azotea_cercana":
				_antenas()

	# ---------------- Plaza ----------------
	func _mar_y_selva(mar: Color, selva: Color) -> void:
		draw_rect(Rect2(-220, 232, ancho + 220, 30), mar)
		draw_line(Vector2(-220, 232), Vector2(ancho, 232), Color("#BDEFF2"), 1.0)
		var pts := PackedVector2Array([Vector2(-220, 460)])
		var x: float = -220.0
		while x <= ancho:
			pts.append(Vector2(x, 255.0 + 8.0 * sin(x * 0.02) + 5.0 * sin(x * 0.07)))
			x += 16.0
		pts.append(Vector2(ancho, 460))
		draw_colored_polygon(pts, selva)

	func _edificios_universidad() -> void:
		var x: float = 40.0
		var i: int = 0
		while x < ancho:
			var w: float = 360.0 + azar(i) * 160.0
			var y0: float = 150.0
			draw_rect(Rect2(x, y0, w, 200), Color("#EDE8DC"))
			# Pisos con pasillos y barandales
			for piso in range(3):
				var py: float = y0 + 22.0 + piso * 52.0
				draw_rect(Rect2(x, py, w, 26), Color("#C9D1D3"))
				draw_line(Vector2(x, py + 14), Vector2(x + w, py + 14), Color("#9AA5A8"), 1.0)
			# Columnas blancas
			var c: float = x + 10.0
			while c < x + w - 10.0:
				draw_rect(Rect2(c, y0, 12, 200), Color("#F7F4EC"))
				c += 46.0
			draw_rect(Rect2(x - 6, y0 - 8, w + 12, 10), Color("#F7F4EC"))
			x += w + 120.0 + azar(i + 7) * 80.0
			i += 1

	func _palmeras_y_arbustos(verde: Color) -> void:
		var b: float = -220.0
		var m: int = 0
		while b < ancho:
			draw_circle(Vector2(b, 318.0 + azar(m) * 6.0), 18.0 + azar(m + 3) * 10.0, verde)
			b += 40.0
			m += 1
		var p: float = 120.0
		var j: int = 0
		while p < ancho:
			_palmera(p, 320.0, 120.0 + azar(j + 30) * 50.0)
			p += 260.0 + azar(j) * 200.0
			j += 1

	func _palmera(x: float, base_y: float, alto: float) -> void:
		var tronco := Color("#7A5E3A")
		var hoja := Color("#2F7D4F")
		var punta := Vector2(x + 14.0, base_y - alto)
		draw_line(Vector2(x, base_y), Vector2(x + 8.0, base_y - alto * 0.5), tronco, 5.0)
		draw_line(Vector2(x + 8.0, base_y - alto * 0.5), punta, tronco, 4.0)
		for k in range(7):
			var a: float = -PI + float(k) * PI / 6.0
			var fin := punta + Vector2(cos(a) * 34.0, sin(a) * 12.0 + 14.0)
			draw_colored_polygon(PackedVector2Array([punta, fin + Vector2(0, -3), fin + Vector2(0, 3)]), hoja)

	# ---------------- Biblioteca ----------------
	func _ventanales() -> void:
		var x: float = 30.0
		while x < ancho:
			draw_rect(Rect2(x, 40, 120, 200), Color("#F4F1EA"))
			draw_rect(Rect2(x + 6, 46, 108, 188), Color("#9ED8EE"))
			draw_line(Vector2(x + 60, 46), Vector2(x + 60, 234), Color("#F4F1EA"), 3.0)
			draw_line(Vector2(x + 6, 140), Vector2(x + 114, 140), Color("#F4F1EA"), 3.0)
			draw_rect(Rect2(x + 10, 50, 40, 40), Color(1, 1, 1, 0.25))
			x += 300.0

	func _estantes_lejanos() -> void:
		var x: float = 0.0
		var i: int = 0
		while x < ancho:
			var w: float = 140.0
			draw_rect(Rect2(x, 150, w, 220), Color("#9C7A55"))
			var y: float = 160.0
			while y < 360.0:
				var bx: float = x + 4.0
				var k: int = 0
				while bx < x + w - 4.0:
					var cols := [Color("#C26A5E"), Color("#6FB8C2"), Color("#E3C46E"), Color("#7FA884")]
					draw_rect(Rect2(bx, y, 5, 16), cols[(k + i) % 4].darkened(0.15))
					bx += 6.0
					k += 1
				draw_rect(Rect2(x, y + 16, w, 3), Color("#7A5A3A"))
				y += 26.0
			x += w + 90.0
			i += 1

	func _columnas_y_lamparas() -> void:
		var x: float = 60.0
		var i: int = 0
		while x < ancho:
			draw_rect(Rect2(x, -40, 26, 420), Color("#F4F1EA"))
			draw_rect(Rect2(x + 20, -40, 6, 420), Color("#DDD6C6"))
			var lx: float = x + 160.0
			var mece: float = sin(tiempo + float(i)) * 2.0
			draw_line(Vector2(lx, 0), Vector2(lx + mece, 60), Color("#4C5A63"), 1.0)
			draw_rect(Rect2(lx - 10 + mece, 60, 20, 8), Color("#4C5A63"))
			draw_circle(Vector2(lx + mece, 70), 10.0, Color(1, 0.9, 0.6, 0.25))
			x += 380.0
			i += 1

	# ---------------- Azotea ----------------
	func _ciudad_lejana() -> void:
		draw_rect(Rect2(-220, 250, ancho + 220, 20), Color("#3E5A7A"))
		var x: float = -220.0
		var i: int = 0
		while x < ancho:
			var w: float = 26.0 + azar(i) * 40.0
			var h: float = 30.0 + azar(i + 11) * 90.0
			draw_rect(Rect2(x, 262.0 - h, w, h + 200.0), Color("#4A3A66"))
			for v in range(int(h / 14.0)):
				if azar(i * 7 + v) > 0.55:
					draw_rect(Rect2(x + 5, 262.0 - h + 6.0 + v * 14.0, 4, 4), Color(1, 0.85, 0.5, 0.7))
			x += w + 10.0 + azar(i + 5) * 30.0
			i += 1
		draw_rect(Rect2(-220, 262, ancho + 220, 200), Color("#2E4A3E"))

	func _techos() -> void:
		var x: float = 0.0
		var i: int = 0
		while x < ancho:
			# Tinaco y equipo de aire
			draw_rect(Rect2(x, 250, 220, 200), Color("#3A3550"))
			draw_rect(Rect2(x + 30, 216, 30, 34), Color("#4C4566"))
			draw_rect(Rect2(x + 26, 210, 38, 8), Color("#57507A"))
			draw_rect(Rect2(x + 120, 232, 50, 18), Color("#4C4566"))
			draw_circle(Vector2(x + 145, 241), 6.0, Color("#3A3550"))
			x += 300.0 + azar(i) * 140.0
			i += 1

	func _antenas() -> void:
		var x: float = 80.0
		var i: int = 0
		while x < ancho:
			var h: float = 140.0 + azar(i) * 80.0
			draw_line(Vector2(x, 360), Vector2(x, 360.0 - h), Color("#2A2638"), 3.0)
			for k in range(3):
				var y: float = 360.0 - h + 20.0 + k * 18.0
				draw_line(Vector2(x - 12, y), Vector2(x + 12, y), Color("#2A2638"), 2.0)
			var parpadeo: float = 0.5 + 0.5 * sin(tiempo * 3.0 + float(i))
			draw_circle(Vector2(x, 360.0 - h), 3.0, Color(1, 0.2, 0.3, parpadeo))
			x += 420.0 + azar(i + 3) * 200.0
			i += 1
		draw_rect(Rect2(-220, 336, ancho + 220, 40), Color("#2A2638"))
