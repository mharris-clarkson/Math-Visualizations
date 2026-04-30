%% Function to set plot labels, grid, etc.
% Pretty_Plot(current_axis)
%   current_axis  - axis to make pretty
function Pretty_Plot(current_axis)
arguments
    current_axis
end

xlabel(current_axis, 'x');
ylabel(current_axis, 'y');
zlabel(current_axis, 'z');
set(current_axis,'Fontsize', 18);

grid(current_axis, 'on');
axis(current_axis, 'tight');

end