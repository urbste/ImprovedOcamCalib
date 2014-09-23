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


Improved Calibration Toolbox by Steffen Urban, September 2014

================================
Installation instruction
================================
1. Download and extract the original toolbox Scaramuzza_OCamCalib_v3.0 from
   https://sites.google.com/site/scarabotix/ocamcalib-toolbox/ocamcalib-toolbox-download-page
  (link worked september 2014)
  
2. Extract "src/" to the folder with all source files of OcamCalib
   If asked to replace C_calib_data.m and optimizefunction.m click yes.
   The first file contains additional varibles for statistics.
   The second file contains additional code lines to save statistics but
   is actually not used by the improved toolbox. It's only for comparison purposes.
 
If you want to run the test data sets:
3. Extract "FisheyeDataSets/" to the same folder (contains 3 image data sets and test scripts))

================================
Calibration and Tests
================================
How to calibrate a single camera:
---------------------------------
 1. Run ocam_calibUrban.m  !!! (instead of ocam_calib)
 2. press (in that order)
      -read images
      -extract corners
      -calibration 
      -non-linear refinement (LM least squares) 
       or robust non-linear refinement (LM least squares with Huber) 
---------------------------------

How to calibrate all test images/cameras at once
---------------------------------  
1. Download FisheyeDatSets.zip
2. Download SampleImages.zip from https://sites.google.com/site/scarabotix/ocamcalib-toolbox/ocamcalib-toolbox-download-page
3. Run Step1_perform_test_calibrations.m  (this takes quite a while)
   (If you want to run it fully automatic with polynomial order 4, got to
    calibration.m and comment out line 31)
4. Compare results with Step2_compare_results.m
---------------------------------

all image files should be .jpg . Otherwise you have to change the test script
Step1_perform_test_calibrations.m