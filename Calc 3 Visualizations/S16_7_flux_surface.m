function S16_7_flux_surface()
%% Visualizes the surface integral of f(x,y) over the surface S: z = x^2 - y^2.
%
%  The surface is colored by f. Black arrows are the vector field F and blue
%  arrows are the surface normals n.
%    Projection button - flatten the surface onto z = 0 and color it by f (F . n)
%    Field button      - switch f between the Gaussian and the constant 1
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
skip = 6;   % arrows are drawn on every skip-th grid point

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Surface integral of f(x,y) over S', 1);
ax  = app.ax(1);

%% Optional math functions for plot computations
% f_surf and f_color are at the bottom of the file.

%% Make the initial plots
% Grid
[x,y] = meshgrid(linspace(-2,2,80));

z = f_surf(x,y);
C = f_color(x,y);

% Vector field
Fx = -2*y;
Fy =  2*x;
Fz = ones(size(x));

% Surface
surfHandle = surf(ax,x,y,z,1+0*C, ...
    'EdgeColor','none', ...
    'FaceColor','interp');
hold(ax,'on')

colormap(ax,cmocean('amp'))
cb = colorbar(ax);
cb.Label.String = 'f(x,y)';

% Normals
Nx = zeros(size(x));
Ny = zeros(size(x));
Nz = zeros(size(x));

for i = 1:numel(x)

    xi = x(i);
    yi = y(i);

    ru = [1, 0, 2*xi];
    rv = [0, 1, -2*yi];

    n = cross(ru,rv);
    n = n / norm(n);

    Nx(i) = n(1);
    Ny(i) = n(2);
    Nz(i) = n(3);
end

Nx = reshape(Nx,size(x));
Ny = reshape(Ny,size(x));
Nz = reshape(Nz,size(x));

% Quiver fields
xq = x(1:skip:end,1:skip:end);
yq = y(1:skip:end,1:skip:end);
zq = z(1:skip:end,1:skip:end);

U = -yq;
V =  xq;
W = ones(size(xq));

hField = quiver3(ax,xq,yq,zq,U,V,W,0.5,'k');

hNormal = quiver3(ax,xq,yq,zq, ...
    Nx(1:skip:end,1:skip:end), ...
    Ny(1:skip:end,1:skip:end), ...
    Nz(1:skip:end,1:skip:end), ...
    0.5,'b','LineWidth',1.5);

legend(ax,[hField hNormal], ...
    {'Vector Field F','Surface Normals n'}, ...
    'Location','northeast')

%% Plot elements are done - Make pretty
Pretty_Plot(ax);
grid(ax,'on')
view(ax,3)
axis(ax,[-2 2 -2 2 -2 2])
axis(ax,'vis3d')
xlabel(ax,'x'); ylabel(ax,'y'); zlabel(ax,'z')

applyCLim(1+0*C)
title(ax,'Surface integral of f(x,y) over S')

%% State variables
isProject = false;
isConstantF = true;

%% Build UI
NumControls = 2;
btnProject = app.addControl('button', 'Projection: OFF', 1, NumControls, @toggleProject, ...
    'ColorChange', true, 'colOrRow', 'row');
btnField = app.addControl('button', 'Field: Gaussian', 2, NumControls, @toggleField, ...
    'ColorChange', true, 'colOrRow', 'row');

% The plot sits above the row of buttons, with room for the colorbar on the
% right, so nothing overlaps.
ax.Position = [0.10, 0.22, 0.72, 0.70];

%% Functions for UI elements
    function toggleProject(~,~)

        isProject = btnProject.Value;

        if isProject
            btnProject.String = 'Projection: ON';
        else
            btnProject.String = 'Projection: OFF';
        end

        updateSurface();
    end

    function toggleField(~,~)

        isConstantF = btnField.Value;

        if isConstantF
            btnField.String = 'Field: Constant f = 1';
        else
            btnField.String = 'Field: Gaussian';
        end

        updateSurface();
    end

%% Main Draw update function.
    function updateSurface()

        % scalar field selection
        if isConstantF
            Fscalar = ones(size(x));
        else
            Fscalar = exp(-x.^2 - y.^2) + 0.1;
        end

        FdotN = Fx.*Nx + Fy.*Ny + Fz.*Nz;

        if isProject
            Cnew = Fscalar .* FdotN;

            set(surfHandle, ...
                'ZData', zeros(size(z)), ...
                'CData', Cnew);

            cb.Label.String = 'f(x,y) (F · n)';
            title(ax,'Projected flux density on z = 0');

        else
            Cnew = Fscalar;

            set(surfHandle, ...
                'ZData', z, ...
                'CData', Cnew);

            cb.Label.String = 'f(x,y)';
            title(ax,'Surface integral of f(x,y) over S');
        end

        applyCLim(Cnew)
    end

    % Safe color limits (a constant field would give a degenerate range)
    function applyCLim(Cnew)

        cmin = min(Cnew(:));
        cmax = max(Cnew(:));

        % avoid degenerate CLim (constant field case)
        if cmin == cmax
            cmin = cmin - 1;
            cmax = cmax + 1;
        end

        clim(ax,[cmin cmax]);
    end

end

%% Functions
function z = f_surf(x,y)
    z = x.^2 - y.^2;
end

function z = f_color(x,y)
    z = exp(-x.^2 - y.^2) + 0.1;
end