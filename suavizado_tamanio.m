function imagen_suavizado = suavizado_tamanio(imagen, tamanio)
filtro= fspecial('average', tamanio);
imagen_suavizado = convn(imagen,filtro,'same');
end