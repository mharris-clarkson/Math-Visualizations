%% Script that plots various surfaces and regions in 3D for exploring the 
% connection between equations and the regions they describe. 
% Complements Lecture 1 for MA 232
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

%% Wipe curent state
clear
close all
clc

%% Load helper functions for cleaner code
run('setup.m')


%% Example 1A: z = 5
fig = figure('Color','w',...
             'Name','Plot of a Part of a Plane: Example 1A',...
             'WindowState','maximized');
ax = axes(fig);  
title(ax, fig.Name);
hold(ax, 'on')
% Plot z = 5 over [-5,5]^2
[x, y] = meshgrid(linspace(-5,5,10));
z = 0*x+5;
surf(x,y,z,...
    'EdgeColor','k','FaceColor','b',...
    'FaceAlpha', 0.5);
% Clean plot up
plot_xyz_axis(ax, 5, 5, 8)
view(100,40)
Pretty_Plot(ax)
legend(ax, '$z = 5$',...
        'Interpreter', 'latex');



%% Example 1B: y = x over [-2,5]^2
clear
fig = figure('Color','w',...
             'Name','Plot of a Part of a Plane: Example 1B',...
             'WindowState','maximized');
ax = axes(fig);  
title(ax, fig.Name);
hold(ax, 'on')
% Plot y = x over [-2,5]^2
[x, z] = meshgrid(linspace(-2,5,10));
y = x;
surf(x,y,z,...
    'EdgeColor','k','FaceColor','b',...
    'FaceAlpha', 0.5);
% Clean plot up
plot_xyz_axis(ax, 5, 5, 8)
view(100,40)
Pretty_Plot(ax)
legend(ax, '$x = y$ in 3D',...
        'Interpreter', 'latex');

%% Example 2: Intersection of x^2 + z^2 = 4 and y = 3
fig = figure('Color','w',...
             'Name','Plot of a the Intersection of x^2 + z^2 = 4 and y = 3: Example 2',...
             'WindowState','maximized');
ax = axes(fig);  
hold(ax,'on')
title(ax, fig.Name);
% Plot the cylinder
[theta, Y] = meshgrid(linspace(0,2*pi,50), linspace(-1,4,2));
surf(ax, 2*sin(theta), Y, 2*cos(theta), ...
    'FaceAlpha', 0.3, 'EdgeAlpha', 0.3,...
    'FaceColor', 'b', 'EdgeColor','b');
% Plot y = 3 over (x,z) in [-3,3]^2
[x, z] = meshgrid(linspace(-3,3,10));
y = 3*ones(size(x));
surf(x,y,z,...
    'EdgeColor','k','FaceColor','g',...
    'EdgeAlpha',  0, 'FaceAlpha', 0.5);
% plot intersection
theta = linspace(0,2*pi,100);
plot3(ax, 2*cos(theta), 3*ones(size(theta)), 2*sin(theta),...
          '.-k','Linewidth', 4)
% Clean plot up
plot_xyz_axis(ax, 3, 4, 3)
view(100,40)
Pretty_Plot(ax)
% Clean axis to see the circle in in the right aspect ratio
axis(ax, 'equal');
legend('$x^2+z^2 = 4$', '$y = 3$','Intersection',...
        'Interpreter', 'latex');

%% Example 3: Plot a solid bounded by two cylinders. Adds caps to make it look full
fig = figure('Color','w',...
             'Name','Solid bounded by Cylinders: Example 3',...
             'WindowState','maximized');
ax = axes(fig); 
hold(ax,'on')
title(ax, fig.Name);
% use the parametric equation to plot the region
[theta, Z_cyl] = meshgrid(linspace(0, 2*pi, 100), linspace(-2, 2, 2));
% Outer cylinder (r=2)
surf(ax, 2*cos(theta), 2*sin(theta), Z_cyl, ...
    'FaceColor', 'b', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
hold(ax,'on')
% Inner cylinder (r=1)
surf(ax, cos(theta), sin(theta), Z_cyl, ...
    'FaceColor', 'r', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
% Top and bottom annular caps
[r, theta_cap] = meshgrid(linspace(1, 2, 50), linspace(0, 2*pi, 100));
X_cap = r .* cos(theta_cap);
Y_cap = r .* sin(theta_cap);
surf(ax, X_cap, Y_cap, max(Z_cyl(:))*ones(size(X_cap)), ...   % top cap
    'FaceColor', 'k', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
surf(ax, X_cap, Y_cap, min(Z_cyl(:))*ones(size(X_cap)), ...     % bottom cap
    'FaceColor', 'k', 'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
% Clean plot up
plot_xyz_axis(ax, 3, 3, 3)
view(100,40)
Pretty_Plot(ax)
% Clean axis to see the circles in in the right aspect ratio
axis(ax, 'equal');
legend(ax, '$x^2+y^2 = 4$', '$x^2 + y^2 = 1$', 'Caps',...
        'Interpreter', 'latex');

%% Example 6: 
clear
fig = figure('Color','w',...
             'Name','Solid Bounded by Spheres and a Plane',...
             'WindowState','maximized');
ax = axes(fig); 
hold(ax,'on')
title(ax, fig.Name);
% Inside
[x,y,z] = sphere(50);
Toplot = (z<=0);
x(~Toplot)=NaN;y(~Toplot)=NaN;z(~Toplot)=NaN;
surf(ax,x,y,z,...
    'EdgeColor','k','FaceColor','b',...
    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
%outside 
hold(ax,'on')
surf(ax,2*x,2*y,2*z, ...
    'EdgeColor','k','FaceColor','r',...
    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
% top 
[r,theta] = meshgrid(linspace(1,2,10),linspace(0,2*pi,50));
x=r.*cos(theta);
y=r.*sin(theta);
z=0*x;
surf(x,y,z,...
    'EdgeColor','k','FaceColor','k',...
    'FaceAlpha', 0.5, 'EdgeAlpha', 0.5);
% Clean plot up
title(ax, fig.Name);
plot_xyz_axis(ax, 3, 3, 1)
view(100,40)
Pretty_Plot(ax)
% Clean axis to see the circles in in the right aspect ratio
axis(ax, 'equal');
xlim([-3,3])
ylim([-3,3])
legend(ax, '$x^2+y^2+z^2 = 1$', '$x^2 + y^2 + z^2 = 4$','$z = 0$',...
        'Interpreter', 'latex');