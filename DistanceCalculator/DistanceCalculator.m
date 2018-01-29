function DistanceCalculator()
    % Program parameters
    RULE_FILENAME = 'Rules.txt';
    EXCEL_SAVE_PATH = './ExcelFiles/';
    PANEL_SAVE_PATH = './Panels/';
    DATA_PATH = './Data/';
    BACKGROUND_PERPROCESSED = 0;
    BCAKGROUND_VORONOI = 1;
    CLOSE_WARNING = 1;
    IMAGE_REALSIZE = 50; %Input image must be square

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

    % Read rules
    [cor, coneRadius, pRadiusDelta] = textread(RULE_FILENAME, '%s%f%f');
    
    % Acquire file
    %[filename, pathname] = uigetfile({'*.png', '*.*'}, 'Choose the file which you want to analyze');
    imageFiles = dir(strcat(DATA_PATH, '*.', 'png'));
    fProcessNum = length(imageFiles);
    
    set(0,'DefaultFigureVisible', 'off');
    
    for pos = 1:fProcessNum
        fprintf('Processing file %d / %d\n', pos, fProcessNum);
        %image = imread(strcat(pathname, filename));
        image = imread(strcat(DATA_PATH, imageFiles(pos).name));
        imageSize = size(image, 1);

        % Find index of parameters and set the parameters
        [C, ~] = strsplit(imageFiles(pos).name, '_');
        indexString = char(C(3));
        paraIndex = find(strcmp(cor, indexString), 1);
        cone_radius = coneRadius(paraIndex);
        p_radiusDelta = pRadiusDelta(paraIndex);

        % Pre-process image
        imagePreprocessed = ConePreProcess_NoFigures(image, cone_radius, unsharp_amount, unsharp_threshold);

        % Identify circles
        [centers, ~] = ConeDetector_wParam(imagePreprocessed, cone_radius, p_Sensitivity, p_radiusDelta);

        % Compute NND, FND, ICD and Regularity for each cell
        % This part requires positions of detected centers
        resultS = cell(size(centers, 1)+2, 6);
        resultS(1, :) = [{'Cell_ID'}, {'Adjacent_Cell_IDs'}, {'NND'}, {'FND'}, {'ICD'}, {'Area'}];
        NND = zeros(size(centers, 1), 1);
        FND = zeros(size(centers, 1), 1);
        ICD = zeros(size(centers, 1), 1);
        cellArea = zeros(size(centers, 1), 1);

        surX = [0.5 0.5 imageSize+0.5 imageSize+0.5];
        surY = [0.5 imageSize+0.5 0.5 imageSize+0.5];
        tempcX = [centers(:, 1)', surX];
        tempcY = [centers(:, 2)', surY];
        TRI = delaunay(tempcX, tempcY);

        surIndex = size(centers, 1)+1:size(centers, 1)+4;
        neighborM = GetNeighborOfCenters(size(centers, 1), surIndex, TRI);
        % For computing the area of cells
        bBox = [1 1; 1 imageSize; imageSize imageSize; imageSize 1];
        [V, cells, XY] = VoronoiLimit(centers(:, 1), centers(:, 2), 'bs_ext', bBox);
        for i = 1:size(centers, 1)
           diffXY = repmat(centers(i, :), nnz(neighborM(i, :)), 1) - centers(neighborM(i, :), :);
           diffXY = diffXY / imageSize *IMAGE_REALSIZE;
           dis = sqrt(sum(diffXY.*diffXY, 2));
           NND(i) = min(dis);
           FND(i) = max(dis);
           ICD(i) = sum(dis) / size(dis, 1);
           resultS(i+1, 1) = {i};
           resultS(i+1, 2) = {sprintf('%d ', find(neighborM(i, :)))};
           
           %For computing the area of cells
           fPos = centers(i, 1) == XY(:, 1) & centers(i, 2) == XY(:, 2);
           cellArea(i) = GetAreaOfCell(V(cells{fPos}, :), centers(i, :), imageSize, IMAGE_REALSIZE);
        end

        resultS(2:end-1, 3) = num2cell(NND);
        resultS(2:end-1, 4) = num2cell(FND);
        resultS(2:end-1, 5) = num2cell(ICD);
        resultS(2:end-1, 6) = num2cell(cellArea);

        resultS(end, 1) = {sprintf('cell num: %d', size(centers, 1))};
        resultS(end, 2) = {sprintf('file name: %s', imageFiles(pos).name)};
        resultS(end, 3) = {sprintf('Regularity: %f', mean(NND) / std(NND))};
        resultS(end, 4) = {sprintf('Regularity: %f', mean(FND) / std(FND))};
        resultS(end, 5) = {sprintf('Regularity: %f', mean(ICD) / std(ICD))};
        resultS(end, 6) = {sprintf('Regularity: %f', mean(cellArea) / std(cellArea))};

        % Save Results
        [C, ~] = strsplit(imageFiles(pos).name, '.');
        resultFileName = strcat(EXCEL_SAVE_PATH, char(C(1)), '.xlsx');
        xlswrite(resultFileName, resultS, 1, 'A1');

        % Illustrate original image
        fig = figure;
        subplot(2, 2, 1);
        imshow(image);
        title('Origin');

        % For cone center detected images
        subplot(2, 2, 2);
        if(BACKGROUND_PERPROCESSED == 1)
            imshow(imagePreprocessed);
        else
            imshow(image);
        end
        hold on;

        plot(centers(:, 1), centers(:, 2), 'ro', 'MarkerSize', cone_radius, 'MarkerFaceColor', 'r');
        title('Center Detected');

        % For Voronoi images
        subplot(2, 2, 3);
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
            axis([0 imageSize 0 imageSize]);
            axis off
        end
        title('Voronoi');

        % For markers
        subplot(2, 2, 4);
        if(BCAKGROUND_VORONOI == 1)
            if(BACKGROUND_PERPROCESSED == 1)
                imshow(imagePreprocessed);
            else
                imshow(image);
            end
            hold on;
        end

        plot(centers(:, 1), centers(:, 2), 'b+', vx, vy, 'b-','LineWidth', 0.5);
        if(BCAKGROUND_VORONOI == 0)
            axis equal
            axis([0 imageSize 0 imageSize]);
            axis off
        end

        for i = 1:size(centers, 1)
            text(centers(i, 1), centers(i, 2), num2str(i), ...
                    'Color', 'red', 'FontSize', 10, 'FontWeight', 'bold');
        end
        title('Cell ID');
        
        resultFileName = strcat(PANEL_SAVE_PATH, char(C(1)), '.png');
        print('-r100', resultFileName, '-dpng');
        close(fig);
    end
    
    set(0,'DefaultFigureVisible', 'on');

end

function neighborM = GetNeighborOfCenters(centerS, surIndex, TRI)
    neighborM = logical(sparse(centerS+1, centerS+1));
    TRI(surIndex(1)<=TRI) = centerS + 1;
    neighborM(sub2ind([centerS+1, centerS+1], TRI(:, 1), TRI(:, 2))) = true;
    neighborM(sub2ind([centerS+1, centerS+1], TRI(:, 1), TRI(:, 3))) = true;
    neighborM(sub2ind([centerS+1, centerS+1], TRI(:, 2), TRI(:, 3))) = true;
    neighborM = neighborM(1:end-1, 1:end-1);
    neighborM = neighborM | neighborM';
end

function cellArea = GetAreaOfCell(cNeighborPos, cellCenter, imageSize, IMAGE_REALSIZE)
    pointsNum = size(cNeighborPos, 1);
    cNeighborPos = repmat(cNeighborPos, 2, 1);
    cNeighborPos = cNeighborPos / imageSize * IMAGE_REALSIZE;
    cellCenter = cellCenter / imageSize * IMAGE_REALSIZE;
    cellArea = 0;
    for i = 1 : pointsNum
        vecA = cNeighborPos(i, :) - cellCenter;
        vecB = cNeighborPos(i+1, :) - cellCenter;
        cellArea = cellArea + abs(vecA(1)*vecB(2) - vecA(2)*vecB(1))*0.5;
    end
end
