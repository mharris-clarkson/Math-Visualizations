function S13_2_Calc_1_integral()
close all;

%% ================== User parameters =====================
f = @(x) (abs(x)<1) .* exp(-1./max(1-x.^2, eps));
xlims = [-1.2,1.2];

color1 = [0 0 0.6];
color2 = [0.6 0 0];

N_min  = 5;
N_max  = 100;

%% Load libraries
run('setup.m')

%% Build app
app = uiFigure('Visualization of the Definition for $\int_a^b f(x)dx$',1);
title(app.ax,app.fig.Name,'Interpreter','latex')
view(app.ax,0,90)
hold(app.ax,'on')

%% Initial function plot
x = linspace(xlims(1), xlims(2), 200);
f_DAT = f(x);

plot(app.ax, x, f_DAT, 'k','LineWidth',2)

ylim(app.ax,[min(f_DAT(:))*1.1, max(f_DAT(:))*1.1]);
xlim(app.ax,xlims);

Pretty_Plot(app.ax);

%% State variables
Method = 'Midpoint';

% Graphics holders
hRects = gobjects(0);
hDots  = gobjects(0);
hArea  = gobjects(0); 

ShowArea = false; 

%% ================= UI =====================
NumControls = 5;

% Slider
NSlider = app.addControl('slider', '$N = $', 1, NumControls, @updatePlot,...
    'default', N_min,'Min', N_min, 'Max',N_max,'Number_format','%d');

% Left button
app.addControl('button','Left Sum',2,NumControls,@(~,~) setMethod('Left'));

% Midpoint button
app.addControl('button','Midpoint Rule',3,NumControls,@(~,~) setMethod('Midpoint'));

% Right button
app.addControl('button','Right Sum',4,NumControls,@(~,~) setMethod('Right'));

app.addControl('button','Toggle Area Under Curve',5,NumControls,@toggleArea);

function toggleArea(~,~)
    ShowArea = ~ShowArea;
    updatePlot();
end

%% Helper to change method
function setMethod(m)
    Method = m;
    updatePlot();
end

%% Initial draw
updatePlot();

%% ================= MAIN UPDATE =====================
function updatePlot(~,~)

    % Delete old graphics
    if ~isempty(hRects), delete(hRects); end
    if ~isempty(hDots), delete(hDots); end
    hRects = gobjects(0);
    hDots  = gobjects(0);
    if ~isempty(hArea), delete(hArea); end    
    hArea = gobjects(0);     

    % Get N
    N = round(NSlider.Value);

    % Partition
    a = xlims(1); 
    b = xlims(2); 
    dx = (b - a)/N;

    xL   = a + (0:N-1)*dx;
    xR   = xL + dx;
    xMid = xL + dx/2;

    % Choose sample points
    switch Method
        case 'Left'
            xSample = xL;
        case 'Right'
            xSample = xR;
        otherwise
            xSample = xMid;
    end

    r = f(xSample);

    % Plot sample points
    hDots = plot(app.ax,xSample,r,...
        'ro','MarkerFaceColor','r','MarkerSize',6);

    % Update title
    title(app.ax, sprintf(['Visualization of the Definition for ' ...
        '$\\int_a^b f(x)\\,dx$: %s'], Method), ...
        'Interpreter','latex')

    % Draw rectangles
    for k = 1:N
        if mod(k,2)==1
            cCurr = color1;
        else
            cCurr = color2;
        end

        X = [xL(k) xR(k) xR(k) xL(k)];
        Y = [0 0 r(k) r(k)];

        hRects(end+1) = patch(app.ax,X,Y,cCurr,...
            'FaceAlpha',0.4,'EdgeColor','k','LineWidth',1);
    end

    % Area under curve 
if ShowArea
    xFill = linspace(xlims(1), xlims(2), 400);
    yFill = f(xFill);

    X = [xFill, fliplr(xFill)];
    Y = [yFill, zeros(size(yFill))];

    hArea = patch(app.ax, X, Y, [0.2 0.7 0.2], ...
        'FaceAlpha',0.2,'EdgeColor','none');
end
end

end