clc; clear; close all;


%% Animation for cats sending the message with sin wave
pause_time = 0.5;
%% ================== LOAD IMAGES ==================
img1 = imread('cats.png');
img2 = imread('catSheepCow.png');

%% ================== CREATE FIGURE ==================
f1 = figure('Color','w', 'WindowState','maximized');

%% ================== CARRIER WAVES ==================
N = 100;
w1 = 1;
w2 = 2;
A = 1;
AM1 = 0.5;
AM2 = 0.5;
t_part = linspace(0,2*pi,N);
t_full = linspace(0,8*2*pi,8*N); % t for an 8 bit sygnal
y1 = sin(w1*t_full);
y2 = sin(w2*t_full);

message1 = "La meow meow!";
message2 = "El moo moo...";

%% ================== IMAGES and TEXT subplot(2,1,1) ==================
subplot(2,1,1)
axis off
hold on

% Display top image
axes('Position',[0.1 0.5 0.8 0.6])
imshow(img1)

% Build text boxes
t_char1 = text(350, 100, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_bin1  = text(350, 122, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

pause
% Animation of signal being sent
for i=1:strlength(message1)
    % Cat Message
    % convert to binary
    ch = extractBetween(message1, i, i);
    binary_char1 = dec2bin(double(char(ch)), 8);
    binary_int1 = binary_char1 - '0';

    % Update text
    t_char1.String = ch;
    t_bin1.String  = binary_char1;

    % Modulate sineswave
    amp1  = repelem(fliplr(binary_int1), length(t_part));
    subplot(2,1,2)
    plot(t_full,(A+AM1*amp1).*y1,'LineWidth',2)

    % Show cutoffs
    hold on
    plot([t_full(1) t_full(end)],[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    hold off

    % Patches
    hold on
    for j=1:4
        patch(2*pi*[2*j,2*j,2*j-1,2*j-1], (A+AM1)*[-1,1,1,-1], 'g','FaceAlpha', 0.25)
    end
    hold off

    legend('Full Signal -- AM')
    xlabel('Time')
    ylabel('Amplitude')
    set(gca,'FontSize',18)
    set(gca, 'XTick', [])
    set(gca, 'XLim',[0, 8*2*pi])
    pause(pause_time)
end
pause
















%% Animation for cats and sheep/cow sending their messages with two sin waves
f2 = figure('Color','w', 'WindowState','maximized');

%% ================== IMAGES and TEXT subplot(2,1,1) ==================
subplot(2,1,1)
axis off
hold on

% Display top image
axes('Position',[0.1 0.48 0.8 0.5])
imshow(img2)

% Build text boxes
t_char1 = text(350, 100, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_bin1  = text(350, 122, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_char2 = text(350, 240, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_bin2  = text(350, 262, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_char3 = text(350, 340, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

t_bin3  = text(350, 362, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w');

pause
% Animation of signal being sent
for i=1:strlength(message1)
    % Cat Message
    % convert to binary
    ch = extractBetween(message1, i, i);
    binary_char1 = dec2bin(double(char(ch)), 8);
    binary_int1 = binary_char1 - '0';

    % Update text
    t_char1.String = ch;
    t_bin1.String  = binary_char1;

    % Sheep Message
    % convert to binary
    ch = extractBetween(message2, i, i);
    binary_char2 = dec2bin(double(char(ch)), 8);
    binary_int2 = binary_char2 - '0';

    % Update text
    t_char2.String = ch;
    t_bin2.String  = binary_char2;

    % Resulting "Message"
    message_sum_Str = num2str(binary_int1 + binary_int2);
    message_sum_Str = message_sum_Str(~isspace(message_sum_Str));

    t_char3.String = "Sum =";
    t_bin3.String  = message_sum_Str;

    % Modulate sineswave
    amp1  = repelem(fliplr(binary_int1) + fliplr(binary_int2), length(t_part));
    subplot(2,1,2)
    plot(t_full,(A+AM1*amp1).*y1,'LineWidth',2)

    % Show cutoffs
    hold on
    plot([t_full(1) t_full(end)],[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    hold off

    % Patches
    hold on
    for j=1:4
        patch(2*pi*[2*j,2*j,2*j-1,2*j-1], (A+AM1)*[-1,1,1,-1], 'g','FaceAlpha', 0.25)
    end
    hold off

    legend('Full Signal -- AM')
    xlabel('Time')
    ylabel('Amplitude')
    set(gca,'FontSize',18)
    set(gca, 'XTick', [])
    set(gca, 'XLim',[0, 8*2*pi])
    pause(pause_time)
end
pause














%% Animation for cats and sheep/cow sending their messages with two sin waves
f3 = figure('Color','w', 'WindowState','maximized');


%% ================== IMAGES and TEXT subplot(2,1,1) ==================
subplot(2,1,1)
axis off
hold on

% Display top image
axes('Position',[0.1 0.48 0.8 0.5])

imshow(img2)

% Build text boxes
t_char1 = text(350, 100, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w',Color='r');

t_bin1  = text(350, 122, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w',Color='r');

t_char2 = text(350, 240, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w',Color='m');

t_bin2  = text(350, 262, '', 'HorizontalAlignment','center', ...
    'FontSize',16, 'FontWeight','bold', 'BackgroundColor','w',Color='m');

pause
% Animation of signal being sent
for i=1:strlength(message1)

    % Cat Message
    % convert to binary
    ch = extractBetween(message1, i, i);
    binary_char1 = dec2bin(double(char(ch)), 8);
    binary_int1 = binary_char1 - '0';

    % Update text
    t_char1.String = ch;
    t_bin1.String  = binary_char1;

    % Sheep Message
    % convert to binary
    ch = extractBetween(message2, i, i);
    binary_char2 = dec2bin(double(char(ch)), 8);
    binary_int2 = binary_char2 - '0';

    % Update text
    t_char2.String = ch;
    t_bin2.String  = binary_char2;

    % Modulate sineswave
    amp1  = repelem(fliplr(binary_int1), length(t_part));
    amp2  = repelem(fliplr(binary_int2), length(t_part));
    subplot(2,1,2)
    plot(t_full,(A+AM1*amp1).*y1 + (A+AM2*amp2).*y2,'LineWidth',2)
    hold on
    plot(t_full,(A+AM1*amp1).*y1,'r','LineWidth',2)
    plot(t_full,(A+AM2*amp2).*y2,'m','LineWidth',2)
    hold off

    % Show cutoffs
    hold on
    plot([t_full(1) t_full(end)],[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A,A] ,'-.k', 'LineWidth',2)
    plot([t_full(1) t_full(end)],1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A+AM1,A+AM1] ,'-.g', 'LineWidth',2)
    plot([t_full(1) t_full(end)],1*[A+AM2,A+AM2] ,'-.g', 'LineWidth',2)
    plot([t_full(1) t_full(end)],-1*[A+AM2,A+AM2] ,'-.g', 'LineWidth',2)
    hold off

    % Patches
    hold on
    for j=1:4
        patch(2*pi*[2*j,2*j,2*j-1,2*j-1], (A+AM1)*[-1,1,1,-1], 'g','FaceAlpha', 0.25)
    end
    hold off
    legend('Full Signal','Signal 1 -- AM','Signal 2 -- AM')


    xlabel('Time')
    ylabel('Amplitude')
    set(gca,'FontSize',18)
    set(gca, 'XTick', [])
    set(gca, 'XLim',[0, 8*2*pi])
    pause(pause_time)
end