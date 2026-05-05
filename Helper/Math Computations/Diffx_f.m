% A function that takes in:
% - A function handle f(x,y) or f(x,y,z) and
% - A scalar or vector of point(s) (x,y) or (x,y,z)
% and returns an approximate f_x at the point(s) (x,y) or (x,y,z)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fx = Diffx_f(f,x,y,z)
h = 1e-10;
if nargin < 4
    fx = (f(x+h,y) - f(x-h,y))/(2*h);
else
    fx = (f(x+h,y,z) - f(x-h,y,z))/(2*h);
end
end