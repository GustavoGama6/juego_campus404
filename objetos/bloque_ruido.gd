extends StaticBody2D
# BLOQUE DE RUIDO: bloque sólido que SOLO se rompe con el dash.
# La posición es el centro. Arte: res://arte/bloque_ruido.png

const ARTE := preload("res://objetos/arte.gd")

var tamano: Vector2 = Vector2(32, 64)
var tiempo: float = 0.0
var roto: bool = false
var romper_timer: float = 0.0
var colision: CollisionShape2D
var arte: Node2D = null

func _ready() -> void:
	colision = CollisionShape2D.new()
	var f := RectangleShape2D.new()
	f.size = tamano
	colision.shape = f
	add_child(colision)
	arte = ARTE.poner(self, "bloque_ruido", false)
	ARTE.ajustar(arte, tamano)

func romper() -> void:
	if roto:
		return
	roto = true
	romper_timer = 0.3
	colision.set_deferred("disabled", true)
	Sonido.sfx("glitch")

func _physics_process(delta: float) -> void:
	tiempo += delta
	queue_redraw()
	if roto:
		romper_timer -= delta
		modulate.a = clampf(romper_timer / 0.3, 0.0, 1.0)
		if romper_timer <= 0.0:
			queue_free()

func _draw() -> void:
	if arte:
		return
	var r := Rect2(-tamano / 2.0, tamano)
	draw_rect(r, Color("#0B0B14"))
	var semilla: int = int(tiempo * 10.0)
	var n: int = int(r.size.x * r.size.y / 40.0)
	for k in range(n):
		var h: int = (k * 131 + semilla * 17) % 4093
		var x: float = r.position.x + float(h % int(r.size.x - 2.0))
		var y: float = r.position.y + float((h / 7) % int(r.size.y - 2.0))
		draw_rect(Rect2(x, y, 2, 2), Color("#D81B8C") if k % 2 == 0 else Color("#29E7FF"))
	draw_rect(r, Color("#29E7FF"), false, 1.0)
