extends Node
var fallos: int = 0
var comprobaciones: int = 0

func comprobar(condicion: bool, descripcion: String) -> void:
	comprobaciones += 1
	if condicion:
		print("OK: ", descripcion)
	else:
		fallos += 1
		push_error(descripcion)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Mantener el verificador al cambiar la escena real del juego.
	get_tree().current_scene = null
	call_deferred("ejecutar")

func esperar_transicion() -> void:
	while Juego.en_transicion():
		await get_tree().process_frame
	await get_tree().process_frame

func ejecutar() -> void:
	if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/campus404-"):
		push_error("Usa XDG_DATA_HOME=/tmp/campus404-tests para proteger el guardado personal.")
		get_tree().quit(1)
		return
	Juego.datos = Juego._datos_nuevos()
	Juego.jugar_desde_menu()
	await esperar_transicion()
	var intro = get_tree().current_scene
	comprobar(intro.scene_file_path == Juego.HISTORIA, "Jugar abre introducción en una partida nueva")
	var salto := InputEventAction.new()
	salto.action = "saltar"
	salto.pressed = true
	intro._input(salto)
	comprobar(intro.letras == float(intro.vinetas[0]["texto"].length()) and intro.indice == 0, "Omitir escritura revela la viñeta sin iniciar partida")
	intro._input(salto)
	comprobar(intro.indice == 1, "Salto avanza la viñeta con botón enfocado")
	intro._terminar()
	await esperar_transicion()
	var plaza = get_tree().current_scene
	comprobar(plaza.scene_file_path == Juego.NIVELES[0]["escena"] and Juego.datos["intro_vista"], "Comenzar aventura llega a Plaza y guarda introducción vista")
	plaza._on_fragmento()
	plaza.pausa.abrir()
	plaza.pausa._reiniciar()
	await esperar_transicion()
	plaza = get_tree().current_scene
	comprobar(not plaza.fragmento_obtenido and not get_tree().paused, "Reiniciar desde pausa limpia el intento y reanuda el árbol")
	plaza.pausa.abrir()
	plaza.pausa._menu()
	await esperar_transicion()
	comprobar(get_tree().current_scene.scene_file_path == Juego.MENU_PRINCIPAL and not get_tree().paused, "Volver al menú desde pausa completa la transición")
	Juego.set_dificultad("extraordinario")
	comprobar(not Juego.extraordinario(), "Extraordinario permanece bloqueado antes de completar aventura")
	Juego.modo_prueba()
	comprobar(not Juego.datos["juego_terminado"], "F12 abre herramientas de prueba sin registrar una victoria falsa")
	Juego.set_dificultad("extraordinario")
	Juego.jugar_nivel("nivel_3")
	await esperar_transicion()
	var azotea = get_tree().current_scene
	comprobar(azotea.ext and azotea.jugador.energia_maxima == 2, "Extraordinario conserva habilidades y energía especial")
	for i in range(3):
		azotea.puerta_nucleo.registrar()
	azotea._empezar_pelea()
	azotea.terminales[0].usada = true
	azotea._reiniciar_pelea()
	await get_tree().process_frame
	comprobar(not azotea.pelea_empezada and not azotea.terminales[0].usada and azotea.puerta_arena.abierta, "Reintentar combate Extraordinario restablece terminales y arena")
	Juego.ir_menu()
	await esperar_transicion()
	print("RESULTADO TRANSICIONES: %d comprobaciones; %d fallos" % [comprobaciones, fallos])
	get_tree().quit(0 if fallos == 0 else 1)
