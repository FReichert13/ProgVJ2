--utiles
function redondear(n)
    return math.floor(n + 0.5)
end
--colision aabb entre dos rectangulos
function hayColision(x1, y1, ancho1, alto1, x2, y2, ancho2, alto2)
    return  x1 < x2 + ancho2 and
            x2 < x1 + ancho1 and
            y1 < y2 + alto2  and
            y2 < y1 + alto1
end
