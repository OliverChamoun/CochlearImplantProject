clear all;
clc;

% Specify the folder where .mp3 files are located
audioFolder = pwd; % Current directory, assuming it contains files and code

% Create a new folder for processed files if it doesn’t exist
processedFolder = fullfile(audioFolder, 'Processed_Files');
if ~exist(processedFolder, 'dir')
    mkdir(processedFolder);
end

% Get a list of all .mp3 files in the folder
audioFiles = dir(fullfile(audioFolder, '*.mp3'));

% Loop through each file in the directory
for k = 1:length(audioFiles)
    try
        % Get the file name and full path
        fileName = audioFiles(k).name;
        filePath = fullfile(audioFolder, fileName);
        
        % Display which file is being processed
        fprintf('Processing %s...\n', fileName);
        
        % Call function to process this file and save in the new folder
        processSoundFile(filePath, processedFolder);
        
        % Pause to wait for playback duration before processing the next file
        [inputSignal, fs] = audioread(filePath);
        duration = length(inputSignal) / fs; % Calculate playback duration
        pause(duration); % Pause for the duration of the audio file
        
    catch ME
        fprintf('Error processing %s: %s\n', fileName, ME.message);
    end
end