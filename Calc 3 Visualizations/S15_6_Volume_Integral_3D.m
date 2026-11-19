function S15_6_Volume_Integral_3D()
%% 3D Volume Integral with Voxels
% Approximates the triple integral of f over a 3D region E by a Riemann
% sum: f is sampled at the center of every N x N x N voxel whose center
% lies inside E and multiplied by the voxel volume. The title compares
%   - the Riemann sum with the (high-resolution) value of the integral, and
%   - the total volume of the voxels with the volume of E.
%
% When the slider reaches its maximum the plot jumps to the limit
% N -> infinity: the voxels are replaced by the region E itself and the
% Riemann sum by the value of the integral.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
f        = @(x,y,z) exp(-x.^2 - y.^2 - z.^2);          % Gaussian 3D
semiAxes = [1, 2, 1.5];                                 % ellipsoid semi-axes (x, y, z)
region   = @(x,y,z) (x/semiAxes(1)).^2 + (y/semiAxes(2)).^2 + (z/semiAxes(3)).^2 <= 1;

xlims = semiAxes(1)*[-1 1];   % bounding box of the region
ylims = semiAxes(2)*[-1 1];
zlims = semiAxes(3)*[-1 1];

N0       = 1;     % initial voxels per dimension
Nmax     = 100;   % slider maximum. Reaching it shows the limit N -> infinity
NdotsMax = 15;    % the voxel center dots are only drawn up to this N
resExact = 200;   % resolution of the reference integral and volume

voxelColor = [0.7 0.7 0.7];

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('3D Volume Integral', 1);
ax = app.ax(1);

Pretty_Plot(ax)
axis(ax, 'equal')
xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
view(ax, 45, 30)

%% Reference integral and volume (one 2D slab at a time -- no 200^3 arrays in memory)
boxSize = [diff(xlims) diff(ylims) diff(zlims)];
cx = centers(xlims, resExact);
cy = centers(ylims, resExact);
cz = centers(zlims, resExact);
[xg, yg] = ndgrid(cx, cy);
count = 0;
fsum  = 0;
for k = 1:resExact
    in    = region(xg, yg, cz(k));
    fk    = f(xg, yg, cz(k));
    count = count + nnz(in);
    fsum  = fsum + sum(fk(in));
end
cellVolume    = prod(boxSize) / resExact^3;
exactVolume   = count * cellVolume;   % volume of the region E
exactIntegral = fsum  * cellVolume;   % integral of f over E

%% Static graphics
[xs, ys, zs] = ellipsoid(0, 0, 0, semiAxes(1), semiAxes(2), semiAxes(3), 40);
hRegion = surf(ax, xs, ys, zs, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', 'cyan');

% Voxels: one patch (all visible voxel faces) + one line object (all center
% dots), created once and updated in place on every slider move.
voxPatch = patch(ax, 'Faces', zeros(0,4), 'Vertices', zeros(0,3), ...
    'FaceColor', voxelColor, 'EdgeColor', 'k', 'FaceAlpha', 0.8);
voxDots  = plot3(ax, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', ...
    'MarkerSize', 6, 'LineStyle', 'none');

% One voxel face: the 4 corner offsets (in units of the voxel size) within
% the plane of the face
quad = [-1 -1; 1 -1; 1 1; -1 1]/2;

%% Build UI
sN = app.addControl('slider', 'Voxels per dimension $N = $', 1, 1, @updatePlot, ...
    'Default', N0, 'Min', 1, 'Max', Nmax, 'Number_format', '%d', ...
    'colOrRow', 'row');

redraw(N0)

%% Callback
function updatePlot(~, ~)
    redraw(max(1, round(sN.Value)))
end

%% Redraw: all voxel math and geometry vectorized (no triple loop)
function redraw(N)
    if N >= Nmax
        showLimit()
        return
    end

    % Back to the voxel view (in case the last view was the limit)
    set(hRegion, 'FaceColor', 'cyan', 'FaceAlpha', 0.5, 'EdgeColor', 'none')
    set(voxPatch, 'Visible', 'on')

    dxyz = boxSize/N;
    [X, Y, Z] = ndgrid(centers(xlims, N), centers(ylims, N), centers(zlims, N));
    inside = region(X, Y, Z);
    C = [X(inside), Y(inside), Z(inside)];     % centers of voxels inside the region
    n = size(C, 1);

    % Riemann sum of f, and the total volume of the voxels
    riemann_sum  = sum(f(C(:,1), C(:,2), C(:,3))) * prod(dxyz);
    voxel_volume = n * prod(dxyz);

    % Only the voxel faces that touch the outside are drawn. Faces shared by
    % two inside voxels are hidden anyway, and skipping them keeps the
    % slider responsive for large N (about N^2 faces instead of 6*N^3).
    P = false(N+2, N+2, N+2);                  % inside mask with a border of "outside"
    P(2:end-1, 2:end-1, 2:end-1) = inside;
    V = zeros(0, 3);
    for a = 1:3                                % axis the face is perpendicular to
        others = setdiff(1:3, a);              % the two axes spanning the face
        for sgn = [-1 1]                       % face on the -a side or the +a side
            shift = [0 0 0];
            shift(a) = sgn;
            neighbor = P((2:N+1)+shift(1), (2:N+1)+shift(2), (2:N+1)+shift(3));
            exposed  = inside & ~neighbor;
            Cf = [X(exposed), Y(exposed), Z(exposed)];   % centers of those voxels
            m  = size(Cf, 1);

            % Corner offsets of this face from the voxel center
            off = zeros(4, 3);
            off(:, a)      = sgn/2;
            off(:, others) = quad;

            % m x 4 x 3 array of corners, flattened to 4 rows per face
            Vf = reshape(Cf, m, 1, 3) + reshape(off.*dxyz, 1, 4, 3);
            V  = [V; reshape(permute(Vf, [2 1 3]), 4*m, 3)]; %#ok<AGROW>
        end
    end
    F = reshape(1:size(V, 1), 4, []).';

    set(voxPatch, 'Faces', F, 'Vertices', V)
    if N <= NdotsMax
        set(voxDots, 'XData', C(:,1), 'YData', C(:,2), 'ZData', C(:,3))
    else
        set(voxDots, 'XData', NaN, 'YData', NaN, 'ZData', NaN)   % too many to be useful
    end

    title(ax, splitlines(sprintf(['Riemann sum of f over the voxels = %.6f   |   Integral of f = %.6f\n' ...
        'Voxels inside region = %d of %d   |   Volume of voxels = %.4f   |   Volume of region = %.4f'], ...
        riemann_sum, exactIntegral, n, N^3, voxel_volume, exactVolume)))
    app.fig.Name = sprintf('3D Volume Integral: Riemann sum = %.6f, N = %d', riemann_sum, N);
    drawnow limitrate
end

%% The limit N -> infinity: the voxels become the region itself
function showLimit()
    set(voxPatch, 'Visible', 'off')
    set(voxDots, 'XData', NaN, 'YData', NaN, 'ZData', NaN)

    % Draw the region as a solid in the voxel color, with a faint mesh so
    % its shape can be read
    set(hRegion, 'FaceColor', voxelColor, 'FaceAlpha', 1, ...
        'EdgeColor', 'k', 'EdgeAlpha', 0.25)

    % Overwrite the slider label to show the limit. The label goes back to
    % "N = ..." by itself the next time the slider moves.
    sN.UserData.label.String = 'Voxels per dimension $N \to \infty$';

    title(ax, splitlines(sprintf(['$N \\rightarrow \\infty$:   Riemann sum $\\rightarrow$ Integral of f = %.6f\n' ...
        'Volume of voxels $\\rightarrow$ Volume of region = %.4f'], ...
        exactIntegral, exactVolume)))
    app.fig.Name = sprintf('3D Volume Integral: limit N -> infinity, integral = %.6f', exactIntegral);
    drawnow limitrate
end

end

%% Stateless helper
function c = centers(lims, N)
% Midpoints of N equal cells spanning lims
d = diff(lims)/N;
c = linspace(lims(1) + d/2, lims(2) - d/2, N);
end