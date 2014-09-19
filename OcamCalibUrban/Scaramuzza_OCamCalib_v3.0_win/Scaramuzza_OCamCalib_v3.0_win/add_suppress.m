function add_suppress(calib_data)

if isempty(calib_data.n_ima),
   fprintf(1,'No data to process.\n');
   return;
end;

if calib_data.n_ima == 0,
    fprintf(1,'No image data available\n');
    return;
end;

if isempty(calib_data.active_images),
	calib_data.active_images = ones(1,n_ima);
end;
n_act = length(calib_data.active_images);
if n_act < calib_data.n_ima,
   calib_data.active_images = [calib_data.active_images ones(1,calib_data.n_ima-n_act)];
else
   if n_act > calib_data.n_ima,
      calib_data.active_images = calib_data.active_images(1:calib_data.n_ima);
   end;
end;

calib_data.ind_active = find(calib_data.active_images);

% I did not call check_active_images, because I want to prevent a break
%check_active_images;


fprintf(1,'\nThis function is useful to select a subset of images to calibrate\n');

   fprintf(1,'\nThere are currently %d active images selected for calibration (out of %d):\n',length(calib_data.ind_active),calib_data.n_ima);
   
   if ~isempty(calib_data.ind_active),
      
      if length(calib_data.ind_active) > 2,
      
   		for ii = 1:length(calib_data.ind_active)-2,
      		
         	fprintf(1,'%d, ',calib_data.ind_active(ii));
         	
      	end;
      	
      	fprintf(1,'%d and %d.',calib_data.ind_active(end-1),calib_data.ind_active(end));
         
      else
         
         if length(calib_data.ind_active) == 2,
            
            fprintf(1,'%d and %d.',calib_data.ind_active(end-1),calib_data.ind_active(end));
            
         else
            
            fprintf(1,'%d.',calib_data.ind_active(end));
            
         end;
         
         
      end;
      
   end;
      
      
   fprintf(1,'\n');
   
   if length(calib_data.ind_active)==0,
      fprintf(1,'\nYou probably want to add images\n');
      choice = 1;
   else
      if length(calib_data.ind_active)==calib_data.n_ima,
         fprintf(1,'\nYou probably want to suppress images\n');
         choice = 0;
      else
         choice = 2;
      end;
   end;
   
   if (choice~=0) & (choice ~=1),
   	fprintf(1,'\nDo you want to suppress or add images from that list?\n');
   end;
   
while (choice~=0)&(choice~=1),
   choice = input('For suppressing images enter 0, for adding images enter 1 ([]=no change): ');
   if isempty(choice),
      fprintf(1,'No change applied to the list of active images.\n');
      return;
   end;
   if (choice~=0)&(choice~=1),
      disp('Bad entry. Try again.');
   end;
end;


if choice,
   
	ima_numbers = input('Number(s) of image(s) to add ([] = all images) = ');

if isempty(ima_numbers),
	   fprintf(1,'All %d images are now active\n',calib_data.n_ima);
   	calib_data.ima_proc = 1:calib_data.n_ima;
	else
   	calib_data.ima_proc = ima_numbers;
	end;
   
else
   
   
	ima_numbers = input('Number(s) of image(s) to suppress ([] = no image) = ');

	if isempty(ima_numbers),
      fprintf(1,'No image has been suppressed. No modication of the list of active images.\n',calib_data.n_ima);
   	calib_data.ima_proc = [];
	else
   	calib_data.ima_proc = ima_numbers;
	end;
   
end;

if ~isempty(calib_data.ima_proc),
   
   calib_data.active_images(calib_data.ima_proc) = choice * ones(1,length(calib_data.ima_proc));
   
end;


   check_active_images(calib_data);
   

   fprintf(1,'\nThere is now a total of %d active images for calibration:\n',length(calib_data.ind_active));
   
   if ~isempty(calib_data.ind_active),
      
      if length(calib_data.ind_active) > 2,
      
   		for ii = 1:length(calib_data.ind_active)-2,
      		
         	fprintf(1,'%d, ',calib_data.ind_active(ii));
         	
      	end;
      	
      	fprintf(1,'%d and %d.',calib_data.ind_active(end-1),calib_data.ind_active(end));
         
      else
         
         if length(calib_data.ind_active) == 2,
            
            fprintf(1,'%d and %d.',calib_data.ind_active(end-1),calib_data.ind_active(end));
            
         else
            
            fprintf(1,'%d.',calib_data.ind_active(end));
            
         end;
         
         
      end;
      
   end;
      
   calib_data.ima_proc = calib_data.ind_active;
   
   fprintf(1,'\n\nYou may now run ''Calibration'' to recalibrate based on this new set of images.\n');
   
   
   