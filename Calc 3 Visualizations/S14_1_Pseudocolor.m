function S14_1_Pseudocolor()
%% Displays three pcolor examples from Section 14.1, selectable via
%  Next/Previous buttons. Shows heat maps and image data using pcolor
%  and imshow with colormaps.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
exampleIdx = 1; % Starting example (1-3)

exampleNames = { ...
    'Example 13.1: Heat Equation Solution $T(x,y)$', ...
    'Example 13.2: Matlab Peaks function', ...
    'Example 13.3: Extracted Image Data'};

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure(exampleNames{exampleIdx}, 1);
view(app.ax, 0, 90)

%% Optional math functions for plot computations
    function drawExample(idx)
        cla(app.ax)
        
        switch idx
            case 1  % Heat equation solution
                [x, y] = meshgrid(linspace(0, 1, 40));
                Z = (sinh(pi*y) / sinh(pi)) .* sin(pi*x);
                pcolor(app.ax, x, y, Z)
                Pretty_Color_Positive(app.ax,Z)
                axis(app.ax, 'xy')

            case 2  % peaks
                [x,y,Z] = peaks(100);
                pcolor(app.ax, x, y, Z)
                Pretty_Color_Centered(app.ax,Z)
                colorbar(app.ax)
                axis(app.ax, 'xy')

            case 3  % Binary image from mat file
                matFile = 'S14_1_Extrated_random_data.mat';
                data = load(matFile);
                imshow(data.BW, 'Parent', app.ax)
        end

        Pretty_Plot(app.ax)
        title(app.ax, exampleNames{idx}, 'Interpreter', 'latex')
        app.fig.Name = exampleNames{idx};
    end

%% Make the initial plots
drawExample(exampleIdx)

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 2;

app.addControl('button', '$\leftarrow$ Previous', 1, NumControls, @prevExample);
app.addControl('button', 'Next $\rightarrow$',    2, NumControls, @nextExample);

%% Functions for UI elements
    function prevExample(~, ~)
        exampleIdx = mod(exampleIdx - 2, 3) + 1;
        drawExample(exampleIdx)
    end

    function nextExample(~, ~)
        exampleIdx = mod(exampleIdx, 3) + 1;
        drawExample(exampleIdx)
    end

%% Main Draw update function.
% (Handled directly in prevExample / nextExample above)
end