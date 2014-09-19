function export_data(ocam_model)

if ~isfield(ocam_model,'invpol') 
    width = ocam_model.width;
    height = ocam_model.height;
    %The ocam_model does not contain the inverse polynomial pol
    ocam_model.invpol = findinvpoly(ocam_model.ss,sqrt((width/2)^2+(height/2)^2));
end

fid = fopen('calib_results.txt', 'w');

fprintf(fid,'#polynomial coefficients for the DIRECT mapping function (ocam_model.ss in MATLAB). These are used by cam2world\n\n');

fprintf(fid,'%d ',length(ocam_model.ss)); %write number of coefficients
for i = 1:length(ocam_model.ss)
    fprintf(fid,'%e ',ocam_model.ss(i));
end

fprintf(fid,'\n\n');

fprintf(fid,'#polynomial coefficients for the inverse mapping function (ocam_model.invpol in MATLAB). These are used by world2cam\n\n');

fprintf(fid,'%d ',length(ocam_model.invpol)); %write number of coefficients
for i = 1:length(ocam_model.invpol)
    fprintf(fid,'%f ',ocam_model.invpol(end-i+1));
end

fprintf(fid,'\n\n');

fprintf(fid,'#center: "row" and "column", starting from 0 (C convention)\n\n');

fprintf(fid,'%f %f\n\n',ocam_model.xc-1, ocam_model.yc-1);

fprintf(fid,'#affine parameters "c", "d", "e"\n\n');

fprintf(fid,'%f %f %f\n\n',ocam_model.c, ocam_model.d, ocam_model.e);

fprintf(fid,'#image size: "height" and "width"\n\n');

fprintf(fid,'%d %d\n\n',ocam_model.height, ocam_model.width);

fclose(fid);