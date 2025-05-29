% List of files (use full path if needed)
files = { '5hrobotfft_1.xlsx', '5hrobotfft.xlsx', '5hrobotfft_2.xlsx' };

% Sampling settings
fs = 44000; % Sampling frequency (Hz)
duration = 2; % seconds
n_samples = [];
freq_axis = [];

% Create a figure
figure;
hold on;

colors = ['r', 'g', 'b'];

% Store peaks for averaging
all_peaks = zeros(length(files), 5);
all_peak_freqs = zeros(length(files), 5);

for i = 1:length(files)
    % Read the data
    data = readtable(files{i});
    data = table2array(data);

    % Create frequency axis
    if isempty(n_samples)
        n_samples = length(data);
        freq_axis = linspace(0, fs/2, n_samples);
    end
    
    % Plot the FFT data
    plot(freq_axis, data, 'Color', colors(i), 'DisplayName', sprintf('File %d', i));
    
    % Find peaks
    [pks, locs] = findpeaks(data, 'SortStr', 'descend');
    
    % Take the top 5 peaks
    top5_pks = pks(1:min(5, end));
    top5_locs = locs(1:min(5, end));
    
    % Save peaks and frequencies for averaging
    all_peaks(i, 1:length(top5_pks)) = top5_pks;
    all_peak_freqs(i, 1:length(top5_locs)) = freq_axis(top5_locs);
    
    % Display peak info
    fprintf('Top 5 peaks for file %d (%s):\n', i, files{i});
    for j = 1:length(top5_pks)
        fprintf('Peak %d: Frequency = %.2f Hz, Amplitude = %.4f\n', ...
                j, freq_axis(top5_locs(j)), top5_pks(j));
    end
    fprintf('\n');
end

% After looping through files:
% Calculate average peak amplitudes and frequencies
avg_peak_amplitudes = mean(all_peaks, 1);
avg_peak_frequencies = mean(all_peak_freqs, 1);

% Calculate standard deviation of peak frequencies
std_peak_frequencies = std(all_peak_freqs, 0, 1);  % 0 means normalize by N-1 (sample std)

fprintf('--- Average and Standard Deviation of Peaks Across All Files ---\n');
for j = 1:5
    fprintf('Peak %d: Average Frequency = %.2f Hz, Amplitude = %.4f, Std Dev Frequency = %.4f Hz\n', ...
            j, avg_peak_frequencies(j), avg_peak_amplitudes(j), std_peak_frequencies(j));
end

xlabel('Frequency (Hz)');
ylabel('FFT (RMS)');
title('FFT Comparison of Robot Data with Top 5 Peaks');
legend('show');
grid on;
xlim([0 fs/2]);
hold off;
