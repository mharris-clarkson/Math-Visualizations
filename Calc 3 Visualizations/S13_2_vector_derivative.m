function S13_2_vector_derivative
%% Script showing the idea behind the definition of the vector derivative
% of a curve in R3
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all;

%% User parameters for math objects.
% Adjust these to modify selected math objects below.
% Vector function
r = @(t) [cos(t); sin(t); 0.5*t];

% Initial parameters
t0 = pi/2;
dt0 = 1;   % sets dt0 and dt max.

% Plot limits
t_Plot_range = [0, pi-.25];
Min_dt = 1e-8;

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('3D Visualization of the Definition for $\vec r\,''(t)$',1); % Plots_to_test is an optional argument to allow for more subplots
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations
% None

%% ============== Make the initial plots =================================
% Setup axis
hold(app.ax,'on')
view(0,90)

% Main curve
tPlot = linspace(t_Plot_range(1), t_Plot_range(2), 50);
curve = r(tPlot);
% Initial points
p1 = r(t0);
p2 = r(t0 + dt0);

%% Plotting elements

% Plot function curve
plot3(app.ax,curve(1,:),curve(2,:),curve(3,:), ...
    'b','LineWidth',2);

% Tangent vector
drdt = Diff_f_forward(r,t0);
quiver3(app.ax,p1(1),p1(2),p1(3), ...
    drdt(1),drdt(2),drdt(3), ...
    1,'g','AutoScale','off','LineWidth',2,'MaxHeadSize',0.5);

% Tangent Line
tangentLength = 1.2; % scale the length of the line
tLine = [-1 1];       % parametric factor along tangent
linePoints = p1 + drdt(:) * tangentLength * tLine; % 2 points along tangent
plot3(app.ax, linePoints(1,:), linePoints(2,:), linePoints(3,:), ...
    'k--','LineWidth',1);

% Vector: r(t0)
quiver3(app.ax,0,     0, 0,...
    p1(1), p1(2), p1(3),...
    1,'k','AutoScale','off','LineWidth',2,'MaxHeadSize',0.5);

% Vector: r(t0 + dt)
Vec_R_t0dt = quiver3(app.ax,0,     0, 0,...
    p2(1), p2(2), p2(3),...
    1,'m','AutoScale','off','LineWidth',2,'MaxHeadSize',0.5);

% Approximate r'
Tan_r_Vec = Diff_f_forward(r,t0,'Dt', dt0);
hTan_r = quiver3(app.ax,p1(1),    p1(2),    p1(3),...
    Tan_r_Vec(1),Tan_r_Vec(2),Tan_r_Vec(3),...
    1,'r','AutoScale','off','LineWidth',4,'MaxHeadSize',0.5);

% plot r(t + dt) -r(t)
Sec_vec = p2 - p1;
hSec_vec = quiver3(app.ax,p1(1),    p1(2),    p1(3),...
    Sec_vec(1),Sec_vec(2),Sec_vec(3),...
    1,'c','AutoScale','off','LineWidth',2,'MaxHeadSize',0.5);

% Point: Origin
plot3(app.ax,0,0,0, ...
    'ko','MarkerSize',8,...
    'MarkerFaceColor','k',...
    'LineWidth',2);
text(app.ax, 0.01, 0.01, 0.01, '$(0,0,0)$', ...
    'Interpreter', 'latex', ...
    'FontSize', 18)

% Point: r(t0)
plot3(app.ax,p1(1),p1(2),p1(3), ...
    'ko','MarkerSize',8,...
    'MarkerFaceColor','k',...
    'LineWidth',2);

% Point: r(t0 + dt)
Point_R_t0dt = plot3(app.ax,p2(1),p2(2),p2(3), ...
    'mo','MarkerSize',8,...
    'MarkerFaceColor','m',...
    'LineWidth',2);

% Plot curve Direction
% Aprox direction for curve
Vec = Diff_f_forward(r,t_Plot_range(2));
quiver3(app.ax,curve(1,end), curve(2,end), curve(3,end),...
    Vec(1),       Vec(2), Vec(3),...
    0.25,'b','AutoScale','off','LineWidth',2,'MaxHeadSize',0.5);

%% Plot elements are done - Make pretty
% Legend
leg = legend(app.ax,'Curve $\vec r(t)$','$\vec r\,''(t)$','Tangent Line',...
    '$\vec r(t_0)$','$\vec r(t_0 + \Delta t)$', ...
    '$\frac{\vec r(t_0 + \Delta t)-\vec r(t_0)}{\Delta t}$', '$\vec r(t_0 + \Delta t)-\vec r(t_0)$');
set(leg,'Interpreter','latex')
set(leg,'FontSize',24)
Pretty_Plot(app.ax);
xlim(app.ax,[min(curve(1,:))-0.25 max(curve(1,:))+0.25]);
ylim(app.ax,[min(curve(2,:))-0.1 max(curve(2,:))+0.25]);
zlim(app.ax,[min(curve(3,:))-0.25 max(curve(3,:))+0.25]);

%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

% Slider for dt
[dtSlider, dtLabel] = app.addControl('slider', '$\Delta t = $', 1, NumControls, @updatePlot_dt,...
    'default', dt0,'Min', Min_dt, 'Max',dt0);

    function updatePlot_dt(~,~)
        % If sufficiently small say it is the limit
        if abs(dtSlider.Value) < Min_dt*10
            if dtSlider.Max > 0 % if positive
                dtSlider.Value = dtSlider.Min;
            else
                dtSlider.Value = dtSlider.Max;
            end
            dtSlider.UserData.label.String = '$\Delta t \to 0$'; % update string

        end
        updatePlot()
    end
% Button for sign swap

btn_Swap_dt = app.addControl('button', 'Change Sign of $\Delta t$', 2, NumControls,  @updatePlot_btn_Swap_dt);

    function updatePlot_btn_Swap_dt(~,~)
        % Swap the sign of dt
        if dtSlider.Max > 0 % if positive
            dtSlider.Value  = -dt0;
            dtSlider.Min    = -dt0;
            dtSlider.Max    = -Min_dt;
        else
            dtSlider.Value = dt0;
            dtSlider.Max   = dt0;
            dtSlider.Min   = Min_dt;
        end
        updatePlot()
    end

%% Functions for UI elements
% none

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

        % Update data
        dt = dtSlider.Value;
        p2 = r(t0 + dt);

        %% Update plots
        % Vector and point on curve
        set(Vec_R_t0dt,'UData',p2(1),'VData',p2(2),'WData',p2(3));
        set(Point_R_t0dt,'XData',p2(1),'YData',p2(2),'ZData',p2(3));

        % r' approx
        Tan_r_Vec = Diff_f_forward(r,t0,'Dt', dt);
        set(hTan_r,'UData',Tan_r_Vec(1),'VData',Tan_r_Vec(2),'WData',Tan_r_Vec(3));

        % r(t+dt) -r(t)
        Sec_vec = p2 - p1;
        set(hSec_vec,'UData',Sec_vec(1),'VData',Sec_vec(2),'WData',Sec_vec(3));
    end
end
