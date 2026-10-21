--declaracion
BalasEnemigas = {}
--inicializacion
function InicializarBalasEnemigas()
    BalasEnemigas = {}
end
function LanzarBalaEnemiga(x, y, angulo, opts)
    opts = opts or {}
    local velocidad = opts.velocidad or 260
    local radio = opts.radio or 6
    table.insert(BalasEnemigas, {
        x = x,
        y = y,
        ancho = radio * 2,
        alto  = radio * 2,
        radio = radio,
        danio = opts.danio or 10,
        velX = math.cos(angulo) * velocidad,
        velY = math.sin(angulo) * velocidad
    })
    if not opts.silencioso then ReproducirLaserEnemigo() end
end
--actualiacion
function ActualizarBalasEnemigas(dt)
    for i = #BalasEnemigas, 1, -1 do
        local b = BalasEnemigas[i]
        b.x = b.x + b.velX * dt
        b.y = b.y + b.velY * dt
        if b.x < -20 or b.x > ANCHO + 20 or b.y < -20 or b.y > ALTO + 20 then
            table.remove(BalasEnemigas, i)
        end
    end
end
--renderizado
function DibujarBalasEnemigas()
    for _, b in ipairs(BalasEnemigas) do
        local r = b.radio or 6
        love.graphics.setColor(1, 0.3, 0.35, 1)
        love.graphics.circle("fill", b.x, b.y, r)
        love.graphics.setColor(1, 0.85, 0.85, 1)
        love.graphics.circle("fill", b.x, b.y, r * 0.5)
        love.graphics.setColor(1, 1, 1, 1)
    end
end