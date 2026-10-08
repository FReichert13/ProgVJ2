--declaracion
Sonidos = nil
--volumenes base (se multiplican por el volumen general de opciones)
VolLaser  = 0.35
VolDerrota = 0.7
VolMusicaMenu  = 0.5
VolMusicaJuego = 0.15
--inicializacion
function CargarSonidos()
    Sonidos = {
        laser       = love.audio.newSource("sonidos/sfx_laser1.ogg", "static"),
        derrota     = love.audio.newSource("sonidos/sfx_lose.ogg", "static"),
        musicaMenu  = love.audio.newSource("sonidos/musica_menu.mp3", "stream"),
        musicaJuego = love.audio.newSource("sonidos/musica_juego.mp3", "stream")
    }
    Sonidos.musicaMenu:setLooping(true)
    Sonidos.musicaJuego:setLooping(true)
    AplicarVolumen()
    --el sonido de derrota responde a un evento
    Signal.register("alPerder", function() ReproducirDerrota() end)
end
--aplica el volumen general a la musica
function AplicarVolumen()
    Sonidos.musicaMenu:setVolume(VolMusicaMenu * Config.volumen)
    Sonidos.musicaJuego:setVolume(VolMusicaJuego * Config.volumen)
end
--reproduccion
function ReproducirLaser()
    local s = Sonidos.laser:clone()
    s:setVolume(VolLaser * Config.volumen)
    s:play()
end
function ReproducirLaserEnemigo()
    local s = Sonidos.laser:clone()
    s:setPitch(0.6)
    s:setVolume(0.22 * Config.volumen)
    s:play()
end
function ReproducirDerrota()
    Sonidos.derrota:setVolume(VolDerrota * Config.volumen)
    Sonidos.derrota:play()
end
--musica (idempotente: no reinicia si ya suena, y corta la otra pista)
function ReproducirMusicaMenu()
    if Sonidos.musicaJuego:isPlaying() then Sonidos.musicaJuego:stop() end
    if not Sonidos.musicaMenu:isPlaying() then Sonidos.musicaMenu:play() end
end
function ReproducirMusicaJuego()
    if Sonidos.musicaMenu:isPlaying() then Sonidos.musicaMenu:stop() end
    if not Sonidos.musicaJuego:isPlaying() then Sonidos.musicaJuego:play() end
end