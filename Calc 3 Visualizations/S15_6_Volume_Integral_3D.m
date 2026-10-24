function S15_6_Volume_Integral_3D()
%% 3D Volume Integral with Voxels
% Approximates the integral of f over a 3D region by summing f at the
% center of every N x N x N voxel whose center lies inside the region, and
% compares the volume of the voxels with a high-resolution reference volume.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
f      = @(x,y,z) exp(-x.^2 - y.^2 - z.^2);                      % Gaussian 3D
region = @(x,y,z) (x/1).^2 + (y/2).^2 + (z/1.5).^2 <= 1;        % ellipsoid

xlims = [-1 1]; ylims = [-2 2]; zlims = [-1.5 1.5];   % bounding box
N0   = 1;     % initial voxels per dimension
Nmax = 100;    % largest N on the slider
resExact = 200;   % resolution of the reference volume

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('3D Volume Integral', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
view(ax, 45, 30)

%% Reference volume (one 2D slab at a time -- no 200^3 arrays in memory)
cx = centers(xlims, resExact);
cy = centers(ylims, resExact);
cz = centers(zlims, resExact);
[xg, yg] = ndgrid(cx, cy);
count = 0;
for k = 1:resExact
    count = count + nnz(region(xg, yg, cz(k)));
end
exactVolume = count * prod([diff(xlims) diff(ylims) diff(zlims)]) / resExact^3;

%% Static graphics
[xs, ys, zs] = ellipsoid(0, 0, 0, 1, 2, 1.5, 40);
surf(ax, xs, ys, zs, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', 'cyan');

% Voxels: one patch (all cubes) + one line object (all center dots),
% created once and updated in place on every slider move.
voxPatch = patch(ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k', 'FaceAlpha', 0.8);
voxDots  = plot3(ax, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', ...
    'MarkerSize', 6, 'LineStyle', 'none');

% Cube template: 8 corner offsets (in units of the voxel size) and 6 faces
corner = [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1]/2;
faceT  = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];

%% Build UI
sN = app.addControl('slider', 'Voxels per dimension $N = $', 1, 1, @updatePlot, ...
    'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d');

redraw(N0)

%% Callback
function updatePlot(~, ~)
    redraw(max(1, round(sN.Value)))
end

%% Redraw: all voxel math and geometry vectorized (no triple loop)
function redraw(N)
    dxyz = [diff(xlims) diff(ylims) diff(zlims)]/N;
    [X, Y, Z] = ndgrid(centers(xlims, N), centers(ylims, N), centers(zlims, N));
    inside = region(X, Y, Z);
    C = [X(inside), Y(inside), Z(inside)];     % centers of voxels inside the region
    n = size(C, 1);

    volume_sum = sum(f(C(:,1), C(:,2), C(:,3))) * prod(dxyz);

    % Vertices: 8 per voxel; faces: 6 per voxel, offset by 8 per voxel
    V = reshape(permute(reshape(C, n, 1, 3) + reshape(corner.*dxyz, 1, 8, 3), [2 1 3]), 8*n, 3);
    F = reshape(permute(faceT + 8*reshape(0:n-1, 1, 1, n), [1 3 2]), 6*n, 4);

    set(voxPatch, 'Faces', F, 'Vertices', V)
    set(voxDots, 'XData', C(:,1), 'YData', C(:,2), 'ZData', C(:,3))

    title(ax, sprintf(['Approximate Volume Integral = %.6f\n' ...
        'Total Cubes in Bounding Box = %d | Cubes Inside Region = %d\n' ...
        'Exact Region Volume (high-res) = %.6f'], volume_sum, N^3, n, exactVolume))
    app.fig.Name = sprintf('3D Volume Integral: approx = %.6f, N = %d', volume_sum, N);
    drawnow limitrate
end

end

%% Stateless helper
function c = centers(lims, N)
% Midpoints of N equal cells spanning lims
d = diff(lims)/N;
c = linspace(lims(1) + d/2, lims(2) - d/2, N);
end