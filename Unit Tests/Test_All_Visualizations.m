classdef Test_All_Visualizations < matlab.unittest.TestCase
    %% Automatic check that every visualization starts and every control works
    % One test per script, found automatically (Find_Visualization_Scripts).
    % Each test runs the script with hidden figures, moves every slider to
    % Min / middle / Max, clicks every button twice, and fails on any error.
    % Warnings (for example bad LaTeX) and slow callbacks are logged.
    %
    %% Syntax
    %
    % results = runtests('Test_All_Visualizations');          % all scripts
    % results = runtests('Test_All_Visualizations', 'Name', '*S13_3*');
    % table(results)
    %
    % Scripts in 'Work In progress' are never tested here. Check them by
    % hand with Run_All_Visualization_Tests('IncludeWIP', true) or
    % Exercise_Visualization(fullpath).
    % Files in Excluded_Visualizations.m (endless animations, long
    % simulations, sound-only scripts) still get a test, which is
    % reported as Incomplete with "SKIPPED (excluded): would normally run,
    % but ..." so the results show they were skipped, not forgotten.
    %
    % Scripts that wait for a person (input, ginput, uiwait, audio
    % recording) or call 'clear all' are reported as Incomplete (skipped).
    % Drag/click-on-plot interactions (WindowButtonDownFcn etc.) are listed
    % in the log as needing a manual check.
    %
    %% Author Info
    %
    %
    % This function was written by Dr Matthew Harris an assistant professor at
    % Clarkson university for visually teaching MA 231: Calculus 3.
    %
    properties (TestParameter)
        Script = Find_Visualization_Scripts('IncludeWIP', false);   % never Work In progress
    end

    properties (Constant)
        SlowCallbackSeconds = 0.25   % log callbacks slower than this
        SlowStartupSeconds  = 3      % log start-ups slower than this
    end

    methods (TestClassSetup)
        function addHelpers(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            oldPath = addpath(genpath(fullfile(root, 'Helper')));
            testCase.addTeardown(@() path(oldPath));
            oldVis = get(groot, 'DefaultFigureVisible');
            set(groot, 'DefaultFigureVisible', 'off');
            testCase.addTeardown(@() set(groot, 'DefaultFigureVisible', oldVis));
        end
    end

    methods (Test)
        function scriptRunsAndControlsWork(testCase, Script)
            r = Exercise_Visualization(Script);

            testCase.assumeNotEqual(r.Status, "skipped", char(r.Message));

            testCase.log(1, sprintf('%s: start-up %.2f s, %d sliders, %d buttons, %d other controls', ...
                r.Name, r.StartupTime, r.NumSliders, r.NumButtons, r.NumOther));
            if r.StartupTime > testCase.SlowStartupSeconds
                testCase.log(1, sprintf('SLOW START-UP: %.2f s', r.StartupTime));
            end
            if r.SlowestCallback > testCase.SlowCallbackSeconds
                testCase.log(1, sprintf('SLOW CALLBACK: %.2f s (%s)', r.SlowestCallback, r.SlowestControl));
            end
            for w = r.Warnings(:)'
                testCase.log(1, "WARNING " + w);
            end
            if strlength(r.NotExercised) > 0
                testCase.log(1, "MANUAL CHECK: " + r.NotExercised);
            end

            % Failure messages include the full MATLAB error trace
            trace = strjoin(r.ErrorTrace, newline + "----" + newline);
            testCase.verifyFalse(startsWith(r.Message, "Start-up error"), ...
                char(r.Message + newline + trace));
            testCase.verifyEmpty(r.ControlErrors, ...
                char(strjoin(r.ControlErrors, newline) + newline + newline + trace));
        end
    end
end
