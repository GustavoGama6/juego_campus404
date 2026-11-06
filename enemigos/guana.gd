extends "res://enemigos/enemigo.gd"
# =====================================================================
#  GUANA CORRUPTA (iguana)
#  Normal: patrulla y, si Kin está enfrente a menos de ~6 tiles, embiste
#  rápido. Se derrota cayéndole encima.
#
#  Extraordinario: tiene el lomo ACORAZADO con púas (pisarla te lastima).
#  Cuando te ve, se prepara (tiembla) y EMBISTE sin detenerse hasta chocar:
#    - Si choca contra una pared o puerta: queda VOLTEADA unos segundos
#      y ahí sí se puede pisar.
#    - Si llega a una orilla: se cae al vacío y desaparece.
#    - Si pasa por pinchos: se destruye.
#  O sea: hay que usar el escenario para vencerla.
#  Arte: res://arte/guana.png (o guana.tres con "caminar", "embestir", "volteada")
# =====================================================================

enum { PATRULLA, PREPARA, EMBISTE, VOLTEADA, CAE }

var rango: float = 50.0
var velocidad: float = 32.0
var distancia_vista: float = 100.0
var origen_x: float = 0.0
var embistiendo: bool = false
var estado_g: int = PATRULLA
var timer_g: float = 0.0
var recorrido: float = 0.0
var vel_y: float = 0.0

func preparar() -> void:
	tamano = Vector2(24, 12)
	nombre_arte = "guana"
	origen_x = position.x
	if ext:
		pisable = false
		distancia_vista = 150.0

func mover(delta: float) -> void:
	if ext:
		_mover_extraordinario(delta)
	else:
		_mover_normal(delta)
	if arte:
		ARTE.animar(arte, "volteada" if estado_g == VOLTEADA else ("embestir" if embistiendo else "caminar"))
		arte.set("flip_v", estado_g == VOLTEADA)

func _ve_a_kin() -> bool:
	var j := jugador()
	if j == null:
		return false
	var dx: float = j.global_position.x - global_position.x
	return signf(dx) == direccion and absf(dx) < distancia_vista and absf(j.global_position.y - global_position.y) < 24.0

# ---------- Normal ----------
func _mover_normal(delta: float) -> void:
	embistiendo = _ve_a_kin()
	var vel: float = velocidad * (2.6 if embistiendo else 1.0)
	position.x += direccion * vel * delta
	if position.x > origen_x + rango:
		position.x = origen_x + rango
		if not embistiendo:
			direccion = -1.0
	elif position.x < origen_x - rango:
		position.x = origen_x - rango
		if not embistiendo:
			direccion = 1.0

# ---------- Extraordinario ----------
func _mover_extraordinario(delta: float) -> void:
	match estado_g:
		PATRULLA:
			embistiendo = false
			position.x += direccion * velocidad * delta
			if position.x > origen_x + rango:
				position.x = origen_x + rango
				direccion = -1.0
			elif position.x < origen_x - rango:
				position.x = origen_x - rango
				direccion = 1.0
			if _ve_a_kin():
				estado_g = PREPARA
				timer_g = 0.45
		PREPARA:
			timer_g -= delta
			if timer_g <= 0.0:
				estado_g = EMBISTE
				embistiendo = true
				recorrido = 0.0
		EMBISTE:
			var paso: float = direccion * 135.0 * delta
			# ¿Pared enfrente?
			var frente: Vector2 = global_position + Vector2(direccion * 13.0, -6.0)
			if not rayo(frente - Vector2(direccion * 4.0, 0), frente + Vector2(paso, 0)).is_empty():
				estado_g = VOLTEADA
				timer_g = 2.6
				embistiendo = false
				pisable = true
				Sonido.sfx("puerta")
				return
			position.x += paso
			recorrido += absf(paso)
			# ¿Se acabó el piso? -> se cae
			var pie: Vector2 = global_position + Vector2(direccion * 6.0, -2.0)
			if rayo(pie, pie + Vector2(0, 14)).is_empty():
				estado_g = CAE
				vel_y = 0.0
				return
			if recorrido > 480.0:
				estado_g = PATRULLA
				origen_x = position.x
		VOLTEADA:
			timer_g -= delta
			if timer_g <= 0.0:
				estado_g = PATRULLA
				pisable = false
				origen_x = position.x
				direccion = -direccion
		CAE:
			vel_y += 900.0 * delta
			position.y += vel_y * delta
			position.x += direccion * 40.0 * delta
			if position.y > 440.0:
				queue_free()

# En Extraordinario, el lomo con púas lastima (salvo volteada)
func _tocar_jugador(j) -> void:
	if estado_g == CAE:
		return
	super(j)

func _dibujar() -> void:
	var magenta := Color("#D81B8C")
	var verde := Color("#3E8E5A")
	if estado_g == VOLTEADA:
		draw_set_transform(Vector2(0, -12), 0.0, Vector2(1, -1))
	var tiembla: float = randf_range(-1.0, 1.0) if estado_g == PREPARA else 0.0
	if tiembla != 0.0:
		draw_set_transform(Vector2(tiembla, 0), 0.0, Vector2.ONE)
	var paso: float = 0.0 if congelado or estado_g == VOLTEADA else sin(tiempo * (20.0 if embistiendo else 10.0)) * 1.0
	# Cola larga
	rect_v(-20, -5, 8, 2, verde)
	rect_v(-14, -6, 4, 3, verde)
	# Cuerpo con manchas de glitch
	rect_v(-11, -10, 18, 7, verde)
	rect_v(-8, -11, 12, 2, magenta)
	rect_v(-3, -8, 3, 2, Color("#29E7FF"))
	# Lomo acorazado con púas (Extraordinario)
	if ext:
		for k in range(4):
			var x: float = -10.0 + float(k) * 4.5
			var izq: float = x if direccion > 0.0 else -(x + 4.0)
			draw_colored_polygon(PackedVector2Array([Vector2(izq, -11), Vector2(izq + 4.0, -11), Vector2(izq + 2.0, -16)]), Color("#29E7FF"))
	# Cabeza
	rect_v(7, -11, 7, 6, verde)
	rect_v(11, -10, 2, 2, Color("#F5D742") if not embistiendo and estado_g != PREPARA else Color("#FF4D4D"))
	# Patas
	rect_v(-9, -3 + paso, 3, 3, Color("#24583A"))
	rect_v(3, -3 - paso, 3, 3, Color("#24583A"))
	if embistiendo:
		rect_v(15, -9, 3, 1, Color("#F4F1EA"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if estado_g == VOLTEADA:
		# Estrellitas de mareo
		for k in range(3):
			var a: float = tiempo * 5.0 + float(k) * TAU / 3.0
			draw_rect(Rect2(Vector2(cos(a) * 9.0, -18.0 + sin(a) * 3.0), Vector2(2, 2)), Color("#F5C242"))
