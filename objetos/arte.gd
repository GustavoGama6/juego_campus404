extends RefCounted
# =====================================================================
#  ARTE: cambia los dibujos provisionales por tus imágenes SIN tocar código.
#
#  Cada objeto busca un archivo con su nombre en res://arte/:
#    res://arte/bug.png      -> imagen fija
#    res://arte/bug.tres     -> SpriteFrames (animaciones hechas en Godot)
#  Si existe, se usa en lugar del dibujo con figuras.
#  La lista de nombres está en COMO_CAMBIAR_EL_ARTE.md
# =====================================================================

# Si una imagen se ve muy grande o muy chica, ponle aquí su escala
# (1.0 = tamaño real del archivo). Ejemplo: un sprite de 64 px para Kin -> 0.5
const ESCALA := {
	# "jugador": 0.5,
	# "bug": 0.5,
}

static func ruta(nombre: String, extensiones: Array = ["png", "webp", "jpg"]) -> String:
	for ext in extensiones:
		var r := "res://arte/%s.%s" % [nombre, ext]
		if ResourceLoader.exists(r):
			return r
	return ""

static func textura(nombre: String) -> Texture2D:
	var r := ruta(nombre)
	if r == "":
		return null
	return load(r) as Texture2D

static func animaciones(nombre: String) -> SpriteFrames:
	var r := ruta(nombre, ["tres", "res"])
	if r == "":
		return null
	return load(r) as SpriteFrames

# Pone la imagen o animación como hijo del objeto. Devuelve el nodo creado
# (Sprite2D o AnimatedSprite2D) o null si no hay archivo.
# apoyado = true: la parte de abajo de la imagen queda en el origen (pies).
# apoyado = false: la imagen queda centrada en el origen.
static func poner(nodo: Node2D, nombre: String, apoyado: bool = true) -> Node2D:
	var frames := animaciones(nombre)
	if frames:
		var a := AnimatedSprite2D.new()
		a.name = "Arte"
		a.sprite_frames = frames
		var anims := frames.get_animation_names()
		if anims.size() > 0:
			var tex := frames.get_frame_texture(anims[0], 0)
			if apoyado and tex:
				a.offset.y = -tex.get_height() / 2.0
			a.play(anims[0])
		a.scale = Vector2.ONE * float(ESCALA.get(nombre, 1.0))
		nodo.add_child(a)
		return a
	var t := textura(nombre)
	if t:
		var s := Sprite2D.new()
		s.name = "Arte"
		s.texture = t
		if apoyado:
			s.offset.y = -t.get_height() / 2.0
		s.scale = Vector2.ONE * float(ESCALA.get(nombre, 1.0))
		nodo.add_child(s)
		return s
	return null

# Estira la imagen para que mida EXACTAMENTE "tamano" (igual que la colisión).
# Se usa en puertas, plataformas, bloques de ruido, paneles y cables, que
# cambian de tamaño según el nivel.
static func ajustar(arte: Node2D, tamano: Vector2, solo_alto: bool = false) -> void:
	if arte == null:
		return
	var tex: Texture2D = null
	if arte is Sprite2D:
		tex = (arte as Sprite2D).texture
	elif arte is AnimatedSprite2D:
		var a := arte as AnimatedSprite2D
		tex = a.sprite_frames.get_frame_texture(a.animation, 0)
	if tex and tex.get_width() > 0 and tex.get_height() > 0:
		var sy: float = tamano.y / tex.get_height()
		arte.scale = Vector2(sy if solo_alto else tamano.x / tex.get_width(), sy)

# Cambia de animación si existe (por ejemplo "caminar", "morir")
static func animar(arte: Node2D, animacion: String) -> void:
	if arte is AnimatedSprite2D:
		var a := arte as AnimatedSprite2D
		if a.sprite_frames.has_animation(animacion) and a.animation != animacion:
			a.play(animacion)

static func voltear(arte: Node2D, a_la_izquierda: bool) -> void:
	if arte is Sprite2D:
		(arte as Sprite2D).flip_h = a_la_izquierda
	elif arte is AnimatedSprite2D:
		(arte as AnimatedSprite2D).flip_h = a_la_izquierda
