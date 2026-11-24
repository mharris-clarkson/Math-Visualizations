% Reads in all the wav files and converts them to the optimal recovered
% images. This bipasses the speaker to microphone error sources that will
% be present.


% fullfile instead of 'wav files\...' so the paths also work on Mac/Linux
wavFiles = dir(fullfile('wav files', '*.wav'));
if isempty(wavFiles)
    fprintf('No WAV files found in %s\n', pwd);
    fprintf('Making them now!')
    run("Batch_Image_To_Audio.m")
    wavFiles = dir(fullfile('wav files', '*.wav'));
end
for k = 1:numel(wavFiles)
    % Read WAV
    [file, fs] = audioread(fullfile('wav files', wavFiles(k).name));
    % If stereo, convert to mono
    file = mean(file,2);

    % STFT parameters
    window = 4096;
    noverlap = 512;
    nfft = 2048*2;

    % Compute spectrogram
    [S,F,T] = spectrogram(file, window, noverlap, nfft, fs);

    % Convert magnitude to dB
    Sdb = 20*log10(abs(S));

    % Waterfall plot
    figure(k)
    pcolor(T, F, Sdb)
    shading flat
    % pcolor(T, F, ...) puts time on x and frequency on y (the labels were
    % the other way round)
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    zlabel('Magnitude (dB)')
    title('Waterfall Spectrum')
    colormap('hot');
    view(0,90)
    % colormap turbo
    % xlim([250,3000])
    % ylim([0,15])
end