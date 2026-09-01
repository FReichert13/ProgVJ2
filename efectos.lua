--declaracion
Efectos = {}
TexturaExplosion = nil
TexturaHumo = nil
TexturaChispa = nil
--inicializacion
function InicializarEfectos()
    Efectos = {}
    TexturaExplosion = love.graphics.newImage("img/explosion05.png")
    TexturaHumo      = love.graphics.newImage("img/blackSmoke07.png")
    TexturaChispa    = love.graphics.newImage("img/fire13.png")
end
--crear
function CrearExplosion(x, y, escala)
    escala = escala or 0.3
    table.insert(Efectos, {
        tipo = "estallido", x = x, y = y,
        tiempo = 0, duracion = 0.5,
        escalaBase = escala, angulo = math.random() * math.pi * 2
    })
    --chispas (sistemas de particulas)
    local ps = love.graphics.newParticleSystem(TexturaChispa, 30)
    ps:setParticleLifetime(0.2, 0.5)
    ps:setSpeed(80, 220)
    ps:setSpread(math.pi * 2)
    ps:setSizes(1.4, 0.2)
    ps:setColors(1, 1, 1, 1, 1, 0.6, 0.2, 0)
    ps:setPosition(x, y)
    ps:emit(20)
    table.insert(Efectos, { tipo = "particulas", sistema = ps, tiempo = 0, duracion = 0.6 })
end
function CrearHumo(x, y)
    table.insert(Efectos, {
        tipo = "humo", x = x, y = y,
        tiempo = 0, duracion = 0.9,
        angulo = math.random() * math.pi * 2,
        derivaX = (math.random() - 0.5) * 20
    })
end
--actualizacion
function ActualizarEfectos(dt)
    for i = #Efectos, 1, -1 do
        local e = Efectos[i]
        e.tiempo = e.tiempo + dt
        if e.tipo == "particulas" then
            e.sistema:update(dt)
        elseif e.tipo == "humo" then
            e.y = e.y - 30 * dt
            e.x = e.x + e.derivaX * dt
        end
        if e.tiempo >= e.duracion then
            table.remove(Efectos, i)
        end
    end
end
--renderizado
function DibujarEfectos()
    for _, e in ipairs(Efectos) do
        local prog = e.tiempo / e.duracion
        if e.tipo == "estallido" then
            local esc = (0.3 + prog * 0.9) * e.escalaBase
            love.graphics.setColor(1, 1, 1, 1 - prog)
            love.graphics.draw(TexturaExplosion, e.x, e.y, e.angulo, esc, esc,
                               TexturaExplosion:getWidth() / 2, TexturaExplosion:getHeight() / 2)
            love.graphics.setColor(1, 1, 1, 1)
        elseif e.tipo == "humo" then
            local esc = 0.3 + prog * 0.5
            love.graphics.setColor(1, 1, 1, 0.7 * (1 - prog))
            love.graphics.draw(TexturaHumo, e.x, e.y, e.angulo, esc, esc,
                               TexturaHumo:getWidth() / 2, TexturaHumo:getHeight() / 2)
            love.graphics.setColor(1, 1, 1, 1)
        elseif e.tipo == "particulas" then
            love.graphics.draw(e.sistema)
        end
    end
end
