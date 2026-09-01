Guardian Estelar
Shooter espacial de combate aereo en Lua y LOVE2D.
Pilotas una nave que gira y avanza por un mapa que se desplaza. Naves enemigas
te persiguen y disparan, si salen del borde, dan la vuelta y siguen. Destrui
todas las oleadas para ganar, si tu energia llega a cero, perdes.

Controles
| Tecla | Accion |
| Flechas Izq/Der o A/D | Girar la nave |
| Flecha Arriba o W | Avanzar |
| Espacio (mantener) | Disparar |
| X | Bengala: estallido de area (con recarga) |
| R | Reiniciar (en pantalla final) |
| Esc | Salir |

Como ejecutar
Instalar LOVE 11.x desde https://love2d.org
Arrastrar la carpeta (la que contiene main.lua) sobre el ejecutable de LOVE.


Estructura del proyecto
main.lua         Configuracion global, modulos y callbacks de LOVE
conf.lua         Ventana (1280x720)
jugador.lua      Nave: girar, avanzar, disparar, bengala, llama animada
disparo.lua      Laseres del jugador 
balaEnemiga.lua  Balas de los enemigos
enemigo.lua      Clase Enemigo: persecucion, disparo, vuelta por bordes
efectos.lua      Explosiones con sistema de particulas
juego.lua        Oleadas, energia, victoria/derrota, colisiones AABB, HUD
fondo.lua        Fondo estelar con desplazamiento
sonido.lua       Carga y reproduccion de audio
utiles.lua       Colision AABB y utilidades

Creditos
Assets: Kenney (CC0). Ver creditos.txt
