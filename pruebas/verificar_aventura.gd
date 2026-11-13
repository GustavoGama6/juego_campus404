extends Node
# Ejecutar con XDG_DATA_HOME temporal: estas pruebas escriben un guardado aislado.
var fallos: int = 0
var comprobaciones: int = 0

func comprobar(condicion: bool, descripcion: String) -> void:
	comprobaciones += 1
	if not condicion:
		fallos += 1
		push_error(descripcion)
	else:
		print("OK: ", descripcion)

func _ready() -> void:
	call_deferred("ejecutar")

func ejecutar() -> void:
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/campus404-"):
		push_error("Usa XDG_DATA_HOME=/tmp/campus404-tests para proteger el guardado personal.")
		get_tree().quit(1)
		return
	Juego.datos = Juego._datos_nuevos()
	comprobar(OS.get_user_data_dir().ends_with("app_userdata/Campus 404"), "Título nuevo conserva la carpeta de guardado anterior")
	await verificar_fisica()
	comprobar(Juego.fragmentos_recuperados() == 0, "Partida nueva: cero fragmentos")
	comprobar(not Juego.nivel_desbloqueado("nivel_2"), "Biblioteca bloqueada sin Plaza")
	comprobar(not Juego.actos_previos_completos("nivel_3"), "Final bloqueado sin actos previos")
	var intro = load("res://menus/historia.tscn").instantiate()
	Juego.historia_pendiente = "intro"
	add_child(intro)
	await get_tree().process_frame
	comprobar(intro.vinetas.size() == 3 and intro.lbl_texto.text.length() >= 0, "Introducción instancia sus tres viñetas")
	var hay_boton := false
	for hijo in intro.get_children():
		if hijo is Button and hijo.text == "COMENZAR AVENTURA":
			hay_boton = true
	comprobar(hay_boton, "Botón de inicio inmediato visible desde la primera viñeta")
	for i in range(intro.vinetas.size()):
		intro.indice = i
		intro._mostrar()
		intro.lbl_texto.text = intro.vinetas[i]["texto"]
		intro.letras = float(intro.lbl_texto.text.length())
		await get_tree().process_frame
		comprobar(intro.lbl_texto.get_minimum_size().y <= 88, "Texto de introducción %d cabe en su caja" % (i + 1))
	intro.free()
	var plaza = load("res://niveles/nivel_1_plaza.tscn").instantiate()
	add_child(plaza)
	await get_tree().physics_frame
	await get_tree().physics_frame
	comprobar(plaza.apuntes_total > 0 and plaza.sellos_total == 3, "Plaza construye coleccionables y tres sellos")
	plaza.completar_nivel()
	comprobar(not plaza.terminado, "Plaza no termina sin reparar acceso ni fragmento")
	plaza.pausa.abrir()
	var tiempo: float = plaza.tiempo
	await get_tree().process_frame
	await get_tree().process_frame
	comprobar(get_tree().paused and plaza.tiempo == tiempo, "Pausa congela el reloj")
	plaza.pausa.cerrar()
	comprobar(not get_tree().paused, "Reanudación libera el árbol")
	var pieza = load("res://coleccionables/fragmento.gd").new()
	plaza.add_child(pieza)
	var emisiones := [0]
	pieza.tomado.connect(func(): emisiones[0] += 1)
	pieza._on_body_entered(plaza.jugador)
	pieza._on_body_entered(plaza.jugador)
	comprobar(emisiones[0] == 1, "Fragmento emite una sola vez ante contactos repetidos")
	var apunte = load("res://coleccionables/apunte.gd").new()
	plaza.add_child(apunte)
	var recogidas := [0]
	apunte.recogido.connect(func(_s, _id): recogidas[0] += 1)
	apunte._on_body_entered(plaza.jugador)
	apunte._on_body_entered(plaza.jugador)
	comprobar(recogidas[0] == 1, "Apunte emite una sola vez")
	plaza._on_recogido(true, 0)
	plaza._on_recogido(true, 0)
	comprobar(plaza.sellos_recogidos == 1, "Nivel deduplica sellos por ID")
	plaza._on_fragmento()
	comprobar(plaza.fragmento_obtenido and plaza.salida.abierta, "Fragmento abre la salida")
	comprobar(Juego.fragmentos_recuperados("nivel_1", true) == 1, "HUD cuenta el fragmento del acto actual")
	plaza.completar_nivel()
	comprobar(not plaza.terminado, "Acceso sigue siendo obligatorio aunque se invoque la recogida")
	plaza._reparar_acceso()
	plaza.completar_nivel()
	comprobar(plaza.terminado and Juego.nivel_desbloqueado("nivel_2"), "Plaza válida registra resultado y desbloquea Biblioteca")
	comprobar(Juego.fragmentos_recuperados("nivel_1", true) == 1, "Acto repetido no duplica progreso global")
	get_tree().paused = false
	await get_tree().process_frame
	plaza.free()
	var biblioteca = load("res://niveles/nivel_2_biblioteca.tscn").instantiate()
	add_child(biblioteca)
	await get_tree().physics_frame
	biblioteca.completar_nivel()
	comprobar(not biblioteca.terminado, "Biblioteca exige su fragmento")
	biblioteca._on_fragmento()
	biblioteca.completar_nivel()
	comprobar(biblioteca.terminado and Juego.nivel_desbloqueado("nivel_3"), "Biblioteca completa desbloquea Azotea")
	get_tree().paused = false
	biblioteca.free()
	var azotea = load("res://niveles/nivel_3_azotea.tscn").instantiate()
	add_child(azotea)
	await get_tree().physics_frame
	azotea.completar_nivel()
	comprobar(not azotea.terminado and not Juego.datos["juego_terminado"], "No hay victoria sin jefe, fragmento y reparación")
	azotea._on_fragmento()
	comprobar(not azotea.fragmento_obtenido, "No se acepta fragmento final antes de vencer al jefe")
	azotea._empezar_pelea()
	comprobar(not azotea.pelea_empezada, "Núcleo exige los tres interruptores incluso si se esquiva la puerta")
	for i in range(3):
		azotea.puerta_nucleo.registrar()
	azotea._on_jefe_derrotado()
	await get_tree().process_frame
	azotea._on_fragmento()
	comprobar(azotea.terminal_reparacion.activa, "Fragmento final habilita terminal de reconstrucción")
	azotea._abrir_reparacion()
	var desafio = azotea.get_child(azotea.get_child_count() - 1)
	comprobar(get_tree().paused and azotea.desafio_activo, "Desafío congela combate y bloquea menú de pausa")
	desafio._responder(0)
	comprobar(desafio.paso == 0, "Respuesta incorrecta ofrece pista y no avanza")
	desafio._cancelar()
	await get_tree().process_frame
	comprobar(not get_tree().paused and azotea.terminal_reparacion.activa, "Cancelar permite reintentar la terminal")
	azotea._abrir_reparacion()
	desafio = azotea.get_child(azotea.get_child_count() - 1)
	desafio._responder(1)
	desafio._responder(2)
	desafio._responder(0)
	comprobar(azotea.sistema_reparado and azotea.terminado and Juego.datos["juego_terminado"], "Tres respuestas correctas permiten victoria con objetivos completos")
	comprobar(Juego.fragmentos_recuperados() == 3, "Victoria registra exactamente tres fragmentos")
	Juego.guardar()
	Juego.datos = Juego._datos_nuevos()
	Juego.cargar()
	comprobar(Juego.fragmentos_recuperados() == 3, "Guardado y carga preservan progreso")
	# Salir antes del temporizador que abre la historia final.
	azotea.free()
	var lago = load("res://niveles/nivel_extra_lago.tscn").instantiate()
	add_child(lago)
	await get_tree().physics_frame
	comprobar(not lago.usa_fragmento, "Nivel extra conserva su objetivo independiente")
	lago.free()
	Juego.historia_pendiente = "final"
	var final = load("res://menus/historia.tscn").instantiate()
	add_child(final)
	comprobar(final.vinetas[0]["titulo"] == "¡SISTEMA RESTAURADO!", "Historia final presenta sistema restaurado")
	final.free()
	var resultados = load("res://menus/fin_juego.tscn").instantiate()
	add_child(resultados)
	await get_tree().process_frame
	resultados.free()
	print("RESULTADO: %d comprobaciones; %d fallos" % [comprobaciones, fallos])
	get_tree().quit(0 if fallos == 0 else 1)

func verificar_fisica() -> void:
	var escenario := Node2D.new()
	add_child(escenario)
	var piso = load("res://objetos/bloque.gd").new()
	piso.tamano = Vector2(400, 32)
	piso.position = Vector2(100, 176)
	escenario.add_child(piso)
	var muro = load("res://objetos/bloque.gd").new()
	muro.tamano = Vector2(8, 200)
	muro.position = Vector2(100, 60)
	escenario.add_child(muro)
	var jugador = load("res://jugador/yeshua.tscn").instantiate()
	jugador.position = Vector2(40, 160)
	escenario.add_child(jugador)
	for i in range(4):
		await get_tree().physics_frame
	comprobar(jugador.is_on_floor(), "Física: el jugador descansa sobre un sólido")
	Input.action_press("derecha")
	for i in range(40):
		await get_tree().physics_frame
	Input.action_release("derecha")
	comprobar(jugador.position.x <= 89.1 and jugador.position.x > 40, "Física: camina y el muro detiene al personaje")
	Input.action_press("saltar")
	for i in range(3):
		await get_tree().physics_frame
	Input.action_release("saltar")
	comprobar(jugador.velocity.y < 0 and jugador.position.y < 160, "Física: salto responde al control")
	jugador.dash_habilitado = true
	Input.action_press("derecha", 0.4)
	Input.action_press("dash")
	await get_tree().physics_frame
	await get_tree().physics_frame
	comprobar(jugador.dash_direccion == 1.0, "Dash mantiene dirección y alcance con entrada analógica parcial")
	Input.action_release("derecha")
	Input.action_release("dash")
	jugador.viento = 200
	jugador.empuje_x = 100
	jugador.timer_coyote = 1
	jugador._reaparecer()
	comprobar(jugador.energia == jugador.energia_maxima and jugador.viento == 0 and jugador.empuje_x == 0 and jugador.timer_coyote == 0, "Reaparición limpia impulsos y tolerancias anteriores")
	# Terminal cercana al otro lado de una pared fina.
	jugador.position = Vector2(88, 160)
	var terminal = load("res://objetos/terminal.gd").new()
	terminal.position = Vector2(108, 160)
	terminal.activa = true
	escenario.add_child(terminal)
	await get_tree().physics_frame
	jugador._buscar_interactuable()
	comprobar(jugador.objeto_cercano == null, "Interacción bloqueada por muro intermedio")
	escenario.free()
