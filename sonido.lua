--declaracion
Sonidos = nil
--inicializacion
function CargarSonidos()
    Sonidos = {
        laser   = love.audio.newSource("sonidos/sfx_laser1.ogg", "static"),
        derrota = love.audio.newSource("sonidos/sfx_lose.ogg", "static")
    }
    Sonidos.laser:setVolume(0.35)
    Sonidos.derrota:setVolume(0.7)
end
--reproduccion
function ReproducirLaser()
    local s = Sonidos.laser:clone()
    s:play()
end
function ReproducirLaserEnemigo()
    local s = Sonidos.laser:clone()
    s:setPitch(0.6)
    s:setVolume(0.22)
    s:play()
end
function ReproducirDerrota()
    Sonidos.derrota:play()
end
