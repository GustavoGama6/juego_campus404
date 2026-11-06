extends Area2D
# Cocodrilo que salta fuera del agua cada cierto tiempo.
# Antes de saltar avisa con burbujas y sus ojos en la superficie.
# Colócalo con "y" igual a la superficie del agua.
#   - Si te toca: pierdes un vaso de energía.
#   - Si le caes encima mientras baja: rebotas.
#   - Si le lanzas comida mientras está fuera: se la come y se va.

@export var altura: float = 100.0      # qué tan alto salta (px sobre el agua)
@export var espera: float = 2.6        # segundos bajo el agua entre saltos
@export var desfase: float = 0.0       # retraso inicial (para que no salten todos juntos)
@export var tiempo_aviso: float = 0.7  # segundos de burbujas antes de saltar

const GRAVEDAD := 700.0
const HUNDIDO := 24.0

enum { BAJO, AVISO, SALTO }

var estado: int = BAJO
var superficie_y: float = 0.0
var timer: float = 0.0
var vel_y: float = 0.0
var saciado: bool = false
var tiempo: float = 0.0
var arte: Node2D = null   # res://arte/cocodrilo_agua.png (centrado, hocico hacia arriba)

const ARTE := preload("res://objetos/arte.gd")

func _ready() -> void:
	superficie_y = position.y
	arte = ARTE.poner(self, "cocodrilo_agua", false)
	if arte:
		arte.visible = false
	position.y = superficie_y + HUNDIDO
	timer = espera * 0.5 + desfase
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(14, 26)
	colision.shape = forma
	add_child(colision)

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	if arte:
		arte.visible = estado == SALTO or saciado
		arte.rotation = 0.0 if vel_y < 0.0 else PI   # hocico hacia donde se mueve

	if saciado:
		modulate.a -= delta * 2.0
		position.y += delta * 30.0
		if modulate.a <= 0.0:
			queue_free()
		return

	match estado:
		BAJO:
			timer -= delta
			if timer <= 0.0:
				estado = AVISO
				timer = tiempo_aviso
		AVISO:
			timer -= delta
			if timer <= 0.0:
				estado = SALTO
				position.y = superficie_y
				vel_y = -sqrt(2.0 * GRAVEDAD * altura)
		SALTO:
			vel_y += GRAVEDAD * delta
			position.y += vel_y * delta
			if vel_y > 0.0 and position.y >= superficie_y + HUNDIDO:
				position.y = superficie_y + HUNDIDO
				estado = BAJO
				timer = espera

	if estado != SALTO:
		return
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_tocar_jugador(cuerpo)
			return

func _tocar_jugador(cuerpo: Node2D) -> void:
	var jugador := cuerpo as CharacterBody2D
	var cae: bool = jugador.velocity.y > 0.0
	var por_encima: bool = jugador.global_position.y < global_position.y - 8.0
	if cae and por_encima and vel_y > 0.0:
		jugador.call("rebotar", -280.0)
		vel_y = maxf(vel_y, 250.0)
	else:
		jugador.call("danar", 1, global_position)

func recibir_comida() -> bool:
	if saciado or estado != SALTO:
		return false
	saciado = true
	set_deferred("monitoring", false)
	return true

func _draw() -> void:
	# La superficie del agua en coordenadas locales
	var sup: float = superficie_y - position.y
	if estado == AVISO:
		# Burbujas y ojos asomando: ¡va a saltar!
		for k in range(4):
			var fase: float = fmod(tiempo * 2.0 + float(k) * 0.25, 1.0)
			draw_circle(Vector2(-6.0 + float(k) * 4.0, sup - fase * 8.0), 1.5, Color(0.85, 1.0, 1.0, 1.0 - fase))
		draw_rect(Rect2(-6, sup - 3, 4, 3), Color("#2E6B34"))
		draw_rect(Rect2(2, sup - 3, 4, 3), Color("#2E6B34"))
		draw_rect(Rect2(-5, sup - 2, 2, 2), Color("#F5D742"))
		draw_rect(Rect2(3, sup - 2, 2, 2), Color("#F5D742"))
		return
	if estado != SALTO and not saciado:
		return
	if arte:
		return

	# Cabeza del cocodrilo apuntando hacia donde se mueve
	var arriba: bool = vel_y < 0.0
	var s: float = -1.0 if arriba else 1.0   # -1 = hocico arriba, 1 = hocico abajo
	var verde := Color("#2E6B34")
	var oscuro := Color("#1F4D24")
	# Cuello / cuerpo (del lado contrario al hocico)
	if arriba:
		draw_rect(Rect2(-6, -1, 12, 14), verde)
	else:
		draw_rect(Rect2(-6, -13, 12, 14), verde)
	# Mandíbulas abiertas
	draw_colored_polygon(PackedVector2Array([Vector2(-6, 0), Vector2(-3, 13 * s), Vector2(0, 0)]), verde)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(3, 13 * s), Vector2(6, 0)]), verde)
	draw_colored_polygon(PackedVector2Array([Vector2(-3, 0), Vector2(0, 9 * s), Vector2(3, 0)]), Color("#8E2A2A"))
	# Dientes
	draw_line(Vector2(-4, 4 * s), Vector2(-2, 4 * s), Color("#F4F1EA"), 1.0)
	draw_line(Vector2(2, 4 * s), Vector2(4, 4 * s), Color("#F4F1EA"), 1.0)
	# Ojos y picos
	draw_rect(Rect2(-6, -3 * s - 1.5, 3, 3), Color("#F5D742"))
	draw_rect(Rect2(3, -3 * s - 1.5, 3, 3), Color("#F5D742"))
	draw_rect(Rect2(-1, -9 * s - 1.5, 2, 3), oscuro)
	# Salpicadura cuando cruza la superficie
	if absf(sup) < 14.0:
		for k in range(3):
			draw_circle(Vector2(-8.0 + float(k) * 8.0, sup - 2.0), 2.0, Color(0.85, 1.0, 1.0, 0.8))
