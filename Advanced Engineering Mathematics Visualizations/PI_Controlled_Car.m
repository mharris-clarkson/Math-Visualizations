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
app = uiFigure("KI Controlled Car$ ",1); % 3 is an optional argument to allow for more subplots

%% Optional math functions for plot computations
    function [Controlled_velocity] = Compute_Vel (ki, kp)
        % Define the Transfer function
        num = [kp/m  ki/m];
        den   = [1  (mu+kp)/m  ki/m];
        sys = tf(num, den);
        Controlled_velocity = lsim(sys, Desired_Path, t);
    end

%% Make the initial plots
Controlled_velocity = Compute_Vel (ki, kp);

plot(app.ax, t, Desired_Path,'r')
hold on
Car_Path = plot(app.ax, t,Controlled_velocity,'k');
hold off
title('PI Controlled Car')
Pretty_Plot(app.ax);



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