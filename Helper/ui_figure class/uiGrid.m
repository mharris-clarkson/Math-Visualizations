function pos = uiGrid(idx, Num_Obj, options)
%
%% Author Info
%
% This function was written by Dr Matthew Harris an assistant professor at
% Clarkson university for visually teaching MA 231: Calculus 3.

arguments
    % Object index for location
    idx               double
    Num_Obj           double
    % Object spacing
    options.minY         double = 0.02
    options.maxY         double = 0.98
    options.minX         double = 0.05
    options.maxX         double = 0.95
    options.width        double = 0.15
    options.height       double = 0.05
    options.gap          double = 0.015
    options.autoCenter   logical = 1
    options.colOrRow     string  = 'col'% Defaults to column when autoCenter
    options.maxheight    double  = 0.05 % Max Height for auto column
    options.minheight    double  = 0.03 % Min Height for auto column
end
% Check for valid colOrRow values
if ~(strcmpi(options.colOrRow,'row') || strcmpi(options.colOrRow,'col'))
    error('UIApplet - addControl: colOrRow should be ''row'' or ''col'' but was %s', options.colOrRow);
end

% Compute spacing
if options.autoCenter % If auto center
    if strcmpi(options.colOrRow,'col') % If auto column
        % Compute heights given spacings above. This does even spacing
        options.height       = (options.maxY - options.minY - options.gap * Num_Obj)/ Num_Obj;

        % Put a catch for excessively tall GUI elements
        if options.height > options.maxheight
            options.height = options.maxheight;
        end
        if options.height < options.minheight
            options.height = options.minheight;
        end

        % Change minY to average the column out
        Total_height   = Num_Obj * (options.height + options.gap);
        extra_space_below = (options.maxY - options.minY - Total_height)/2;

        % Change miny to fit the column (not that miny can go below the
        % desired min
        if Total_height < options.maxY - options.minY
            options.minY = options.minY + extra_space_below;
        else
            options.minY = options.minY - extra_space_below;
        end

    else % If auto row
        options.width = (options.maxX - options.minX - options.gap * Num_Obj)/ Num_Obj;
    end
end

% Compute locations based on grid type
if strcmpi(options.colOrRow,'col')
    x = 1 - options.width - options.gap;              % fit one button width
    y = options.minY + (idx - 1) * (options.height + options.gap);% compute y spacing
else % Build a row
    x  = options.minX + (idx - 1) * (options.width + options.gap);% compute x spacing
    y  = options.minY;          % use min
end

% Return position
pos = [x, y, options.width, options.height];
end