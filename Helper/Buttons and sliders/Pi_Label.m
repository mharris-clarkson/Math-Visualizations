function str = Pi_Label(val, options)
%% Write a number as a LaTeX multiple of pi, e.g. 2.3562 -> '$\frac{3\pi}{4}$'
% Used by uiFigure sliders with 'Number_format','pi' and by Pi_Ticks. A
% value that is not a simple fraction of pi (denominator <= MaxDen) is
% written as a decimal multiple, e.g. '$0.37\pi$'.
%
%% Syntax
%
% str = Pi_Label(val)
% str = Pi_Label(val, 'MaxDen', 24, 'Dollars', false)
% str = Pi_Label(val, 'Style', "inline")   % '$17\pi/12$' on one line (no tall fraction)
%
% Inputs:
%
% val       - a real number (radians).
% 'MaxDen'  - largest denominator tried (default 12).
% 'Dollars' - wrap the result in $...$ (default true).
% 'Style'   - "frac" (default, stacked fraction) or "inline" (17\pi/12).
%
% Outputs:
%
% str      - a char array of LaTeX.
%
%% Author Info
%
% Written by Claude for Dr Matthew Harris, assistant professor at
% Clarkson University, for MA 231: Calculus 3, following the style of his
% Math-Visualizations scripts.

arguments
    val              (1,1) double
    options.MaxDen   (1,1) double = 12
    options.Dollars  (1,1) logical = true
    options.Style    (1,1) string  = "frac"   % "frac" or "inline"
end

tol = 1e-9 * max(1, abs(val));
str = '';
if abs(val) < tol
    str = '0';
else
    for d = 1:options.MaxDen
        n = round(val / pi * d);
        if n ~= 0 && abs(val - n*pi/d) < tol && gcd(abs(n), d) == 1
            sgn = '';
            if n < 0, sgn = '-'; end
            n = abs(n);
            if d == 1
                if n == 1, str = [sgn '\pi'];
                else,      str = sprintf('%s%d\\pi', sgn, n);
                end
            else
                if options.Style == "inline"          % one line: 17\pi/12
                    if n == 1, str = sprintf('%s\\pi/%d', sgn, d);
                    else,      str = sprintf('%s%d\\pi/%d', sgn, n, d);
                    end
                elseif n == 1, str = sprintf('%s\\frac{\\pi}{%d}', sgn, d);
                else,          str = sprintf('%s\\frac{%d\\pi}{%d}', sgn, n, d);
                end
            end
            break
        end
    end
    if isempty(str)
        str = sprintf('%.2f\\pi', val/pi);
    end
end

if options.Dollars
    str = ['$' str '$'];
end
end