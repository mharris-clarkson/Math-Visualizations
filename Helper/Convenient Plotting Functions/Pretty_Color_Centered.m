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

% Use the balance colormap
colormap(current_axis, Pretty_Colormap('balance')); % cached copy of cmocean('balance')
% Center the color axis. Guard against all-zero data, which would give an
% invalid (non-increasing) color range.
cmax = max(abs(cdata(:)));
if isempty(cmax) || ~isfinite(cmax) || cmax <= 0
    cmax = 1;
end
clim(current_axis,cmax*[-1,1]);

% Place a colorbar only when asked to
if strcmpi(options.colorbar, 'on')
    cb = colorbar(current_axis,'Location', 'eastoutside');
else
    colorbar(current_axis, 'off');   % as in Pretty_Color_Positive
    cb = gobjects(0); % nothing to return in the 'off' case
end
% Only hand back the colorbar when asked for it, so a call without a
% semicolon does not print "ans = 0x0 empty GraphicsPlaceholder array"
if nargout > 0
    varargout{1} = cb;
end
end