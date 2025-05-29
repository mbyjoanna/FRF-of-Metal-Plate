% File names
filenames = {'htest41.xlsx', 'htest40.xlsx', 'htest42.xlsx'};

% Sampling frequency
fs = 44000;

% Number of peaks to detect
Npeaks = 5;

% Frequency range to display (0 to 1000 Hz)
freq_limit = 1000;

% Create figure
figure;
hold on;

% Initialize matrix to store peaks
allPeakFreqs = zeros(length(filenames), Npeaks);

% Process each file
for k = 1:length(filenames)
    % Read the table from the current file
    T = readtable(filenames{k});
    
    % Assuming the signal is in column 2
    signal = T{:, 2};
    
    % Remove NaNs
    signal = signal(~isnan(signal));
    
    % FFT
    N = length(signal);
    t = (0:N-1)/fs;
    Y = fft(signal);
    f = (0:N-1)*(fs/N);
    
    % Use only positive frequencies
    halfIdx = 1:floor(N/2);
    Y_half = abs(Y(halfIdx));
    f_half = f(halfIdx);
    
    % Normalize magnitude
    Y_half = Y_half / max(Y_half);
    
    % Limit frequency range
    freqIdx = f_half <= freq_limit;
    f_half = f_half(freqIdx);
    Y_half = Y_half(freqIdx);
    
    % Plot the FFT
    plot(f_half, Y_half, 'DisplayName', filenames{k});
    
    % --- Peak Detection ---
    [peakValsAll, peakLocsAll] = findpeaks(Y_half, f_half, 'MinPeakProminence', 0.1);
    
    % Get top N most prominent peaks
    [peakVals, idx] = maxk(peakValsAll, Npeaks);
    peakLocs = peakLocsAll(idx);
    
    % Store for averaging later
    allPeakFreqs(k, :) = sort(peakLocs);  % Sort so 1st peak is always lowest freq, etc.
    
    % Plot peaks
    plot(peakLocs, peakVals, 'ro', 'MarkerFaceColor', 'r');
    text(peakLocs, peakVals, sprintfc('%.1f Hz', peakLocs), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% Average and standard deviation of peak positions
avgPeaks = mean(allPeakFreqs, 1);
stdPeaks = std(allPeakFreqs, 0, 1);

% Display results
fprintf('Average Peak Frequencies with Standard Deviations (Location 5 with Hole):\n');
for i = 1:Npeaks
    fprintf('Peak %d: %.2f Hz ± %.2f Hz\n', i, avgPeaks(i), stdPeaks(i));
end

% Labels and final touches
title('FFT of Signals at Location 5 with Hole');
xlabel('Frequency (Hz)');
ylabel('Normalized Magnitude');
xlim([0 freq_limit]);
legend('show');
grid on;
hold off;
