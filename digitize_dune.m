function varargout = digitize_dune(pic, stationname)

%DIGITIZE_DUNE  digitize a continuous dune base line from imagery.
%   output = digitize_dune returns the X- and Y- values of the graphically
%   selected dune position data in the array OUTPUT.
%
% INPUTS: stationname = name of the webcam station, chosen by the user in
% station_setup pic = single frame image from a webcam video.
%
% While substantial changes were made, the thought for this code came from
% a script:  digitize2.m on the Matlab Central Repository. Author(s): A.
% Prasad Original version created by J.D.Cogdell Anil (2020). digitize2.m
% (https://www.mathworks.com/matlabcentral/fileexchange/928-digitize2-m),
% MATLAB Central File Exchange. Retrieved January 30, 2020.
%
% Adapted from the original version (digitize2.m) to use an image already
% in the matlab workspace and removed excess inputs originally required
% (e.g., logarithmic axes) Joseph Long, Deanna Edwing, Kelsea Edwing 2/2020

image(pic)
FigName = ['IMAGE: ' stationname];

% Commence Data Acquisition from image
msgStr{1} = 'Digitize duneline by clicking along dune base';
msgStr{2} = ' ';
msgStr{2} = 'Click with LEFT mouse button to ACQUIRE';
msgStr{3} = ' ';
msgStr{4} = 'Click with RIGHT mouse button to QUIT';
titleStr = 'Ready for data acquisition';
uiwait(msgbox(msgStr,titleStr,'warn','modal'));
drawnow

numberformat = '%6.2f';
nXY = [];
ng = 0;
while 1
    n = 0;
    
    % %%%%%%%%%%%%%% DATA ACQUISITION LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while 1
        [x,y, buttonNumber] = ginput(1);
        line(x,y,'Marker','.','Color','r','MarkerSize',12)
        if buttonNumber == 1
            n = n+1;
            xpt(n) = x;
            ypt(n) = y;
        else
            query = questdlg('STOP digitizing and QUIT ?', ...
                'DIGITIZE: confirmation', ...
                'YES', 'NO', 'NO');
            drawnow
            switch upper(query)
                case 'YES'
                    %disp(sprintf('\n'))
                    break
                case 'NO'
                    
            end % switch query
        end
    end
    % %%%%%%%%%%%%%% DATA ACQUISITION LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          outputdata = [xpt' ypt'];
        varargout{1} = outputdata;
    break
end







