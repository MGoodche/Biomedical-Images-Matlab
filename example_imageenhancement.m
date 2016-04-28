clc; % Se limpia el command window.
close all;
imagen= imread('retina.tif');
imagen_t= im2double(imagen);
imagen_l = laplace(imagen_t);