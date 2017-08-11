function [img] = annTemp(imsize, dist, stdev)
%ANNTEMP Creates an Annular Template with a Gaussian Profilee
%   Takes parameters imsize - size of output image, dist - distance from
%   image centre to the midpoint of the Gaussian profile, and stdev -
%   standard deviation of Gaussian profile.
% example [img] = annTemp(500, 40, 10);
img = zeros(imsize);
height = normpdf(meshgrid(0:0.5:imsize/2,0:2*pi/imsize:2*pi),dist/sqrt(2),stdev); % use the gaussian pdf to plot a straight band in polar coords
height = height';
for x = -imsize/2:imsize/2-1
    for y = -imsize/2:imsize/2-1
        r = round(sqrt(x^2 + y^2)/sqrt(2));
        theta = atan(y/x)/(2*pi);
        if isnan(theta) % need to catch atan(0/0)
            theta = 1;
        end
        img(x+imsize/2+1,y+imsize/2+1) = height(max(r/0.5,1), catchRoll(round(theta*imsize),imsize)); % address into the polar coords
    end
end
img = img*(1/max(img(:))); % normalise, as pdf values are never 1
end

function [i] = catchRoll(i,max)
% Catches rollover and counts down from max value instead.
if i < 1
    i = max + i;
end
end
