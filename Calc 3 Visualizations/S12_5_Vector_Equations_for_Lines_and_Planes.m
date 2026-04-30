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

% Base point and vectors defining the line and or plane (Changing this will
% update all [most] visual elements)
r0 = [0;  0; 1]; % One point on the line/plane
v  = [1;  1; 1]; % Direction vector 1 (this is also the vector for the line)
u  = [-1; 1; 0]; % Direction vector 2 (this is the other direction for the
% plane). Must not be a multiple of v!
t0 = 0;          % Starting point for t  in [-1,1]. s0 is forced to 0

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("Vector Equations for Lines and Planes",1);

%% Optional math functions for plot computations
% None as we are just updating a line

%% ============== Make the initial plots =================================
labelOffset = 0.05;  % Offset for in plot texts

%% Plot Static Elements
% Plot the origin
plot3(app.ax(1), 0,0,0, 'ok','MarkerSize',10,'MarkerFaceColor','k');

% Elements for the line:
tLine = [-1.5 1.5];
linePts = r0 + v*tLine;

% Line
plot3(app.ax(1), linePts(1,:), linePts(2,:), linePts(3,:), 'b','LineWidth',2)

% Point on line for r0
plot3(app.ax(1), r0(1), r0(2), r0(3), '.k','MarkerSize', 20);

% Vector from origin to r0
quiver3(   0,     0,     0,...
    r0(1), r0(2), r0(3), 0,'k','LineWidth',2,'MaxHeadSize',0.5);

% r0 label.
text(r0(1)+labelOffset/2, r0(2)+labelOffset/2, r0(3)+labelOffset/2, ...
    '$\vec r_0$','Interpreter', 'latex','FontSize', 24,'Color','k');

% Direction vector v
quiver3(app.ax(1), 0,       0,    0,...
    v(1), v(2), v(3), 0,'b','LineWidth',2,'MaxHeadSize',0.5);

% Vector v label
text(v(1)+labelOffset, v(2)+labelOffset, v(3)+labelOffset, ...
    '$\vec{v}$','Interpreter','latex','FontSize',24,'Color','b');

%% Dynamic elements
% Elements for the plane:
[sGrid,tGrid] = meshgrid(linspace(tLine(1), tLine(2), 7)); % 7 for nice stepsize
XPlane = r0(1) + tGrid*v(1) + sGrid*u(1);
YPlane = r0(2) + tGrid*v(2) + sGrid*u(2);
ZPlane = r0(3) + tGrid*v(3) + sGrid*u(3);

% % Plane surface. Initially not visable
Plane_Plot = surf(XPlane, YPlane, ZPlane,...
    'FaceColor', 'cyan', 'FaceAlpha', 0.3, 'Visible', 'off');

% Direction vector u
Plane_dir_vec = quiver3(0,    0,    0,...
    u(1), u(2), u(3),...
    0, 'r', 'LineWidth',2, 'MaxHeadSize', 0.5, 'Visible', 'off');

% Line along  u. Initially not visable
lineUpts = r0 + u*tLine;
Plane_dir_line = plot3(lineUpts(1,:), lineUpts(2,:), lineUpts(3,:),...
    'r','LineWidth',2,'Visible','off');

% Point on r = r0 + tv + su
r = r0 + t0*v ;
Moving_Point_on_plane = plot3(r(1), r(2), r(3),'om',...
    'MarkerSize',10,'MarkerFaceColor','m');

% Vector to r = r_0 + tv + su
Moving_Vector_on_plane = quiver3(0, 0, 0,...
    0, 0, 0,...
    0, 'm', 'LineWidth', 2,'MaxHeadSize', 0.5);

% Unit normal vector. Initially not visable
n = cross(v,u);
n = n / norm(n);
edgePoint = r0 + tLine(2)*v;

Plane_Normal_Vec = quiver3(edgePoint(1),edgePoint(2),edgePoint(3), ...
    n(1),n(2),n(3), ...
    0,'k','LineWidth',2,'MaxHeadSize',0.7,'Visible','off');

% Normal vector label. Initially not visable
Normal_vector_Label = text(edgePoint(1) + n(1) + labelOffset, ...
    edgePoint(2) + n(2) + labelOffset, ...
    edgePoint(3) + n(3) + labelOffset, ...
    '$\vec{n} = \vec{v} \times \vec{u}$', ...
    'Interpreter','latex', 'FontSize',24,'Color','k','Visible','off');

% Line equation label
Point_Label = text(r(1)+labelOffset, r(2)+labelOffset, r(3)+labelOffset, ...
    '$\vec{r}(t) = \vec r_0 + t\vec{v}$', ...
    'Interpreter', 'latex','FontSize', 24,'Color','m');

% Vector u label
u_Vector_Label = text(u(1)+labelOffset, u(2)+labelOffset, u(3)+labelOffset, ...
    '$\vec{u}$', ...
    'Interpreter','latex','FontSize',24,'Color','r','Visible','off');

% Force a view
view(app.ax(1), 7, 32);

%% Precompute math for updates
% Light weight so skip

%% Build UI
num_GUI = 4;

sliderT = app.addControl('slider', '$t = $', 1, num_GUI,  @updatePlot_t,...
    'Default',t0, 'Min',-1, 'Max',1);
% Put update function here as it is simple
    function updatePlot_t(~, ~)
        update(sliderT.Value, sliderS.Value)
    end

sliderS = app.addControl('slider', '$s = $', 2, num_GUI,  @updatePlot_s,...
    'Default',0, 'Min',-1, 'Max',1,...
    'Visible', 'off');
% Put update function here as it is simple
    function updatePlot_s(~, ~)
        update(sliderT.Value, sliderS.Value)
    end

app.addControl('button', 'Show Plane', 3, num_GUI,  @updatePlot_btn_Swap_Plane_Line);
% Put update function here as it is "simple"
    function updatePlot_btn_Swap_Plane_Line(src,~)
        % Change strings
        if src.Value
            src.String='Line Mode';
            set(Point_Label, 'String', '$\vec r(t,s) = \vec r_0 + t\vec{v} + s\vec{u}$');
        else
            src.String='Plane Mode';
            set(Point_Label, 'String', '$\vec r(t,s) = \vec r_0 + t\vec{v}$');
        end
        % Toggle view states
        flip_state(Plane_Plot);
        flip_state(Plane_dir_vec);
        flip_state(Plane_dir_line);
        flip_state(u_Vector_Label);
        flip_state(btn_Normal_View);
        flip_state(sliderS); sliderS.Value=0.0;
        flip_state(Normal_vector_Label)
        flip_state(Plane_Normal_Vec)

        %update plot
        update(sliderT.Value, sliderS.Value)
    end

btn_Normal_View= app.addControl('button', 'Normal View', 4, num_GUI,  @updatePlot_btn_Normal_View,...
    'Visible','off');
% Put update function here as it is simple
    function updatePlot_btn_Normal_View(src,~)
        if src.Value
            % manually found for default u and v. Does not update with user data!!
            view(app.ax(1), -44.8, -48);
            btn_Normal_View.String = "Orignal View";
        else
            view(app.ax(1), 7, 32);
            btn_Normal_View.String = "Normal View";
        end
    end

%% Functions for UI elements
% Function to flip view states
    function flip_state(PlotItem)
        if strcmp(PlotItem.Visible,'on')
            PlotItem.Visible='off';
        else
            PlotItem.Visible='on';
        end
    end

%% Main Draw update function. All initial plot functions are updated below.
    function update(t,s)
        % update points
        rPlane = r0 + t*v + s*u;
        set(Moving_Vector_on_plane, 'UData', rPlane(1),...
            'VData',rPlane(2) ,'WData',rPlane(3))
        set(Moving_Point_on_plane, 'XData', rPlane(1),...
            'YData',rPlane(2) ,'ZData',rPlane(3))

        %update label for point function
        Point_Label.Position = rPlane + labelOffset;
    end
end