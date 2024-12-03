clear; close all; clc;

% Specify the folder where your .mp3 files are located
audioFolder = pwd; % Current directory, assuming it contains your files and code
processedFolder = fullfile(audioFolder, 'Processed_Files_Phase2');
if ~exist(processedFolder, 'dir')
    mkdir(processedFolder);
end

% Get a list of all .mp3 files in the folder
audioFiles = dir(fullfile(audioFolder, '*.mp3'));

% Number of channels for bandpass filter bank
N = 8; % You can adjust this value as needed

% Loop through each file and process for Phase 2
for k = 1:length(audioFiles)
    try
        % Get the file name and full path
        fileName = audioFiles(k).name;
        filePath = fullfile(audioFolder, fileName);
        
        % Display which file is being processed
        fprintf('Processing %s for Phase 2...\n', fileName);
        
        % Call the Phase 2 processing function
        processPhase2(filePath, processedFolder, N);
        
    catch ME
        fprintf('Error processing %s: %s\n', fileName, ME.message);
    end
end
