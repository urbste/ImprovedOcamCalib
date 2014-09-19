if ~exist('Omni_Calib_Results.mat'),
   fprintf(1,'\nCalibration file Omni_Calib_Results.mat not found!\n');
   return;
end;

fprintf(1,'\nLoading calibration results from Omni_Calib_Results.mat\n');

clear calib_data;
load Omni_Calib_Results.mat

fprintf(1,'done\n');
