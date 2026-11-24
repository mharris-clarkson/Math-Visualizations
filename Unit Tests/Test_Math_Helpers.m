classdef Test_Math_Helpers < matlab.unittest.TestCase
    %% Numeric checks for the functions in Helper/Math Computations
    % Test_All_Visualizations only checks that scripts start and that their
    % controls do not error. This class checks that the helper math is
    % right, by comparing against answers known in closed form. It runs in
    % a second or two and opens no figures.
    %
    %% Syntax
    %
    % results = runtests('Test_Math_Helpers');
    % table(results)
    %
    %% Author Info
    %
    % Written by Claude for Dr Matthew Harris, assistant professor at
    % Clarkson University, for MA 231: Calculus 3, following the style of his
    % Math-Visualizations scripts.
    %
    methods (TestClassSetup)
        function addHelpers(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            oldPath = addpath(genpath(fullfile(root, 'Helper')));
            testCase.addTeardown(@() path(oldPath));
        end
    end

    methods (Test)
        %% One-variable derivatives
        function firstDerivative(testCase)
            t = linspace(-2, 2, 11);
            testCase.verifyEqual(Diff_f(@sin, t), cos(t), 'AbsTol', 1e-8);
        end

        function secondDerivative(testCase)
            t = linspace(-2, 2, 11);
            testCase.verifyEqual(Diff2_f(@sin, t), -sin(t), 'AbsTol', 1e-5);
        end

        function forwardDerivative(testCase)
            t = 0.7;
            testCase.verifyEqual(Diff_f_forward(@exp, t), exp(t), 'AbsTol', 1e-6);
        end

        function unitTangentIsUnitPerSample(testCase)
            % Helix sampled at a row of times: 3 x n, one column per sample
            r = @(t) [cos(t); sin(t); 2*t];
            t = linspace(0, 2*pi, 7);
            T = Diff_f_unit(r, t);
            testCase.verifyEqual(vecnorm(T, 2, 1), ones(1, numel(t)), 'AbsTol', 1e-8);
            % Exactly 3 samples given as a column (3 x 3 result, rows = samples)
            rc = @(t) [cos(t), sin(t), 2*t];
            tc = [0; 1; 2];
            Tc = Diff_f_unit(rc, tc);
            testCase.verifyEqual(vecnorm(Tc, 2, 2), ones(3, 1), 'AbsTol', 1e-8);
        end

        function forwardUnitTangentPerSample(testCase)
            r = @(t) [cos(t); sin(t); 2*t];
            t = linspace(0, 2*pi, 7);
            T = Diff_f_forward(r, t, 'unit', true);
            testCase.verifyEqual(vecnorm(T, 2, 1), ones(1, numel(t)), 'AbsTol', 1e-6);
        end

        %% Partial derivatives
        function partialsOfTwoVariables(testCase)
            f = @(x,y) x.^3.*y + sin(y);
            [x, y] = meshgrid(linspace(-1, 1, 5));
            testCase.verifyEqual(Diffx_f(f, x, y),  3*x.^2.*y,        'AbsTol', 1e-7);
            testCase.verifyEqual(Diffy_f(f, x, y),  x.^3 + cos(y),    'AbsTol', 1e-7);
            testCase.verifyEqual(Diffxx_f(f, x, y), 6*x.*y,           'AbsTol', 1e-5);
            testCase.verifyEqual(Diffyy_f(f, x, y), -sin(y),          'AbsTol', 1e-5);
            testCase.verifyEqual(Diffxy_f(f, x, y), 3*x.^2,           'AbsTol', 1e-5);
        end

        function partialsOfThreeVariables(testCase)
            f = @(x,y,z) x.*y.*z.^2;
            x = 0.3; y = -0.4; z = 1.1;
            testCase.verifyEqual(Diffx_f(f, x, y, z),  y*z^2,   'AbsTol', 1e-7);
            testCase.verifyEqual(Diffz_f(f, x, y, z),  2*x*y*z, 'AbsTol', 1e-7);
            testCase.verifyEqual(Diffzz_f(f, x, y, z), 2*x*y,   'AbsTol', 1e-5);
        end

        function gradientBothForms(testCase)
            f = @(x,y) x.^2 + 3*y;
            testCase.verifyEqual(Grad_f(f, [1; 2]), [2; 3], 'AbsTol', 1e-7);
            [X, Y] = meshgrid(-1:1);
            [fx, fy] = Grad_f(f, X, Y);
            testCase.verifyEqual(fx, 2*X, 'AbsTol', 1e-7);
            testCase.verifyEqual(fy, 3*ones(size(Y)), 'AbsTol', 1e-7);
        end

        function curlOfRotation(testCase)
            % F = <-y, x, 0> has curl <0, 0, 2> everywhere
            [cx, cy, cz] = curl_f(@(x,y,z) -y, @(x,y,z) x, @(x,y,z) 0*x, 0.5, -1, 2);
            testCase.verifyEqual([cx cy cz], [0 0 2], 'AbsTol', 1e-7);
        end

        %% Arc length, limits, extrema
        function arcLengthOfHelix(testCase)
            % r(t) = <cos t, sin t, t>, 0 <= t <= 2 pi has length 2 pi sqrt(2)
            L = arc_length(@cos, @sin, @(t) t, [0, 2*pi]);
            testCase.verifyEqual(L, 2*pi*sqrt(2), 'AbsTol', 1e-6);
        end

        function limitAlongPath(testCase)
            t  = linspace(-1, 1, 401);           % includes t = 0, which is skipped
            zp = 5 + t.^2;
            testCase.verifyEqual(Limit_Along_Path(zp, t), 5, 'AbsTol', 1e-3);
        end

        function localExtrema(testCase)
            [X, Y] = meshgrid(linspace(-3, 3, 301));
            Z = exp(-(X - 1).^2 - Y.^2);         % one interior max at (1, 0)
            [isMax, isMin] = Local_Extrema_2D(Z);
            testCase.verifyEqual(nnz(isMax), 1);
            testCase.verifyEqual(nnz(isMin), 0);
            testCase.verifyEqual([X(isMax), Y(isMax)], [1, 0], 'AbsTol', 1e-9);
        end

        %% Regions bounded by polygons
        function insidePolygonGridMatchesInpolygon(testCase)
            % Same answer as inpolygon on meshgrids: random star-shaped and
            % self-crossing polygons, and grids through vertices and edges
            rng(1);
            for k = 1:60
                nv = randi([3 40]);
                if k <= 30
                    th = sort(rand(1, nv))*2*pi;  r = 0.3 + rand(1, nv);
                    xv = r.*cos(th);  yv = r.*sin(th);
                else
                    xv = round(2*randn(1, nv))/2;  yv = round(2*randn(1, nv))/2;
                end
                [X, Y] = meshgrid(-3:0.25:3, -3:0.5:3);
                testCase.verifyEqual(Inside_Polygon_Grid(X, Y, xv, yv), inpolygon(X, Y, xv, yv), ...
                    sprintf('polygon %d', k));
            end
        end

        function insidePolygonGridOtherInputs(testCase)
            % Points that are not a meshgrid fall back to inpolygon
            xv = [0 1 1 0];  yv = [0 0 1 1];
            x = [0.5 2 1 -0.1];  y = [0.5 0.5 0.5 0.2];
            testCase.verifyEqual(Inside_Polygon_Grid(x, y, xv, yv), inpolygon(x, y, xv, yv));
        end

        function polygonIntegralKnownValues(testCase)
            % Unit square: area 1, integral of x*y is 1/4
            sq = {[0 1 1 0], [0 0 1 1]};
            testCase.verifyEqual(Polygon_Integral(@(x,y) 1 + 0*x, sq{:}), 1, 'AbsTol', 1e-10);
            testCase.verifyEqual(Polygon_Integral(@(x,y) x.*y, sq{:}), 1/4, 'AbsTol', 1e-10);
            % Non-convex L shape (area 3); integral of x is 2.5 (closed polygon given)
            Lx = [0 2 2 1 1 0 0];  Ly = [0 0 1 1 2 2 0];
            testCase.verifyEqual(Polygon_Integral(@(x,y) 1 + 0*x, Lx, Ly), 3, 'AbsTol', 1e-10);
            testCase.verifyEqual(Polygon_Integral(@(x,y) x, Lx, Ly), 2.5, 'AbsTol', 1e-10);
        end

        function polygonIntegralMatchesGreen(testCase)
            % Polygon approximating a circle: area against polyarea, and the
            % integral of x^2 against Green's theorem (1/3) oint x^3 dy,
            % which is exact for straight edges
            th = linspace(0, 2*pi, 400);  xv = cos(th) - 1;  yv = sin(th);
            testCase.verifyEqual(Polygon_Integral(@(x,y) 1 + 0*x, xv, yv), polyarea(xv, yv), 'AbsTol', 1e-9);
            x1 = xv(1:end-1);  x2 = xv(2:end);  dy = diff(yv);
            green = sum(dy/12 .* (x1.^3 + x1.^2.*x2 + x1.*x2.^2 + x2.^3));
            testCase.verifyEqual(Polygon_Integral(@(x,y) x.^2, xv, yv), green, 'AbsTol', 1e-9);
        end

        %% Mesh and labels
        function prismMeshSizes(testCase)
            [V, bottomF, topF, sideF] = buildPrismMesh([0 1], [0 0], [2 3], 1, 1);
            testCase.verifySize(V, [16 3]);
            testCase.verifySize(bottomF, [2 4]);
            testCase.verifySize(topF, [2 4]);
            testCase.verifySize(sideF, [8 4]);
            testCase.verifyEqual(max(V(:,3)), 3);
        end

        function piLabels(testCase)
            testCase.verifyEqual(Pi_Label(0),        '$0$');
            testCase.verifyEqual(Pi_Label(pi/4),     '$\frac{\pi}{4}$');
            testCase.verifyEqual(Pi_Label(-3*pi/2),  '$-\frac{3\pi}{2}$');
            testCase.verifyEqual(Pi_Label(2*pi),     '$2\pi$');
            testCase.verifyEqual(Pi_Label(17*pi/12, 'Style', "inline"), '$17\pi/12$');
        end
    end
end
