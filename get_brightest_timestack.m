function [photobrt, ts1, ts2, ts3] = get_brightest_timestack(avifname, stationname, yl)

%% Function called from analyze_dune_collision
% Script generates the brightest image and a set of timestacks (pixel
% intensity along a cross-shore transect for each video frame) at the three
% alongshore locations identified during station_setup

%INPUTS:
% avifname = avifname = filename of the video stationname = user-defined
% station name from the station_setup routine yl = locations of the three
% places of interest defined by the user in the station_setup routine.

%OUTPUTS:
% photobrt = brightest image product ts1, ts2, ts2 = timestack of pixel
% intensity at the three alongshore locations of interest

%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing 2/2020


obj = VideoReader(avifname);

N = obj.NumberOfFrames;   %  determine the number of frames in the video
vidHeight = obj.Height;
vidWidth = obj.Width;
vidFrameRate = obj.frameRate;
vidDuration = obj.Duration;

%% PARAMETERS
ISTART = 1; % could be changed if you want to skip the first part of the video
IEND = N; % could be changed if you want to skip the last part of the video
DFRAME = 30; % skip this number of frames each step (to go faster)
nn=1;

obj = VideoReader(avifname);

% loop through frames
photobrt = 0; % brightest

w = N/DFRAME;
w = round(w);
if(N>ISTART)
    % read the images into the program
    f = waitbar(0,'Processing...this could take up to 2 minutes','Name','Processing Video...');
    for i = ISTART:DFRAME:IEND
        waitbar(i/IEND,f)
        snap = readindexframe(obj,i);
        
        if i == ISTART
            % create array for photos to be put in
             photobrt = 0*double(snap);
                ts1 = zeros(w,size(snap,2),3);
                ts2 = zeros(w,size(snap,2),3);
                ts3 = zeros(w,size(snap,2),3);
            
            % get a sample photo of the area
            [fd,fn,fe] = fileparts(avifname);
            imwrite(snap, [fn,'.snap.jpg'],'jpeg');
        elseif(i>ISTART)
            % update
            snapd = double(snap);
            
            if rem(i,1000)==0
            fprintf('%d of %d: updating\n', i,(N-ISTART))
            end
            
            B = (255/max(double(snap(:))))/64;
            bitwt(i)=1; bitwt = bitwt*B;
            id = snapd>photobrt;
            photobrt(id) = snapd(id);
            
            if length(yl)==1
                ts1(nn,:,:) = snapd(yl(1),:,:);
            elseif length(yl)==2
                ts1(nn,:,:) = snapd(yl(1),:,:);
                ts2(nn,:,:) = snapd(yl(2),:,:);
            elseif length(yl)==3
                ts1(nn,:,:) = snapd(yl(1),:,:);
                ts2(nn,:,:) = snapd(yl(2),:,:);
                ts3(nn,:,:) = snapd(yl(3),:,:);
            end
            nn = nn + 1;
        end
    end
end
delete(f)

% convert images into useable format
bscale = max(max(max(photobrt,[],3),[],2));
photobrt = uint8(254*photobrt/bscale);

%write images to disk after they have been created
imwrite(photobrt, [fn,'.brt.jpg'],'jpeg');
save([stationname,'_timestacks.mat'],'ts*')

