clc; % Se limpia el command window.
close all;
imagen= imread('retina.tif');
imagen_t = im2double(imagen);
%Imagen con suavizado, se llama a la función para ello
imagen_s=suavizado(imagen_t);
%Se le añade ruido a la imagen original
imagen_r = imnoise(imagen_t,'gaussian',0,0.01)
%Se suaviza el ruido
imagen_s2=suavizado(imagen_r)
%Se cambia el tamaño de la matriz
imagen_t1=suavizado_tamanio(imagen_t,6);
imagen_t2=suavizado_tamanio(imagen_t,12);
%Se cambia el tamaño de la matriz con ruido
imagen_tr1=suavizado_tamanio(imagen_r,6);
imagen_tr2=suavizado_tamanio(imagen_r,12);
%Se muestran los resultados
figure
subplot (2,2,1)
imshow(imagen),title('Retina Original');
subplot (2,2,2)
imshow(imagen_s),title('Retina suavizada de tamaño 3x3');
subplot (2,2,3)
imshow(imagen_t1),title('Retina suavizada de tamaño 6x6');
subplot (2,2,4)
imshow(imagen_t2),title('Retina suavizada de tamaño 12x12');
figure
subplot (2,2,1)
imshow(imagen_r),title('Retina con ruido gaussiano');
subplot (2,2,2)
imshow(imagen_s2),title('Retina con ruido gaussiano suavizado 3x3');
subplot (2,2,3)
imshow(imagen_tr1),title('Retina con ruido gaussiano suavizado 6x6');
subplot (2,2,4)
imshow(imagen_tr2),title('Retina con ruido gaussiano suavizado 12x12');