% A function that takes in:
% - A function handle f(x,y,z) and
% - A scalar or vector of point(s) x, y, z
% and returns an approximate f_zz at the point(s)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function fzz = Diffzz_f(f,x,y,z)
h = 1e-4;
fzz = (f(x,y,z+h) - 2*f(x,y,z)+ f(x,y,z-h))/(h^2);
end