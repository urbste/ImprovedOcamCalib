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
function analyse_error(calib_data)

if isempty(calib_data.n_ima) | calib_data.calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;

figure(5);
set(5,'Name','Analyse error','NumberTitle','off');
zoom on;

colors = 'brgkcm';
m=[];
xx=[];
err=[];
stderr=[];
rhos=[];
num_points=size(calib_data.Xp_abs,1);
MSE=0;
count=0;
if isempty(calib_data.ocam_model.c) & isempty(calib_data.ocam_model.d) & isempty(calib_data.ocam_model.e)
   calib_data.ocam_model.c=1;
    calib_data.ocam_model.d=0;
    calib_data.ocam_model.e=0;
end
for i=calib_data.ima_proc
    count=count+1;
    xx=calib_data.RRfin(:,:,i)*[calib_data.Xt';calib_data.Yt';ones(size(calib_data.Xt'))];
    [xp1,yp1]=omni3d2pixel(calib_data.ocam_model.ss,xx,calib_data.ocam_model.width,calib_data.ocam_model.height); %convert 3D coordinates in 2D pixel coordinates    
    xp=xp1*calib_data.ocam_model.c + yp1*calib_data.ocam_model.d + calib_data.ocam_model.xc;
    yp=xp1*calib_data.ocam_model.e + yp1 + calib_data.ocam_model.yc;    
    sqerr= (calib_data.Xp_abs(:,:,i)-xp').^2+(calib_data.Yp_abs(:,:,i)-yp').^2;
    err(count)=mean(sqrt(sqerr));
    stderr(count)=std(sqrt(sqerr));
    MSE=MSE+sum(sqerr);
    plot(calib_data.Xp_abs(:,:,i)-xp', calib_data.Yp_abs(:,:,i)-yp',[num2str(colors(rem(i-1,6)+1)) '+']); hold on;
end
hold off;
grid on;

fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
for i=1:length(err)
    fprintf(' %3.2f %c %3.2f\n',err(i),177,stderr(i));
end

fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);
ss = calib_data.ocam_model.ss;
ss
