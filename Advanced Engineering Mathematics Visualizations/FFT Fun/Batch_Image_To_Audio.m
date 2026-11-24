function Batch_Image_To_Audio()
%% Batch Image-to-Audio Edge Sonification
% Converts every PNG in the "PNGs to Convert" folder into its own WAV file
% (edges -> sequential tones, no intermodulation), saved to a "wav files"
% subfolder, then concatenates all of them into one combined file in that
% same subfolder. Needs only base MATLAB (edge detection and resizing are
% local functions at the bottom of this file).
%
%% Author Info
%
% Written by Claude, building on an original script written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3. Claude's changes were to remove the reliance on
% the image processing package.

close all

%% User parameters
fs           = 44100;    % sample rate (Hz)
f_min        = 500;      % lowest tone frequency (Hz)
f_max        = 15000;    % highest tone frequency (Hz)
total_dur    = 8;        % target duration per image (s)
min_tone_ms  = 3;        % minimum tone duration (ms)
gapSec       = 0.5;      % silence inserted between images in the combined file
inDir        = 'PNGs to Convert';
outDir       = 'wav files';
combinedFile = fullfile(outDir, 'All_In_One.wav');
print_Progress = false;

if ~exist(outDir, 'dir')
    mkdir(outDir)
end

%% Find every PNG in the input folder
pngFiles = dir(fullfile(inDir, '*.png'));
if isempty(pngFiles)
    fprintf('No PNG files found in %s\n', fullfile(pwd, inDir));
    return
end

%% Encode each image to its own WAV, collecting the audio for the combined file
gapSamples = round(gapSec*fs);
allAudio   = cell(1, numel(pngFiles));
tBatch     = tic;

for k = 1:numel(pngFiles)
    imgFile = fullfile(inDir, pngFiles(k).name);
    if print_Progress
        fprintf('[%d/%d] %s ...\n', k, numel(pngFiles), imgFile)
    end
    tImg = tic;

    y = Image_To_Edge_Audio(imgFile, f_min, f_max, fs, total_dur, min_tone_ms, outDir);
    allAudio{k} = [y, zeros(1, gapSamples)];

    if print_Progress
        fprintf('[%d/%d] %s  (%.2f s audio, %.2f s to process)\n', ...
            k, numel(pngFiles), imgFile, length(y)/fs, toc(tImg));
    end
end

%% Stitch everything together into one combined WAV
y_combined = [allAudio{:}];
audiowrite(combinedFile, y_combined', fs);
if print_Progress
    fprintf('Combined WAV written: %s  (%.2f s, %d images)\n', ...
        combinedFile, length(y_combined)/fs, numel(pngFiles));
    fprintf('Total batch time: %.2f s\n', toc(tBatch));
end
end

%% ========================================================================
% Per-image encoder
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
I = loadGrayImage(imgFile);

max_pixels = floor((total_dur*fs)/min_tone_samp);

% Shrink large images before the first edge pass
maxStartDim = 800;
[origRows, origCols] = size(I);
if max(origRows, origCols) > maxStartDim
    I = resizeImage(I, maxStartDim/max(origRows, origCols));
end

[rows, cols] = size(I);
edges = cannyEdges(I);

% Shrink until the edge count fits (with an iteration cap)
maxIter = 15;
iter = 0;
while sum(edges(:)) > max_pixels && rows > 2 && cols > 2 && iter < maxIter
    iter  = iter + 1;
    scale = 0.9*sqrt(max_pixels/sum(edges(:)));
    rows  = max(round(rows*scale), 2);
    cols  = max(round(cols*scale), 2);
    edges = cannyEdges(resizeImage(I, [rows, cols]));
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

    % Starting phase of each tone, carried on from the previous tone
    phaseInc   = 2*pi*freqs*tone_dur/fs;                      % n x 1
    phaseStart = phase + [0; cumsum(phaseInc(1:end-1))];      % n x 1

    PHI = phaseStart + 2*pi*freqs.*t_seg;    % n x tone_dur (broadcast)
    segMatrix = sin(PHI) .* fade_win;        % n x tone_dur (broadcast)
    audio_cols{col} = reshape(segMatrix.', 1, []);   % tone-major flatten

    phase = mod(phaseStart(end) + phaseInc(end), 2*pi);
end

y_total = [audio_cols{:}];
end

%% ========================================================================
% Base-MATLAB image helpers (replace Image Processing Toolbox functions)
% ========================================================================

function I = loadGrayImage(imgFile)
% Read any image as a grayscale double in [0, 1].
% Replaces rgb2gray + im2double.
[I, map] = imread(imgFile);
if ~isempty(map)                      % indexed (palette) image
    I = ind2rgb(I, map);
end
if isinteger(I)
    I = double(I) / double(intmax(class(I)));
else
    I = double(I);
end
if size(I, 3) >= 3                    % same weights as rgb2gray
    I = 0.2989*I(:,:,1) + 0.5870*I(:,:,2) + 0.1140*I(:,:,3);
end
end

function E = cannyEdges(I)
% Canny edge detector, same steps and default settings as edge(I,'Canny'):
%   1) smooth with a Gaussian (sigma = sqrt(2)) and take the gradient
%   2) non-maximum suppression: keep a pixel only if it is the peak of
%      |grad I| across the edge, so edges are 1 pixel wide
%   3) hysteresis: strong pixels (top 30% of |grad I|) are edges; weak
%      pixels (above 40% of that level) are kept only if they connect to
%      a strong one
sigma = sqrt(2);
r  = ceil(3*sigma);
x  = -r:r;
g  = exp(-x.^2/(2*sigma^2));  g = g/sum(g);   % Gaussian
dg = -x.*g/sigma^2;                           % its derivative

% Smooth and differentiate in one separable pass; replicate the border
% so the image edge does not look like an edge
Ip = padReplicate(I, r);
Ix = conv2(g, dg, Ip, 'valid');   % d/dx (along rows), smoothed down columns
Iy = conv2(dg, g, Ip, 'valid');   % d/dy (down columns), smoothed along rows

mag = hypot(Ix, Iy);
mag = mag / (max(mag(:)) + eps);

% Gradient direction rounded to one of 4 lines: 0 = horizontal,
% 1 = diagonal, 2 = vertical, 3 = anti-diagonal
a = mod(round(atan2(Iy, Ix)/(pi/4)), 4);

[m, n] = size(mag);
M = zeros(m+2, n+2);
M(2:end-1, 2:end-1) = mag;
nb = @(dr, dc) M((2:m+1)+dr, (2:n+1)+dc);   % neighbour at offset (dr, dc)

keep = (a == 0 & mag >= nb(0,-1) & mag >= nb(0, 1)) | ...
    (a == 1 & mag >= nb(1, 1) & mag >= nb(-1,-1)) | ...
    (a == 2 & mag >= nb(-1,0) & mag >= nb(1, 0)) | ...
    (a == 3 & mag >= nb(-1,1) & mag >= nb(1,-1));
thin = mag .* keep;

s    = sort(mag(:));
high = s(ceil(0.7*numel(s)));
low  = 0.4*high;
weak = thin > low;
E    = thin > high;

% Grow the strong edges into touching weak pixels until nothing changes
while true
    grown = conv2(double(E), ones(3), 'same') > 0 & weak;
    if isequal(grown, E), break, end
    E = grown;
end
end

function J = resizeImage(I, sz)
% Resize to a scale factor (scalar) or to [rows cols]. Replaces imresize:
% Gaussian pre-blur when shrinking (anti-aliasing), then bilinear interp.
[m, n] = size(I);
if isscalar(sz)
    sz = max(round([m n]*sz), 1);
end
s = min(sz ./ [m n]);
if s < 1
    sigma = 0.5/s;
    r = ceil(3*sigma);
    x = -r:r;
    g = exp(-x.^2/(2*sigma^2));  g = g/sum(g);
    I = conv2(g, g, padReplicate(I, r), 'valid');
end
J = interp2(I, linspace(1, n, sz(2)), linspace(1, m, sz(1)).', 'linear');
end

function P = padReplicate(I, r)
% Pad r pixels on every side by repeating the border (replaces padarray)
[m, n] = size(I);
P = I([ones(1, r), 1:m, m*ones(1, r)], [ones(1, r), 1:n, n*ones(1, r)]);
end