function mosaic(calib_data)
if isempty(calib_data.I),
   active_images_save = calib_data.active_images;
   ima_read_calib(calib_data);
   calib_data.active_images = active_images_save;
   check_active_images(calib_data);
end;

check_active_images(calib_data);

if isempty(calib_data.ind_read),
   return;
end;


n_col = floor(sqrt(calib_data.n_ima*calib_data.ocam_model.width/calib_data.ocam_model.height));

n_row = ceil(calib_data.n_ima / n_col);


ker2 = 1;
for ii  = 1:n_col,
   ker2 = conv(ker2,[1/4 1/2 1/4]);
end;


II = calib_data.I{1}(1:n_col:end,1:n_col:end);

[ny2,nx2] = size(II);



kk_c = 1;

II_mosaic = [];

for jj = 1:n_row,
    
    
    II_row = [];
    
    for ii = 1:n_col,
        
        if ((kk_c <= calib_data.n_ima) & ~isempty(calib_data.I{kk_c})),
            
            if calib_data.active_images(kk_c),
                I = calib_data.I{kk_c};
                %I = conv2(conv2(I,ker2,'same'),ker2','same'); % anti-aliasing
                I = I(1:n_col:end,1:n_col:end);
            else
                I = zeros(ny2,nx2);
            end;
            
        else
            
            I = zeros(ny2,nx2);
            
        end;
        
        
        
        II_row = [II_row I];
        
        if ii ~= n_col,
            
            II_row = [II_row zeros(ny2,3)];
            
        end;
        
        
        kk_c = kk_c + 1;
        
    end;
    
    nn2 = size(II_row,2);
    
    if jj ~= n_row,
        II_row = [II_row; zeros(3,nn2)];
    end;
    
    II_mosaic = [II_mosaic ; II_row];
    
end;

figure(2);
image(II_mosaic);
colormap(gray(256));
title('Calibration images');
set(gca,'Xtick',[])
set(gca,'Ytick',[])
axis('image');
end


