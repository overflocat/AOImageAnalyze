function [yelRadius_dppR, coneDensityR] = YelMeasure(ImagePath)
    %Read Image
    if(nargin == 0)
       ImagePath = ('./Data/55x55/CrebbinB_OD_7,00T0,00V_TR.png');
       DEBUGFLAG = 1;
    else
       DEBUGFLAG = 0;
    end
    image = imread(ImagePath);
    imSize = size(image, 1);

    %Set Parameters
    METHOD = 0; %0 for Gaussian mask&correlation, 1 for fitting
    PRE_PROCESSING = 1; %1 for image enhancement
    DELTA = 1.5; %Unit is 'Cycles per degree'
    ACCU = 0.01; %The accuracy of the result
    WINDOW_SIZE = 0.055; %Unit is mm
    DEGREE_PER_PIXEL = 0.0026;
    FENLARGE_TIMES = 5;

    %Calculate Adaptive Parameters
    FMAX = 1 / (2 * DEGREE_PER_PIXEL);
    STDEV = DELTA / FMAX * (imSize / 2) * FENLARGE_TIMES;
    IMAGE_MAG = WINDOW_SIZE / (DEGREE_PER_PIXEL * imSize);
    
    %Image Preprocessing
    if(PRE_PROCESSING == 1)
        image = adapthisteq(image);
        image = imsharpen(image);
    end

    %Get fftResult and resize it
    fftResult = fftshift(fft2(image));
    fftResult = log(abs(fftResult).^2);
    fftResult = imresize(fftResult, FENLARGE_TIMES, 'bicubic');
%     filtMask = 1 - annTemp(imSize*FENLARGE_TIMES, 0, 7);
%     fftResult = fftResult .* filtMask;
    
    %Method 0
    intensity = GetIntensity(fftResult);
    if(DEBUGFLAG == 1)
        corrValue = GetCorrMap(fftResult, STDEV);
    end
    yelRadius = GetDist(fftResult, STDEV, 1, ceil(imSize/2 * sqrt(2)), ACCU);
    
    yelRadius_dpp = yelRadius / (imSize * FENLARGE_TIMES / 2) * FMAX;
    coneDensity = sqrt(3) / (2 * (IMAGE_MAG/yelRadius_dpp)^2);
    
    if(DEBUGFLAG == 1)
        fprintf('by GauMethod:\n');
        fprintf('YelRadius of the image is %.2f cycles per degree.\n', yelRadius_dpp);
        fprintf('Cone Density of the image is %.3f cones per mm^2.\n', coneDensity);
    end

    %Method 1
    xValue = [1:size(intensity,1)]';
    fitCoef = polyfit(xValue(10:length(intensity)), intensity(10:length(intensity)), 3);
    yValue = xValue.*xValue.*xValue*fitCoef(1) + xValue.*xValue*fitCoef(2) + xValue*fitCoef(3) + fitCoef(4);

    subY = intensity - yValue;
    yelR = find(subY(5:floor(length(subY)/2), :) == max(subY(5:floor(length(subY)/2), :))) + 4;

    yelR_dpp = yelR / (imSize * FENLARGE_TIMES / 2) * FMAX;
    coneD = sqrt(3) / (2 * (IMAGE_MAG/yelR_dpp)^2);

    %Set Return Value
    if(METHOD == 0)
        yelRadius_dppR = yelRadius_dpp;
        coneDensityR = coneDensity;
    end
    if(METHOD == 1)
        yelRadius_dppR = yelR_dpp;
        coneDensityR = coneD;
    end

    if(DEBUGFLAG == 1)
        fprintf('by Fitting Method:\n');
        fprintf('YelRadius of the image is %.2f cycles per degree.\n', yelR_dpp);
        fprintf('Cone Density of the image is %.3f cones per mm^2.\n', coneD);
    end

    if(DEBUGFLAG == 1)
        %For Original Image
        figure
        subplot(2, 2, 1)
        imagesc(image);
        title('Original Image');
        colormap(gca, gray)
        axis equal
        axis off

        %For FFT Result Illustraing
        subplot(2, 2, 2)
        imagesc(fftResult);
        title('FFT Result');
        colormap(gca, jet)
        axis equal
        
        %For YelMask illustrating
        subplot(2, 2, 3)
        imagesc(annTemp(imSize*FENLARGE_TIMES, yelRadius, STDEV));
        title('Annular Mask');
        colormap(gca, jet)
        axis equal

        %For Intensity
        subplot(2, 2, 4)
        [ax, ~, ~] = plotyy(1:size(intensity,1), intensity, 1:size(corrValue,1), corrValue);
        title('Intensity and Correlation Cof');
        set(ax(1), 'ylim', [min(intensity)-1, max(intensity)+1]);

        %For Intensity - Another measurement of YelRadius
        figure
        subplot(1, 2, 1)
        plot(1:size(intensity,1), intensity);
        title('Intensity and Fitting Curve');
        hold on
        plot(xValue, yValue);

        subplot(1, 2, 2)
        plot(xValue, subY);
        title('YelRadius Detection');
        hold on
        plot(yelR, max(subY(5:floor(length(subY)/2), :)), 'o');
    end
end

%For calculating radial average
function [intensity] = GetIntensity( fftResult )
    imSize = size(fftResult, 1);
    intenResult = zeros(ceil(imSize/2 * sqrt(2)), 2);

    for x = -(imSize/2-0.5):1:(imSize/2-0.5)
        for y = -(imSize/2-0.5):1:(imSize/2-0.5)
            pixelValue = fftResult(x+imSize/2+0.5, y+imSize/2+0.5);
            radius = round(sqrt(x^2 + y^2));
            intenResult(radius, 1) = intenResult(radius, 1) + pixelValue;
            intenResult(radius, 2) = intenResult(radius, 2) + 1;
        end
    end

    intensity = intenResult(:, 1) ./ intenResult(:, 2);
    intensity(isnan(intensity)) = [];
end

%For computing the radius of the Yellott's ring by bisection method
function [dist] = GetDist( fftResult, stdev, lThre, rThre, accu )
    imSize = size(fftResult, 1);

    yelMaskL = annTemp(imSize, lThre, stdev);
    yelMaskR = annTemp(imSize, rThre, stdev);
    cofL = corr2(yelMaskL, fftResult);
    cofR = corr2(yelMaskR, fftResult);

    while(rThre - lThre > accu)
        medThre = (lThre + rThre) / 2;
        if cofL > cofR
            rThre = medThre;
            yelMaskR = annTemp(imSize, rThre, stdev);
            cofR = corr2(yelMaskR, fftResult);
        else
            lThre = medThre;
            yelMaskL = annTemp(imSize, lThre, stdev);
            cofL = corr2(yelMaskL, fftResult);
        end
    end

    dist = medThre;
end

%For generating the correlation curve
function [corrValue] = GetCorrMap( fftResult, stdev )
    imSize = size(fftResult, 1);

    corrValue = zeros(ceil(imSize/2 * sqrt(2)), 1);
    for r = 1:ceil(imSize/2 * sqrt(2))
        corrValue(r) = corr2(annTemp(imSize, r, stdev), fftResult);
    end
end

