--configuracion global
ANCHO = 1280
ALTO  = 720
--modulos
Class = require('lib.class')
require('estado')
require('maquinaEstado')
require('estadosEnemigo')
require('utiles')
require('sonido')
require('fondo')
require('jugador')
require('disparo')
require('balaEnemiga')
require('enemigo')
require('tiposEnemigo')
require('obstaculo')
require('efectos')
require('juego')
--inicializacion
function love.load()
    math.randomseed(os.time())
    CargarSonidos()
    InicializarFondo()
    InicializarJugador()
    InicializarDisparos()
    InicializarBalasEnemigas()
    InicializarEnemigos()
    InicializarObstaculos()
    InicializarEfectos()
    InicializarJuego()
end
--interaccion
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if Juego.estado == "jugando" then
        InteraccionJugador(key)
    elseif key == "r" then
        ReiniciarJuego()
    end
end
--actualizacion
function love.update(dt)
    ActualizarFondo(dt)
    ActualizarEfectos(dt)
    ActualizarJuego(dt)  
    if Juego.estado == "jugando" then
        ActualizarJugador(dt)
        ActualizarDisparos(dt)
        ActualizarBalasEnemigas(dt)
        ActualizarEnemigos(dt)
        ActualizarObstaculos(dt)
    end
end
--renderizado
function love.draw()
    DibujarFondo()
    DibujarObstaculos()      --meteoros y planetas
    DibujarEnemigos()
    DibujarBalasEnemigas()
    DibujarDisparos()
    DibujarJugador()
    DibujarEfectos()
    DibujarDestello()
    DibujarHUD()
    if Juego.estado ~= "jugando" then
        DibujarFinDeJuego()
    end
end
