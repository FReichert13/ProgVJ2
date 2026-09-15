--clase enemigo
Enemigo = Class{}
Enemigos = {}
SpriteEnemigo = nil
--inicializacion
function Enemigo:init(x, y, v)
    self.x = x
    self.y = y
    self.sprite = SpriteEnemigo
    self.ancho = self.sprite:getWidth()
    self.alto  = self.sprite:getHeight()
    self.origen_x = self.ancho / 2
    self.origen_y = self.alto / 2
    self.velocidad = v
    self.angulo = 0
    self.relojDisparo = math.random(20, 40) / 10
    self.maquina = MaquinaEstado{
        entrando     = function() return EstadoEntrando(self) end,
        persiguiendo = function() return EstadoPersiguiendo(self) end,
        disparando   = function() return EstadoDisparando(self) end
    }
    self.maquina:cambiar("entrando")
end
--persigue al jugador
function Enemigo:MoverHaciaJugador(dt)
    local dx = Jugador.x - self.x
    local dy = Jugador.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 1 then
        self.x = self.x + (dx / dist) * self.velocidad * dt
        self.y = self.y + (dy / dist) * self.velocidad * dt
        self.angulo = math.atan2(dy, dx)
    end
end
--no deja salir de la pantalla
function Enemigo:Limitar()
    if self.x < self.origen_x         then self.x = self.origen_x end
    if self.x > ANCHO - self.origen_x then self.x = ANCHO - self.origen_x end
    if self.y < self.origen_y         then self.y = self.origen_y end
    if self.y > ALTO - self.origen_y  then self.y = ALTO - self.origen_y end
end
--actualiacion
function Enemigo:Actualizar(dt)
    self.maquina:actualizar(dt)
end
--renderizado
function Enemigo:Dibujar()
    love.graphics.draw(self.sprite, redondear(self.x), redondear(self.y),
                       self.angulo + math.pi / 2, 1, 1, self.origen_x, self.origen_y)
end
function Enemigo:CajaX() return self.x - self.origen_x end
function Enemigo:CajaY() return self.y - self.origen_y end
--gestor
function InicializarEnemigos()
    Enemigos = {}
    SpriteEnemigo = love.graphics.newImage("img/enemyRed3.png")
end
function GenerarOleada(cantidad, velocidad)
    for i = 1, cantidad do
        local x, y
        local lado = math.random(3)   --1 arriba, 2 izquierda, 3 derecha
        if lado == 1 then
            x = math.random(40, ANCHO - 40)
            y = -math.random(40, 200)
        elseif lado == 2 then
            x = -math.random(40, 200)
            y = math.random(40, ALTO - 40)
        else
            x = ANCHO + math.random(40, 200)
            y = math.random(40, ALTO - 40)
        end
        table.insert(Enemigos, Enemigo(x, y, velocidad))
    end
end
function SepararEnemigos()
    for i = 1, #Enemigos do
        for j = i + 1, #Enemigos do
            local a = Enemigos[i]
            local b = Enemigos[j]
            local dx = b.x - a.x
            local dy = b.y - a.y
            local dist = math.sqrt(dx * dx + dy * dy)
            local minimo = (a.origen_x + b.origen_x) * 0.9
            if dist == 0 then
                b.x = b.x + 1
            elseif dist < minimo then
                local empuje = (minimo - dist) / 2
                a.x = a.x - (dx / dist) * empuje
                a.y = a.y - (dy / dist) * empuje
                b.x = b.x + (dx / dist) * empuje
                b.y = b.y + (dy / dist) * empuje
            end
        end
    end
end
function ActualizarEnemigos(dt)
    for i = #Enemigos, 1, -1 do
        local e = Enemigos[i]
        e:Actualizar(dt)
    end
    SepararEnemigos()
end
function DibujarEnemigos()
    for _, e in ipairs(Enemigos) do
        e:Dibujar()
    end
end