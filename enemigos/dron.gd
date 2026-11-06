extends "res://enemigos/enemigo.gd"
# =====================================================================
#  DRON VIGÍA: vuela de un lado a otro haciendo ondas.
#  Ataque: si Kin pasa por debajo, se detiene (el ojo parpadea) y se lanza
#  en PICADA hacia donde estaba Kin; luego regresa a su altura.
#  Se derrota cayéndole encima (y rebotas: sirve para cruzar huecos).
#  Extraordinario: además DISPARA proyectiles de ruido apuntando a Kin.
#  Truco del escenario: dentro de la luz se congela y no puede disparar,
#  y la luz borra sus proyectiles.
#  El origen está en su centro.
#  Arte: res://arte/dron.png (o dron.tres con "volar", "aviso", "picada")
# =====================================================================

enum { VUELA, AVISO_PICADA, PICADA, SUBE, AVISO_DISPARO }

var rango: float = 100.0
var velocidad: float = 40.0
var amplitud: float = 12.0
var origen: Vector2 = Vector2.ZERO
var estado_d: int = VUELA
var timer_d: float = 0.0
var espera_picada: float = 1.0
var espera_disparo: float = 2.0
var meta: Vector2 = Vector2.ZERO
var x_patrulla: float = 0.0

func preparar() -> void:
	tamano = Vector2(16, 12)
	centrado = true
	nombre_arte = "dron"
	origen = position
	x_patrulla = position.x
	if ext:
		velocidad = 55.0
		espera_disparo = randf_range(1.0, 2.0)

func mover(delta: float) -> void:
	var j := jugador()
	espera_picada -= delta
	espera_disparo -= delta
	match estado_d:
		VUELA:
			x_patrulla += direccion * velocidad * delta
			if x_patrulla > origen.x + rango:
				x_patrulla = origen.x + rango
				direccion = -1.0
			elif x_patrulla < origen.x - rango:
				x_patrulla = origen.x - rango
				direccion = 1.0
			position = Vector2(x_patrulla, origen.y + sin(tiempo * 2.5) * amplitud)
			if j:
				var d: Vector2 = j.global_position + Vector2(0, -12) - global_position
				if espera_picada <= 0.0 and absf(d.x) < 40.0 and d.y > 20.0 and d.y < 160.0:
					estado_d = AVISO_PICADA
					timer_d = 0.4 if not ext else 0.3
				elif ext and espera_disparo <= 0.0 and d.length() < 230.0:
					estado_d = AVISO_DISPARO
					timer_d = 0.45
		AVISO_PICADA:
			timer_d -= delta
			if timer_d <= 0.0 and j:
				estado_d = PICADA
				meta = j.global_position + Vector2(0, -10)
				meta.y = minf(meta.y, origen.y + 170.0)
				Sonido.sfx("dash")
		PICADA:
			position = position.move_toward(meta, (260.0 if ext else 200.0) * delta)
			if position.distance_to(meta) < 1.0:
				estado_d = SUBE
		SUBE:
			position = position.move_toward(Vector2(position.x, origen.y), 70.0 * delta)
			if absf(position.y - origen.y) < 1.0:
				estado_d = VUELA
				x_patrulla = clampf(position.x, origen.x - rango, origen.x + rango)
				espera_picada = 1.5
		AVISO_DISPARO:
			timer_d -= delta
			if timer_d <= 0.0:
				estado_d = VUELA
				espera_disparo = 2.0
				if j:
					disparar(global_position + Vector2(0, 6), j.global_position + Vector2(0, -12), 115.0)
	if arte:
		ARTE.animar(arte, "picada" if estado_d == PICADA else ("aviso" if estado_d == AVISO_PICADA or estado_d == AVISO_DISPARO else "volar"))

func _dibujar() -> void:
	var gris := Color("#3A4A50")
	rect_v(-8, -4, 16, 8, gris)
	rect_v(-5, -6, 10, 2, Color("#9AA5A8"))
	# Hélices
	var giro: float = 0.0 if congelado else absf(sin(tiempo * 30.0)) * 4.0
	draw_line(Vector2(-10 - giro, -8), Vector2(-4 + giro, -8), Color("#F4F1EA"), 1.0)
	draw_line(Vector2(4 - giro, -8), Vector2(10 + giro, -8), Color("#F4F1EA"), 1.0)
	# Ojo: parpadea rápido cuando va a atacar
	var avisa: bool = estado_d == AVISO_PICADA or estado_d == AVISO_DISPARO
	var ojo: Color = Color("#D81B8C") if int(tiempo * (16.0 if avisa else 4.0)) % 2 == 0 else Color("#FF4D4D")
	if avisa:
		ojo = Color("#F5C242") if int(tiempo * 16.0) % 2 == 0 else Color("#FF4D4D")
	rect_v(2, -2, 4, 3, ojo)
	# Haz de vigilancia
	draw_line(Vector2(0, 4), Vector2(0, 10), Color(0.85, 0.1, 0.55, 0.4), 1.0)
	if estado_d == AVISO_DISPARO:
		draw_circle(Vector2(0, 6), 3.0 + sin(tiempo * 30.0), Color(0.85, 0.1, 0.55, 0.6))
