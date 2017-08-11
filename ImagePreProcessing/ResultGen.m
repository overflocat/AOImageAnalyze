dataPath = './Original/';
imageFiles = dir(strcat(dataPath, '*.png'));

for i = 1:length(imageFiles)
    ImagePreProcessing(dataPath, imageFiles(i).name);
end