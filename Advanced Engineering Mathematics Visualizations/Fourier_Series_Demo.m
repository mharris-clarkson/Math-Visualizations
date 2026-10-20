function Fourier_Series_Demo()
%% Plots a function along with fourier sum approximations of it 
%
%% Author Info
%
% Ported/cleaned up by Claude from an original visualization written by
% Dr Matthew Harris, assistant professor at Clarkson University,
% for MA 330: Advanced Engineering Mathematics.

close all

%% User parameters for math objects

f = @(t) -1*(t<0)+ 1*(t>=0);
t = linspace(-pi,pi,10000);
Max_N = 100; % maximum number of fourier modes


%% ==== Below this we build the UI, compute math, and wire up controls ====
run('setup.m')
app = uiFigure("Fourier Series Demo", 1);


%% Precompute fourier coefficients

% Find needed period from user function
T = (t(end)-t(1));
w0 = 2*pi/T;

% Fourier coefficients - FFT would be faster but this is more insightful
% for students
a0 = (2/T) * trapz(t, f(t));

a = zeros(1, Max_N);
b = zeros(1, Max_N);

for n = 1:Max_N
    a(n) = (2/T) * trapz(t, f(t).*cos(n*w0*t));
    b(n) = (2/T) * trapz(t, f(t).*sin(n*w0*t));
end

    function f_fourier = Fourier_f(n)
          f_fourier = a0+0*t;
          for k = 1:n
              f_fourier = f_fourier + a(k)*cos(k*w0*t) + b(k)*sin(k*w0*t);
          end
    end

plot(app.ax(1),t,f(t),'b')
hold(app.ax(1), "on");
f_approx = plot(app.ax(1),t,Fourier_f(1),'r');
legend('f(t)', 'Fourier approximation (finite sum)','Location','Best')


Pretty_Plot(app.ax)
set(app.ax(1), 'FontSize', 24)


%% Build UI
numGUI = 1;
NSlider = app.addControl('slider', 'N = ', 1, numGUI, @changeN,...
                'Number_format','%d','default', 1,'Min', 1, 'Max',Max_N,...
                'colOrRow','Row');

%% Callbacks
    function changeN(~,~)
        N = round(NSlider.Value);
        set(f_approx,'ydata',Fourier_f(N))
    end




end