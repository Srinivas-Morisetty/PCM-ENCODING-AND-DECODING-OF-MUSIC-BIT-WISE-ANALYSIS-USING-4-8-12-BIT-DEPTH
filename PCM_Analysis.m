function pcm_music_analysis()
    % PCM Encoding & Decoding of Music Signal Analysis
    % This function performs quantization analysis on user's audio file
    
    clc;clear;close all;
    
    % Get user input for audio file
    [filename, pathname] = uigetfile({'*.wav;*.mp3;*.m4a', 'Audio Files (*.wav, *.mp3, *.m4a)'}, ...
        'Select an audio file');
    
    if isequal(filename, 0)
        disp('No file selected. Using default sample.');
        % Create a sample signal if no file is selected
        fs = 8000; % Sampling frequency
        t = 0:1/fs:2; % 2 seconds
        original_signal = sin(2*pi*440*t) + 0.5*sin(2*pi*880*t); % A4 + A5 notes
    else
        % Read the audio file
        filepath = fullfile(pathname, filename);
        [original_signal, fs] = audioread(filepath);
        
        % Convert to mono if stereo
        if size(original_signal, 2) > 1
            original_signal = mean(original_signal, 2);
        end
        
        % Use the full signal (no truncation)
        original_signal = original_signal(:); 
        
        % Normalize signal
        original_signal = original_signal / max(abs(original_signal));
    end
    
    % Time vector
    t = (0:length(original_signal)-1) / fs;
    
    % Standalone figure for Original Signal
    figure('Position', [200, 200, 1200, 400]);
    plot(t, original_signal, 'b', 'LineWidth', 1.2);
    title('Original Audio Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
    
    % Quantization levels
    bit_levels = [4, 8, 12];
    
    % Initialize results storage
    results = struct();
    
    % Create figure for summary plots
    figure('Position', [100, 100, 1400, 1000]);
    
    % Plot 1: Original Signal (in summary figure)
    subplot(4, 4, 1);
    plot(t, original_signal, 'b', 'LineWidth', 1.5);
    title('Original Signal', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on; axis tight;
    
    % Initialize table data
    table_data = [];
    
    % Loop over different bit depths
    for i = 1:length(bit_levels)
        bits = bit_levels(i);
        
        % PCM Encoding & Decoding
        [quantized_signal, reconstructed_signal, quantization_levels, step_size, ...
         transmitted_samples, snr_db, mse, psnr_db, thd_percent] = ...
         pcm_encode_decode(original_signal, bits);
        
        % Store results
        results.(sprintf('bits_%d', bits)).quantized = quantized_signal;
        results.(sprintf('bits_%d', bits)).reconstructed = reconstructed_signal;
        results.(sprintf('bits_%d', bits)).snr = snr_db;
        results.(sprintf('bits_%d', bits)).mse = mse;
        results.(sprintf('bits_%d', bits)).psnr = psnr_db;
        results.(sprintf('bits_%d', bits)).thd = thd_percent;
        
        % Add to table data
        table_data = [table_data; bits, quantization_levels, step_size, ...
                      snr_db, mse, psnr_db, thd_percent];
        
        % === Print results to Command Window ===
        fprintf('\n=== %d-bit Quantization Results ===\n', bits);
        fprintf('Quantization Levels : %d\n', quantization_levels);
        fprintf('Step Size           : %.6f\n', step_size);
        fprintf('SNR (dB)            : %.4f\n', snr_db);
        fprintf('MSE                 : %.6e\n', mse);
        fprintf('PSNR (dB)           : %.4f\n', psnr_db);
        fprintf('THD (%%)             : %.4f\n', thd_percent);
        fprintf('-----------------------------------\n');
        
        % Plot quantized vs original
        subplot(4, 4, 1+i);
        plot(t, original_signal, 'b-', 'LineWidth', 1, 'DisplayName', 'Original');
        hold on;
        plot(t, quantized_signal, 'r-', 'LineWidth', 1, 'DisplayName', 'Quantized');
        title(sprintf('%d-bit Quantization', bits), 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Time (s)'); ylabel('Amplitude'); legend('show');
        grid on; axis tight;
        
        % Plot transmitted samples (first 200 samples for clarity)
        subplot(4, 4, 5+i);
        n_samples = min(200, length(transmitted_samples));
        stem(1:n_samples, transmitted_samples(1:n_samples), 'g', 'MarkerSize', 3);
        title(sprintf('%d-bit Transmitted Samples', bits), 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Sample Index'); ylabel('Digital Value');
        grid on;
        
        % Plot reconstruction comparison
        subplot(4, 4, 9+i);
        plot(t, original_signal, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Original');
        hold on;
        plot(t, reconstructed_signal, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Reconstructed');
        title(sprintf('%d-bit Reconstruction (SNR: %.2f dB)', bits, snr_db), ...
              'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Time (s)'); ylabel('Amplitude'); legend('show');
        grid on; axis tight;
        
        % Plot quantization error
        subplot(4, 4, 13+i);
        error_signal = original_signal - reconstructed_signal;
        plot(t, error_signal, 'm', 'LineWidth', 1);
        title(sprintf('%d-bit Quantization Error', bits), 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Time (s)'); ylabel('Error Amplitude');
        grid on; axis tight;
        
        % Save reconstructed audio file
        if ~isequal(filename, 0)
            [~, name, ~] = fileparts(filename);
            output_filename = sprintf('%s_%dbit_reconstructed.wav', name, bits);
            audiowrite(output_filename, reconstructed_signal, fs);
            fprintf('Saved: %s\n', output_filename);
        end
    end
    
    % Detailed figures for each bit level
    plot_detailed_results(4, t, original_signal, results);
    plot_detailed_results(8, t, original_signal, results);
    plot_detailed_results(12, t, original_signal, results);
    
    % === Print summary table at the end ===
    fprintf('\n=== Summary Table ===\n');
    Summary = array2table(table_data, ...
        'VariableNames', {'Bits', 'Levels', 'Step_Size', 'SNR_dB', 'MSE', 'PSNR_dB', 'THD_percent'});
    disp(Summary);
end

% ----------------------------------------------------
% Helper function for detailed figures per bit level
% ----------------------------------------------------
function plot_detailed_results(bits, t, original_signal, results)
    figure('Position', [200, 200, 1200, 800]);
    
    % Original vs Reconstructed
    subplot(2,2,1);
    plot(t, original_signal, 'b', 'LineWidth', 1.2); hold on;
    plot(t, results.(sprintf('bits_%d', bits)).reconstructed, 'r--', 'LineWidth', 1.2);
    title(sprintf('Original vs %d-bit Reconstructed', bits));
    legend('Original', sprintf('%d-bit', bits));
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
    
    % Transmitted Samples (first 200)
    subplot(2,2,2);
    stem(results.(sprintf('bits_%d', bits)).quantized(1:200), 'g', 'MarkerSize', 3);
    title(sprintf('%d-bit Transmitted Samples (First 200)', bits));
    xlabel('Sample Index'); ylabel('Quantized Value'); grid on;
    
    % Error waveform
    subplot(2,2,3);
    plot(t, original_signal - results.(sprintf('bits_%d', bits)).reconstructed, 'm');
    title(sprintf('%d-bit Quantization Error', bits));
    xlabel('Time (s)'); ylabel('Error Amplitude'); grid on;
    
    % Error histogram
    subplot(2,2,4);
    histogram(original_signal - results.(sprintf('bits_%d', bits)).reconstructed, 50, 'FaceColor','c');
    title(sprintf('Histogram of %d-bit Quantization Error', bits));
    xlabel('Error Amplitude'); ylabel('Count'); grid on;
end

% ----------------------------------------------------
% PCM Encode/Decode function
% ----------------------------------------------------
function [quantized_signal, reconstructed_signal, quantization_levels, step_size, ...
          transmitted_samples, snr_db, mse, psnr_db, thd_percent] = pcm_encode_decode(signal, bits)
    
    % Number of quantization levels
    quantization_levels = 2^bits;
    
    % Find signal range
    signal_min = min(signal);
    signal_max = max(signal);
    signal_range = signal_max - signal_min;
    
    % Step size
    step_size = signal_range / (quantization_levels - 1);
    
    % Quantization (Encoding)
    normalized_signal = (signal - signal_min) / signal_range * (quantization_levels - 1);
    quantized_indices = round(normalized_signal);
    quantized_indices = max(0, min(quantization_levels - 1, quantized_indices));
    
    % Quantized signal
    quantized_signal = quantized_indices / (quantization_levels - 1) * signal_range + signal_min;
    
    % Transmitted samples (digital values)
    transmitted_samples = quantized_indices;
    
    % Reconstruction
    reconstructed_signal = quantized_signal;
    
    % Metrics
    signal_power = mean(signal.^2);
    noise_power = mean((signal - reconstructed_signal).^2);
    if noise_power == 0
        snr_db = Inf;
    else
        snr_db = 10 * log10(signal_power / noise_power);
    end
    
    mse = mean((signal - reconstructed_signal).^2);
    max_signal = max(abs(signal));
    if mse == 0
        psnr_db = Inf;
    else
        psnr_db = 20 * log10(max_signal) - 10 * log10(mse);
    end
    
    fundamental_power = signal_power;
    distortion_power = noise_power;
    if fundamental_power == 0
        thd_percent = 0;
    else
        thd_percent = 100 * sqrt(distortion_power / fundamental_power);
    end
end
