clear; close all; clc;

% Specify the folder where your .mp3 files are located
audioFolder = pwd; % Current directory, assuming it contains your files and code
processedFolder = fullfile(audioFolder, 'Processed_Files_Phase3');

% Create the processed folder if it does not exist
if ~exist(processedFolder, 'dir')
    mkdir(processedFolder);
end

% Get a list of all .mp3 files in the folder
audioFiles = dir(fullfile(audioFolder, '*.mp3'));

% Number of channels for bandpass filter bank
N = 8; % You can adjust this value as needed

% Loop through each file and process for Phase 3
for k = 1:length(audioFiles)
    try
        % Get the file name and full path
        fileName = audioFiles(k).name;
        filePath = fullfile(audioFolder, fileName);
        
        % Display which file is being processed
        %fprintf('Processing %s for Phase 3...\n', fileName);
        
        % Call the Phase 3 processing function
        processPhase3(filePath, processedFolder, N);
        
    catch ME
        % Display an error message if the processing fails
        fprintf('Error processing %s: %s', fileName, ME.message);
    end
end

% Notify the user that processing is complete
fprintf('All audio files have been processed for Phase 3.');
