% --- Read the text file that was grabbed from a github ---
filename = 'extract mario/mario.txt';
fileText = fileread(filename);

% --- Extract all frequencies ---
freqPattern = "beep frequency=(\d+)";
freqMatches = regexp(fileText, freqPattern, 'tokens');
Note_HZ = cellfun(@(x) str2double(x{1}), freqMatches);

% --- Extract all note lengths ---
lengthPattern = "length=(\d+)ms";
lengthMatches = regexp(fileText, lengthPattern, 'tokens');
Note_time = cellfun(@(x) str2double(x{1}), lengthMatches)/1000;  % convert ms to seconds

% --- Extract all delays ---
delayPattern = ":delay (\d+)ms";
delayMatches = regexp(fileText, delayPattern, 'tokens');
Note_pause = cellfun(@(x) str2double(x{1}), delayMatches)/1000;  % convert ms to seconds

% --- Optional Display results ---
if false
    disp('Note_HZ = ');
    disp(Note_HZ);

    disp('Note_time = ');
    disp(Note_time);

    disp('Note_pause = ');
    disp(Note_pause);
end