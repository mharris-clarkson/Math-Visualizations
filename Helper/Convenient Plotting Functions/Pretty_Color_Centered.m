%% Function to change and balance colour map and produce a cbar
% cb = Pretty_Color_Centered(current_axis, cdata)
%   current_axis  - axis to apply to
%   cdata         - colour data to balance out
%   cb            - Returned colorbar
function varargout = Pretty_Color_Centered(current_axis,cdata,options)
% Pretty_Color_Centered is a helper function for changing to a diverging
% color map (provided by Kristen Thyng's cmocean function), centering
% it at zero and optionally adding a color bar.
%
%% Syntax
%
% cb = Pretty_Color_Centered(current_axis,cdata)
% cb = Pretty_Color_Centered(current_axis,cdata,'colorbar','off')
%
% Inputs:
%
% current_axis  - A axis handle for the axis to be modified.
% cdata         - A tensor for the color data for the colorbar.
% 'colorbar'    - 'on' (default) adds a colorbar, 'off' adds none and
%                 removes one that is already attached to the axis
%                 (same behaviour as Pretty_Color_Positive).
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

colormap(current_axis, Pretty_Colormap('balance'));

% Center the color axis (all-zero data falls back to [-1 1])
cmax = max(abs(cdata(:)));
if isempty(cmax) || ~isfinite(cmax) || cmax <= 0
    cmax = 1;
end
clim(current_axis,cmax*[-1,1]);

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