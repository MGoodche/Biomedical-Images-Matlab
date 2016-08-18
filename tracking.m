%% Paso 1: Carga del vídeo y creación del vídeo de salida

% El objetivo de esta fase es cargar en el programa el vídeo a procesar y
% crear una estructura de vídeo en Matlab para el vídeo de salida

% Carga del vídeo a utilizar y almacenamiento de parámetros de interés
% (número de frames, tasa de frame y tamaño del frame)

clear all;
clear avi;
close all;

video      = VideoReader('3_prension_Vid1_x264.avi');

% EXPLICACIÓN:
% Se crea un nuevo objeto de la clase VideoReader utilizando la ruta del archivo de vídeo.

% 1.2 Carga en las siguientes variables los siguientes parámetros del
% vídeo: número de frames, tasa de frame, ancho y alto del frame

numFrames  = video.NumberOfFrames;  % numero de frames
fps        = video.FrameRate;       % tasa de frames
width      = video.Width;           % ancho del frame
height     = video.Height;          % alto del frame

% CREACCION DE VIDEO
movie = avifile('videoTracking.avi', 'fps', 10, 'compression', 'none'); % Creamos un video con 10 frames por segundo y sin compresión
       
%% Paso 2: Procesamiento de cada frame de vídeo

% En este paso se recorren todos los frames del vídeo para su
% procesamiento. De cara a aligerar los tiempos de procesado, vamos a
% procesar un frame cada dos segundos de vídeo. Así mismo, se incluye en el
% bucle una estructura try-catch que nos permita capturar cualquier
% excepción no controlada de un procesamiento erroneo de frame.

for k = 1:2*floor(fps):numFrames
    try
        
        % Carga del frame actual
        currentFrame = read(video, k); 
        % Comenta esta línea si quieres ver qué frame se está procesando
        disp(['Procesando el frame ', num2str(k)]);
        

        %% 2.1 Preprocesamiento de la imagen

        % 2.1.1 Realiza un filtrado gaussiano del frame que permita suavizar
        % la imagen. Se recomienda usar un tamaño de filtro de 7x7 y un
        % valor de sigma de 1.5
        
        h               = fspecial('gaussian',7, 1.5);
        filteredImage   = imfilter(currentFrame,h,'conv','same');
        
        % EXPLICACIÓN:

        % fspecial('gaussian', tamaño, sigma) devuelve un filtro simetrico 
        % Gaussiano del tamaño especificado con la desviacion tipica indicada
        % en sigma. Luego se ha empleado la funcionimfilter que sirve oara
        % aplicacion de filtros locales con mascaras
        
        % 2.1.2 Para realizar una segmentación en color, vamos a trabajar en
        % un espacio de color HSV, que nos va a permitir separar nuestra
        % imagen en 3 canales atendiendo a matiz, saturación y valor.
        % Transforma la imagen resultado de 2.1 a este espacio de color.
        
        hsvImage        = rgb2hsv(currentFrame);
        
        % EXPLICACIÓN:
        % rgb2hsv convierte una imagen RGB en una imagen HSV

        % 2.1.3 De cara a mejorar el proceso de segmentación, vamos a llevar a
        % cabo una ecualización simple del histograma de la imagen. Usa la
        % función imadjust por defecto para ello. Recuerda que tendrás que
        % aplicarla para cada canal de la imagen HSV.
   
        hsvImageAdjust(:,:,1)  = imadjust(hsvImage(:,:,1));
        hsvImageAdjust(:,:,2)  = imadjust(hsvImage(:,:,2));
        hsvImageAdjust(:,:,3)  = imadjust(hsvImage(:,:,3));
        

        %% 2.2 Detección de marcador
        % En esta fase vamos a segmentar el marcador verde colocado sobre
        % la herramienta laparoscópica. A partir de la detección de la
        % región del marcador, vamos a realizar un seguimiento de su punto
        % centroide.
        
        % 2.2.1 De cara a segmentar el marcador, construye 3 máscaras (una
        % por canal) cuya composición sea una imagen binaria en la que en
        % blanco se destaque el marcador.

        greenMarkerH = double(hsvImageAdjust(:,:,1));
        greenMarkerS = double(hsvImageAdjust(:,:,2));
        greenMarkerV = double(hsvImageAdjust(:,:,3));

        greenMarkerH    = greenMarkerH > 0.2 & greenMarkerH < 0.35 ;
        greenMarkerS    = greenMarkerS > 0.45 ;
        greenMarkerV    = greenMarkerV > 0.35 ;
 
        greenMarker     = greenMarkerH & greenMarkerS & greenMarkerV; 
       
        % EXPLICACIÓN:
        % Los valores que se han escogido teniendo en cuenta las tonalidades en las que trabaja el verde en RGB 
        % y convirtiéndolas al formato HSV. Se ha conseguido detectar el marcador construyendo tres máscaras donde
        % se destaca el marcador, teniendo en cuenta los valores HSV en los que trabaja el verde.
        
        % 2.2.2 De cara a eliminar pequeños huecos que puedan aparecer en
        % la máscara, vamos a hacer un cierre de la imagen. Además,
        % vamos a primar la dilatación de la misma de forma que en frames
        % donde aunque el marcador no se aprecie del todo bien (p.ej: frames en
        % sombra) se pueda detectar correctamente la región
        
        se_e            = strel('line',5,90);
        se_d            = imclose(greenMarker, se_e);
        greenMarker     = imclearborder (se_d); %para limpiar el ruido de los bordes del frame  
        
        % EXPLICACIÓN:
        % Se utiliza el elemento estructural con line, variando el tamaño en primer lugar y los grados en segundo:
        % Así que se ha seleccionado un tamaño de cinco y una orientación 90º, de esta manera se consigue obtener
        % el objeto correspondiente al marcador.
        % Luego se ha realizado un cierre de la imagen con imclose y se han limpiado los bordes del frame con 
        % imclearborder. Con estas dos técnicas, se consiguen alisar porciones de contornos, fusionar grietas 
        % estrechas, rellenar vacíos y agujeros pequeños, eliminar entrantes pequeños y conectar objetos vecinos.


        %% 2.3 Detección de punto de tracking
        
        % Una vez segmentado el marcador, la siguiente tarea será detectar
        % el punto sobre el cuál realizaremos el tracking. Para ello, vamos
        % a usar el centroide del marcador (momento de primer orden). 
        % Además, vamos a utilizar el momento de segundo orden para estimar
        % la orientación de la herramienta.
        
        % Para llevar a cabo esta sección vamos a definir una región a
        % partir del marcador, sobre la que extraeremos las propiedades
        % deseadas. Consulta la ayuda de matlab sobre como obtener
        % propiedades a partir de regiones creadas con la función bwlabel

        % 2.3.1 Obtención de regiones en la imagen máscara
      
        L   = bwlabel(greenMarker, 8); 
        
        % EXPLICACIÓN:
        % Devuelve una matriz L del mismo tamaño que greenMarker, conteniendo etiquetas conectadas a los objetos 
        % de greenMarker. Se puede realizar una vencindad a cuatro o a ocho.Por defecto Matlab pone ocho. Los 
        % píxeles etiquetados como cero son el fondo, los etiquetados como 1 son el primer objeto...y así. La 
        % imagen greenMarker es un array logical, ya que no puede tener ninguna dimensión.
        
        % 2.3.2 Obtención de propiedades de L
        S   = regionprops(L,'Orientation', 'Centroid', 'Area');
        
        % EXPLICACIÓN:
        % La función 'regionprops' mide el conjunto de propiedad de cada componente conectado en la imagen binaria
        % Gracias a  Using ‘bwlabel’ y ‘regionprops’, el centroide del marcador puede ser encontrado en todos los 
        % frames del vídeo.
        
        % 2.3.3 En ocasiones, según la calidad de la segmentación de la máscara,
        % bwlabel identificará varias regiones de pequeño tamaño que pueden
        % llevar a la aparición de errores en la detección del punto de
        % tracking. Opcionalmente, diseña un código que elimine las
        % regiones menores de la imagen antes de calcular el centroide y
        % orientación del marcador
        
        numeroRegiones = size(S);    % obtenemos 2 paremetros el primero es el numero de regiones y el segundo siempre es 1
        numeroRegiones = numeroRegiones(1);
        
        % comprobamos si hay mas de una region, si no es el caso no tiene
        % sentido eliminar nada
        if numeroRegiones > 1
            areaMaxima = max([S.Area]);  % Obtenemos el area de la region mas grande
            for i = 1:numeroRegiones
                if S(i).Area < areaMaxima
                       L1 = L ~= i & L ~= 0;     % creamos una matriz que tiene a 1 los elementos distintos del area encontrada y a 0 el fondo y el area encontrada
                       L = L.* L1;               % realizamos una operacion elemento a elemento de la matriz y solo dejamos el area maxima
                end
            end
        end

        % volvemos a calcular las propiedades de L puesto que ahora ya solo
        % hay una region
        % 2.3.2 Obtención de propiedades de L
        if (numeroRegiones ~= 0)    % comprobamos que hay alguna region, en caso contario no tiene sentido nada mas
            L   = bwlabel(L, 8);
            S   = regionprops(L,'Orientation', 'Centroid', 'Area');

            % 2.3.4 Finalmente, obten el punto P (centroide) y la orientación del
            % marcador. Asegúrate de que el punto P obtenido
            % es un número entero.

            P   = round(cat(1,S.Centroid));
            Or  = S.Orientation;

            % EXPLICACIÓN:
            % Se computan todos los centroides de las regiones etiquetadas y entonces se superponen sobre la imagen
            % Se ha utilizado el comando 'round' para asegurarse de que que el punto P es un número entero. Se ha 
            % empleado el comando 'cat' para concatener el array estructural conteniendo los centroides en una 
            % matriz individual

            %% 2.4 Detección de bordes de la imagen

            % En esta fase vamos a realizar la segmentación del vástago del
            % instrumental (parte negra), de cara a detectar robustamente los
            % bordes del mismo

            % 2.4.1 De cara a segmentar el vástago, construye una máscara en
            % el canal V de hsvImageAdjust

            blackShaft    = double(hsvImageAdjust(:,:,3));
            blackShaft    = blackShaft < 0.15;                 % solo ultilizamos el valor (V) puesto que si este es 0 o cercano
                                                                % da igual que tengamos en matiz o saturacion, puesto que siempre sera negro

            % 2.4.2 De cara a ajustar bien los bordes, vamos a hacer una apertura de la imagen. 

            se_e          = strel('diamond',5);
            se_d          = imdilate (blackShaft,se_e); 
            blackShaft    = imopen (se_d,se_e);
            se_e2         = strel('disk',10);
            blackShaft    = imopen (blackShaft,se_e2);

            % EXPLICACIÓN:
            % Primero se utiliza un la función strel para crear un elemento estructurante en forma de diamante de 
            % tamaño cinco. Luego se emplea imdilate ya que se quiere añadir puntos a un objeto en los pixeles que
            % tocan el borde en las imágenes utilizadas, aumentando la definición de la imagen. Así se consigue 
            % tener más definición en el vástago instrumental. Luego se hace una apertura de la imagen. Por último 
            % se usa otro elemento estructurante en forma de disco, para eliminar las partes de la imagen que no 
            % corresponden al vástago instrumental. 

            % 2.4.3 Finalmente, ajusta un filtro de Canny que permita obtener
            % los bordes de la imagen, de forma que se maximize la información
            % de los bordes de la herramienta y se minimicen el resto. Use la
            % función edge pare ello.

            imgThresh     = edge(blackShaft,'Canny');  

            %% 2.5 Caracterización de bordes (Transformada de Hough)

            % La transformación de Hough permite detectar y caracterizar rectas
            % en una imagen. En el espacio de la imagen, la recta se puede representar 
            % con la ecuación y=m?x+n y se puede graficar para cada par (x,y) 
            % de la imagen. En la transformada de Hough, la idea principal es 
            % considerar las características de una recta en término de sus parámetros
            % (m,n), y no como puntos de la imagen (x1,y1),...,(xn,yn). 
            % Basándose en lo anterior, la recta y=m?x+n se puede representar
            % como un punto (m,n) en el espacio de parámetros. Sin embargo, 
            % cuando se tienen rectas verticales, los parámetros de la recta (m,n) 
            % se indefinen. Por esta razón es mejor usar los parámetros que 
            % describen una recta en coordenada polares, denotados (?,?).

            % Para comprender mejor el funcionamiento de la transformada,
            % consulta la ayuda de Matlab.

            % 2.5.1 La función hough de matlab permite calcular la transformada
            % de Hough en matlab. En nuestro caso, los argumentos de entrada
            % serán nuestra imagen de bordes, la resolución de rho ( = 0.5) y
            % una ventana de búsqueda de rectas delimitada por la orientación
            % (theta) de las mismas. Para filtrar las rectas de la imagen y
            % quedarnos sólo con las del instrumental, definiremos esa ventana
            % en un entorno de -20 a 20 grados de la orientación Or definida a
            % partir del márcador. A la hora de definir la ventana, ten en
            % cuenta los casos en los que la orientación del marcador sea menor
            % que 20 grados o mayor que 70 grados.

            Theta_window1 = Or -20:0.5:Or+20;
            Theta_window2 = Or<20: 0.5: Or>70;
            Theta_window  = [Theta_window1 Theta_window2]; 

            % EXPLICACIÓN:
            % Se seleccionan los ángulos correspondientes a un entorno de -20 a  20 grados de la orientación Or. 
            % Y también se seleccionan los casos en los que la orientación del marcador sea menor que 20 grados 
            % o mayor que 70 grados. Todo ello se encuentra en Theta_window.

            % Cálculo de la transformada (ya completada)

            [H,theta,rho]  =  hough(imgThresh,'RhoResolution',0.5,'Theta', Theta_window);
            
            % EXPLICACIÓN:
            % Se realiza la transformada de Hough de la imagen binaria imgThresh, theta (en grados) y rho son 
            % arrays de los valores de rho y theta calculados a partir de la matriz H

            % 2.5.2 Para protegernos frente a imágenes ruidosas, vamos a
            % calcular el doble de picos en la imagen transformada que rectas
            % buscadas en la imagen original con la función houghpeaks.
            % Posteriormente, la función houghlines nos devolverá un vector de
            % rectas. Cada recta se construye como una estructura con distintos
            % campos asociados a esa recta. Familiarizate con ellos usando la
            % ayuda de Matlab.
            % Utiliza las funciones houghpeaks y houghlines para obtener los
            % cuatro picos de mayor intensidad de la imagen y sus rectas
            % asociadas respectivamente. 

            peaks = houghpeaks(H,4,'Threshold',0.1*max(H(:)));
            lines = houghlines(imgThresh, theta, rho, peaks,'FillGap',50,'MinLength',5);

            % EXPLICACIÓN:
            % En houghpeaks se ha seleccionado el valor de 4, ya que el enunciado te recomienda usar cuatro picos 
            % de intensidad. Y se ha seleccionado un valor de umbral de 0.1*max(H) debido a que con valores mayores 
            % se detectan líneas no deseadas.

            % Asumiendo que nuestra imagen de bordes está bien segmentada,
            % vamos a tomar como primer borde de la imagen la primera recta
            % obtenida.

            filteredLines = lines(1);        

            % 2.5.3 Para la segmentación de la segunda recta, diseña un algoritmo que
            % recorra todas las rectas restantes y compruebe 1) que la recta no
            % está vacía (por ejemplo, comprobando si existe algún valor en el
            % campo rho); 2) que la distancia entre cada recta y la primera,
            % entendida como la distancia entre sus rho y sus theta, es mayor
            % que 5. Usa la función pdist2 para ello.

            index = 0;     
            for i = 2:length(lines)
                max_len1=0;
                index = 0;
                if  (lines(i).rho ~= 0) && (lines(i).theta ~= 0)   % si rho y theta son distintos de cero comprobamos
                    if  (pdist2(lines(1).rho,lines(i).rho) + pdist2(lines(1).theta,lines(i).theta) > 5) 
                        len = pdist2(lines(i).point1, lines(i).point2); % calculo de la distancia entre los dos puntos, 
                                                                        % suponemos que contra mas larga sea una recta mas se aproximara
                                                                        % a la recta que buscamos
                        if (len > max_len1)
                            if (comprobarAmbosLadosPunto(lines(1),lines(i),P) == 1) % comprobamos que ambas lineas estan en lados distintos del vastago
                                max_len1 = len;                                     % utilizando para ello como referencia el punto P (centroide del vastago)
                                index = i;
                            end
                        end
                    end
                end
            end

            if not(isempty(filteredLines)) & index ~= 0 % si hemos encontrado una linea la añadimos
                filteredLines(end + 1) = lines(index);
            else
                if not(isempty(filteredLines))  % si no encontramos una linea pero ya teniamos uno, añadimos la siguiente que sera una aproximacion
                    filteredLines(end + 1) = lines(2);
                end
            end

            %% 2.6 Caracterización de bordes (Transformada de Hough)

            % 2.6.1 Llama a la función buildFrameTF (proporcionada en el
            % ejercicio) para representar tanto los bordes como el punto P del
            % instrumental
            if (length(filteredLines)>1) 
                [currentFrame,x_r,y_r1,y_r2]  = buildFrameTF(filteredLines(1),filteredLines(2),P,filteredImage);  
            end
            
            % añadimos un frame al video
            frame = getframe(gcf);  % capturamos la imagen mostrada como frame para el video
            movie = addframe(movie, frame);             % añadimos el frame al video
            
            % Almacenamos el valor de P en un vector de puntos
            pos2D(floor(k/(2*floor(fps)))+1,:) = P;
            
            
        end
        
    catch ME
        disp(ME);
    end
end


%% Paso 3: Representación de resultados y guardado de vídeo final

% 3.1 En este paso se va a representar la trayectoria del punto característico
% seguido, y se va a guardar el resultado final. Dibuje la trayectoria
% seguida en la figura 2. Use los siguientes ajustes de representación: '--gs',
% 'MarkerEdgeColor','g''MarkerFaceColor','g','MarkerSize',5

% Detectamos el índice de los puntos no detectados (valor (0,0)). Estos
% índices deben servir posteriormente para no representar estos puntos.

aux = not((pos2D(:,1) == 0) & (pos2D(:,2) == 0));

figure(2);title('Trayectoria del instrumental'); grid on; hold on; axis ij;
xlabel('x');ylabel('y');axis([0, width, 0, height]);
for j = 1:length(pos2D)
   if (aux(j) ~= 0)
       plot(pos2D(j,1),pos2D(j,2),'--gs','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',5)
   end
end 
hold off
save position.mat pos2D;

% cerramos la creaccion del video
movie = close(movie);
