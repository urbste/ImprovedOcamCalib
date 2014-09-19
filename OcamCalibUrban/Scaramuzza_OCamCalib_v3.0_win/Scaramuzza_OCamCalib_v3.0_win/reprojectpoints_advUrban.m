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
% this is a modified file from
% Davide Scaramuzzas Toolbox OcamCalib
% filename: reprojectpoints_adv.m
% Code was added to 
% weight the SSRE if robust bundle adjustment is performed

function [allerr, rms] = reprojectpoints_advUrban(ocam_model, RRfin, ima_proc, Xp_abs, Yp_abs, M)

M(:,3)=1;

allerr = [];
off = 1;
for i=ima_proc
    Mc=RRfin(:,:,i)*M';
    m = world2cam(Mc, ocam_model);
    xp = m(1,:);
    yp = m(2,:);    
        
%     nrp = size(Xp_abs(:,:,i),1);
    % get weights 
%     wx = weights(off:2:(nrp*2+off-1));
%     wy = weights(off+1:2:(nrp*2+off));   
    % respect the weights, otherwise the MSE is obviously larger      
%     allerr = [allerr
%              ( wx.*(Xp_abs(:,:,i)-xp') ) 
%              ( wy.*(Yp_abs(:,:,i)-yp') )];
    allerr = [allerr
             (Xp_abs(:,:,i)-xp')
             (Yp_abs(:,:,i)-yp')];
%     off = off+nrp*2;
end

rms = sqrt( sum(allerr.^2) / length(allerr) );

% fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
% for i=1:length(err)
%     fprintf(' %3.2f %c %3.2f\n',err(i),177,stderr(i));
% end
% 
% fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
% fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);