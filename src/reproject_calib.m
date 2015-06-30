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

%%%%%%%%%%%%%%%%%%%% REPROJECT ON THE IMAGES %%%%%%%%%%%%%%%%%%%%%%%%
function reproject_calib(calib_data)

if isempty(calib_data.n_ima) | calib_data.calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;

%if isempty(calib_data.no_image),
%   no_image = 0;
%end;

if isempty(calib_data.ocam_model.width)|isempty(calib_data.ocam_model.height),
   fprintf(1,'WARNING: No image size (width,height) available. Setting width=640 and height=480\n');
   calib_data.ocam_model.width = 640;
   calib_data.ocam_model.height = 480;
end;


check_active_images(calib_data);


% Color code for each image:

colors = 'brgkcm';

% Reproject the patterns on the images, and compute the pixel errors:

% Reload the images if necessary
if calib_data.n_ima ~= 0,
if isempty(calib_data.ocam_model.ss),
   fprintf(1,'Need to calibrate before showing image reprojection. Maybe need to load Calib_Results.mat file.\n');
   return;
end;
end;

if calib_data.n_ima ~= 0,
if false,
	if isempty(calib_data.ind_active(1)) || size(calib_data.I)<calib_data.ind_active(1) || isempty(calib_data.I{calib_data.ind_active(1)}),
	   n_ima_save = calib_data.n_ima;
	   active_images_save = calib_data.active_images;
	   ima_read_calib(calib_data);
	   calib_data.n_ima = n_ima_save;
	   calib_data.active_images = active_images_save;
	   check_active_images;
   	if calib_data.no_image_file,
	   fprintf(1,'WARNING: Do not show the original images\n'); %return;
   	end;
   end;
else
   calib_data.no_image_file = 1;
end;
end;


if (isempty(calib_data.ocam_model.c) || isempty(calib_data.ocam_model.d) || isempty(calib_data.ocam_model.e))
    calib_data.ocam_model.c=1;
    calib_data.ocam_model.d=0;
    calib_data.ocam_model.e=0;
end

for kk = calib_data.ima_proc,            
    
            if (size(calib_data.I,1) >= kk) && ~isempty(calib_data.I{kk}),
                I = calib_data.I{kk};
            else
                I = 255*ones(calib_data.ocam_model.height,calib_data.ocam_model.width);
            end;

            xx = calib_data.RRfin(:,:,kk)*[calib_data.Xt';calib_data.Yt';ones(size(calib_data.Xt'))];       
            m = world2cam(xx, calib_data.ocam_model);
            xp = m(1,:);
            yp = m(2,:);
            figure(5+kk);
            image(I); hold on;
            colormap(gray(256));
            hold on;
            title(['Image ' num2str(kk) ' - Image points (+) and reprojected grid points (o)']);            
            plot(calib_data.Yp_abs(:,:,kk), calib_data.Xp_abs(:,:,kk),'r+','markersize',9, 'LineWidth', 2.5);             
            plot(yp, xp, [num2str(colors(rem(kk-1,6)+1)) 'o'],'markersize',9, 'LineWidth', 2.5);
            plot(calib_data.ocam_model.yc,calib_data.ocam_model.xc,'ro','markersize',9); %plot the image center
            axis([1 calib_data.ocam_model.width 1 calib_data.ocam_model.height]);
            drawnow;
            set(5+kk,'color',[1 1 1]);
            set(5+kk,'Name',['Image ' num2str(kk)],'NumberTitle','off');
            draw_axes(calib_data.Xp_abs(:,:,kk), calib_data.Yp_abs(:,:,kk),calib_data.n_sq_y); %draws axes and origin on the image
            hold off;
            zoom on;
            
end;
        
        
            