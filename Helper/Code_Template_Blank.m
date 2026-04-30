function Code_Template_Blank()
%% Script showing the idea behind the definition of the calc 1 derivative
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.
close all;

%% User parameters for math objects. 
% Adjust these to modify selected math objects below.

%% ==== Below this we build the UI, compute the needed math functions for future updates and update ================
%% Load libraries
run('setup.m')

%% Build an applet that holds the figure, plot and all UI elements
app = uiFigure('Plot for Something',1); % Plots_to_test is an optional argument to allow for more subplots
title(app.ax,app.fig.Name,'Interpreter','latex')

%% Optional math functions for plot computations
% None

%% ============== Make the initial plots =================================

%% Precompute math for updates
% Light weight so skip

%% Build UI
NumControls = 2; % maximum number of controls

%% Functions for UI elements
% none



%% Main Draw update function. All initial plot functions are updated below.
    function updatePlot(~,~)

    end
end
 