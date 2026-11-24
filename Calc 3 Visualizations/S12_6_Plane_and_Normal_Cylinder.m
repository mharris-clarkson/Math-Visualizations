function S12_6_Plane_and_Normal_Cylinder()
%% Script showing a cylinder and its normal plane.
% Allows the user to move sliders to change the angles for the cylinder
% with locks for angles that are not useful
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Cross-section of the cylinder. A triangle:
x = [0,                   -0.5,            0.5];
y = [1/sqrt(3), -1/(2*sqrt(3)), -1/(2*sqrt(3))];

% or any curve x(t), y(t) (this one overrides the triangle)
t = linspace(0,1,50);
x = cos(2*pi*t);
y = sin(2*pi*t);

% initial angles
theta0 = 0;
phi0   = 0;

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("Cylinder with Normal Plane",1);

%% Optional math functions for plot computations
view(app.ax,65,40);

% Compute normal vector for plane
    function n = normal_to_plane(theta,phi)
        n = [cos(theta)*sin(phi), ...
            sin(theta)*sin(phi), ...
            cos(phi) ];
        n = n / norm(n);
    end

% Compute cylinder and plane data
    function [Xc, Yc, Zc, Xp, Yp, Zp, Xint, Yint, Zint] = cylinder_and_plane(n)
        if abs(n(3)) < 0.9
            ref = [0;0;1];
        else
            ref = [0;1;0];
        end
        e1 = cross(n, ref)';
        e1 = e1 / norm(e1);
        e2 = cross(n, e1')';
        e2 = e2 / norm(e2);
        t = linspace(-2,2,2);
        Xc = zeros(size(T,1),numel(t));
        Yc = Xc; Zc = Xc;
        for k = 1:numel(t)
            pts = T(:,1)*e1.' + T(:,2)*e2.' + t(k)*n;
            Xc(:,k) = pts(:,1);
            Yc(:,k) = pts(:,2);
            Zc(:,k) = pts(:,3);
        end
        Xp = U*e1(1) + V*e2(1);
        Yp = U*e1(2) + V*e2(2);
        Zp = U*e1(3) + V*e2(3);

        Xint = T(:,1)*e1(1) + T(:,2)*e2(1);
        Yint = T(:,1)*e1(2) + T(:,2)*e2(2);
        Zint = T(:,1)*e1(3) + T(:,2)*e2(3);
    end


%% ============== Make the initial plots =================================
T = [x', y'];
T = [T; T(1,:)];      % close the curve
[U,V] = meshgrid(linspace(-2, 2, 2));

n = normal_to_plane(theta0,phi0);
Normal_vec = quiver3(app.ax,0,0,0, ...
    n(1), n(2), n(3), ...
    1, 'r','LineWidth',4,'MaxHeadSize',0.2);
Normal_vec_text = text(app.ax, ...
    n(1), n(2), n(3), ...
    '$\vec n$', 'color','r', ...
    'FontSize',18);

[Xc, Yc, Zc, Xp, Yp, Zp, Xint, Yint, Zint] = cylinder_and_plane(n);

cylinder = surf(app.ax,Xc,Yc,Zc, ...
    'FaceAlpha',0.5, ...
    'FaceColor',[0.85 0.4 0.1], ...
    'EdgeColor','none');

plane = surf(app.ax, Xp, Yp, Zp, ...
    'FaceAlpha',0.9, ...
    'EdgeColor','none', ...
    'FaceColor',[0.2 0.6 0.9]);

intersection = plot3(app.ax, Xint, Yint, Zint, ...
    'b','LineWidth', 2);

plot_xyz_axis(app.ax, 1, 1, 1)

legend(app.ax,'Normal Vector to Plane','Cylinder','Plane','Intersection of Cylinder and Plane', ...
    'Location', 'northwest');

xlim(app.ax, [-2.5,2.5])
ylim(app.ax, [-2.5,2.5])
zlim(app.ax,[-2.5,2.5])

%% Build UI
title(app.ax,app.fig.Name)
NumControls = 2;
thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls,  @update,...
    'Default',theta0,'Min',0,'Max',360,'Number_format','%d','AddToEnd','$^\circ$');
thetaSlider.SliderStep = 10/360*[1, 1];

phiSlider = app.addControl('slider', '$\phi = $', 2, NumControls,  @update,...
    'Default',phi0,'Min',0,'Max',360,'Number_format','%d','AddToEnd','$^\circ$');
phiSlider.SliderStep = 10/360*[1, 1];

update()

%% Main Draw update function. All initial plot functions are updated below.
    function update(~,~)
        theta = thetaSlider.Value*pi/180;
        phi   = phiSlider.Value*pi/180;

        % Hide theta when n is along the z-axis (it does nothing there)
        if  abs(cos(phi)) > 1-1e-6
            newVis = "off";
        else
            newVis = "on";
        end
        if ~strcmp(thetaSlider.Visible, newVis)
            thetaSlider.Visible = newVis;
            app.UpdateUISlider(thetaSlider, thetaSlider.Value);
        end

        n = normal_to_plane(theta,phi);
        set(Normal_vec, 'UData',n(1), 'VData',n(2), 'WData',n(3))
        set(Normal_vec_text, 'Position', [n(1), n(2), n(3)])

        [Xc, Yc, Zc, Xp, Yp, Zp, Xint, Yint, Zint] = cylinder_and_plane(n);
        set(cylinder, 'XData',Xc, 'YData',Yc, 'ZData',Zc)
        set(plane, 'XData',Xp, 'YData',Yp, 'ZData',Zp)
        set(intersection, 'XData',Xint, 'YData',Yint, 'ZData',Zint)
    end
end