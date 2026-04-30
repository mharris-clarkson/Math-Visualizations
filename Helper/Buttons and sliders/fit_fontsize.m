%% Function that computes the fontsize needed for text to fit in that width.
% Has a hard coded max of 18.

function fs = fit_fontsize(fig, text, norm_width)
    fs = 18;
    if false % Work in progress
    % Convert normalised width to pixels
    fig_width_px = fig.Position(3);
    width_px     = norm_width * fig_width_px;
    
    % Search for largest font that fits. Brute force but only 12 checks max
    % so...
    fs  = 18;  % start at max
    low = 6;
    found = false;
    while ~found
        ext = get(text_extent(fig, text, fs), 'Extent');
        if ext(3) <= width_px && low < fs
            fs = fs - 1;
        else
            found = true;
        end
    end
    end
end

function t = text_extent(fig, str, fs)
    % Temporary invisible text object to measure string width
    t = uicontrol(fig, 'Style', 'text', 'String', str, ...
        'FontSize', fs, 'Visible', 'off', 'Units', 'pixels');
end