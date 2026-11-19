%% Function to apply a sequential colour map to positive data and produce a cbar
% cb = Pretty_Color_Positive(current_axis, cdata)
%   current_axis  - axis to apply to
%   cdata         - colour data used to set the colour limits
%   cb            - Returned colorbar
function cb = Pretty_Color_Positive(current_axis,cdata,options)
% Pretty_Color_Positive is a helper function for changing to a sequential
% color map (provided by Kristen Thyng's cmocean function), setting the
% color limits to [0, max(cdata)] and optionally adding a color bar.
%
%% Syntax
%
% cb = Pretty_Color_Positive(current_axis,cdata)
% cb = Pretty_Color_Positive(current_axis,cdata,'colorbar','off')
%
% Inputs:
%
% current_axis  - A axis handle for the axis to be modified.
% cdata         - A tensor for the color data for the colorbar.
% 'colorbar'    - 'on' (default) adds a colorbar, 'off' adds none and
%                 removes one that is already attached to the axis.
%
% Outputs:
%
% cb       - A handle to a colorbar (empty when 'colorbar' is 'off').

%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
arguments
    current_axis
    cdata
    options.colorbar = 'on'
end

% Use the amp colormap
colormap(current_axis, Pretty_Colormap('amp')); % cached copy of cmocean('amp')

% Set the color axis to [0, max]. Guard against data with no positive
% values, which would give an invalid (non-increasing) color range.
cmax = max(cdata(:));
if isempty(cmax) || ~isfinite(cmax) || cmax <= 0
    cmax = 1;
end
clim(current_axis, [0, cmax]);

% Place a colorbar only when asked to
if strcmpi(options.colorbar, 'on')
    cb = colorbar(current_axis,'Location', 'eastoutside');
else
    colorbar(current_axis, 'off');
    cb = gobjects(0);
end
end
