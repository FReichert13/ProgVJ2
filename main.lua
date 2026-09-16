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
require('estadosJuego')
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
    InicializarFuentes()
    MaquinaJuego = MaquinaEstado{
        menu     = function() return EstadoMenu() end,
        jugando  = function() return EstadoJugando() end,
        victoria = function() return EstadoVictoria() end,
        derrota  = function() return EstadoDerrota() end
    }
    MaquinaJuego:cambiar("menu")
end
--interaccion
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if MaquinaJuego.actual.teclado then
        MaquinaJuego.actual:teclado(key)
    end
end
--actualizacion
function love.update(dt)
    ActualizarFondo(dt)
    ActualizarEfectos(dt)
    MaquinaJuego:actualizar(dt)
end
--renderizado
function love.draw()
    DibujarFondo()
    MaquinaJuego:dibujar()
end