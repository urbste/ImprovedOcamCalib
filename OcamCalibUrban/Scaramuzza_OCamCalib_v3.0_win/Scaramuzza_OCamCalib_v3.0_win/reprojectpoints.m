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
function reprojectpoints(calib_data)
m=[];
xx=[];
err=[];
stderr=[];
rhos=[];
num_points=size(calib_data.Xp_abs,1);
MSE=0;
counterr=0;
for i=calib_data.ima_proc
    counterr=counterr+1;
    xx=calib_data.RRfin(:,:,i)*[calib_data.Xt';calib_data.Yt';ones(size(calib_data.Xt'))];
    [Xp_reprojected,Yp_reprojected]=omni3d2pixel(calib_data.ocam_model.ss,xx,calib_data.ocam_model.width, calib_data.ocam_model.height); %convert 3D coordinates in 2D pixel coordinates    
    stt= sqrt( (calib_data.Xp_abs(:,:,i)-calib_data.ocam_model.xc-Xp_reprojected').^2 + (calib_data.Yp_abs(:,:,i)-calib_data.ocam_model.yc-Yp_reprojected').^2 ) ;
    err(counterr)=(mean(stt));
    stderr(counterr)=std(stt);
    MSE=MSE+sum( (  calib_data.Xp_abs(:,:,i)-calib_data.ocam_model.xc-Xp_reprojected').^2 + (calib_data.Yp_abs(:,:,i)-calib_data.ocam_model.yc-Yp_reprojected').^2 );
end

fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
for i=1:length(err)
    fprintf(' %3.2f %c %3.2f\n',err(i),177,stderr(i));
end
%err'
fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);