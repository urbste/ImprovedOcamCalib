function check_active_images(calib_data)

if calib_data.n_ima ~= 0,
    
    if isempty(calib_data.active_images),
        calib_data.active_images = ones(1,calib_data.n_ima);
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
    
    if prod(double(calib_data.active_images == 0)),
        disp('Error: There is no active image. Run Add/Suppress images to add images');
        return;
    end;

end;
end
