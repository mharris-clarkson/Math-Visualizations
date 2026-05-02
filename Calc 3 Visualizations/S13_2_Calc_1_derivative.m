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
% Vector function
r = @(t) [t; sqrt(1-t.^2); 0*t];

% Initial parameters
t0 = 0;
dt0 = 1;   % also sets dt0 and dt max.

% Scale for secant line
Sec_Line_Scale = 1;

% Plot limits
t_Plot_range = [-1, 1];
Min_dt = 1e-8; % min dt before we call it 0.


%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('2D Visualization of the Definition for $f''(x_0)$',1); % Plots_to_test is an optional argument to allow for more subplots
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations
% None

%% ============== Make the initial plots =================================
% Function initiation
tPlot = linspace(t_Plot_range(1), t_Plot_range(2), 500);
curve = r(tPlot);
% Initial points
p1 = r(t0);
p2 = r(t0 + dt0);

% Plot function curve
plot3(app.ax,curve(1,:),curve(2,:),curve(3,:), ...
    'b','LineWidth',2);

% Point: (x_0,f(x_0,~) = r(t0)
r0 = r(t0);
plot3(app.ax,r0(1),r0(2), r0(3),...
    'ko','MarkerSize',8,...
    'MarkerFaceColor','k',...
    'LineWidth',2);

% Point: (x_0+dx,f(x_0+dx,~) = r(t0 + dt)
Point_R_t0dt = plot3(app.ax,p2(1),p2(2),p2(3), ...
    'mo','MarkerSize',8,...
    'MarkerFaceColor','m',...
    'LineWidth',2);

% Approximate f'(x_0)
Sec_r_Vec = Diff_f_forward(r,t0,'Dt', dt0);
m = Sec_r_Vec(2)/Sec_r_Vec(1);
x_for_sec = p1(1) + Sec_Line_Scale*[-1,1];
y_for_sec = m*x_for_sec + p1(2);
Sec_Line = plot3(app.ax,x_for_sec,y_for_sec,0*x_for_sec, ...
    'r','LineWidth',2);

% Plot the chord for the secant vec for r(t + dt) and r(t)
Chord_DAT = [p1,p2];
hChord_Line = plot3(app.ax,Chord_DAT(1,:), Chord_DAT(2,:), Chord_DAT(3,:), ...
    'm','LineWidth',2);

% Tangent line
drdt = Diff_f_forward(r,t0);
tangentLength = 1.2; % scale the length of the line
tLine = [-1 1];       % parametric factor along tangent
linePoints = p1 + drdt(:) * tangentLength * tLine; % 2 points along tangent
plot3(app.ax, linePoints(1,:), linePoints(2,:), linePoints(3,:), ...
    'k--','LineWidth',1);

% Dashed lines for dx and dy
hdx_Line = plot3(app.ax,Chord_DAT(1,:), [1,1]*Chord_DAT(2,2), Chord_DAT(3,:), ...
    'g','LineWidth',2);
hdy_Line = plot3(app.ax,0*Chord_DAT(1,:), Chord_DAT(2,:), Chord_DAT(3,:), ...
    '--g','LineWidth',2);

%% Plot elements are done - Make pretty
% Legend
leg = legend(app.ax,'Curve $y = f(x)$','$(x_0 , f(x_0))$','$(x_0 +\Delta x, f(x_0+\Delta x))$',...
    'Secant Line Segment', 'Secant Chord','Tangent Line','$\Delta x$','$\Delta y$');
set(leg, 'Interpreter','latex')
leg.Location ="best";
set(leg,'FontSize',18)

Pretty_Plot(app.ax);

% Change limits
xlim(app.ax,[min(curve(1,:))-0.25 max(curve(1,:))+0.25]);
ylim(app.ax,[min(curve(2,:))-0.1 max(curve(2,:))+0.25]);
zlim(app.ax,[min(curve(3,:))-0.25 max(curve(3,:))+0.25]);
%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

% dt
dtSlider = app.addControl('slider', '$\Delta x = $', 1, NumControls, @updatePlot_dt,...
                                    'default', dt0,'Min', Min_dt, 'Max',dt0);
    % Functionality
    function updatePlot_dt(~,~)
        % If sufficiently small say it is the limit
        if abs(dtSlider.Value) < Min_dt*1e2
            if dtSlider.Max > 0 % if positive
                app.UpdateUISlider(dtSlider, dtSlider.Min)
            else
                app.UpdateUISlider(dtSlider, dtSlider.Max)
            end
            dtSlider.UserData.label.String = '$\Delta x \to 0$'; % update string
        end
        updatePlot()
    end

% Button for sign swap
app.addControl('button', 'Change Sign of $\Delta x$', 2, NumControls,  @updatePlot_btn_Swap_dt);

     % Functionality
    function updatePlot_btn_Swap_dt(~,~)
        % Swap the sign of dt
        if dtSlider.Max > 0 % if positive
            app.UpdateUISlider(dtSlider, -dt0,...
                "Min",-dt0,"Max",-Min_dt)
        else
            app.UpdateUISlider(dtSlider, dt0,...
                "Min",Min_dt,"Max",dt0)
        end
        updatePlot()
    end

%% Functions for UI elements
% none


 updatePlot()

%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

        % Update data
        dt = dtSlider.Value;
        p2 = r(t0 + dt)

        %% Update plots
        % Vector and point on curve
        set(Point_R_t0dt,'XData',p2(1),'YData',p2(2),'ZData',p2(3));

        % r' approx
        Sec_r_Vec = Diff_f_forward(r,t0,'Dt', dt);
        m = Sec_r_Vec(2)/Sec_r_Vec(1);
        x_for_sec = p1(1) + Sec_Line_Scale*[-1,1];
        y_for_sec = m*x_for_sec + p1(2);
        set(Sec_Line,'xdata',x_for_sec,'ydata',y_for_sec);

        % r(t+dt) -r(t)
        Chord_DAT = [p1, p2];
        set(hChord_Line,'xdata',Chord_DAT(1,:),'ydata',Chord_DAT(2,:));

        % update dx and dy lines
        set(hdx_Line,'xdata',Chord_DAT(1,:),'ydata',[1,1]*Chord_DAT(2,2));
        set(hdy_Line,'ydata',Chord_DAT(2,:));

        % % update legend text
        % leg.String{7} = sprintf('$\\Delta x = $ %.2f', p2(1)-p1(1));
        % leg.String{8} = sprintf('$\\Delta y = $ %.2f', p2(2)-p1(2));
    end
end
 