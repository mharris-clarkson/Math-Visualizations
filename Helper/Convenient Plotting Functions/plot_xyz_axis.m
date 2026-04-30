function plot_xyz_axis(ax, xmax, ymax, zmax)
% plot_xyz_axis plots lines for the x, y and z axis 
%
%% Syntax
%
% plot_xyz_axis(ax, xmax, ymax, zmax)
%
% Inputs:
%
% ax     - A axis handle for the figure to plot on
% xmax   - A double for the maximum value for x
% ymax   - A double for the maximum value for y
% zmax   - A double for the maximum value for z

%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

arguments
    ax    matlab.graphics.axis.Axes
    xmax  double
    ymax  double
    zmax  double
end

% Force ax on in case it was not already
hold(ax, 'on')

quiver3(ax, 0, 0, 0, ...
         xmax, 0, 0,...
         'k', 'AutoScale','on','LineWidth', 2, 'MaxHeadSize', 0.05);
text(ax,xmax,0,0,'$\hat i$','Interpreter','latex','FontSize',18);
quiver3(ax, 0, 0, 0, ...
            0, ymax, 0,...
         'k', 'AutoScale','on','LineWidth', 2, 'MaxHeadSize', 0.05);
text(ax,0,ymax,0,'$\hat j$','Interpreter','latex','FontSize',18);
quiver3(ax, 0, 0, 0, ...
            0, 0, zmax,...
         'k', 'AutoScale','on','LineWidth', 2, 'MaxHeadSize', 0.05);
text(ax,0,0,zmax,'$\hat k$','Interpreter','latex','FontSize',18);
end
