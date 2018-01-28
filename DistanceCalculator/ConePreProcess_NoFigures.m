% Script ConePreProcess
% Description: Function to aquire image and crop to size
% Author: PMW
% Version: 1.0
% Date: 10/12/2014

% Input Parameters
% - image_input : the input image
% - cone_radius : the radius of the cones

% Output Paramters
% - image_out : output image

function image_out = ConePreProcess_NoFigures(input_image, cone_radius, ...
    unsharp_amount, unsharp_threshold);

% perform adaptive histogram equalisation, across localised area
eq_NumTiles = [20 20];
eq_ClipLimit = 0.01;
eq_NBins = 256;
eq_Range = 'full';
eq_Distribution = 'rayleigh';
eq_Alpha = 1.5; % only for rayleigh / exponential
eq_image = adapthisteq(input_image, 'NumTiles', eq_NumTiles, ...
       'ClipLimit', eq_ClipLimit, 'NBins', eq_NBins, ...
       'Range', eq_Range, 'Distribution', eq_Distribution);

preprocessed_image = imsharpen(eq_image, 'Radius', cone_radius, 'Amount', unsharp_amount, ...
    'Threshold', unsharp_threshold);

image_out = preprocessed_image;

