clc
clear all 
close all
% Open file selection dialog to choose an image
[filename, pathname] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', ...
                                   'Image Files (*.png, *.jpg, *.jpeg, *.bmp, *.tif, *.tiff)'; ...
                                   '*.*', 'All Files (*.*)'}, ...
                                   'Select an Image');

% Check if the user canceled the operation
if isequal(filename, 0) || isequal(pathname, 0)
    disp('User canceled the operation.');
else
    % Construct the full path of the image
    fullImagePath = fullfile(pathname, filename);
% Step 1: Load the Medical Image
img = imread(fullImagePath);
% img = imread('kidney 25.JPG');  % Replace with the actual kidney ultrasound or CT image
figure;
imshow(img);
title('Original Image');

% Step 2: Convert to Grayscale (if the image is in RGB)
grayImg = rgb2gray(img);  
figure;
imshow(grayImg);
title('Grayscale Image');

% Step 3: Image Enhancement - Contrast Adjustment
% Apply histogram equalization to enhance contrast
enhancedImg = histeq(grayImg);
figure;
imshow(enhancedImg);
title('Enhanced Image with Histogram Equalization');

% Step 4: Noise Reduction - Gaussian Smoothing
% Apply Gaussian filter to reduce noise and smooth the image
smoothedImg = imgaussfilt(enhancedImg, 2);  % Gaussian filter with sigma = 2
figure;
imshow(smoothedImg);
title('Smoothed Image (Noise Reduced)');

% Step 5: Edge Detection (Identify Potential Stones)
% Using Canny edge detection to find edges of kidney stones
edges = edge(smoothedImg, 'Canny');  
figure;
imshow(edges);
title('Edge Detected Image');

% Step 6: Morphological Operations (Clean up the Image)
% Dilate edges to make stone areas more prominent
dilatedImg = imdilate(edges, strel('disk', 2));  % Disk-shaped structuring element
figure;
imshow(dilatedImg);
title('Dilated Edges');

% Step 7: Segment the Stones
% Fill holes to create solid regions where kidney stones are detected
filledImg = imfill(dilatedImg, 'holes');
figure;
imshow(filledImg);
title('Filled Image (Segmented Stones)');

% Step 8: Remove Small Objects (Noise)
% Remove small objects that are not likely to be kidney stones
cleanedImg = bwareaopen(filledImg, 50);  % Removing small objects with less than 50 pixels
figure;
imshow(cleanedImg);
title('Cleaned Image (Noise Removed)');

% Step 9: Label and Analyze Detected Stones
% Label connected components (stones) in the binary image
[labeledImg, numObjects] = bwlabel(cleanedImg);
disp(['Number of detected kidney stones: ', num2str(numObjects)]);

% Step 10: Display the stones in original image
% Show detected stones on the original image for visualization
stoneOverlay = label2rgb(labeledImg, 'jet', 'k', 'shuffle');
figure;
% Display the original grayscale image with the stone overlay
% overlayedImage = imoverlay(grayImg, stoneOverlay, 'yellow');
% imshow(overlayedImage);
imshow(stoneOverlay)

%imshow(imoverlay(grayImg, stoneOverlay, 'Transparency', 0.3));
title('Detected Stones Overlay on Original Image');

% Step 11: Extract Features of Detected Stones
% Extract properties like Area, Centroid, and Bounding Box of the stones
stats = regionprops(cleanedImg, 'Area', 'Centroid', 'BoundingBox');

% Display information about each stone
for i = 1:numObjects
    fprintf('Stone %d: Area = %.2f pixels\n', i, stats(i).Area);
    fprintf('Centroid = (%.2f, %.2f)\n', stats(i).Centroid(1), stats(i).Centroid(2));
end

% Optional: Mark Bounding Boxes on the Original Image
figure;
imshow(img);
hold on;
for i = 1:numObjects
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    text(stats(i).Centroid(1), stats(i).Centroid(2), sprintf('Stone %d', i), 'Color', 'g');
end
hold off;
title('Kidney Stones Detected with Bounding Boxes');
end
