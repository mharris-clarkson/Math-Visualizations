% A function that takes in:
% - A function handle f(x,y) and
% - A point p = [x; y] (or separate x and y arrays)
% and returns the approximate gradient of f using Diffx_f and Diffy_f
%
%
%% Syntax
%
% g = Grad_f(f, [x0; y0])     % 2 x 1 column vector [f_x; f_y]
% [fx, fy] = Grad_f(f, X, Y)  % two arrays the same size as X and Y
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
function [out1, out2] = Grad_f(f, x, y)
if nargin < 3            % point given as p = [x; y]
    p = x;
    x = p(1);
    y = p(2);
end
fx = Diffx_f(f, x, y);
fy = Diffy_f(f, x, y);
if nargout <= 1
    out1 = [fx; fy];     % column vector for a single point
else
    out1 = fx;
    out2 = fy;
end
end
