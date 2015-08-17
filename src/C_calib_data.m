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
% filename: C_calib_data.m
% Code was added to 
% save statistical relevant variables

classdef C_calib_data < handle
    %CALIB_DATA Stores image and calibration data used by the calibration toolbox
    
    properties
        
        % Image data      
        calib_name          % Base image name
        format_image        % Image format
        L                   % Image file names
        
        map                 % Colormap for displaying images

        I                   % Calibration images
        n_ima               % Number of images read
        active_images       % Vector indicating images used
        ind_active          % Indices of images used
        ind_read            % Indices of images read
        ima_proc            % Images being processed
        
        % Calibration model        
        ocam_model =...
            struct( 'ss',[],... % Coefficients of polynomial
                    'xc',[],... % x-coordinate of image center
                    'yc',[],... % y-coordinate of image center
                    'c',[],'d',[],'e',[],... % Affine transformation parameters
                    'width',[],...  % Image width
                    'height',[])    % Image height

        RRfin               % Extrinsic parameters of checkerboards
      
        taylor_order        % Order of the polynomial
        taylor_order_default
        
        dX                  % Width of a square on checkerboard (mm)
        dY                  % Height of a square on checkerboard (mm)
        n_sq_x              % Number of squares in x-direction
        n_sq_y              % Number of squares in y-direction
        Xt                  % Checkerboard corner coordinates (mm)
        Yt
        Xp_abs              % Checkerboard corner coordinates (px)
        Yp_abs 
        Xp_abss             % Checkerboard sub pixel corner coordinates (px)
        Yp_abss
       
        wintx               % Size of corner search window for assisted
        winty               % manual corner selection
        
        % Flags
        no_image_file       % Indicates missing image files
        calibrated          % Indicates calibrated ocam_model
        %% ================ 
        %  added code 
        %
        % errors 
        % overall errors
        errMean
        errStd
        mse
        rms
        runtime
        rmsAfterCenter
        
        statEO    ={struct('stdEO',[], 'varEO',[], 'sg0',[], 'Exx',[])};
        statIO    ={struct('stdIO',[], 'varIO',[], 'sg0',[], 'Exx',[])};
        optimized = false;
        
        % weights from robust optimization
        weights
        %% ================ 
    end
    
    methods
        
       
    end
    
end

