%     Steffen Urban email: steffen.urban@kit.edu
%     Copyright (C) 2014  Steffen Urban
% 
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

% 04.03.2014 by Steffen Urban
% error function for the center of distortion search

function [error] = errCenterUrban(x, calib_data)

error = 0;
xc = x(1);
yc = x(2);
% call calibration function
[RRfin, ss] = calibrate(calib_data.Xt, calib_data.Yt, calib_data.Xp_abs, ...
                                                        calib_data.Yp_abs, xc,yc, ...
                                                        calib_data.taylor_order, ...
                                                        calib_data.ima_proc);
lauf = 1;
M = [calib_data.Xt,calib_data.Yt,ones(size(calib_data.Xt))];  

for i = 1:size(RRfin,3)    
    % if calibration was not possible add a high value
    % to penalize the minimization away from that point
    if calib_data.RRfin(:,:,i)==0
      error= error+sum(ones(length(calib_data.Xp_abs),1)*sqrt( (calib_data.ocam_model.width/2)^2 + (calib_data.ocam_model.height/2)^2));
    else                      
        Mc = RRfin(:,:,i)*M';
        Xpp=calib_data.Xp_abs(:,:,i);
        Ypp=calib_data.Yp_abs(:,:,i);     
        [xp1,yp1] = omni3d2pixel(ss, Mc, calib_data.ocam_model.width, calib_data.ocam_model.height);
        if (isinf(xp1) | isinf(yp1))
             error = error+sum(ones(length(calib_data.Xp_abs),1)*sqrt( (calib_data.ocam_model.width/2)^2 + (calib_data.ocam_model.height/2)^2));
        else         
            xp = xp1 + xc;     
            yp = yp1 + yc; 
            lauf = lauf+length(Xpp);
            error = error + sum((Xpp-xp').^2) + sum((Ypp-yp').^2);
        end

    end
end
error = sqrt(error / lauf);

end

