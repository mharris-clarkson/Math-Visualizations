function S14_1_Surface_Plots()
%% Displays five surf examples from Example  9.1, selectable via
%  Next/Previous buttons. Shows 3D surface plots of scalar functions
%  f(x,y) using surf with semi-transparent blue shading.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all
%% User parameters for math objects.
% Adjust these to modify selected math objects below.
exampleIdx = 1; % Starting example (1-5)
exampleNames = { ...
    'Example 9.1: $f(x,y) = \sin(xy)$', ...
    'Example 9.2: $f(x,y) = e^{-x^2y^2}$', ...
    'Example 9.3: $T(x,y)$ Heat Equation Solution', ...
    'Example 9.4: $\phi(x,y)$ Electric Potential', ...
    'Example 9.5: $l(x,y)$ Matlab Peaks function'};
%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')
%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure(exampleNames{exampleIdx}, 1);
%% Optional math functions for plot computations
    function drawExample(idx)
        cla(app.ax)
        switch idx
            case 1  % f(x,y) = sin(xy)
                [x, y] = meshgrid(linspace(-pi, pi, 40));
                Z = sin(x.*y);
                h = surf(app.ax, x, y, Z);
            case 2  % f(x,y) = e^{x^2 y^2}
                [x, y] = meshgrid(linspace(-4, 4, 41));
                Z = exp(-x.^2.*y.^2);
                h = surf(app.ax, x, y, Z);
            case 3  % Heat equation solution T(x,y)
                [x, y] = meshgrid(linspace(0, 1, 40));
                Z = (sinh(pi*y) / sinh(pi)) .* sin(pi*x);
                h = surf(app.ax, x, y, Z);
            case 4  % Electric potential phi(x,y)
                [x, y] = meshgrid(linspace(-3, 3, 50));
                Z = 1./(4*pi*8.854*10^(-12)*sqrt(x.^2 + y.^2));
                h = surf(app.ax, x, y, Z);
            case 5  % Matlab peaks l(x,y)
                [x, y, Z] = peaks(50);
                h = surf(app.ax, x, y, Z);
        end
        h.FaceColor = [0 0 1];   % pure blue
        h.FaceAlpha = 0.8;       % slightly see-through (0=transparent, 1=opaque)
        if idx == 5
            h.FaceAlpha = 0.6;   % peaks example uses a lighter alpha
        end
        Pretty_Plot(app.ax)
        xlabel(app.ax, '$x$', 'Interpreter', 'latex')
        ylabel(app.ax, '$y$', 'Interpreter', 'latex')
        zlabel(app.ax, '$z$', 'Interpreter', 'latex')
        view(app.ax, 45,45)
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
        exampleIdx = mod(exampleIdx - 2, 5) + 1;
        drawExample(exampleIdx)
    end
    function nextExample(~, ~)
        exampleIdx = mod(exampleIdx, 5) + 1;
        drawExample(exampleIdx)
    end
%% Main Draw update function.
% (Handled directly in prevExample / nextExample above)
end