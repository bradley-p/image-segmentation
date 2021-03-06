% Specify the folder where the files live.
% dynamically read in all the images in a folder and do image segmentation
% with default threshold values 


myFolder = 'images';
saveFolder = 'results3/';
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
    savename = sprintf('%s%s_%d',saveFolder, 'result_0_10_150th' ,k);
    tic
    try
        scaleDown = true;
        doSave = false;
        
        image_segmentation(fullFileName, scaleDown, 0.10, 0, doSave, savename);
    catch
        disp("An error occurred ");
    end
    toc
end