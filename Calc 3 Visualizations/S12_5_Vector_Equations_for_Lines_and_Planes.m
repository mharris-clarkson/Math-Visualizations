function S12_5_Vector_Equations_for_Lines_and_Planes()
%% Script showing how lines and planes can be defined using vector functions
% Allows the user to move sliders to change the values of paramaters to
% pick points on a line/plane.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.

r0 = [0;  0; 1]; % point on the line/plane
v  = [1;  1; 1]; % direction of the line (first direction of the plane)
u  = [-1; 1; 0]; % second direction of the plane, not a multiple of v
t0 = 0;          % starting t in [-1,1]; s starts at 0

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("Vector Equations for Lines and Planes",1);
title(app.ax,app.fig.Name)

%% ============== Make the initial plots =================================
labelOffset = 0.05;

%% Static elements: origin, line, r0 and v
plot3(app.ax(1), 0,0,0, 'ok','MarkerSize',10,'MarkerFaceColor','k');

tLine = [-1.5 1.5];
linePts = r0 + v*tLine;
plot3(app.ax(1), linePts(1,:), linePts(2,:), linePts(3,:), 'b','LineWidth',2)

plot3(app.ax(1), r0(1), r0(2), r0(3), '.k','MarkerSize', 20);
quiver3(app.ax(1), 0,     0,     0,...
    r0(1), r0(2), r0(3), 0,'k','LineWidth',2,'MaxHeadSize',0.5);
text(app.ax(1), r0(1)+labelOffset/2, r0(2)+labelOffset/2, r0(3)+labelOffset/2, ...
    '$\vec r_0$','FontSize', 24,'Color','k');

quiver3(app.ax(1), 0,       0,    0,...
    v(1), v(2), v(3), 0,'b','LineWidth',2,'MaxHeadSize',0.5);
text(app.ax(1), v(1)+labelOffset, v(2)+labelOffset, v(3)+labelOffset, ...
    '$\vec{v}$','FontSize',24,'Color','b');

%% Dynamic elements (plane items start hidden)
[sGrid,tGrid] = meshgrid(linspace(tLine(1), tLine(2), 7));
XPlane = r0(1) + tGrid*v(1) + sGrid*u(1);
YPlane = r0(2) + tGrid*v(2) + sGrid*u(2);
ZPlane = r0(3) + tGrid*v(3) + sGrid*u(3);

Plane_Plot = surf(app.ax(1), XPlane, YPlane, ZPlane,...
    'FaceColor', 'cyan', 'FaceAlpha', 0.3, 'Visible', 'off');

Plane_dir_vec = quiver3(app.ax(1), 0,    0,    0,...
    u(1), u(2), u(3),...
    0, 'r', 'LineWidth',2, 'MaxHeadSize', 0.5, 'Visible', 'off');

lineUpts = r0 + u*tLine;
Plane_dir_line = plot3(app.ax(1), lineUpts(1,:), lineUpts(2,:), lineUpts(3,:),...
    'r','LineWidth',2,'Visible','off');

% Moving point r = r0 + tv + su and its position vector
r = r0 + t0*v ;
Moving_Point_on_plane = plot3(app.ax(1), r(1), r(2), r(3),'om',...
    'MarkerSize',10,'MarkerFaceColor','m');

Moving_Vector_on_plane = quiver3(app.ax(1), 0, 0, 0,...
    0, 0, 0,...
    0, 'm', 'LineWidth', 2,'MaxHeadSize', 0.5);

% Unit normal vector and its label
n = cross(v,u);
n = n / norm(n);
edgePoint = r0 + tLine(2)*v;

Plane_Normal_Vec = quiver3(app.ax(1), edgePoint(1),edgePoint(2),edgePoint(3), ...
    n(1),n(2),n(3), ...
    0,'k','LineWidth',2,'MaxHeadSize',0.7,'Visible','off');

Normal_vector_Label = text(app.ax(1), edgePoint(1) + n(1) + labelOffset, ...
    edgePoint(2) + n(2) + labelOffset, ...
    edgePoint(3) + n(3) + labelOffset, ...
    '$\vec{n} = \vec{v} \times \vec{u}$', 'FontSize',24,'Color','k','Visible','off');

Point_Label = text(app.ax(1), r(1)+labelOffset, r(2)+labelOffset, r(3)+labelOffset, ...
    '$\vec{r}(t) = \vec r_0 + t\vec{v}$','FontSize', 24,'Color','m');

u_Vector_Label = text(app.ax(1), u(1)+labelOffset, u(2)+labelOffset, u(3)+labelOffset, ...
    '$\vec{u}$','FontSize',24,'Color','r','Visible','off');

view(app.ax(1), 7, 32);

%% Build UI
num_GUI = 4;

sliderT = app.addControl('slider', '$t = $', 1, num_GUI,  @updatePlot,...
    'Default',t0, 'Min',-1, 'Max',1);

sliderS = app.addControl('slider', '$s = $', 2, num_GUI,  @updatePlot,...
    'Default',0, 'Min',-1, 'Max',1,...
    'Visible', 'off');

app.addControl('button', 'Show Plane', 3, num_GUI,  @swapPlaneLine, ...
    'Toggle', ["Show Plane", "Show Line"]);

btn_Normal_View = app.addControl('button', 'Normal View', 4, num_GUI,  @toggleNormalView,...
    'Visible','off', 'Toggle', ["Normal View", "Original View"]);

updatePlot()

%% Functions for UI elements
    function swapPlaneLine(src,~)
        if src.Value
            set(Point_Label, 'String', '$\vec r(t,s) = \vec r_0 + t\vec{v} + s\vec{u}$');
        else
            set(Point_Label, 'String', '$\vec{r}(t) = \vec r_0 + t\vec{v}$');
        end
        for h = [Plane_Plot, Plane_dir_vec, Plane_dir_line, u_Vector_Label, ...
                 btn_Normal_View, sliderS, Normal_vector_Label, Plane_Normal_Vec]
            h.Visible = onoff(strcmp(h.Visible, 'off'));
        end
        app.UpdateUISlider(sliderS,0);
        updatePlot()
    end

    function toggleNormalView(src,~)
        if src.Value
            view(app.ax(1), -44.8, -48);   % found by hand for the default u and v
        else
            view(app.ax(1), 7, 32);
        end
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)
        rPlane = r0 + sliderT.Value*v + sliderS.Value*u;
        set(Moving_Vector_on_plane, 'UData', rPlane(1),...
            'VData',rPlane(2) ,'WData',rPlane(3))
        set(Moving_Point_on_plane, 'XData', rPlane(1),...
            'YData',rPlane(2) ,'ZData',rPlane(3))
        Point_Label.Position = rPlane + labelOffset;
    end
end