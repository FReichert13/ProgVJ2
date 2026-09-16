--estado
Juego = {
    puntaje = 0,
    oleada = 0,
    oleadasTotales = 3,
    gano = false,
    destelloDanio = 0,
    fuenteHUD = nil,
    fuenteGrande = nil
}
--fuentes (se crean una sola vez)
function InicializarFuentes()
    Juego.fuenteHUD    = love.graphics.newFont(16)
    Juego.fuenteGrande = love.graphics.newFont(52)
    love.graphics.setFont(Juego.fuenteHUD)
end
--inicializacion
function InicializarJuego()
    Juego.puntaje = 0
    Juego.oleada = 0
    Juego.gano = false
    Juego.destelloDanio = 0
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
    Misiles = {}
    TiempoMeteoro = 0
    TiempoPlaneta = 0
    InicializarJuego()
end
--oleadas
function SiguienteOleada()
    Juego.oleada = Juego.oleada + 1
    if Juego.oleada > Juego.oleadasTotales then
        Juego.gano = true
    else
        GenerarOleada(Juego.oleada)
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
        ReproducirDerrota()
    end
end
--muerte instantanea (cuando te chocas a un planeta)
function DestruirJugador()
    Jugador.vida = 0
    Jugador.vivo = false
    Juego.destelloDanio = 1
    CrearExplosion(Jugador.x, Jugador.y, 0.9)
    ReproducirDerrota()
end
--bengala (lanza 6 misiles en abanico, 3 de cada lado)
function LanzarBengala()
    local a = Jugador.angulo
    local lateral = Jugador.alto / 2
    local izqX = Jugador.x + math.cos(a - math.pi / 2) * lateral
    local izqY = Jugador.y + math.sin(a - math.pi / 2) * lateral
    local derX = Jugador.x + math.cos(a + math.pi / 2) * lateral
    local derY = Jugador.y + math.sin(a + math.pi / 2) * lateral
    local aberturas = {math.rad(20), math.rad(45), math.rad(70)}
    for _, off in ipairs(aberturas) do
        LanzarMisil(izqX, izqY, a - off)
        LanzarMisil(derX, derY, a + off)
    end
    ReproducirLaser()
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
    --misiles de la bengala (destruyen nave o meteoro de un golpe, menos planetas)
    for i = #Misiles, 1, -1 do
        local m = Misiles[i]
        local mx = m.x - m.ancho / 2
        local my = m.y - m.alto / 2
        local impacto = false
        for j = #Enemigos, 1, -1 do
            local e = Enemigos[j]
            if hayColision(mx, my, m.ancho, m.alto, e:CajaX(), e:CajaY(), e.ancho, e.alto) then
                CrearExplosion(e.x, e.y)
                table.remove(Enemigos, j)
                Juego.puntaje = Juego.puntaje + 10
                impacto = true
                break
            end
        end
        if not impacto then
            for j = #Obstaculos, 1, -1 do
                local o = Obstaculos[j]
                if o.tipo ~= "planeta" and hayColision(mx, my, m.ancho, m.alto,
                               o:CajaX(), o:CajaY(), o:CajaAncho(), o:CajaAlto()) then
                    CrearExplosion(o.x, o.y)
                    table.remove(Obstaculos, j)
                    Juego.puntaje = Juego.puntaje + 5
                    impacto = true
                    break
                end
            end
        end
        if impacto then
            table.remove(Misiles, i)
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
    ResolverColisiones()
    if #Enemigos == 0 and not Juego.gano then
        SiguienteOleada()
    end
end
--menu
function DibujarMenu()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteGrande)
    love.graphics.printf("GUARDIAN ESTELAR", 0, ALTO / 2 - 100, ANCHO, "center")
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.printf("Enter para jugar", 0, ALTO / 2, ANCHO, "center")
    love.graphics.printf("Flechas/AD: girar    W/Arriba: avanzar    Espacio: disparar    X: bengala",
                        0, ALTO / 2 + 40, ANCHO, "center")
end
--escena de la partida
function DibujarJuego()
    DibujarObstaculos()
    DibujarEnemigos()
    DibujarBalasEnemigas()
    DibujarDisparos()
    DibujarMisiles()
    DibujarJugador()
    DibujarEfectos()
    DibujarDestello()
    DibujarHUD()
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
function DibujarFin(gano)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteGrande)
    if gano then
        love.graphics.printf("¡VICTORIA!", 0, ALTO / 2 - 80, ANCHO, "center")
    else
        love.graphics.printf("NAVE DESTRUIDA", 0, ALTO / 2 - 80, ANCHO, "center")
    end
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.printf("Puntaje final: " .. Juego.puntaje, 0, ALTO / 2, ANCHO, "center")
    love.graphics.printf("Presioná R para reiniciar", 0, ALTO / 2 + 30, ANCHO, "center")
end