function S12_6_quadric_surfaces()
%% This function plots %   A x^2 + B y^2 + C z^2 + D xy + I z + J = 0
% with sliders for all coefficents
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
close all % Close all Windows

%% User parameters for math objects. Adjust these to modify all math objects
%  below.
% xy plot ranges
xrange = [-10,10];
yrange = xrange;
zrange = 50*[-1,1];
Resolution = 25;

% Set default values for coefficients
A = 2; B = -2; C = 0; D = 0; I = 1; J = 0;
% Slider range
SliderMin = -2;
SliderMax = 2;
%% ==== Below this we build the UI, compute the needed math functions for future updates ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure("Quadratic Surfaces: $A x^2 + B y^2 + C z^2 + D xy + I z + J = 0$ ",1); % 3 is an optional argument to allow for more subplots

%% Optional math functions for plot computations
    function [X, Y, Z,title_val] = quadric_surface_generator(Coef, xrange, yrange, N)
        % Generates X,Y,Z satisfying: A x^2 + B y^2 + C z^2 + D xy + I z + J = 0
        %
        % For two-sheet surfaces (C~=0), uses proper parametric forms.
        % For one-sheet surfaces (C==0), solves z = f(x,y) on a fixed grid.
        %
        % INPUT:
        %   Coef   = [A B C D I J]
        %   xrange = [xmin xmax]  — used for the linear-z and degenerate cases
        %   yrange = [ymin ymax]
        %   N      = grid resolution (default: 25)

        A = Coef(1); B = Coef(2); C = Coef(3);
        D = Coef(4); I = Coef(5); J = Coef(6);
        title_val = '';

        if abs(C) > 1e-10
            % ============================================================
            % Quadratic in z — use parametric forms
            % ============================================================
            %
            % Shift z to eliminate the linear I*z term by completing the square:
            %   C z^2 + I z + R = 0
            %   C(z + I/2C)^2 = I^2/4C - R
            %   Let w = z + I/(2C), then C w^2 + R - I^2/(4C) = 0
            %   => A x^2 + B y^2 + D xy + C w^2 = I^2/(4C) - J  := K
            %
            % Ignore D for parametrization (handled by rotation below)
            % and treat the equation as: A x^2 + B y^2 + C w^2 = K

            K      = I^2/(4*C) - J;   % right-hand side after completing square
            z_shift = -I/(2*C);       % w = z - z_shift, so z = w + z_shift

            % Signs of A, B, C relative to K determine surface type
            % Normalize: divide through by K so equation is A'x^2+B'y^2+C'w^2=1
            % If K=0 it's a cone — treat as degenerate
            if abs(K) < 1e-10
                % CONE: x^2/a^2 + y^2/b^2 = w^2/c^2
                title_val = '. Type: Cone';
                % Parametrize as rays from apex: r in [0, rmax], v in [-pi, pi]
                % x = a*r*cos(v),  y = b*r*cos(v),  w = +/-c*r  (two sheets)
                rmax = max(abs([xrange, yrange]));
                [r, v] = meshgrid(linspace(0, rmax, N), linspace(-pi, pi, N));
                Xp =  A * r .* cos(v);
                Yp =  B * r .* sin(v);
                Zp  =  C * r;
                % Stack +sheet and -sheet with NaN separator
                X = [Xp;         NaN(1,N); Xp        ];
                Y = [Yp;         NaN(1,N); Yp        ];
                Z  = [Zp;          NaN(1,N); -Zp        ];
                return
            end

            Ap = A/K;  Bp = B/K;  Cp = C/K;
            sA = sign(Ap);  sB = sign(Bp);  sC = sign(Cp);

            % Semi-axes (all positive)
            a = 1/sqrt(abs(Ap) + 1e-12);
            b = 1/sqrt(abs(Bp) + 1e-12);
            c = 1/sqrt(abs(Cp) + 1e-12);

            nPos = (sA>0) + (sB>0) + (sC>0);
            nNeg = (sA<0) + (sB<0) + (sC<0);

            if nPos == 3 || nNeg == 3
                % ---------------------------------------------------------
                % ELLIPSOID:  x^2/a^2 + y^2/b^2 + w^2/c^2 = 1
                title_val = '. Type: Ellipsoid';
                % Parametrize with u in [-pi/2, pi/2], v in [-pi, pi]
                % ---------------------------------------------------------
                [u, v] = meshgrid(linspace(-pi/2, pi/2, N), ...
                    linspace(-pi,    pi,   N));
                Xp = a * cos(u) .* cos(v);
                Yp = b * cos(u) .* sin(v);
                Zp  = c * sin(u);
            elseif (nPos==2 && nNeg==1) || (nPos==1 && nNeg==2)
                % ---------------------------------------------------------
                % Determine which axis is the "odd one out"
                % For hyperboloid of 1 sheet: 2 pos 1 neg  =>  odd axis is negative
                % For hyperboloid of 2 sheets: 1 pos 2 neg =>  odd axis is positive
                % We always put the "special" axis as w (z after shift)
                % ---------------------------------------------------------

                if nPos==2 && nNeg==1
                    % HYPERBOLOID OF ONE SHEET: x^2/a^2 + y^2/b^2 - w^2/c^2 = 1
                    % (assuming Cp < 0; if not, permute — see below)
                    title_val = '. Type: Hyperboloid 1 sheet';
                    if sC < 0
                        % Standard: cosh on xy, sinh on w
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Xp = a * cosh(u) .* cos(v);
                        Yp = b * cosh(u) .* sin(v);
                        Zp  = c * sinh(u);
                    elseif sA < 0
                        % Odd axis is x: -x^2/a^2 + y^2/b^2 + w^2/c^2 = 1
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Yp = b * cosh(u) .* cos(v);
                        Zp  = c * cosh(u) .* sin(v);
                        Xp = a * sinh(u);
                    else
                        % Odd axis is y: x^2/a^2 - y^2/b^2 + w^2/c^2 = 1
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Xp = a * cosh(u) .* cos(v);
                        Zp  = c * cosh(u) .* sin(v);
                        Yp = b * sinh(u);
                    end
                else
                    % HYPERBOLOID OF TWO SHEETS
                    title_val = '. Type: Hyperboloid 2 sheets';
                    if sC > 0
                        % w^2/c^2 - x^2/a^2 - y^2/b^2 = 1 => two w-sheets
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Xp = a * sinh(u) .* cos(v);
                        Yp = b * sinh(u) .* sin(v);
                        Zp  = c * cosh(u);
                        % Stack both sheets (w and -w)
                        Xp = [Xp;          NaN(1,N); Xp          ];
                        Yp = [Yp;          NaN(1,N); Yp          ];
                        Zp  = [Zp;           NaN(1,N); -Zp           ];
                    elseif sA > 0
                        % x^2/a^2 - y^2/b^2 - w^2/c^2 = 1 => two x-sheets
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Yp = b * sinh(u) .* cos(v);
                        Zp  = c * sinh(u) .* sin(v);
                        Xp = a * cosh(u);
                        Xp = [Xp;          NaN(1,N); -Xp         ];
                        Yp = [Yp;          NaN(1,N); Yp          ];
                        Zp  = [Zp;           NaN(1,N); Zp           ];
                    else
                        % y^2/b^2 - x^2/a^2 - w^2/c^2 = 1 => two y-sheets
                        [u, v] = meshgrid(linspace(-2, 2, N), ...
                            linspace(-pi, pi, N));
                        Xp = a * sinh(u) .* cos(v);
                        Zp  = c * sinh(u) .* sin(v);
                        Yp = b * cosh(u);
                        Xp = [Xp;          NaN(1,N); Xp          ];
                        Zp  = [Zp;           NaN(1,N); Zp           ];
                        Yp = [Yp;          NaN(1,N); -Yp         ];
                    end
                end
            else
                % Degenerate / planar — fall through to linear solver
                [X, Y] = meshgrid(linspace(xrange(1),xrange(2),N), ...
                    linspace(yrange(1),yrange(2),N));
                R = A*X.^2 + B*Y.^2 + D*X.*Y + J;
                Z = -R ./ (I + 1e-12);
                return
            end

            % Apply D rotation in xy (rotate Xp, Yp by theta)
            if abs(D) > 1e-10
                theta = 0.5 * atan2(D, A - B);
                Xr = Xp*cos(theta) - Yp*sin(theta);
                Yr = Xp*sin(theta) + Yp*cos(theta);
                Xp = Xr;  Yp = Yr;
            end

            X = Xp;
            Y = Yp;
            Z = Zp + z_shift;   % undo the z-shift from completing the square

        elseif abs(I) > 1e-10
            % ============================================================
            % Linear in z — one sheet, solve z = f(x,y) on fixed grid
            % ============================================================
             nPos = (A>0) + (B>0);
             nNeg = (A<0) + (B<0);
             nZero = (A==0) + (B==0);
            if (nPos == 2) || (nNeg == 2) || (nZero == 1 && ((nPos + nNeg) == 1))
                title_val = '. Type: Parabolic sheet';
            elseif nPos == 1 && nNeg == 1
                title_val = '. Type: Hyperbolic sheet';
            else 
                title_val = '. Type: Plane';
            end
            [X, Y] = meshgrid(linspace(xrange(1),xrange(2),N), ...
                linspace(yrange(1),yrange(2),N));
            R = A*X.^2 + B*Y.^2 + D*X.*Y + J;
            Z = -R ./ I;

        else
            % ============================================================
            % No z dependence — degenerate vertical surface
            % ============================================================
            warning('No z dependence: returning z = 0 plane.');
            [X, Y] = meshgrid(linspace(xrange(1),xrange(2),N), ...
                linspace(yrange(1),yrange(2),N));
            Z = zeros(size(X));
        end
    end

%% Make the initial plots

% Generate the initial quadric surface
coefficients = [A, B, C, D, I, J];
[X, Y, Z] = quadric_surface_generator(coefficients, xrange,yrange, Resolution);
Surface = surf(app.ax,X,Y,Z);
view(30,50)
Pretty_Color_Centered(app.ax,Z,'colorbar','off');
xlim(app.ax,xrange)
ylim(app.ax,yrange)
% zlim(app.ax,zrange)

%% Precompute math for updates
% Skip

%% Build UI
NumControls = 6;
% Create sliders for coefficients A, B, C, D, I, J
sliderA = app.addControl('slider', '$A = $', 1, NumControls, @update,...
    'Default',A,'Min',SliderMin,'Max',SliderMax);
sliderB = app.addControl('slider', '$B = $', 2, NumControls, @update,...
    'Default',B,'Min',SliderMin,'Max',SliderMax);

% Button to switch c
buttonC = app.addControl('button', '$C = 0$', 3, NumControls, @update_C, ...
    'Default',0);
buttonI.UserData.Value = 0;
    function update_C(~,~)
        % Switch between states
        if buttonC.UserData.Value == 0
            buttonC.UserData.Value = 1;
            buttonC.String = "$C = 1$";
        elseif buttonC.UserData.Value == 1
            buttonC.UserData.Value = -1;
            buttonC.String = "$C = -1$";
        else
            buttonC.UserData.Value = 0;
            buttonC.String = "$C = 0$";
        end
        update();
    end

sliderD = app.addControl('slider', '$D = $', 4, NumControls, @update,...
    'Default',D,'Min',SliderMin,'Max',SliderMax);

% Button to flip I
buttonI = app.addControl('button', '$I = 1$', 5, NumControls, @update_I, ...
    'Default',1);
buttonI.UserData.Value = 1;
    function update_I(~,~)
        if buttonI.Value
            buttonI.UserData.Value = -1;
            buttonI.String = "$I =-1$";
        else
            buttonI.UserData.Value = 1;
            buttonI.String = "$I = 1$";
        end
        update();
    end

sliderJ = app.addControl('slider', '$J = $', 6, NumControls, @update,...
    'Default',J,'Min',zrange(1)/2,'Max',zrange(2)/2); % force z lim to be nice

% Launch update function
update();

%% Functions for UI elements

%% Main Draw update function.
    function update(~,~)
        % Recompute data and plot
        coefficients = [sliderA.Value, sliderB.Value, buttonC.UserData.Value,...
            sliderD.Value, buttonI.UserData.Value, sliderJ.Value];
        [X, Y, Z, title_val] = quadric_surface_generator(coefficients,xrange, yrange, Resolution);
        set(Surface, 'XData',X, 'YData',Y, 'ZData',Z)
        title(app.ax,[app.fig.Name title_val],'Interpreter','latex')
        
        if ~ min(Z(:)) == max(Z(:))
        Pretty_Color_Centered(app.ax,Z,'colorbar','off');
        end
    end
end
