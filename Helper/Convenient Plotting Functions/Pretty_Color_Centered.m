%% Function to change and balance colour map and produce a cbar
% cb = Pretty_Color_Centered(current_axis, cdata)
%   current_axis  - axis to apply to
%   current_axis  - colour data to balance out
%   cb            - Returned colorbar
function cb = Pretty_Color_Centered(current_axis,cdata,options)
% Pretty_Color_Centered is a helper function for changing to a divergence 
% frees color map (provided by Kristen Thyng's cmocean function, centering 
% it, adding a color bar and shifting the colorbar for better 3D function 
% placement.
%
%% Syntax
%
% cb = Pretty_Color_Centered(current_axis,cdata)
%
% Inputs:
%
% current_axis  - A axis handle for the axis to be modified.
% cdata         - A tensor for the color data for the colorbar.
%
% Outputs:
%
% cb       - A handle to a colorbar.

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
colormap(current_axis, cmocean('balance'));
% Center the color axis
clim(current_axis,max(abs(cdata(:)))*[-1,1]);

% Place a colorbar and adjust its horizontal position
if strcmp(options.colorbar, 'on')
cb = colorbar(current_axis,'Location', 'eastoutside');
ax_pos = current_axis.Position;
current_axis.Position = ax_pos;
end
end