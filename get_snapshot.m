function [snap] = get_snapshot(avifname)

%Function called by station_setup. Extracts one snapshot from a webcam
%video at one location. The resulting snapshot will be used to digtize and
%interpolate a duneline, and also identify alongshore locations of
%interest.

%Inputs:  avifname = filename of the video Outputs: snap = single frame
%from the video

%Author: Joseph Long, Deanna Edwing, Kelsea Edwing Original version created
%2/2020

%% extracts the first frame from a previously downloaded video
obj = VideoReader(avifname);
snap = readFrame(obj);



