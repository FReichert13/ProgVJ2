--clase obstaculo
--meteoros y planetas que descienden
Obstaculo = {}
Obstaculo.__index = Obstaculo
Obstaculos = {}
SpritesMeteoroChico = {}
SpritesMeteoroGrande = {}
SpritesPlaneta = {}
TiempoMeteoro = 0
TiempoPlaneta = 0
--inicializacion
function Obstaculo:Nuevo(sprite, x, y, escala, vel, giro, danio, factorCaja, destruible)
    local o = setmetatable({}, Obstaculo)
    o.sprite = sprite
    o.escala = escala
    o.origen_x = sprite:getWidth() / 2
    o.origen_y = sprite:getHeight() / 2
    o.ancho = sprite:getWidth() * escala
    o.alto  = sprite:getHeight() * escala
    o.x = x
    o.y = y
    o.vel = vel
    o.angulo = math.random() * math.pi * 2
    o.giro = giro
    o.danio = danio
    o.factorCaja = factorCaja
    o.tipo = "meteoro"
    o.destruible = destruible
    return o
end
--actualizar
function Obstaculo:Actualizar(dt)
    self.y = self.y + self.vel * dt
    self.angulo = self.angulo + self.giro * dt
end
--renderizado
function Obstaculo:Dibujar()
    love.graphics.draw(self.sprite, redondear(self.x), redondear(self.y),
                       self.angulo, self.escala, self.escala, self.origen_x, self.origen_y)
end
function Obstaculo:CajaAncho() return self.ancho * self.factorCaja end
function Obstaculo:CajaAlto()  return self.alto  * self.factorCaja end
function Obstaculo:CajaX() return self.x - self:CajaAncho() / 2 end
function Obstaculo:CajaY() return self.y - self:CajaAlto()  / 2 end
--gestor
function InicializarObstaculos()
    Obstaculos = {}
    TiempoMeteoro = 0
    TiempoPlaneta = 0
    SpritesMeteoroChico = {
        love.graphics.newImage("img/meteorGrey_small1.png"),
        love.graphics.newImage("img/meteorGrey_small2.png"),
        love.graphics.newImage("img/meteorBrown_small2.png")
    }
    SpritesMeteoroGrande = {
        love.graphics.newImage("img/meteorGrey_big2.png"),
        love.graphics.newImage("img/meteorBrown_big1.png")
    }
    SpritesPlaneta = {
        love.graphics.newImage("img/planet03.png"),
        love.graphics.newImage("img/planet05.png"),
        love.graphics.newImage("img/planet08.png")
    }
end
function GenerarMeteoro()
    local x = math.random(40, ANCHO - 40)
    local giro = (math.random() - 0.5) * 3
    if math.random() < 0.5 then
        local sp = SpritesMeteoroChico[math.random(#SpritesMeteoroChico)]
        local vel = math.random(140, 240)
        table.insert(Obstaculos, Obstaculo:Nuevo(sp, x, -60, 1, vel, giro, 8, 0.8, true))
    else
        local sp = SpritesMeteoroGrande[math.random(#SpritesMeteoroGrande)]
        local vel = math.random(100, 180)
        table.insert(Obstaculos, Obstaculo:Nuevo(sp, x, -80, 1, vel, giro, 10, 0.8, false))
    end
end
function GenerarPlaneta()
    local sp = SpritesPlaneta[math.random(#SpritesPlaneta)]
    local esc = math.random(26, 38) / 100
    local mitad = sp:getWidth() * esc / 2
    local x = math.random(math.floor(mitad), math.floor(ANCHO - mitad))
    local vel = math.random(45, 75)
    local planeta = Obstaculo:Nuevo(sp, x, -mitad - 20, esc, vel, 0.15, 20, 0.6, false)
    planeta.tipo = "planeta"
    table.insert(Obstaculos, planeta)
end
function ActualizarObstaculos(dt)
    TiempoMeteoro = TiempoMeteoro + dt
    if TiempoMeteoro >= 1.8 then TiempoMeteoro = 0; GenerarMeteoro() end
    TiempoPlaneta = TiempoPlaneta + dt
    if TiempoPlaneta >= 28 then TiempoPlaneta = 0; GenerarPlaneta() end
    for i = #Obstaculos, 1, -1 do
        local o = Obstaculos[i]
        o:Actualizar(dt)
        if o.y - o.alto / 2 > ALTO + 60 then
            table.remove(Obstaculos, i)
        end
    end
end
function DibujarObstaculos()
    for _, o in ipairs(Obstaculos) do
        o:Dibujar()
    end
end
