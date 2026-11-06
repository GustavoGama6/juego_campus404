extends Area2D
# Pescado que el jugador recoge. Suma 1 a su comida (se lanza con F).
# Si "reaparece" es mayor que 0, vuelve a salir después de esos segundos
# (sirve en la pelea del jefe para que nunca te quedes sin comida).

signal recogida

@export var reaparece: float = 0.0

var tiempo: float = 0.0
var base_y: float = 0.0
var activa: bool = true
var espera: float = 0.0
var arte: Node2D = null   # res://arte/comida.png (centrado)

const ARTE := preload("res://objetos/arte.gd")

func _ready() -> void:
	base_y = position.y
	arte = ARTE.poner(self, "comida", false)
	var colision := CollisionShape2D.new()
	var forma := CircleShape2D.new()
	forma.radius = 8.0
	colision.shape = forma
	add_child(colision)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	tiempo += delta
	position.y = base_y + sin(tiempo * 3.0) * 2.0
	if not activa and reaparece > 0.0:
		espera -= delta
		if espera <= 0.0:
			activa = true
			visible = true
			set_deferred("monitoring", true)

func _on_body_entered(cuerpo: Node2D) -> void:
	if not activa or not cuerpo.is_in_group("jugador"):
		return
	cuerpo.call("agregar_comida", 1)
	Sonido.sfx("apunte")
	recogida.emit()
	if reaparece > 0.0:
		activa = false
		visible = false
		espera = reaparece
		set_deferred("monitoring", false)
	else:
		queue_free()

func _draw() -> void:
	# Brillo para que se note
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.75, 0.3, 0.18))
	if arte:
		return
	# Cuerpo del pez
	var cuerpo := PackedVector2Array()
	for k in range(12):
		var a: float = TAU * float(k) / 12.0
		cuerpo.append(Vector2(cos(a) * 6.0, sin(a) * 3.5))
	draw_colored_polygon(cuerpo, Color("#F2994A"))
	# Cola
	draw_colored_polygon(PackedVector2Array([Vector2(-5, 0), Vector2(-10, -4), Vector2(-10, 4)]), Color("#E07B2A"))
	# Raya y ojo
	draw_line(Vector2(-1, -3), Vector2(-1, 3), Color("#FFD29A"), 1.0)
	draw_rect(Rect2(2, -2, 2, 2), Color("#0B0B14"))
