function Test
    WINSIZE = 3; %Image.Dimx / WINSIZE must be an interger
    
    Image = imread('Test_2.png');
    LapOperator = fspecial('laplacian');
    FM = imfilter(Image, LapOperator, 'replicate', 'conv');
    FM = double(FM);
    FM = FM.^2;
    
    ResultDimX = size(Image, 1)/WINSIZE;
    ResultDimY = size(Image, 2)/WINSIZE;
    ResultImage = zeros(ResultDimX, ResultDimY);
    
    for i = 1:1:ResultDimX
        for j = 1:1:ResultDimY
            ResultImage(i, j) = mean2(imcrop(FM, [i*WINSIZE j*WINSIZE WINSIZE WINSIZE]));
        end
    end
    
    %ResultImage = ResultImage / max(max(ResultImage));
    %BLevel = graythresh(ResultImage);
    %ResultImage = im2bw(ResultImage, BLevel);
    
    %ResultImage = ResultImage + 1;
    %ResultImage = log2(ResultImage);
    ResultImage = int16(fix(ResultImage / max(max(ResultImage)) * 65535));
    ResultImage = histeq(ResultImage);
    figure, imshow(ResultImage);
    figure, imshow(Image);
    
    ImageFDis = zeros(size(Image, 1), size(Image, 2));
    for i = 1:1:ResultDimX
        for j = 1:1:ResultDimY
            for m = 1:WINSIZE
                for n = 1:WINSIZE
                    ImageFDis(i*WINSIZE+m, j*WINSIZE+n) = ResultImage(i, j);
                end
            end
        end
    end
    
    figure, imshow(imcrop(Image, [500 500 299 299]));
    figure, imshow(imcrop(ImageFDis, [500 500 299 299]));
            
end