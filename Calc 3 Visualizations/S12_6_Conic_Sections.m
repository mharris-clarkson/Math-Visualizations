function S12_6_Conic_Sections()
%% Script showing the classical 2D conic sections and their intersection
% origins
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all;

%% Load helper functions for cleaner code
run('setup.m')

%% ================== User parameters =====================
% Cone parameters
h = 1;          % reference height of cone for slope
r_base = 1;     % base radius
r_ratio = r_base/h;
% Plane parameters
z0 = 5;          % plane initially passes through z = z0
theta = 0;       % initial angle
z_max = 25;      % Max for Z (also sets x and y)

% Critical tilt of the plane: at |theta| = alpha the plane is parallel to
% a line on the cone (parabola). The cone is x^2+y^2 = r_ratio^2 z^2, so its
% sides have slope dz/dr = h/r_base and alpha = atan(h/r_base).
alpha = atan(1/r_ratio);
degenTol = 1e-1; % |z0| below this counts as a plane through the vertex

%% ========== Code below here is for making the visualizations ============

%% Build figure object and open full screen
app = uiFigure('Conic Sections: Cone and Plane Intersection',1);

%% Axes
title(app.ax, app.fig.Name);
Num_GUI = 8;

thetaSlider = app.addControl('slider', '$\theta = $ ', 1, Num_GUI, @updatePlot,...
    'Number_format','%d','AddToEnd','$^\circ$','Min',-90,'Max',90,'Default',0);

ZSlider = app.addControl('slider', '$z_0 = $ ', 2, Num_GUI, @updatePlot,...
    'Min',-10,'Max',10,'Default',z0);

%% Buttons for preset conic sections
btn_point = app.addControl('button', "Point", 3, Num_GUI,  @update_point,...
    'ColorChange',true);
    function update_point(~,~)
        app.UpdateUISlider(thetaSlider,0);
        app.UpdateUISlider(ZSlider,0);
        updatePlot()
    end

btn_circle = app.addControl('button', "Circle", 4, Num_GUI,  @update_circle,...
    'ColorChange',true);
    function update_circle(~,~)
        app.UpdateUISlider(thetaSlider,0);
        app.UpdateUISlider(ZSlider,5);
        updatePlot()
    end

btn_ellipse = app.addControl('button', "Ellipse", 5, Num_GUI,  @update_btn_ellipse,...
    'ColorChange',true);
    function update_btn_ellipse(~,~)
        app.UpdateUISlider(thetaSlider,alpha*0.9*180/pi);
        app.UpdateUISlider(ZSlider,1);
        updatePlot()
    end

btn_parabola = app.addControl('button', "Parabola", 6, Num_GUI,  @update_btn_parabola,...
    'ColorChange',true);
    function update_btn_parabola(~,~)
        app.UpdateUISlider(thetaSlider,alpha*180/pi);
        app.UpdateUISlider(ZSlider,5);
        updatePlot()
    end

btn_hyperbola = app.addControl('button', "Hyperbola", 7, Num_GUI,  @update_btn_hyperbola,...
    'ColorChange',true);
    function update_btn_hyperbola(~,~)
        app.UpdateUISlider(thetaSlider,alpha*180/pi + pi/12*180/pi);
        app.UpdateUISlider(ZSlider,5);
        updatePlot()
    end


btn_line = app.addControl('button', "Line", 8, Num_GUI,  @update_btn_line,...
    'ColorChange',true);
    function update_btn_line(~,~)
        app.UpdateUISlider(thetaSlider,alpha*180/pi);
        app.UpdateUISlider(ZSlider,0);
        updatePlot()
    end

%% Helper for button colors
    function turn_off_Buttons()
        btn_point.UserData.setColor(0);
        btn_circle.UserData.setColor(0);
        btn_ellipse.UserData.setColor(0);
        btn_parabola.UserData.setColor(0);
        btn_hyperbola.UserData.setColor(0);
        btn_line.UserData.setColor(0);
    end

%% Plotting elements: Create initial plots and store handles
% Compute cone
[Phi, Z] = meshgrid(linspace(0,2*pi,50),...
    linspace(-z_max,z_max,3));
Xc = r_ratio*abs(Z).*cos(Phi);
Yc = r_ratio*abs(Z).*sin(Phi);
Zc = Z;

surf(app.ax,Xc,Yc,Zc,'FaceAlpha',0.7,'FaceColor',[0.2 0.6 0.9],'EdgeColor','none');

% Compute plane
[X_plane,Y_plane] = meshgrid(linspace(-10*z_max,10*z_max,2));
Z_plane = z0*ones(size(X_plane));

planeSurf = surf(app.ax,X_plane,Y_plane,Z_plane,'FaceAlpha',0.9,'FaceColor',[1 0.4 0],'EdgeColor','none');

%% Intersection curve
phi = [linspace(0, 2*pi, 10000-1) 2*pi];
[x, y, z] = Compute_intersection(theta, z0);

Intersect = plot3(app.ax, x, y, z, '.-k','LineWidth',2,'MarkerSize',20);

%% Clean and update
Pretty_Plot(app.ax);
xlim(app.ax,z_max*[-1, 1]);
ylim(app.ax,z_max*[-1, 1]);
zlim(app.ax,z_max*[-1, 1]);
view(app.ax,120, 40)
updatePlot();

%% Callback
    function updatePlot(~,~)
        % A vertical plane is drawn at 89 degrees
        theta = round(thetaSlider.Value) * pi/180;
        if abs(theta) > pi/2 - 1e-3
            theta = sign(theta)*89*pi/180;
        end
        z0    = ZSlider.Value;

        n = [0 sin(theta) cos(theta)];

        if n(3) < 1e-9
            Z_plane = -500*Y_plane;
        else
            Z_plane = z0 - (n(1)*X_plane + n(2)*Y_plane)/n(3);
        end
        set(planeSurf,'ZData',Z_plane);

        [x, y, z] = Compute_intersection(theta, z0);
        set(Intersect, 'XData', x, 'YData', y, 'ZData', z);

        % Classify by |theta| and z0 (same z0 tolerance as Compute_intersection)
        turn_off_Buttons()
        if abs(z0) < degenTol % plane through the vertex: degenerate conics
            if abs(abs(theta) - alpha) < 1e-3
                conicType = 'Line';
                btn_line.UserData.setColor(1);
            elseif abs(theta) < alpha
                conicType = 'Point';
                btn_point.UserData.setColor(1);
            else
                conicType = 'Two Intersecting Lines';
                btn_line.UserData.setColor(1);
            end
        else
            if theta == 0
                conicType = 'Circle';
                btn_circle.UserData.setColor(1);
            elseif abs(abs(theta) - alpha) < 1e-3
                conicType = 'Parabola';
                btn_parabola.UserData.setColor(1);
            elseif abs(theta) < alpha
                conicType = 'Ellipse';
                btn_ellipse.UserData.setColor(1);
            else
                conicType = 'Hyperbola';
                btn_hyperbola.UserData.setColor(1);
            end
        end

        title(app.ax,sprintf('Cone and Plane Intersection: %s',conicType),'FontSize',18);

        zlim(app.ax,[-z_max z_max]);
    end

%% ========================================================================
% Helper functions
    function [x, y, z] = Compute_intersection(theta, z0)
        r = r_ratio;
        m = tan(theta);

        k = r * m .* sin(phi);
        den1 = 1 + k;

        tol = 1e-15;

        z = z0 ./ den1;

        v1 = abs(den1) > tol;

        z(~v1) = NaN;

        x = r .* z .* cos(phi);
        y = r .* z .* sin(phi);

        if abs(z0) < degenTol % Degenerate cases
            if r*abs(m) < 1 - 1e-5
                x = zeros(size(x));
                y = sign(theta)*x;
                z = x;
            elseif abs(r*abs(m) - 1) < 1e-3
                t = linspace(-1*z_max, 1*z_max, length(phi));
                x = 0*t;
                y = sign(theta)*t;
                z = -m*sign(theta)*t;
            else
                t = linspace(-1*z_max,1*z_max,length(phi)/2-1);
                slope = sqrt(abs(r^2 * m^2 - 1));

                x = [sign(theta)*slope*t NaN NaN -slope*t];
                y = [sign(theta)*t NaN NaN t];
                z = [-sign(theta)*m*t NaN NaN -m*t];
            end
        end

        dx = diff(x);
        dy = diff(y);
        dz = diff(z);

        jump = [false, (dx.^2 + dy.^2 + dz.^2) > 1e3*z_max];

        x(jump) = NaN;
        y(jump) = NaN;
        z(jump) = NaN;
    end
end