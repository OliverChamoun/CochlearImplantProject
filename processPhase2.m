function processPhase2(filePath, processedFolder, N)
    % Function to process sound files for Phase 2 of the cochlear implant project
    % Input: filePath - path to the sound file
    %        processedFolder - folder to save processed files
    %        N - number of bandpass filter channels

    % 3.1 Read the input sound file and get sampling rate
    [inputSignal, fs] = audioread(filePath);

    % 3.2 Ensure the signal is mono
    if size(inputSignal, 2) == 2
        inputSignal = sum(inputSignal, 2) / 2; % Convert stereo to mono
    end

    % 3.3 Play the original sound and wait for it to finish
    sound(inputSignal, fs);
    pause(length(inputSignal) / fs); % Wait for the sound to finish playing

    % 3.4 Write the original sound to a new file in the processed folder
    [~, fileName, ext] = fileparts(filePath);
    outputFilePath = fullfile(processedFolder, [fileName '_processed' ext]);
    audiowrite(outputFilePath, inputSignal, fs);

    % 3.5 Plot the sound waveform as a function of sample number
    figure;
    plot(inputSignal);
    title('Waveform of the Original Sound Signal');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % 3.6 Resample if the sampling rate is not 16 kHz
    if fs ~= 16000
        inputSignal = resample(inputSignal, 16000, fs);
        fs = 16000; % Update the sampling rate
    end

    % Commented out 3.7 (Generating a 1 kHz cosine signal)
    % % 3.7 Generate a 1 kHz cosine signal
    % duration = length(inputSignal) / fs; % Duration in seconds
    % t = 0:1/fs:duration-(1/fs); % Time vector
    % cosineSignal = cos(2 * pi * 1000 * t); % 1 kHz cosine signal
    % 
    % % Play the cosine signal
    % sound(cosineSignal, fs);
    % 
    % % Plot two cycles of the cosine signal
    % figure;
    % plot(t(1:round(2*fs/1000)), cosineSignal(1:round(2*fs/1000)));
    % title('Two Cycles of 1 kHz Cosine Wave');
    % xlabel('Time (seconds)');
    % ylabel('Amplitude');

    % --- Phase 2 Starts Here ---
    % Task 4: Design a bank of N bandpass filters to split sound between 100 Hz and 8 kHz
    f_min = 100; % Minimum frequency
    f_max = min(8000, fs / 2 - 200); % Make sure we are even more conservative for f_max

    bandwidth = (f_max - f_min) / N; % Bandwidth of each filter

    bandpassFilters = cell(N, 1);
    for i = 1:N
        % Round values to avoid any precision issues
        f_low = round(f_min + (i - 1) * bandwidth);
        f_high = round(f_low + bandwidth);

        % Ensure f_high is within valid bounds and below Nyquist limit
        if f_high >= fs / 2
            f_high = round(fs / 2 - 1); % Set f_high to be safely below Nyquist frequency
        end

        % Design bandpass filter manually (using butter as a simple approximation)
        [b, a] = butter(4, [f_low, f_high] / (fs / 2), 'bandpass');
        bandpassFilters{i} = {b, a};
    end

    % Task 5: Filter the input signal using each bandpass filter
    filteredSignals = cell(N, 1);
    for i = 1:N
        [b, a] = bandpassFilters{i}{:};
        filteredSignals{i} = filter(b, a, inputSignal);
    end

    % Task 6: Plot the output signals of the lowest and highest frequency channels
    figure;
    subplot(2, 1, 1);
    plot(filteredSignals{1});
    title('Output of the Lowest Frequency Channel');
    xlabel('Sample Number');
    ylabel('Amplitude');

    subplot(2, 1, 2);
    plot(filteredSignals{N});
    title('Output of the Highest Frequency Channel');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Task 7: Rectify the output signals
    rectifiedSignals = cell(N, 1);
    for i = 1:N
        rectifiedSignals{i} = abs(filteredSignals{i});
    end

    % Task 8: Implement manual envelope extraction using a simple FIR lowpass filter
    % Design a lowpass filter manually (e.g., a moving average filter)
    cutoff_freq = 400; % 400 Hz cutoff frequency
    windowSize = round(fs / cutoff_freq); % Window size based on cutoff frequency
    lowpassKernel = ones(1, windowSize) / windowSize; % Simple moving average filter

    envelopes = cell(N, 1);
    for i = 1:N
        envelopes{i} = filter(lowpassKernel, 1, rectifiedSignals{i});
    end

    % Plot the extracted envelopes of the lowest and highest frequency channels
    figure;
    subplot(2, 1, 1);
    plot(envelopes{1});
    title('Envelope of the Lowest Frequency Channel');
    xlabel('Sample Number');
    ylabel('Amplitude');

    subplot(2, 1, 2);
    plot(envelopes{N});
    title('Envelope of the Highest Frequency Channel');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Save the filtered signals to the processed folder
    for i = 1:N
        outputFilePath = fullfile(processedFolder, [fileName '_filtered_channel_' num2str(i) ext]);
        audiowrite(outputFilePath, filteredSignals{i}, fs);
    end
end
