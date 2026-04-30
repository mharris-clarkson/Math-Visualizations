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
% Points defining the cylinder. Values below are for a nice triagle
x = [0,                   -0.5,            0.5];
y = [1/sqrt(3), -1/(2*sqrt(3)), -1/(2*sqrt(3))];

% For any curve x(t), y(t) you can use/modify the below
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
app = uiFigure("Cylinder with Normal Plan",1);

%% Optional math functions for plot computations
view(app.ax,65,40);


%% ============== Make the initial plots =================================
% Just call update at the end as this is lightweight and no elements have
% complex features (turn on/off, etc.)

%% Precompute math for updates
% Close cylinder
T = [x', y'];
T = [T; T(1,:)];
% Compute dimensions on plane
u = linspace(-2, 2, 2);
v = linspace(-2, 2, 2);
[U,V] = meshgrid(u,v);


%% Build UI
title(app.ax,app.fig.Name)
NumControls = 2; % maximum number of controls
% Theta
thetaSlider = app.addControl('slider', '$\theta = $', 1, NumControls,  @update,...
    'Default',theta0,'Min',0,'Max',360,'Number_format','%d','AddToEnd','$^\circ$');
thetaSlider.SliderStep = 10/360*[1, 1]; % force bigger and integer slider step

% Phi
phiSlider = app.addControl('slider', '$\phi = $', 2, NumControls,  @update,...
    'Default',phi0,'Min',0,'Max',360,'Number_format','%d','AddToEnd','$^\circ$');
phiSlider.SliderStep = 10/360*[1, 1]; % force bigger  and integer slider step


% Launch update function
update();

%% Functions for UI elements



%% Main Draw update function. All initial plot functions are updated below.
    function update(~,~)
        cla(app.ax);


        hold(app.ax,'on')

        % Read angles and convert to radian
        theta = thetaSlider.Value*pi/180;
        phi   = phiSlider.Value*pi/180;

        % Turn on or off Theta
        if  abs(cos(phi)) > 1-1e-6
            thetaSlider.Visible = "off";
            thetaSlider.Value  = 0;
            thetaLabel.String = '$\theta = $ 0$^\circ$'; % force degree symbol
        else
            thetaSlider.Visible = "on";
        end

        % Plot and label normal vector for plane
        n = [cos(theta)*sin(phi), ...
            sin(theta)*sin(phi), ...
            cos(phi) ];
        n = n / norm(n);
        quiver3(app.ax,0,0,0, ...
            n(1), n(2), n(3), ...
            1, 'r','LineWidth',4,'MaxHeadSize',0.2);
        text(app.ax, ...
            n(1), n(2), n(3), ...
            '$\vec n$', 'color','r', ...
            'Interpreter','latex', ...
            'FontSize',18);

        % Plot cylinder
        % Find unit basis vectors in the plane by using a vector not parallel to n
        if abs(n(3)) < 0.9
            ref = [0;0;1];
        else
            ref = [0;1;0];
        end
        e1 = cross(n, ref)';
        e1 = e1 / norm(e1);
        e2 = cross(n, e1')';
        e2 = e2 / norm(e2);
        % Compute normal-aligned cylinder
        t = linspace(-2,2,2);
        Xc = zeros(size(T,1),numel(t));
        Yc = Xc; Zc = Xc;
        for k = 1:numel(t)
            pts = T(:,1)*e1.' + T(:,2)*e2.' + t(k)*n;
            Xc(:,k) = pts(:,1);
            Yc(:,k) = pts(:,2);
            Zc(:,k) = pts(:,3);
        end
        surf(app.ax,Xc,Yc,Zc, ...
            'FaceAlpha',0.5, ...
            'FaceColor',[0.85 0.4 0.1], ...
            'EdgeColor','none');

        % Plot plane
        Xp = U*e1(1) + V*e2(1);
        Yp = U*e1(2) + V*e2(2);
        Zp = U*e1(3) + V*e2(3);
        surf(app.ax, Xp, Yp, Zp, ...
            'FaceAlpha',0.9, ...
            'EdgeColor','none', ...
            'FaceColor',[0.2 0.6 0.9]);

        % Plot intersection
        Xp = T(:,1)*e1(1) + T(:,2)*e2(1);
        Yp = T(:,1)*e1(2) + T(:,2)*e2(2);
        Zp = T(:,1)*e1(3) + T(:,2)*e2(3);
        plot3(app.ax, Xp, Yp, Zp, ...
            'b','LineWidth', 2);

        % Plot standard basis vectors
        plot_xyz_axis(app.ax, 1, 1, 1)

        % Add legend
        leg = legend(app.ax,'Normal Vector to Plane','Cylinder','Plane','Intersection of Cylinder and Plane');
        leg.Location = "northwest";

        % Set limits for fixed view
        xlim(app.ax, [-2.5,2.5])
        ylim(app.ax, [-2.5,2.5])
        zlim(app.ax,[-2.5,2.5])
    end
end