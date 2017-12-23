% Script ConeFileAquisition
% Description: Function to aquire image and crop to size
% Author: PMW
% Version: 1.0
% Date: 10/12/2014

% Input Parameters
% - path : base directory of files
% - path_subdir : sub directory of image file
% - file : filename to process

% Output Paramters
% - image_out : output image, in double format

function image_out = ConeFileAquisition_NoFigure(path, path_subdir, file)

% read file
input_image = imread(strcat(path, path_subdir, file));

% crop image to cone area
crop_image = input_image(271:1770, 1:1500);
% testing
%crop_image = input_image(500:700, 400:600);

% show input image
%figure ('Name', 'Input Image');
%imshow (crop_image);
image_out = crop_image;
