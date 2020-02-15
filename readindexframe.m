function outputFrame=readindexframe(videoSource,frameNumber)

% Script called by the 'get_brightest_timestack' routine. The high frame
% rate of the video (often 30fps) is unnecessary to generate the brightest
% image. This routine grabs non-sequential video frames to speed up
% processing.
%
% INPUTS: videoSource - Video object framenumber = the single frame to
% extract/analyze
%
% OUTPUTS: outputFrame = single from from the video at the time desired
%
%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing 2/2020

info=get(videoSource);
videoSource.CurrentTime=(frameNumber-1)/info.FrameRate;
outputFrame=readFrame(videoSource);