function FocusMeasure(Measure)
    %Set Parameters
    WINSIZE = 5; %Window size of the sharpness map
    DISPLAYA = [500 500 199 199]; %The area which will be showed on the screen
    
    %Read the image
    Image = imread('Test.png');
    
    %Set the focus operator and get the results
    switch upper(Measure)
        case 'LAPE'
            LapOperator = fspecial('laplacian');
            FM = imfilter(Image, LapOperator, 'replicate', 'conv');
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
            FM = Ix.^2 + Iy.^2;
    end

    %Generate sharpness map
    fun = @(block_struct) mean2(block_struct.data) * ones(size(block_struct.data));
    I3 = blockproc(FM,[WINSIZE WINSIZE],fun);
    norm_I3 = (I3 - min(I3(:))) / ( max(I3(:)) - min(I3(:)) );
    norm_I3 = histeq(norm_I3);
    
    %For original image
    IO = figure;
    set(gca,'position',[0 0 1 1],'units','normalized');
    imagesc(imcrop(Image, DISPLAYA));
    colormap gray
    axis off
    axis equal
    saveas(IO, 'Original', 'tif');
    
    %For shaprness map
    ID = figure;
    set(gca,'position',[0 0 1 1],'units','normalized');
    imagesc(imcrop(norm_I3, DISPLAYA));
    colormap jet
    axis off
    axis equal
    saveas(ID, 'Map', 'tif');
    
    %Overlapping shaprness map on the original image
    figure
    set(gca,'position',[0 0 1 1],'units','normalized');
    im1 = imread('Original.tif');
    image(im1)
    im2 = imread('Map.tif');
    hold on
    him = image(im2);
    set(him, 'AlphaData', 0.5);
    axis off
    axis equal
    
    BLevel = graythresh(norm_I3);
    ResultImage = im2bw(norm_I3, BLevel);

    %For illustrating binary sharpness map
    figure
    set(gca,'position',[0 0 1 1],'units','normalized');
    imagesc(imcrop(ResultImage, DISPLAYA))
    axis off
    axis equal
    colormap jet
end
