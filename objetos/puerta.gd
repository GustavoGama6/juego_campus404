extends StaticBody2D
# PUERTA / REJA. Bloquea el paso hasta que se abre.
#   modo = "interruptor": la abre un interruptor (abrir(segundos))
#   modo = "credencial":  se abre con E si Kin tiene la credencial
#   modo = "sellada":     necesita "necesarios" interruptores (registrar())
# La posición es el CENTRO. Arte: res://arte/puerta_<modo>.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(16, 96)
var modo: String = "interruptor"
var necesarios: int = 3
var contados: int = 0
var abierta: bool = false
var timer: float = 0.0
var apertura: float = 0.0   # 0 = cerrada, 1 = abierta (animación)
var tiempo: float = 0.0
var colision: CollisionShape2D
var arte: Node2D = null
var aviso_area: Area2D

func _ready() -> void:
	colision = CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	colision.shape = f
	add_child(colision)
	if modo == "credencial":
		add_to_group("interactuable")
	arte = ARTE.poner(self, "puerta_" + modo, false)
	ARTE.ajustar(arte, tamano)

# El jugador mide la distancia desde la base de la puerta
func _get_base() -> Vector2:
	return global_position + Vector2(0, tamano.y / 2.0)

func punto_interaccion() -> Vector2:
	return _get_base()

func puede_interactuar(j) -> bool:
	return not abierta and bool(j.get("tiene_credencial"))

func interactuar(_j) -> void:
	abrir()

func abrir(segundos: float = 0.0) -> void:
	if abierta and segundos <= 0.0:
		timer = 0.0
		return
	abierta = true
	timer = segundos
	colision.set_deferred("disabled", true)
	Sonido.sfx("puerta")

func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	colision.set_deferred("disabled", false)
	Sonido.sfx("puerta")

func registrar() -> void:
	contados += 1
	if contados >= necesarios:
		abrir()

func _process(delta: float) -> void:
	tiempo += delta
	if abierta and timer > 0.0:
		timer -= delta
		if timer <= 0.0:
			if _jugador_adentro():
				timer = 0.2
			else:
				cerrar()
	apertura = move_toward(apertura, 1.0 if abierta else 0.0, delta * 3.0)
	if arte:
		arte.position.y = -tamano.y * apertura
		arte.modulate.a = 1.0 - apertura * 0.7
	queue_redraw()

func _jugador_adentro() -> bool:
	var j = get_tree().get_first_node_in_group("jugador")
	if j == null:
		return false
	var d: Vector2 = j.global_position - global_position
	return absf(d.x) < tamano.x / 2.0 + 7.0 and d.y > -tamano.y / 2.0 and d.y - 24.0 < tamano.y / 2.0

func _draw() -> void:
	var j = get_tree().get_first_node_in_group("jugador")
	if arte == null:
		var r := Rect2(-tamano / 2.0, tamano)
		r.size.y *= (1.0 - apertura)
		match modo:
			"credencial":
				draw_rect(r, Color("#8B5A2B"))
				draw_rect(r, Color("#5E3718"), false, 2.0)
				if apertura < 0.5:
					draw_rect(Rect2(-4, -6, 8, 10), Color("#F5C242"))
					draw_rect(Rect2(-2, -10, 4, 4), Color("#F5C242"), false, 1.0)
			"sellada":
				draw_rect(r, Color("#2A2A33"))
				draw_rect(r, Color("#29E7FF"), false, 2.0)
				for k in range(necesarios):
					var y: float = -tamano.y / 2.0 + 14.0 + k * 14.0
					if y < r.end.y:
						draw_circle(Vector2(0, y), 4.0, Color("#7CFFB2") if k < contados else Color("#D81B8C"))
			_:
				var x: float = r.position.x + 2.0
				while x < r.end.x:
					draw_rect(Rect2(x, r.position.y, 3, r.size.y), Color("#9AA5A8"))
					x += 6.0
				draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 4), Color("#4C5A63"))
				if r.size.y > 8.0:
					draw_rect(Rect2(r.position.x, r.end.y - 4.0, r.size.x, 4), Color("#4C5A63"))
	if modo == "credencial" and not abierta and j != null:
		var d: Vector2 = j.global_position - _get_base()
		if absf(d.x) < 40.0 and absf(d.y) < 40.0:
			if bool(j.get("tiene_credencial")):
				pass
			else:
				draw_string(ThemeDB.fallback_font, Vector2(-40, -tamano.y / 2.0 - 6.0), "NECESITAS LA CREDENCIAL", HORIZONTAL_ALIGNMENT_CENTER, 80, 8, Color("#F5C242"))
	if j != null and j.get("objeto_cercano") == self:
		var t: String = "[" + Juego.tecla("interactuar") + "]"
		var p := Vector2(0, -tamano.y / 2.0 - 8.0)
		draw_rect(Rect2(p + Vector2(-10, -9), Vector2(20, 12)), Color(0, 0, 0, 0.7))
		draw_string(ThemeDB.fallback_font, p + Vector2(-10, 0), t, HORIZONTAL_ALIGNMENT_CENTER, 20, 9, Color("#F5C242"))
