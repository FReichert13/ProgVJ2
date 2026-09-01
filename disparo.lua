--declaracion
Disparos = {}
SpriteLaser = nil
--inicializacion
function InicializarDisparos()
    Disparos = {}
    SpriteLaser = love.graphics.newImage("img/laserGreen11.png")
end
function DispararLaser(x, y, angulo)
    local velocidad = 720
    table.insert(Disparos, {
        x = x,
        y = y,
        ancho = SpriteLaser:getWidth(),
        alto  = SpriteLaser:getHeight(),
        velX = math.cos(angulo) * velocidad,
        velY = math.sin(angulo) * velocidad,
        angulo = angulo
    })
    ReproducirLaser()
end
--actualizacion
function ActualizarDisparos(dt)
    for i = #Disparos, 1, -1 do
        local p = Disparos[i]
        p.x = p.x + p.velX * dt
        p.y = p.y + p.velY * dt
        if p.x < -60 or p.x > ANCHO + 60 or p.y < -60 or p.y > ALTO + 60 then
            table.remove(Disparos, i)
        end
    end
end
--renderizado
function DibujarDisparos()
    for _, p in ipairs(Disparos) do
        love.graphics.draw(SpriteLaser, p.x, p.y, p.angulo + math.pi / 2,
                           1, 1, p.ancho / 2, p.alto / 2)
    end
end
