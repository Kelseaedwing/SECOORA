function [dcol] = check_timestack(ts1, ts2, ts3, yl,Di)

%Script converts timestacks (generated in get_brightest_timestack routine)
%from RGB to HSV imagery. The intensity of the third channel at the
%position of the dune is extracted. A threshold three times the standard
%deviation of the mean pixel intensity at that location is used to
%determine if a dune collision event has occurred. If the time series of
%pixel intensity exceeds this threshold, it is flagged as a '1' to indicate
%that a dune collision event occurred at that transect location.
%
%Inputs are the timestacks that were generated based on the three tranect
%locations, the stationname if the webcam where the video and associated
%products originated from, and the digitized and interpolated duneline
%
%Output is a variable dcol, which records whether each transect location is
%marked as having a dune collision event or not
%
%Authors: Joseph Long, Deanna Edwing, Kelsea Edwing original version
%created 2/2020

%Converts each date from strings to numbers computer will understand
for ii = 1:length(yl)
    
    %convert from rgb to hsv
        tmp = squeeze(rgb2hsv(eval(['ts' num2str(ii)])));
        V(:,:,ii) = squeeze(tmp(:,:,3));
        dx(ii) = Di(yl(ii),1);
        Vtran(:,ii) = V(:,round(dx(ii)),ii);
        Vm(ii) = mean(Vtran(:,ii));
        Vs(ii) = std(Vtran(:,ii));
        th(ii) = Vm(ii)+3*Vs(ii);
        
        %figure; subplot(3,1,ii);
        %pcolor(V(:,:,ii)); shading flat; hold on
        %plot(Vtran(:,ii)); hold on
        %plot([0 size(Vtran,1)],[th(ii) th(ii)],'-k')
        %title(['tran = ' num2str(dune(ii))])
        
         if any(Vtran(:,ii) > th(ii))
             dcol(ii) = 1;
         else
             dcol(ii) = 0;
         end
end

