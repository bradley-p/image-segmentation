%% Bradley Payne - Final Project
% This function takes in a color image
% converts to YCbCr (YCC) color space as defined by the paper: 
% title: "Automatic seeded region growing ..."
% authors: Shih, Cheng
% page 2 
% implements equation (1)
%
% input: rgb image
% output: tranformed image
% Y color space has range [16, 235]
% Cb and Cr spaces have range [16, 240]

function [YCC] = convertToYCC(im)
if size(im, 3) ~= 3
    disp("ERROR - color images only");
    YCC = [];
    return;
end

% scale to be between 0 - 1
% also converts to double 
im = rescale(im);

% coefficient matrix given by paper
coef = [65.481 128.553 24.966; ...
        -39.797 -74.203 112; ...
        112 -93.786 -18.214];
    
% constant matrix from paper
C = [16; 128; 128];
    
% initialize size of new color space
YCC = zeros(size(im));

% implementation of equation (1)
for r = 1 : size(im, 1)
    for c = 1 : size(im, 2)
        R = im(r,c,1);
        G = im(r,c,2);
        B = im(r,c,3);
        rgb = [R; G; B];
        YCC(r,c, :) = coef * rgb + C;
    end
end

return;
end