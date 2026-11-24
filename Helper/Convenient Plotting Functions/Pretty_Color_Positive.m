%% Function to apply a sequential colour map to positive data and produce a cbar
% cb = Pretty_Color_Positive(current_axis, cdata)
%   current_axis  - axis to apply to
%   cdata         - colour data used to set the colour limits
%   cb            - Returned colorbar
function varargout = Pretty_Color_Positive(current_axis,cdata,options)
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

colormap(current_axis, Pretty_Colormap('amp'));

% Color axis [0, max] (no positive data falls back to [0 1])
cmax = max(cdata(:));
if isempty(cmax) || ~isfinite(cmax) || cmax <= 0
    cmax = 1;
end
clim(current_axis, [0, cmax]);

if strcmpi(options.colorbar, 'on')
    cb = colorbar(current_axis,'Location', 'eastoutside');
else
    colorbar(current_axis, 'off');
    cb = gobjects(0);
end
if nargout > 0
    varargout{1} = cb;
end
end