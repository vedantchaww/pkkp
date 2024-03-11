
clc
close all
clear
%-------------------------Importing the Video File-------------------------
VideoFile = VideoReader('Input_video.mp4');
%-------------------Loading Region of Interest Variables-------------------
load('ROI_variables');
%-----------------Defining Variables for saving Video File-----------------
Output_Video=VideoWriter('Output_video');
Output_Video.FrameRate= 25;
open(Output_Video);


%% Initializing the loop to take frames one by one
while hasFrame(VideoFile)
%------------------Reading each frame from Video File------------------
frame = readFrame(VideoFile);
% figure('Name','Original Image'), imshow(frame);
frame = imgaussfilt3(frame);
% figure('Name','Filtered Image'), imshow(frame);
%% Masking the image for White and Yellow Color
%--------------Define Thresholds for masking Yellow Color--------------

%----------------------Define thresholds for 'Hue'---------------------
channel1MinY = 130;
channel1MaxY = 255;
%------------------Define thresholds for 'Saturation'------------------
channel2MinY = 130;
channel2MaxY = 255;
%---------------------Define thresholds for 'Value'--------------------
channel3MinY = 0;
channel3MaxY = 130;
%-----------Create mask based on chosen histogram thresholds-----------
Yellow=((frame(:,:,1)>=channel1MinY)|(frame(:,:,1)<=channel1MaxY))& ...
(frame(:,:,2)>=channel2MinY)&(frame(:,:,2)<=channel2MaxY)&...
(frame(:,:,3)>=channel3MinY)&(frame(:,:,3)<=channel3MaxY);
% figure('Name','Yellow Mask'), imshow(Yellow);
%--------------Define Thresholds for masking White Color---------------

%----------------------Define thresholds for 'Hue'---------------------
channel1MinW = 200;
channel1MaxW = 255;
%------------------Define thresholds for 'Saturation'------------------
channel2MinW = 200;
channel2MaxW = 255;
%---------------------Define thresholds for 'Value'--------------------
channel3MinW = 200;
channel3MaxW = 255;

%-----------Create mask based on chosen histogram thresholds-----------
White=((frame(:,:,1)>=channel1MinW)|(frame(:,:,1)<=channel1MaxW))&...
(frame(:,:,2)>=channel2MinW)&(frame(:,:,2)<=channel2MaxW)& ...
(frame(:,:,3)>=channel3MinW)&(frame(:,:,3)<=channel3MaxW);
% figure('Name','White Mask'), imshow(White);

%% Detecting edges in the image using Canny edge function
frameW = edge(White, 'canny', 0.2);
frameY = edge(Yellow, 'canny', 0.2);

%% Neglecting closed edges in smaller areas
frameY = bwareaopen(frameY,15);
frameW = bwareaopen(frameW,15);
% figure('Name','Detecting Edges of Yellow mask'), imshow(frameY);
% figure('Name','Detecting Edges of White mask'), imshow(frameW);


%% Extracting ROI
%---------Extracting Region of Interest from Yellow Edge Frame---------
roiY = roipoly(frameY, r, c);
[R , C] = size(roiY);
for i = 1:R
for j = 1:C
if roiY(i,j) == 1
frame_roiY(i,j) = frameY(i,j);
else
frame_roiY(i,j) = 0;
end
end
end
% figure('Name','Filtering ROI from Yellow mask'), imshow(frame_roiY);


%---------Extracting Region of Interest from White Edge Frame----------
roiW = roipoly(frameW, r, c);
[R , C] = size(roiW);
for i = 1:R
for j = 1:C
if roiW(i,j) == 1
frame_roiW(i,j) = frameW(i,j);
else
frame_roiW(i,j) = 0;
end
end
end
% figure('Name','Filtering ROI from White mask'), imshow(frame_roiW);


%% Applying Hough Tansform to get straight lines from Image

%----------Applying Hough Transform to White and Yellow Frames---------
[H_Y,theta_Y,rho_Y] = hough(frame_roiY);
[H_W,theta_W,rho_W] = hough(frame_roiW);

%--------Extracting Hough Peaks from Hough Transform of frames---------
P_Y = houghpeaks(H_Y,2,'threshold',2);
P_W = houghpeaks(H_W,2,'threshold',2);
%----------Plotting Hough Transform and detecting Hough Peaks----------

% figure('Name','Hough Peaks for White Line')
%imshow(imadjust(rescale(H_W)),[],'XData',theta_W,'YData',rho_W,'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal
% hold on
% colormap(gca,hot)

% x = theta_W(P_W(:,2));
% y = rho_W(P_W(:,1));
% plot(x,y,'s','color','blue');
% hold off

% figure('Name','Hough Peaks for Yellow Line')
% imshow(imadjust(rescale(H_Y)),[],'XData',theta_Y,'YData',rho_Y,'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal
% hold on
% colormap(gca,hot)

% x = theta_W(P_Y(:,2));
% y = rho_W(P_Y(:,1));
% plot(x,y,'s','color','blue');
% hold off

%--------------Extracting Lines from Detected Hough Peaks--------------

lines_Y = houghlines(frame_roiY,theta_Y,rho_Y,P_Y,'FillGap',3000,'MinLength',20);
% figure('Name','Hough Lines found in image'), imshow(frame), hold on
% max_len = 0;
% for k = 1:length(lines_Y)
% xy = [lines_Y(k).point1; lines_Y(k).point2];
% plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

% Plot beginnings and ends of lines
% plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
% plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% end

lines_W = houghlines(frame_roiW,theta_W,rho_W,P_W,'FillGap',3000,'MinLength',20);
max_len = 0;
% for k = 1:2
% xy = [lines_W(k).point1; lines_W(k).point2];
% plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

% Plot beginnings and ends of lines
% plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
% plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% end
% hold off



