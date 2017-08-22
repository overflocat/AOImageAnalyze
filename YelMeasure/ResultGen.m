dataPath = './Data/55x55/';
imageFiles = dir(strcat(dataPath, '*.png'));

for i = 1:length(imageFiles)
    [yelRadius, coneDensity] = YelMeasure(strcat(dataPath, imageFiles(i).name));
    image = imread(strcat(dataPath, imageFiles(i).name));
    focusMeaR = fmeasure(image, 'LAPE');
    fprintf('%s, %.2f, %.2f, %.2f\n', imageFiles(i).name, yelRadius, coneDensity, focusMeaR);
end