function S16_5_Laplacian()
%% Visualizes the Laplacian through the heat equation
%
%    dT/dt = lap T = T_xx + T_yy   on the square [-L,L]^2, insulated edges
%
%  (no heat flows in or out through the edges).
%    Left   : the temperature T(x,y,t) as a surface. The axes and colors are
%             fixed, so you can watch it flatten out toward its average,
%             which never changes because the edges are insulated.
%    Middle : the heat flow -grad T (arrows, from hot to cold, across the
%             level curves of T). The arrows shrink as T evens out.
%    Right  : the Laplacian lap T. By the heat equation it IS the rate of
%             change dT/dt: red where T is warming, blue where it is cooling.
%  Controls: time slider and a button that cycles through three starting
%  temperatures.
%
%  The solution is exact (no time stepping): T is a cosine series in the
%  eigenfunctions of the Laplacian with insulated edges, and each term
%  decays like exp(-lambda t). The gradient and the Laplacian come from the
%  same series, so they have no edge errors.
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
N    = 100;     % grid points in each direction
L    = 2;       % domain half-width
tMax = 0.5;     % end of the time slider

% Starting temperatures (cycled by a button)
ICnames = {'one cosine mode', 'hot and cold spots', 'hot square'};
ICs = {@(x,y) 0.5 + 0.4*cos(pi*x/L).*cos(pi*y/L), ...
       @(x,y) 0.5 + 0.45*exp(-((x-0.8).^2 + (y-0.6).^2)/0.15) ...
                  - 0.35*exp(-((x+0.7).^2 + (y+0.6).^2)/0.10), ...
       @(x,y) double(abs(x) < 0.6 & abs(y) < 0.6)};
icIdx = 2;      % starting choice

% Arrows and level curves in the middle plot
nArrows   = 12;   % arrows per side
arrowFrac = 0.9;  % longest arrow (just after t = 0) as a fraction of the arrow spacing
nLevels   = 12;   % level curves of T
tRef      = 0.005;% time used to fix the arrow and Laplacian scales (the hot
                  % square has infinite slope exactly at t = 0)

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plots and all UI elements
app = uiFigure('Heat Equation: Temperature, Heat Flow and Laplacian', 3);
ax1 = app.ax(1); % temperature
ax2 = app.ax(2); % heat flow
ax3 = app.ax(3); % Laplacian

%% Optional math functions for plot computations
% T, its gradient at the arrow points and its Laplacian at time t, from
% the cosine series: T = sum A_nm exp(-lambda_nm t) cos(k_n (y+L)) cos(k_m (x+L))
    function [Tt, Tx, Ty, LapT] = solution(t)
        B    = A .* exp(-Lam*t);
        Tt   = Cb*B*Cb';                  % rows = y, columns = x
        LapT = Cb*(-Lam.*B)*Cb';          % lap(cos cos) = -lambda cos cos
        Tx   = Cb(iq,:)*B*Sb(iq,:)';      % d/dx acts on the x (column) basis
        Ty   = Sb(iq,:)*B*Cb(iq,:)';      % d/dy acts on the y (row) basis
    end

% New starting temperature: series coefficients and fixed plot scales
    function setIC(iIC)
        f0 = ICs{iIC}(xg, yg);
        A  = (Cb' * f0 * Cb) ./ (w(:) * w);   % orthogonality of the cosine basis
        Tmean  = A(1,1);                      % the constant term = the average

        Trange = [min(f0(:)) max(f0(:))];
        [~, Tx0, Ty0, Lap0] = solution(tRef);
        arrowScale = arrowFrac * spacing / max(hypot(Tx0(:), Ty0(:)));
        lapScale   = max(abs(Lap0(:)));
        if lapScale>40 % catch for hot square
            lapScale = 5;
        end

        clim(ax1, Trange);  zlim(ax1, Trange);
        clim(ax3, lapScale*[-1 1]);
        set(hC, 'LevelList', linspace(Trange(1), Trange(2), nLevels + 2));
    end

%% Precompute math for updates
% Cell-centred grid: makes the cosine basis exactly orthogonal on the grid
h  = 2*L/N;
x  = -L + h*((1:N) - 0.5);
y  = x;
[xg, yg] = meshgrid(x, y);

% Insulated-edge eigenfunctions cos(k_m (x+L)), k_m = m pi/(2L), m = 0..N-1
m   = 0:N-1;
k   = m*pi/(2*L);
Cb  = cos(((1:N)' - 0.5) * m*pi/N);        % Cb(i,m+1) = cos(k_m (x_i + L))
Sb  = -sin(((1:N)' - 0.5) * m*pi/N) .* k;  % its x derivative
w   = [N, (N/2)*ones(1, N-1)];             % sum over the grid of Cb(:,m+1).^2
Lam = k(:).^2 + k.^2;                      % eigenvalues lambda_nm = k_n^2 + k_m^2

% Arrow points (evenly spaced, away from the edges)
iq = round(linspace(1, N, nArrows + 2));
iq = iq(2:end-1);
spacing = x(iq(2)) - x(iq(1));

% Starting temperature for the first plots (setIC fills in the rest)
f0init = ICs{icIdx}(xg, yg);
A = []; Tmean = []; arrowScale = []; lapScale = [];

%% Make the initial plots
% Left: temperature surface
hSurf = surf(ax1, x, y, f0init, 'EdgeColor', 'none', 'FaceColor', 'interp');
colormap(ax1, Pretty_Colormap('amp'))
cb1 = colorbar(ax1);
cb1.Label.String = '$T$';

% Middle: level curves of T and the heat flow -grad T
[~, hC] = contour(ax2, x, y, f0init, 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
hQ = quiver(ax2, xg(iq,iq), yg(iq,iq), zeros(numel(iq)), zeros(numel(iq)), 0, ...
    'Color', [0.75 0 0], 'LineWidth', 1.5, 'MaxHeadSize', 0.6);

% Right: Laplacian = dT/dt (red = warming, blue = cooling)
hLap = imagesc(ax3, x, y, f0init);
set(ax3, 'YDir', 'normal')
colormap(ax3, Pretty_Colormap('balance'))
cb3 = colorbar(ax3);
cb3.Label.String = '$\frac{\partial T}{\partial t}$';

% Colorbar labels are not covered by the figure's LaTeX defaults
for cbk = [cb1 cb3]
    cbk.Label.Interpreter = 'latex';
    cbk.Label.FontSize    = ax1.FontSize;
end

%% Plot elements are done - Make pretty
Pretty_Plot(ax1);
Pretty_Plot(ax2);
Pretty_Plot(ax3);
zlabel(ax1, '$T$')
view(ax1, -35, 25)
xlim(ax1, [-L L]); ylim(ax1, [-L L]);
axis(ax2, 'image'); axis(ax3, 'image');
xlim(ax2, [-L L]); ylim(ax2, [-L L]);
xlim(ax3, [-L L]); ylim(ax3, [-L L]);
grid(ax3, 'off')

hTitle1 = title(ax1, '');
title(ax2, {'Heat flow $-\nabla T$', 'from hot to cold, across level curves'})
title(ax3, {'$\frac{\partial T}{\partial t} = \nabla^2 T$', 'red: warming, blue: cooling'})

% What is being solved, over all three plots
sgtitle(app.fig, ['Solving the heat equation  $\frac{\partial T}{\partial t} = \nabla^2 T$' ...
    '  on a square with insulated edges'], ...
    'Interpreter', 'latex', 'FontSize', 22);

%% Build UI
NumControls = 2;

tSlider = app.addControl('slider', '$t = $', 1, NumControls, @updatePlot, ...
    'Default', 0, 'Min', 0, 'Max', tMax, 'Number_format', '%.3f', 'colOrRow', 'row');

btnIC = app.addControl('button', ['Start: ' ICnames{icIdx}], 2, NumControls, @nextIC, ...
    'colOrRow', 'row');

% Equal panels below the overall title. The gaps leave room for the
% colorbars of the left and right plots.
panelW = 0.22;
panelH = 0.56;
panelB = 0.22;
ax1.Position = [0.05, panelB, panelW, panelH];
ax2.Position = [0.40, panelB, panelW, panelH];
ax3.Position = [0.70, panelB, panelW, panelH];

setIC(icIdx)
updatePlot()

%% Functions for UI elements
% Cycle the starting temperature and go back to t = 0
    function nextIC(~, ~)
        icIdx = mod(icIdx, numel(ICs)) + 1;
        btnIC.String = ['Start: ' ICnames{icIdx}];
        setIC(icIdx)
        tSlider.Value = 0;
        updatePlot()
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        if ~isvalid(app.fig), return, end
        t = tSlider.Value;
        [Tt, Tx, Ty, LapT] = solution(t);

        set(hSurf, 'ZData', Tt, 'CData', Tt)
        set(hC,    'ZData', Tt)
        set(hQ,    'UData', -arrowScale*Tx, 'VData', -arrowScale*Ty)
        set(hLap,  'CData', LapT)

        hTitle1.String = {sprintf('Temperature $T$ ')};
    end
end