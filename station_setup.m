function [stationname, vid] = station_setup

% Users use this script to setup a station to analyze dune collision from a
% webcan videos. This process only needs to be performed once per webcam
% location or if the position of the dune or view of the camera changes.
%
% First, users are promted to name the station. A snapshot will be created
% from one downloaded video, and the
%user will be prompted digitize the base of primary dune. When complete,the
%duneline will automatically be interpolated without an input needed from
%the user. Once again, the same snapshot will reappear, with the digitized
%dune line, prompting the user to chose three alongshore locations. These
%locations should ideally represent an area of interest where it is
%necessary to monitor dune collision. After transect locations are chosen,
%the code will prompt the user to select a single point in the frame to
%eliminate the horizon from the final snapshot. This helps with
%identificaton of the water line from the analysis. A .png of the snapshot
%will appear after these steps are completed that should display the
%digitized and interpolated duneline, three dots indicating the dune line
%and the alongshore locations of interest. These files will be saved as
%.png and all variables will be save in a .mat formats for use in analyzing
%all future videos from this site.
%
%INPUTS: None
%
%OUTPUS: A .png and .mat file containing digitized and interpolated
%duneline, location of three identified areas of interest, and the position
%of the horizon.
%
%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing original version
%created 2/2020

% User should have already downloaded your first video from your station of
% interest (https://secoora.org/webcat/)

% Describe the general steps:
msgStr{1} = 'This will allow you to set up a station for analysis';
msgStr{2} = ' ';
msgStr{2} = 'This only needs to be done once, or if the position of the dune or camera view changes';
msgStr{3} = ' ';
msgStr{4} = 'Step 1: identify a station name and associated video ';
msgStr{5} = '';
msgStr{6} = 'Step 2. digitize a line along the dune base';
msgStr{7} = '';
msgStr{8} = 'Step 3. identify three alongshore transect locations along the dune to monitor for dune collision';
titleStr = 'Station Setup Instructions';
uiwait(msgbox(msgStr,titleStr,'warn','modal'));
clear msgStr titleStr

% Prompt user for a station name
if nargin < 1
    prompt={'Choose a Site Name(no spaces):'};
    def={''};
    dlgTitle='Site Name: user input required';
    lineNo=1;
    stationname=inputdlg(prompt,dlgTitle,lineNo,def);
    if (isempty(char(stationname{:})) == 1)
        close(FigName)
        return
    end
    stationname = stationname{1};
end

% process the video for the first snapshot only. Assuming you are in the
% directory with the video
% Describe the general steps:
msgStr{1} = 'Next, choose a video you have already downloaded for this station';
msgStr{2} = '';
msgStr{2} = 'If you have not downloaded a video yet, go to https://secoora.org/webcat/';
msgStr{3} = '';
titleStr = 'Choose a video';
uiwait(msgbox(msgStr,titleStr,'warn','modal'));


[filename, pathname] = uigetfile( ...
    {'*.mp4'}, ...
    'Select movie file');
if isequal(filename,0) | isequal(pathname,0)
    return
else
    imagename = fullfile(pathname, filename);
end

vid = [pathname filename];

% if isempty(vid)
%     print('Have you downloaded a video yet?  If not, go here: https://secoora.org/webcat/). If so, navigate to the folder with the video')
% end

[snap] = get_snapshot(vid);

% digitize a duneline from the snapshot
[D] = digitize_dune(snap, stationname);
close

% interpolate duneline to all pixel locations
% interpolate points to the pixel grid
sz = size(snap);
py = 0:sz(1)-1;
[xi] = interp1(D(:,2),D(:,1),py);
Di(:,1)= xi;
Di(:,2)= py';
figure; image(snap)
hold on; plot(xi,py,'b','linewidth',2)
xlabel('cross-shore pixels')
ylabel('alongshore pixels')

% choose up to 3 alongshore locations for analysis
[~,yl] = choose_locations; yl = round(yl);
close

% choose a point to ignore the horizon
figure; image(snap);
LocButton = questdlg(...
    'Choose a point on the image just below the horizon', ...
    'Find horizon', ...
    'OK','Cancel','OK');

switch LocButton
    case 'OK'
        drawnow
        [xh,yh] = ginput(1);
    case 'Cancel'
        close(FigName)
        return
end
yh = round(yh);
Di(1:yh+1,1) = NaN;
Di(1:yh+1,2) = NaN;

figure; image(snap)
hold on; plot(xi,py,'b','linewidth',2)
plot(Di(yl,1),Di(yl,2),'.g','markersize',20)
xlabel('cross-shore pixels')
ylabel('alongshore pixels')

% save figure
saveas(gcf,[stationname '_setup'],'png')
save([stationname '_station_setup.mat'], 'Di','yl','yh','stationname');
