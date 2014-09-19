%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%   Copyright (C) 2006 DAVIDE SCARAMUZZA
%   
%   Author: Davide Scaramuzza - email: davsca@tiscali.it
%   
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%   
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%   USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function calibration(calib_data)

format long;


if isempty(calib_data.ima_proc) | isempty(calib_data.Xp_abs)
    fprintf(1,'\nNo corner data available. Extract grid corners before calibrating.\n\n');
    return;
end

% calib_data.taylor_order = input(['\nDegree of polynomial expansion ([]=' num2str(calib_data.taylor_order_default) ') = ']); %4
if isempty(calib_data.taylor_order), calib_data.taylor_order = calib_data.taylor_order_default; end;

calib_data.ocam_model.c=1;
calib_data.ocam_model.d=0;
calib_data.ocam_model.e=0;
[calib_data.RRfin,calib_data.ocam_model.ss]=calibrate(calib_data.Xt, calib_data.Yt, calib_data.Xp_abs, calib_data.Yp_abs, calib_data.ocam_model.xc, calib_data.ocam_model.yc, calib_data.taylor_order, calib_data.ima_proc);
calib_data.calibrated = 1; %This flag i s1 when the camera has been calibrated
reprojectpoints(calib_data);
ss = calib_data.ocam_model.ss;
ss

figure(3);
set(3,'Name','Calibration results','NumberTitle','off');
subplot(2,1,1);
plot(0:floor(calib_data.ocam_model.width/2),polyval([ss(end:-1:1)],[0:floor(calib_data.ocam_model.width/2)])); grid on; axis equal; 
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('f(rho)');
title('Forward projection function');
%
subplot(2,1,2);
plot(0:floor(calib_data.ocam_model.width/2),180/pi*atan2(0:floor(calib_data.ocam_model.width/2),-polyval([ss(end:-1:1)],[0:floor(calib_data.ocam_model.width/2)]))-90); grid on;
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('Degrees');
title('Angle of optical ray as a function of distance from circle center (pixels)');



