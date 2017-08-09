function AutoImageCrop
    %Set Parameters
    CENTRE_DETECT_WINDOW = [4500 4500 2000 2000]; %Make centre detecting faster
    AXIAL_LENGTH = 24.68; %The unit is milimeter
    CROPPED_WINDOW_SIZE = 50; %The Unit is micrometer
    ODorOS = 'OS';
    COORDINATES_PATH = 'Coordinates.txt';
    DEBUGFLAG = 1;
    SAVEPATH = './Result/';
    NAME = 'BorichR'; %For output
    FOCUS_OPERATOR = 'LAPE'; %For auto select
    CROP_OPTION = 6; %1 for mid, 2 for tl, 3 for bl, 4 for tr, 5 for br, 6 for all, 7 for auto select
    COLOR_OF_CIRCLE = [255 0 66]; %The color of pixels in the circle
    %Experimental function - it may be time consuming or incorrect
    AUTO_COLOR_DETECT = 1; %set to 1 for AutoCentreColorDetect
    COLORDIFF = 130; %Useful if AUTO_COLOR_DETECT is set
    
    %Read The Image
    image = imread('./Data/Copy of Borich, Ronald.png');
    imSize = size(image, 1);
    
    %Calculate Adaptive Parameters
    PIXELS_PER_DEGREE = (imSize * 24.39) / (30 * AXIAL_LENGTH); %Formula offered in the introduction
    PIXELS_PER_CROPPED_WINDOW = (1500 * CROPPED_WINDOW_SIZE) / (4*1000*0.01306*(AXIAL_LENGTH - 1.82));
    PPCW = PIXELS_PER_CROPPED_WINDOW;
    
    %Find The Centre
    imageSlice = imcrop(image, CENTRE_DETECT_WINDOW);
    if(AUTO_COLOR_DETECT == 1)
        COLOR_OF_CIRCLE = CentreColorDetect( imageSlice, COLORDIFF );
    end
    
    [rowC, colC] = FindOriginPoint(imageSlice, COLOR_OF_CIRCLE);
    rowC = rowC + CENTRE_DETECT_WINDOW(2) - 1;
    colC = colC + CENTRE_DETECT_WINDOW(1) - 1;
    
    %Get Coordinates form the txt file
    [cropIndex, nasal, temp, vert] = textread(COORDINATES_PATH, '%d%f%s%f');
    temp = char(temp);
    
    %Compute Real Coordinates(in pixel)
    nasalR = nasal;
    if(strcmp(ODorOS, 'OD'))
        negIndex = find(temp == 'T');
    else
        negIndex = find(temp == 'N');
    end
    nasalR(negIndex) = -nasalR(negIndex);
    
    nasalR = round(nasalR * PIXELS_PER_DEGREE) + colC;
    vertR = round(vert * PIXELS_PER_DEGREE) + rowC;
    
    %Crop Image and save the results
    autoSelList = zeros(length(cropIndex), 1);
    for i = 1:length(cropIndex)
        crMid = imcrop(image, [nasalR(i)-PPCW/2, vertR(i)-PPCW/2, PPCW, PPCW]);
        crTL = imcrop(image, [nasalR(i)-PPCW, vertR(i)-PPCW, PPCW, PPCW]);
        crBL = imcrop(image, [nasalR(i)-PPCW, vertR(i), PPCW, PPCW]);
        crTR = imcrop(image, [nasalR(i), vertR(i)-PPCW, PPCW, PPCW]);
        crBR = imcrop(image, [nasalR(i), vertR(i), PPCW, PPCW]);
        
        autoSelR = 0;
        if(CROP_OPTION == 7)
            autoSel = zeros(1, 5);
            autoSel(1) = fmeasure(crMid, FOCUS_OPERATOR);
            autoSel(2) = fmeasure(crTL, FOCUS_OPERATOR);
            autoSel(3) = fmeasure(crBL, FOCUS_OPERATOR);
            autoSel(4) = fmeasure(crTR, FOCUS_OPERATOR);
            autoSel(5) = fmeasure(crBR, FOCUS_OPERATOR);
            autoSelR = find(autoSel == max(autoSel));
            autoSelList(i) = autoSelR;
        end
        
        if(CROP_OPTION == 1 || autoSelR == 1 || CROP_OPTION == 6)
            fileName = sprintf('%s_%s_%.2f%s%.2f%s_%s', NAME, ODorOS, ...
                nasal(i), temp(i), vert(i), 'V', 'Mid');
            fileName = strrep(fileName, '.', ',');
            imwrite(crMid, strcat(SAVEPATH, fileName, '.png'));
        end
        if(CROP_OPTION == 2 || autoSelR == 2 || CROP_OPTION == 6)
            fileName = sprintf('%s_%s_%.2f%s%.2f%s_%s', NAME, ODorOS, ...
                nasal(i), temp(i), vert(i), 'V', 'TL');
            fileName = strrep(fileName, '.', ',');
            imwrite(crTL, strcat(SAVEPATH, fileName, '.png'));
        end
        if(CROP_OPTION == 3 || autoSelR == 3 || CROP_OPTION == 6)
            fileName = sprintf('%s_%s_%.2f%s%.2f%s_%s', NAME, ODorOS, ...
                nasal(i), temp(i), vert(i), 'V', 'BL');
            fileName = strrep(fileName, '.', ',');
            imwrite(crBL, strcat(SAVEPATH, fileName, '.png'));
        end
        if(CROP_OPTION == 4 || autoSelR == 4 || CROP_OPTION == 6)
            fileName = sprintf('%s_%s_%.2f%s%.2f%s_%s', NAME, ODorOS, ...
                nasal(i), temp(i), vert(i), 'V', 'TR');
            fileName = strrep(fileName, '.', ',');
            imwrite(crTR, strcat(SAVEPATH, fileName, '.png'));
        end
        if(CROP_OPTION == 5 || autoSelR == 5 || CROP_OPTION == 6)
            fileName = sprintf('%s_%s_%.2f%s%.2f%s_%s', NAME, ODorOS, ...
                nasal(i), temp(i), vert(i), 'V', 'BR');
            fileName = strrep(fileName, '.', ',');
            imwrite(crBR, strcat(SAVEPATH, fileName, '.png'));
        end
    end
    
    %Showing where the windows are
    if(DEBUGFLAG == 1)
        figure
        imagesc(image);
        axis equal
        hold on
        plot(colC, rowC, 'b*');
        
        for i = 1:length(cropIndex)
            colorL = ['r' 'r' 'r' 'r' 'r'];
            if(CROP_OPTION == 1 || autoSelList(i) == 1 || CROP_OPTION == 6)
                colorL(1) = 'y';
            end
            if(CROP_OPTION == 2 || autoSelList(i) == 2 || CROP_OPTION == 6)
                colorL(2) = 'y';
            end
            if(CROP_OPTION == 3 || autoSelList(i) == 3 || CROP_OPTION == 6)
                colorL(3) = 'y';
            end
            if(CROP_OPTION == 4 || autoSelList(i) == 4 || CROP_OPTION == 6)
                colorL(4) = 'y';
            end
            if(CROP_OPTION == 5 || autoSelList(i) == 5 || CROP_OPTION == 6)
                colorL(5) = 'y';
            end
            
            rectangle('Position', [nasalR(i)-PPCW/2, vertR(i)-PPCW/2, PPCW, PPCW], ...
                'EdgeColor', colorL(1), 'LineWidth', 2);
            rectangle('Position', [nasalR(i)-PPCW, vertR(i)-PPCW, PPCW, PPCW], ...
                'EdgeColor', colorL(2), 'LineWidth', 2);
            rectangle('Position', [nasalR(i)-PPCW, vertR(i), PPCW, PPCW], ...
                'EdgeColor', colorL(3), 'LineWidth', 2);
            rectangle('Position', [nasalR(i), vertR(i)-PPCW, PPCW, PPCW], ...
                'EdgeColor', colorL(4), 'LineWidth', 2);
            rectangle('Position', [nasalR(i), vertR(i), PPCW, PPCW], ...
                'EdgeColor', colorL(5), 'LineWidth', 2);
            
            text(nasalR(i), vertR(i), num2str(cropIndex(i)), ...
                'Color', 'white', 'FontSize', 14);
        end 
    end
    
end

%Find the centre of the fovea by color
function [rowIndexC, colIndexC] = FindOriginPoint( imageSlice, COLOR_OF_CIRCLE )
    imSize = size(imageSlice);
    
    for rowIndex = 1:imSize(1)
        indicator = imageSlice(rowIndex, :, 1) == COLOR_OF_CIRCLE(1) ...
            & imageSlice(rowIndex, :, 2) == COLOR_OF_CIRCLE(2) ...
            & imageSlice(rowIndex, :, 3) == COLOR_OF_CIRCLE(3);
        redPixelsPos = find(indicator);
        if ~isempty(redPixelsPos)
            cColIndex = round(median(redPixelsPos));
            break;
        end
    end
    
    indicator = imageSlice(:, cColIndex, 1) == COLOR_OF_CIRCLE(1) ...
        & imageSlice(:, cColIndex, 2) == COLOR_OF_CIRCLE(2) ...
        & imageSlice(:, cColIndex, 3) == COLOR_OF_CIRCLE(3);
    redPixelsPos = find(indicator);
    dCIndex = redPixelsPos(end);
    
    rowIndexC = round((rowIndex + dCIndex) / 2);
    colIndexC = cColIndex;
end

function COLOR_OF_CIRCLE = CentreColorDetect( imageSlice, colorDiff )
    imageSlice = imresize(imageSlice, 0.1);
    
    indexM = (imageSlice(:, :, 1)- imageSlice(:, :, 2) > colorDiff) & ...
        (imageSlice(:, :, 1) - imageSlice(:, :, 3) > colorDiff);
    [row, col] = find(indexM == 1);
    
    COLOR_OF_CIRCLE = zeros(1, 3);
    COLOR_OF_CIRCLE(1) = median(median(imageSlice(row, col, 1)));
    COLOR_OF_CIRCLE(2) = median(median(imageSlice(row, col, 2)));
    COLOR_OF_CIRCLE(3) = median(median(imageSlice(row, col, 3)));
end