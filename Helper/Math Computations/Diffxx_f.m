% A function that takes in:
% - A function handle f(x,y) or f(x,y,z) and
% - A scalar or vector of point(s) (x,y) or (x,y,z)
% and returns an approximate f_xx at the point(s) (x,y) or (x,y,z)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fxx = Diffxx_f(f,x,y,z)
h = 1e-4;
if nargin < 4
    fxx = (f(x+h,y) - 2*f(x,y)+ f(x-h,y))/(h^2);
else
    fxx = (f(x+h,y,z) - 2*f(x,y,z)+ f(x-h,y,z))/(h^2);
end
end