function S12_4_Cross_product_and_volumes()
%% Visualizes the cross product of two vectors u and v, showing the
%  resulting normal vector, the parallelogram they span, and optionally
%  the parallelepiped formed with a third height vector w.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
% This version of the script was ported to the new framework I am using
% with the help of Claud Code.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
v1 = [2, 0, 0];  % red vector u
v2 = [0, 2, 0];  % blue vector v
v3 = [0, 0, 2];  % green height vector w

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Cross Products, Parallelogram, and Parallelepiped', 1);
axis(app.ax, 'equal')
view(app.ax, 3)
title(app.ax, 'Cross Products, Parallelogram, and Parallelepiped', 'Interpreter', 'latex')

%% Make the initial plots
[s, t] = meshgrid(linspace(0, 1, 10));
X = s*v1(1) + t*v2(1);
Y = s*v1(2) + t*v2(2);
Z = s*v1(3) + t*v2(3);
hPlane = surf(app.ax, X, Y, Z, 'FaceAlpha',0.5, 'EdgeColor','k', 'FaceColor','c');

hV1 = quiver3(app.ax, 0,0,0, v1(1),v1(2),v1(3), 0, 'r', 'LineWidth',2, 'MaxHeadSize',0.5);
hV2 = quiver3(app.ax, 0,0,0, v2(1),v2(2),v2(3), 0, 'b', 'LineWidth',2, 'MaxHeadSize',0.5);
hV3 = quiver3(app.ax, 0,0,0, v3(1),v3(2),v3(3), 0, 'g', 'LineWidth',2, 'MaxHeadSize',0.5, 'Visible','off');

n  = cross(v1, v2);
hN = quiver3(app.ax, 0,0,0, n(1),n(2),n(3), 0, 'k', 'LineWidth',2, 'MaxHeadSize',0.5);

offset   = 0.05;
hLabelV1 = text(app.ax, v1(1)+offset, v1(2)+offset, v1(3)+offset, '$\mathbf{u}$', 'Interpreter','latex', 'FontSize',18, 'Color','r');
hLabelV2 = text(app.ax, v2(1)+offset, v2(2)+offset, v2(3)+offset, '$\mathbf{v}$', 'Interpreter','latex', 'FontSize',18, 'Color','b');
hLabelN  = text(app.ax, n(1)+offset,  n(2)+offset,  n(3)+offset,  '$\mathbf{n}=\mathbf{u}\times\mathbf{v}$', 'Interpreter','latex', 'FontSize',18, 'Color','k');

mid   = (v1+v2)/2;
hText = text(app.ax, mid(1),mid(2),mid(3), sprintf('Area = %.2f', norm(n)), ...
    'FontSize',18, 'FontWeight','bold', 'BackgroundColor','w', 'Visible','off');

hPara    = patch(app.ax, 'Vertices',zeros(8,3), 'Faces',[], ...
    'FaceColor','m', 'FaceAlpha',0.3, 'EdgeColor','k', 'Visible','off');
hVolText = text(app.ax, 0,0,0, '', 'FontSize',18, 'FontWeight','bold', ...
    'BackgroundColor','w', 'Visible','off');

Pretty_Plot(app.ax)

% Force set plot limits
minaxis = 5;
set(app.ax,'XLim', minaxis*[-1,1], ...
    'YLim', minaxis*[-1,1], ...
    'ZLim', minaxis*[-1,1])

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 11;

s_v1x  = app.addControl('slider', '$u_x = $', 1, NumControls, @updatePlot, 'Default', v1(1), 'Min', -2, 'Max', 2);
s_v1y  = app.addControl('slider', '$u_y = $', 2, NumControls, @updatePlot, 'Default', v1(2), 'Min', -2, 'Max', 2);
s_v1z  = app.addControl('slider', '$u_z = $', 3, NumControls, @updatePlot, 'Default', v1(3), 'Min', -2, 'Max', 2);

s_v2x  = app.addControl('slider', '$v_x = $', 4, NumControls, @updatePlot, 'Default', v2(1), 'Min', -2, 'Max', 2);
s_v2y  = app.addControl('slider', '$v_y = $', 5, NumControls, @updatePlot, 'Default', v2(2), 'Min', -2, 'Max', 2);
s_v2z  = app.addControl('slider', '$v_z = $', 6, NumControls, @updatePlot, 'Default', v2(3), 'Min', -2, 'Max', 2);

s_v3x  = app.addControl('slider', '$w_x = $', 7, NumControls, @updatePlot, 'Default', v3(1), 'Min', -2, 'Max', 2, 'Visible', 'off');
s_v3y  = app.addControl('slider', '$w_y = $', 8, NumControls, @updatePlot, 'Default', v3(2), 'Min', -2, 'Max', 2, 'Visible', 'off');
s_v3z  = app.addControl('slider', '$w_z = $', 9, NumControls, @updatePlot, 'Default', v3(3), 'Min', -2, 'Max', 2, 'Visible', 'off');

btnArea = app.addControl('button', 'Show Area',           10, NumControls, @toggleArea, 'ColorChange', true);
btnPara = app.addControl('button', 'Show Parallelepiped', 11, NumControls, @togglePara, 'ColorChange', true);

%% Functions for UI elements
    function toggleArea(~, ~)
        set(hText, 'Visible', onoff(btnArea.Value))
    end

    function togglePara(~, ~)
        % Show/hide w sliders with the parallelepiped
        vis = onoff(btnPara.Value);
        set(s_v3x, 'Visible', vis);
        set(s_v3y, 'Visible', vis);
        set(s_v3z, 'Visible', vis);
        set(s_v3x.UserData.label, 'Visible', vis);
        set(s_v3y.UserData.label, 'Visible', vis);
        set(s_v3z.UserData.label, 'Visible', vis);
        updatePlot()
    end

    function s = onoff(val)
        if val; s = 'on'; else; s = 'off'; end
    end

%% Main Draw update function.
    function updatePlot(~, ~)
        u = [s_v1x.Value, s_v1y.Value, s_v1z.Value];
        v = [s_v2x.Value, s_v2y.Value, s_v2z.Value];
        w = [s_v3x.Value, s_v3y.Value, s_v3z.Value];

        set(hV1, 'UData',u(1), 'VData',u(2), 'WData',u(3))
        set(hV2, 'UData',v(1), 'VData',v(2), 'WData',v(3))
        set(hV3, 'UData',w(1), 'VData',w(2), 'WData',w(3))

        X = s*u(1) + t*v(1);
        Y = s*u(2) + t*v(2);
        Z = s*u(3) + t*v(3);
        set(hPlane, 'XData',X, 'YData',Y, 'ZData',Z)

        n = cross(u, v);
        set(hN, 'UData',n(1), 'VData',n(2), 'WData',n(3))

        set(hText, 'Position',(u+v)/2, 'String',sprintf('Area = %.2f', norm(n)))
        set(hLabelV1, 'Position', u+offset)
        set(hLabelV2, 'Position', v+offset)
        set(hLabelN,  'Position', n+offset)

        % Update plot limits
        axislim =  max(abs([minaxis,v,u,w,n]));
        set(app.ax,'XLim', axislim*[-1,1], ...
            'YLim', axislim*[-1,1], ...
            'ZLim', axislim*[-1,1])

        if btnPara.Value
            verts = [0 0 0; u; v; w; u+v; u+w; v+w; u+v+w];
            faces = [1 2 5 3; 1 2 6 4; 1 3 7 4; 8 5 2 6; 8 7 3 5; 8 6 4 7];
            set(hPara, 'Vertices',verts, 'Faces',faces, 'Visible','on')
            vol = abs(dot(u, cross(v, w)));
            set(hVolText, 'Position',mean(verts,1), ...
                'String',sprintf('Volume = %.2f', vol), 'Visible','on')
            set(hV3, 'Visible','on')
        else
            set(hPara,    'Visible','off')
            set(hVolText, 'Visible','off')
            set(hV3,      'Visible','off')
        end
    end
end