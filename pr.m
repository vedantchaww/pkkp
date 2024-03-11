% Read video file
video = VideoReader('project_video.mp4');

% Define output video file
outputVideo = VideoWriter('output_video.avi');
outputVideo.FrameRate = video.FrameRate;
open(outputVideo);

% Set parameters for Canny edge detection
lowThreshold = 50;
highThreshold = 100;

% Set parameters for Hough transform
houghThreshold = 100;
houghFillGap = 20;
houghMinLength = 50;

% Loop through video frames
while hasFrame(video)
    % Read video frame
    frame = readFrame(video);
    
    % Convert frame to grayscale
    grayFrame = rgb2gray(frame);
    
    % Apply Canny edge detection
    edgeFrame = edge(grayFrame, 'Canny', [lowThreshold highThreshold]);
    
    % Apply Hough transform
    [houghLines, houghProb] = hough(edgeFrame);
    houghPeaks = houghpeaks(houghProb, 10, 'Threshold', houghThreshold);
    houghLines = houghlines(edgeFrame, houghProb, houghPeaks, 'FillGap', houghFillGap, 'MinLength', houghMinLength);
    
    % Plot detected lines on original frame
    for k = 1:length(houghLines)
        xy = [houghLines(k).point1; houghLines(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
    
    % Write frame to output video
    writeVideo(outputVideo, frame);
end

% Close output video file
close(outputVideo);
