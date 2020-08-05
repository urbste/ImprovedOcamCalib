# Improved OcamCalib

This repository contains addon files for Scaramuzzas OcamCalib Toolbox. 
More information about the addon can be found in the paper.
If you use the addons, consider citing it.

    @article{urban2015improved,
      title={Improved wide-angle, fisheye and omnidirectional camera calibration},
      author={Urban, Steffen and Leitloff, Jens and Hinz, Stefan},
      journal={ISPRS Journal of Photogrammetry and Remote Sensing},
      volume={108},
      pages={72--79},
      year={2015},
      publisher={Elsevier}
    }
    
## Installation instruction ##
1. Download and extract the original toolbox Scaramuzza_OCamCalib_v3.0 from
   Davide Scaramuzzas Homepage [Link](https://sites.google.com/site/scarabotix/ocamcalib-toolbox/ocamcalib-toolbox-download-page)
  (link worked june 2015)
2. Download this repository and copy the content of the src folder to the main
   directory of ocam_calib.
3. You should be asked to replace 
   C_calib_data.m and
   optimizefunction.m -> click yes.
   The first file contains additional variables for statistics.
   The second file contains additional code lines to save statistics but
   is actually not used by the improved toolbox.
 
If you want to run the test data sets, 
copy the images from "FisheyeDataSets/" to the same folder 
(contains 3 image data sets and test scripts)

## Calibration and Tests ##

### How to calibrate a single camera: ###
  1. Run ocam_calibUrban.m  !!! (instead of ocam_calib)
  2. press (in that order)
    * read names
    * extract grid corners
    * calibration 
    * non-linear refinement (LM least squares) 
      or robust non-linear refinement (LM least squares with Huber) 

### How to calibrate all test images/cameras at once  ###
1. If not done already, 
   copy the images from FisheyeDataSets to the ocam_calib folder 
2. Download SampleImages.zip from Davide Scaramuzzas Homepage [Link](https://sites.google.com/site/scarabotix/ocamcalib-toolbox/ocamcalib-toolbox-download-page)
3. Run Step1_perform_test_calibrations.m  (this takes quite a while)
   (If you want to run it fully automatic with polynomial order 4, go to
    calibration.m and comment out line 31)
4. Compare results with Step2_compare_results.m

all image files should be .jpg . Otherwise you have to change the test script
Step1_perform_test_calibrations.m
