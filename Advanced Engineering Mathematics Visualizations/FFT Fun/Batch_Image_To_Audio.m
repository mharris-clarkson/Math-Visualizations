function Batch_Image_To_Audio()
%% Batch Image-to-Audio Edge Sonification
% Converts every PNG in the current directory into its own WAV file
% (edges -> sequential tones, no intermodulation), saved to a "wav files"
% subfolder, then concatenates all of them into one combined file in that
% same subfolder. This only synthesizes and writes audio -- it never
% reads anything back for analysis.
%
%% Author Info
%
% Written by Claude, building on an original script written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3. Claude did a lot of the heavylifting here. My
% original code was significantly smaller but produced results that how
% significantly less resolution.

close all

%% User parameters
fs           = 44100;    % sample rate (Hz)
f_min        = 500;      % lowest tone frequency (Hz)
f_max        = 15000;    % highest tone frequency (Hz)
total_dur    = 8;        % target duration per image (s)
min_tone_ms  = 3;        % minimum tone duration (ms) -- keeps tones clean, avoids clicks
gapSec       = 0.5;      % silence inserted between images in the combined file
outDir       = 'wav files';
combinedFile = fullfile(outDir, 'All_In_One.wav');

if ~exist(outDir, 'dir')
    mkdir(outDir)
end

%% Find every PNG in the current directory
pngFiles = dir('PNGs to Convert\*.png');
if isempty(pngFiles)
    fprintf('No PNG files found in %s\n', pwd);
    return
end

%% Encode each image to its own WAV, collecting the audio for the combined file
gapSamples = round(gapSec*fs);
allAudio   = cell(1, numel(pngFiles));
tBatch     = tic;

for k = 1:numel(pngFiles)
    imgFile = ['PNGs to Convert\' pngFiles(k).name];
    fprintf('[%d/%d] %s ...\n', k, numel(pngFiles), imgFile)
    tImg = tic;

    y = Image_To_Edge_Audio(imgFile, f_min, f_max, fs, total_dur, min_tone_ms, outDir);
    allAudio{k} = [y, zeros(1, gapSamples)];

    fprintf('[%d/%d] %s  (%.2f s audio, %.2f s to process)\n', ...
        k, numel(pngFiles), imgFile, length(y)/fs, toc(tImg));
end

%% Stitch everything together into one combined WAV
y_combined = [allAudio{:}];
audiowrite(combinedFile, y_combined', fs);
fprintf('Combined WAV written: %s  (%.2f s, %d images)\n', ...
    combinedFile, length(y_combined)/fs, numel(pngFiles));
fprintf('Total batch time: %.2f s\n', toc(tBatch));

end

%% ========================================================================
% Per-image encoder (synthesis + write only -- no decoding/analysis)
% ========================================================================

function y_total = Image_To_Edge_Audio(imgFile, f_min, f_max, fs, total_dur, min_tone_ms, outDir)
[~, baseName] = fileparts(imgFile);
wavFile = fullfile(outDir, [baseName, '.wav']);

min_tone_samp = round(min_tone_ms*fs/1000);

[edges, numRows, ~] = loadEdgesFitDuration(imgFile, total_dur, fs, min_tone_samp);
total_edge_pixels   = max(sum(edges(:)), 1);
tone_dur            = max(round((total_dur*fs)/total_edge_pixels), min_tone_samp);

freq_rows = f_max - (f_max - f_min)*(0:numRows-1).'/(numRows-1);

y_total = synthesizeEdgeTones(edges, freq_rows, tone_dur, fs);
y_total = y_total / (max(abs(y_total)) + eps);

audiowrite(wavFile, y_total', fs);
end

function [edges, numRows, numCols] = loadEdgesFitDuration(imgFile, total_dur, fs, min_tone_samp)
% Canny-edge the image, then iteratively shrink it until the edge-pixel
% count fits the target duration at min_tone_samp per pixel.
I = imread(imgFile);
if size(I,3) == 3
    I = rgb2gray(I);
end
I = im2double(I);

max_pixels = floor((total_dur*fs)/min_tone_samp);

% Pre-shrink before the first edge() call: the target is only ~max_pixels
% edge pixels, so running Canny at a multi-megapixel source resolution
% is wasted work that was the main cause of multi-minute hangs on large
% photos. Cap the long side generously up front.
maxStartDim = 800;
[origRows, origCols] = size(I);
if max(origRows, origCols) > maxStartDim
    I = imresize(I, maxStartDim/max(origRows, origCols));
end

[rows, cols] = size(I);
edges = edge(I, 'Canny');

% Shrink loop, with a safety margin so every step shrinks meaningfully
% (guarantees fast convergence even when the edge count barely exceeds
% the target) and a hard iteration cap so this can never hang forever.
maxIter = 15;
iter = 0;
while sum(edges(:)) > max_pixels && rows > 1 && cols > 1 && iter < maxIter
    iter  = iter + 1;
    scale = 0.9*sqrt(max_pixels/sum(edges(:)));
    rows  = max(round(rows*scale), 1);
    cols  = max(round(cols*scale), 1);
    edges = edge(imresize(I, [rows, cols]), 'Canny');
    fprintf('    shrink %d: [%d x %d], %d edge pixels (target %d)\n', ...
        iter, rows, cols, sum(edges(:)), max_pixels);
end
if iter == maxIter
    warning('loadEdgesFitDuration:maxIter', ...
        'Hit the %d-iteration shrink cap; using %d edge pixels (target %d).', ...
        maxIter, sum(edges(:)), max_pixels);
end

[numRows, numCols] = size(edges);
end

function y_total = synthesizeEdgeTones(edges, freq_rows, tone_dur, fs)
% One tone per edge pixel in a column, concatenated column by column, with
% a short raised-cosine fade in/out on every tone to avoid clicks.
%
% Vectorized per column: instead of looping over every edge pixel and
% calling sin() once each, each column's whole batch of tones is built as
% one (numActiveTones x tone_dur) matrix and flattened in one shot -- the
% only remaining loop is over columns, not over individual edge pixels.
numCols = size(edges, 2);

fade_samp = min(round(fs*0.002), floor(tone_dur/2));   % 2 ms, or half a tone if shorter
fade_in   = 0.5*(1 - cos(pi*(0:fade_samp-1)/fade_samp));
fade_win  = ones(1, tone_dur);
fade_win(1:fade_samp)         = fade_in;
fade_win(end-fade_samp+1:end) = fliplr(fade_in);

t_seg      = (0:tone_dur-1)/fs;        % 1 x tone_dur
audio_cols = cell(1, numCols);
phase      = 0;

for col = 1:numCols
    freqs = freq_rows(edges(:, col));
    n = numel(freqs);
    if n == 0
        audio_cols{col} = zeros(1, tone_dur);
        phase = 0;
        continue
    end

    % Starting phase of each tone in this column, carried from the
    % previous tone (or from the previous column for the first one).
    phaseInc   = 2*pi*freqs*tone_dur/fs;                      % n x 1
    phaseStart = phase + [0; cumsum(phaseInc(1:end-1))];      % n x 1

    PHI = phaseStart + 2*pi*freqs.*t_seg;    % n x tone_dur (broadcast)
    segMatrix = sin(PHI) .* fade_win;        % n x tone_dur (broadcast)
    audio_cols{col} = reshape(segMatrix.', 1, []);   % tone-major flatten

    phase = mod(phaseStart(end) + phaseInc(end), 2*pi);
end

y_total = [audio_cols{:}];
end