% A function that takes in:
% - A function handle f(x,y) or f(x,y,z) and
% - A scalar or vector of point(s) (x,y) or (x,y,z)
% and returns an approximate f_xy at the point(s) (x,y) or (x,y,z)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%

function fxy = Diffxy_f(f,x,y,z)
h = 1e-4;
if nargin < 4
    fxy = (f(x+h,y+h) - f(x+h,y-h) - f(x-h,y+h)+ f(x-h,y-h))/(4*h^2);
else
    fxy = (f(x+h,y+h,z) - f(x+h,y-h,z) - f(x-h,y+h,z)+ f(x-h,y-h,z))/(4*h^2);
end
end