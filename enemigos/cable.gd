extends "res://enemigos/enemigo.gd"
# CABLE PELADO: arco eléctrico. 1 s encendido y 1.5 s apagado (avisa parpadeando).
# Solo daña encendido. No se puede derrotar. El origen está en el piso.
# Arte: res://arte/cable.png (o .tres con "encendido" y "apagado")

var alto: float = 64.0
var tiempo_encendido: float = 1.0
var tiempo_apagado: float = 1.5
var desfase: float = 0.0
var encendido: bool = false

func preparar() -> void:
	tamano = Vector2(10, alto)
	pisable = false
	muere_con_trampas = false
	# Normal: 1.2 s encendido / 1.3 s apagado. Extraordinario: 1.4 / 1.0
	tiempo_encendido = 1.4 if ext else 1.2
	tiempo_apagado = 1.0 if ext else 1.3
	nombre_arte = "cable"
	estirar_al_alto = true

func mover(_delta: float) -> void:
	var ciclo: float = tiempo_encendido + tiempo_apagado
	var t: float = fmod(tiempo + desfase, ciclo)
	var antes: bool = encendido
	encendido = t >= tiempo_apagado
	if encendido and not antes:
		var j := get_tree().get_first_node_in_group("jugador") as Node2D
		if j and j.global_position.distance_to(global_position) < 200.0:
			Sonido.sfx("chispa")
	if arte:
		ARTE.animar(arte, "encendido" if encendido else "apagado")

func activo() -> bool:
	return encendido and not congelado

func _dibujar() -> void:
	# Postes arriba y abajo
	draw_rect(Rect2(-4, -alto, 8, 4), Color("#3A4A50"))
	draw_rect(Rect2(-4, -4, 8, 4), Color("#3A4A50"))
	var ciclo: float = tiempo_encendido + tiempo_apagado
	var t: float = fmod(tiempo + desfase, ciclo)
	var aviso: bool = not encendido and t > tiempo_apagado - 0.35
	if encendido and not congelado:
		var puntos := PackedVector2Array()
		var pasos: int = int(alto / 6.0)
		for k in range(pasos + 1):
			var y: float = -alto + 4.0 + float(k) * (alto - 8.0) / float(pasos)
			puntos.append(Vector2(randf_range(-4.0, 4.0), y))
		draw_polyline(puntos, Color("#29E7FF"), 2.0)
		draw_polyline(puntos, Color("#F4F1EA"), 1.0)
		draw_rect(Rect2(-5, -alto, 10, alto), Color(0.16, 0.9, 1.0, 0.15))
	elif aviso and int(tiempo * 20.0) % 2 == 0:
		draw_line(Vector2(0, -alto + 4), Vector2(0, -4), Color(0.85, 0.1, 0.55, 0.7), 1.0)
	else:
		draw_line(Vector2(0, -alto + 4), Vector2(0, -4), Color(0.3, 0.3, 0.35, 0.6), 1.0)
