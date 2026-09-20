--configuracion global
ANCHO = 960
ALTO  = 1280
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
require('misil')
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
    Lienzo = love.graphics.newCanvas(ANCHO, ALTO)
    CargarSonidos()
    InicializarFondo()
    InicializarJugador()
    InicializarDisparos()
    InicializarMisiles()
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
    --dibuja el juego en resolucion logica sobre el lienzo
    love.graphics.setCanvas(Lienzo)
    love.graphics.clear()
        DibujarFondo()
        MaquinaJuego:dibujar()
    love.graphics.setCanvas()
    --escala el lienzo para llenar la ventana manteniendo la proporcion
    local vw, vh = love.graphics.getDimensions()
    local escala = math.min(vw / ANCHO, vh / ALTO)
    local ox = (vw - ANCHO * escala) / 2
    local oy = (vh - ALTO * escala) / 2
    love.graphics.draw(Lienzo, ox, oy, 0, escala, escala)
end