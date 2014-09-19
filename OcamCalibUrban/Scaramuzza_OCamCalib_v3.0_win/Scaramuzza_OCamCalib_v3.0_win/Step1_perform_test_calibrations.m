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
clear all
close all

% test cases: [use_urban, use_subpixel, robust]
test_cases = {[false,false,false],[false,true,false],[true,false,false],[true,true,false],[true,true,true]};
% test_cases = {[true,true,true]};
nr_tests = size(test_cases,2);

% filenames
base_names = {'Fisheye1_', 'Fisheye2_', 'GOPR', ...   % own data sets
              'MiniOmni', 'VMRImage', 'Ladybug', 'KaidanOmni'};   % data sets from ocam_calib
% base_names = {'MiniOmni'};   % data sets from ocam_calib 

% base_names = {'MiniOmni'};   % data sets from ocam_calib  

calibDataMei = load('imgParaPts.mat');  
% vmrPts = load('VMRImagePts.mat');  
% calibDataMei = load('MEIImages2DPts.mat');  
% goproPoints = load('GOPROPOINTS.mat');  
% ladyPoints = load('LadyBugPts.mat'); 

% nr of squares
squares = {[5,7],[5,7],[5,7], ...
           [6,10], [5,6], [4,7],[6,10]}; 
% squares = {[6,10]};        
% size of squares in [mm]
sizes = {32.5,117,117,...
         30,30,30,30};   
%  sizes = {30};  
% change polynomial degree if necessary
polDegree = {4,4,4,4,...
             4,4,4}; 
% polDegree = {4};          
corners_already_extracted = 1;
% wintx = 5; winty = 5;
% minInfo.taux =  1.0000e-03;
% minInfo.nu = 2;
% minInfo.MaxIterBiased = 60;
% minInfo.MaxIterExtr = 20;
% minInfo.recompute_extrinsic_biased = 1;
% minInfo.freqRecompExtrBiased = 4;
% minInfo.MaxIterUnbiased = 60;
% minInfo.recompute_extrinsic_unbiased = 1;
% minInfo.freqRecompExtrUnbiased = 4;

% for i=1:size(test_cases,2)  
%     path = sprintf('CalibData_NEW%i.mat', i);
%     calib_data{i} = load(path);
% end

%% this loop automatically calls all relevant calibration functions
% loop over test scenarios
for b=1:size(test_cases,2)
    % loop over data sets
    for idx=1:size(base_names,2)
        tic
        % set bool variables
        use_urban    = test_cases{b}(1);
        use_subpixel = test_cases{b}(2);
        
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
        % calc X
%         if idx == 1
%                 calib_data{idx}.Xt = calibDataMei.gridInfo.X{1}(1,:)';
%                 calib_data{idx}.Yt = calibDataMei.gridInfo.X{1}(2,:)';           
%         else
            for i=0:calib_data{idx}.n_sq_x
                for j=0:calib_data{idx}.n_sq_y
                    calib_data{idx}.Yt = [calib_data{idx}.Yt;j*calib_data{idx}.dY];
                    calib_data{idx}.Xt = [calib_data{idx}.Xt;i*calib_data{idx}.dX];
                end
            end    
%         end
        
        ima_numbers = 1:calib_data{idx}.n_ima;  
        count = 0;
        % extract corners
        for kk = ima_numbers
            
            % MEIs test
%             if idx == 1
%                 calib_data{idx}.Xp_abs(:,:,kk) = calibDataMei.gridInfo.x{kk}(1,:)';
%                 calib_data{idx}.Yp_abs(:,:,kk) = calibDataMei.gridInfo.x{kk}(2,:)';
%                 calib_data{idx}.Yt = calibDataMei.gridInfo.X{kk}(2,:)';
%                 calib_data{idx}.Xt = calibDataMei.gridInfo.X{kk}(1,:)';
%                 calib_data{idx}.ima_proc = sort([calib_data{idx}.ima_proc, kk]);
%                 calib_data{idx}.active_images(kk) = 1;
%                 calib_data{idx}.I{kk} = 1;
%             else 

                if (~use_subpixel)
                    [callBack, x, y]  = get_checkerboard_corners(kk,use_subpixel,calib_data{idx});
                else
                    [callBack, x, y]  = get_checkerboard_cornersUrban(kk,use_subpixel,calib_data{idx});
                end
                if callBack == 1
                    count = count + 1;
                    calib_data{idx}.Xp_abs(:,:,kk) = x;
                    calib_data{idx}.Yp_abs(:,:,kk) = y;
                    calib_data{idx}.active_images(kk) = 1;
                    calib_data{idx}.ima_proc = sort([calib_data{idx}.ima_proc, kk]);
                end
                calib_data{idx}.I{kk} = 1;
            
%             end
           
        end
        
%          check_active_images(calib_data{idx});   
         % perform linear calibration
         % this step is equal to all methods
         calibration(calib_data{idx});
    
         if (use_urban)             
%              findcenterUrban(calib_data{idx});
%              optimizefunction(calib_data{idx});
             % bundle adjustment, can be robust
             bundleAdjustmentUrban(calib_data{idx}, test_cases{b}(3));
         else
             % ocam_calib method
             findcenter(calib_data{idx});
             optimizefunction(calib_data{idx});
         end
        calib_data{idx}.runtime = toc;
%     % save calibration results     


%     path = sprintf('CalibDataPP%i.mat', b);
%     save(path,'calib_data');


%% mei's toolbox
    % image stuff
%     
%     format_image = 'jpg';
%     [n_ima,image_numbers,active_images,N_slots,type_numbering, ...
%         Nima_valid] = check_directory1(base_names{idx},format_image);
%     images.n_ima = n_ima;
%     images.image_numbers = image_numbers;
%     images.active_images = active_images;
%     images.N_slots = N_slots;
%     images.type_numbering = type_numbering;
% 
%     images.calib_name = base_names{idx};
%     images.format_image = format_image;
%     [I,active_images,ind_read] = ima_read_calib1(images); % may be launched from the toolbox itself
%     images.I = I;
%     images.active_images = active_images;
%     images.nx = size(images.I{1},2);
%     images.ny = size(images.I{1},1);
%     
%     
%     % param estimate 
%     % if abfrage für tests
%     paramEst.est_xi = 1;
%     paramEst.xi = 1;
%     paramEst.dioptric = 1;
%     
%     [gen_KK_est, borderInfo] = border_estimate(images,paramEst);
%     paramEst = go_omni_calib_optim_iter(minInfo,images,...
%                                         gen_KK_est,gridInfo,paramEst);
    
    end
    path = sprintf('CalibData_ALL%i.mat', b);
    save(path,'calib_data');
end



