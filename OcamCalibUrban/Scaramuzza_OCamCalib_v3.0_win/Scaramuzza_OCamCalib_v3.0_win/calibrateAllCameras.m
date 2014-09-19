%     Steffen Urban email: steffen.urban@kit.edu
%     Copyright (C) 2014  Steffen Urban
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% clear all
% close all

% test cases: [use_urban, use_subpixel, robust]

% filenames
base_names = {'imgLeft','imgRight','imgBack' };   % data sets from ocam_calib

% nr of squares
squares = {[5,7],[5,7],[5,7]}; 
       
% size of squares in [mm]
sizes = {117,117,117};                      
% change polynomial degree if necessary
polDegree = {4,4,4}; 
         
corners_already_extracted = 0;

% loop over data sets
for idx=1:size(base_names,2)

    % set up calibration relevant variables
    calib_data{idx} = C_calib_data;
    calib_data{idx}.format_image = 'jpg'; 
    calib_data{idx}.calib_name = base_names{idx};   
    [Nima_valid] = check_directory(calib_data{idx});
    ima_read_calib(calib_data{idx}); 
    calib_data{idx}.calibrated = 0;
    check_active_images(calib_data{idx});
    calib_data{idx}.map = gray(256);
    calib_data{idx}.taylor_order = polDegree{idx};
    calib_data{idx}.taylor_order_default = polDegree{idx};  
    use_video_mode = 1;
    use_corner_find = 0;    
    calib_data{idx}.Xt=[];
    calib_data{idx}.Yt=[];
    % initial values for O_c
    calib_data{idx}.ocam_model.xc = round(calib_data{idx}.ocam_model.height/2);   
    calib_data{idx}.ocam_model.yc = round(calib_data{idx}.ocam_model.width/2);   
    calib_data{idx}.dX = sizes{idx};
    calib_data{idx}.dY = sizes{idx};   
    calib_data{idx}.n_sq_x = squares{idx}(1);
    calib_data{idx}.n_sq_y = squares{idx}(2);   

    for i=0:calib_data{idx}.n_sq_x
        for j=0:calib_data{idx}.n_sq_y
            calib_data{idx}.Yt = [calib_data{idx}.Yt;j*calib_data{idx}.dY];
            calib_data{idx}.Xt = [calib_data{idx}.Xt;i*calib_data{idx}.dX];
        end
    end    

    ima_numbers = 1:calib_data{idx}.n_ima;  
    count = 0;
    % extract corners
    for kk = ima_numbers

            [callBack, x, y]  = get_checkerboard_cornersUrban(kk,1,calib_data{idx});
            if callBack == 1
                count = count + 1;
                calib_data{idx}.Xp_abs(:,:,kk) = x;
                calib_data{idx}.Yp_abs(:,:,kk) = y;
                calib_data{idx}.active_images(kk) = 1;
                calib_data{idx}.ima_proc = sort([calib_data{idx}.ima_proc, kk]);
            end
%             calib_data{idx}.I{kk} = 1;
    end
        
    % perform calibration   
    calibration(calib_data{idx});
    bundleAdjustmentUrban(calib_data{idx}, 1);
    
    for kk = ima_numbers
        calib_data{idx}.I{kk} = [];
    end
    % save calibration results
    
end

path = sprintf('CalibDataLeftRightBack1.mat');
save(path,'calib_data');
