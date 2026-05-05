% A function that takes in:
% - A function handle f(x,y) or f(x,y,z) and
% - A scalar or vector of point(s) (x,y) or (x,y,z)
% and returns an approximate f_y at the point(s) (x,y) or (x,y,z)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%

function fy = Diffy_f(f,x,y,z)
h = 1e-10;
if nargin < 4
    fy = (f(x,y+h) - f(x,y-h))/(2*h);
else
    fy = (f(x,y+h,z) - f(x,y-h,z))/(2*h);
end
end