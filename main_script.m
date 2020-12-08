%% Bradley Payne
%  Final Project
%  Main Script
%  This project implements the segmentation described in the paper:
%  title: "Automatic seeded region growing ..."
%  authors: Shih, Cheng
close all;
clear all;
clc

%% Read in image
% 
imgname = 'images/01587660047c5afa.jpg';
im = imread(imgname);

% cam = webcam;
% im = snapshot(cam);
% cam = [];

%% reduce the size of image if it larger than 2.5e5
if numel(im)/3 > 2.5e5
    while numel(im)/3 > 3e5
        im = imresize(im, 0.75); 
    end
end
% 
% h = fspecial('gaussian', [5 5], 1);
% im1 = imfilter(im, h, 'symmetric');
im1 = im;
im2 = im1;
%% Convert from RGB to YCC color space 

YCCim = convertToYCC(im1);
% YCCim = rgb2hsv(im1);
%% Automatic Seed Selection

seeds = automaticSeedSelection(YCCim);
numSeeds = max(seeds, [], 'all');
fprintf("Automatic Seed Selection initially detected %.0f regions \n", numSeeds);

%% Burn seeds into the original image 

R = im1(:,:,1);
G = im1(:,:,2);
B = im1(:,:,3);
R(seeds>0) = 255;
G(seeds>0) = 0;
B(seeds>0) = 0;

im1 = cat(3, R, G, B);

figure(3)
imshow(im1), title("seeds found with my implementation")

%% Region Growing
tic
disp("Starting region growing");
regions = regionGrowing(YCCim, seeds);
toc
%% outline regions

% figure(4)
% hold on
mask = boundarymask(regions);
im2 = labeloverlay(im2, mask, 'Transparency', 0);
% title("Regions without merging");

%% Region Merging 
tic
% thresholds  given in paper
disp("Starting region merging");
similarityThresh = 0.1;
sizeThresh = numel(regions)/150;
regions = regionMerging(YCCim, regions, similarityThresh, sizeThresh);
disp("Merging completed");
toc

%% Display merged result
% figure(5)
% hold on
mask = boundarymask(regions);
im3= labeloverlay(im, mask, 'Transparency', 0, 'Colormap', [1, 0, 0]);
% title("Regions after merging");
% 


%% Display results, Save 

fig = figure();
hold on
subplot(2,2,1), imshow(im), title("original image");
subplot(2,2,2), imshow(im1), title("Initial seeds marked in red");
subplot(2,2,3), imshow(im2), title("Regions without merging");
subplot(2,2,4), imshow(im3), title("Regions after merging");