% A function that takes in:
% - A function handle f(x,y,z) and
% - A scalar or vector of point(s) x, y, z
% and returns an approximate f_z at the point(s)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fz = Diffz_f(f,x,y,z)
h = 1e-10;
fz = (f(x,y,z+h) - f(x,y,z-h))/(2*h);
end