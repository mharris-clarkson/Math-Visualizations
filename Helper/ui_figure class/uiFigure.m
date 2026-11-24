classdef uiFigure < handle
    %% Class for creating nice figure objects for dynamic plots.
    %  It returns a figure handle, axes handles and button/slider handles for
    %  modifying the data.
    %  app = uiFigure(name, numSubPlots) initalizes the object with some
    %  subplots (default is 1)
    %
    %  addControl adds a button or slider on a grid decided by uiGrid. Can
    %  do rows and cols with equal or min size spacing. The data of these
    %  items are modifiable if needed as noted in demo()
    %
    %  New in this version (all optional, old scripts run unchanged):
    %   - Every figure uses LaTeX for all text by default (Latex_Defaults).
    %   - Sliders: 'Number_format','pi' shows values as multiples of pi
    %     (stacked fraction, label font 75% so it fits) and snaps to pi/12
    %     steps; 'pi_inline' writes them on one line (17\pi/12) at full
    %     size; 'Step' snaps any slider to a step size;
    %     'LimitLabel' shows e.g. '$n \to \infty$' when the slider sits at
    %     its limit end ('LimitAt' = "max", "min" or "zero").
    %   - app.isAtLimit(slider) and app.getValue(slider) read a limit slider;
    %     getValue returns 'LimitValue' (e.g. a very large n) at the limit.
    %   - Buttons: 'Toggle', ["Show Plane","Hide Plane"] swaps the text on
    %     every click (and when btn.Value is set from code).
    %   - app.addPrevNext(...) builds a Previous/Next pair for galleries.
    %
    %% Author Info
    %
    % This function was written by Dr Matthew Harris an assistant professor at
    % Clarkson university for visually teaching MA 231: Calculus 3.
    % Copyright (c) 2026 Matthew Harris
    % Licensed under the MIT License.
    % See LICENSE file in the project root for full license information.
    %
    % November 2026: LaTeX defaults, pi/limit/step slider options, toggle
    % text, addPrevNext, isAtLimit/getValue added by Claude.
    % Later November 2026 (Claude): UpdateUISlider no longer trips
    % linkMinMax, getValue snaps code-set values to 'Step'.
    properties
        fig
        ax = gobjects(0)
        controls = gobjects(0)
        galleryIdx = 1        % current item for addPrevNext galleries
    end

    methods
        % ============================================
        % Initalize applet and apply Pretty_Plot for nice labels
        % ============================================
        function app = uiFigure(name, numSubPlots, RowOrCol, options)
            arguments
                name
                numSubPlots (1,1) double = 1
                RowOrCol    (1,1) string = "row"
                options.Latex (1,1) logical = true  % LaTeX for all text in this figure
            end

            % Initalize the figure
            app.fig = figure('Color','w',...
                'Name',name,...
                'WindowState','maximized');

            % LaTeX for every title/label/legend/tick made in this figure,
            % so scripts do not need 'Interpreter','latex' on every call.
            if options.Latex
                Latex_Defaults(app.fig);
            end

            % Create subplots
            for i = 1:numSubPlots
                if strcmpi(RowOrCol, "col")
                    app.ax(i) = subplot(numSubPlots, 1, i);
                else
                    app.ax(i) = subplot(1, numSubPlots, i);
                end
                hold(app.ax(i), 'on')
                Pretty_Plot(app.ax(i));
            end
        end

        % ============================================
        % OBJECT ADDER - Adds both buttons and sliders to the grid built
        % by uiGrid
        % ============================================
        function [h, label] = addControl(app,type,label,idx,Num_Obj,callback,options)
            arguments
                app
                type
                label
                idx
                Num_Obj
                callback
                % Grid control options
                options.minY         double = []
                options.maxY         double = []
                options.minX         double = []
                options.maxX         double = []
                options.width        double = []
                options.height       double = []
                options.gap          double = []
                options.autoCenter   logical =[]
                options.colOrRow     string = 'col'
                options.maxheight    double = []
                % Button/Slider shaired controls
                options.Visible      string  = []
                options.FontSize     double  = []
                % Button control options
                options.ColorChange logical  = []
                options.Toggle       string  = []   % ["text when off","text when on"]
                % Slider controls
                options.Default       double = []
                options.labelRatio    double = []
                options.Number_format string = []   % '%.2f', '%d', 'pi' or 'pi_inline'
                options.AddToEnd      char   = ''
                options.Min           double = []
                options.Max           double = []
                options.Step          double = []   % snap the value to this step
                options.LimitLabel    string = []   % e.g. '$n \to \infty$'
                options.LimitAt       string = []   % "max" (default), "min" or "zero"
                options.LimitValue    double = []   % value getValue returns at the limit
            end
            % Check for valid colOrRow values
            if ~(strcmpi(options.colOrRow,'row') || strcmpi(options.colOrRow,'col'))
                error('uiFigure - addControl: colOrRow should be ''row'' or ''col'' but was %s', options.colOrRow);
            end

            % Build gridOpts from only the fields that were explicitly set
            gridArgs = uiFigure.pickOptions(options, ...
                {'minY','maxY','minX','maxX','width','height','gap', ...
                 'autoCenter','colOrRow','maxheight'});

            %compute position
            pos = uiGrid(idx, Num_Obj, gridArgs{:});

            switch lower(string(type))
                case "button"
                    btnArgs = uiFigure.pickOptions(options, ...
                        {'Visible','ColorChange','colOrRow','FontSize','Toggle'});
                    h = CreateUIButton(app, label, pos, callback, btnArgs{:});
                case "slider"
                    sldArgs = uiFigure.pickOptions(options, ...
                        {'Visible','colOrRow','Min','Max','Default','FontSize', ...
                         'Number_format','AddToEnd','labelRatio','Step', ...
                         'LimitLabel','LimitAt','LimitValue'});
                    h = CreateUISlider(app, label, pos, callback, sldArgs{:});
                otherwise
                    error('uiFigure - addControl: type should be ''button'' or ''slider'' but was %s', type);
            end
            % Store in creation order. (Storing at idx overwrote controls
            % that shared an index, e.g. a row and a column both using 1.)
            app.controls(end+1) = h;
            label = h.UserData.label;   % the text object that shows the label
        end

        % ============================================
        % LATEX BUTTON
        % ============================================
        function Button = CreateUIButton(app, name, pos, CallbackFcn, options)
            arguments
                app
                name                 string
                pos                  double
                CallbackFcn          function_handle
                options.Visible      string  = "on"
                options.ColorChange  logical = false
                options.colOrRow     string  = 'col'
                options.FontSize     double  = 18
                options.Toggle       string  = string.empty
            end
            % Call helper function to resize axes to fit buttons/sliders if needed
            Subplot_Mover(app, pos, options.colOrRow);

            % With 'Toggle' the first entry is the starting text
            if numel(options.Toggle) == 2
                name = options.Toggle(1);
            end

            % Add button with dynamic fontsize based on the button pixel size
            % Only pass Toggle_strings when a toggle is used, so this also
            % works with an older uicontrol_Latex that lacks the option.
            toggleArgs = {};
            if numel(options.Toggle) == 2
                toggleArgs = {'Toggle_strings', options.Toggle};
            end
            Button = uicontrol_Latex(app.fig, ...
                'String',   name, ...
                'Position', pos, ...
                'FontSize', options.FontSize, ...
                'Callback', CallbackFcn,...
                'Visible', options.Visible,...
                'Color_change',options.ColorChange, ...
                toggleArgs{:});
        end

        % ============================================
        % LATEX SLIDER
        % ============================================
        function Slider = CreateUISlider(app, Name, pos, CallbackFcn, options)
            arguments
                app
                Name                 string
                pos                  double
                CallbackFcn          function_handle
                options.Default       double  = 0
                options.Min           double  = 0
                options.Max           double  = 1
                options.Visible       string  = "on"
                options.colOrRow      string  = 'col'
                options.labelRatio    double  = 0.4
                options.Number_format char    = '%.2f'
                options.AddToEnd      char    = ''
                options.FontSize      double  = []   % default 18 (13.5 for 'pi')
                options.Step          double  = []
                options.LimitLabel    string  = ""
                options.LimitAt       string  = "max"
                options.LimitValue    double  = []
            end

            % Angles in radians: label as multiples of pi and land on pi/12
            isPi = any(strcmpi(options.Number_format, {'pi', 'pi_inline'}));
            if isPi && isempty(options.Step)
                options.Step = pi/12;
            end

            % Stacked fractions are about twice as tall as normal text, so
            % 'pi' labels use a smaller font unless FontSize was given.
            if isempty(options.FontSize)
                if strcmpi(options.Number_format, 'pi')
                    options.FontSize = 18 * 0.75;
                else
                    options.FontSize = 18;
                end
            end

            % Keep the starting value inside the slider range
            options.Default = min(max(options.Default, options.Min), options.Max);

            % Grab Slider/Label pos to split for label/slider
            SliderPosition    = pos;
            SliderLabPosition = pos;

            % Adjust slider and label to share the space
            SliderPosition(4)    = SliderPosition(4) * options.labelRatio;
            SliderLabPosition(2) = SliderPosition(2) + SliderPosition(4) + 0.001; % num is padding
            SliderLabPosition(4) = pos(4) * (1 - options.labelRatio);

            %% Call helper function to resize axes to fit the slider if needed
            Subplot_Mover(app, pos, options.colOrRow);

            %% Make slider label
            % (axtoolbar(ax,{}) was removed: building a toolbar is one of
            %  the slowest steps of figure start-up and this axes is hidden.)
            ax_label = axes(app.fig, ...
                'Units',    'normalized', ...
                'Position', SliderLabPosition, ...
                'Tag',      'uiFigureControl', ... % marks it as a control, not a plot
                'HitTest',  'off', ...
                'Visible',  'off');

            % Disable all interactivity on ax_label
            disableDefaultInteractivity(ax_label);
            ax_label.Interactions = [];
            ax_label.Toolbar.Visible = 'off';

            Slider_label = text(ax_label, 0.5, 0.5, '', ... % hard coded center
                'Interpreter',         'latex', ...
                'HorizontalAlignment', 'center', ...
                'FontSize',            options.FontSize,...
                'VerticalAlignment',   'middle',...
                'HitTest',             'off', ...
                'Visible',  options.Visible,...
                'PickableParts',       'none');

            %% Make slider object
            sliderArgs = {};
            if ~isempty(options.Step) && options.Max > options.Min
                frac = options.Step / (options.Max - options.Min);
                sliderArgs = {'SliderStep', [min(frac,1), min(max(5*frac, 0.1), 1)]};
            end
            Slider = uicontrol(app.fig, ...
                'Style',    'slider', ...
                'Min',      options.Min, ...
                'Max',      options.Max, ...
                'Value',    options.Default, ...
                'Units',    'normalized', ...
                'Position', SliderPosition, ...
                'Visible',  options.Visible,...
                sliderArgs{:}, ...
                'Callback', @sliderMoved);

            % Store name, label and limit settings on the slider handle
            Slider.UserData.name       = Name;
            Slider.UserData.label      = Slider_label;
            Slider.UserData.ax_label   = ax_label;
            Slider.UserData.format     = options.Number_format;
            Slider.UserData.addToEnd   = options.AddToEnd;
            Slider.UserData.step       = options.Step;
            Slider.UserData.limitLabel = options.LimitLabel;
            Slider.UserData.limitAt    = lower(options.LimitAt);
            Slider.UserData.limitValue = options.LimitValue;
            Slider.UserData.callback   = CallbackFcn;

            %% Listener that auto-updates label whenever Value changes
            addlistener(Slider, 'Value', 'PostSet', @(~,~) updateLabel());

            %% Listener that hides/shows the label together with the slider, so
            %  slider.Visible = 'off' is all a script has to set.
            addlistener(Slider, 'Visible', 'PostSet', ...
                @(~,~) set(Slider_label, 'Visible', Slider.Visible));

            updateLabel() % Force update

            % Snap to the step (if any), then run the script's callback
            function sliderMoved(src, evt)
                st = src.UserData.step;
                if ~isempty(st)
                    v = src.Min + round((src.Value - src.Min)/st)*st;
                    v = min(max(v, src.Min), src.Max);
                    if v ~= src.Value
                        src.Value = v;      % listener refreshes the label
                    end
                end
                CallbackFcn(src, evt);
            end

            function updateLabel()
                ud = Slider.UserData;
                if strlength(ud.limitLabel) > 0 && app.isAtLimit(Slider)
                    str = char(ud.limitLabel);
                else
                    % joinLatex merges '...$' + '$...' into one math block
                    % (a plain '$$' would break LaTeX, e.g. name + pi value)
                    str = uiFigure.joinLatex(char(ud.name), uiFigure.formatValue(Slider.Value, ud.format));
                    str = uiFigure.joinLatex(str, ud.addToEnd);
                end
                set(ud.label, 'String', str);
                % (Visibility is kept in step by the 'Visible' listener
                %  above, so it is not re-set on every slider move.)
            end
        end

        % ============================================
        % LIMIT SLIDER HELPERS
        % ============================================
        function tf = isAtLimit(~, Slider)
            % True when a slider sits at the end that stands for the limit
            % ('LimitAt' = "max" (default), "min" or "zero").
            ud    = Slider.UserData;
            limAt = "max";
            if isstruct(ud) && isfield(ud, 'limitAt'), limAt = ud.limitAt; end
            tol = 1e-9 * max(1, abs(Slider.Max - Slider.Min));
            switch limAt
                case "min",  tf = Slider.Value <= Slider.Min + tol;
                case "zero"
                    % closest value to 0 the slider can reach (e.g. Min_dt)
                    if Slider.Min <= 0 && Slider.Max >= 0
                        z0 = 0;
                    else
                        z0 = min(abs([Slider.Min Slider.Max]));
                    end
                    tf = abs(Slider.Value) <= z0 + tol;
                otherwise,   tf = Slider.Value >= Slider.Max - tol;
            end
        end

        function v = getValue(app, Slider)
            % Slider value ready to use: rounded for '%d' sliders, snapped
            % for 'Step' sliders, and 'LimitValue' at the limit end.
            ud = Slider.UserData;
            v  = Slider.Value;
            if isfield(ud, 'step') && ~isempty(ud.step)   % value set from code
                v = Slider.Min + round((v - Slider.Min)/ud.step)*ud.step;
                v = min(max(v, Slider.Min), Slider.Max);
            end
            if isfield(ud, 'format') && strcmp(ud.format, '%d')
                v = round(v);
            end
            if isfield(ud, 'limitValue') && ~isempty(ud.limitValue) && app.isAtLimit(Slider)
                v = ud.limitValue;
            end
        end

        % ============================================
        % KEEP A MIN SLIDER BELOW ITS MAX SLIDER
        % ============================================
        function linkMinMax(~, sMin, sMax, gap)
            % After this call, dragging sMin above sMax pushes sMax up (and
            % dragging sMax below sMin pushes sMin down), so a region such
            % as r_min <= r <= r_max can never turn inside out. gap is the
            % smallest allowed difference (default 0).
            if nargin < 4, gap = 0; end
            addlistener(sMin, 'Value', 'PostSet', @(~,~) pushOther(sMin, sMax, +1));
            addlistener(sMax, 'Value', 'PostSet', @(~,~) pushOther(sMax, sMin, -1));
            function pushOther(moved, other, dirn)
                % UpdateUISlider briefly parks a slider at its Max to force
                % a refresh; that temporary value must not push the partner.
                if isfield(moved.UserData, 'holdLink') && moved.UserData.holdLink
                    return
                end
                if dirn > 0 && other.Value < moved.Value + gap
                    other.Value = min(moved.Value + gap, other.Max);
                    if other.Value < moved.Value + gap   % other hit its end
                        moved.Value = other.Value - gap;
                    end
                elseif dirn < 0 && other.Value > moved.Value - gap
                    other.Value = max(moved.Value - gap, other.Min);
                    if other.Value > moved.Value - gap
                        moved.Value = other.Value + gap;
                    end
                end
            end
        end

        % ============================================
        % PREVIOUS / NEXT GALLERY BUTTONS
        % ============================================
        function [hPrev, hNext] = addPrevNext(app, idx, Num_Obj, nItems, drawFcn, varargin)
            % Two buttons at grid positions idx and idx+1 that step through
            % nItems examples, wrapping around. drawFcn(k) draws example k.
            % Extra name/value pairs go to addControl (e.g. 'colOrRow','row').
            app.galleryIdx = 1;
            hPrev = app.addControl('button', '$\leftarrow$ Previous', idx,   Num_Obj, @(~,~) stepGallery(-1), varargin{:});
            hNext = app.addControl('button', 'Next $\rightarrow$',    idx+1, Num_Obj, @(~,~) stepGallery(+1), varargin{:});
            function stepGallery(d)
                app.galleryIdx = mod(app.galleryIdx - 1 + d, nItems) + 1;
                drawFcn(app.galleryIdx);
            end
        end

        % ============================================
        % LATEX SLIDER FORCE UPDATE
        % ============================================
        function UpdateUISlider(app, Slider, Value, options)
            arguments
                app
                Slider
                Value double
                options.Min double = Slider.Min
                options.Max double = Slider.Max
            end

            % --- Update limits FIRST ---
            set(Slider, 'Min', options.Min);
            set(Slider, 'Max', options.Max);

            % Keep the value inside the new range (a value outside the
            % range makes MATLAB hide the slider with a warning)
            Value = min(max(Value, options.Min), options.Max);

            % --- Force value refresh (needed for MATLAB 2025) ---
            % holdLink stops linkMinMax from reacting to the temporary Max
            % (it would otherwise push a linked max slider to its end).
            isUi = isstruct(Slider.UserData);
            if isUi, Slider.UserData.holdLink = true; end
            set(Slider, 'Value', options.Max);
            if isUi, Slider.UserData.holdLink = false; end
            set(Slider, 'Value', Value);

            drawnow
        end


        % ============================================
        % SUBPLOT MOVER - Shrinks the plot axes once per layout direction so
        % that a column of controls (right side) or a row of controls
        % (bottom) never overlaps the plots. Mixed layouts are supported:
        % the first 'col' control and the first 'row' control each trigger
        % their own move.
        % ============================================
        function Subplot_Mover(app, pos, colOrRow)
            arguments
                app
                pos  double
                colOrRow string
            end
            isRow = strcmpi(colOrRow, 'row');

            % Each direction is only applied once per figure
            if isRow
                flag = 'SubplotsMovedRow';
            else
                flag = 'SubplotsMovedCol';
            end
            if isstruct(app.fig.UserData) && isfield(app.fig.UserData, flag) ...
                    && app.fig.UserData.(flag)
                return
            end

            % Plot axes only: the axes that draw buttons and slider labels
            % are tagged 'uiFigureControl' and must not be moved.
            ax_list = findobj(app.fig, 'Type', 'axes', '-not', 'Tag', 'uiFigureControl');

            if isRow
                % Lift the bottom of every plot above the row of controls.
                % Leave room for that plot's own tick labels and x label
                % (TightInset(2) = space they need below the axes box), plus
                % a small gap, so the x label never sits on the controls.
                gap = 0.03;
                controlsTop = pos(2) + pos(4);
                drawnow limitrate   % make sure label sizes are up to date
                for i = 1:numel(ax_list)
                    ax = ax_list(i);
                    below = 0.07;                       % fallback label space
                    if strcmp(ax.Units, 'normalized')
                        below = max(below, ax.TightInset(2));
                    end
                    new_bottom = controlsTop + gap + below;
                    axPos = ax.Position;
                    if axPos(2) < new_bottom
                        shrink = new_bottom - axPos(2);
                        ax.Position(2) = new_bottom;
                        ax.Position(4) = max(0.05, axPos(4) - shrink);
                    end
                end
            else
                % Squeeze every plot to the left of the column of controls
                ShiftBy = (pos(1) - 0.03) * 1.1;
                for i = 1:numel(ax_list)
                    axPos = ax_list(i).Position;
                    ax_list(i).Position(1) = axPos(1) * ShiftBy;
                    ax_list(i).Position(3) = axPos(3) * ShiftBy;
                end
            end

            app.fig.UserData.(flag)        = true;
            app.fig.UserData.SubplotsMoved = true; % kept for older scripts
        end
        %%%%%%%%%%%%%%%%%%%%%%%%  END FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    methods (Static, Access = private)
        function args = pickOptions(options, fields)
            % Name/value cell of only the options that were explicitly set
            s = struct();
            for i = 1:numel(fields)
                f = fields{i};
                if ~isempty(options.(f))
                    s.(f) = options.(f);
                end
            end
            args = namedargs2cell(s);
        end

        function s = joinLatex(a, b)
            % Join two label pieces. If a ends in math mode and b starts in
            % math mode ('$\theta = $' + '$\frac{\pi}{4}$'), merge them into
            % one block ('$\theta = \frac{\pi}{4}$') instead of writing '$$'.
            a = char(a); b = char(b);
            if ~isempty(a) && ~isempty(b) && a(end) == '$' && b(1) == '$'
                s = [a(1:end-1) ' ' b(2:end)];
            else
                s = [a b];
            end
        end

        function str = formatValue(val, fmt)
            % Text for a slider value: '%d', 'pi' or any sprintf format
            switch fmt
                case '%d'
                    str = sprintf('%d', round(val));
                case 'pi'
                    str = Pi_Label(val);                       % \frac{17\pi}{12}
                case 'pi_inline'
                    str = Pi_Label(val, 'Style', "inline");    % 17\pi/12
                otherwise
                    str = sprintf(fmt, val);
            end
        end
    end
end