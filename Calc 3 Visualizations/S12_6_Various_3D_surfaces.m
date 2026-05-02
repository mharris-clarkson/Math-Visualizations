%% Script to plot various surfaces and contour plots 
% This is for a lecture introducing contour plots
% Complements Lecture 5 for MA 232

%% Wipe curent state
clear
close all


%% Load helper functions for cleaner code
run('setup.m')

%% Example 2
clear
% Define figure and children
fig = figure('Color','w',...
             'Name','Plot of a Parabolic Sheet: Example 2',...
             'WindowState','maximized');
ax_left = subplot(1,2,1);
ax_right = subplot(1,2,2);
hold(ax_left,'on')
hold(ax_right,'on')
title(ax_left,'Surface Plot: Parabolic Sheet $z=x^2$','Interpreter','latex')
title(ax_right,'Contour Plot')

% Compute Surface
[X,Y] = meshgrid(linspace(-5,5,50));
Z = X.^2;
% Compute some integer contours
numLevels = 12;
levels = round(linspace(min(Z(:)), max(Z(:)), numLevels)); % integer level curves

% Plot surface to the left
surf(ax_left,X,Y,Z)
% Flatten shading
shading(ax_left,"flat")
% Countour plot on top of the surface
contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
%Clean up axis
cb = Pretty_Color_Positive(ax_left,Z);
plot_xyz_axis(ax_left, 5, 5, 24)
view(ax_left,-25,15)
Pretty_Plot(ax_left)

% Plot 2D contours to the right
[C,hc] = contour(ax_right,X, Y, Z, levels, 'k', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color', 'k'); % add contour labels
%Clean up axis
Pretty_Plot(ax_right)

%% Example 3
clear
% Define figure and children
fig = figure('Color','w',...
             'Name','Plot of a Paraboloid: Example 3',...
             'WindowState','maximized');
ax_left = subplot(1,2,1);
ax_right = subplot(1,2,2);
hold(ax_left,'on')
hold(ax_right,'on')
title(ax_left,'Surface Plot: Paraboloid $z = x^2 + 4y^2$','Interpreter','latex')
title(ax_right,'Contour Plot')
% Compute Surface
[X,Y] = meshgrid(-3:0.1:3);
Z=X.^2 + 4*Y.^2;
% Compute some integer contours
levels = 0:5:45; 

% Plot surface to the left
ax_left = subplot(1,2,1);
surf(ax_left, X,Y,Z)
% Flatten shading
shading(ax_left, "flat")
% Countour plot on top of the surface
contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
%Clean up axis
cb = Pretty_Color_Positive(ax_left,Z);
view(ax_left,-72,20)
plot_xyz_axis(ax_left, 2, 2, 25)
Pretty_Plot(ax_left)

% Plot 2D contours to the right
[C,hc] = contour(ax_right, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color', 'k');clabel(C, hc, 'FontSize',14, 'Color','k');  % add contour labelsxlabel('x')
%Clean up axis
Pretty_Plot(ax_right)

%% Example 4
clear
% Define figure and children
fig = figure('Color','w',...
             'Name','Plot of a Saddle: Example 4',...
             'WindowState','maximized');
ax_left = subplot(1,2,1);
ax_right = subplot(1,2,2);
hold(ax_left,'on')
hold(ax_right,'on')
title(ax_left,'Surface Plot: Saddle $z = x^2 - y^2$','Interpreter','latex')
title(ax_right,'Contour Plot')
% Compute Surface
[X,Y] = meshgrid(-10:0.1:10);
Z=X.^2-Y.^2;
% Compute some integer contours
levels = [-100:10:-10, -5, 0, 5, 10:10:100]; % integer levels

% Plot surface to the left
surf(ax_left,X,Y,Z)
% Flatten shading
shading(ax_left, "flat")
% Countour plot on top of the surface
contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
%Clean up axis
cb = Pretty_Color_Centered(ax_left,Z);
plot_xyz_axis(ax_left, 5, 5, 24)
view(ax_left,-25,15)
Pretty_Plot(ax_left)

% Plot 2D contours to the right
[C,hc] = contour(ax_right, X, Y, Z, levels(levels>0), 'r', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color', 'r'); % add contour labels
[C,hc] = contour(ax_right, X, Y, Z, [0,0], 'k', 'LineWidth', 1.5); % 0 contour black.
clabel(C, hc, 'FontSize', 14, 'Color', 'k'); % add contour labels
[C,hc] = contour(ax_right, X, Y, Z, levels(levels<0), 'b', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color', 'b');  % add contour labels
%Clean up axis
Pretty_Plot(ax_right)

%% Example 5
clear
% Define figure and children
fig = figure('Color','w',...
             'Name','Plot of a Hyperboloid: Example 5',...
             'WindowState','maximized');
ax_left = subplot(1,2,1);
ax_right = subplot(1,2,2);
hold(ax_left,'on')
hold(ax_right,'on')
title(ax_left,'Surface Plot: Hyperboloid $x^2 + y^2 - z^2 = 4$','Interpreter','latex')
title(ax_right,'Contour Plot')
% Compute Surface using parametric equations 
[u,v] = meshgrid(linspace(-8,8,50), [linspace(0,2*pi,50) 2*pi]);
X = sqrt(u.^2 + 4).*cos(v);
Y = sqrt(u.^2 + 4).*sin(v);
Z=u;
% Compute some integer contours
levels = -10:2:10; % integer levels
surf(ax_left,X,Y,Z)
% Flatten shading
shading(ax_left, "flat")
% Countour plot on top of the surface
contour3(ax_left, X, Y, Z, levels, 'k', 'LineWidth', 1.5);
%Clean up axis
cb = Pretty_Color_Centered(ax_left, Z);
plot_xyz_axis(ax_left, 5, 5, 5)
view(ax_left, -25,15)
Pretty_Plot(ax_left)
axis(ax_left, 'equal');


% Plot 2D contours
[C,hc] = contour(ax_right,X, Y, Z, levels(levels>1), 'r', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color','r');  % add contour labels
[C,hc] = contour(ax_right,X, Y, Z, [0 0], 'k', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color','k');  % add contour labels
[C,hc] = contour(ax_right,X, Y, Z, levels(levels<-1), 'b', 'LineWidth', 1.5);
clabel(C, hc, 'FontSize', 14, 'Color','b');  % add contour labels
Pretty_Plot(ax_right)
axis(ax_right, 'equal');
