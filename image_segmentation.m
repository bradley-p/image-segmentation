%% Bradley Payne 
% Final Project 
%
%
% The purpose of this file is to functionize the different sections
% of image segmentation using a Seeded Region Growing (SRG) algorithm 
% 
% method is an implementation of the paper: 
% title: "Automatic seeded region growing ..."
% authors: Shih, Cheng

function [im, im1, im2, im3] = image_segmentation(imgname, resizeopt, simThresh, sizeThresh, saveopt, savename)
%% Read in image
im = [];
im1 = [];
im2 = [];
im3 = [];

im = imread(imgname);

% cam = webcam;
% im = snapshot(cam);
% cam = [];
%% reduce the size of image if it larger than 3.5e5
if resizeopt
    if numel(im)/3 > 2.6e5
        while numel(im)/3 > 3.5e5
            im = imresize(im, 0.75); 
        end
    end
end
% h = fspecial('gaussian', [5 5], 1);
% im1 = imfilter(im, h, 'symmetric');

%% Convert from RGB to YCC color space 
disp(" - Converting image to YCC color Space - ");
YCCim = convertToYCC(im);
disp(" * image converted * ");
fprintf("\n");
%% Automatic Seed Selection
disp(" -- Starting automatic seed selection -- ");
seeds = automaticSeedSelection(YCCim);
numSeeds = max(seeds, [], 'all');
fprintf("Automatic Seed Selection detected %.0f regions \n", numSeeds);
disp("** Seeds initialized ** ");
fprintf("\n");

%% Burn seeds into the original image 
im1 = im;
R = im1(:,:,1);
G = im1(:,:,2);
B = im1(:,:,3);
R(seeds>0) = 255;
G(seeds>0) = 0;
B(seeds>0) = 0;

im1 = cat(3, R, G, B);

% figure(3)
% imshow(im1), title("seeds marked in red")

%% Region Growing
disp("--- Starting region growing ---");
regions = regionGrowing(YCCim, seeds);
disp("*** Region Growing Completed *** ");
fprintf("\n");
%% outline regions without merging 

% figure(4)
% hold on
mask = boundarymask(regions);
im2 = labeloverlay(im, mask, 'Transparency', 0);
% title("Regions without merging");

%% Region Merging 
% thresholds  given in paper
disp("--- region merging ---");

% similarityThresh = 0.1;

if sizeThresh == 0
    sizeThresh = numel(regions)/150;
end
regions = regionMerging(YCCim, regions, simThresh, sizeThresh);
disp("**** Merging Completed **** \n");
fprintf("\n");
fprintf("\n");
mask = boundarymask(regions);
im3 = labeloverlay(im, mask, 'Transparency', 0);
%% Display results, Save 

fig = figure();
hold on
subplot(2,2,1), imshow(im), title("original image");
subplot(2,2,2), imshow(im1), title("Initial seeds marked in red");
subplot(2,2,3), imshow(im2), title("Regions without merging");
subplot(2,2,4), imshow(im3), title("Regions after merging");

if saveopt
    saveas(fig, savename, 'jpeg');
end
hold off
end
