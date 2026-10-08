--estados del juego

--menu inicial (con submenus de opciones y controles)
EstadoMenu = Class{ __includes = Estado }
function EstadoMenu:ingresar()
    ReproducirMusicaMenu()
    self.pantalla = "principal"
    self.seleccion = 1
end
function EstadoMenu:dibujar()
    DibujarTituloMenu()
    if self.pantalla == "principal" then
        DibujarMenuLista(OpcionesPrincipal, self.seleccion, ALTO / 2, 70)
    elseif self.pantalla == "opciones" then
        DibujarMenuOpciones(self.seleccion)
    elseif self.pantalla == "controles" then
        DibujarMenuControles(self.seleccion)
    end
end
function EstadoMenu:teclado(key)
    if self.pantalla == "principal" then
        self.seleccion = MoverSeleccion(self.seleccion, #OpcionesPrincipal, key)
        if key == "return" then
            if self.seleccion == 1 then MaquinaJuego:cambiar("jugando")
            elseif self.seleccion == 2 then self.pantalla = "opciones"; self.seleccion = 1
            elseif self.seleccion == 3 then self.pantalla = "controles"; self.seleccion = 1
            elseif self.seleccion == 4 then love.event.quit() end
        end
    elseif self.pantalla == "opciones" then
        self.seleccion = MoverSeleccion(self.seleccion, 3, key)
        if self.seleccion == 1 then
            if key == "left"  then Config.volumen = math.max(0, Config.volumen - 0.1); AplicarVolumen()
            elseif key == "right" then Config.volumen = math.min(1, Config.volumen + 0.1); AplicarVolumen() end
        elseif self.seleccion == 2 then
            if key == "left"  then Config.brillo = math.max(0.3, Config.brillo - 0.1)
            elseif key == "right" then Config.brillo = math.min(1, Config.brillo + 0.1) end
        end
        if key == "return" and self.seleccion == 3 then
            self.pantalla = "principal"; self.seleccion = 2
        end
    elseif self.pantalla == "controles" then
        if key == "return" then
            self.pantalla = "principal"; self.seleccion = 3
        end
    end
end

--partida en curso
EstadoJugando = Class{ __includes = Estado }
function EstadoJugando:ingresar()
    ReproducirMusicaJuego()
    if Juego.continuar then
        Juego.continuar = false
        Juego.gano = false
    else
        ReiniciarJuego()
    end
end
function EstadoJugando:actualizar(dt)
    ActualizarJugador(dt)
    ActualizarDisparos(dt)
    ActualizarMisiles(dt)
    ActualizarBalasEnemigas(dt)
    ActualizarEnemigos(dt)
    ActualizarObstaculos(dt)
    ActualizarJuego(dt)
    MiHUD:Actualizar(dt)
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
function EstadoVictoria:ingresar()
    ReproducirMusicaMenu()
    self.seleccion = 1
end
function EstadoVictoria:dibujar()
    DibujarJuego()
    DibujarPanelFin("¡VICTORIA!", OpcionesVictoria, self.seleccion)
end
function EstadoVictoria:teclado(key)
    self.seleccion = MoverSeleccion(self.seleccion, #OpcionesVictoria, key)
    if key == "return" then
        if self.seleccion == 1 then
            Juego.continuar = true
            MaquinaJuego:cambiar("jugando")
        elseif self.seleccion == 2 then
            MaquinaJuego:cambiar("menu")
        elseif self.seleccion == 3 then
            love.event.quit()
        end
    end
end

--pantalla de derrota
EstadoDerrota = Class{ __includes = Estado }
function EstadoDerrota:ingresar()
    ReproducirMusicaMenu()
    self.seleccion = 1
end
function EstadoDerrota:dibujar()
    DibujarJuego()
    DibujarPanelFin("NAVE DESTRUIDA", OpcionesDerrota, self.seleccion)
end
function EstadoDerrota:teclado(key)
    self.seleccion = MoverSeleccion(self.seleccion, #OpcionesDerrota, key)
    if key == "return" then
        if self.seleccion == 1 then
            MaquinaJuego:cambiar("jugando")
        elseif self.seleccion == 2 then
            MaquinaJuego:cambiar("menu")
        elseif self.seleccion == 3 then
            love.event.quit()
        end
    end
end