imagen= imread('micro2.tif');
se1= strel('square',3);
nhood= [1 0 0 0 1];
se2= strel('arbitrary',nhood);
se3= strel(strel('rectangle', [5,5]));
%Apertura
imagen_open1=imopen(imagen,se1);
imagen_erosion1=imerode(imagen,se1);
imagen_dilatada1=imdilate(imagen,se1);
imagen_final1=imagen_erosion1+imagen_dilatada1;
imagen_open2=imopen(imagen,se2);
imagen_erosion2=imerode(imagen,se2);
imagen_dilatada2=imdilate(imagen,se2);
imagen_final2=imagen_erosion2+imagen_dilatada2;
imagen_open3=imopen(imagen,se3);
imagen_erosion3=imerode(imagen,se3);
imagen_dilatada3=imdilate(imagen,se3);
imagen_final3=imagen_erosion3+imagen_dilatada3;
%Cierre
imagencierre1=imclose(imagen,se1);
imagen_cierre1=imagen_dilatada1+imagen_erosion1;
imagencierre2=imclose(imagen,se2);
imagen_cierre2=imagen_dilatada2+imagen_erosion2;
imagencierre3=imclose(imagen,se3);
imagen_cierre3=imagen_dilatada3+imagen_erosion3;
%Representación
figure
subplot(2,3,1)
imshow(imagen), title ('Original');
subplot(2,3,2)
imshow(imagen_open1), title ('Apertura SE1');
subplot(2,3,3)
imshow(imagencierre1), title ('Cierre SE1');
subplot(2,3,4)
imshow(imagen_final1), title ('Erosion y dilatación SE1');
subplot(2,3,5)
imshow(imagen_cierre1), title ('Dilatación y erosión SE1');
figure
subplot(2,3,1)
imshow(imagen), title ('Original');
subplot(2,3,2)
imshow(imagen_open2), title ('Apertura SE2');
subplot(2,3,3)
imshow(imagencierre2), title ('Cierre SE2');
subplot(2,3,4)
imshow(imagen_final2), title ('Erosion y dilatación SE2');
subplot(2,3,5)
imshow(imagen_cierre2), title ('Dilatación y erosión SE2');
figure
subplot(2,3,1)
imshow(imagen), title ('Original');
subplot(2,3,2)
imshow(imagen_open3), title ('Apertura SE3');
subplot(2,3,3)
imshow(imagencierre3), title ('Cierre SE3');
subplot(2,3,4)
imshow(imagen_final3), title ('Erosion y dilatación SE3');
subplot(2,3,5)
imshow(imagen_cierre3), title ('Dilatación y erosión SE3');
