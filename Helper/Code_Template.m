function Code_Template()
%% Template for new visualizations
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects. 
% Adjust these to modify selected math objects below.
omega0 = 1;
amp0 = 1;
xmax = 10; 

% Slider limits. These pick the ranges for any given sliders. See warning
% above regarding the initial values.
omegaMin = 0;
omegaMax = 2;

Plots_to_test = 1; 

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = UIApplet("Mixed Controls",Plots_to_test); % Plots_to_test is an optional argument to allow for more subplots


%% Optional math functions for plot computations






%% ============== Make the initial plots =================================
% Store default values for reset button made later
amp = amp0; omega = omega0;

% Compute initial (x,y) data
x = linspace(0, xmax, 500);
y = amp*sin(omega*x);

% Plot the objects on plot app.ax(1) -- the first subplot
Curve = plot(app.ax(1),x,y);  % main curve
plot(app.ax(1),x,0*x,'--k');  % reference line

% Fix y lims to fit the max amplitude wave.
ylim(app.ax(1),amp*[-2,2])

% Add a title to axis 1
title(app.ax(1),'Explore the Function: $A\sin(\omega x)$',...
    'Interpreter','latex')

%% Precompute math for updates






%% Build UI
NumControls = 3; % maximum number of controls
CorOrRow = 'col'; % options 'row' and 'col'

sliderFreq = app.addControl('slider', 'Frequency $\omega = $', 1, NumControls,  @SliderOmega,...
    'colOrRow', CorOrRow,'Default',omega0,...
    'Min',omegaMin,'Max',omegaMax);

sliderAmp = app.addControl('slider', 'Amplitude $A = $', 2, NumControls,  @sliderA,...
    'colOrRow', CorOrRow,'Default',amp,...
    'Min',-2,'Max',2);

app.addControl('button', 'Reset', 3, NumControls,  @reset,...
    'colOrRow', CorOrRow); % no handle as this does not change properties.



% Launch update function
update();

%% Functions for UI elements
% Update function for omega slider
    function SliderOmega(src,~)
        % Update omega value
        omega = src.Value;

        % Update the plot
        update();
    end

% Update function for amp slider
    function sliderA(src,~)
        % Update amp value
        amp = src.Value;

        % Update the plot
        update();
    end

% Update function for reset slider. This sets the sliders to their default
% position and value and updates the labels
    function reset(~,~)
        % Reset  to default values
        amp = amp0; omega = omega0;

        % update UI elements. Sliders auto change position
        sliderFreq.Value = omega;
        sliderAmp.Value = amp;

        % Update the plot
        update();
    end


%% Main Draw update function. All initial plot functions are updated below.
    function update(~,~)
        % Compute things or ideally look up/interoperate known lookup values.
        y = amp*sin(omega*x);

        % Update plot item
        set(Curve,'YData',y)

        % Repeat for any other math data
    end

% How to force change sliders:
% dtSlider.UserData.label.String = '$\Delta x \to 0$'; % update string

end
