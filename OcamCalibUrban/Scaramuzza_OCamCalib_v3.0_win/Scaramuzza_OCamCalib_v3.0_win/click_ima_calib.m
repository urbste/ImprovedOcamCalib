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
function click_ima_calib(kk,use_corner_find,calib_data)
fprintf(1,'\nProcessing image %d...\n',kk);

I = calib_data.I{kk};
% if ~(size(calib_data.wintx_,2)<kk),
%     
%     wintxkk = calib_data.wintx_{kk};
%     
%     if ~isempty(wintxkk) & ~isnan(wintxkk),
%         
%         calib_data.wintx = calib_data.wintx_{kk};
%         calib_data.winty = calib_data.winty_{kk};
%         
%     end;
% end;

if use_corner_find
    fprintf(1,'Using (wintx,winty)=(%d,%d) - Window size = %dx%d\n',calib_data.wintx,calib_data.winty,2*calib_data.wintx+1,2*calib_data.winty+1);
    %fprintf(1,'Note: To reset the window size, clear wintx and winty and run ''Extract grid corners'' again\n');
end


figure(2);
image(I);
colormap(calib_data.map);
set(2,'color',[1 1 1]);

title(['Press ENTER and then Click on the extreme corners of the rectangular pattern (first corner = origin)... Image ' num2str(kk)]);

disp('Press ENTER and then Click on the extreme corners of the rectangular complete pattern (the first clicked corner is the origin)...');
pause;
x= [];y = [];
figure(2); hold on;
for count = 1:(calib_data.n_sq_x+1)*(calib_data.n_sq_y+1),
    [xi,yi] = ginput3(1);
    if use_corner_find
        [xxi] = cornerfinder([xi;yi],I,calib_data.winty,calib_data.wintx);
        xi = xxi(1);
        yi = xxi(2);
    end
    figure(2);
    plot(xi,yi,'+','color',[ 1.000 0.314 0.510 ],'linewidth',2);
    x = [x;xi];
    y = [y;yi];
    drawnow;
end;
hold off;
%Xc = cornerfinder([x';y'],I,winty,wintx);
calib_data.Yp_abs(:,:,kk)=x;
calib_data.Xp_abs(:,:,kk)=y;




