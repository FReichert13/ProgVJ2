--clase hud (interfaz de juego que escucha eventos)
HUD = Class{}
--inicializacion
function HUD:init()
    self.vida = 100
    self.puntaje = 0
    self.textoOleada = ""
    self.tiempoOleada = 0
    --suscribir eventos
    Signal.register("alRecibirDanio", function(vida) self:ActualizarVida(vida) end)
    Signal.register("alMorirEnemigo", function(puntos) self:SumarPuntaje(puntos) end)
    Signal.register("alDestruirMeteoro", function(puntos) self:SumarPuntaje(puntos) end)
    Signal.register("alIniciarOleada", function(numero) self:AnunciarOleada(numero) end)
    Signal.register("alReiniciar", function() self:Reiniciar() end)
end
--oyentes
function HUD:ActualizarVida(vida)
    self.vida = vida
end
function HUD:SumarPuntaje(puntos)
    self.puntaje = self.puntaje + puntos
end
function HUD:AnunciarOleada(numero)
    self.textoOleada = "OLEADA " .. numero
    self.tiempoOleada = 1.8
end
function HUD:Reiniciar()
    self.vida = 100
    self.puntaje = 0
    self.tiempoOleada = 0
end
--actualizacion (cuenta regresiva del cartel)
function HUD:Actualizar(dt)
    if self.tiempoOleada > 0 then
        self.tiempoOleada = self.tiempoOleada - dt
    end
end
--renderizado
function HUD:Dibujar()
    love.graphics.setFont(Juego.fuenteHUD)
    love.graphics.setColor(1, 1, 1, 1)
    --fila 1: energia (izquierda) y misiles (derecha)
    love.graphics.print("Energía", 12, 10)
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", 130, 12, 140, 16)
    local r, g, b = 0.2, 0.9, 0.3
    if self.vida <= 15 then r, g, b = 1, 0.2, 0.2
    elseif self.vida <= 40 then r, g, b = 1, 0.6, 0.1 end
    love.graphics.setColor(r, g, b, 1)
    love.graphics.rectangle("fill", 130, 12, 140 * (self.vida / 100), 16)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(math.floor(self.vida), 280, 10)
    love.graphics.print("Misiles [X]", ANCHO - 300, 10)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", ANCHO - 120, 12, 110, 16)
    if Jugador.misilesListos then
        love.graphics.setColor(1, 0.8, 0.2, 1)
        love.graphics.rectangle("fill", ANCHO - 120, 12, 110, 16)
    else
        local pr = 1 - (Jugador.misilesRecarga / Jugador.misilesRecargaMax)
        love.graphics.setColor(0.8, 0.6, 0.1, 1)
        love.graphics.rectangle("fill", ANCHO - 120, 12, 110 * pr, 16)
    end
    love.graphics.setColor(1, 1, 1, 1)
    --fila 2: oleada, puntaje y enemigos
    love.graphics.print("Oleada " .. Juego.oleada .. "/" .. Juego.oleadasTotales, 12, 40)
    love.graphics.print("Puntaje " .. self.puntaje, 320, 40)
    love.graphics.print("Enemigos " .. #Enemigos, 620, 40)
    --cartel de oleada (respuesta visual al evento)
    if self.tiempoOleada > 0 then
        love.graphics.setFont(Juego.fuenteGrande)
        love.graphics.setColor(1, 1, 1, math.min(1, self.tiempoOleada))
        love.graphics.printf(self.textoOleada, 0, ALTO * 0.3, ANCHO, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
    --controles abajo
    love.graphics.setFont(Juego.fuenteControles)
    love.graphics.print("Flechas/AD: girar   W: avanzar   Espacio: disparar   X: misiles",
                        12, ALTO - 22)
end
--gestor (se crea una sola vez)
function InicializarHUD()
    MiHUD = HUD()
end