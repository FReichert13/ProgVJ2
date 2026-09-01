--declaracion
Fondo = {
    imagen = nil,
    y = 0,
    vel = 120
}
--inicializacion
function InicializarFondo()
    Fondo.imagen = love.graphics.newImage("img/black.png")
end
--actualiacion
function ActualizarFondo(dt)
    Fondo.y = (Fondo.y + Fondo.vel * dt) % Fondo.imagen:getHeight()
end
--renderizado
function DibujarFondo()
    local img = Fondo.imagen
    local ancho = img:getWidth()
    local alto  = img:getHeight()
    for ix = 0, ANCHO, ancho do
        for iy = -alto, ALTO, alto do
            love.graphics.draw(img, ix, iy + Fondo.y)
        end
    end
end
