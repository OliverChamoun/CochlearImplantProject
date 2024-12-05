% This codes works best with lower number of channels (eg.8)

function Lower_freq(filePath, processedFolder, N)
    % Function to process sound files for Phase 3 of the cochlear implant project
    % Input: filePath - path to the sound file
    %        processedFolder - folder to save processed files
    %        N - number of bandpass filter channels

    % Read the input sound file
    [inputSignal, fs] = audioread(filePath);

    % Ensure the signal is mono
    if size(inputSignal, 2) == 2
        inputSignal = sum(inputSignal, 2) / 2; % Convert stereo to mono
    end

    % Replace any non-finite values in input signal
    inputSignal(~isfinite(inputSignal)) = 0;

    % Plot the sound waveform as a function of sample number
    figure;
    plot(inputSignal);
    title('Waveform of the Original Sound Signal');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Resample if the sampling rate is not 16 kHz
    if fs ~= 16000
        inputSignal = resample(inputSignal, 16000, fs);
        fs = 16000; % Update the sampling rate
    end

    % Define bandpass filter parameters using logarithmic spacing
    f_min = 100; % Minimum frequency
    f_max = min(8000, fs / 2 - 200); % Ensure f_max is below Nyquist frequency
    centerFrequencies = logspace(log10(f_min), log10(f_max), N); % Logarithmic spacing of center frequencies

    % Design bandpass filters
    bandpassFilters = cell(N, 1);
    for i = 1:N
        if i == 1
            f_low = f_min;
        else
            f_low = sqrt(centerFrequencies(i-1) * centerFrequencies(i)); % Geometric mean for smoother transition
        end
        if i == N
            f_high = f_max;
        else
            f_high = sqrt(centerFrequencies(i) * centerFrequencies(i+1)); % Geometric mean for smoother transition
        end

        % Ensure filter parameters are within valid bounds
        if f_low < 0
            f_low = 0;
        end
        if f_high > fs / 2
            f_high = fs / 2 - 1;
        end

        [b, a] = butter(4, [f_low, f_high] / (fs / 2), 'bandpass');
        bandpassFilters{i} = {b, a};
    end

    % Filter the input signal using each bandpass filter
    filteredSignals = cell(N, 1);
    for i = 1:N
        [b, a] = bandpassFilters{i}{:};
        filteredSignals{i} = filter(b, a, inputSignal);
        % Replace any non-finite values in filtered signal
        filteredSignals{i}(~isfinite(filteredSignals{i})) = 0;
    end

    % Plot the output signals of the lowest and highest frequency channels
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

    % Rectify the filtered signals
    rectifiedSignals = cell(N, 1);
    for i = 1:N
        rectifiedSignals{i} = abs(filteredSignals{i});
    end

    % Implement manual envelope extraction using a simple FIR lowpass filter
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

    % Task 10: Generate cosine signal for each channel
    cosSignals = cell(N, 1);
    for i = 1:N
        t = (0:length(rectifiedSignals{i})-1)' / fs;
        cosSignals{i} = cos(2 * pi * centerFrequencies(i) * t);
    end

    % Task 11: Amplitude modulate each cosine signal with the rectified signal
    modulatedSignals = cell(N, 1);
    for i = 1:N
        modulatedSignals{i} = rectifiedSignals{i} .* cosSignals{i};
    end

    % Task 12: Add all modulated signals together and normalize
    outputSignal = sum(cat(2, modulatedSignals{:}), 2);
    maxVal = max(abs(outputSignal));
    if maxVal > 0
        outputSignal = outputSignal / maxVal; % Normalize by the maximum of its absolute value
    else
        outputSignal = zeros(size(outputSignal)); % If max is zero, set outputSignal to all zeros
    end

    % Task 13: Play the output sound and write to a new file
    sound(outputSignal, fs);
    %pause(length(inputSignal) / fs); % Wait for the sound to finish playing
    [~, fileName, ext] = fileparts(filePath);
    outputFilePath = fullfile(processedFolder, [fileName '_phase3_processed' ext]);
    audiowrite(outputFilePath, outputSignal, fs);

    % Evaluation Metrics for Quality Assessment
    % Use the original input signal as the reference signal for comparison
    referenceSignal = inputSignal;

    % Convert both signals to double explicitly
    referenceSignal = double(referenceSignal);
    outputSignal = double(outputSignal);

    % Ensure both signals are the same length by truncating the longer signal
    minLength = min(length(referenceSignal), length(outputSignal));
    referenceSignal = referenceSignal(1:minLength);
    outputSignal = outputSignal(1:minLength);

    % Ensure both signals are column vectors
    if size(referenceSignal, 2) > size(referenceSignal, 1)
        referenceSignal = referenceSignal';
    end
    if size(outputSignal, 2) > size(outputSignal, 1)
        outputSignal = outputSignal';
    end

    % STOI Evaluation: Measures intelligibility of speech (values range between 0 and 1)
    try
        stoiScore = stoi(referenceSignal, outputSignal, fs);
        %adjustedStoiScore = (stoiScore - 0.4) / 0.6; % Normalizing as per instructions
        fprintf('%s, STOI Score: %.2f,', fileName, stoiScore);
    catch ME
        fprintf('Error calculating STOI for %s: %s ', fileName, ME.message);
    end

    % Alternative Evaluation: Cross-Correlation for Similarity Assessment
    try
        [correlation, lag] = xcorr(referenceSignal, outputSignal);
        [maxCorr, idx] = max(abs(correlation));
        timeLag = lag(idx) / fs; % Time lag in seconds
        fprintf('Cross-Correlation: Maximum Correlation = %.2f, Time Lag = %.4f seconds\n', maxCorr, timeLag);
    catch ME
        fprintf('Error calculating Cross-Correlation for %s: %s ', fileName, ME.message);
    end
end