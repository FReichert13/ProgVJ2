--estados del juego
--menu inicial
EstadoMenu = Class{ __includes = Estado }
function EstadoMenu:dibujar()
    DibujarMenu()
end
function EstadoMenu:teclado(key)
    if key == "return" then
        MaquinaJuego:cambiar("jugando")
    end
end
--partida en curso
EstadoJugando = Class{ __includes = Estado }
function EstadoJugando:ingresar()
    ReiniciarJuego()
end
function EstadoJugando:actualizar(dt)
    ActualizarJugador(dt)
    ActualizarDisparos(dt)
    ActualizarMisiles(dt)
    ActualizarBalasEnemigas(dt)
    ActualizarEnemigos(dt)
    ActualizarObstaculos(dt)
    ActualizarJuego(dt)
    if not Jugador.vivo then
        MaquinaJuego:cambiar("derrota")
    elseif Juego.gano then
        MaquinaJuego:cambiar("victoria")
    end
end
function EstadoJugando:dibujar()
    DibujarJuego()
end
function EstadoJugando:teclado(key)
    InteraccionJugador(key)
end
--pantalla de victoria
EstadoVictoria = Class{ __includes = Estado }
function EstadoVictoria:dibujar()
    DibujarJuego()
    DibujarFin(true)
end
function EstadoVictoria:teclado(key)
    if key == "r" then
        MaquinaJuego:cambiar("jugando")
    end
end
--pantalla de derrota
EstadoDerrota = Class{ __includes = Estado }
function EstadoDerrota:dibujar()
    DibujarJuego()
    DibujarFin(false)
end
function EstadoDerrota:teclado(key)
    if key == "r" then
        MaquinaJuego:cambiar("jugando")
    end
end