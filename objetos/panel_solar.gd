extends AnimatableBody2D
# PANEL SOLAR GIRATORIO: el peso determina el sentido y la velocidad del giro.
# El peso y los aterrizajes alteran el giro, con amortiguación y velocidad limitada.
# La superficie y el dibujo giran juntos. La posición es el centro.
# Arte: res://arte/panel_solar.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(64, 8)
@export var sensibilidad_peso: float = 160.0 # aceleración angular máxima, grados/s²
@export var impulso_aterrizaje: float = 35.0 # cambio máximo de velocidad, grados/s
@export var amortiguacion: float = 0.5
@export var friccion_libre: float = 0.2 # conserva inercia al saltar fuera
@export var zona_centro: float = 0.12 # franja alrededor del pivote para equilibrarse
@export var velocidad_maxima: float = 80.0 # grados/s, también en Extraordinario
var velocidad_angular: float = 0.0
var jugador_encima: bool = false
var ultima_caida: float = 0.0
var angulo: float = 0.0
var activado: bool = false
var arte: Node2D = null

func _ready() -> void:
	sync_to_physics = true
	var c := CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	c.shape = f
	add_child(c)
	arte = ARTE.poner(self, "panel_solar", false)
	ARTE.ajustar(arte, tamano)

func _physics_process(delta: float) -> void:
	var j = get_tree().get_first_node_in_group("jugador") as CharacterBody2D
	var apoyado := false
	if j and j.is_on_floor():
		for i in range(j.get_slide_collision_count()):
			var contacto := j.get_slide_collision(i)
			if contacto.get_collider() == self and contacto.get_normal().dot(Vector2.UP) > 0.7:
				apoyado = true
				break
	var aceleracion_peso := 0.0
	if apoyado:
		if not activado:
			activado = true
		# El brazo horizontal respecto al pivote hace bajar el lado que soporta el peso.
		# En el centro el efecto es mínimo; en los extremos alcanza la sensibilidad máxima.
		var brazo := clampf((j.global_position.x - global_position.x) / (tamano.x * 0.5), -1.0, 1.0)
		# Una pequeña zona neutra permite detener la placa sin oscilaciones por ruido.
		if absf(brazo) < zona_centro:
			brazo = 0.0
		aceleracion_peso = brazo * sensibilidad_peso
		if not jugador_encima:
			# Aplicar el golpe solo al aterrizar, usando la caída del fotograma anterior:
			# move_and_slide ya puede haber anulado la velocidad vertical del jugador.
			var intensidad := clampf(ultima_caida / 400.0, 0.0, 1.0)
			velocidad_angular += brazo * impulso_aterrizaje * intensidad
	jugador_encima = apoyado
	ultima_caida = maxf(j.velocity.y, 0.0) if j else 0.0
	if not activado:
		return
	# Sin motor de giro: el peso puede frenar, detener e invertir la plataforma.
	# Al salir, conservar el sentido adquirido y perder velocidad por fricción.
	var rozamiento := maxf(amortiguacion if apoyado else friccion_libre, 0.01)
	var factor := exp(-rozamiento * delta)
	var objetivo := aceleracion_peso / rozamiento
	velocidad_angular = objetivo + (velocidad_angular - objetivo) * factor
	if aceleracion_peso == 0.0 and absf(velocidad_angular) < 0.5:
		velocidad_angular = 0.0
	velocidad_angular = clampf(velocidad_angular, -velocidad_maxima, velocidad_maxima)
	angulo = fposmod(angulo + deg_to_rad(velocidad_angular) * delta, TAU)
	rotation = angulo

func _draw() -> void:
	# Soporte
	draw_rect(Rect2(-3, tamano.y / 2.0, 6, 14), Color("#4C5A63"))
	if arte:
		return
	var r := Rect2(-tamano / 2.0, tamano)
	draw_rect(r, Color("#1E3A5F"))
	var x: float = r.position.x + 8.0
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color("#6FA8DC"), 1.0)
		x += 8.0
	draw_rect(Rect2(r.position, Vector2(r.size.x, 1)), Color("#BFE3FF"))
	draw_rect(r, Color("#9AA5A8"), false, 1.0)
