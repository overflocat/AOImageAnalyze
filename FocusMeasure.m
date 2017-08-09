function FocusMeasure(Measure)
    WINSIZE = 15; %Image.Dimx / WINSIZE must be an interger
    Image = imread('Test_2.png');
    
    switch upper(Measure)
        case 'LAPE'
            LapOperator = fspecial('laplacian');
            FM = imfilter(Image, LapOperator, 'replicate', 'conv');
            imshow(FM);
            FM = double(FM);
            FM = FM.^2;
            
        case 'BREN'
            [M, N] = size(Image);
            DH = zeros(M, N);
            DV = zeros(M, N);
            DV(1:M-2,:) = Image(3:end,:)-Image(1:end-2,:);
            DH(:,1:N-2) = Image(:,3:end)-Image(:,1:end-2);
            FM = max(DH, DV);
            FM = double(FM);
            FM = FM.^2;
            
        case 'GRAE'
            Ix = Image;
            Iy = Image;
            Iy(1:end-1,:) = diff(Image, 1, 1);
            Ix(:,1:end-1) = diff(Image, 1, 2);
            FM = double(Image);
            FM = Ix.^2 + Iy.^2;
    end   
    
    ResultDimX = size(Image, 1)/WINSIZE;
    ResultDimY = size(Image, 2)/WINSIZE;
    ResultImage = zeros(ResultDimX, ResultDimY);
    
    for i = 1:1:ResultDimX
        for j = 1:1:ResultDimY
            ResultImage(i, j) = mean2(imcrop(FM, [(j-1)*WINSIZE+1 (i-1)*WINSIZE+1 WINSIZE-1 WINSIZE-1]));
        end
    end
    
    %ResultImage = ResultImage / max(max(ResultImage));
    %BLevel = graythresh(ResultImage);
    %ResultImage = im2bw(ResultImage, BLevel);
    
    %ResultImage = ResultImage + 1;
    %ResultImage = log2(ResultImage);
    ResultImage = uint16(fix(ResultImage / max(max(ResultImage)) * 65535));
    ResultImage = histeq(ResultImage);
    
    ImageFDis = zeros(size(Image, 1), size(Image, 2));
    for i = 1:1:ResultDimX
        for j = 1:1:ResultDimY
            for m = 1:WINSIZE
                for n = 1:WINSIZE
                    ImageFDis((i-1)*WINSIZE+m, (j-1)*WINSIZE+n) = ResultImage(i, j);
                end
            end
        end
    end
    ImageFDis = uint16(ImageFDis);
    
    %figure, imshow(imcrop(Image, [300 300 499 499]));
    %figure, imshow(imcrop(ImageFDis, [300 300 499 499]));
    
    figure, imshow(Image);
    figure, imshow(ImageFDis);
            
end