function KHIPlotData()
%% Visualizes Kelvin-Helmholtz instability simulation data. Shows velocity
%  magnitude with quiver arrows and (optionally) vorticity side-by-side.
%  A slider scrubs through time snapshots. A toggle button adds/removes
%  the vorticity panel live.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
stride = 8;     % quiver subsampling stride
scale  = 0.15;  % quiver arrow scale factor

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Load data, or run the simulation to create it
dataFile = fullfile(fileparts(mfilename('fullpath')), 'KH_data.mat');
if isfile(dataFile)
     data = load(dataFile);
else
    fprintf('KH_data.mat not found. Running fluids simulation.\n This will take a while.\n')
    runSimulation()
    data = load(dataFile);
end

x             = data.x;
y             = data.y;
U_store       = data.U_store;
V_store       = data.V_store;
VEL_store     = sqrt(U_store.^2 + V_store.^2);
VORT_store    = data.VORT_store;
T_store       = data.T_store;
num_snapshots = length(T_store);

xLim = [min(x), max(x)];
yLim = [min(y), max(y)];

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Kelvin-Helmholtz Instability', 1);
delete(app.ax)  % axes are built by buildAxes

% State
plotVorticity = false;
ax_vel   = [];
ax_vort  = [];
hImgVel  = [];
hQuiver  = [];
hImgVort = [];

%% Build UI first, so the plot area above the controls is known
NumControls = 2;

tSlider = app.addControl('slider', '$t$ Index $ = $', 1, NumControls, @updatePlot, ...
    'Default', 1, 'Min', 1, 'Max', num_snapshots, 'Number_format', '%d', 'colOrRow', 'row', ...
    'Step', 1);

btnVort = app.addControl('button', '', 2, NumControls, ...
    @toggleVorticity, 'ColorChange', true, 'colOrRow', 'row', ...
    'Toggle', ["Vorticity: OFF", "Vorticity: ON"]);

%% Plot area above the controls
ctrlBottom   = tSlider.Position(2);
ctrlHeight   = tSlider.Position(4);
PLOT_BOTTOM  = ctrlBottom + ctrlHeight + 0.12;
PLOT_HEIGHT  = 1 - PLOT_BOTTOM - 0.05;
MARGIN_L     = 0.07;
MARGIN_R     = 0.04;
GAP          = 0.03;

%% Make the initial plots
buildAxes()

%% Build or rebuild the plot axes
    function buildAxes()
        if ~isempty(ax_vel)  && isvalid(ax_vel);  delete(ax_vel);  end
        if ~isempty(ax_vort) && isvalid(ax_vort); delete(ax_vort); end

        idx = round(tSlider.Value);

        if plotVorticity
            w = (1 - MARGIN_L - MARGIN_R - GAP) / 2;
            ax_vel  = axes('Parent', app.fig, ...
                'Position', [MARGIN_L,              PLOT_BOTTOM, w, PLOT_HEIGHT]);
            ax_vort = axes('Parent', app.fig, ...
                'Position', [MARGIN_L + w + GAP,    PLOT_BOTTOM, w, PLOT_HEIGHT]);
        else
            w = 1 - MARGIN_L - MARGIN_R;
            ax_vel  = axes('Parent', app.fig, ...
                'Position', [MARGIN_L, PLOT_BOTTOM, w, PLOT_HEIGHT]);
            ax_vort = [];
        end

        % --- Velocity panel ---
        hImgVel = pcolor(ax_vel, x, y, VEL_store(:,:,idx));
        shading(ax_vel,'interp')
        Pretty_Color_Positive(ax_vel, [0,3]);
        hold(ax_vel, 'on')
        hQuiver = quiver(ax_vel, ...
            x(1:stride:end), y(1:stride:end), ...
            scale*U_store(1:stride:end, 1:stride:end, idx), ...
            scale*V_store(1:stride:end, 1:stride:end, idx), ...
            0, 'k');
        hold(ax_vel, 'off')
        Pretty_Plot(ax_vel)

        % --- Vorticity panel ---
        if plotVorticity
            hImgVort = pcolor(ax_vort, x, y, VORT_store(:,:,idx));
            shading(ax_vort,'interp')
            Pretty_Color_Centered(ax_vort, VORT_store(:,:,end));
            title(ax_vort, 'Vorticity')
            Pretty_Plot(ax_vort)
            ylabel(ax_vort,'')
            yticks(ax_vort,[])
        end

        updatePlot()
    end

%% Functions for UI elements
    function toggleVorticity(~, ~)
        plotVorticity = logical(btnVort.Value);
        buildAxes()
    end

    function updateTitle(idx)
        title(ax_vel, sprintf('Velocity Field,  $t = %.2f$', T_store(idx)))
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        idx = round(tSlider.Value);
        set(hImgVel, 'CData', VEL_store(:,:,idx))
        set(hQuiver, ...
            'UData', scale * U_store(1:stride:end, 1:stride:end, idx), ...
            'VData', scale * V_store(1:stride:end, 1:stride:end, idx))
        xlim(ax_vel, xLim);
        ylim(ax_vel, yLim);
        if plotVorticity
            set(hImgVort, 'CData', VORT_store(:,:,idx))
        end
        updateTitle(idx)
    end
end

%% Run the simulation script in its own workspace (it clears variables)
function runSimulation()
run(fullfile(fileparts(mfilename('fullpath')), 'Run_KHI_Sim.m'))
close all   % the simulation's own preview figure
end