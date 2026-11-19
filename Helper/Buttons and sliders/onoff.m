function s = onoff(tf)
%% Turn true/false into 'on'/'off' for Visible-type properties
% Toggle to turn on/off the visability of plot objects. 
%
%% Syntax
%
% h.Visible = onoff(showPlane);
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
if tf
    s = 'on';
else
    s = 'off';
end
end
