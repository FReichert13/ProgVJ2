--jefe final: nave insignia del General Zorn
--comportamiento asincrono con corrutina (patron 7.3)
Jefe = Class{}
--sprite (se carga una sola vez y queda cacheado)
local spriteJefe = nil
--espera una cantidad de segundos cediendo cada frame (acumula dt)
local function esperar(segundos)
    local t = 0
    while t < segundos do
        t = t + coroutine.yield()
    end
end
--inicializacion (nivel 1 = primer jefe; sube con cada reaparicion)
function Jefe:init(x, y, nivel)
    self.nivel = nivel or 1
    self.x = x
    self.y = y
    if not spriteJefe then spriteJefe = love.graphics.newImage("img/jefe_final.png") end
    self.sprite = spriteJefe
    self.escala = 1
    self.ancho = self.sprite:getWidth()  * self.escala
    self.alto  = self.sprite:getHeight() * self.escala
    --escalado por nivel: mas vida, mas dano y dispara mas rapido
    self.hpMax = 90 + (self.nivel - 1) * 60
    self.hp = self.hpMax
    self.danioMult = 1 + (self.nivel - 1) * 0.25
    self.ritmo = math.max(0.5, 1 - (self.nivel - 1) * 0.12)
    self.danioCuerpo = math.floor(14 * self.danioMult)
    self.danioLaser  = math.floor(16 * self.danioMult)
    self.estado = "Apareciendo"
    self.muerto = false
    self.terminado = false
    self.destello = 0
    --movimiento lateral
    self.dirX = 1
    self.velX = 90
    --laser recto hacia abajo
    self.laser = { fase = "off", t = 0, x = x, ancho = 60 }
    --corrutina de patrones de ataque
    self.rutina = coroutine.create(function() self:patrones() end)
end
--espera escalada por el ritmo del jefe (mas nivel = ataca mas seguido)
function Jefe:pausa(segundos)
    esperar(segundos * self.ritmo)
end
--libreto de ataques (se lee como un guion gracias a la corrutina)
function Jefe:patrones()
    self.estado = "Preparando"
    esperar(1.5)
    while self.hp > 0 do
        if self.hp > self.hpMax * 0.5 then
            --fase 1
            self.estado = "Fase 1"
            self:abanico(6)
            self:pausa(1.2)
            self:abanico(6)
            self:pausa(1.0)
            self:balaGrande()
            self:pausa(1.6)
        else
            --fase 2 (mas agresivo)
            self.estado = "Fase 2"
            self:abanico(8)
            self:pausa(0.6)
            self:lanzarLaser()
            self:pausa(1.6)
            self:abanico(7)
            self:pausa(0.5)
            self:invocar()
            self:pausa(1.4)
        end
    end
    --derrotado: agonia con explosiones antes de la victoria
    self.muerto = true
    self.estado = "Derrotado"
    for i = 1, 8 do
        CrearExplosion(self.x + (math.random() - 0.5) * self.ancho,
                       self.y + (math.random() - 0.5) * self.alto, 0.6)
        esperar(0.18)
    end
    CrearExplosion(self.x, self.y, 1.6)
    esperar(0.4)
    self.terminado = true
end
--angulo desde el jefe hacia el jugador
function Jefe:anguloAlJugador()
    return math.atan2(Jugador.y - self.y, Jugador.x - self.x)
end
--ataque: abanico de balas iguales a las de las naves (bien espaciadas)
function Jefe:abanico(cantidad)
    local base = self:anguloAlJugador()
    local apertura = math.rad(72)
    local danio = math.floor(10 * self.danioMult + 0.5)
    for i = 1, cantidad do
        local t = (i - 1) / (cantidad - 1) - 0.5
        LanzarBalaEnemiga(self.x, self.y + self.alto / 2, base + t * apertura,
                          { velocidad = 240, danio = danio, silencioso = true })
    end
    ReproducirLaserEnemigo()
end
--ataque: una sola bala grande y lenta
function Jefe:balaGrande()
    LanzarBalaEnemiga(self.x, self.y + self.alto / 2, self:anguloAlJugador(),
                      { velocidad = 160, radio = 18, danio = math.floor(20 * self.danioMult + 0.5),
                        silencioso = true })
    ReproducirLaserEnemigo()
end
--ataque: laser recto hacia abajo (primero avisa, despues golpea)
function Jefe:lanzarLaser()
    self.laser.fase = "aviso"
    self.laser.t = 0
    self.laser.x = self.x
end
--ataque: invoca un par de enemigos rapidos
function Jefe:invocar()
    table.insert(Enemigos, EnemigoRapido(self.x - 120, self.y, 150))
    table.insert(Enemigos, EnemigoRapido(self.x + 120, self.y, 150))
end
--recibe dano del jugador
function Jefe:RecibirDano(n)
    if self.muerto then return end
    self.hp = math.max(0, self.hp - n)
    self.destello = 1
end
function Jefe:LaserActivo() return self.laser.fase == "activo" end
function Jefe:LaserCaja() return self.laser.x - self.laser.ancho / 2, self.laser.ancho end
function Jefe:CajaX() return self.x - self.ancho / 2 end
function Jefe:CajaY() return self.y - self.alto / 2 end
--actualizacion
function Jefe:Actualizar(dt)
    if self.destello > 0 then self.destello = self.destello - dt * 4 end
    --avanza el libreto de la corrutina (patron 7.3)
    if coroutine.status(self.rutina) ~= "dead" then
        coroutine.resume(self.rutina, dt)
    end
    --movimiento lateral mientras esta vivo
    if not self.muerto then
        self.x = self.x + self.dirX * self.velX * dt
        if self.x > ANCHO - self.ancho / 2 then self.x = ANCHO - self.ancho / 2; self.dirX = -1 end
        if self.x < self.ancho / 2         then self.x = self.ancho / 2;         self.dirX = 1 end
    end
    --progresion del laser
    local L = self.laser
    if L.fase == "aviso" then
        L.x = self.x
        L.t = L.t + dt
        if L.t >= 0.8 then L.fase = "activo"; L.t = 0 end
    elseif L.fase == "activo" then
        L.t = L.t + dt
        if L.t >= 0.5 then L.fase = "off"; L.t = 0 end
    end
end
--renderizado
function Jefe:Dibujar()
    --laser recto
    local L = self.laser
    if L.fase == "aviso" then
        local a = 0.3 + 0.25 * math.sin(love.timer.getTime() * 20)
        love.graphics.setColor(1, 0.3, 0.3, a)
        love.graphics.rectangle("fill", L.x - 4, self.y, 8, ALTO - self.y)
    elseif L.fase == "activo" then
        love.graphics.setColor(1, 0.4, 0.4, 0.9)
        love.graphics.rectangle("fill", L.x - L.ancho / 2, self.y, L.ancho, ALTO - self.y)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", L.x - L.ancho / 4, self.y, L.ancho / 2, ALTO - self.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
    --cuerpo del jefe (sprite)
    if self.destello > 0 then love.graphics.setColor(1, 0.6, 0.6, 1)
    elseif self.muerto    then love.graphics.setColor(0.4, 0.4, 0.4, 1)
    else love.graphics.setColor(1, 1, 1, 1) end
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.escala, self.escala,
                       self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)
    --nombre y barra de vida
    love.graphics.setFont(Juego.fuenteControles)
    local titulo = "GENERAL ZORN"
    if self.nivel > 1 then titulo = titulo .. "  x" .. self.nivel end
    love.graphics.printf(titulo, 0, 34, ANCHO, "center")
    local bw = 520
    local bx = (ANCHO - bw) / 2
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", bx, 58, bw, 18)
    love.graphics.setColor(0.9, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", bx, 58, bw * (self.hp / self.hpMax), 18)
    love.graphics.setColor(1, 1, 1, 1)
end