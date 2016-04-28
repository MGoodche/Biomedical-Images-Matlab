function imagen_suavizado = suavizado(imagen)
kernel = ones(3, 3) / 9; % matriz average 3x3
imagen_suavizado = conv2(imagen, kernel, 'same');
end