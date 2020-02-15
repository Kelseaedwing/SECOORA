function [xpt,ypt] = choose_locations

%Function called by the station_setup script. Allows user to identify three
%locations of interest along a dune base line which will be used to monitor
%dune collision.
%
%OUTPUTS: User-defined x and y pixel locations represening the three
%identified locations of interest.
%
%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing Original version
%created 2/2020

n = 0;

LocButton = questdlg(...
    'Choose up to 3 locations of interest along the dune', ...
    'Choose Locations', ...
    'OK','Cancel','OK');

switch LocButton
    case 'OK'
        drawnow
        for i = 1:3
        [xpt(i),ypt(i)] = ginput(1);
        plot(xpt(i),ypt(i),'.','Color','g','MarkerSize',12)
        end
    case 'Cancel'
        close(FigName)
        return
end 
