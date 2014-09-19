function [ima_proc, Xp_abs, Yp_abs] = get_best_checkerboard_images(ima_numbers, I, n_sq_x, n_sq_y, use_corner_find)

count = 0;
for kk = ima_numbers
    
    [callBack, x, y]  = get_checkerboard_corners(I, kk, n_sq_x, n_sq_y, use_corner_find);
    
    if callBack > 0
        count = count + 1;
        ima_proc(count) = kk;
        Xp_abs(:,:,kk) = x;
        Yp_abs(:,:,kk) = y;
    end
end