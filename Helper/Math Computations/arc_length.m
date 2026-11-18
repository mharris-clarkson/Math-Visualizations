% A function that takes in:
% - Function handles x, y, z for the curve r(t) = <x(t), y(t), z(t)> and
% - time limits tlims = [t_start, t_end]
% and returns an approximate arc length
%
%   L = integral from t_start to t_end of |r'(t)| dt
%
% The speed |r'(t)| is sampled at N points and integrated with the
% trapezoid rule. (A plain sum(speed)*dt over all N samples counts one
% extra interval and overestimates the length by a factor of N/(N-1).)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
%
function len = arc_length(x, y, z, tlims)
N = 2001;                                  % number of sample points
t = linspace(tlims(1), tlims(2), N);
dX = Diff_f(x,t);
dY = Diff_f(y,t);
dZ = Diff_f(z,t);
speed = sqrt(dX.^2 + dY.^2 + dZ.^2);       % |r'(t)| at every sample
len = trapz(t, speed);
end
