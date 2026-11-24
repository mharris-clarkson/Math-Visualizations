% Reads in all the wav files and converts them to the optimal recovered
% images. This bypasses the speaker to microphone error sources that will
% be present.

wavFiles = dir(fullfile('wav files', '*.wav'));
if isempty(wavFiles)
    fprintf('No WAV files found in %s\n', pwd);
    fprintf('Making them now!')
    run("Batch_Image_To_Audio.m")
    wavFiles = dir(fullfile('wav files', '*.wav'));
end
for k = 1:numel(wavFiles)
    [file, fs] = audioread(fullfile('wav files', wavFiles(k).name));
    file = mean(file,2);   % stereo to mono

    % STFT parameters
    window = 4096;
    noverlap = 512;
    nfft = 2048*2;

    [S,F,T] = spectrogram(file, window, noverlap, nfft, fs);
    Sdb = 20*log10(abs(S));   % magnitude in dB

    % Waterfall plot
    figure(k)
    pcolor(T, F, Sdb)
    shading flat
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