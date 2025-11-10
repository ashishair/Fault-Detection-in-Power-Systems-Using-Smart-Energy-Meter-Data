% Load data from Excel file (TRANSPOSED structure with mixed data types)
filename = 'Fault data laterite.xlsx';

% Read the entire file WITHOUT automatic header detection
opts = detectImportOptions(filename, 'FileType', 'spreadsheet');
opts.DataRange = '1:4';  % Only read first 4 rows (header + 3 phases)
data_table = readtable(filename, opts, 'ReadVariableNames', false);

% Convert to cell array to handle mixed types
data_cell = table2cell(data_table);

% Extract data (first column has labels, skip it)
t_full = cell2mat(data_cell(1, 2:end))';           % Time vector (numeric)
phaseA = cell2mat(data_cell(2, 2:end))';           % Phase A data (numeric)
phaseB = cell2mat(data_cell(3, 2:end))';           % Phase B data (numeric)
phaseC = cell2mat(data_cell(4, 2:end))';           % Phase C data (numeric)

% Display loaded data info
fprintf('=== Data Loaded Successfully ===\n');
fprintf('Number of samples: %d\n', length(t_full));
fprintf('Time range: %.4f s to %.4f s\n', t_full(1), t_full(end));
fprintf('Phase A range: %.2f to %.2f\n', min(phaseA), max(phaseA));
fprintf('Phase B range: %.2f to %.2f\n', min(phaseB), max(phaseB));
fprintf('Phase C range: %.2f to %.2f\n', min(phaseC), max(phaseC));
fprintf('\n');

% Parameters
Ts = 0.0005;           % Sampling period (0.5 ms)
Fs = 1/Ts;             % Sampling frequency (2000 Hz)
win_duration = 0.1;    % Window duration: 100 ms
step_duration = 0.001; % Step size: 1 ms

win_samples = 200;     % Window size: 200 samples (100 ms)
step_samples = 2;      % Step size: 2 samples (1 ms)

% Calculate number of windows
N_total = length(phaseA);
N_windows = floor((N_total - win_samples) / step_samples) + 1;

fprintf('=== ROLLING WINDOW FFT ANALYSIS CONFIGURATION ===\n');
fprintf('Total data points: %d\n', N_total);
fprintf('Window size: %d samples (%.1f ms)\n', win_samples, win_samples * Ts * 1000);
fprintf('Step size: %d samples (%.1f ms)\n', step_samples, step_samples * Ts * 1000);
fprintf('Total windows to process: %d\n\n', N_windows);

% Fundamental frequency and harmonics
f0 = 50;               % Fundamental frequency (Hz)
harmonics = 1:9;       % Harmonics 1-9

% Preallocate matrices to store harmonic magnitudes over time
harm_A = zeros(N_windows, 9);  % Phase A harmonics
harm_B = zeros(N_windows, 9);  % Phase B harmonics
harm_C = zeros(N_windows, 9);  % Phase C harmonics
window_centers = zeros(N_windows, 1); % Time of window centers

% Perform rolling FFT analysis
fprintf('Processing rolling windows...\n');

for w = 1:N_windows
    % Extract window indices
    start_idx = (w-1) * step_samples + 1;
    end_idx = start_idx + win_samples - 1;
    
    % Extract windowed data
    win_A = phaseA(start_idx:end_idx);
    win_B = phaseB(start_idx:end_idx);
    win_C = phaseC(start_idx:end_idx);
    
    % Store center time of window
    window_centers(w) = t_full(start_idx + floor(win_samples/2));
    
    % Perform FFT on each phase
    FFT_A = fft(win_A);
    FFT_B = fft(win_B);
    FFT_C = fft(win_C);
    
    % Normalize (single-sided spectrum)
    L = win_samples;
    mag_A = abs(FFT_A/L);
    mag_B = abs(FFT_B/L);
    mag_C = abs(FFT_C/L);
    
    % Double magnitude for positive frequencies (except DC and Nyquist)
    mag_A(2:end-1) = 2*mag_A(2:end-1);
    mag_B(2:end-1) = 2*mag_B(2:end-1);
    mag_C(2:end-1) = 2*mag_C(2:end-1);
    
    % Create frequency vector for this window
    f = Fs*(0:(L/2))/L;
    
    % Extract harmonic magnitudes (1st to 9th)
    for h = 1:9
        target_freq = h * f0;  % Target harmonic frequency
        [~, freq_idx] = min(abs(f - target_freq)); % Find closest index
        
        harm_A(w, h) = mag_A(freq_idx);
        harm_B(w, h) = mag_B(freq_idx);
        harm_C(w, h) = mag_C(freq_idx);
    end
    
    % Progress indicator
    if mod(w, 100) == 0 || w == N_windows
        fprintf('  Processed %d/%d windows (%.1f%%)\n', w, N_windows, 100*w/N_windows);
    end
end

fprintf('\nFFT analysis complete!\n\n');

%% ========== PLOT 1: 1st Harmonic (Fundamental 50 Hz) - ALL PHASES ==========
figure('Position', [100, 100, 1200, 600], 'Name', '1st Harmonic (50 Hz) - All Phases');

plot(window_centers, harm_A(:,1), 'r-', 'LineWidth', 2, 'DisplayName', 'Phase A'); 
hold on;
plot(window_centers, harm_B(:,1), 'g-', 'LineWidth', 2, 'DisplayName', 'Phase B');
plot(window_centers, harm_C(:,1), 'b-', 'LineWidth', 2, 'DisplayName', 'Phase C'); 
hold off;

xlabel('Time (s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Magnitude', 'FontSize', 12, 'FontWeight', 'bold');
title('1st Harmonic (50 Hz) Evolution Over Time - All 3 Phases', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
grid on;
grid minor;

%% ========== PLOTS 2-10: Individual Harmonics (2nd-9th) ==========
for h = 2:9
    figure('Position', [100 + (h-2)*30, 100 + (h-2)*30, 1200, 800], ...
           'Name', sprintf('%dth Harmonic (%d Hz) - All Phases', h, h*f0));
    
    % Phase A
    subplot(3,1,1);
    plot(window_centers, harm_A(:,h), 'r-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 11);
    ylabel('Magnitude', 'FontSize', 11);
    title(sprintf('Phase A - %dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 12, 'FontWeight', 'bold');
    grid on; grid minor;
    
    % Phase B
    subplot(3,1,2);
    plot(window_centers, harm_B(:,h), 'g-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 11);
    ylabel('Magnitude', 'FontSize', 11);
    title(sprintf('Phase B - %dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 12, 'FontWeight', 'bold');
    grid on; grid minor;
    
    % Phase C
    subplot(3,1,3);
    plot(window_centers, harm_C(:,h), 'b-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 11);
    ylabel('Magnitude', 'FontSize', 11);
    title(sprintf('Phase C - %dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 12, 'FontWeight', 'bold');
    grid on; grid minor;
end

%% ========== PLOT 11: Combined View - All Harmonics (1st-9th) Phase A ==========
figure('Position', [100, 100, 1400, 900], 'Name', 'All Harmonics (1st-9th) - Phase A');

for h = 1:9
    subplot(3,3,h);
    plot(window_centers, harm_A(:,h), 'r-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 10);
    ylabel('Magnitude', 'FontSize', 10);
    title(sprintf('%dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 11, 'FontWeight', 'bold');
    grid on; grid minor;
end

sgtitle('Phase A: Harmonics 1st-9th Evolution Over Time', 'FontSize', 14, 'FontWeight', 'bold');

%% ========== PLOT 12: Combined View - All Harmonics (1st-9th) Phase B ==========
figure('Position', [150, 150, 1400, 900], 'Name', 'All Harmonics (1st-9th) - Phase B');

for h = 1:9
    subplot(3,3,h);
    plot(window_centers, harm_B(:,h), 'g-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 10);
    ylabel('Magnitude', 'FontSize', 10);
    title(sprintf('%dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 11, 'FontWeight', 'bold');
    grid on; grid minor;
end

sgtitle('Phase B: Harmonics 1st-9th Evolution Over Time', 'FontSize', 14, 'FontWeight', 'bold');

%% ========== PLOT 13: Combined View - All Harmonics (1st-9th) Phase C ==========
figure('Position', [200, 200, 1400, 900], 'Name', 'All Harmonics (1st-9th) - Phase C');

for h = 1:9
    subplot(3,3,h);
    plot(window_centers, harm_C(:,h), 'b-', 'LineWidth', 1.5);
    xlabel('Time (s)', 'FontSize', 10);
    ylabel('Magnitude', 'FontSize', 10);
    title(sprintf('%dth Harmonic (%d Hz)', h, h*f0), 'FontSize', 11, 'FontWeight', 'bold');
    grid on; grid minor;
end

sgtitle('Phase C: Harmonics 1st-9th Evolution Over Time', 'FontSize', 14, 'FontWeight', 'bold');

%% ========== SUMMARY STATISTICS ==========
fprintf('\n=== HARMONIC ANALYSIS SUMMARY ===\n');
fprintf('Window duration: %.1f ms\n', win_duration*1000);
fprintf('Step size: %.1f ms\n', step_duration*1000);
fprintf('Total windows analyzed: %d\n', N_windows);
fprintf('Time range: %.4f s to %.4f s\n', window_centers(1), window_centers(end));
fprintf('\n');

for h = 1:9
    fprintf('--- %dth Harmonic (%d Hz) ---\n', h, h*f0);
    fprintf('Phase A: Mean=%.6f | Max=%.6f | Min=%.6f\n', ...
            mean(harm_A(:,h)), max(harm_A(:,h)), min(harm_A(:,h)));
    fprintf('Phase B: Mean=%.6f | Max=%.6f | Min=%.6f\n', ...
            mean(harm_B(:,h)), max(harm_B(:,h)), min(harm_B(:,h)));
    fprintf('Phase C: Mean=%.6f | Max=%.6f | Min=%.6f\n', ...
            mean(harm_C(:,h)), max(harm_C(:,h)), min(harm_C(:,h)));
    fprintf('\n');
end

fprintf('All plots generated successfully!\n');
