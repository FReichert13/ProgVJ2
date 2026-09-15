--tipos de enemigo (heredan de Enemigo)
--rapido: mas veloz, dispara menos
EnemigoRapido = Class{ __includes = Enemigo }
function EnemigoRapido:init(x, y, v)
    Enemigo.init(self, x, y, v * 1.6)
    self.color = {0.4, 0.8, 1}
    self.relojMin = 35
    self.relojMax = 55
    self.relojDisparo = math.random(self.relojMin, self.relojMax) / 10
end
--artillero: mas lento, dispara seguido
EnemigoArtillero = Class{ __includes = Enemigo }
function EnemigoArtillero:init(x, y, v)
    Enemigo.init(self, x, y, v * 0.7)
    self.color = {1, 0.6, 0.2}
    self.relojMin = 12
    self.relojMax = 25
    self.relojDisparo = math.random(self.relojMin, self.relojMax) / 10
end