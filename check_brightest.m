function [wl] = check_brightest(photobrt,yl)

%This script is an adaption of the CIRN code developed by Mitch Harley, but
%has been modified to work on non-rectified cameras and brightest image
%products to determine extreme water levels. This script converts the
%brightest image product to HSV, relying on the V-channel of the HSV image
%for analysis. The HSV image is then smoothed to remove or dampen edge
%effects to ensure the shoreline is chosen instead of sand or some other
%feature. A threshold is then identified and the shoreline is contoured. In
%the event that there are multiple contours, flags have been set to chose
%the longest contour over 100 pixels in length. This contour is then
%interpolated onto the pixel grid to be able to compare the contour
%position to the digitized and interpolated duneline to determine if a dune
%collision event occurred.

%Inputs are the brightest image product and yl, the chosen locations of the
%alongshore locations of interest.

%Output is a variable called 'wl' which records the x and y pixel location
%of the extreme water line.

%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing Original version for
%rectified imagery created by: Mitch Harley February 2020
%https://github.com/Coastal-Imaging-Research-Network/Shoreline-Mapping-Toolbox


%Relies on a threshold in the V-channel of an HSV image
photobrt_hsv = rgb2hsv(photobrt);
V1 = double(photobrt_hsv(:,:,3));
V = medfilt2(V1,[25 25]);

% compensate for the edge effects of the median filter
V(1:5,1:end) = V1(1:5,1:end);
V(end-5:end,1:end) = V1(end-5:end,1:end);
V(1:end,1:5) = V1(1:end,1:5);
V(1:end,end-5:end) = V1(1:end,end-5:end);

sz = size(photobrt_hsv);

f1=figure;
image(photobrt)
axis image;

for i= 1:3
    transects.x(i,:) = [0 sz(2)];
    transects.y(i,:) = [yl(i) yl(i)];
end

%Find threshold
P = improfile(1:sz(1),1:sz(2),photobrt_hsv, transects.x, transects.y); %Sample pixels at transects to determine threshold
[pdf_values,pdf_locs] = ksdensity(P(:,:,3)); %find smooth pdf of V-channel

xlabel_type = 'V-channel';
thresh_weightings = [0.6 0.4]; %This weights the authomatic thresholding towards the extreme values to avoid picking out the surf zone variations
[peak_values,peak_locations]=findpeaks(pdf_values,pdf_locs); %Find peaks

thresh_otsu = multithresh(P(:,:,3)); %Threshold using Otsu's method CITATION FOR THIS OTSU METHOD?

% f2 = figure;
% plot(pdf_locs,pdf_values)
% hold on
I1 = find(peak_locations<thresh_otsu);
[~,J1] = max(peak_values(I1));
I2 = find(peak_locations>thresh_otsu);
[~,J2] = max(peak_values(I2));
% plot(peak_locations([I1(J1) I2(J2)]),peak_values([I1(J1) I2(J2)]),'ro')

%thresh = mean(peak_locations([I1(J1) I2(J2)])); %only find the last two peaks
thresh = thresh_weightings(1)*peak_locations(I1(J1)) + thresh_weightings(2)*peak_locations(I2(J2)); %Skew average towards the positive (i.e. sand pixels)

% YL = ylim;
% plot([thresh thresh], YL,'r:','linewidth',2)
% xlabel(xlabel_type,'fontsize',10)
% ylabel('Counts','fontsize',10)

%Extract contour
c = contours(V,[thresh thresh]);
figure(f1)

%Now look at contours to only find the longest contour (assumed to be the
%shoreline)
xyz.x = [];
xyz.y = [];
II = find(c(1,:)==thresh);
if II==1 %If only one line
    startI = 2;
    endI = size(c,2);
    xyz.x = [xyz.x; c(1,startI:endI)'];
    xyz.y = [xyz.y; c(2,startI:endI)'];
else
    D = diff(II);
    [~,J] = find(D>100); %Select contours that are above some length threshold (100 points defined here)
    if J == 1
        startI = 2;
        endI = size(c,2);
        xyz.x = [xyz.x; c(1,startI:endI)'];
        xyz.y = [xyz.y; c(2,startI:endI)'];
    else
        for i = 1:length(J)
            startI = 1+J(i)+sum(D(1:J(i)-1));
            endI = startI+D(J(i))-J(i)-1;
            xyz.x = [xyz.x; c(1,startI:endI)'];
            xyz.y = [xyz.y; c(2,startI:endI)'];
        end
    end
end

points = [xyz.y xyz.x];
hold on; plot(points(:,2),points(:,1), '.r','linewidth',3);

% interpolate points to the pixel grid
ip = find(points(:,1)>25);
px = 0:sz(2)-1;
py = 0:sz(1)-1;
[~,ind] = unique(points(ip,1));
[xi] = interp1(points(ip(ind),1),points(ip(ind),2),py);
wl.x= xi;
wl.y= py';
plot(wl.x,wl.y,'.g');

