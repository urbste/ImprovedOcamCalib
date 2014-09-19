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
function findcenter(calib_data)

if isempty(calib_data.ima_proc) | isempty(calib_data.Xp_abs)
    fprintf(1,'\nNo corner data available. Extract grid corners before calibrating.\n\n');
    return;
end


fprintf(1,'\nComputing center coordinates.\n\n');

if isempty(calib_data.taylor_order),
    calib_data.taylor_order = calib_data.taylor_order_default;
end

pxc=calib_data.ocam_model.xc;
pyc=calib_data.ocam_model.yc;
width=calib_data.ocam_model.width;
height=calib_data.ocam_model.height;
regwidth=(width/2);
regheight=(height/2);
yceil=5;
xceil=5;

xregstart=pxc-(regheight/2);
xregstop= pxc+(regheight/2);
yregstart=pyc-(regwidth/2);
yregstop= pyc+(regwidth/2);
fprintf(1,'Iteration ');
for glc=1:9
    [yreg,xreg]=meshgrid(yregstart:(yregstop-yregstart)/yceil:yregstop+1/yceil, xregstart:(xregstop-xregstart)/xceil:xregstop+1/xceil);
    ic_proc=[ 1:size(xreg,1) ];
    jc_proc=[ 1:size(xreg,2) ];    
    MSEA=inf*ones(size(xreg));
    for ic=ic_proc
        for jc=jc_proc
            calib_data.ocam_model.xc=xreg(ic,jc);
            calib_data.ocam_model.yc=yreg(ic,jc);
%            hold on; plot(yc,xc,'r.');
            
            [calib_data.RRfin,calib_data.ocam_model.ss]=calibrate(calib_data.Xt, calib_data.Yt, calib_data.Xp_abs, calib_data.Yp_abs, calib_data.ocam_model.xc, calib_data.ocam_model.yc, calib_data.taylor_order, calib_data.ima_proc);
            if calib_data.RRfin==0
                MSEA(ic,jc)=inf;
                continue;
            end
            MSE=reprojectpoints_fun(calib_data.Xt, calib_data.Yt, calib_data.Xp_abs, calib_data.Yp_abs, calib_data.ocam_model.xc, calib_data.ocam_model.yc, calib_data.RRfin, calib_data.ocam_model.ss, calib_data.ima_proc, calib_data.ocam_model.width, calib_data.ocam_model.height);

%obrand_start 
%speedup removed to compensate for calibration errors
%            if ic>1 & jc>1
%                if MSE>MSEA(ic-1,jc)
%                    jc_proc(find(jc_proc==jc))=inf;
%                    jc_proc=sort(jc_proc);
%                    jc_proc=jc_proc(1:end-1);
%                    continue;
%                elseif MSE>MSEA(ic,jc-1)
%                    break;
%                elseif isnan(MSE)
%                    break;
%                end
%            end
%            MSEA(ic,jc)=MSE;
%obrand_replacement
	if ~isnan(MSE)
            MSEA(ic,jc)=MSE;
        end
%obrand_end
        end
    end
%    drawnow;
    indMSE=find(min(MSEA(:))==MSEA);
    calib_data.ocam_model.xc=xreg(indMSE(1));
    calib_data.ocam_model.yc=yreg(indMSE(1));
    dx_reg=abs((xregstop-xregstart)/xceil);
    dy_reg=abs((yregstop-yregstart)/yceil);
    xregstart=calib_data.ocam_model.xc-dx_reg;
    xregstop =calib_data.ocam_model.xc+dx_reg;
    yregstart=calib_data.ocam_model.yc-dy_reg;
    yregstop =calib_data.ocam_model.yc+dy_reg;
    fprintf(1,'%d...',glc);
end

fprintf(1,'\n');
[calib_data.RRfin,calib_data.ocam_model.ss]=calibrate(calib_data.Xt, calib_data.Yt, calib_data.Xp_abs, calib_data.Yp_abs, calib_data.ocam_model.xc, calib_data.ocam_model.yc, calib_data.taylor_order, calib_data.ima_proc);
reprojectpoints(calib_data);
xc = calib_data.ocam_model.xc;
yc = calib_data.ocam_model.yc;
xc
yc

% reproject
M=[calib_data.Xt,calib_data.Yt,zeros(size(calib_data.Xt))];
[allerr,rms] = reprojectpoints_advUrban(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);
calib_data.rmsAfterCenter = rms;


calib_data.calibrated = 1; %This flag is 1 when the camera has been calibrated

