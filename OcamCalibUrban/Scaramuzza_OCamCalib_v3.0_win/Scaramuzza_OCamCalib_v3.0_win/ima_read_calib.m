function ima_read_calib(calib_data)

if isempty(calib_data.calib_name)|isempty(calib_data.format_image),
   data_calib(calib_data);
   return;
end;

[~,image_numbers,type_numbering,N_slots] = check_directory(calib_data);

if isempty(calib_data.n_ima),
   data_calib(calib_data);
   return;
end;

check_active_images(calib_data);


images_read = calib_data.active_images;


if ~isempty(image_numbers),
   first_num = image_numbers(1);
end;


% Just to fix a minor bug:
if ~exist('first_num'),
   first_num = image_numbers(1);
end;


image_numbers = first_num:calib_data.n_ima-1+first_num;

calib_data.no_image_file = 0;

i = 1;
calib_data.L = {};
if isempty(calib_data.I)
    calib_data.I = cell(calib_data.n_ima,1);
end

while (i <= calib_data.n_ima), % & (~no_image_file),
   
   if calib_data.active_images(i),
   
   	%fprintf(1,'Loading image %d...\n',i);
   
   	if ~type_numbering,   
      	number_ext =  num2str(image_numbers(i));
   	else
      	number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(i));
   	end;
   	
      ima_name = [calib_data.calib_name  number_ext '.' calib_data.format_image];
      calib_data.L{i} = ima_name;
      
      if i == calib_data.ind_active(1),
         fprintf(1,'Loading image ');
      end;
      
      if exist(ima_name),
         
         fprintf(1,'%d...',i);
         
         if calib_data.format_image(1) == 'p',
            if calib_data.format_image(2) == 'p',
               Ii = double(loadppm(ima_name));
            else
               Ii = double(loadpgm(ima_name));
            end;
         else
            if calib_data.format_image(1) == 'r',
               Ii = readras(ima_name);
            else
               Ii = double(imread(ima_name));
            end;
         end;

   		if size(Ii,3)>1,
            Ii = 0.299 * Ii(:,:,1) + 0.5870 * Ii(:,:,2) + 0.114 * Ii(:,:,3);
   		end;
        
        if ~strcmp('jpg',calib_data.format_image) %If image format is not JPG then converts to JPG! Needed only for OpenCV functions!
            imwrite(uint8(Ii), [calib_data.calib_name  number_ext '.' 'jpg'], 'jpg','Quality',100); %converts to JPG
            calib_data.L{i} = [calib_data.calib_name  number_ext '.' 'jpg'];
        end
      	
   		eval(['I_' num2str(i) ' = Ii;']);
        calib_data.I{i} = Ii;
      else
         
         %fprintf(1,'%d...no image...',i);
	 
	 images_read(i) = 0;
	 
	 %no_image_file = 1;
	 
      end;
      
   end;
   
   i = i+1;   
   
end;


calib_data.ind_read = find(images_read);




if isempty(calib_data.ind_read),
   
   fprintf(1,'\nWARNING! No image were read\n');
   
   calib_data.no_image_file = 1;
   
   
else
   

   %fprintf(1,'\nWARNING! Every exsisting image in the directory is set active.\n');

   
   if calib_data.no_image_file,
      
        %fprintf(1,'WARNING! Some images were not read properly\n');
     
   end;
     
   
   fprintf(1,'\n');
   
   [Hcal,Wcal] = size(I_1); 	% size of the calibration image
   
   [ny,nx] = size(I_1);
   calib_data.ocam_model.width=nx;
   calib_data.ocam_model.height=ny;
   clickname = [];
   
   calib_data.map = gray(256);
   

	disp('done');
	%click_calib;

end;

if isempty(calib_data.map), calib_data.map = gray(256); end;

calib_data.active_images = images_read;
end

