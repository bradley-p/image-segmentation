%% Bradley Payne - Final Project
% implements region merging algorithm
% defined by the paper: 
% title: "Automatic seeded region growing ..."
% authors: Shih, Cheng
% implements equation (9)
%
% 2 criteria are used for reigion-merging:
% 1. similarity - defined by relative euclidian distance (eq 9)
%   if the similarity (relative distance of average value) of 2 connected
%   regions is less than a threshold, they are merged together. 
%   The size and color averages of the new combined region is updated. 
%   Similarity merging is prioritized based on the most
%   similar, connected regions. Ends when there are no 2 connected regions
%   with a relative distance less than the given treshold 
% 2. size - defined by number of pixels with certain label
%   similar to similarity threshold merging except regions with a size smaller
%   than a given threshold are merged with the connected region most
%   similar. Merges smallest regions first.
%   also updates region sizes and averages after merging
%   Merges until there are no regions smaller than the threshold
%
%
% INPUT:
% YCbCr color space image 
% initial regions found by automaticSeedSelection.m and regionGrowing.m
% a Similarity Threshold
% size threshold
% OUTPUT:
% merged regions

function [regions] = regionMerging(im, regions, simThresh, sizeThresh)
numR = size(regions,1);
numC = size(regions,2);

% need to compute the Y C C average of each region 
numRegions = max(regions, [], 'all'); 

% seperate YCC image into individual components 
Y = im(:,:,1);
Cb = im(:,:,2);
Cr = im(:,:,3);

 % seedAvg contains the mean of all seed pixels 
% in terms of Y Cb, Cr 
% index for region i is seedAvg(i, n)
% where n is (1,2,3) coresponding with (Y, Cb, Cr)
regAvg = zeros(numRegions, 5);

for i = 1 : numRegions        
    % compute size of that region
    regAvg(i, 5) = sum(regions == i, 'all');
    % index so we can keep track of regions when we merge 
    regAvg(i, 1) = i;  
	% compute Y_bar for seed/region i 
	regAvg(i, 2) = mean(Y(regions == i), 'all');
	% compute Cb_bar
	regAvg(i, 3) = mean(Cb(regions == i), 'all');
	% compute Cr_bar
	regAvg(i, 4) = mean(Cr(regions == i), 'all');
end
disp('region averages computed');
disp("Merging regions based on similarity");
while true
   
    connectivityMat = false(numRegions);
    % find the borders
    borders = boundarymask(regions);
    for r = 1 : numR
        for c = 1 : numC
            if borders(r,c)
                % region of pix
                rpix = regions(r,c);
                if(rpix < 1)
                   disp("Unknown error occured");
                   regions(regions == rpix) = 1;
                   continue;
                end
                if r > 1
                    if regions(r-1, c) ~= rpix
                       connectivityMat(rpix, regions(r-1,c)) = 1;
                       connectivityMat(regions(r-1,c), rpix) = 1;
                    end
                end
                if r < numR
                    if regions(r+1, c) ~= rpix
                       connectivityMat(rpix, regions(r+1,c)) = 1;
                       connectivityMat(regions(r+1,c), rpix) = 1;
                    end
                end
                if c > 1
                    if regions(r, c - 1) ~= rpix
                       connectivityMat(rpix, regions(r,c -1)) = 1;
                       connectivityMat(regions(r,c -1), rpix) = 1;
                    end
                end
                if c < numC
                    if regions(r, c + 1) ~= rpix
                       connectivityMat(rpix, regions(r,c +1)) = 1;
                       connectivityMat(regions(r,c +1), rpix) = 1;
                    end
                end
            end % end if there is a border here
        end 
    end % connections computed

    % iteratively merge based on similarity distance less than a threshold
    dist = nan(numRegions);
    for r = 1 : numRegions
        for c = 1 : numRegions
            if connectivityMat(r,c) && isnan(dist(r,c))
                d = computeD(regAvg(r, :), regAvg(c, :));
                dist(r,c) = d;
                dist(c,r) = d; 
            end
        end
    end
    
  [minD, ind] =  min(dist(:));
    
  if minD <= simThresh
     
      [reg1, reg2] = ind2sub(size(dist), ind);
      % merge lower higher to lower
      if reg1 > reg2
          temp = reg1;
          reg1 = reg2;
          reg2 = temp;      
      end
      % THIS IS WHERE WE MERGE
      regions(regions == reg2) = reg1;
      % update region averages and sizes
      s1 = regAvg(reg1, 5);
      s2 = regAvg(reg2, 5);
      newS = s1 + s2;
      % Ybar update
      regAvg(reg1, 2) = (regAvg(reg1,2)*s1 + regAvg(reg2,2)*s2)/newS;
      % CbBar update
      regAvg(reg1, 3) = (regAvg(reg1,3)*s1 + regAvg(reg2,3)*s2)/newS;
      % Cr Bar update
      regAvg(reg1, 4) = (regAvg(reg1,4)*s1 + regAvg(reg2,4)*s2)/newS;
      % size
      regAvg(reg1, 5) = newS;
      
      if reg2 < numRegions
      regions(regions == numRegions) = reg2;
      regAvg(reg2, :)  = regAvg(numRegions, :);
      end
      regAvg(numRegions,:) = [];
      numRegions = numRegions - 1; 
  else
     % There are no more regions with similarity less than threshold 
     break; % ends while true
  end   % end similarity merging

end % end while true
disp("Merging regions based on size");

% merge based on size
while(true)   
     
    % get minimum size and the region that has it
    [minSize, rpix] = min(regAvg(:,5));
    
    if minSize <= sizeThresh
    % find connected components with reg 
    connectivityMat = false(numRegions, 1);
    % find the borders
    borders = boundarymask(regions);
    for r = 1 : numR
        for c = 1 : numC
            if borders(r,c)
                if regions(r,c) == rpix
                    if r > 1
                        if regions(r-1, c) ~= rpix
                           connectivityMat(regions(r-1,c)) = 1;
                        end
                    end
                    if r < numR
                        if regions(r+1, c) ~= rpix
                            connectivityMat(regions(r+1,c)) = 1;
                        end
                    end
                    if c > 1
                        if regions(r, c - 1) ~= rpix
                        connectivityMat(regions(r,c -1)) = 1;
                        end
                    end
                    if c < numC
                        if regions(r, c + 1) ~= rpix
                            connectivityMat(regions(r,c +1)) = 1;
                        end
                    end
                end
            end % end if there is a border here
        end 
    end % connections computed
    % compute min distance
    minDistReg = inf;
    % region of min distance
    minReg = 0;
    for j = 1 : numRegions
        if connectivityMat(j)
            dr1 = computeD(regAvg(rpix, :), regAvg(j, :));
            if dr1 < minDistReg
               minDistReg = dr1;
               minReg = j;
            end
        end
    end
    
    % merge rpix -> minReg
    regions(regions == rpix) = minReg;
    % update region averages and sizes
    s1 = regAvg(minReg, 5);
    s2 = regAvg(rpix, 5);
    newS = s1 + s2;
    % Ybar update
    regAvg(minReg, 2) = (regAvg(minReg,2)*s1 + regAvg(rpix,2)*s2)/newS;
    % CbBar update
    regAvg(minReg, 3) = (regAvg(minReg,3)*s1 + regAvg(rpix,3)*s2)/newS;
    % Cr Bar update
    regAvg(minReg, 4) = (regAvg(minReg,4)*s1 + regAvg(rpix,4)*s2)/newS;
    % size
    regAvg(minReg, 5) = newS;
   
    if rpix < numRegions
        regions(regions == numRegions) = rpix;
        regAvg(rpix, :)  = regAvg(numRegions, :);
    end
    regAvg(numRegions,:) = [];
    numRegions = numRegions - 1;
  
    else
        % all regions are bigger than sizethresh 
        break;
    end
    
end

end

function [d] = computeD(avg1, avg2)
num = (avg1(2) - avg2(2))^2 ...
      + (avg1(3) - avg2(3))^2 ...
      + (avg1(4) - avg2(4))^2;

den1 = sqrt(avg1(2)^2 + avg1(3)^2 + avg1(4)^2);
den2 = sqrt(avg2(2)^2 + avg2(3)^2 + avg2(4)^2);

d = sqrt(num) / (min(den1, den2));

end
