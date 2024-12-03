function processSoundFile(filePath, processedFolder)
    % Function to process sound files according to the steps in Task 3

    % 3.1 Read sound file and get sampling rate
    [inputSignal, fs] = audioread(filePath); % Read the file and obtain sampling rate
    
    % 3.2 Check if stereo or mono
    [~, cols] = size(inputSignal);
    if cols == 2
        % Convert stereo to mono by averaging the two channels
        inputSignal = sum(inputSignal, 2) / 2;
    end
    
    % 3.3 Play the sound
    sound(inputSignal, fs);
    
    % 3.4 Write the sound to a new file in the specified processed folder
    [~, fileName, ext] = fileparts(filePath);
    outputFilePath = fullfile(processedFolder, [fileName '_processed' ext]);
    audiowrite(outputFilePath, inputSignal, fs);
    
    % 3.5 Plot the sound waveform as a function of sample number
    figure;
    plot(inputSignal);
    title('Waveform of the Sound Signal');
    xlabel('Sample Number');
    ylabel('Amplitude');
    
    % 3.6 Resample if the sampling rate is not 16 kHz
    if fs > 16000
        % Manually downsample by selecting every (fs / 16000) sample
        factor = round(fs / 16000);
        inputSignal = inputSignal(1:factor:end);
        fs = 16000; % Update the sampling rate
    end
    
    % 3.7 Generate a 1 kHz cosine signal
    duration = length(inputSignal) / fs; % Duration in seconds
    t = 0:1/fs:duration-(1/fs); % Time vector
    cosineSignal = cos(2 * pi * 1000 * t); % 1 kHz cosine signal

    % Play the cosine signal
    sound(cosineSignal, fs);

    % Plot two cycles of the cosine signal
    figure;
    plot(t(1:round(2*fs/1000)), cosineSignal(1:round(2*fs/1000)));
    title('Two Cycles of 1 kHz Cosine Wave');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
end