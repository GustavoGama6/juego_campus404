extends "res://enemigos/enemigo.gd"
# NUBE DE RUIDO: estática que va y viene por un riel. Daña al tocarla y NO se
# puede derrotar. Se cruza en el momento justo o con el dash (el dash te hace
# invulnerable). El origen está en su centro.
# Arte: res://arte/nube_ruido.png (o .tres)

var punto_a: Vector2 = Vector2.ZERO
var punto_b: Vector2 = Vector2(0, 100)
var velocidad: float = 50.0
var progreso: float = 0.0

func preparar() -> void:
	tamano = Vector2(30, 30) if ext else Vector2(26, 26)
	centrado = true
	pisable = false
	muere_con_trampas = false
	nombre_arte = "nube_ruido"
	velocidad *= 1.5 if ext else 1.2      # Normal: un poco más rápida que antes

func mover(delta: float) -> void:
	var largo: float = maxf(punto_a.distance_to(punto_b), 1.0)
	progreso += delta * velocidad / largo
	var f: float = fmod(progreso, 2.0)
	if f > 1.0:
		f = 2.0 - f
	global_position = punto_a.lerp(punto_b, f)

func _dibujar() -> void:
	# Riel
	draw_line(punto_a - global_position, punto_b - global_position, Color(0.85, 0.1, 0.55, 0.25), 1.0)
	# Estática: cuadritos que cambian de lugar
	var semilla: int = int(tiempo * 12.0)
	for k in range(26):
		var h: int = (k * 73 + semilla * 31) % 997
		var x: float = float(h % 26) - 13.0
		var y: float = float((h / 26) % 26) - 13.0
		var c: Color = Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF")
		if congelado:
			c = Color(0.6, 0.7, 1.0)
		draw_rect(Rect2(x, y, 3, 3), c)
	draw_circle(Vector2.ZERO, 9.0, Color(0.04, 0.04, 0.08, 0.7))
