clc; % Se limpia el command window.
close all;
%Identificacion de células
%Carga la imagen celulas.png
celulas = imread('celulas.png');
figure, imshow(celulas),title('Imagen de microscopio');
%Ahora se selecciona la componente RGB de la imagen con el histograma más ecualizado
%Para ello se analizan todos
im_r = celulas(:,:,1)
im_g = celulas(:,:,2)
imagen = celulas(:,:,3)
figure
subplot(2,3,1)
imshow(im_r),title('Componente RGB rojo')
subplot(2,3,2)
imshow(im_g),title('Componente RGB verde')
subplot(2,3,3)
imshow(imagen),title('Componente RGB azul') %RGB elegido
subplot(2,3,4)
imhist(im_r),title('Histograma de la componente RGB rojo ');
subplot(2,3,5)
imhist(im_g),title('Histograma de la componente RGB verde');
subplot(2,3,6)
imhist(imagen),title('Histograma de la componente RGB azul'); %Histograma elegido
colormap(gray);
figure
imshow(imagen);
%Binarización de la imagen a partir de un nivel de intensidad
imagen_bin = imagen > 155;
%Rellena los agujeros de las regiones
im_aux = imfill(imagen_bin,'holes');
%------------------------------------------------------------------
%Aplique una operación morfológica que elimine las regiones más pequeñas
%(errores de la umbralización) manteniendo los bordes de las regiones
%grandes. Utilice el elemento estructurante que considere oportuno
%-----------------------------------------------------------------
se= strel('disk', 7)
im_aux = imclose(im_aux,se)
%Elimina las regiones incompletas pegadas al borde de la imagen
im_aux = imclearborder(im_aux);
figure, imshow(im_aux), title('Imagen binaria de trabajo');
%-------------------------------------------------------------------------
%Segmentación de las células de gran tamaño
%Cree un marcador mediante erosión que seleccione sólo las células de
%gran tamaño y utilicelo para realizar una reconstrucción de im_aux
se_cel_grande= strel('disk', 17)
ero_grande = imerode(im_aux,se_cel_grande);
cel_grande = imreconstruct(ero_grande,im_aux);
figure, imshow(cel_grande), title('Celulas de gran tamaño');
%------------------------------------------------------------------------
%Crea una segunda imagen auxiliar con las células de tamaño pequeño
im_aux2 = im_aux - cel_grande;
figure, imshow(im_aux2), title('Células de pequeño tamaño');
%-------------------------------------------------------------------------
%Segmentación de las células alargadas
se1 = strel('line', 40,0);
se2 = strel('line', 40,-45);
%Cree dos marcadores a partir de la erosion de im_aux2 con los elementos
%estructurantes elegidos
ero_a_0 = imerode(im_aux2,se1);
ero_a_45 = imerode(im_aux2,se2);
%Reconstruya im_aux2 a partir de los marcadores obtenidos
cel_a_0 = imreconstruct(ero_a_0,im_aux2);
cel_a_45 = imreconstruct(ero_a_45,im_aux2);
%Células pequeñas
cel_a = logical(cel_a_0 + cel_a_45);
figure, imshow(cel_a), title('Células alargadas');
%Segmentación del resto de células pequeñas
%Seleccione el resto de células restando las segmentadas anteriormente a
%la imagen de trabajo
cel_p = logical(im_aux2-cel_a);
figure, imshow(cel_p), title('Células pequeñas');
%Crea una segunda imagen auxiliar con las células de tamaño pequeño
im_aux2 = im_aux - cel_grande;
figure, imshow(im_aux2), title('Células de pequeño tamaño');
%-------------------------------------------------------------------------
%Segmentación de las células pequeñas
se1 = strel('disk', 9);
se2 = strel('disk', 10);
%Cree dos marcadores a partir de la erosion de im_aux2 con los elementos
%estructurantes elegidos
ero_a_0 = imerode(im_aux2,se1);
ero_a_45 = imerode(im_aux2,se2);
%Reconstruya im_aux2 a partir de los marcadores obtenidos
cel_a_0 = imreconstruct(ero_a_0,im_aux2);
cel_a_45 = imreconstruct(ero_a_45,im_aux2);
%Células pequeñas
cel_a = logical(cel_a_0 + cel_a_45);
figure, imshow(cel_a), title('Células pequeñas');
%Visualización de los resultados
AUX = celulas;
AUXR = AUX(:,:,1);
AUXG = AUX(:,:,2);
AUXB = AUX(:,:,3);
AUXR(cel_grande)=255;
AUXR(cel_p)=255;
AUXG(cel_a)=255;
AUXG(cel_p)=255;
im(:,:,1)=AUXR;
im(:,:,2)=AUXG;
im(:,:,3)=AUXB;
figure,imshow(im),title('Resultado final de la segmentación');
