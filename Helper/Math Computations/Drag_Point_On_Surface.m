function Drag_Point_On_Surface(ax, f, xlims, ylims, moveFcn, options)
%% Click or drag on the graph z = f(x,y) in a 3D axes to move a point
% After this call, clicking anywhere in ax calls moveFcn(x, y) with the
% point (x,y) of the surface under the mouse, and holding the button down
% keeps calling it while the mouse moves. The point is found by following
% the mouse ray from the front of the axes box until it first passes below
% the surface, so it lands under the cursor even on steep or tall parts of
% the graph. If the ray misses the surface, the point where it meets the
% plane z = 0 is used. The point is kept inside xlims x ylims.
%
% Call it AFTER all plots are made: it turns off clicks on every object in
% ax (so the clicks reach the axes) and turns off the built-in rotate/pan
% on drag, which would compete with moving the point. The axes toolbar
% rotate button still works.
%
%% Syntax
%
% Drag_Point_On_Surface(app.ax, f, [-1 1], [-1 1], @(x,y) redraw(x, y))
% Drag_Point_On_Surface(ax, f, xlims, ylims, moveFcn, 'nRay', 800)
%
% Inputs:
%
% ax       - 3D axes that shows the graph of f.
% f        - function handle f(x,y) (elementwise).
% xlims    - [xmin xmax] the point may move in.
% ylims    - [ymin ymax] the point may move in.
% moveFcn  - called as moveFcn(x, y) every time the point moves.
% 'nRay'   - samples along the mouse ray (default 400).
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    ax
    f              function_handle
    xlims          (1,2) double
    ylims          (1,2) double
    moveFcn        function_handle
    options.nRay   (1,1) double = 400
end

fig = ancestor(ax, 'figure');

% Every plotted object ignores clicks so they reach the axes' ButtonDownFcn
set(ax.Children, 'HitTest', 'off', 'PickableParts', 'none')
disableDefaultInteractivity(ax)
ax.ButtonDownFcn = @startDrag;

    function startDrag(~, ~)
        doDrag();                                % a click alone moves the point
        fig.WindowButtonMotionFcn = @doDrag;
        fig.WindowButtonUpFcn     = @stopDrag;
    end

    function doDrag(~, ~)
        P = pointUnderMouse();
        if isempty(P), return, end
        moveFcn(P(1), P(2))
        drawnow limitrate
    end

    function stopDrag(~, ~)
        fig.WindowButtonMotionFcn = '';
        fig.WindowButtonUpFcn     = '';
    end

    % Point (x,y) on the surface under the mouse
    function P = pointUnderMouse()
        cp = ax.CurrentPoint;                    % row 1 = front, row 2 = back
        t  = linspace(0, 1, options.nRay).';
        L  = cp(1,:) + t.*(cp(2,:) - cp(1,:));   % points along the ray
        inBox = L(:,1) >= xlims(1) & L(:,1) <= xlims(2) & ...
                L(:,2) >= ylims(1) & L(:,2) <= ylims(2);
        g = L(:,3) - f(L(:,1), L(:,2));          % height above the surface
        g(~inBox) = NaN;
        k = find(g(1:end-1) > 0 & g(2:end) <= 0, 1);
        if ~isempty(k)
            s = g(k)/(g(k) - g(k+1));            % linear interpolation in the step
            P = L(k,1:2) + s*(L(k+1,1:2) - L(k,1:2));
        else
            dz = cp(2,3) - cp(1,3);
            if abs(dz) < 1e-12, P = []; return, end
            P = cp(1,1:2) - cp(1,3)/dz*(cp(2,1:2) - cp(1,1:2));
        end
        P = [min(max(P(1), xlims(1)), xlims(2)), min(max(P(2), ylims(1)), ylims(2))];
    end
end
