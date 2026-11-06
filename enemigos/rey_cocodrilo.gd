extends Area2D
# EL REY COCODRILO (miniboss del lago)
# Duerme hasta que el nivel llama a despertar(). Después repite este ciclo:
#   1. PATRULLA:      camina de un lado a otro de la arena.
#   2. BOCA_ABIERTA:  se detiene, te mira y abre la boca. ¡Ahora sí come!
#   3. EMBESTIDA:     corre rápido hacia ti. Sáltalo.
# Cada pescado que le entra con la boca abierta le quita 1 de vida.
# Con la boca cerrada la comida rebota y no le hace nada.
# Si le caes encima rebotas (no le hace daño). Si te toca de lado, pierdes energía.
# El origen (position) está a la altura de sus patas.

signal despertado
signal vida_cambio(vida: int, maxima: int)
signal derrotado

@export var vida_maxima: int = 5
@export var limite_izq: float = 3410.0       # x mínima de su centro (borde de la arena)
@export var limite_der: float = 3770.0       # x máxima de su centro
@export var velocidad_patrulla: float = 45.0
@export var velocidad_embestida: float = 120.0
@export var tiempo_patrulla: float = 2.2
@export var tiempo_boca_abierta: float = 2.4
@export var tiempo_embestida: float = 1.6

enum { DORMIDO, PATRULLA, BOCA_ABIERTA, EMBESTIDA, ATURDIDO, DERROTADO }

var estado: int = DORMIDO
var vida: int = 5
var direccion: float = -1.0
var timer: float = 0.0
var tiempo: float = 0.0
var destello: float = 0.0
var texto: String = ""
var texto_timer: float = 0.0
var arte: Node2D = null   # res://arte/rey_cocodrilo.png o .tres (dormido, patrulla, boca_abierta, embestida, aturdido, derrotado)

const ARTE := preload("res://objetos/arte.gd")
const NOMBRES_ESTADO := ["dormido", "patrulla", "boca_abierta", "embestida", "aturdido", "derrotado"]

func _ready() -> void:
	vida = vida_maxima
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(72, 26)
	colision.shape = forma
	colision.position = Vector2(0, -13)
	add_child(colision)
	arte = ARTE.poner(self, "rey_cocodrilo")

func despertar() -> void:
	if estado != DORMIDO:
		return
	estado = PATRULLA
	timer = 1.0
	_mirar_jugador()
	despertado.emit()
	vida_cambio.emit(vida, vida_maxima)

func esta_despierto() -> bool:
	return estado != DORMIDO

func _physics_process(delta: float) -> void:
	tiempo += delta
	destello -= delta
	texto_timer -= delta
	queue_redraw()
	if arte:
		ARTE.voltear(arte, direccion < 0.0)
		ARTE.animar(arte, NOMBRES_ESTADO[estado])
		arte.modulate = Color(1.6, 1.6, 1.6) if destello > 0.0 else Color.WHITE

	match estado:
		DORMIDO:
			return
		PATRULLA:
			position.x += direccion * velocidad_patrulla * delta
			_limitar()
			timer -= delta
			if timer <= 0.0:
				estado = BOCA_ABIERTA
				timer = tiempo_boca_abierta
				_mirar_jugador()
		BOCA_ABIERTA:
			_mirar_jugador()
			timer -= delta
			if timer <= 0.0:
				estado = EMBESTIDA
				timer = tiempo_embestida
		EMBESTIDA:
			# Cada vez que lo alimentas embiste un poco más rápido
			var vel: float = velocidad_embestida + float(vida_maxima - vida) * 10.0
			position.x += direccion * vel * delta
			timer -= delta
			if _limitar() or timer <= 0.0:
				estado = PATRULLA
				timer = tiempo_patrulla
		ATURDIDO:
			timer -= delta
			if timer <= 0.0:
				estado = EMBESTIDA
				timer = tiempo_embestida
				_mirar_jugador()
		DERROTADO:
			timer -= delta
			modulate.a = clampf(timer / 1.5, 0.0, 1.0)
			if timer <= 0.0:
				queue_free()
			return

	if estado == ATURDIDO:
		return
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_tocar_jugador(cuerpo)
			return

# Mantiene al jefe dentro de la arena. Si llega a una orilla se da la vuelta
# y devuelve true.
func _limitar() -> bool:
	if position.x > limite_der:
		position.x = limite_der
		direccion = -1.0
		return true
	if position.x < limite_izq:
		position.x = limite_izq
		direccion = 1.0
		return true
	return false

func _mirar_jugador() -> void:
	var jugador := get_tree().get_first_node_in_group("jugador") as Node2D
	if jugador == null:
		return
	var dx: float = jugador.global_position.x - global_position.x
	if absf(dx) > 4.0:
		direccion = signf(dx)

func _tocar_jugador(cuerpo: Node2D) -> void:
	var jugador := cuerpo as CharacterBody2D
	var cae: bool = jugador.velocity.y > 0.0
	var por_encima: bool = jugador.global_position.y < global_position.y - 18.0
	if cae and por_encima:
		jugador.call("rebotar", -300.0)
	else:
		jugador.call("danar", 1, global_position)

# La llama la comida lanzada. Devuelve true si la comida se gasta.
func recibir_comida() -> bool:
	if estado == DORMIDO or estado == DERROTADO:
		return false
	if estado == BOCA_ABIERTA:
		vida -= 1
		destello = 0.4
		vida_cambio.emit(vida, vida_maxima)
		if vida <= 0:
			estado = DERROTADO
			timer = 2.0
			_texto("¡ME RINDO!")
			set_deferred("monitoring", false)
			derrotado.emit()
		else:
			estado = ATURDIDO
			timer = 0.9
			_texto("¡ÑAM!")
		return true
	_texto("¡BOCA CERRADA!")
	return true

func _texto(t: String) -> void:
	texto = t
	texto_timer = 1.0

# ----------------- Dibujo -----------------
func _col(c: Color) -> Color:
	return c.lightened(0.6) if destello > 0.0 else c

func _rect(x: float, y: float, w: float, h: float, c: Color) -> void:
	var izq: float = x if direccion > 0.0 else -(x + w)
	draw_rect(Rect2(izq, y, w, h), _col(c))

func _poli(puntos: Array, c: Color) -> void:
	var p := PackedVector2Array()
	for v in puntos:
		p.append(Vector2(v.x * direccion, v.y))
	draw_colored_polygon(p, _col(c))

func _draw() -> void:
	var fuente := ThemeDB.fallback_font
	if arte == null:
		_cuerpo()

	# Zzz mientras duerme
	if estado == DORMIDO:
		var sube: float = fmod(tiempo * 12.0, 14.0)
		draw_string(fuente, Vector2(-4, -36 - sube), "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.9))
		draw_string(fuente, Vector2(4, -46 - sube), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1, 1, 1, 0.7))
		return

	if estado != DERROTADO:
		# Barra de vida
		draw_rect(Rect2(-30, -52, 60, 5), Color("#0B0B14"))
		draw_rect(Rect2(-29, -51, 58.0 * float(vida) / float(vida_maxima), 3), Color("#E04B4B"))
		# Aviso: con la boca abierta es momento de lanzar comida
		if estado == BOCA_ABIERTA and fmod(tiempo, 0.5) < 0.35:
			draw_string(fuente, Vector2(-30, -58), "¡LANZA COMIDA!", HORIZONTAL_ALIGNMENT_CENTER, 60, 9, Color("#F5C242"))

	if texto_timer > 0.0:
		draw_string(fuente, Vector2(-40, -66 - (1.0 - texto_timer) * 10.0), texto, HORIZONTAL_ALIGNMENT_CENTER, 80, 10, Color("#F4F1EA"))

# Dibujo provisional del cuerpo (no se usa si hay arte en res://arte/rey_cocodrilo)
func _cuerpo() -> void:
	if estado == DERROTADO:
		# Panza arriba
		draw_set_transform(Vector2(0, -26), PI, Vector2.ONE)

	var verde := Color("#2C6B32")
	var oscuro := Color("#1C4A22")
	var panza := Color("#B5CF7A")
	var moviendo: bool = estado == PATRULLA or estado == EMBESTIDA
	var paso: float = sin(tiempo * (20.0 if estado == EMBESTIDA else 10.0)) * 1.5 if moviendo else 0.0

	# Cola
	_poli([Vector2(-34, -20), Vector2(-52, -6), Vector2(-34, -7)], verde)
	# Patas
	_rect(-28, -5 + paso, 6, 5, oscuro)
	_rect(-14, -5 - paso, 6, 5, oscuro)
	_rect(0, -5 + paso, 6, 5, oscuro)
	_rect(10, -5 - paso, 6, 5, oscuro)
	# Cuerpo
	_rect(-36, -24, 52, 19, verde)
	_rect(-36, -9, 52, 4, panza)
	for k in range(8):
		var bx: float = -34.0 + float(k) * 6.0
		_poli([Vector2(bx, -24), Vector2(bx + 3.0, -29), Vector2(bx + 6.0, -24)], oscuro)

	# Cabeza y boca
	var boca: float = 0.0
	if estado == BOCA_ABIERTA:
		boca = 10.0 + sin(tiempo * 6.0) * 1.5
	elif estado == ATURDIDO:
		boca = 3.0
	_rect(14, -23 - boca, 24, 8, verde)     # mandíbula de arriba
	_rect(14, -11, 24, 6, verde)            # mandíbula de abajo
	if boca > 0.0:
		_rect(14, -15 - boca, 24, boca + 4.0, Color("#8E2A2A"))
		for k in range(5):
			var tx: float = 16.0 + float(k) * 4.5
			_poli([Vector2(tx, -15 - boca), Vector2(tx + 2.0, -11 - boca), Vector2(tx + 4.0, -15 - boca)], Color("#F4F1EA"))
			_poli([Vector2(tx, -11), Vector2(tx + 2.0, -15), Vector2(tx + 4.0, -11)], Color("#F4F1EA"))
	# Ojo
	_rect(16, -30 - boca, 8, 7, verde)
	if estado == DORMIDO or estado == DERROTADO:
		_rect(17, -27 - boca, 6, 1, Color("#0B0B14"))
	else:
		_rect(18, -28 - boca, 4, 4, Color("#F5D742"))
		_rect(20, -27 - boca, 2, 3, Color("#0B0B14"))
	# Corona del rey
	_poli([Vector2(15, -30 - boca), Vector2(15, -37 - boca), Vector2(18.5, -33 - boca),
		Vector2(21.5, -39 - boca), Vector2(24.5, -33 - boca), Vector2(28, -37 - boca), Vector2(28, -30 - boca)],
		Color("#F5C242"))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
