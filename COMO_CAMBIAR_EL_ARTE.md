# Cómo cambiar el arte y los sonidos

El juego ya trae un sistema de **"poner y listo"**: cada objeto busca una imagen con su
nombre dentro de la carpeta `arte/`. Si la encuentra, la usa en lugar del dibujo
provisional. **No hay que tocar código ni mover colisiones**: las hitbox se quedan igual.

Lo mismo con el sonido: un archivo en `audio/` con el nombre correcto reemplaza al sonido
provisional.

---

## 1. El proceso (siempre igual)

1. Hagan o descarguen la imagen en **PNG con fondo transparente**.
2. Pónganle **exactamente** el nombre de la tabla (minúsculas, sin acentos, sin espacios).
   Ejemplo: `bug.png`.
3. Arrástrenla a la carpeta **arte/** dentro del panel *Sistema de archivos* de Godot
   (abajo a la izquierda). Godot la importa sola.
4. Presionen **F5**. Ya debe salir su imagen.

Si no aparece: revisen el nombre (que no sea `Bug.png` ni `bug.png.png`) y que esté en
`res://arte/`, no en una subcarpeta.

**Para quitar** una imagen y volver al dibujo provisional, bórrenla de `arte/`.

---

## 2. Reglas de tamaño (importante)

El juego es pixel art a **640 × 360** (se ve al doble en 1280 × 720).
Dibujen al tamaño de la tabla. Por ejemplo Kin mide 16 × 24 px, no 512 × 512.

- **Personajes, enemigos y objetos con "pies"** (Kin, bug, guana, farola, terminal, salida...):
  la parte de abajo de la imagen queda sobre el piso. Dejen los pies pegados al borde inferior.
- **Objetos flotantes** (apunte, sello, café, fragmento, dron, nube, jefe): la imagen queda
  centrada en el objeto.
- **Dibujen a los personajes mirando a la DERECHA.** El juego los voltea solo.
- **Puertas, plataformas, plataformas glitch, bloques de ruido y paneles solares** se estiran
  solos al tamaño exacto de su colisión. Hagan la imagen del tamaño sugerido y listo.
- **Bloques** (`bloque_<estilo>.png`) se repiten como mosaico: hagan un cuadro de
  16 × 16 o 32 × 32 que se pueda repetir sin que se note la unión.

**¿Su imagen quedó muy grande o muy chica?** Abran `objetos/arte.gd` y agreguen su escala
en la lista `ESCALA` (1.0 = tamaño real):
```gdscript
const ESCALA := {
	"jugador": 0.5,   # mi Kin mide 32 x 48, lo dejo a la mitad
	"bug": 0.5,
}
```

---

## 3. Imágenes fijas (.png) o animadas (.tres)

**Imagen fija:** `bug.png` → listo.

**Animada:** creen un archivo **SpriteFrames** con el mismo nombre:
1. En *Sistema de archivos*, clic derecho en `arte/` → **Crear nuevo → Recurso…**
   → busquen **SpriteFrames** → guárdenlo como `bug.tres`.
2. Doble clic en `bug.tres`: abajo se abre el panel *SpriteFrames*.
3. Renombren la animación `default` con el nombre de la tabla (ej. `caminar`).
   Para agregar más, botón **Agregar animación**.
4. Arrastren los cuadros (PNG) al panel, o usen el botón de **hoja de sprites** (icono de
   cuadrícula) para cortar una imagen con varios cuadros.
5. Pongan la velocidad (FPS, ej. 8) y activen *Loop* en las que se repiten.

Si existe `bug.tres` se usa ese (animado); si no, `bug.png` (fijo); si no, el dibujo provisional.
Si a su `.tres` le falta una animación de la lista, simplemente se queda en la que está.

---

## 4. Lista completa de nombres

### Kin y personajes

| Archivo | Qué es | Tamaño sugerido | Animaciones (.tres) |
|---|---|---|---|
| `jugador` | Kin (hitbox 14 × 24) | 16 × 24 | `reposo`, `correr`, `saltar`, `caer`, `pared`, `planear`, `dash` |
| `chicle` | Chicle el coatí (aparece en las farolas) | 16 × 16 | `sentado`, `senalar` |
| `pantalla` | Pantalla de la Profe Ixchel | 28 × 46 | — |

### Enemigos

| Archivo | Qué es | Tamaño sugerido | Animaciones |
|---|---|---|---|
| `bug` | Bug | 16 × 16 | `caminar`, `saltar`, `puas` (Extraordinario) |
| `guana` | Guana corrupta | 24 × 16 | `caminar`, `embestir`, `volteada` (se voltea sola si no la tienen) |
| `dron` | Dron vigía | 16 × 16 | `volar`, `aviso` (antes de atacar), `picada` |
| `proyectil` | Disparo de ruido (dron y jefe) | 8 × 8 | — |
| `nube_ruido` | Nube de ruido | 32 × 32 | (la primera) |
| `cable` | Cable pelado (se estira al alto del cable) | 16 × 64 | `encendido`, `apagado` |
| `error404` | Jefe Error 404 | 64 × 64 a 96 × 96 | `flotar`, `aturdido`, `caida` (Extraordinario) |
| `cocodrilo` | Cocodrilo de la orilla (Lago) | 48 × 20 | `caminar`, `atacar`, `aturdido` |
| `cocodrilo_agua` | Cocodrilo que salta del agua (hocico hacia arriba) | 16 × 28 | — |
| `rey_cocodrilo` | Rey Cocodrilo (Lago) | 96 × 40 | `dormido`, `patrulla`, `boca_abierta`, `embestida`, `aturdido`, `derrotado` |

### Objetos

| Archivo | Qué es | Tamaño sugerido | Animaciones |
|---|---|---|---|
| `farola` | Farola / checkpoint | 12 × 44 | `apagada`, `encendida` |
| `palanca` | Interruptor que se usa con E | 16 × 16 | `apagado`, `encendido` |
| `placa` | Interruptor que se pisa | 24 × 4 | `apagado`, `encendido` |
| `puerta_interruptor` | Reja que abre una palanca | 16 × 96 (se estira) | — |
| `puerta_credencial` | Puerta con candado | 24 × 96 (se estira) | — |
| `puerta_sellada` | Puerta del Núcleo | 32 × 200 (se estira) | — |
| `terminal` | Terminal del Núcleo (jefe) | 24 × 32 | `apagada`, `encendida`, `usada` |
| `salida_puerta` | Salida de los niveles 1 y extra | 32 × 50 | `cerrada`, `abierta` |
| `salida_escalera` | Salida del nivel 2 | 32 × 50 | `cerrada`, `abierta` |
| `plataforma_carrito` | Carrito de libros | 56 × 16 (se estira) | — |
| `plataforma_glitch` | Plataforma que desaparece | 40 × 12 (se estira) | — |
| `ventilador` | Ventilador (solo la base; el aire se dibuja solo) | 40 × 8 | — |
| `bloque_ruido` | Bloque que se rompe con dash | 32 × 64 (se estira) | — |
| `panel_solar` | Panel basculante | 64 × 8 (se estira) | — |
| `letrero_mojado` | Letrero amarillo de piso mojado | 12 × 16 | — |
| `totem_pared`, `totem_planeo` | Tótems del Lago | 24 × 44 | — |
| `pinchos` | UN pincho apuntando hacia arriba (se repite y se gira solo) | 8 × 8 | — |

### Coleccionables

| Archivo | Qué es | Tamaño sugerido |
|---|---|---|
| `apunte` | Apunte (+1) | 10 × 12 |
| `sello` | Sello de honor (estrella) | 16 × 16 |
| `cafe` | Vaso de café (+1 energía) | 12 × 14 |
| `fragmento` | Fragmento del Códice | 16 × 16 |
| `credencial` | Credencial | 16 × 12 |
| `comida` | Pez (Lago; también el que se lanza) | 16 × 10 |

### Bloques (se repiten como mosaico)

`bloque_concreto`, `bloque_escalon`, `bloque_columna`, `bloque_pasillo`, `bloque_piso`,
`bloque_estante`, `bloque_mesa`, `bloque_azotea`, `bloque_metal`, `bloque_nucleo`,
`bloque_tierra`, `bloque_piedra`, `bloque_tronco`, `bloque_hojas`
(16 × 16 o 32 × 32 cada uno).

### Fondos (3 capas con parallax + cielo)

Para cada fondo: `fondo_<variante>_cielo`, `fondo_<variante>_lejana`, `fondo_<variante>_media`,
`fondo_<variante>_cercana`.

| Variante | Nivel |
|---|---|
| `plaza` | Nivel 1 (y el menú principal) |
| `biblioteca` | Nivel 2 (y selección de nivel) |
| `azotea` | Nivel 3 (y créditos) |
| `selva` | Nivel extra del Lago |

- `cielo`: se estira a toda la pantalla y no se mueve. Tamaño 640 × 360.
- `lejana`, `media`, `cercana`: se repiten a lo ancho y se acomodan abajo. Tamaño
  640 × 360 (o más ancho) con **fondo transparente** arriba para que se vea la capa de atrás.
  Se mueven al 15 %, 35 % y 60 % de la velocidad de la cámara.

Ejemplo para el nivel 1: `fondo_plaza_cielo.png`, `fondo_plaza_lejana.png`,
`fondo_plaza_media.png`, `fondo_plaza_cercana.png`. Pueden poner solo algunas; las que
falten se siguen dibujando con código.

### Menús

| Archivo | Qué es | Tamaño sugerido |
|---|---|---|
| `titulo` | Logo del juego en el menú principal (reemplaza el texto) | hasta 400 × 80 |
| `vineta_intro_1`, `vineta_intro_2`, `vineta_intro_3` | Viñetas de introducción | 560 × 210 |
| `vineta_final_1` | Viñeta final | 560 × 210 |
| `fuente.ttf` (u `.otf`) | Tipografía de todo el juego (ej. Pixelify Sans) | — |

---

## 5. Sonidos y música

Pongan archivos **.ogg** (recomendado), **.wav** o **.mp3** en la carpeta **audio/** con
estos nombres. La música se repite sola (menos `victoria`).

**Música (6 pistas del GDD + extra):**

| Archivo | Cuándo suena |
|---|---|
| `menu` | Menú principal, selección, créditos, historia |
| `nivel_1` | Plaza de Acceso |
| `nivel_2` | Biblioteca |
| `nivel_3` | Azotea y Núcleo |
| `jefe` | Pelea con Error 404 y Rey Cocodrilo |
| `victoria` | Fin de nivel y fin del juego |
| `extra` | Nivel del Lago |

**Efectos (los 19 del GDD):**

`salto`, `aterrizar`, `pared`, `dash`, `planeo`, `pisar`, `dano`, `reaparecer`, `apunte`,
`cafe`, `sello`, `fragmento`, `farola`, `interruptor`, `puerta`, `glitch`, `chispa`,
`golpe_jefe`, `menu`.

Ejemplo: `audio/salto.wav`, `audio/nivel_1.ogg`.
Herramientas gratis: jsfxr / BFXR (efectos), BeepBox / LMMS (música), Audacity (recortar).

---

## 6. Si prefieren armar a Kin a mano en el editor

También pueden abrir `jugador/yeshua.tscn` y agregarle un **AnimatedSprite2D** como hijo
con su SpriteFrames (Inspector → *Sprite Frames* → *Nuevo SpriteFrames*). El juego lo detecta
solo, lo voltea y lo anima (tiene prioridad sobre `arte/jugador`). Las animaciones deben
llamarse igual que en la tabla. La colisión (CollisionShape2D, 14 × 24) se deja como está: si su sprite es más
grande, muevan el sprite (propiedad *Offset*) para que los pies queden en el origen, en
lugar de agrandar la colisión.

---

## 7. Créditos de lo que descarguen

Si usan recursos de internet (Kenney, OpenGameArt, itch.io), usen solo licencias **CC0** o
**CC-BY** y agréguenlos en `menus/creditos.gd`, en la lista `LICENCIAS`.
