% Main Script: This script begins with a check to ensure users have already
% set-up a webcam location and generated their digitized and interpolated
% duneline and identified three locations of interest. If the user has not
% set-up a webcam station, the 'station_setup' script will be called to
% allow user to complete that step. If a station has been setup, users will
% identify the station name and select the video they wish to process. The
% chosen video will be processed to generate the brightest image and
% timestack products, which will then be compared to the duneline to
% determine if a dune collision event has occured. The final output of this
% script is a .png and .mat file containing the final results of the
% algorithm. If a dune collision event is identified over the ten-minute
% video using both methods the location will be plotted on a snapshot in
% red. If a dune collision event is identified over the ten-minute video
% using only one of the methods the location will be plotted on a snapshot
% in yellow. If no dune collision event is detected, the location will be
% plotted in green.

%%stationname = input('stationname') with one input arguement 'stationname'
%is used to directly specify the video(s) to load at that specified webcam
%location

%downloaded video = the second input, users must identify the video they
%wish the algorithm to process by navigating through the file finder window
%that will appear to prompt the user to chose a downloaded video from the
%station previosuly set-up

%output = final results will be saved as a .png and .mat file in the
%identified working directory to save for future use if necessary

%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing original version
%created 2/2020


%Go to SECOORA WebCAT website to download data
% right now Buxton is the only option you need the user to pick a day and
% time. http://webcat-video.axds.co/<station
% code>/raw/<year>/<year>_<month>/<year>_<month>_<day>/<station
% code>.<year>-<month>-<day>_<time>.mp4

% Set up a new station?
StartupButton = questdlg('Do you need to set up a station?', ...
    '', 'YES','NO','NO');
switch StartupButton
    case 'YES'
        [stationname, vid] = station_setup;
    case 'NO'
        % Provide a station name to load station information
        prompt={'Enter the Site Name(no spaces):'};
        def={''};
        dlgTitle='Site Name: user input required';
        lineNo=1;
        stationname=inputdlg(prompt,dlgTitle,lineNo,def);
        if (isempty(char(stationname{:})) == 1)
            close(FigName)
            return
        end
        stationname= stationname{1};
        
             [filename, pathname] = uigetfile( ...
	       {'*.mp4'}, ...
	       'Select movie file');
     if isequal(filename,0) | isequal(pathname,0)
	  return
     else
	  imagename = fullfile(pathname, filename);
     end
     
vid = [pathname filename];
end
load([stationname '_station_setup.mat'])

% find the time of the video
% this is hard-coded for webcat
[tmp] = strfind(vid,'.'); 
tname = vid(tmp(1)+1:tmp(2)-1);
y = str2double(tname(1:4));  % year
mo = str2double(tname(6:7));   % month
day = str2double(tname(9:10));
hr = str2double(tname(12:13));
mi = str2double(tname(14:15));
timage = datenum(y,mo,day,hr,mi,0);

% process video for brightest image and timestacks

[photobrt, ts1, ts2, ts3] = get_brightest_timestack(vid, stationname, yl);

% remove the horizon
photobrt2 = photobrt(yh:end,:,:);

% check the water levels compared to the dune line
% method 1: find maximum water line from the brightest image and compare to
% dune locations
yl2 = yl-yh;
[wl] = check_brightest(photobrt2,yl2);

% Check the timestack method
[dcol_ts] = check_timestack(ts1,ts2,ts3, yl, Di);

% % compare brightest image to the dune line?
for i = 1:3
    if Di(yl(i),1) > wl.x(yl2(i))
        dcol_brt(i) = 1;
    else
        dcol_brt(i) = 0;
    end
end

dtest = dcol_ts+dcol_brt;

close all
figure;
image(photobrt); hold on
plot(Di(:,1),Di(:,2),'-b','linewidth',3)
plot(wl.x,wl.y+yh,'-g','linewidth',3)
for i = 1:3
    if dtest(i) == 2
    plot(Di(yl(i),1),Di(yl(i),2),'.r','markersize',20)
    elseif dtest(i) == 1
    plot(Di(yl(i),1),Di(yl(i),2),'.y','markersize',20)
    elseif dtest(i) == 0
    plot(Di(yl(i),1),Di(yl(i),2),'.g','markersize',20)
    end
end

% save figure
saveas(gcf,[stationname '_' datestr(timage,'yyyymmdd_HHMM') '_results'],'png')
save([stationname '_' datestr(timage,'yyyymmdd_HHMM') '_results.mat'], 'Di','yl','yh','stationname','wl','dcol_brt','dcol_ts','dtest');




