%% Bradley Payne - Final Project
% implements region growing algorihtm
% defined by the paper: 
% title: "Automatic seeded region growing ..."
% authors: Shih, Cheng
% section 4
% pages 3-6 
% 
%
% GENERAL METHOD: 
% ** Calculate Y, Cb, Cr average of each region, store in seedAvg matrix
% ** Record neighbors of all regions in a sorted list T in decreasing order
% of distances. 
% ** While T is not empty, remove point p and check 4-neighbors to
% determine region 
% 
% T is the set of pixels that are unclassified and have labeled neighbors 
% 
% Function implements steps (3) and (4) in section 4 of the paper
% 
% INPUT:
% im - YCbCr color space image 
% seeds - Labeled seeds matrix from automaticSeedSelection  
% 
% OUTPUT:
% seeds - labeled, grown seeds matrix 

function [seeds] = regionGrowing(im, seeds)

% need to compute the Y C C average of each region 
numSeeds = max(seeds, [], 'all'); 

% seedAvg contains the mean of all seed pixels 
% in terms of Y Cb, Cr 
% index for region i is seedAvg(i, n)
% where n is (1,2,3) coresponding with (Y, Cb, Cr)
seedAvg = zeros(numSeeds, 3);
sizeReg = zeros(numSeeds, 1);
% seperate YCC image into individual components 
Y = im(:,:,1);
Cb = im(:,:,2);
Cr = im(:,:,3);

% compute averages for each region
for i = 1 : numSeeds
   % compute Y_bar for seed/region i 
   seedAvg(i, 1) = mean(Y(seeds == i), 'all');
   % compute Cb_bar
   seedAvg(i, 2) = mean(Cb(seeds == i), 'all');
   % compute Cr_bar
   seedAvg(i, 3) = mean(Cr(seeds == i), 'all');
   % compute size of that region
   sizeReg(i) = sum(seeds == i, 'all');
end
disp('     initial averages computed')


% record unclassified neighbors of all regions in sorted list T
% use relative Euclidian distance (equation 8)
% implementation of section 4 item (3) on page 4 of the paper
% initially populate T which contains: [row, column, relativeDistance]
T = [];
numR = size(seeds, 1);
numC = size(seeds, 2);
% Populate T with all the 8-connected neigbors of labeled areas 
% ignore corners for simplicity 
for r = 2 : numR - 1
    for c = 2 : numC - 1
        
        if seeds(r,c) > 0
           % already labeled, skip this iteration
           continue;  
        end

        % we have a unclassified pixel, if it has a labeled neighbor, add to T
        
        % check above neighbor
        if seeds(r - 1, c) > 0
            T = [T; r , c, relD(seedAvg(seeds(r-1,c), :), im(r, c, :))];
            continue;
        end
     
        % check left neighbor    
        if seeds(r, c-1) > 0
            T = [T; r , c, relD(seedAvg(seeds(r,c -1), :), im(r, c, :))];
            continue;
        end
        % check right neigbor
        if seeds(r, c+1) > 0
            T = [T; r , c, relD(seedAvg(seeds(r,c + 1), :), im(r, c, :))];
            continue;
        end
        % check bottom neighbor
        if seeds(r +1, c) > 0
            T = [T; r, c, relD(seedAvg(seeds(r + 1,c), :), im(r, c, :))]; 
        end
        
    end % end column for loop
end % end initial populate T
disp("     T initially populated");

% sort by T by relative distance, in ascending order
T = sortrows(T, 3); 

% Implementation of section 4 item (4) on page 4 of paper

while ~isempty(T)
    % first point p 
%     p = T(1,:);
    % index of p 
    r = T(1, 1);
    c = T(1, 2);
    
    % pop off first element
    T(1,:) = [];
    
    % check 4 neigbors, put labels
    % initialize to -1
    uL = -1; % up
    dL = -1; % down
    rL = -1; % right
    lL = -1; % left 
    
    % check left and right
    if c > 1
       lL = seeds(r, c - 1);
    end
    if c < numC
        rL = seeds(r, c + 1);
    end
    % check up and down
    if r > 1
       uL = seeds(r - 1, c);
    end
    if r < numR
        dL = seeds(r + 1, c);
    end
    
    % if all neighbors have same label, set to that label
    if lL == rL && uL == dL && lL == uL
        
       seeds(r,c) = lL; 
       newLabel = lL;
        % recompute average for that region
        seedAvg(newLabel, 1) = (seedAvg(newLabel, 1)*sizeReg(newLabel) + Y(r,c))/(sizeReg(newLabel) + 1);
        seedAvg(newLabel, 2) = (seedAvg(newLabel, 2)*sizeReg(newLabel) + Cb(r,c))/(sizeReg(newLabel) + 1);
        seedAvg(newLabel, 3) = (seedAvg(newLabel, 3)*sizeReg(newLabel) + Cr(r,c))/(sizeReg(newLabel) + 1);
        sizeReg(newLabel) = sizeReg(newLabel) + 1;
       continue;
    end
    
    % if multiple labels are options, compute distances to each and set to
    % smallest distance label
    %    l    r    u    d
    l = [lL, rL, uL, dL];
    d = [nan, nan, nan, nan];
    s = [0, 0, 0, 0];
    for i = 1 : 4
        if l(i) > 0
            d(i) = relD(seedAvg(l(i), :), im(r, c, :));
            s(i) = sizeReg(l(i));
        end
    end
    % sort by distance, use region size to break ties
    neighbor4 = [l' d' s'];
    neighbor4 = sortrows(neighbor4, [2 3], {'ascend' 'descend'});
    newLabel = neighbor4(1,1);
    seeds(r,c) = newLabel;
    if newLabel < 1
        disp('error');
    end

    % update average of affected region
    seedAvg(newLabel, 1) = (seedAvg(newLabel, 1)*sizeReg(newLabel) + Y(r,c))/(sizeReg(newLabel) + 1);
    seedAvg(newLabel, 2) = (seedAvg(newLabel, 2)*sizeReg(newLabel) + Cb(r,c))/(sizeReg(newLabel) + 1);
    seedAvg(newLabel, 3) = (seedAvg(newLabel, 3)*sizeReg(newLabel) + Cr(r,c))/(sizeReg(newLabel) + 1);
    sizeReg(newLabel) = sizeReg(newLabel) + 1;
    
    % add 4 neigbors of p to T
    % IF, they are not classified and are not already in T 
    isadded = false;
    if ~lL   % not classified
        if sum(T(:,1) == r & T(:, 2) == (c - 1) ) ~= 1 % not in T
            T = [T; r , c - 1, relD(seedAvg(seeds(r,c), :), im(r, c -1, :))];
            isadded = true;
        end   
    end
     
    if ~rL
        if sum(T(:,1) == r & T(:, 2) == (c + 1) ) ~= 1
            T = [T; r , c + 1, relD(seedAvg(seeds(r,c), :), im(r, c + 1, :))];
            isadded = true;
        end   
    end
    
    if ~uL
        if sum(T(:,1) == (r - 1) & T(:, 2) == c ) ~= 1
            T = [T; r - 1, c, relD(seedAvg(seeds(r,c), :), im(r-1, c, :))];
            isadded = true;
        end   
    end
    if ~dL
       if  sum(T(:,1) == (r + 1) & T(:, 2) == c ) ~= 1
           T = [T; r + 1, c, relD(seedAvg(seeds(r,c), :), im(r+1, c, :))];
           isadded = true;
       end
    end
    if isadded
        % resort T
        T = sortrows(T, 3);  
    end

end % end while(T)
disp("     All pixels Labeled");

end

% helper function that inputs average Y, Cb, Cr for the region
% and inputs Y, Cb, and Cr for the pixel
% (equation 8)
function d = relD(regionAvg, pixel)
numerator = sqrt((pixel(1) - regionAvg(1))^2) + (pixel(2) - regionAvg(2))^2 ...
            + (pixel(3) - regionAvg(3))^2;
denominator = sqrt(pixel(1) + pixel(2)^2 + pixel(3)^2);

d = numerator / denominator; 
end