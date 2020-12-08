% Specify the folder where the files live.
% dynamically read in all the images in a folder and do image segmentation
% with default threshold values 

myFolder = 'images/images';
saveFolder = 'results/';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.jpg'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    % Now do whatever you want with this file name,
    savename = sprintf('%s%s_%d',saveFolder, 'res_110' ,k);
    tic
    try
    image_segmentation(fullFileName, true, 0.110, 0, true, savename);
    catch
        disp("An error occurred ");
    end
    toc
end