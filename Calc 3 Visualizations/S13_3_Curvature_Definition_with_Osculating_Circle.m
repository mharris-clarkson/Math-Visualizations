function S13_3_Curvature_Definition_with_Osculating_Circle()
close all;

%% Load helper functions
run('setup.m')

%% ================== User parameters =====================
curve1 = @(t) 2*[cos(t)./(1 + 0.5*sin(t));
                 sin(t)./(1 + 0.5*sin(t))+0.5];

curve2 = @(t) [(sin(2.^t)-1.7).*cos(t);
               (sin(2.^t)-1.7).*sin(t)];

r_fun = curve1;

tlims = [0 2*pi];
s0 = 0;

%% Build app
app = uiFigure('Definition of Curvature ($\kappa$) in 2D',1);
title(app.ax,app.fig.Name,'Interpreter','latex')
hold(app.ax,'on')

%% ================= Precompute =====================

% Numerical derivatives (updated dynamically when curve switches)
r_prime  = @(t) (r_fun(t+1e-6)-r_fun(t-1e-6))/(2e-6);
r_double = @(t) (r_fun(t+1e-6)-2*r_fun(t)+r_fun(t-1e-6))/(1e-6)^2;

t_samples = linspace(tlims(1), tlims(2), 10000);
[s_samples, sMax] = arclength_param(r_fun,t_samples);
t_of_s = @(s) interp1(s_samples, t_samples, s, 'linear', 'extrap');

%% Plot curve
t = linspace(tlims(1), tlims(2), 2000);
r = r_fun(t);
hCurve = plot(app.ax, r(1,:), r(2,:),'b','LineWidth',2);

%% Initial geometry
[r0,T,N,kappa,R,C] = computeVectors_s(s0);

hPoint = plot(app.ax,r0(1), r0(2), '.r', 'MarkerSize', 24);
hT = quiver(app.ax,r0(1), r0(2), T(1), T(2), 0, 'r','LineWidth',2);
hN = quiver(app.ax,r0(1), r0(2), N(1), N(2), 0, 'm','LineWidth',2);

theta = linspace(0,2*pi,200);
xCircle = C(1) + R*cos(theta);
yCircle = C(2) + R*sin(theta);
hCircle = plot(app.ax,xCircle, yCircle, 'k--','LineWidth',1.5);

legend(app.ax,[hT,hN,hCircle], {'$\vec{T}$','$d\vec{T}/ds$','Osculating Circle'}, ...
       'Interpreter','latex','FontSize',16);

Pretty_Plot(app.ax);

%% ================= UI =====================
NumControls = 2;

% Slider
sSlider = app.addControl('slider', 'Arc Length: $s = $', 1, NumControls, @updatePlot_s,...
    'default', s0,'Min', 0, 'Max',sMax);

% Button
btn_Swap_curve = app.addControl('button','Switch to Mr. Polar Face',2,NumControls,@updatePlot_switchCurve);

%% Initial draw
updatePlot_s();

%% ================= Functions =====================

function [r0,T,N,kappa,R,C] = computeVectors_s(s_val)
    t_val = t_of_s(s_val);
    r0 = r_fun(t_val);
    r1 = r_prime(t_val);
    r2 = r_double(t_val);

    T = r1 / norm(r1);

    kappa = (r1(1)*r2(2) - r1(2)*r2(1)) / (norm(r1)^3);

    N = [-r1(2); r1(1)]/norm(r1);
    N = sign(kappa)*N;

    R = abs(1/kappa);
    C = r0 + R*N;
end

function updatePlot_s(~,~)
    s_val = sSlider.Value;
    [r0,T,N,kappa,R,C] = computeVectors_s(s_val);

    set(hPoint,'XData',r0(1),'YData',r0(2));
    set(hT,'XData',r0(1),'YData',r0(2),'UData',T(1),'VData',T(2));
    set(hN,'XData',r0(1),'YData',r0(2),'UData',N(1),'VData',N(2));

    xCircle = C(1) + R*cos(theta);
    yCircle = C(2) + R*sin(theta);
    set(hCircle,'XData',xCircle,'YData',yCircle);

    title(app.ax, ['Curvature $\kappa = $', num2str(kappa,'%.3f')], 'Interpreter','latex');

    Pretty_Plot(app.ax)
    xlim(app.ax,[-5,5])
    ylim(app.ax,[-5,5])
end

function updatePlot_switchCurve(~,~)
    if strcmp(func2str(r_fun), func2str(curve1))
        r_fun = curve2;
        btn_Swap_curve.String = 'Switch to Ellipse';
    else
        r_fun = curve1;
        btn_Swap_curve.String = 'Switch to Mr. Polar Face';
    end

    % Update derivatives
    % Swap over
    r_prime  = @(t) Diff_f(r_fun,t);%r_fun(t+1e-6)-r_fun(t-1e-6))/(2e-6);
    r_double = @(t) Diff2_f(r_fun,t);(r_fun(t+1e-6)-2*r_fun(t)+r_fun(t-1e-6))/(1e-6)^2;

    % Recompute arc-length
    [s_samples, sMax] = arclength_param(r_fun, t_samples);
    t_of_s = @(s) interp1(s_samples, t_samples, s, 'linear', 'extrap');

    % Update curve
    r = r_fun(t_samples);
    set(hCurve,'XData',r(1,:),'YData',r(2,:));

    % Update slider
    sSlider.Max = sMax;
    sSlider.Value = 0;

    updatePlot_s();
end

function [s, sMax] = arclength_param(r_fun,t_samples)
    % Compute arc length parameterization
    r_prime_squared = Diff_f(r_fun,t_samples).^2;
    ds = sqrt(r_prime_squared(1,:) + r_prime_squared(2,:));
    s = cumtrapz(t_samples, ds);
    sMax = s(end);
end

end