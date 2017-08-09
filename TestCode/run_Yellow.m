close all
clear all
fclose all
clc

I = imread('test_I.png');

% (from the paper) this image was resampled to five times its size using bicubic interpolation.
% I haven't include this one, it should just scale the reults
% I = imresize(I,5,'bicubic');

figure
subplot(1,3,1)
imshow(I)
title('Image')
colormap(gca,gray)

% (from the paper)  The power spectrum was calculated as the log10 of the square of the absolute value of the DFT image
F=fft2(double(I));
S=fftshift(F);
PS = log10(abs(S).^2);

subplot(1,3,2)
imagesc(PS)
axis image
axis off
title('The power spectrum ')
colormap(gca,jet)

subplot(1,3,3)
[mask] = annTemp(size(S,1), 60, 5);
imagesc(mask)
title('The annular mask')
axis image
axis off
colormap(gca,jet)

figure
plot(PS((size(I,1)/2)+1,((size(I,2)/2))+1:end),'r')
hold on
plot(mask((size(I,1)/2)+1,((size(I,2)/2))+1:end),'b')
legend('Profile of the power Spectrum','Profile mask')
