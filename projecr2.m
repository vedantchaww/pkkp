% Read the input image
img = imread('roadd_image.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Apply a Gaussian blur to the image to reduce noise
blur_img = imgaussfilt(gray_img, 3);

% Apply a Canny edge detector to the image to detect edges
edges = edge(blur_img, 'Canny');

% Remove edges outside the region of interest (ROI)
roi = [100, 100; 500, 300; 600, 300; 900, 100];
mask = poly2mask(roi(:,1), roi(:,2), size(edges,1), size(edges,2));
roi_edges = uint8(edges) .* uint8(mask * 255);

% Apply a Hough transform to detect straight lines in the ROI
[H,theta,rho] = hough(roi_edges);
peaks = houghpeaks(H, 50);
lines = houghlines(roi_edges,theta,rho,peaks,'FillGap',20,'MinLength',50);

% Plot the detected straight lines on the input image
figure;
imshow(img);
hold on;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
end

% Apply a Hough transform to detect curves in the ROI
[H,theta,rho] = hough(roi_edges, 'Theta', -90:0.5:89.5);
peaks = houghpeaks(H, 50);
curves = houghlines(roi_edges,theta,rho,peaks,'FillGap',20,'MinLength',50);

% Plot the detected curves on the input image
for k = 1:length(curves)
   xy = [curves(k).point1; curves(k).point2];
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
end

