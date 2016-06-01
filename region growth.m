function region = etiqueta(imagen)
figure, imshow(imagen)
%Introduzca la semilla de manera interactiva usando el comando ginput
% Primero se muestra la imagen con el comando imagesc:
figure;
clf;
h = imagesc(imagen);
axis image
%Se obtiene un valor de la pantalla. Una entrada de puntos con el ratón
[x, y] = ginput(1);
%Se muestra un pop up de la semilla escogida
msgbox(['Semilla escogida: ' num2str(round([x,y]))]);
%Se redondea cada punto a un valor entero, ya que es preferible que los
% resultados de esta operación sean enteros, por lo que usa %la función round
% para conseguirlo.
y= round(y);
x= round(x);
sem(x,y)=imagen(x,y);
%Se solicita al usuario que introduzca un valor de rango mediante la línea de %comandos usando la función input
rango=input('Ingrese el valor del rango:')
rango= rango;
%Se inicializa una máscara que umbralice la imagen a los valores
%situados alrededor de la intensidad del punto seleccionado en un
%rango [-rango, +rango]. Para ello se suman las dos máscaras, las
%del rango inferior y las del rango superior
intens_semilla=sem(x,y);
rangoinferior = intens_semilla - rango
rangosuperior = intens_semilla + rango
msk1 = (rangoinferior<imagen);
msk2 = (rangosuperior>imagen);
msk = msk1 + msk2;
msk = (msk==2);
% Se etiqueta la máscara con bwlabel, esto convierte la imagen a
% una representación de etiquetas.
regiones = bwlabel(msk,8);
% Se crea una nueva máscara binaria de aquellos píxeles con la
% misma etiqueta que el punto seleccionado, así que para ello
% cuando coincidan los píxeles de los puntos seleccionados con los
% de la imagen, se iguala a uno.
regiones(find(imagen==intens_semilla))=1
region = imagen*0;
% Represente la imagen original superponiendo la región calculada en
% rojo. Utilice los conocimientos adquiridos en la práctica 1.
%El código siguiente permitirá indicar las diferencias que se presentan en las, %para ello se representaran las diferencias entre las imágenes gracias al uso de %diferentes gamas RGB en una y otra imagen
imagen=double(imagen);
regiones=double(regiones);
imagen = (imagen - min(imagen(:)))/(max(imagen(:))-min(imagen(:)));
regiones = (regiones - min(regiones(:)))/(max(regiones(:))-min(regiones(:)));
r = regiones; % Contorno en rojo
g = imagen;
b = imagen
rgb(:,:,1) = r;
rgb(:,:,2) = g;
rgb(:,:,3) = b;
figure
imshow(rgb)
