function ImagePreProcessing(readPath, fileName)
    %Set Parameters
    SAVEPATH = './Result/'; %Save all results here
    NEW_DIM = 300; % The new size of the image, must be an even number
    DELTA_DETECT = 5.5; %Unit is 'Cycles per degree', for detecting Yellot's ring
    DEGREE_PER_PIXEL = 0.0026; %predefined parameter
    DEBUGFLAG = 1; %For illustrating the results
    FIL_OPTION = 2; %1 for gaussian band-pass filtering, 2 for gaussian low-pass filtering, 
                    %3 for ideal low-pass filtering, 4 for bilateral filtering
    DELTA_FIL_BAND = 9.5; %For option 1, set the value of delta when generating the gaussian mask
                          %The unit of it is cycles per degree
    PER_RADIUSG = 1.0; %For option 2, the radius of Gaussian mask is PER_RADIUSG * Radius_of_Yellot_ring
    PER_RADIUSI = 1.0; %For option 3, cut all parts which frequency is above PER_RADIUSI * Radius_of_Yellot_ring
                       %Both units of the parameters are cycles per degree 
    LOW_PERCENT = 0; %For option 3, set all High frequency part into LOW_PERCENT * Original_Value
    Q_ENHANCEMENT = 1; %Set it to 1 to open unsharp mask and adapthisteq
    %Caution: the paramters of bifilter can be set below

    %For debug
    if(nargin == 0)
       readPath = './Original/';
       fileName = 'CrebbinB_OD_3,00T0,00V_Mid.png';
    else
       DEBUGFLAG = 0;
    end
    
    %Calculate Adaptive parameters
    FMAX = 1 / (2 * DEGREE_PER_PIXEL);
    STDEV_DETECT = DELTA_DETECT / FMAX * (NEW_DIM / 2);
    STDEV_FIL_BAND = DELTA_FIL_BAND / FMAX * (NEW_DIM / 2);

    %Read Image
    image = imread(strcat(readPath, fileName));
    image = imresize(image, [NEW_DIM NEW_DIM], 'bicubic');
    
    %Get fftResult
    fftResult = fftshift(fft2(image)); 
    fftResultE = log(abs(fftResult).^2);
    
    %Get the radius of Yellot's ring
    dist = GetDist(fftResultE, STDEV_DETECT, 1, ceil(NEW_DIM/2 * sqrt(2)), 0.01);

    %Get Mask
    if(FIL_OPTION == 1)
        mask = annTemp(NEW_DIM, dist, STDEV_FIL_BAND);
    elseif(FIL_OPTION == 2)
        mask = annTemp(NEW_DIM, 0, dist*PER_RADIUSG);
    elseif(FIL_OPTION == 3)
        mask = GetLowPassMask(NEW_DIM, dist*PER_RADIUSI, LOW_PERCENT);
    elseif(FIL_OPTION == 4)
        %Set parameters for bifilter here
        imageT = double(image);
        imageT = bfilter2(imageT/max(imageT(:)));
    end
    
    %Filtering
    if(FIL_OPTION ~= 4)
        fftResultT = fftResult .* mask;
        imageT = ifft2(ifftshift(fftResultT));
        imageT = mat2gray((real(imageT)));
    end
    
    %Image quality enhancement
    if(Q_ENHANCEMENT == 1)
        imageT = adapthisteq(imageT, 'Distribution', 'rayleigh');
        imageT = imsharpen(imageT);
    end
    
    %Write result
    imwrite(imageT, strcat(SAVEPATH, fileName));

    if(DEBUGFLAG == 1)
        %For original image
        figure
        subplot(2, 2, 1);
        imshow(image);
        title('Original Image');

        %For filtered image
        subplot(2, 2, 2)
        imshow(imageT);
        title('Filtered Image')
        
        %If you use bi-filter, mask and FT result won't show here
        if(FIL_OPTION ~= 4)
            %For the mask
            subplot(2, 2, 3)
            imagesc(mask);
            title('Mask');
            colormap(gca, jet);
            axis off
            axis equal

            %For the power spectrum of FT result after filtering
            subplot(2, 2, 4)
            imagesc(fftResultE .* mask);
            title('FFT result after filtering');
            colormap(gca, jet)
            axis off
            axis equal
        end
    end
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

%Generate ideal low-pass mask
function [mask] = GetLowPassMask( imSize, radius, percent )
    mask = zeros(imSize, imSize);
    
    for x = -imSize/2:1:imSize/2-1
        for y = -imSize/2:1:imSize/2-1
            r = sqrt(x^2 + y^2);
            if( r > radius )
                mask(x+imSize/2+1, y+imSize/2+1) = percent;
            else
                mask(x+imSize/2+1, y+imSize/2+1) = 1;
            end
        end
    end  
end