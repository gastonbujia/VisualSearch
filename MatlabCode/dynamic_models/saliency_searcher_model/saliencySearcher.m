function searchInfo = saliencySearcher(saliencyMap, targetInfo, delta, mode, verbose)
    
    % TODO: Agregar la distancia minima como parametro de la busqueda
    % TODO: Agregar que el modelo utilizado de saliencia sea un
    % parametro(*)
    % TODO: Referenciar las sacadas a la imagen y no a la grilla
    % TODO: Lo anterior para el IOR

    [Row, Col]   = size(saliencyMap);
    S            = reduceMatrix(saliencyMap, delta, mode);
    [Nrow, Ncol] = size(S);
    searchMatrix = zeros(Nrow,Ncol);
    notFound     = true;
    Nfix         = 1;
    % indices de la matriz reducida
    currentFix   = [0 0];
    % inicializo el struct de salida
    searchInfo.scanpath  = zeros(Nrow * Ncol,2);
    searchInfo.found     = false;
    searchInfo.nfix      = 0;
    searchInfo.rsaliency = S;
    % ordenamos la matriz S
    [saliencyValue, saliencyIndex]  = sort(S(:), 'descend');
    [I, J]                          = ind2sub(size(S), saliencyIndex);
    template                        = templateMaskReduce(targetInfo, Col, Row, delta);
    % harcodeado
    minDist = zeros(Nrow*Ncol);
    minDist(2) = 3;
    minDist(3) = 2;
    minDist(4) = 1;
    while notFound
        
        % sacada + fijacion
        [nextFixLocation, searchMatrix] = getNextFix(Nfix, currentFix, saliencyValue, I, J, searchMatrix, minDist);
        currentFix = nextFixLocation;
        searchInfo.scanpath(Nfix,:) = currentFix;
        Nfix = Nfix + 1;
        if verbose==1
            fprintf('Nfix: ')
            disp(Nfix)
            fprintf('CurrentFix: ')
            disp(currentFix)
        end
        % fixLocation es una tupla que contiene los indices (i,j) de donde
        % esta mirando
        % currentFix tiene la posicion de la ultima sacada en indices de la
        % matriz reducida
        
        % chequeo si lo encontre
        if template(currentFix(1),currentFix(2)) 
            notFound = false;
            % hasta aca fix location solo devuelve la posicion en la matriz
            % reducida, tendria que generarme la ubicacion para mostrar en
            % la imagen original haciendo la transformacion de coordenas
            searchInfo.nfix = Nfix - 1;
            searchInfo.fixposx = currentFix(1);
            searchInfo.fixposy = currentFix(2);
        end       
    end
    searchInfo.template = template;
    searchInfo.found = not(notFound);
end

function [nextFixLocation, searchMatrix] = getNextFix(Nfix, currentFix, saliencyValue, I, J, searchMatrix, minDistance)
    % recorrer saliencyValue
    % minDistance pensado como 0, 2, 1, 1, 0 ...
    ind = 1;
    escapeCond = true;
    while (ind < numel(saliencyValue)) && escapeCond
        i = I(ind);
        j = J(ind);
        % si todavia no lo visite
        if not(searchMatrix(i,j))
            % las condiciones las dividi en dos solo para que no me
            % molesten
            % keyboard
            if (max(abs(currentFix-[i,j])) >= minDistance(Nfix))
                % marco que lo estoy visitando y salgo
                % disp(Nfix);
                % keyboard
                searchMatrix(i,j) = 1;
                escapeCond = false;
                nextFixLocation = [i j];
            else
                ind = ind + 1;
            end
        else
            % si no cumple con la condicion de no haberlo visitado y de
            % tener una distancia minima, sigo recorriendo la imagen
            ind = ind + 1;
            %disp(ind)
        end
    end
end