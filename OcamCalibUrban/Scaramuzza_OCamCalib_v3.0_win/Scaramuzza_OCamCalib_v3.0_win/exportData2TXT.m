function exportData2TXT(calib_data)

if isempty(calib_data.n_ima) | calib_data.calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;

fprintf(1,'Exporting ocam_model to "calib_results.txt"\n');
export_data(calib_data.ocam_model);
fprintf(1,'done\n');