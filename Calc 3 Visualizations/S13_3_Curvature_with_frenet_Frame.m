function S13_3_Curvature_with_frenet_Frame()
%% 3D Curvature visualization with the Frenet frame (T, N, B vectors),
%  osculating circle, normal plane, and osculating plane. Supports toggling
% between two curves.
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.
%
close all

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
tlims = [0, pi];
t0    = pi/2;

% Shared toggle state
Constant_curve     = true;
ShowOscCircle      = false;
ShowNormalPlane    = false;
ShowOscPlane       = false;

%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('3D Curvature and Frenet Frame', 1);
hold(app.ax, 'on')
axis(app.ax, 'equal')
view(app.ax, 3)

%% Optional math functions for plot computations
    function r = get_curve(t)
        if Constant_curve
                        r = [cos(3*t), sin(3*t), 3*t/(2*pi)];
        else
            r = [(1./(pi + 0.5*pi*sin(6*t))) .* cos(2*t), ...
                 (1./(pi + 0.5*pi*sin(6*t))) .* sin(2*t), ...
                 t];
        end
    end

    function [r1, r2] = FD_approx(t)
        % r'(t) and r''(t) from the shared helpers (step sizes tuned there)
        r1 = Diff_f(@get_curve, t);
        r2 = Diff2_f(@get_curve, t);
    end

%% Make the initial plots
% Every object is created once here and updated in place (set ...Data)
% by plot_curve / update_frenet, instead of being deleted and re-drawn.
hCurve = plot3(app.ax, NaN, NaN, NaN, 'b', 'LineWidth', 2);
hDir   = quiver3(app.ax, 0, 0, 0, 0, 0, 0, ...
    0.1,'b','AutoScale','off','LineWidth',2,'MaxHeadSize',1);
hPt    = plot3(app.ax, NaN, NaN, NaN, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
hT     = quiver3(app.ax, 0,0,0, 0,0,0, 0, 'r', 'LineWidth', 2);
hN     = quiver3(app.ax, 0,0,0, 0,0,0, 0, 'm', 'LineWidth', 2);
hB     = quiver3(app.ax, 0,0,0, 0,0,0, 0, 'c', 'LineWidth', 2);
hCirc  = plot3(app.ax, NaN, NaN, NaN, 'k--', 'LineWidth', 2, 'Visible', 'off');
hNormP = surf(app.ax, NaN(10), NaN(10), NaN(10), 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none', 'FaceColor', 'g', 'Visible', 'off');
hOscP  = surf(app.ax, NaN(10), NaN(10), NaN(10), 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none', 'FaceColor', 'y', 'Visible', 'off');
legend(app.ax, [hT, hN, hB], ...
    {'$\vec{T}$ (unit tangent)', '$\vec{N}$ (unit normal)', '$\vec{B} = \vec{T}\times\vec{N}$'}, ...
    'Interpreter', 'latex', 'FontSize', 16, 'AutoUpdate', 'off')

L = 0.5; % plane half-size
[uP, vP] = meshgrid(linspace(-L, L, 10));   % planes centred on the point
th = linspace(0, 2*pi, 100)';                % osculating circle angles

    function plot_curve()
        tFine = linspace(tlims(1), tlims(2), 600)';
        rMat  = get_curve(tFine);              % get_curve works on a column of t
        set(hCurve, 'XData', rMat(:,1), 'YData', rMat(:,2), 'ZData', rMat(:,3));
        tmax = tlims(2);
        % plot direction quiver
        h = 0.1;
        vec = (get_curve(tmax + h)-get_curve(tmax))/h;
        point = get_curve(tmax);
        set(hDir, 'XData', point(1), 'YData', point(2), 'ZData', point(3), ...
            'UData', vec(1), 'VData', vec(2), 'WData', vec(3));
    end

    function update_frenet(t)
        r  = get_curve(t);
        [r1, r2] = FD_approx(t);

        kappa = norm(cross(r1, r2)) / norm(r1)^3;
        T = r1 / norm(r1);
        B = cross(r1, r2); B = B / norm(B);
        N = cross(B, T);

        s = 0.5; % vector display scale

        % Point on curve
        set(hPt, 'XData', r(1), 'YData', r(2), 'ZData', r(3));

        % T, N, B vectors
        set(hT, 'XData', r(1), 'YData', r(2), 'ZData', r(3), 'UData', T(1)*s, 'VData', T(2)*s, 'WData', T(3)*s);
        set(hN, 'XData', r(1), 'YData', r(2), 'ZData', r(3), 'UData', N(1)*s, 'VData', N(2)*s, 'WData', N(3)*s);
        set(hB, 'XData', r(1), 'YData', r(2), 'ZData', r(3), 'UData', B(1)*s, 'VData', B(2)*s, 'WData', B(3)*s);

        % Osculating circle: radius 1/kappa, centre r + N/kappa, in the
        % osculating plane spanned by T and N (it was drawn in the N-B
        % plane, i.e. the normal plane)
        if ShowOscCircle && kappa > 1e-10
            R      = 1 / kappa;
            center = r + R*N;
            C      = center + R*(cos(th)*(-N) + sin(th)*T);
            set(hCirc, 'XData', C(:,1), 'YData', C(:,2), 'ZData', C(:,3), 'Visible', 'on');
        else
            set(hCirc, 'Visible', 'off');
        end

        % Normal plane: spanned by N and B
        if ShowNormalPlane
            set(hNormP, 'XData', r(1) + uP*N(1) + vP*B(1), ...
                        'YData', r(2) + uP*N(2) + vP*B(2), ...
                        'ZData', r(3) + uP*N(3) + vP*B(3), 'Visible', 'on');
        else
            set(hNormP, 'Visible', 'off');
        end

        % Osculating plane: spanned by T and N
        if ShowOscPlane
            set(hOscP, 'XData', r(1) + uP*T(1) + vP*N(1), ...
                       'YData', r(2) + uP*T(2) + vP*N(2), ...
                       'ZData', r(3) + uP*T(3) + vP*N(3), 'Visible', 'on');
        else
            set(hOscP, 'Visible', 'off');
        end

        title(app.ax, sprintf('3D Curvature and Frenet Frame: $\\kappa = %.4f$', kappa), ...
            'Interpreter', 'latex')
    end

% First draw
plot_curve();
update_frenet(t0);

%% Precompute math for updates
% Light weight — skip

%% Build UI
NumControls = 5;

tSlider = app.addControl('slider', '$t = $', 1, NumControls, @updateSlider, ...
    'Default', t0, 'Min', tlims(1), 'Max', tlims(2));

    function updateSlider(~, ~)
        update_frenet(tSlider.Value);
    end

% Buttons: 'Toggle' keeps each label in step with its state. The first
% curve (cos t, sin t, t/2pi) is the helix (constant curvature); the second
% has a wobbling radius, so its curvature varies.
app.addControl('button', '', 2, NumControls, @toggleCurve, ...
    'Toggle', ["Curve: Helix (Constant Curvature)", "Curve: Varying Curvature"]);
    function toggleCurve(src, ~)
        Constant_curve = ~logical(src.Value);
        plot_curve();
        update_frenet(tSlider.Value);
    end

app.addControl('button', '', 3, NumControls, @toggleCircle, ...
    'Toggle', ["Show Osculating Circle", "Hide Osculating Circle"]);
    function toggleCircle(src, ~)
        ShowOscCircle = logical(src.Value);
        update_frenet(tSlider.Value);
    end

app.addControl('button', '', 4, NumControls, @toggleNormalPlane, ...
    'Toggle', ["Show Normal Plane", "Hide Normal Plane"]);
    function toggleNormalPlane(src, ~)
        ShowNormalPlane = logical(src.Value);
        update_frenet(tSlider.Value);
    end

app.addControl('button', '', 5, NumControls, @toggleOscPlane, ...
    'Toggle', ["Show Osculating Plane", "Hide Osculating Plane"]);
    function toggleOscPlane(src, ~)
        ShowOscPlane = logical(src.Value);
        update_frenet(tSlider.Value);
    end

%% Functions for UI elements
% (none: the buttons use the 'Toggle' option for their text)

%% Main Draw update function.
% (Handled directly in each button/slider callback above)
end
