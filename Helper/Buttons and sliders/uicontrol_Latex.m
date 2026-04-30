function Button = uicontrol_Latex(fig, options)
% uicontrol_Latex is a helper function for creating dynamic buttons in
% matlab that allow the user to use LaTeX fonts.
%
%% Syntax
%
% Button = uicontrol_Latex(fig, options)
%
% Inputs:
%
% fig           - A figure handle for the figure to place the button on
% options:
%           'String'   - A string for the name of the button.
%           'Position' - A double array with position data for the button.
%           'FontSize' - A double for the fontsize.
%           'Visible'  - A string for initial viaibility
%           'CallbackFcn' - A local function to define the behaviour of the
%                           button.
%           Options.Color_change  - A bool for enabling color change when clicked
%
% Outputs:
%
% Button - A handle to the created button object.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
arguments
    fig                       matlab.ui.Figure
    options.String   string   = ""
    options.Position double   = [0 0 0.1 0.05]
    options.FontSize double   = 18
    options.Visible   string   = "on"
    options.Callback          = @(~,~) []
    options.Color_change logical = false % need extra class to 

end

% Read and store data from options
Button_Name     = options.String;
Button_Position = options.Position;
FontSize        = options.FontSize;
CallbackFcn     = options.Callback;

%% Invisible zero-size togglebutton — that stores .Value and .String
Button = uicontrol(fig, ...
    'Style',    'togglebutton', ...
    'String',   '', ...
    'Units',    'normalized', ...
    'Position', [0 0 0 0], ...
    'Visible',  options.Visible, ...
    'Callback', CallbackFcn);


%% Axes that fills the button region — handles visuals and clicks

    ax = axes(fig, ...
        'Units',    'normalized', ...
        'Position', Button_Position, ...
        'XLim',     [0 1],...
        'YLim',     [0 1], ...
        'Visible',  'on', ...
        'XTick',    [], ...
        'YTick',    []);


% Disable all built-in axes UI controls
disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';

%% Draw button background patch showing clickable region
btn_patch = patch(ax, ...
    [0 1 1 0], [0 0 1 1], [0.94 0.94 0.94], ...
    'EdgeColor', [0.5 0.5 0.5], ...
    'LineWidth',  1.5);

%% LaTeX label
btn_text = text(ax, 0.5, 0.5, '', ...
    'Interpreter',         'latex', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment',   'middle', ...
    'FontSize',            FontSize);

%% Listener: any write to Button.String syncs to the visible text object
addlistener(Button, 'String', 'PostSet', @(~,~) syncLabel(Button, btn_text));

%% Listener: allows the button region to be turned off
addlistener(Button, 'Visible', 'PostSet', @(~,~) syncVisible(Button, ax));


%% Seed the string — fires the listener so btn_text is immediately populated
Button.String = Button_Name;

%% Store cross-references
ax.UserData.button   = Button;
ax.UserData.patch    = btn_patch;
ax.UserData.label    = btn_text;
ax.UserData.callback = CallbackFcn;

Button.UserData.String  = Button_Name;
Button.UserData.Value   = false;
Button.UserData.label   = btn_text;
Button.UserData.patch   = btn_patch;
Button.UserData.ax      = ax;
Button.UserData.callback = CallbackFcn;
Button.UserData.ax_position = Button_Position;
Button.UserData.Color_change = options.Color_change;
Button.UserData.setColor = @(state) setButtonColor(Button, state);
btn_text.String = Button_Name;


%% Initial visible check
syncVisible(Button, ax)


%% Attach click handler to axes, patch, and text
clickFcn = @(src, event) toggleButton(src, event, ax);
set(ax,        'ButtonDownFcn', clickFcn);
set(btn_patch, 'ButtonDownFcn', clickFcn);
set(btn_text,  'ButtonDownFcn', clickFcn);

end


%% -----------------------------------------------------------------------
% Button toggle function
function toggleButton(~, ~, ax)

ud  = ax.UserData;
btn = ud.button;

btn.Value = ~btn.Value;

% optional colorchange
if btn.UserData.Color_change
    setButtonColor(btn, btn.Value);
end

% callback
ud.callback(btn, []);
end


%% -----------------------------------------------------------------------
% Button string update function
function syncLabel(btn, btn_text)
btn_text.String = btn.String;
end

%% -----------------------------------------------------------------------
% Button visability option
function syncVisible(btn, ax)
if strcmp(btn.Visible, 'off')
    set(ax.Children, 'Visible', 'off');
    ax.Position = [0 0 0 0];
else
    ax.Position = btn.UserData.ax_position;
    set(ax.Children, 'Visible', 'on');
end
end

%% -----------------------------------------------------------------------
% force set button color
function setButtonColor(btn, state)
ud = btn.UserData;

if state
    ud.patch.FaceColor = [0.75 0.85 1.0];
    ud.patch.LineWidth = 2.5;
else
    ud.patch.FaceColor = [0.94 0.94 0.94];
    ud.patch.LineWidth = 1.5;
end

btn.UserData.Value = logical(state);
end