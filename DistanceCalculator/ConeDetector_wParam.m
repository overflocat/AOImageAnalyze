% Script ConeDetector
% Description: Wrapper function to detect cones in image
% Author: PMW
% Version: 1.0
% Date: 10/12/2014

% Input Parameters
% - image_input : the input image
% - radius : the radius of the cones to find

% Output Paramters
% - centers : x,y coordinates of the center of circles
% - radii : radius of circles

function [centers, radii] = ConeDetector_wParam(image_input, radius, p_Sensitivity, p_radiusDelta)

p_ObjectPolarity = 'bright';
p_Method = 'TwoStage';
%p_Method = 'PhaseCode';
%p_Sensitivity = 0.95;
p_EdgeThreshold = 0.8; % Not used
p_radiusFudgeFactor = p_radiusDelta;
[centers, radii] = imfindcircles (image_input, [radius-p_radiusFudgeFactor radius+p_radiusFudgeFactor], ...
    'ObjectPolarity', p_ObjectPolarity, 'Method', p_Method, ...
    'Sensitivity', p_Sensitivity);


