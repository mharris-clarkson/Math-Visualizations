function demo()
%% This demo test shows how the uiFigure class works to update intended
%  functionality and serves as a psudo unit test (not a real unit test) for
%  the UIApplet class, the uiGrid function and the Pretty_plot function
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all % Close all Windows

%% User parameters for math objects. Adjust these to modify all math objects
%  below.
% Starting values for sliders. Must be in chosen range or else you will get
% and error. Forcing this check manually is tedious so the check might not
% be done. An error on the user's part should not be fatal
f0 = 1;
amp0 = 1;
xmax = 10; % Maximum value for x

% Slider limits. These pick the ranges for any given sliders. See warning
% above regarding the initial values.
f0Min = 1/xmax;
f0Max = 2;
ampMin = -2;
ampMax = 2;

Plots_to_test = 1; % Number of plots to test. Must be 1, 2 or 3.

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("Demo/Test",Plots_to_test); % 3 is an optional argument to allow for more subplots


%% Optional math functions for plot computations
% Example user function. Not needed here... but good to give an example
    function  y = mysin(x)
        y = sin(x);
    end

%% Make the initial plots
% Store default values for reset button made later
amp = amp0; f = f0;

% Compute initial (x,y) data
x = linspace(0, xmax, 500);
y = amp*mysin(f*x);

% Plot the objects on plot app.ax(1) -- the first subplot
Curve = plot(app.ax(1),x,y, 'LineWidth',2');  % main curve
plot(app.ax(1),x,0*x,'--k','LineWidth',2);  % reference line

% Fix y lims to fit the max amplitude wave.
ylim(app.ax(1),ampMax*[-1,1])

% Add a title to axis 1
title(app.ax(1),'Explore the Function: $A\sin\left(2\pi f x\right)$',...
    'Interpreter','latex')




if Plots_to_test > 1
    % Add "random" plot to second axis
    [X,Y,Z] = peaks;
    surf(app.ax(2),X,Y,Z)

    % Center the plot and apply divergence free color plot
    cb = Pretty_Color_Centered(app.ax(2),Z);

    % Set default view for 3D plot
    view(app.ax(2), 45,30)

    % Add a title to axis 2
    title(app.ax(2),'Peaks ','Interpreter','latex')
end





if Plots_to_test >= 3
    % Add another "Random plot
    axes(app.ax(3));
    spy();

    % Add a title to axis 3
    title(app.ax(3),'Dogo ','Interpreter','latex')
end

%% Precompute math for updates
% Optional section to define computations for all plot updates. Only needed
% if computations slow down the updates in the update() function defined at
% the end. Formally it is best to precompute all slider values but this is
% tricky as slider values are based on internal slider percent updates. Can
% ignore unless figure is not sufficiently responsive.

%% Build UI
NumControls = 10; % maximum number of controls
CorOrRow = 'col'; % options 'row' and 'col'

sliderFreq = app.addControl('slider', 'Frequency $f = $', 1, NumControls,  @Sliderfreq,...
    'colOrRow', CorOrRow,'Default',f0,...
    'Min',f0Min,'Max',f0Max);

sliderAmp = app.addControl('slider', 'Amplitude $A = $', 2, NumControls,  @sliderA,...
    'colOrRow', CorOrRow,'Default',amp0,...
    'Min',ampMin,'Max',ampMax);

app.addControl('button', 'Reset', 3, NumControls,  @reset,...
    'colOrRow', CorOrRow); % no handle as this does not change properties.

btnColor = app.addControl('button', 'Change Line Color to Red', 4, NumControls,  @ColorChange,...
    'colOrRow', CorOrRow);

btnColorable = app.addControl('button', 'Button with ColorChange on ', 5, NumControls,  @update,...
    'colOrRow', CorOrRow,'ColorChange',1); % button when clicked just changes color

app.addControl('button', 'Change Color of Button Below', 6, NumControls,  @ColorToggle,...
    'colOrRow', CorOrRow); % no handle as this does not change properties.

btnSliderLock = app.addControl('button', 'Turn Sliders Off', 7, NumControls,  @SliderToggle,...
    'colOrRow', CorOrRow);

% Extra fill buttons to show spacing for large numbers of buttons
for i=8:NumControls
    app.addControl('button', ['Filler ' num2str(i)], i, NumControls,  @SliderToggle,...
        'colOrRow', CorOrRow); % no handle as these do not change properties.
end

% Launch update function
update();

%% Functions for UI elements
% Update function for omega slider
    function Sliderfreq(~,~)

        update();
    end

% Update function for amp slider
    function sliderA(~,~)
        update();
    end

% Update function for reset slider. This sets the sliders to their default
% position and value and updates the labels
    function reset(~,~)
        % Reset Slider values
        app.UpdateUISlider(sliderFreq,f0);
        app.UpdateUISlider(sliderAmp,amp0);

        % Update the plot
        update();
    end

    function ColorChange(~,~)
        if btnColor.Value % if state  is 1 (button has already been pressed)
            % Update button string
            btnColor.String = 'Change Line Color to Blue';

            % Update curve color
            Curve.Color = 'r';
        else
            % Update button string
            btnColor.String = 'Change Line Color to Red';

            % Update curve color
            Curve.Color = 'b';
        end
    end

    function ColorToggle(~,~)
        % Flip color bool value. This goes into the item for the custom
        % buttons to update its data.
        color = ~btnColorable.UserData.Value;

        % Push color state to custom button
        btnColorable.UserData.setColor(color);
    end

    function SliderToggle(~,~)
        if btnSliderLock.Value % If button is 'on', change visability value
            sliderFreq.Visible = 'off';
            sliderAmp.Visible='off';

            % Change button text
            btnSliderLock.String='Turn Sliders on';
        else % If button is 'off', change visability value
            sliderFreq.Visible = 'on';
            sliderAmp.Visible='on';

            % Change button text
            btnSliderLock.String='Turn Sliders off';
        end
    end

%% Main Draw update function. All initial plot functions are updated below.
%  Generally this will use the math functions defined in the section
%  "Optional math functions for plot computations" above or the data
%  generated in the "Precompute math for updates" section above. Note that
%  it is better to precompute everything but for many applications
%  precomputing the data is not needed and precomputing and looking up the
%  data is annoying to implement in practice.
    function update(~,~)
        % Compute things or ideally look up/interoperate known lookup values.

        y = sliderAmp.Value*mysin(2*pi*sliderFreq.Value*x);

        % Update plot item
        set(Curve,'YData',y)

        % Repeat for any other math data
    end
end
