function GetFocusValue
    dataPath = './Data/55x55/';
    imageFiles = dir(strcat(dataPath, '*.png'));
    focusOperator = 'LAPE';
    resultFileName = 'Result.xlsx';

    fileNameList = cell(length(imageFiles)+1, 1);
    resultList = cell(length(imageFiles)+1, 1);
    for i = 1:length(imageFiles)
        %Implement Focus Measurement
        image = imread(strcat(dataPath, imageFiles(i).name));
        focusMeaR = fmeasure(image, focusOperator);

        fileNameList(i+1) = {imageFiles(i).name};
        resultList(i+1) = {focusMeaR};    
    end
    
    fileNameList(1) = {'File Name'};
    resultList(1) = {focusOperator};
    xlswrite(resultFileName, fileNameList, 1, 'A1');
    xlswrite(resultFileName, resultList, 1, 'B1');
end