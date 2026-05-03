function S13_3_Curvature_with_frenet_Frame()
%% 3D Curvature visualization with the Frenet frame (T, N, B vectors),
%  osculating circle, normal plane, and osculating plane. Supports toggling
% between two curves.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
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
                        r = [cos(t), sin(t), t/(2*pi)];
        else
            r = [(1./(pi + 0.5*pi*sin(6*t))) .* cos(2*t), ...
                 (1./(pi + 0.5*pi*sin(6*t))) .* sin(2*t), ...
                 t];
        end
    end

    function [r1, r2] = FD_approx(t)
        dt = 1e-5;
        rp = get_curve(t + dt);
        rm = get_curve(t - dt);
        r0 = get_curve(t);
        r1 = (rp - rm) / (2*dt);
        r2 = (rp - 2*r0 + rm) / (dt^2);
    end

%% Make the initial plots
    function plot_curve()
        delete(findall(app.ax, 'Tag', 'mainCurve'));
        tFine = linspace(tlims(1), tlims(2), 600);
        rMat  = arrayfun(@(t) get_curve(t), tFine, 'UniformOutput', false);
        rMat  = vertcat(rMat{:});
        plot3(app.ax, rMat(:,1), rMat(:,2), rMat(:,3), ...
            'b', 'LineWidth', 2, 'Tag', 'mainCurve');
        tmax = tlims(2);
        % plot direction quiver
        h = 0.1;
        vec = (get_curve(tmax + h)-get_curve(tmax))/h;
        point = get_curve(tmax);
        quiver3(app.ax,point(1), point(2), point(3),vec(1),vec(2),vec(3),...
            0.1,'b','AutoScale','off','LineWidth',2,'MaxHeadSize',1);
    end

    function update_frenet(t)
        % Remove previous dynamic elements
        delete(findall(app.ax, 'Tag', 'frenetPt'));
        delete(findall(app.ax, 'Tag', 'frenetVec'));
        delete(findall(app.ax, 'Tag', 'oscCircle'));
        delete(findall(app.ax, 'Tag', 'normalPlane'));
        delete(findall(app.ax, 'Tag', 'oscPlane'));

        r  = get_curve(t);
        [r1, r2] = FD_approx(t);

        kappa = norm(cross(r1, r2)) / norm(r1)^3;
        T = r1 / norm(r1);
        B = cross(r1, r2); B = B / norm(B);
        N = cross(B, T);

        s = 0.5; % vector display scale

        % Point on curve
        plot3(app.ax, r(1), r(2), r(3), 'ko', ...
            'MarkerFaceColor', 'k', 'MarkerSize', 8, 'Tag', 'frenetPt');

        % T, N, B vectors
        quiver3(app.ax, r(1),r(2),r(3), T(1)*s,T(2)*s,T(3)*s, ...
            0, 'r', 'LineWidth', 2, 'Tag', 'frenetVec');
        quiver3(app.ax, r(1),r(2),r(3), N(1)*s,N(2)*s,N(3)*s, ...
            0, 'm', 'LineWidth', 2, 'Tag', 'frenetVec');
        quiver3(app.ax, r(1),r(2),r(3), B(1)*s,B(2)*s,B(3)*s, ...
            0, 'c', 'LineWidth', 2, 'Tag', 'frenetVec');

        % Osculating circle
        if ShowOscCircle && kappa > 1e-10
            R      = 1 / kappa;
            center = r + R*N;
            th     = linspace(0, 2*pi, 100);
            C      = center + R*(cos(th')*(-N) + sin(th')*B);
            plot3(app.ax, C(:,1), C(:,2), C(:,3), ...
                'k--', 'LineWidth', 2, 'Tag', 'oscCircle');
        end

        L = 0.5; % plane half-size
        % Normal plane: spanned by N and B
        if ShowNormalPlane
            [u, v] = meshgrid(linspace(0, L, 10));
            Xp = r(1) + u*N(1) + v*B(1);
            Yp = r(2) + u*N(2) + v*B(2);
            Zp = r(3) + u*N(3) + v*B(3);
            surf(app.ax, Xp, Yp, Zp, 'FaceAlpha', 0.2, ...
                'EdgeColor', 'none', 'FaceColor', 'g', 'Tag', 'normalPlane');
        end

        % Osculating plane: spanned by T and N
        if ShowOscPlane
            [u, v] = meshgrid(linspace(0, L, 10));
            Xp = r(1) + u*T(1) + v*N(1);
            Yp = r(2) + u*T(2) + v*N(2);
            Zp = r(3) + u*T(3) + v*N(3);
            surf(app.ax, Xp, Yp, Zp, 'FaceAlpha', 0.2, ...
                'EdgeColor', 'none', 'FaceColor', 'y', 'Tag', 'oscPlane');
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


app.addControl('button', 'Curve: Constant Curvature', 2, NumControls, @toggleCurve);
    function toggleCurve(src, ~)
        Constant_curve = ~logical(src.Value);
        if Constant_curve
                  src.String = 'Curve: Constant Curvature';      
        else
            src.String = 'Curve: Helix';
        end
        cla(app.ax);
        plot_curve();
        update_frenet(tSlider.Value);
    end

app.addControl('button', 'Osculating Circle ON', 3, NumControls, @toggleCircle);
    function toggleCircle(src, ~)
        ShowOscCircle = logical(src.Value);
        src.String = sprintf('Osculating Circle: %s', onOff(ShowOscCircle));
        update_frenet(tSlider.Value);
    end

app.addControl('button', 'Normal Plane ON', 4, NumControls, @toggleNormalPlane);
    function toggleNormalPlane(src, ~)
        ShowNormalPlane = logical(src.Value);
        src.String = sprintf('Normal Plane %s', onOff(ShowNormalPlane));
        update_frenet(tSlider.Value);
    end

app.addControl('button', 'Osculating Plane ON', 5, NumControls, @toggleOscPlane);
    function toggleOscPlane(src, ~)
        ShowOscPlane = logical(src.Value);
        src.String = sprintf('Osculating Plane %s', onOff(ShowOscPlane));
        update_frenet(tSlider.Value);
    end

%% Functions for UI elements
    function s = onOff(val)
        if val; s = 'ON'; else; s = 'OFF'; end
    end

%% Main Draw update function.
% (Handled directly in each button/slider callback above)
end
