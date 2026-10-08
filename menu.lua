--configuracion y menus del juego
Config = {
    volumen = 1,
    brillo = 1
}
--opciones de cada menu
OpcionesPrincipal = {"Jugar", "Opciones", "Controles", "Salir"}
OpcionesVictoria  = {"Seguir jugando", "Volver al menu", "Salir"}
OpcionesDerrota   = {"Volver a jugar", "Volver al menu", "Salir"}
--mueve la seleccion con arriba/abajo (con vuelta circular)
function MoverSeleccion(sel, cantidad, key)
    if key == "up" then
        sel = sel - 1
        if sel < 1 then sel = cantidad end
    elseif key == "down" then
        sel = sel + 1
        if sel > cantidad then sel = 1 end
    end
    return sel
end
--dibuja una lista de opciones centradas con una flechita en la seleccionada
function DibujarMenuLista(opciones, seleccion, y, paso)
    local fuente = Juego.fuenteMenu
    love.graphics.setFont(fuente)
    for i, texto in ipairs(opciones) do
        local oy = y + (i - 1) * paso
        local x = (ANCHO - fuente:getWidth(texto)) / 2
        if i == seleccion then
            love.graphics.setColor(1, 1, 0.3, 1)
            love.graphics.print(">", x - 55, oy)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.print(texto, x, oy)
    end
    love.graphics.setColor(1, 1, 1, 1)
end
--titulo del menu principal
function DibujarTituloMenu()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteTitulo)
    love.graphics.printf("STELLAR", 0, ALTO / 2 - 300, ANCHO, "center")
    love.graphics.printf("GUARDIAN", 0, ALTO / 2 - 240, ANCHO, "center")
end
--submenu de opciones (volumen y brillo se mueven con izquierda/derecha)
function DibujarMenuOpciones(seleccion)
    local vol = math.floor(Config.volumen * 100 + 0.5)
    local bri = math.floor(Config.brillo * 100 + 0.5)
    local ops = {
        "Volumen  < " .. vol .. "% >",
        "Brillo  < " .. bri .. "% >",
        "Volver"
    }
    DibujarMenuLista(ops, seleccion, ALTO / 2, 70)
end
--submenu de controles (solo muestra, no se cambian)
function DibujarMenuControles(seleccion)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteHUD)
    local lineas = {
        "Flechas / A - D : girar",
        "W / Arriba : avanzar",
        "Espacio : disparar",
        "X : misiles",
        "F1 : modo debug",
        "Esc : salir"
    }
    local y = ALTO / 2 - 140
    for i, l in ipairs(lineas) do
        love.graphics.printf(l, 0, y + (i - 1) * 50, ANCHO, "center")
    end
    DibujarMenuLista({"Volver"}, 1, y + #lineas * 50 + 30, 70)
end
--panel de victoria/derrota con sus opciones
function DibujarPanelFin(titulo, opciones, seleccion)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteGrande)
    love.graphics.printf(titulo, 0, ALTO / 2 - 180, ANCHO, "center")
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.printf("Puntaje: " .. MiHUD.puntaje, 0, ALTO / 2 - 110, ANCHO, "center")
    DibujarMenuLista(opciones, seleccion, ALTO / 2, 70)
end
--oscurecimiento segun el brillo (se dibuja arriba de todo)
function DibujarBrillo()
    if Config.brillo < 1 then
        love.graphics.setColor(0, 0, 0, 1 - Config.brillo)
        love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
        love.graphics.setColor(1, 1, 1, 1)
    end
end