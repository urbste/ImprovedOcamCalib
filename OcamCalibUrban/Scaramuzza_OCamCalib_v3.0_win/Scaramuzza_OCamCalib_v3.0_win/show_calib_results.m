function show_calib_results(calib_data)

if isempty(calib_data.n_ima) | calib_data.calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;

M = [calib_data.Xt,calib_data.Yt,zeros(size(calib_data.Xt))];

reprojectpoints_adv(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);

ss = calib_data.ocam_model.ss;
ss

xc = calib_data.ocam_model.xc;
xc

yc = calib_data.ocam_model.yc;
yc


figure(3);
set(3,'Name','Calibration results','NumberTitle','off');
subplot(2,1,1);
plot(0:floor(calib_data.ocam_model.width/2),polyval([calib_data.ocam_model.ss(end:-1:1)],[0:floor(calib_data.ocam_model.width/2)])); grid on; axis equal; 
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('f(rho)');
title('Forward projection function');
%
subplot(2,1,2);
plot(0:floor(calib_data.ocam_model.width/2),180/pi*atan2(0:floor(calib_data.ocam_model.width/2),-polyval([calib_data.ocam_model.ss(end:-1:1)],[0:floor(calib_data.ocam_model.width/2)]))-90); grid on;
xlabel('Distance ''rho'' from the image center in pixels');
ylabel('Degrees');
title('Angle of optical ray as a function of distance from circle center (pixels)');

