function Eigenvalue_Eigenvector_Visualization()
%% Eigenvalue / Eigenvector Visualization
% Visualizes the action of a matrix A on points of the unit circle and
% shows eigenvectors as the directions A only stretches/flips.
%
% UI controls:
%   1. Apply A                - animates the unit circle mapping to A*(circle)
%   2. Show/Hide Eigenvectors - toggle: odd clicks animate them in, even
%                               clicks remove them instantly
%   3. Show Mapping Lines      - toggles lines from each point to its image
%   4. Swap Matrix             - cycles through a small set of demo matrices
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 231: Calculus 3.

close all

%% User parameters for math objects
% Matrices for the "Swap Matrix" button (add entries with a matching label)
S1 = [1, 1; 0, sqrt(2)]/sqrt(2);
A1 = S1 \ diag([2, 3]) * S1;             % non-orthogonal basis, eig = 2,3

S2 = [1, 1; 1, -1]/sqrt(2);
A2 = S2 \ diag([2, 1]) * S2;             % orthogonal basis,     eig = 2,1


A3 = rand(2);
A3 = A3'*A3;                             % random symmetric (positive semidefinite)
while min(abs(eig(A3)))<0.2   % avoid near-zero eigenvalues
    A3 = rand(2);
    A3 = A3'*A3;
end


matrices    = {A1, A2, A3};
matrixNames = {'Shear basis ($\lambda = 2, 3$)', ...
'Orthogonal basis ($\lambda = 2, 1$)', ...
'Random symmetric matrix'};

N            = 100;   % number of points on the unit circle
nFramesApply = 60;   % frames for the "Apply A" animation
nFramesEigen = 50;   % frames for the eigenvector-stretch animation

%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure("Eigenvalue / Eigenvector Demo", 1);
axis(app.ax(1), 'equal')

%% Precompute math
theta = linspace(0, 2*pi, N);
Pts   = [cos(theta); sin(theta)];   % unit circle

matIdx = 1;
A      = matrices{matIdx};
colors = lines(2);

[APts, lambda, Vnorm] = computeFromMatrix(A, Pts);

Pretty_Plot(app.ax)
set(app.ax(1), 'FontSize', 24)

%% Static graphics
Transformed = plot(app.ax(1), Pts(1,:), Pts(2,:), '.r', 'MarkerSize', 30, ...
    'Visible', 'off', 'DisplayName', 'A x points');
plot(app.ax(1), Pts(1,:), Pts(2,:), '.b', 'MarkerSize', 30, 'DisplayName', 'Original points')

AxLineX = plot(app.ax(1), [0, 0], [0, 0], 'k-', 'LineWidth', 2);
AxLineY = plot(app.ax(1), [0, 0], [0, 0], 'k-', 'LineWidth', 2);

% Mapping lines as one NaN-separated line
MappingLines = plot(app.ax(1), NaN, NaN, 'k-', 'LineWidth', 1.2, 'Visible', 'off');
mappingLinesOn = false;

EigVec  = gobjects(1, 2);
EigRef  = gobjects(1, 2);
EigText = gobjects(1, 2);
for i = 1:2
    EigRef(i)  = plot(app.ax(1), [0, 0], [0, 0], '--', ...
        'Color', colors(i,:), 'LineWidth', 1.2, 'Visible', 'off');
    EigVec(i)  = quiver(app.ax(1), 0, 0, 0, 0, 0, ...
        'Color', colors(i,:), 'LineWidth', 2.5, 'MaxHeadSize', 0.35, 'Visible', 'off');
    EigText(i) = text(app.ax(1), 0, 0, '', 'Color', colors(i,:), ...
        'FontSize', 24, 'FontWeight', 'bold', 'Visible', 'off');
end
eigenvectorsOn = false;

applyAxesAndLabels()

%% Build UI
numGUI = 4;
app.addControl('button', 'Apply A', 1, numGUI, @applyA);
btnEig   = app.addControl('button', 'Show Eigenvectors', 2, numGUI, @toggleEigenvectors);
btnLines = app.addControl('button', 'Show Mapping Lines', 3, numGUI, @toggleMappingLines);
app.addControl('button', 'Swap Matrix', 4, numGUI, @swapMatrix);

%% Callbacks
function applyA(~, ~)
    set(Transformed, 'Visible', 'on')
    title(app.ax(1), 'Applying A to every point')
    for k = 1:nFramesApply
        s = smoothstep(k/nFramesApply);
        current = (1-s)*Pts + s*APts;
        set(Transformed, 'XData', current(1,:), 'YData', current(2,:))
        if mappingLinesOn
            setMappingLines(current(1,:), current(2,:))
        end
        drawnow
        pause(0.02)
    end
    title(app.ax(1), 'Original points and A x points')
end

function toggleEigenvectors(~, ~)
    eigenvectorsOn = ~eigenvectorsOn;
    if eigenvectorsOn
        % Show at unit length, then animate the stretch
        for i = 1:2
            set(EigVec(i), 'UData', Vnorm(1,i), 'VData', Vnorm(2,i))
            set(EigText(i), 'Position', 1.08*[Vnorm(1,i), Vnorm(2,i), 0])
        end
        set([EigVec, EigRef, EigText], 'Visible', 'on')
        title(app.ax(1), 'Eigenvectors: stretching by A')
        drawnow
        pause(0.5)
        for k = 1:nFramesEigen
            s = smoothstep(k/nFramesEigen);
            for i = 1:2
                len  = 1 + s*(abs(lambda(i)) - 1);
                vNew = sign(lambda(i))*len*Vnorm(:,i);
                set(EigVec(i), 'UData', vNew(1), 'VData', vNew(2))
                set(EigText(i), 'Position', 1.08*[vNew(1), vNew(2), 0])
            end
            drawnow
            pause(0.02)
        end
        title(app.ax(1), 'Eigenvectors and their stretches')
        btnEig.String = 'Hide Eigenvectors';
    else
        set([EigVec, EigRef, EigText], 'Visible', 'off')
        btnEig.String = 'Show Eigenvectors';
        title(app.ax(1), sprintf('Unit Circle -- %s', matrixNames{matIdx}))
    end
end

function toggleMappingLines(~, ~)
    mappingLinesOn = ~mappingLinesOn;
    if mappingLinesOn
        setMappingLines(get(Transformed, 'XData'), get(Transformed, 'YData'))
        btnLines.String = 'Hide Mapping Lines';
    else
        btnLines.String = 'Show Mapping Lines';
    end
    set(MappingLines, 'Visible', onoff(mappingLinesOn))
end

function swapMatrix(~, ~)
    matIdx = mod(matIdx, numel(matrices)) + 1;
    A      = matrices{matIdx};
    [APts, lambda, Vnorm] = computeFromMatrix(A, Pts);

    % Reset everything for the new matrix
    eigenvectorsOn = false;
    mappingLinesOn = false;
    set(Transformed, 'Visible', 'off', 'XData', Pts(1,:), 'YData', Pts(2,:))
    set(MappingLines, 'Visible', 'off')
    set([EigVec, EigRef, EigText], 'Visible', 'off')
    btnEig.String   = 'Show Eigenvectors';
    btnLines.String = 'Show Mapping Lines';

    applyAxesAndLabels()
end

%% Local helpers
% Segment j goes from Pts(:,j) to (curX(j), curY(j))
function setMappingLines(curX, curY)
    set(MappingLines, ...
        'XData', reshape([Pts(1,:); curX; NaN(1,N)], 1, []), ...
        'YData', reshape([Pts(2,:); curY; NaN(1,N)], 1, []))
end

function applyAxesAndLabels()
    maxRange = 1.25*max(1.2, max(abs(APts(:))));
    xlim(app.ax(1), [-maxRange, maxRange])
    ylim(app.ax(1), [-maxRange, maxRange])
    set(AxLineX, 'XData', [-maxRange, maxRange], 'YData', [0, 0])
    set(AxLineY, 'XData', [0, 0], 'YData', [-maxRange, maxRange])

    for i = 1:2
        set(EigRef(i), 'XData', [0, Vnorm(1,i)], 'YData', [0, Vnorm(2,i)])
        set(EigVec(i), 'UData', Vnorm(1,i), 'VData', Vnorm(2,i))
        set(EigText(i), 'Position', 1.08*[Vnorm(1,i), Vnorm(2,i), 0], ...
            'String', sprintf('$\\lambda = %.2f$', lambda(i)))
    end

    title(app.ax(1), sprintf('Unit Circle -- %s', matrixNames{matIdx}))
end

end

%% Stateless helpers
function [APts, lambda, Vnorm] = computeFromMatrix(A, Pts)
APts = A*Pts;
[V, D] = eig(A);
lambda = diag(D);
Vnorm  = V ./ vecnorm(V);
end

function s = smoothstep(t)
s = 3*t.^2 - 2*t.^3;
end