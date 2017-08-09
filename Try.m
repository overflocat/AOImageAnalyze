function Try
    Image = imread('Ftest.png');
    
    WINSIZE = 12;
    
    fun = @(block_struct) im2bw(block_struct.data, graythresh(block_struct.data));
    result = blockproc(Image, [WINSIZE WINSIZE], fun);
    
    figure
    imagesc(Image);
    colormap gray
    axis equal
    
    figure
    imagesc(result);
    colormap gray
    axis equal
    
end