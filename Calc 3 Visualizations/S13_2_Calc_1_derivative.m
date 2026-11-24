function S13_2_Calc_1_derivative()
%% Script showing the idea behind the definition of the calc 1 derivative
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all;

%% User parameters for math objects. 
% Adjust these to modify selected math objects below.
r = @(t) [t; sqrt(1-t.^2); 0*t];   % graph of f as a curve

t0  = 0;
dt0 = 0.5;          % starting and largest dx

Sec_Line_Scale = 1; % half-length of the secant line

t_Plot_range = [-1, 1];
Min_dt = 1e-8;      % dx below this counts as 0

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('2D Visualization of the Definition for $f''(x_0)$',1);
title(app.ax,app.fig.Name)

%% ============== Make the initial plots =================================
tPlot = linspace(t_Plot_range(1), t_Plot_range(2), 500);
curve = r(tPlot);
p1 = r(t0);
p2 = r(t0 + dt0);

plot3(app.ax,curve(1,:),curve(2,:),curve(3,:), ...
    'b','LineWidth',2);

% (x_0, f(x_0)) and (x_0 + dx, f(x_0 + dx))
plot3(app.ax,p1(1),p1(2), p1(3),...
    'ko','MarkerSize',8,...
    'MarkerFaceColor','k',...
    'LineWidth',2);

Point_R_t0dt = plot3(app.ax,p2(1),p2(2),p2(3), ...
    'mo','MarkerSize',8,...
    'MarkerFaceColor','m',...
    'LineWidth',2);

% Secant line through (x_0, f(x_0))
Sec_r_Vec = Diff_f_forward(r,t0,'Dt', dt0);
m = Sec_r_Vec(2)/Sec_r_Vec(1);
x_for_sec = p1(1) + Sec_Line_Scale*[-1,1];
y_for_sec = m*(x_for_sec - p1(1)) + p1(2);
Sec_Line = plot3(app.ax,x_for_sec,y_for_sec,0*x_for_sec, ...
    'r','LineWidth',2);

% Chord from r(t) to r(t + dt)
Chord_DAT = [p1,p2];
hChord_Line = plot3(app.ax,Chord_DAT(1,:), Chord_DAT(2,:), Chord_DAT(3,:), ...
    'm','LineWidth',2);

% Tangent line
drdt = Diff_f_forward(r,t0);
tangentLength = 1.2;
linePoints = p1 + drdt(:) * tangentLength * [-1 1];
plot3(app.ax, linePoints(1,:), linePoints(2,:), linePoints(3,:), ...
    'k--','LineWidth',1);

% dx and dy legs
hdx_Line = plot3(app.ax,Chord_DAT(1,:), [1,1]*Chord_DAT(2,2), Chord_DAT(3,:), ...
    'g','LineWidth',2);
hdy_Line = plot3(app.ax,[1,1]*p1(1), Chord_DAT(2,:), Chord_DAT(3,:), ...
    '--g','LineWidth',2);

%% Plot elements are done - Make pretty
legend(app.ax,'Curve $y = f(x)$','$(x_0 , f(x_0))$','$(x_0 +\Delta x, f(x_0+\Delta x))$',...
    'Secant Line Segment', 'Secant Chord','Tangent Line','$\Delta x$','$\Delta y$', ...
    'Location', 'best', 'FontSize', 18);

Pretty_Plot(app.ax);

xlim(app.ax,[min(curve(1,:))-0.25 max(curve(1,:))+0.25]);
ylim(app.ax,[min(curve(2,:))-0.1 max(curve(2,:))+0.25]);
zlim(app.ax,[min(curve(3,:))-0.25 max(curve(3,:))+0.25]);

%% Build UI
NumControls = 2;

dtSlider = app.addControl('slider', '$\Delta x = $', 1, NumControls, @updatePlot_dt,...
    'Default', dt0, 'Min', Min_dt, 'Max', dt0, ...
    'LimitLabel', '$\Delta x \to 0$', 'LimitAt', "zero");

app.addControl('button', 'Change Sign of $\Delta x$', 2, NumControls,  @updatePlot_btn_Swap_dt);

updatePlot()

%% Functions for UI elements
% Snap tiny dx to the end of the slider (the limit dx -> 0)
    function updatePlot_dt(~,~)
        if abs(dtSlider.Value) < Min_dt*1e2
            if dtSlider.Max > 0
                app.UpdateUISlider(dtSlider, dtSlider.Min)
            else
                app.UpdateUISlider(dtSlider, dtSlider.Max)
            end
        end
        updatePlot()
    end

    function updatePlot_btn_Swap_dt(~,~)
        if dtSlider.Max > 0
            app.UpdateUISlider(dtSlider, -dt0,...
                "Min",-dt0,"Max",-Min_dt)
        else
            app.UpdateUISlider(dtSlider, dt0,...
                "Min",Min_dt,"Max",dt0)
        end
        updatePlot()
    end

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)
        dt = dtSlider.Value;
        p2 = r(t0 + dt);
        set(Point_R_t0dt,'XData',p2(1),'YData',p2(2),'ZData',p2(3));

        Sec_r_Vec = Diff_f_forward(r,t0,'Dt', dt);
        m = Sec_r_Vec(2)/Sec_r_Vec(1);
        y_for_sec = m*(x_for_sec - p1(1)) + p1(2);
        set(Sec_Line,'xdata',x_for_sec,'ydata',y_for_sec);

        Chord_DAT = [p1, p2];
        set(hChord_Line,'xdata',Chord_DAT(1,:),'ydata',Chord_DAT(2,:));
        set(hdx_Line,'xdata',Chord_DAT(1,:),'ydata',[1,1]*Chord_DAT(2,2));
        set(hdy_Line,'ydata',Chord_DAT(2,:));
    end
end
 