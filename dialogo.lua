--sistema de dialogos (corrutina + maquina de escribir, patron 7.1)
local utf8 = require("utf8")
Dialogo = Class{}
local VELOCIDAD = 28 --caracteres por segundo
--textos (editables)
TextoIntro = {
    "Guardián, la flota enemiga cruzó los límites estelares.",
    "Tu nave es lo único entre ellos y la colonia.",
    "Resistí las oleadas... nuestro destino está en tus manos."
}
TextoJefe = {
    "Has derrotado a todas las oleadas enemigas, pero ahora toca vencer a su nave insignia, comandada por el malvado General Zorn. La victoria está cerca. Éxitos, guardián."
}
--recorta un texto a los primeros k caracteres (seguro con acentos/utf-8)
local function recortar(s, k)
    k = math.floor(k)
    if k <= 0 then return "" end
    local total = utf8.len(s)
    if k >= total then return s end
    local b = utf8.offset(s, k + 1)
    return string.sub(s, 1, b - 1)
end
--inicializacion
function Dialogo:init(lineas, alTerminar)
    self.lineas = lineas
    self.alTerminar = alTerminar
    self.textoActual = ""
    self.mostrados = 0
    self.esperandoEnter = false
    self.saltar = false
    self.terminado = false
    self.tiempo = 0
    self.rutina = coroutine.create(function() self:correr() end)
end
--libreto: por cada linea revela letra por letra y espera Enter
function Dialogo:correr()
    for _, linea in ipairs(self.lineas) do
        self.textoActual = linea
        self.mostrados = 0
        local largo = utf8.len(linea)
        while self.mostrados < largo do
            local dt = coroutine.yield()
            if self.saltar then
                self.mostrados = largo
                self.saltar = false
            else
                self.mostrados = math.min(largo, self.mostrados + VELOCIDAD * dt)
            end
        end
        self.esperandoEnter = true
        while self.esperandoEnter do
            coroutine.yield()
        end
    end
    self.terminado = true
end
--actualizacion
function Dialogo:Actualizar(dt)
    self.tiempo = self.tiempo + dt
    if coroutine.status(self.rutina) ~= "dead" then
        coroutine.resume(self.rutina, dt)
    end
    if self.terminado and self.alTerminar then
        local cb = self.alTerminar
        self.alTerminar = nil
        cb()
    end
end
--entrada: Enter avanza o completa la linea de una
function Dialogo:Teclado(key)
    if key == "return" then
        if self.esperandoEnter then
            self.esperandoEnter = false
        else
            self.saltar = true
        end
    end
end
--renderizado (caja de dialogo)
function Dialogo:Dibujar()
    local x1, y1 = 70, ALTO * 0.38
    local w, h = ANCHO - 140, ALTO * 0.24
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", x1, y1, w, h, 10, 10)
    love.graphics.setColor(0.5, 0.7, 1, 1)
    love.graphics.rectangle("line", x1, y1, w, h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Juego.fuenteMenu)
    love.graphics.printf(recortar(self.textoActual, self.mostrados), x1 + 30, y1 + 30, w - 60, "left")
    if self.esperandoEnter and math.floor(self.tiempo * 2) % 2 == 0 then
        love.graphics.setFont(Juego.fuenteControles)
        love.graphics.printf("Enter >", x1, y1 + h - 30, w - 20, "right")
    end
    love.graphics.setColor(1, 1, 1, 1)
end