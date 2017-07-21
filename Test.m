% function Test
    WINSIZE = 1; %Image.Dimx / WINSIZE must be an interger
    
% %     Image = imread('Test.png');
% %     LapOperator = fspecial('laplacian');
% %     FM = imfilter(Image, LapOperator, 'replicate', 'conv');
% %     FM = double(FM);
% %     FM = FM.^2;
% %     
% %     ResultDimX = size(Image, 1)/WINSIZE;
% %     ResultDimY = size(Image, 2)/WINSIZE;
% %     ResultImage = zeros(ResultDimX, ResultDimY);
% %     
% %     for i = 1:1:ResultDimX
% %         for j = 1:1:ResultDimY
% %             ResultImage(i, j) = mean2(imcrop(FM, [i*WINSIZE j*WINSIZE WINSIZE WINSIZE]));
% %         end
% %     end
% %     
% %     ResultImage = ResultImage / max(max(ResultImage));
% %     BLevel = graythresh(ResultImage);
% %     ResultImage = im2bw(ResultImage, BLevel);
% %     
% %     ImageFDis = zeros(size(Image, 1), size(Image, 2));
% %     for i = 1:1:ResultDimX
% %         for j = 1:1:ResultDimY
% %             for m = 1:WINSIZE
% %                 for n = 1:WINSIZE
% %                     ImageFDis(i*WINSIZE+m, j*WINSIZE+n) = ResultImage(i, j);
% %                 end
% %             end
% %         end
% %     end
% %     
% %     figure, imshow(imcrop(Image, [500 500 299 299]));
% %     figure, imshow(imcrop(ImageFDis, [500 500 299 299]));
% %             
    fclose all
    clear all
    close all
    clc
    
    WINSIZE = 5;
    
    Image = imread('Test_2.png');
     
    LAP = fspecial('laplacian');
    FM = imfilter(double(Image), LAP, 'replicate', 'conv');
    FM = (FM.^2);

    figure
    imagesc(Image)
    colormap gray
    axis off
    title('Original image')

    fun = @(block_struct) mean2(block_struct.data) * ones(size(block_struct.data));
    I3 = blockproc(FM,[WINSIZE WINSIZE],fun);
    norm_I3 = (I3 - min(I3(:))) / ( max(I3(:)) - min(I3(:)) );
    norm_I3 = histeq(norm_I3);
    
    figure
    imagesc(norm_I3)
    colormap jet
    axis off
    title('LAPE with block mean')
    
    BLevel = graythresh(norm_I3);
    ResultImage = im2bw(norm_I3, BLevel);

    figure
    imagesc(ResultImage)
    axis off
    colormap jet
    title('Binary separation with Otsu')
