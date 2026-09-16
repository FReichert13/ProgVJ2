--misiles de la bengala
Misiles = {}
SpriteMisil = nil
function InicializarMisiles()
    Misiles = {}
    SpriteMisil = love.graphics.newImage("img/spaceMissiles_008.png")
end
--crea un misil
function LanzarMisil(x, y, angulo)
    local escala = 0.7
    table.insert(Misiles, {
        x = x,
        y = y,
        ancho = SpriteMisil:getWidth() * escala,
        alto  = SpriteMisil:getHeight() * escala,
        escala = escala,
        velX = math.cos(angulo) * 500,
        velY = math.sin(angulo) * 500,
        angulo = angulo
    })
end
function ActualizarMisiles(dt)
    for i = #Misiles, 1, -1 do
        local m = Misiles[i]
        m.x = m.x + m.velX * dt
        m.y = m.y + m.velY * dt
        if m.x < -60 or m.x > ANCHO + 60 or m.y < -60 or m.y > ALTO + 60 then
            table.remove(Misiles, i)
        end
    end
end
function DibujarMisiles()
    for _, m in ipairs(Misiles) do
        love.graphics.draw(SpriteMisil, m.x, m.y, m.angulo + math.pi / 2,
                           m.escala, m.escala, SpriteMisil:getWidth() / 2, SpriteMisil:getHeight() / 2)
    end
end