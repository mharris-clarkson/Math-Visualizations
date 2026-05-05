% A function that takes in:
% - A function handle f(x,y) or f(x,y,z) and
% - A scalar or vector of point(s) (x,y) or (x,y,z)
% and returns an approximate f_yy at the point(s) (x,y) or (x,y,z)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%

function fyy = Diffyy_f(f,x,y,z)
h = 1e-4;
if nargin < 4
    fyy = (f(x,y+h) - 2*f(x,y)+ f(x,y-h))/(h^2);
else
    fyy = (f(x,y+h,z) - 2*f(x,y,z)+ f(x,y-h,z))/(h^2);
end
end