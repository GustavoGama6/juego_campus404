extends "res://enemigos/enemigo.gd"
# =====================================================================
#  BUG: camina de un lado a otro sobre su plataforma.
#  Ataque: si Kin está cerca, da un SALTITO hacia él.
#  Se derrota cayéndole encima.
#  Extraordinario: es más rápido, salta más seguido y cada tanto saca PÚAS
#  (parpadea cian antes). Con las púas fuera NO se puede pisar: espera a
#  que las guarde, o atráelo a unos pinchos / al vacío.
#  Arte: res://arte/bug.png (o bug.tres con "caminar", "saltar", "puas")
# =====================================================================

var rango: float = 60.0          # cuánto camina hacia cada lado de su punto inicial
var velocidad: float = 38.0
var origen_x: float = 0.0
var base_y: float = 0.0

# Saltito hacia Kin
var espera_salto: float = 1.6
var fuerza_salto: float = -170.0
var timer_salto: float = 1.0
var vel_y: float = 0.0
var en_aire: bool = false

# Púas (solo Extraordinario)
var puas: bool = false
var timer_puas: float = 2.0

func preparar() -> void:
	tamano = Vector2(16, 12)
	nombre_arte = "bug"
	origen_x = position.x
	base_y = position.y
	if ext:
		velocidad = 52.0
		espera_salto = 1.0
		fuerza_salto = -220.0
		timer_puas = randf_range(0.8, 2.0)

func mover(delta: float) -> void:
	var j := jugador()
	if en_aire:
		vel_y += 900.0 * delta
		position.y += vel_y * delta
		position.x = clampf(position.x + direccion * velocidad * 1.5 * delta, origen_x - rango, origen_x + rango)
		if position.y >= base_y:
			position.y = base_y
			en_aire = false
	else:
		position.x += direccion * velocidad * delta
		if position.x > origen_x + rango:
			position.x = origen_x + rango
			direccion = -1.0
		elif position.x < origen_x - rango:
			position.x = origen_x - rango
			direccion = 1.0
		timer_salto -= delta
		if j and timer_salto <= 0.0:
			var dx: float = j.global_position.x - global_position.x
			var dy: float = j.global_position.y - global_position.y
			# Normal: solo salta si Kin está a su altura (pisarlo desde arriba sigue siendo seguro)
			if absf(dx) < 90.0 and absf(dy) < (40.0 if ext else 16.0):
				direccion = signf(dx) if dx != 0.0 else direccion
				vel_y = fuerza_salto
				en_aire = true
				timer_salto = espera_salto
	if ext:
		timer_puas -= delta
		if timer_puas <= 0.0:
			puas = not puas
			timer_puas = 1.1 if puas else 1.8
		pisable = not puas
	if arte:
		ARTE.animar(arte, "puas" if puas else ("saltar" if en_aire else "caminar"))

# Púas a punto de salir: parpadeo de aviso
func avisando() -> bool:
	return ext and not puas and timer_puas < 0.4

func _dibujar() -> void:
	var pata: float = 0.0 if congelado or en_aire else sin(tiempo * 14.0) * 1.5
	var cuerpo: Color = Color("#D81B8C")
	if avisando() and int(tiempo * 20.0) % 2 == 0:
		cuerpo = Color("#29E7FF")
	rect_v(-7, -10, 14, 8, cuerpo)
	rect_v(-5, -12, 10, 3, cuerpo)
	rect_v(3, -10, 2, 2, Color("#29E7FF"))
	rect_v(-6, -2, 2, 2 + pata, Color("#0B0B14"))
	rect_v(-1, -2, 2, 2 - pata, Color("#0B0B14"))
	rect_v(4, -2, 2, 2 + pata, Color("#0B0B14"))
	if puas:
		for k in range(4):
			var x: float = -7.0 + float(k) * 4.0
			draw_colored_polygon(PackedVector2Array([Vector2(x, -12), Vector2(x + 4.0, -12), Vector2(x + 2.0, -18)]), Color("#29E7FF"))
	# Píxeles sueltos de glitch
	if int(tiempo * 8.0) % 3 == 0:
		rect_v(-9, -8, 2, 2, Color("#29E7FF"))
