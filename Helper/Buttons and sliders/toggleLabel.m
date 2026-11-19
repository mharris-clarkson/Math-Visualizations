function s = toggleLabel(tf, name)
%% Button text for a show/hide toggle: toggleLabel(true,'Plane') -> 'Hide Plane'
% Allows toggling of for buttons that change what they do when pressed
% without the local hardcoding that was previously done
%
%% Syntax
%
% btn.String = toggleLabel(showPlane, 'Plane');
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
if tf
    s = ['Hide ', name];
else
    s = ['Show ', name];
end
end
