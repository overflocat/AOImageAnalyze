dataPath = './Data/55x55/';
imageFiles = dir(strcat(dataPath, '*.png'));

for i = 1:length(imageFiles)
    %Compute cone density
    [yelRadius, coneDensity] = YelMeasure(strcat(dataPath, imageFiles(i).name));

    %Implement Focus Measurement
    image = imread(strcat(dataPath, imageFiles(i).name));
    focusMeaR = fmeasure(image, 'LAPE');

    %Print results directly on the console
    fprintf('%s, %.2f, %.2f, %.2f\n', imageFiles(i).name, yelRadius, coneDensity, focusMeaR);
end