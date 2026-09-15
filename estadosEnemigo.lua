--estados del enemigo
--entra desde afuera hasta meterse en la pantalla
EstadoEntrando = Class{ __includes = Estado }
function EstadoEntrando:init(enemigo)
    self.enemigo = enemigo
end
function EstadoEntrando:actualizar(dt)
    local e = self.enemigo
    e:MoverHaciaJugador(dt)
    if e.x >= e.origen_x and e.x <= ANCHO - e.origen_x and
       e.y >= e.origen_y and e.y <= ALTO - e.origen_y then
        e.maquina:cambiar("persiguiendo")
    end
end
--persigue al jugador hasta que le toca disparar
EstadoPersiguiendo = Class{ __includes = Estado }
function EstadoPersiguiendo:init(enemigo)
    self.enemigo = enemigo
end
function EstadoPersiguiendo:actualizar(dt)
    local e = self.enemigo
    e:MoverHaciaJugador(dt)
    e:Limitar()
    e.relojDisparo = e.relojDisparo - dt
    if e.relojDisparo <= 0 then
        e.maquina:cambiar("disparando")
    end
end
--lanza una bala apuntando al jugador y vuelve a perseguir
EstadoDisparando = Class{ __includes = Estado }
function EstadoDisparando:init(enemigo)
    self.enemigo = enemigo
end
function EstadoDisparando:ingresar()
    local e = self.enemigo
    local ang = math.atan2(Jugador.y - e.y, Jugador.x - e.x)
    LanzarBalaEnemiga(e.x, e.y, ang)
    e.relojDisparo = math.random(25, 45) / 10
    self.tiempo = 0.2
end
function EstadoDisparando:actualizar(dt)
    local e = self.enemigo
    e:MoverHaciaJugador(dt)
    e:Limitar()
    self.tiempo = self.tiempo - dt
    if self.tiempo <= 0 then
        e.maquina:cambiar("persiguiendo")
    end
end