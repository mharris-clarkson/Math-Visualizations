% A function that takes in:
% - Function handles x, y, z for the curve r(t) = <x(t), y(t), z(t)> and
% - time limits tlims = [t_start, t_end]
% and returns an approximate arc length
%
%   L = integral from t_start to t_end of |r'(t)| dt
%
% using the trapezoid rule on N samples of the speed.
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function len = arc_length(x, y, z, tlims)
N = 2001;
t = linspace(tlims(1), tlims(2), N);
speed = sqrt(Diff_f(x,t).^2 + Diff_f(y,t).^2 + Diff_f(z,t).^2);
len = trapz(t, speed);
end
