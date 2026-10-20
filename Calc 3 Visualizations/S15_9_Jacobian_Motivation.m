function S15_9_Jacobian_Motivation()
%% Jacobian Motivation: Area Distortion Under a Coordinate Transformation
% Shows a small rectangle in the (x,y) plane and its image under the
% transformation u(x,y), v(x,y) in the (u,v) plane. Toggles reveal the
% rectangle's edge vectors, the parallelogram spanned by the straight-line
% image of those edges, and the tangent-plane (Jacobian) approximation of
% that image.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
u = @(x,y) y./sqrt(x);
v = @(x,y) y.*sqrt(x);

x0 = 0.2; y0 = 0.3;
Dx = 0.5; Dy = 0.5;

N_plot = 30;   % points used to trace each curved edge of the rectangle's image

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure('Jacobian Motivation', 2);
ax1 = app.ax(1);
ax2 = app.ax(2);

Pretty_Plot(app.ax)
xlabel(ax1, 'x'); ylabel(ax1, 'y'); xlim(ax1, [0 2]); ylim(ax1, [0 2]);
xlabel(ax2, 'u'); ylabel(ax2, 'v'); xlim(ax2, [0 2]); ylim(ax2, [0 2]);

%% Static graphics (created once; updated in place, never recreated)
rect1 = patch(ax1, [x0 x0+Dx x0+Dx x0], [y0 y0 y0+Dy y0+Dy], 'b', 'FaceAlpha', 0.4);
pt1   = plot(ax1, x0, y0, '.k', 'MarkerSize', 20);
edge1 = quiver(ax1, x0, y0, Dx, 0, 0, 'r', 'LineWidth', 2, 'Visible', 'off');
edge2 = quiver(ax1, x0, y0, 0, Dy, 0, 'r', 'LineWidth', 2, 'Visible', 'off');

rect2  = patch(ax2, NaN, NaN, 'b', 'FaceAlpha', 0.4);
pt2    = plot(ax2, NaN, NaN, '.k', 'MarkerSize', 20);
edge2a = quiver(ax2, 0, 0, 0, 0, 0, 'r', 'LineWidth', 2, 'Visible', 'off');
edge2b = quiver(ax2, 0, 0, 0, 0, 0, 'r', 'LineWidth', 2, 'Visible', 'off');

edgeParaPatch = patch(ax2, NaN, NaN, 'g', 'FaceAlpha', 0.4, 'Visible', 'off');
tangent1      = quiver(ax2, 0, 0, 0, 0, 0, 'b', 'LineWidth', 2, 'Visible', 'off');
tangent2      = quiver(ax2, 0, 0, 0, 0, 0, 'b', 'LineWidth', 2, 'Visible', 'off');
tanParaPatch  = patch(ax2, NaN, NaN, 'k', 'FaceAlpha', 0.4, 'Visible', 'off');

%% Build UI
% (Built before the first redraw() call below, since redraw() reads the
% toggle buttons' .Value directly -- they must exist first.)
NumControls = 7;
sx0 = app.addControl('slider', '$x_0 = $', 1, NumControls, @updatePlot, ...
'Default', x0, 'Min', 0.05, 'Max', 2, 'Number_format', '%.2f');
sy0 = app.addControl('slider', '$y_0 = $', 2, NumControls, @updatePlot, ...
'Default', y0, 'Min', 0.05, 'Max', 2, 'Number_format', '%.2f');
sDx = app.addControl('slider', '$\Delta x = $', 3, NumControls, @updatePlot, ...
'Default', Dx, 'Min', 0.01, 'Max', 1, 'Number_format', '%.2f');
sDy = app.addControl('slider', '$\Delta y = $', 4, NumControls, @updatePlot, ...
'Default', Dy, 'Min', 0.01, 'Max', 1, 'Number_format', '%.2f');
btnEdgeVec  = app.addControl('button', 'Show Edge Vectors', 5, NumControls, @updatePlot, 'ColorChange', true);
btnEdgePara = app.addControl('button', 'Show Edge Parallelogram', 6, NumControls, @updatePlot, 'ColorChange', true);
btnTanPara  = app.addControl('button', 'Show Tangent Parallelogram', 7, NumControls, @updatePlot, 'ColorChange', true);

redraw(x0, y0, Dx, Dy)

%% Callback
function updatePlot(~, ~)
    redraw(sx0.Value, sy0.Value, sDx.Value, sDy.Value)
end

%% Redraw function: updates every graphics object in place for the
% current (x0,y0,Dx,Dy) and the current toggle states.
function redraw(x0, y0, Dx, Dy)
    % Ax1: rectangle, point, edge vectors
    set(rect1, 'XData', [x0 x0+Dx x0+Dx x0], 'YData', [y0 y0 y0+Dy y0+Dy])
    set(pt1, 'XData', x0, 'YData', y0)
    set(edge1, 'XData', x0, 'YData', y0, 'UData', Dx, 'VData', 0)
    set(edge2, 'XData', x0, 'YData', y0, 'UData', 0, 'VData', Dy)
    set([edge1, edge2], 'Visible', onoff(logical(btnEdgeVec.Value)))

    % Ax2: curved image of the rectangle's boundary under (u,v)
    x_plot = [x0+zeros(1,N_plot), linspace(x0,x0+Dx,N_plot), x0+Dx+zeros(1,N_plot), linspace(x0+Dx,x0,N_plot)];
    y_plot = [linspace(y0,y0+Dy,N_plot), y0+Dy+zeros(1,N_plot), linspace(y0+Dy,y0,N_plot), y0+zeros(1,N_plot)];
    set(rect2, 'XData', u(x_plot,y_plot), 'YData', v(x_plot,y_plot))
    set(pt2, 'XData', u(x0,y0), 'YData', v(x0,y0))

    set(edge2a, 'XData', u(x0,y0), 'YData', v(x0,y0), ...
        'UData', u(x0+Dx,y0)-u(x0,y0), 'VData', v(x0+Dx,y0)-v(x0,y0))
    set(edge2b, 'XData', u(x0,y0), 'YData', v(x0,y0), ...
        'UData', u(x0,y0+Dy)-u(x0,y0), 'VData', v(x0,y0+Dy)-v(x0,y0))
    set([edge2a, edge2b], 'Visible', onoff(logical(btnEdgeVec.Value)))

    % Edge parallelogram: straight-line image of the two straight edges
    if logical(btnEdgePara.Value)
        vec1 = [u(x0+Dx,y0)-u(x0,y0); v(x0+Dx,y0)-v(x0,y0)];
        vec2 = [u(x0,y0+Dy)-u(x0,y0); v(x0,y0+Dy)-v(x0,y0)];
        base = [u(x0,y0); v(x0,y0)];
        pts  = [base, base+vec1, base+vec1+vec2, base+vec2];
        set(edgeParaPatch, 'XData', pts(1,:), 'YData', pts(2,:), 'Visible', 'on')
    else
        set(edgeParaPatch, 'Visible', 'off')
    end

    % Tangent parallelogram: the Jacobian's linear approximation of the image
    if logical(btnTanPara.Value)
        J  = jacob_mat(x0, y0, u, v);
        t1 = Dx*J(:,1); t2 = Dy*J(:,2);
        base = [u(x0,y0); v(x0,y0)];
        set(tangent1, 'XData', base(1), 'YData', base(2), 'UData', t1(1), 'VData', t1(2))
        set(tangent2, 'XData', base(1), 'YData', base(2), 'UData', t2(1), 'VData', t2(2))
        pts = [base, base+t1, base+t1+t2, base+t2];
        set(tanParaPatch, 'XData', pts(1,:), 'YData', pts(2,:))
        set([tangent1, tangent2, tanParaPatch], 'Visible', 'on')
    else
        set([tangent1, tangent2, tanParaPatch], 'Visible', 'off')
    end
end

end

%% Stateless helpers (ordinary local functions, not nested)
function J = jacob_mat(x, y, funx, funy)
h = 1e-8;
J = 1/(2*h)*[funx(x+h,y)-funx(x-h,y), funx(x,y+h)-funx(x,y-h); ...
             funy(x+h,y)-funy(x-h,y), funy(x,y+h)-funy(x,y-h)];
end

function s = onoff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end