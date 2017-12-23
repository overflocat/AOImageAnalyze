% Script ConeCounter
% Description: Overall coordinating script for cone counter
% Author: PMW, WYF
% Version: 1.0
% Date: 10/12/2014

function AutoConeCounter
    % Program parameters
    DEBUG_FLAG = 0;
    IMAGE_TYPE = 'png';
    RULE_FILENAME = 'Rules.txt';
    RESULT_FILENAME = 'Result.xlsx';
    DATA_PATH = './Data/';
    IMAGEA_PATH = './ImageA/';
    IMAGEB_PATH = './ImageB/';
    IMAGE_SAVE_TYPE = 'png';
    IMAGE_SAVE_PARA = '-dpng';
    ENLARGE_TIMES = 5;
    BACKGROUND_PERPROCESSED = 1;
    BCAKGROUND_VORONOI = 1;
    CLOSE_WARNING = 1;

    % Fixed image paramaters
    p_Sensitivity = 0.99;
    unsharp_amount = 0.99;
    unsharp_threshold = 0.1;

    % Auto-adjusted parameters
    cone_radius = 4;
    p_radiusDelta = 2;
    
    % Close warning of circle detector 
    if(CLOSE_WARNING == 1)
        warning('off','all');
    end

    % Get image handles
    imageFiles = dir(strcat(DATA_PATH, '*.', IMAGE_TYPE));
    if(DEBUG_FLAG == 1)
        fProcessNum = 3;
    else
        fProcessNum = length(imageFiles);
    end

    % Read rules
    [cor, coneRadius, pRadiusDelta] = textread(RULE_FILENAME, '%s%f%f');

    % Creat lists to store results
    fileNameList = cell(fProcessNum+1, 1);
    coneTotalList = cell(fProcessNum+1, 1);
    coneStdDevList = cell(fProcessNum+1, 1);
    coneMeanList = cell(fProcessNum+1, 1);
    fileNameList(1) = {'File Name'};
    coneTotalList(1) = {'Cone Number'};
    coneStdDevList(1) = {'Cone Radii Dev'};
    coneMeanList(1) = {'Cone Radii Mean'};

    % Open figure
    if(DEBUG_FLAG == 1)
        set(0,'DefaultFigureVisible', 'on');
    else
        set(0,'DefaultFigureVisible', 'off');
    end

    waitBar = waitbar(0,'Processing started. Please wait...');
    for i = 1:fProcessNum
        % Acquire file
        image = imread(strcat(DATA_PATH, imageFiles(i).name));
        imageSize = size(image);

        % Find index of parameters and set the parameters
        [C, ~] = strsplit(imageFiles(i).name, '_');
        indexString = char(C(3));
        paraIndex = find(strcmp(cor, indexString), 1);
        cone_radius = coneRadius(paraIndex);
        p_radiusDelta = pRadiusDelta(paraIndex);

        % Pre-process image
        imagePreprocessed = ConePreProcess_NoFigures(image, cone_radius, unsharp_amount, unsharp_threshold);

        % Identify circles
        [centers, radii] = ConeDetector_wParam(imagePreprocessed, cone_radius, p_Sensitivity, p_radiusDelta);

        % Store stats about the cones
        fileNameList(i+1) = {imageFiles(i).name};
        coneTotalList(i+1) = {size(radii, 1)};
        coneStdDevList(i+1) = {std(radii)};
        coneMeanList(i+1) = {mean(radii)};

        % Generate and store figures
        [C, ~] = strsplit(imageFiles(i).name, '.');

        % For cone center detected images
        ceFileName = strcat(char(C(1)), '_Ce', '.', IMAGE_SAVE_TYPE);

        fig = figure;
        set(gca, 'Position', [0 0 1 1]);
        set(gcf, 'PaperPosition',[0 0 imageSize(2)*ENLARGE_TIMES/100 imageSize(1)*ENLARGE_TIMES/100]);
        if(BACKGROUND_PERPROCESSED == 1)
            imshow(imagePreprocessed);
        else
            imshow(image);
        end
        hold on;
        
        plot(centers(:, 1), centers(:, 2), 'ro', 'MarkerSize', cone_radius*ENLARGE_TIMES/5, 'MarkerFaceColor', 'r');
        print('-r100', strcat(IMAGEA_PATH, ceFileName), IMAGE_SAVE_PARA);
        %export_fig(strcat(IMAGEA_PATH, ceFileName), '-r100');
        
        if(DEBUG_FLAG == 0)
            close(fig);
        end

        % For Voronoi images
        voFileName = strcat(char(C(1)), '_Vo', '.', IMAGE_SAVE_TYPE);

        fig = figure;
        set(gca, 'Position', [0 0 1 1]);
        set(gcf, 'PaperPosition',[0 0 imageSize(2)*ENLARGE_TIMES/100 imageSize(1)*ENLARGE_TIMES/100]);
        if(BCAKGROUND_VORONOI == 1)
            if(BACKGROUND_PERPROCESSED == 1)
                imshow(imagePreprocessed);
            else
                imshow(image);
            end
            hold on;
        end

        [vx, vy] = voronoi(centers(:, 1), centers(:, 2));
        plot(centers(:, 1), centers(:, 2), 'r+', vx, vy, 'b-','LineWidth', 1.5);
        if(BCAKGROUND_VORONOI == 0)
            axis equal
            axis([0 imageSize(1) 0 imageSize(2)]);
            axis off
        end
        print('-r100', strcat(IMAGEB_PATH, voFileName), IMAGE_SAVE_PARA);
        %export_fig(strcat(IMAGEB_PATH, voFileName), '-r100');

        if(DEBUG_FLAG == 0)
            close(fig);
        end

        waitbar(i / fProcessNum);
    end
    close(waitBar);

    xlswrite(RESULT_FILENAME, fileNameList, 1, 'A1');
    xlswrite(RESULT_FILENAME, coneTotalList, 1, 'B1');
    xlswrite(RESULT_FILENAME, coneStdDevList, 1, 'C1');
    xlswrite(RESULT_FILENAME, coneMeanList, 1, 'D1');

end