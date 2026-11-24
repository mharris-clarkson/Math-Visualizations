function PI_Controlled_Car()
%% This function shows the output of a PI controlled car
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all % Close all Windows

%% User parameters for math objects. Adjust these to modify all math objects
%  below.

% Car parameters
m  = 1;
mu = 0.5;

% Desired path
t=linspace(0,50,5000);
Desired_Path = 60 * (t > 1);

% Desired_Path = 30*(erf(0.1*(t-20))+1)

% Controller parameters
kp = 1;
ki = 0;
% Slider range
SliderpMin = 0;
SliderpMax = 5;
SlideriMin = 0;
SlideriMax = 1;




%% ========== Code below here is for making the visualizations ============
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("PI Controlled Car",1); % 3 is an optional argument to allow for more subplots

%% Optional math functions for plot computations
    function [Controlled_velocity] = Compute_Vel (ki, kp)
        % Car: m v' = -mu v + u, controller u = kp e + ki int e, e = r - v.
        % Transfer function V/R = (kp s + ki)/(m s^2 + (mu+kp) s + ki), i.e.
        %   num = [kp/m  ki/m],  den = [1  (mu+kp)/m  ki/m]
        % (tf/lsim need the Control System Toolbox). Same system in state
        % space, stepped exactly over each dt with the input held constant
        % (zero-order hold), using base MATLAB only:
        A = [0, 1; -ki/m, -(mu+kp)/m];
        B = [0; 1];
        C = [ki/m, kp/m];
        dt = t(2) - t(1);
        E  = expm([A, B; 0, 0, 0]*dt);   % gives exp(A dt) and int_0^dt exp(A s) ds B
        Ad = E(1:2, 1:2);
        Bd = E(1:2, 3);
        x  = [0; 0];
        Controlled_velocity = zeros(size(t));
        for k = 1:numel(t)
            Controlled_velocity(k) = C*x;
            x = Ad*x + Bd*Desired_Path(k);
        end
    end

%% Make the initial plots
Controlled_velocity = Compute_Vel (ki, kp);

plot(app.ax, t, Desired_Path,'r')
Car_Path = plot(app.ax, t,Controlled_velocity,'k');   % (uiFigure already set hold on)
title(app.ax, 'PI Controlled Car')
Pretty_Plot(app.ax);
xlabel(app.ax, 'Time $t$')
ylabel(app.ax, 'Speed $v(t)$')
legend(app.ax, {'Desired speed', 'Car speed'}, 'Location', 'southeast')



%% Precompute math for updates
% Skip


%% UI layout and updates
Num_GUI = 2;

% Sliders for kp and ki
kpSlider = app.addControl('slider', '$k_p = $ ', 1, Num_GUI, @updatePlot,...
    'Min',SliderpMin,'Max',SliderpMax,'Default', kp);

kiSlider = app.addControl('slider', '$k_i = $ ', 2, Num_GUI, @updatePlot,...
    'Min',SlideriMin,'Max',SlideriMax,'Default', ki);

function updatePlot(~,~)
    % Grab data
    kp = kpSlider.Value;
    ki = kiSlider.Value;

    % Compute solution
    Controlled_velocity = Compute_Vel (ki, kp);

    % update plot
   set(Car_Path,'YData',Controlled_velocity);
end


end