--estado
Juego = {
    oleada = 0,
    oleadaVictoria = 10,
    continuar = false,
    gano = false,
    destelloDanio = 0,
    fuenteHUD = nil,
    fuenteGrande = nil
}
--fuentes (se crean una sola vez)
function InicializarFuentes()
    Juego.fuenteHUD       = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 14)
    Juego.fuenteControles = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 11)
    Juego.fuenteGrande    = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 32)
    Juego.fuenteTitulo    = love.graphics.newFont("fonts/PressStart2P-Regular.ttf", 48)
    love.graphics.setFont(Juego.fuenteHUD)
end
--inicializacion
function InicializarJuego()
    Juego.oleada = 0
    Juego.gano = false
    Juego.destelloDanio = 0
    SiguienteOleada()
end
function ReiniciarJuego()
    Signal.emit("alReiniciar")
    Jugador.x = ANCHO / 2
    Jugador.y = ALTO * 0.75
    Jugador.angulo = -math.pi / 2
    Jugador.vida = 100
    Jugador.vivo = true
    Jugador.invulnerable = 0
    Jugador.misilesListos = true
    Jugador.misilesRecarga = 0
    Signal.clear("aturdirEnemigos")
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
--oleadas (infinitas, el mapa se acelera y a la oleada meta hay victoria)
function SiguienteOleada()
    Juego.oleada = Juego.oleada + 1
    Fondo.vel = math.min(340 + (Juego.oleada - 1) * 35, 900)
    GenerarOleada(Juego.oleada)
    Signal.emit("alIniciarOleada", Juego.oleada)
    if Juego.oleada == Juego.oleadaVictoria then
        Juego.gano = true
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
        Signal.emit("alPerder")
    end
    Signal.emit("alRecibirDanio", Jugador.vida)
end
--muerte instantanea (cuando te chocas a un planeta)
function DestruirJugador()
    Jugador.vida = 0
    Jugador.vivo = false
    Juego.destelloDanio = 1
    CrearExplosion(Jugador.x, Jugador.y, 0.9)
    Signal.emit("alPerder")
    Signal.emit("alRecibirDanio", 0)
end
--misiles (lanza 6 misiles en abanico, 3 de cada lado)
function LanzarMisiles()
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
    Signal.emit("aturdirEnemigos")
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
                e:Eliminar()
                table.remove(Enemigos, j)
                table.remove(Disparos, i)
                Signal.emit("alMorirEnemigo", 10)
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
                Signal.emit("alDestruirMeteoro", 5)
                break
            end
        end
    end
    --misiles contra enemigos y meteoros (un golpe, menos planetas)
    for i = #Misiles, 1, -1 do
        local m = Misiles[i]
        local mx = m.x - m.ancho / 2
        local my = m.y - m.alto / 2
        local impacto = false
        for j = #Enemigos, 1, -1 do
            local e = Enemigos[j]
            if hayColision(mx, my, m.ancho, m.alto, e:CajaX(), e:CajaY(), e.ancho, e.alto) then
                CrearExplosion(e.x, e.y)
                e:Eliminar()
                table.remove(Enemigos, j)
                Signal.emit("alMorirEnemigo", 10)
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
                    Signal.emit("alDestruirMeteoro", 5)
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
    love.graphics.setFont(Juego.fuenteTitulo)
    love.graphics.printf("STELLAR", 0, ALTO / 2 - 160, ANCHO, "center")
    love.graphics.printf("GUARDIAN", 0, ALTO / 2 - 100, ANCHO, "center")
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.printf("Enter para jugar", 0, ALTO / 2, ANCHO, "center")
    love.graphics.setFont(Juego.fuenteControles)
    love.graphics.printf("Flechas/AD: girar    W/Arriba: avanzar    Espacio: disparar    X: misiles",
                        0, ALTO / 2 + 50, ANCHO, "center")
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
    MiHUD:Dibujar()
end
function DibujarDestello()
    if Juego.destelloDanio > 0 then
        love.graphics.setColor(1, 0, 0, 0.35 * Juego.destelloDanio)
        love.graphics.rectangle("fill", 0, 0, ANCHO, ALTO)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
--modo debug (hitboxes y fps, se activa con F1)
function DibujarDebug()
    if not Depurar then return end
    love.graphics.setColor(0, 1, 0, 1)
    for _, e in ipairs(Enemigos) do
        love.graphics.rectangle("line", e:CajaX(), e:CajaY(), e.ancho, e.alto)
    end
    for _, o in ipairs(Obstaculos) do
        love.graphics.rectangle("line", o:CajaX(), o:CajaY(), o:CajaAncho(), o:CajaAlto())
    end
    love.graphics.rectangle("line", CajaJugadorX(), CajaJugadorY(), Jugador.ancho, Jugador.alto)
    love.graphics.setFont(Juego.fuenteControles)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 12, 70)
    love.graphics.setColor(1, 1, 1, 1)
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
    love.graphics.printf("Puntaje: " .. MiHUD.puntaje, 0, ALTO / 2, ANCHO, "center")
    if gano then
        love.graphics.printf("Enter: seguir    R: reiniciar", 0, ALTO / 2 + 30, ANCHO, "center")
    else
        love.graphics.printf("Presioná R para reiniciar", 0, ALTO / 2 + 30, ANCHO, "center")
    end
end