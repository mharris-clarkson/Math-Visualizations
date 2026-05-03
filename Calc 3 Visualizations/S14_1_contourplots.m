function S14_1_contourplots()
%% Displays some contour plot examples from Section 14.1, selectable via
%  Next/Previous buttons. Each example shows a different function and its
%  labeled level curves.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
exampleIdx = 1;  

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Contour Plots', 1);
view(app.ax, 0, 90)

%% Optional math functions for plot computations
NumFigs = 4;
    function drawExample(idx)
        cla(app.ax)
        switch idx
            case 1
                [x, y] = meshgrid(linspace(-5, 5, 40));
                Z = -3*y ./ (x.^2 + y.^2 + 1);
                [C, h] = contour(app.ax, x, y, Z, 11, 'k');
                clabel(C, h, 'FontSize', 14, 'Color', 'r')
                title(app.ax, '$f(x,y) = -3y/(x^2+y^2+1)$', 'Interpreter', 'latex')

            case 2
                [r, theta] = meshgrid(linspace(0, 0.98, 40), linspace(0, 2*pi, 40));
                x = r .* cos(theta);
                y = r .* sin(theta);
                Z = exp(-1 ./ (1 - (x.^2 + y.^2).^(1/2)));
                [C, h] = contour(app.ax, x, y, Z, 'k');
                clabel(C, h, 'FontSize', 14, 'Color', 'r')
                axis(app.ax, 'equal')
                title(app.ax, '$h(x,y) = e^{-1/(1-\sqrt{x^2+y^2})}$', 'Interpreter', 'latex')

            case 3
                [x, y] = meshgrid(linspace(0, 1, 40));
                Z = (sinh(pi*y) / sinh(pi)) .* sin(pi*x);
                [C, h] = contour(app.ax, x, y, Z, 20, 'k');
                clabel(C, h, 'FontSize', 14, 'Color', 'r')
                title(app.ax, '$T(x,y) = \frac{\sinh(\pi y)}{\sinh(\pi)}\sin(\pi x)$', 'Interpreter', 'latex')

            case 4
                [x, y, z] = peaks(100);
                [C, h] = contour(app.ax, x, y, z, -10:1:10, 'k');
                clabel(C, h, 'FontSize', 14, 'Color', 'r')
                title(app.ax, '$\ell(x,y) = \mathrm{peaks}(x,y)$', 'Interpreter', 'latex')
        end
        xlabel(app.ax, '$x$', 'Interpreter', 'latex')
        ylabel(app.ax, '$y$', 'Interpreter', 'latex')
        set(app.ax, 'FontSize', 18)
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
        exampleIdx = mod(exampleIdx - 2, NumFigs) + 1;
        drawExample(exampleIdx)
    end

    function nextExample(~, ~)
        exampleIdx = mod(exampleIdx, NumFigs) + 1;
        drawExample(exampleIdx)
    end

%% Main Draw update function.
% (Handled directly in prevExample / nextExample above)
end