%% Function to set plot labels, grid, etc.
% Pretty_Plot(current_axis)
%   current_axis  - axis to make pretty
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function Pretty_Plot(current_axis)
arguments
    current_axis
end

xlabel(current_axis, '$x$', 'Interpreter', 'latex');
ylabel(current_axis, '$y$', 'Interpreter', 'latex');
zlabel(current_axis, '$z$', 'Interpreter', 'latex');
set(current_axis, 'TickLabelInterpreter', 'latex');
set(current_axis,'Fontsize', 18);

grid(current_axis, 'on');
axis(current_axis, 'tight');

end