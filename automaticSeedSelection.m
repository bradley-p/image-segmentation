%% Bradley Payne - Final Project
% implements Automatic seed Selection algorithm
% defined by the paper: 
% title: "Automatic seeded region growing ..."
% authors: Shih, Cheng
% pages 2 - 3 
% implements equations (2 - 7)
%
% 
%
% input YCbCr color space image 
% returns 'seeds' that meet the following criteria:
% 1. Seed pixel must have high similarity to its neighbors
% 2. for an expected region, at least one seed must be generated
% 3. seeds for different regions must be disconnected 
%
%
%
% This function requires 2 thresholds
% a similarity threshold
% a distance threshold
% The similarity threshold is computed using Otsu's method in the paper
% I chose to alter this and use the average similarity as the threshold
% distance threshold is hardcoded at 0.05

function [seeds] = automaticSeedSelection(im)

if size(im, 3) ~= 3 || class(im) ~= "double"
    disp("ERROR -- Wrong color space detected");
    seeds = [];
    return;
end

% Threshold value

numR = size(im,1);
numC = size(im,2);

% initialize seeds array with 0's
seeds = zeros(numR, numC);

% seperate image into YCC color space
Y = im(:,:,1);
Cb = im(:,:,2);
Cr = im(:,:,3);

% calculate similarity of pixel to its neigbors
% consider 3x3 neighborhood standard deviation in each color space 
% for simplicity of implementation, assume Seeds cannot reside on the image
% border

% compute standard deviations in each color space seperately
sigmaY = computeSTD(Y, numR, numC);
sigmaCb = computeSTD(Cb, numR, numC);
sigmaCr = computeSTD(Cr, numR, numC);

% compute total standard deviation (equation 3)
totalSigma = sigmaY + sigmaCb + sigmaCr; 

% normalize (equation 4)
total_normalized_sigma = totalSigma / max(totalSigma, [], 'all');

% H is similarity to neighbors (equation 5)
H = 1 - total_normalized_sigma;

% now we need to compute the relative Euclidian Distances
% of each pixel to its eight neighbors

% D is maximum euclidian distance from pixel i,j to its 8 neighbors
% helper function is defined below
% (equations 6 & 7)
D = computeDistance(Y, Cb, Cr, numR, numC);

% THRESHOLDS
% similarity threshold is computed automatically using 
% Otsu's method
% using the matlab built in function will return thresh between 0 - 1
[N, edges] = histcounts(im, 200);
T = otsuthresh(N);

T1 = mean(H, 'all');

T = max(T, T1);
% Distance threshold was anectodotally found
Tdist= 0.05; 

% perform similarity threshold
Hthresh = H > T;
% Hthresh = imdilate(Hthresh, ones(3));
% Hthresh = imerode(Hthresh, ones(3));
% perform distance threshold
Dthresh = D < Tdist;

% Dthresh = imdilate(Dthresh, ones(3));
% Dthresh = imerode(Dthresh, ones(3));

% morphological operations don't generally improve performance 
% potential seeds satisfy Conditions 1 and 2
seeds = Hthresh & Dthresh;
se = strel('disk', 1);

% seeds = imclose(seeds, se);
seeds = imopen(seeds, se);


% better method is to use MATLAB Built in label 
% label based on 4 connectivity
seeds = bwlabel(seeds, 4);

end


% helper function that computes std deviation in a 3x3 neighborhood
% in a given colorspace 
%
% INPUTS:
% cS: given color space
% numR - number of rows in color Space
% numC - number of columns in color Space
%
% OUTPUTS: 
% sigmaN : standard deviation of 3x3 neighborhood centered 
% at that pixel location
% edge pixels are exluded for simplicity 
function [sigmaN] = computeSTD(cS, numR, numC)
sigmaN = ones(numR, numC);

for r = 1 : numR - 2
    for c = 1 : numC - 2 
        % get this subbarray
        sub = cS(r:r+2, c : c+2);
        avgSub = mean(sub, 'all');
        % sum of the differences squared
        % (equation 2)
        sumDifSq = 0;
        for i = 1 : 9
            sumDifSq = sumDifSq + (sub(i) - avgSub)^2;
        end
        sigmaN(r+1,c+1) = sqrt(1/9 * sumDifSq);
    end
end

end

% helper function 
% computes relative Euclidian distnace
% implements equations 6 - 7 
function [D] = computeDistance(Y, Cb, Cr, numR, numC)
D = ones(numR, numC);

for r = 1 : numR - 2
    for c = 1 : numC - 2
        % this pixel 
        Ythis = Y(r+1, c+1);
        Cbthis = Cb(r+1, c+1);
        Crthis = Cr(r+1, c+1);
        % neighborhood pixel
        Ysub = Y(r:r+2, c : c+2);
        Cbsub = Cb(r:r+2, c:c+2);
        Crsub = Cr(r:r+2, c:c+2);
        
        % distance to myself will be 0, so gonna include for simplicity
        d = zeros(9,1);
        
        % (equation 6)
        for i = 1 : 9
            numerator = (Ythis - Ysub(i))^2 + (Cbthis-Cbsub(i))^2 + ...
               (Crthis - Crsub(i))^2;
           d(i) = sqrt(numerator) ... % end of numerator 
               /sqrt(Ythis^2 + Cbthis^2 + Crthis^2); % denomiator
        end
        % equation (7)
        D(r+1, c+1) = max(d);
    end
end

return; 
end

% Recursive Helper function
% Labels seeds based on 4 connectivity
% Disqualifies border pixels as seeds
% I chose to use MATLAB built-in bwlabel for efficiency
function [seeds] = labelSeeds(seeds, r,c, label)
numR = size(seeds,1);
numC = size(seeds,2);

% base case
% first 4 validity checks ensure we don't go out of bounds
if r < 1 || c < 1 || r > numR || c > numC || ...
        seeds(r,c) == 0 || seeds(r,c) == label
    return;
end

% can't be a seed if on border
% if already labeled, on border, set to 0 
if seeds(r,c) > 0 && seeds(r,c) < label
    seeds(r,c) = 0;
    return;
end

seeds(r,c) = label;

% use 4 connectivity based on paper description 
seeds = labelSeeds(seeds, r, c + 1, label);
seeds = labelSeeds(seeds, r + 1, c, label);
seeds = labelSeeds(seeds, r - 1, c, label);
seeds = labelSeeds(seeds, r, c - 1, label);
    
end