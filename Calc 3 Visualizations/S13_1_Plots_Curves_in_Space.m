%% Script that plot several curves in 3D
% Complements Lecture 6 for MA 232
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all

run('setup.m')
%% Helix: Example 5
% Make figure and ax
fig = figure('Color','w',...
             'Name','Helix: Example 5',...
             'WindowState','maximized');
ax = axes(fig);  
% Define the stuff to plot
t = linspace(0,5*pi,200);
% Build curve
x = @(t) cos(t);
y = @(t) sin(t);
z = @(t) t;

% Build the unit vector at the end
tp = t(end);
u = Diff_f_unit(x,tp);
v = Diff_f_unit(y,tp);
w = Diff_f_unit(z,tp);

% Plot
plot3(ax,x(t),y(t),z(t),'b','LineWidth',2)
title(ax, fig.Name);
hold(ax,'on')
quiver3(ax, x(tp), y(tp), z(tp), ...
        u, v, w, 0.2, 'b', ...
        'MaxHeadSize', 3, 'LineWidth',2)
% Axes formatting
Pretty_Plot(ax)


%% Parabolid-plane intersection: Example 7
% Make figure and ax
fig = figure('Color','w',...
             'Name',' Parabolid-Plane Intersection: Example 7',...
             'WindowState','maximized');
ax = axes(fig);  
% Define the stuff to plot and plot it
[x, y] = meshgrid(linspace(-2,2,100),linspace(-3,2,100));
t  = linspace(0,2*pi,500);

% Plot parabolid
surf(ax, x,y, x.^2+y.^2,...
    'FaceAlpha',0.3,'FaceColor',[0.2 0.6 0.9],'EdgeColor','none')
title(ax, fig.Name);
hold(ax,'on')

% Plot plane
surf(ax, x,y,2-y,...
    'FaceAlpha',0.5,'FaceColor',[0.9 0.6 0.2],'EdgeColor','none')

% Plot intersection
plot3(3/2*cos(t), -1/2+3/2*sin(t), 5/2-3/2*sin(t),'k','LineWidth',2)

% Axes formatting
Pretty_Plot(ax)
legend('Paraboloid: $z = x^2 + y^2$', ...
             'Plane: $z = 2 - y$', ...
             'Intersection',...
             'Interpreter', 'latex');

%% Parabolid-Plane Intersection: Example 8
% Make figure and ax
fig = figure('Color','w',...
             'Name',' Parabolid-Plane Intersection: Example 8',...
             'WindowState','maximized');
ax = axes(fig);  
% Define the stuff to plot and plot

% Plot parametric version of z^2 = 4y-x^2
[x, z] = meshgrid(linspace(-3,5,500));
y = (x.^2 + z.^2)/4;
surf(ax, x,y,z,...
    'FaceAlpha',0.3,'FaceColor',[0.2 0.6 0.9],'EdgeColor','none')
title(ax, fig.Name);
hold(ax,'on')

%Plot the plane
[y, z] = meshgrid(linspace(-1,5,2),linspace(-3,3,2));
x=y;
surf(ax, x,y,z,'FaceAlpha',0.5,'FaceColor',[0.9 0.6 0.2],'EdgeColor','none')

% plot intersection
t  = linspace(0,2*pi,100);
plot3(ax, 2 + 2*cos(t), 2 + 2*cos(t), 2*sin(t),'k','LineWidth',2)

% Axes formatting
Pretty_Plot(ax)
legend('Paraboloid: $z^2 = 4y - x^2$', ...
             'Plane: $y = x$', ...
             'Intersection',...
             'Interpreter', 'latex');

%% Toroidal Spiral: Example 9
% Make figure and ax
fig = figure('Color','w',...
             'Name',' Toroidal Spiral: Example 9',...
             'WindowState','maximized');
ax = axes(fig);  
% Define the stuff to plot and plot
t = linspace(0,2*pi,2000);
% Vector-valued function r(t)
x = (4+sin(10*t)).*cos(t);
y = (4+sin(10*t)).*sin(t);
z = cos(10*t);
% Plot
plot3(ax, x,y,z,'r','LineWidth',2)
title(ax, fig.Name);
% Improve viewing angle
view(45,25)
Pretty_Plot(ax)

%% Trefoil Knot: Example 10
% Make figure and ax
fig = figure('Color','w',...
             'Name',' Trefoil Knot: Example 10',...
             'WindowState','maximized');
ax = axes(fig);  
% Parameter
t = linspace(0,6*pi,2000);
% Vector-valued function r(t)
x = (2+cos(1.5*t)).*cos(t);
y = (2+cos(1.5*t)).*sin(t);
z = sin(1.5*t);
% Plot
plot3(ax, x,y,z,'r','LineWidth',2)
title(ax, fig.Name);

% Improve viewing angle
view(45,25)
Pretty_Plot(ax)

% 3D Heart Curve
% Make figure and ax
fig = figure('Color','w',...
             'Name',' 3D Heart Curve',...
             'WindowState','maximized');
ax = axes(fig);  % Parameter
t = linspace(0,2*pi,200);
% Vector-valued function r(t)
x = 16*sin(t).^3;
y = 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t);
z = 2.5*sin(t);
% Plot
plot3(ax, x,y,z,'r','LineWidth',2)
title(ax, fig.Name);

% Change viewing angle to hide what it is to start
view(45,25)
Pretty_Plot(ax)