clc; clear; close all;
[filename,pathname]=uigetfile('*.*','Select the ecg signal');
filewithpath=strcat(pathname,filename);


% Set sampling frequency (Hz)
Fs = 360;

% Load ECG signal from MAT file
ecg = load(filename);

% Extract ECG signal and convert to millivolts
ecg_sig = (ecg.val) ./ 200;

% Create time index vector
t = 1:length(ecg_sig);

% Convert time index to seconds
tx = t ./ Fs;

% Perform MODWT on ECG signal with 4-level decomposition using 'sym4' wavelet
wt = modwt(ecg_sig, 4, 'sym4');

% Initialize matrix to store modified wavelet coefficients
wtrec = zeros(size(wt));

% Copy third and fourth level wavelet coefficients to wtrec
wtrec(3:4, :) = wt(3:4, :);

% Reconstruct signal from modified wavelet coefficients
y = imodwt(wtrec, 'sym4');

% Compute squared magnitude of reconstructed signal
y = abs(y).^2;

% Calculate average squared magnitude
avg = mean(y);

% Detect R-peaks in the signal
[Rpeaks, locs] = findpeaks(y, t, 'MinPeakHeight', 8 * avg, 'MinPeakDistance', 50);

% Count number of detected R-peaks (heartbeats)
nohb = length(locs);


% Calculate signal duration in seconds
timelimit = length(ecg_sig) / Fs;

% Calculate heart rate in beats per minute
hbpermin = (nohb * 60) / timelimit;

% Display calculated heart rate
disp(strcat('Heart Rate=', num2str(hbpermin)))

% Plot ECG signal
subplot(211);
plot(tx, ecg_sig);
xlim([0, timelimit]);
grid on;
xlabel('Seconds');
title('ECG signal');

% Plot squared magnitude signal with detected R-peaks
subplot(212);
plot(t, y);
xlim([0, length(ecg_sig)]);
hold on;
plot(locs, Rpeaks, 'r');
xlabel('Samples');
title(strcat('R-peaks found and heart rate:', num2str(hbpermin)));
