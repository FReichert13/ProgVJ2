--declaracion
Jugador = {
    x = 640,
    y = 360,
    angulo = -math.pi / 2,
    ancho = 98,
    alto = 75,
    vel = 320,
    velGiro = 3.6,
    vida = 100,
    sprite = nil,
    cadencia = 0.18,
    tiempoDisparo = 0,
    bengalaLista = true,
    bengalaRecarga = 0,
    bengalaRecargaMax = 6,
    invulnerable = 0,
    vivo = true,
    llama = nil,
    llamaEscala = 1,
    llamaTiempo = 0,
    propulsando = false
}
--inicializacion
function InicializarJugador()
    Jugador.sprite = love.graphics.newImage("img/playerShip3_green.png")
    Jugador.llama  = love.graphics.newImage("img/fire13.png")
    Jugador.ancho  = Jugador.sprite:getWidth()
    Jugador.alto   = Jugador.sprite:getHeight()
end
--interaccion
function InteraccionJugador(key)
    if key == "x" and Jugador.bengalaLista then
        LanzarBengala()
        Jugador.bengalaLista = false
        Jugador.bengalaRecarga = Jugador.bengalaRecargaMax
    end
end
--actualizacion
function ActualizarJugador(dt)
    if love.keyboard.isDown("left", "a")  then Jugador.angulo = Jugador.angulo - Jugador.velGiro * dt end
    if love.keyboard.isDown("right", "d") then Jugador.angulo = Jugador.angulo + Jugador.velGiro * dt end
    Jugador.propulsando = false
    if love.keyboard.isDown("up", "w") then
        Jugador.x = Jugador.x + math.cos(Jugador.angulo) * Jugador.vel * dt
        Jugador.y = Jugador.y + math.sin(Jugador.angulo) * Jugador.vel * dt
        Jugador.propulsando = true
    end
    --limite de pantalla
    local mx = Jugador.ancho / 2
    local my = Jugador.alto / 2
    if Jugador.x < mx         then Jugador.x = mx end
    if Jugador.x > ANCHO - mx then Jugador.x = ANCHO - mx end
    if Jugador.y < my         then Jugador.y = my end
    if Jugador.y > ALTO - my  then Jugador.y = ALTO - my end
    Jugador.tiempoDisparo = Jugador.tiempoDisparo - dt
    if love.keyboard.isDown("space") and Jugador.tiempoDisparo <= 0 then
        local nx = Jugador.x + math.cos(Jugador.angulo) * (Jugador.alto / 2)
        local ny = Jugador.y + math.sin(Jugador.angulo) * (Jugador.alto / 2)
        DispararLaser(nx, ny, Jugador.angulo)
        Jugador.tiempoDisparo = Jugador.cadencia
    end
    if not Jugador.bengalaLista then
        Jugador.bengalaRecarga = Jugador.bengalaRecarga - dt
        if Jugador.bengalaRecarga <= 0 then
            Jugador.bengalaRecarga = 0
            Jugador.bengalaLista = true
        end
    end
    if Jugador.invulnerable > 0 then
        Jugador.invulnerable = Jugador.invulnerable - dt
    end

    Jugador.llamaTiempo = Jugador.llamaTiempo + dt * 20
    Jugador.llamaEscala = 0.6 + math.abs(math.sin(Jugador.llamaTiempo)) * 0.4
end
--renderizado
function DibujarJugador()
    if not Jugador.vivo then return end
    local escala = Jugador.llamaEscala * (Jugador.propulsando and 1.5 or 0.7)
    local tx = Jugador.x - math.cos(Jugador.angulo) * (Jugador.alto / 2)
    local ty = Jugador.y - math.sin(Jugador.angulo) * (Jugador.alto / 2)
    love.graphics.draw(Jugador.llama, tx, ty, Jugador.angulo + math.pi / 2,
                       1, escala, Jugador.llama:getWidth() / 2, 0)
    if Jugador.invulnerable > 0 and math.floor(Jugador.invulnerable * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.3)
    end
    love.graphics.draw(Jugador.sprite, Jugador.x, Jugador.y, Jugador.angulo + math.pi / 2,
                       1, 1, Jugador.ancho / 2, Jugador.alto / 2)
    love.graphics.setColor(1, 1, 1, 1)
end
function CajaJugadorX() return Jugador.x - Jugador.ancho / 2 end
function CajaJugadorY() return Jugador.y - Jugador.alto / 2 end
