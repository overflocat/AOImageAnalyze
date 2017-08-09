function YelMeasure_temp
    Image = imread('CrebbinB_OD_3,00N0,00V_BL.png');
    %Image = imresize(Image, 5, 'bicubic');
    imSize = size(Image, 1);
    stdev = 1.44;
    
    fftResult = fftshift(fft2(Image));
    fftResult = log(abs(fftResult).^2);
    
    dist = FindDist(fftResult, stdev, 2, 100)
    ccpd = dist / 36 * 187.5 * sqrt(2)
    %D = sqrt(3) / (2 * (M / ccpd)^2)
    yelMask = annTemp(imSize, 2, 1);
    
    %For Original Image
    figure
    imagesc(Image);
    set(gca,'position',[0 0 1 1],'units','normalized');
    colormap gray
    axis equal
    colorbar

    %For YelMask illustrating
    figure
    imagesc(yelMask);
    set(gca,'position',[0 0 1 1],'units','normalized');
    colormap jet
    axis equal
    colorbar
    
    %For FFT Result Illustraing
    figure
    imagesc(fftResult);
    set(gca,'position',[0 0 1 1],'units','normalized');
    colormap jet
    axis equal
    colorbar
    
    GeneratingIntensity(Image);   
end

function [dist] = FindDist( fftResult, stdev, lThre, rThre )
    imSize = size(fftResult, 1);
    
    for i = 1:30
        YelMaskL = annTemp(imSize, lThre, stdev);
        YelMaskR = annTemp(imSize, rThre, stdev);
        medThre = (lThre + rThre) / 2;
        cofL = corr2(YelMaskL, fftResult);
        cofR = corr2(YelMaskR, fftResult);
        if cofL > cofR
           rThre = medThre;
        else
           lThre = medThre;
        end
    end
    
    dist = medThre;
end

function GeneratingIntensity( Image )
    imSize = size(Image, 1);

    fftResult = fft2(Image);
    fftResult = log(abs(fftResult));
    
    %For Counting of radial average
    splitPos = ((imSize + 1) / 2);
    fftTrans = fftResult(:, 1:1:floor(splitPos))/2 + fftResult(:, imSize:-1:ceil(splitPos))/2;
    fftTrans = fftTrans(1:1:floor(splitPos), :)/2 + fftTrans(imSize:-1:ceil(splitPos), :)/2;
    %fftTrans = interp2(fftTrans, 3);
    
    %For fftTrans Illustrating
    figure
    imagesc(fftTrans);
    set(gca,'position',[0 0 1 1],'units','normalized');
    colormap gray
    axis equal
    colorbar
%     
    %For cycles per degree Illustraing
    figure
    plot(1:size(fftTrans, 1), fftTrans(1, :));
    hold on
    
    a = 1:size(fftTrans, 1);
    b = fftTrans(1, :);
    m = polyfit(a, b, 4);
    q = (a.*a).*(a.*a)*m(1) + (a.*a).*a*m(2) + a.*a*m(3) + a*m(4) + m(5);
    plot(a, q);

    %For Peak Measurement
    figure
    plot(a, b - q);
    n = find(b - q == max(b - q))
    hold on
    plot(n, max(b - q), 'o');

end