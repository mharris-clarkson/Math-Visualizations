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
        % Undo what imshow (example 3) changes; cla keeps colorbars
        colorbar(app.ax, 'off');
        axis(app.ax, 'normal');
        app.ax.Visible = 'on';

        switch idx
            case 1  % Heat equation solution
                [x, y] = meshgrid(linspace(0, 1, 40));
                Z = (sinh(pi*y) / sinh(pi)) .* sin(pi*x);
                pcolor(app.ax, x, y, Z)
                Pretty_Color_Positive(app.ax,Z);
                axis(app.ax, 'xy')

            case 2  % peaks
                [x,y,Z] = peaks(100);
                pcolor(app.ax, x, y, Z)
                Pretty_Color_Centered(app.ax,Z);
                axis(app.ax, 'xy')

            case 3  % Binary image from mat file
                matFile = 'S14_1_Extrated_random_data.mat';
                data = load(matFile);
                imshow(data.BW, 'Parent', app.ax)
        end

        Pretty_Plot(app.ax)
        title(app.ax, exampleNames{idx})
        app.fig.Name = exampleNames{idx};
    end

%% Make the initial plots
drawExample(exampleIdx)

%% Build UI
NumControls = 2;

app.addPrevNext(1, NumControls, numel(exampleNames), @drawExample,'colOrRow','row');
app.galleryIdx = exampleIdx;

end