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

function recomp_corner_calib(calib_data)

if isempty(calib_data.ima_proc) | isempty(calib_data.Xp_abs)
    fprintf(1,'\nNo corner data available. Extract grid corners before calibrating.\n\n');
    return;
end

if isempty(calib_data.wintx) || isempty(calib_data.winty)
    wintx_default = max(round(calib_data.ocam_model.width/128),round(calib_data.ocam_model.height/96));
    winty_default = wintx_default;
else
    wintx_default = calib_data.wintx;
    winty_default = calib_data.winty;
end

disp('Window size for corner finder (wintx and winty):');
wintx = input(['wintx ([] = ' num2str(wintx_default) ') = ']);
if isempty(wintx)
    wintx = wintx_default; 
else
    calib_data.wintx = round(wintx);
end;
wintx = round(wintx);
winty = input(['winty ([] = ' num2str(winty_default) ') = ']);
if isempty(winty)
    winty = winty_default; 
else
    calib_data.winty = round(winty);
end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);
for kk = calib_data.ima_proc,
    I = calib_data.I{kk};
    for count = 1:(calib_data.n_sq_x+1)*(calib_data.n_sq_y+1),
        xx=calib_data.RRfin(:,:,kk)*[calib_data.Xt';calib_data.Yt';ones(size(calib_data.Xt'))];
        [Xp_reprojected,Yp_reprojected]=omni3d2pixel(calib_data.ocam_model.ss,xx,calib_data.ocam_model.width,calib_data.ocam_model.height); %convert 3D coordinates in 2D pixel coordinates  
        if wintx~=0 & winty~=0
            [xxi] = cornerfinder([Yp_reprojected(count) + calib_data.ocam_model.yc ;Xp_reprojected(count) + calib_data.ocam_model.xc],I,winty,wintx);
        else
            [xxi] = [Yp_reprojected(count) + calib_data.ocam_model.yc ;Xp_reprojected(count) + calib_data.ocam_model.xc];
        end;
        calib_data.Yp_abs(count,1,kk) = xxi(1);
        calib_data.Xp_abs(count,1,kk) = xxi(2);
    end;
end;
fprintf(1,'Corners recomputed \nDone');
