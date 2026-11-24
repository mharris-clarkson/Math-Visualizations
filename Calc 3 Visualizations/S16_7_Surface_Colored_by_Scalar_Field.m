function S16_7_Surface_Colored_by_Scalar_Field()
%% Shows the saddle surface S: z = x^2 - y^2 colored by a scalar field
%  f(x,y) = exp(-x^2 - y^2 + sin(pi y)) that has nothing to do with the
%  height z. This is the picture behind the surface integral of a scalar
%  field: the surface supplies the geometry (dS) and the color supplies the
%  value of f being added up.
%    Color button - switch the coloring between f(x,y) and the height z, so
%                   students see that the color is a separate function.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
f_surf  = @(x,y) x.^2 - y.^2;                      % geometry of the surface
f_color = @(x,y) exp(-x.^2 - y.^2 + sin(pi*y));    % scalar field (color)

xlims = [-2 2]; ylims = [-2 2];
res   = 150;    % grid points per side

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Surface colored by a scalar field', 1);
ax  = app.ax(1);

%% Make the initial plots
[X, Y] = meshgrid(linspace(xlims(1), xlims(2), res), ...
                  linspace(ylims(1), ylims(2), res));
Z = f_surf(X, Y);
C = f_color(X, Y);

surfHandle = surf(ax, X, Y, Z, C, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'interp');

cb = Pretty_Color_Positive(ax, C);
cb.Label.String = '$f(x,y)$';

%% Plot elements are done - Make pretty
view(ax, 3)
xlim(ax, xlims); ylim(ax, ylims)
title(ax, 'Surface $z = x^2 - y^2$ colored by $f(x,y) = e^{-x^2-y^2+\sin(\pi y)}$')


%% Build UI
NumControls = 1;
btnColor = app.addControl('button', '', 1, NumControls, @updatePlot, ...
    'Toggle', ["Color by height $z$", "Color by $f(x,y)$"], ...
    'colOrRow', 'row');

%% Main Draw update function.
    function updatePlot(~, ~)
        if btnColor.Value
            set(surfHandle, 'CData', Z)
            cb = Pretty_Color_Centered(ax, Z);
            cb.Label.String = '$z$';
            title(ax, 'Surface $z = x^2 - y^2$ colored by its height $z$')
        else
            set(surfHandle, 'CData', C)
            cb = Pretty_Color_Positive(ax, C);
            cb.Label.String = '$f(x,y)$';
            title(ax, 'Surface $z = x^2 - y^2$ colored by $f(x,y) = e^{-x^2-y^2+\sin(\pi y)}$')
        end
    end

end
