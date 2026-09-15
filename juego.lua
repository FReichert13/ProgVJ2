--estado
Juego = {
    estado = "jugando",
    puntaje = 0,
    oleada = 0,
    oleadasTotales = 3,
    destelloDanio = 0,
    fuenteHUD = nil,
    fuenteGrande = nil
}
--inicializacion
function InicializarJuego()
    Juego.estado = "jugando"
    Juego.puntaje = 0
    Juego.oleada = 0
    Juego.destelloDanio = 0
    if not Juego.fuenteHUD then
        Juego.fuenteHUD    = love.graphics.newFont(16)
        Juego.fuenteGrande = love.graphics.newFont(52)
    end
    love.graphics.setFont(Juego.fuenteHUD)
    SiguienteOleada()
end
function ReiniciarJuego()
    Jugador.x = ANCHO / 2
    Jugador.y = ALTO / 2
    Jugador.angulo = -math.pi / 2
    Jugador.vida = 100
    Jugador.vivo = true
    Jugador.invulnerable = 0
    Jugador.bengalaLista = true
    Jugador.bengalaRecarga = 0
    Disparos = {}
    BalasEnemigas = {}
    Enemigos = {}
    Obstaculos = {}
    Efectos = {}
    TiempoMeteoro = 0
    TiempoPlaneta = 0
    InicializarJuego()
end
--oleadas
function SiguienteOleada()
    Juego.oleada = Juego.oleada + 1
    if Juego.oleada > Juego.oleadasTotales then
        Juego.estado = "victoria"
    else
        local cantidad  = 3 + Juego.oleada
        local velocidad = 80 + Juego.oleada * 20
        GenerarOleada(cantidad, velocidad)
    end
end
--daño
function DanarJugador(danio)
    if Jugador.invulnerable > 0 then return end
    Jugador.vida = Jugador.vida - danio
    Jugador.invulnerable = 1.2
    Juego.destelloDanio = 1
    CrearHumo(Jugador.x, Jugador.y)
    if Jugador.vida <= 0 then
        Jugador.vida = 0
        Jugador.vivo = false
        CrearExplosion(Jugador.x, Jugador.y, 0.9)
        Juego.estado = "derrota"
        ReproducirDerrota()
    end
end
--muerte instantanea (cuando te chocas a un planeta)
function DestruirJugador()
    Jugador.vida = 0
    Jugador.vivo = false
    Juego.destelloDanio = 1
    CrearExplosion(Jugador.x, Jugador.y, 0.9)
    Juego.estado = "derrota"
    ReproducirDerrota()
end
--bengala (explocion en area que destruye a los enemigos cercanos)
function LanzarBengala()
    local lado = 380
    local bx = Jugador.x - lado / 2
    local by = Jugador.y - lado / 2
    for j = #Enemigos, 1, -1 do
        local e = Enemigos[j]
        if hayColision(bx, by, lado, lado, e:CajaX(), e:CajaY(), e.ancho, e.alto) then
            CrearExplosion(e.x, e.y)
            table.remove(Enemigos, j)
            Juego.puntaje = Juego.puntaje + 15
        end
    end
    CrearExplosion(Jugador.x, Jugador.y)
end
--colisiones
function ResolverColisiones()
    --laser contra enemigos
    for i = #Disparos, 1, -1 do
        local p = Disparos[i]
        local px = p.x - p.ancho / 2
        local py = p.y - p.alto / 2
        for j = #Enemigos, 1, -1 do
            local e = Enemigos[j]
            if hayColision(px, py, p.ancho, p.alto, e:CajaX(), e:CajaY(), e.ancho, e.alto) then
                CrearExplosion(e.x, e.y)
                table.remove(Enemigos, j)
                table.remove(Disparos, i)
                Juego.puntaje = Juego.puntaje + 10
                break
            end
        end
    end
    --laser contra meteoros chicos (estos son destruibles)
    for i = #Disparos, 1, -1 do
        local p = Disparos[i]
        local px = p.x - p.ancho / 2
        local py = p.y - p.alto / 2
        for j = #Obstaculos, 1, -1 do
            local o = Obstaculos[j]
            if o.destruible and hayColision(px, py, p.ancho, p.alto,
                           o:CajaX(), o:CajaY(), o:CajaAncho(), o:CajaAlto()) then
                CrearExplosion(o.x, o.y)
                table.remove(Obstaculos, j)
                table.remove(Disparos, i)
                Juego.puntaje = Juego.puntaje + 5
                break
            end
        end
    end
    --balas enemigas contra el jugador
    for i = #BalasEnemigas, 1, -1 do
        local b = BalasEnemigas[i]
        if hayColision(b.x - b.ancho / 2, b.y - b.alto / 2, b.ancho, b.alto,
                       CajaJugadorX(), CajaJugadorY(), Jugador.ancho, Jugador.alto) then
            table.remove(BalasEnemigas, i)
            DanarJugador(10)
        end
    end
    --choque enemigo contra el jugador
    for j = #Enemigos, 1, -1 do
        local e = Enemigos[j]
        if hayColision(e:CajaX(), e:CajaY(), e.ancho, e.alto,
                       CajaJugadorX(), CajaJugadorY(), Jugador.ancho, Jugador.alto) then
            local dx = e.x - Jugador.x
            local dy = e.y - Jugador.y
            local d = math.sqrt(dx * dx + dy * dy)
            if d < 1 then d = 1 end
            e.x = e.x + (dx / d) * 40
            e.y = e.y + (dy / d) * 40
            DanarJugador(12)
        end
    end
    --obstaculos contra el jugador
    for i = 1, #Obstaculos do
        local o = Obstaculos[i]
        if hayColision(o:CajaX(), o:CajaY(), o:CajaAncho(), o:CajaAlto(),
                       CajaJugadorX(), CajaJugadorY(), Jugador.ancho, Jugador.alto) then
            if o.tipo == "planeta" then
                DestruirJugador()
            else
                DanarJugador(o.danio)
            end
        end
    end
end
--actualiacion
function ActualizarJuego(dt)
    if Juego.destelloDanio > 0 then
        Juego.destelloDanio = Juego.destelloDanio - dt * 1.6
        if Juego.destelloDanio < 0 then Juego.destelloDanio = 0 end
    end
    if Juego.estado ~= "jugando" then return end
    ResolverColisiones()
    if #Enemigos == 0 then
        SiguienteOleada()
    end
end
--hud
function DibujarHUD()
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Energía", 12, 10)
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", 90, 12, 160, 16)
    local r, g, b = 0.2, 0.9, 0.3
    if Jugador.vida <= 15 then r, g, b = 1, 0.2, 0.2
    elseif Jugador.vida <= 40 then r, g, b = 1, 0.6, 0.1 end
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", 90, 12, 160 * (Jugador.vida / 100), 16)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(math.floor(Jugador.vida), 258, 10)
    love.graphics.print("Oleada " .. Juego.oleada .. "/" .. Juego.oleadasTotales, 320, 10)
    love.graphics.print("Puntaje " .. Juego.puntaje, 470, 10)
    love.graphics.print("Enemigos " .. #Enemigos, 620, 10)
    love.graphics.print("Bengala [X]", ANCHO - 275, 10)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", ANCHO - 150, 12, 140, 16)
    if Jugador.bengalaLista then
        love.graphics.setColor(1, 0.8, 0.2, 1)
        love.graphics.rectangle("fill", ANCHO - 150, 12, 140, 16)
    else
        local pr = 1 - (Jugador.bengalaRecarga / Jugador.bengalaRecargaMax)
        love.graphics.setColor(0.8, 0.6, 0.1, 1)
        love.graphics.rectangle("fill", ANCHO - 150, 12, 140 * pr, 16)
    end
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print("Flechas/AD: girar    W/Arriba: avanzar    Espacio: disparar    X: bengala",
                        12, ALTO - 24)
end
function DibujarDestello()
    if Juego.destelloDanio > 0 then
        love.graphics.setColor(1, 0, 0, 0.35 * Juego.destelloDanio)
        love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
--pantalla final
function DibujarFinDeJuego()
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteGrande)
    if Juego.estado == "victoria" then
        love.graphics.printf("¡VICTORIA!", 0, ALTO / 2 - 80, ANCHO, "center")
    else
        love.graphics.printf("NAVE DESTRUIDA", 0, ALTO / 2 - 80, ANCHO, "center")
    end
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.printf("Puntaje final: " .. Juego.puntaje, 0, ALTO / 2, ANCHO, "center")
    love.graphics.printf("Presioná R para reiniciar", 0, ALTO / 2 + 30, ANCHO, "center")
end
