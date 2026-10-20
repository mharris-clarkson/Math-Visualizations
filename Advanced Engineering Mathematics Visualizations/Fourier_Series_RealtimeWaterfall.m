function Fourier_Series_RealtimeWaterfall()
%% Real-Time Audio FFT Waterfall
% Streams audio from the default input device and displays a live
% spectrogram ("waterfall") alongside the raw waveform. Buttons toggle
% the waterfall's frequency range and show/hide the waveform plot (which
% starts hidden).
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math/audio objects
fs        = 44100;   % sample rate (Hz)
fftSize   = 4096;     % FFT length
hop       = 512;      % samples read per loop
windowSec = 20;       % waterfall history shown (s)
fullMaxHz = 20000;    % full-range upper frequency limit
zoomMaxHz = 1000;     % zoomed upper frequency limit
dispRate  = 30;       % max display refresh (frames/s)
colDecim  = 3;        % audio frames merged into one waterfall column

In_CAMP177 = false; % boost the output for a bad mic

showWaveform0 = false;   % bottom (waveform) plot starts hidden

%% ==== Below this we build the UI, compute math, and wire up controls ====

%% Precompute derived quantities and buffers
dt      = hop/fs;
colDt   = dt*colDecim;                          % seconds per waterfall column
history = ceil(windowSec/colDt);
binHz   = fs/fftSize;
nBins   = floor(fullMaxHz/binHz) + 1;           % only keep bins up to fullMaxHz

reader     = audioDeviceReader('SampleRate', fs, 'SamplesPerFrame', hop);
cleanupObj = onCleanup(@() release(reader));

buffer        = zeros(fftSize, 1);
waterfallData = -120*ones(nBins, history, 'single');
w             = hann(fftSize);
winGain       = sum(w)/2;          % so a full-scale sine reads 0 dB
histIdx       = 1;                 % next column to write (circular)
pending       = -120*ones(nBins, 1, 'single');   % max-hold within a column
frameCount    = 0;
order         = [1:history, 1:history];          % reused for display reordering

f        = (0:nBins-1) * binHz;
timeAxis = linspace(-windowSec, 0, history);   % seconds before "now"
sampleT  = ((-fftSize+1):0) / fs;              % waveform time axis (s)

%% Load libraries
run('setup.m')

%% Build an applet that holds the figure and both subplots
app = uiFigure('Real Time Audio Waterfall', 2, 'Col');
axW = app.ax(1);
axS = app.ax(2);

%% Initial plots
hWater = imagesc(axW, timeAxis, f, waterfallData);
set(axW, 'YDir', 'normal', 'YLim', [0 fullMaxHz], 'XLim', [-windowSec 0], ...
    'CLim', [-80 -10], 'FontSize', 14);
colormap(axW, 'hot');
colorbar(axW);
xlabel(axW, 'Time (s)');
ylabel(axW, 'Frequency (Hz)');
title(axW, 'Real Time Audio Waterfall (dB)');

hSample = plot(axS, sampleT, zeros(fftSize, 1));
set(axS, 'XLim', [sampleT(1) 0], 'YLim', [-1 1], 'FontSize', 14);
xlabel(axS, 'Time (s)');
ylabel(axS, 'Amplitude');
title(axS, 'Real Time Audio');

%% Build UI
NumControls = 2;
btnFreq = app.addControl('button', 'Show 0-1000 Hz', 1, NumControls, @onFreqToggle, ...
    'ColorChange', true, 'colOrRow', 'row');
btnWave = app.addControl('button', 'Hide Waveform', 2, NumControls, @onWaveToggle, ...
    'ColorChange', true, 'colOrRow', 'row');

% Capture the subplot positions now that uiFigure has finished laying out
% the axes around both buttons, and compute the "waterfall only" position
% by extending the waterfall plot down to the bottom of the waveform plot.
posWaterWithWave = axW.Position;
posWave          = axS.Position;
posWaterNoWave   = [posWaterWithWave(1), posWave(2), ...
    posWaterWithWave(3), sum(posWaterWithWave([2 4])) - posWave(2)];

% Waveform plot starts hidden, per showWaveform0.
if ~showWaveform0
    btnWave.Value  = 1;
    btnWave.String = 'Show Waveform';
    set(axS, 'Visible', 'off')
    set(hSample, 'Visible', 'off')
    axW.Position = posWaterNoWave;
end

%% Callbacks
    function onFreqToggle(~, ~)
        if logical(btnFreq.Value)
            set(axW, 'YLim', [0 zoomMaxHz])
            btnFreq.String = 'Show Full Range';
        else
            set(axW, 'YLim', [0 fullMaxHz])
            btnFreq.String = 'Show 0-1000 Hz';
        end
    end

    function onWaveToggle(~, ~)
        if logical(btnWave.Value)
            set(axS, 'Visible', 'off')
            set(hSample, 'Visible', 'off')
            axW.Position = posWaterNoWave;
            btnWave.String = 'Show Waveform';
        else
            set(axS, 'Visible', 'on')
            set(hSample, 'Visible', 'on')
            axW.Position = posWaterWithWave;
            btnWave.String = 'Hide Waveform';
        end
    end


%% Main loop (runs until the figure is closed)
lastDraw = tic;
while ishandle(app.fig)
    newAudio = reader();

    % Slide the audio buffer (cheap: fftSize samples).
    buffer = [buffer(hop+1:end); newAudio(:,1)];

    % FFT -> dBFS, with max-hold accumulated into the pending column.
    Y       = fft(buffer .* w);
    if In_CAMP177
        Y = 100*Y;
    end
    mag     = abs(Y(1:nBins)) / winGain;
    pending = max(pending, single(20*log10(mag + 1e-6)));

    % Commit one waterfall column every colDecim frames.
    frameCount = frameCount + 1;
    if mod(frameCount, colDecim) == 0
        waterfallData(:, histIdx) = pending;
        pending(:) = -120;
        histIdx = mod(histIdx, history) + 1;
    end

    % Throttle drawing by wall-clock time (also lets button callbacks run).
    if toc(lastDraw) >= 1/dispRate
        lastDraw = tic;
        set(hWater, 'CData', waterfallData(:, order(histIdx:histIdx+history-1)))
        if btnWave.Value == 0
            if In_CAMP177
                set(hSample, 'YData', 100*buffer)
            else
                set(hSample, 'YData', buffer)
            end
        end
        drawnow limitrate
    end
end

end