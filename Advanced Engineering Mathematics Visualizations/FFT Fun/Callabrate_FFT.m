clear all
%% Runs several tests for the waterfall plot analyser. Just run two copies 
% of matlab, one with the waterfall plot and one with this code. Laptops 
% with sound cancelation might have issues with this code. 

fs = 44100;          % Sampling frequency (Hz)
t = 0:1/fs:0.5;        % Time vector
f = 500;             % Frequency (Hz)

%% Test single frequency
y = 5*sin(2*pi*f*t); % Generate 50 Hz sine wave
sound(y, fs);        % Play the sound
pause(max(t)*2)


%% Test full human range
Dt = 1;             % Time in sec for signal
t = 0:1/fs:Dt;      % Time vector

omega_0 = 0;        % Starting Frequency
omega_f = 20000;    % Ending Frequency

% Define signal
ft = @(t) omega_0+((omega_f-omega_0)/Dt)*t;
%adjust phase to remove ringing
phi = 2*pi*cumtrapz(t, ft(t));
% Build signal
y = sin(phi);

sound(y, fs);        % Play the sound

pause(Dt)





%% fun
run('extract mario\Mario.m')
Dt = 2;sum(Note_time) + sum(Note_pause); % Time in sec for signal
t = 0:1/fs:Dt;      % Time vector

omega_0 = 0;        % Starting Frequency
omega_f = 20000;    % Ending Frequency

% Define signal
notes = @(t,Hz,t_start,t_end) Hz*(t_start<t).*(t<t_end);

ft = 0*t;
Current_time = 0;
for i=1:1:length(Note_HZ)
    ft = ft + notes(t,Note_HZ(i),...
        Current_time, Current_time+Note_time(i));
    Current_time = Current_time + Note_time(i)+ Note_pause(i);
end




%adjust phase to remove ringing
phi = 2*pi*cumtrapz(t, ft);
% Build signal
y = sin(phi);

sound(y, fs);        % Play the sound

pause(Dt+2)








%% Spell MATH
Dt = 7;             % Time in sec for signal
t = 0:1/fs:Dt;      % Time vector

omega_0 = 2000;        % Starting Frequency
omega_f = 4000;    % Ending Frequency

% Define signal

ft_helper = @(t, start, stop,...
    omega_start, omega_stop) (t>start).*(t<stop).*(omega_start+((omega_stop-omega_start)/(stop-start))*(t-start));

%M
ft1 = @(t)  ft_helper(t, 0, 0.2,omega_0, omega_f);
ft2 = @(t) -1*ft_helper(t, 0.2, .8,omega_f, (omega_f+omega_0)/2);
ft3 = @(t) ft_helper(t, 0.8, 1.6 ,(omega_f+omega_0)/2, omega_f);
ft4 = @(t) ft_helper(t, 1.6, 1.8,omega_f, omega_0);

%A minus the solid line
ft5 = @(t)  ft_helper(t, 2.5, 3,omega_0, omega_f);
ft6 = @(t)  ft_helper(t, 3, 3.5,omega_f, omega_0);

%T
ft7 = @(t)  ft_helper(t, 4, 4.45,omega_f, omega_f)+...
    ft_helper(t, 4.55, 5,omega_f, omega_f);
ft8 = @(t)  -ft_helper(t, 4.45, 4.55,omega_0, omega_f);


%H
ft9 = @(t)  ft_helper(t, 5.5, 5.6,omega_0, omega_f);
ft10 = @(t)  ft_helper(t, 5.6, 6.5,(omega_f+omega_0)/2, (omega_f+omega_0)/2);
ft11 = @(t)  ft_helper(t, 6.5,6.6,omega_0, omega_f);



ft = @(t) ft1(t)+ft2(t)+ft3(t)+ft4(t)+...
    ft5(t)+ft6(t)+ft7(t)+ft8(t)+...
    ft9(t)+ft10(t)+ft11(t);
%ft = @(t) omega_0+((omega_f-omega_0)/Dt)*t;
%adjust phase to remove ringing
phi1 = 2*pi*cumtrapz(t, ft(t));
% Build signal
y = .5*sin(phi1) + .5*sin(2*pi*((omega_0+omega_f)/2)*t.*(2.75<t).*(t<3.25));

sound(y, fs);        % Play the sound

pause(Dt);


%% make pictures from wav files
wavFiles = dir('wav files\*.wav');
if isempty(wavFiles)
    fprintf('No WAV files found in %s\n', pwd);
    return
end
for k = 1:numel(wavFiles)
    wavFile = ['wav files\' wavFiles(k).name];
    [y, Fs] = audioread(wavFile);
    soundsc(y, Fs);
    pause(0.5)
end

