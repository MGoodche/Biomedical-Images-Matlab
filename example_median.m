clc; % Se limpia el command window.
close all;
imagen= imread('retina.tif');
imagen_t = im2double(imagen);
%Se añade ruido gaussiano y sal-pimienta a la imagen original
imagen_r = imnoise(imagen_t,'gaussian',0,0.01)
imagen_r2 = imnoise(imagen_t,'salt & pepper',0.05) %Por defecto es 0.05
% Se utiliza la función medfilt2 para el suavizado y eliminación de ruido
fmediana1 = medfilt2(imagen_t);
fmediana2 = medfilt2(imagen_r);
fmediana3 = medfilt2(imagen_r2);
%Se representan las imágenes
figure
subplot (2,3,1)
imshow(imagen_t),title('Retina original');
subplot (2,3,2)
imshow(imagen_r),title('Retina con ruido Gausiano');
subplot (2,3,3)
imshow(imagen_r2),title('Retina con ruido Sal y Pimienta');
subplot (2,3,4)
imshow(fmediana1),title('Retina con Filtro Mediana');
subplot (2,3,5)
imshow(fmediana2),title('Retina Ruido Gausiano Filtro Mediana');
subplot (2,3,6)
imshow(fmediana3),title('Retina Ruido Sal y Pimienta con Filtro Mediana');