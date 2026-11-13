# Mejoras de ERROR 404: El Código Perdido

## Estado inicial y diagnóstico

Proyecto existente en **Godot 4 / GDScript**, ejecutado para esta revisión con Godot 4.7.2. Renderizador GL Compatibility, resolución lógica de 640 × 360 y escalado de canvas. Sin dependencias nuevas.

La arquitectura construye los escenarios por código sobre `niveles/nivel_base.gd`. `autoload/juego.gd` administra progreso, controles remapeables, opciones y transiciones; `autoload/sonido.gd` sintetiza música y efectos. Se conservan las escenas, dos PNG de arte existentes, fondos procedurales, créditos, calificaciones, logros y guardados.

La campaña contiene **tres fragmentos, uno por acto**: Plaza de Acceso, Biblioteca y Azotea/Núcleo. El Lago es una aventura extra sin fragmento. Ya existían coyote time, buffer de salto, salto variable, salto de pared, dash, planeo, plataformas móviles, peligros, credencial, interruptores, checkpoints, pausa, opciones y jefe final con tres terminales. Se reutilizan esas mecánicas; no se reconstruyó el juego.

Problemas identificados:

- Protagonista y narrativa usaban Kin y una entrega escolar, incompatibles con la misión solicitada de Yoshua.
- Introducción con escritura progresiva pero sin botón visible para comenzar inmediatamente.
- HUD mostraba únicamente el fragmento local 0/1, sin progreso global ni misión común a todos los actos.
- Recolección de fragmentos y apuntes emitía señales antes de la eliminación diferida, sin protección explícita frente a contactos repetidos.
- Finalización de los niveles confiaba en sus emisores; no comprobaba fragmento, acceso reparado ni requisitos de victoria dentro de los métodos de finalización.
- Final automático al recoger el tercer fragmento, sin reconstrucción interactiva del sistema.
- Dash tomaba directamente la intensidad del stick: una inclinación parcial reducía el alcance.
- Interacciones cercanas no comprobaban paredes intermedias.
- Reaparición conservaba ciertos impulsos y temporizadores anteriores.
- F12 marcaba la aventura como terminada, aunque solo se quisieran probar niveles.

## Plan aplicado y prioridades

1. **Correcciones necesarias:** recolección única, condiciones explícitas de finalización, bloqueo del Núcleo por interruptores y reinicios consistentes.
2. **Experiencia:** historia coherente, inicio rápido, progreso global, objetivo contextual, legibilidad y confirmaciones.
3. **Ampliación compatible:** reconstrucción del código en la terminal existente con tres preguntas breves de programación.
4. **Verificación:** pruebas con el motor, física y cambios reales de escena; documentación de límites.

## Mejoras estéticas

- Título de aplicación y presentación: **ERROR 404: El Código Perdido**. Se conserva el logo gráfico existente y se añade el título completo en texto.
- Introducción de tres viñetas con la narrativa solicitada, Yoshua, Universidad del Caribe en Cancún, código fragmentado y misión de restauración. Se mantienen las ilustraciones procedurales animadas y se añade fundido de entrada.
- Botón **COMENZAR AVENTURA** disponible desde la primera viñeta; no obliga a esperar la escritura.
- Espacio revela el texto o avanza; clic en el fondo avanza; Enter sobre el botón o Esc permite comenzar inmediatamente. Se evita que el foco del botón capture Espacio e impida leer las viñetas.
- HUD con fondo oscuro y borde turquesa, progreso global, misión contextual y aviso de interacción con la tecla configurada.
- Se unifica el objetivo de Plaza con el HUD para evitar dos textos superpuestos.
- Confirmación de recogida con mensaje y destello cian breve.
- Balanceo leve del PNG al correr, inclinación durante dash, estela visible también al usar PNG y sombra sencilla al estar en suelo. No requiere imágenes nuevas ni partículas costosas.
- Historia final y resultados anuncian **¡SISTEMA RESTAURADO!**, felicitan a Yoshua y muestran **MISIÓN COMPLETADA**.

## Jugabilidad y progresión

1. Yoshua recibe la misión en la introducción.
2. En Plaza repara la terminal de acceso y recoge el primer fragmento; se conserva la recompensa de dash.
3. Biblioteca conserva credencial, obstáculos y segundo fragmento; se conserva la recompensa de planeo.
4. Azotea exige los tres interruptores antes de comenzar la pelea del Núcleo.
5. El jefe conserva sus patrones y terminales; solo su derrota permite recoger el último fragmento.
6. El jugador vuelve a la **terminal central** y pulsa su tecla de interacción para reconstruir el código.
7. El diagnóstico plantea tres retos: asignación de variables, condición lógica AND e índices de una lista. Los errores dan pistas sin quitar progreso. Se puede cancelar y reabrir el desafío.
8. Solo después de resolverlo, con los actos previos completos, interruptores, jefe y fragmento final, se registra la victoria y aparece el desenlace.

El desafío pausa el mundo y bloquea el menú de pausa simultáneo. Al cancelar, la terminal vuelve a activarse. La derrota conserva el diseño original de reaparición y ahora muestra un mensaje de reintento con objetos conservados; no se introduce una pantalla que interrumpa cada caída.

## Correcciones de lógica

- Fragmentos y apuntes se marcan recogidos antes de emitir; se desactiva su monitorización de manera diferida.
- El nivel también ignora eventos repetidos de fragmento y sellos con ID duplicado.
- Progreso global calculado sobre actos completados y fragmento actual, sin duplicar un acto al repetirlo. Los objetos de un intento quedan guardados al completar el acto, como en el sistema original.
- Las llamadas normales a jugar un nivel respetan sus desbloqueos.
- Plaza exige reparar acceso además de obtener el fragmento; Biblioteca exige su fragmento.
- Núcleo comprueba tres interruptores, jefe derrotado, fragmento, actos previos y reparación del código.
- La señal de derrota del jefe y la recogida final son idempotentes.
- F12 conserva acceso a niveles, habilidades y Extraordinario, pero ya no registra una victoria ficticia. La etiqueta de modo prueba sigue visible.
- Dash usa el signo del eje para mantener su alcance con entrada analógica parcial.
- Raycast contra sólidos evita interacciones a través de paredes.
- Reaparición limpia viento, empuje, piso mojado, objetivo cercano y tolerancias de salto anteriores.
- Se mantiene explícitamente la carpeta `app_userdata/Campus 404` al cambiar el título, para conservar la ubicación del guardado existente.

## Archivos modificados y añadidos

| Archivo | Responsabilidad del cambio |
| --- | --- |
| `project.godot` | Título y compatibilidad de ubicación del guardado |
| `autoload/juego.gd` | Nombre, protagonista, conteo global, requisitos previos y modo prueba |
| `coleccionables/fragmento.gd` | Recogida única |
| `coleccionables/apunte.gd` | Recogida única de apuntes y sellos |
| `jugador/yeshua.gd` | Dash, raycast de interacción, limpieza al reaparecer y efectos del PNG |
| `menus/historia.gd` | Narrativa, botón, controles de lectura y transición visual |
| `menus/menu_principal.gd` | Presentación del título y Yoshua |
| `menus/fin_juego.gd` | Mensaje de sistema restaurado |
| `niveles/nivel_base.gd` | Misiones, deduplicación, reintento y condiciones de finalización |
| `niveles/nivel_1_plaza.gd` | Yoshua, objetivo común y requisito de acceso reparado |
| `niveles/nivel_3_azotea.gd` | Interruptores obligatorios, terminal final y requisitos de victoria |
| `ui/hud.gd` | Progreso global, misión, interacción y fondo legible |
| `ui/menu_pausa.gd` | Exclusión de pausa durante desafío |
| `ui/desafio_codigo.gd` (nuevo) | Diagnóstico interactivo con pistas y reintento |
| `pruebas/verificar_aventura.gd` y `.tscn` (nuevos) | Verificación de física, objetivos, recogida, guardado y desenlace |
| `pruebas/verificar_transiciones.gd` y `.tscn` (nuevos) | Flujo real entre escenas y modo Extraordinario |
| `MEJORAS_VIDEOJUEGO.md` (nuevo) | Diagnóstico, cambios, pruebas y pendientes |

## Pruebas y resultados

Las pruebas se ejecutan con **Godot 4.7.2 en modo headless** y datos temporales. Los verificadores rechazan ejecutarse sin un `XDG_DATA_HOME` que empiece por `/tmp/campus404-`, para proteger la partida personal.

Ejemplo desde la raíz del proyecto, ajustando la ruta del ejecutable si hace falta:

```bash
XDG_DATA_HOME=/tmp/campus404-tests XDG_CONFIG_HOME=/tmp/campus404-config \
  /home/gustavux/Descargas/Godot_v4.7.2-stable_linux.x86_64 \
  --headless --path . pruebas/verificar_aventura.tscn

XDG_DATA_HOME=/tmp/campus404-transiciones XDG_CONFIG_HOME=/tmp/campus404-config \
  /home/gustavux/Descargas/Godot_v4.7.2-stable_linux.x86_64 \
  --headless --path . pruebas/verificar_transiciones.tscn
```

- **Suite de aventura:** 41 comprobaciones; cero fallos. Incluye física real en escenario de prueba (suelo, muro, salto, dash parcial, limpieza de reaparición e interacción obstruida), caja de texto de las tres viñetas, recogida única, pausa/reanudación, requisitos de Plaza/Biblioteca/Núcleo, tres interruptores, respuestas incorrectas, cancelación/reintento, victoria válida, conteo 3/3, guardado/carga y escenas de Lago y resultados.
- **Suite de transiciones:** 10 comprobaciones; cero fallos. Incluye menú → introducción → Plaza, lectura con botón enfocado, reinicio desde pausa, regreso al menú, bloqueo de Extraordinario, modo prueba sin victoria ficticia, energía de Extraordinario y restablecimiento de arena/terminales.
- Inicio del menú principal y carga de Azotea ejecutados por separado en headless, sin errores de scripts.
- `git diff --check`: sin errores de formato.

Los estados de progreso y la derrota del jefe se fuerzan en partes de las pruebas para aislar requisitos; **no equivalen a completar los mapas jugando manualmente**. El salto, movimiento y colisión del escenario de prueba sí avanzan mediante frames de física y acciones de entrada.

## Límites, pendientes y recomendaciones

- No se realizó inspección visual en ventana ni recorrido manual completo de cada mapa. No se afirma haber validado el aspecto final mediante capturas, el equilibrio de dificultad ni todos los obstáculos del campus.
- La música sintetizada se conserva; no se realizó escucha. Las ejecuciones headless reportan al salir objetos pendientes de `AudioStreamWAV`/`AudioStreamPlaybackWAV` (2 en inicio/transiciones y entre 2 y 7 en distintas ejecuciones de la suite de aventura; la última ejecución con `--verbose` identificó 2 objetos de audio). El módulo de audio existente queda sin cambios; es un pendiente de diagnóstico de cierre, no se presenta como prueba limpia de advertencias.
- La primera apertura del editor encontró restricciones del entorno al escribir su configuración/carpeta de usuario y abrir sockets. La verificación funcional posterior usó ejecución headless con datos temporales, sin depender del editor.
- Verificar visualmente 1280 × 720 y pantalla completa; comprobar mando físico, remapeo, textos, audio y todas las rutas, incluido Lago.
- El arte disponible sigue siendo limitado: no hay hojas completas de animación ni ilustraciones de historia. Se usan alternativas procedurales y animación leve del PNG; para animación corporal detallada se necesitarían recursos adicionales compatibles con el cargador de arte existente.
- No se añadieron mapas, bibliotecas, dependencias ni un sistema de guardado por objeto a mitad de nivel. La progresión conserva el guardado por acto y los checkpoints originales.
- Guardados anteriores que ya indicaran victoria o modo prueba no se borran ni se reinterpretan automáticamente. Para comprobar el recorrido inicial usar datos temporales o la opción existente de borrar progreso, después de respaldar la partida si se desea conservarla.
