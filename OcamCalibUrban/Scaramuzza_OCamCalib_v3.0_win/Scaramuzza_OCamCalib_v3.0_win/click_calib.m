%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%   Copyright (C) 2006 DAVIDE SCARAMUZZA
%   
%   Author: Davide Scaramuzza - email: davsca@tiscali.it
%   
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) acalib_data.ocam_model.height later version.
%   
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT Acalib_data.ocam_model.height WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%   USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function click_calib(calib_data)

%if isnan(calib_data.dX_default),    calib_data.dX_default = [];end;
%if isnan(calib_data.dY_default),    calib_data.dY_default = [];end;
%if isnan(calib_data.map),    calib_data.map = [];end;


calib_data.calibrated = 0; %this flag is - when the camera has not yet been calibrated

if isempty(calib_data.n_ima),
    data_calib(calib_data);
end;

check_active_images(calib_data);

if isempty(calib_data.I{calib_data.ind_active(1)}),
    ima_read_calib(calib_data);
    if isempty(calib_data.ind_read),
        disp('Cannot extract corners without images');
        return;
    end;
end;


fprintf(1,'\nExtraction of the grid corners on the images\n');


if isempty(calib_data.map), calib_data.map = gray(256); end;


%disp('WARNING!!! Do not forget to change dX_default and dY_default in click_calib.m!!!')

if ~isempty(calib_data.dX),
    dX_default = calib_data.dX;
end;

if ~isempty(calib_data.dY),
    dY_default = calib_data.dY;
end;

if ~isempty(calib_data.n_sq_x),
    n_sq_x_default = calib_data.n_sq_x;
end;

if ~isempty(calib_data.n_sq_y),
    n_sq_y_default = calib_data.n_sq_y;
end;

if ~isempty(calib_data.taylor_order),
    calib_data.taylor_order_default = calib_data.taylor_order;
end;


if ~exist('dX_default')|~exist('dY_default');
    dX_default = 30;
    dY_default = 30;
end;

if ~exist('n_sq_x_default')|~exist('n_sq_y_default'),
    n_sq_x_default = 10;
    n_sq_y_default = 10;
end;

if ~exist('wintx_default')|~exist('winty_default'),
    wintx_default = max(round(calib_data.ocam_model.width/128),round(calib_data.ocam_model.height/96));
    winty_default = wintx_default;
    clear wintx winty
end;

if ~exist('xc_default'),
    xc_default = round(calib_data.ocam_model.height/2);
end;

if ~exist('yc_default'),
    yc_default = round(calib_data.ocam_model.width/2);
end;

if ~exist('taylor_order_default')
    calib_data.taylor_order_default=4;
end;

if ~exist('wintx') | ~exist('winty'),
    for kk = 1:calib_data.n_ima,
        eval(['clear wintx_' num2str(kk)]);
        eval(['clear winty_' num2str(kk)]);
    end;

end;



if ~exist('dont_ask'),
    dont_ask = 0;
end;

% if isempty(calib_data.ima_proc),
%     calib_data.ima_proc=[];
% end;


if ~isempty(calib_data.ima_proc)
    fprintf(1,'\nCurrently, corners have been extracted for the following image(s): %s\n',num2str(calib_data.ima_proc));
    suppress_image = input('  Do you want to suppress the current image(s) ([] = no, other = yes)? ','s');
    if isempty(suppress_image),
        ima_numbers = input('Type a vector containing the Images to add (e.g. [1 2 3]) = ');
        for i=ima_numbers
            if ~isempty(find(calib_data.ima_proc==i)),
                fprintf(1,'\nyou have already extracted corners from image %d',i);
                replace_image = input(', are you sure you want to replace this image ([] = yes, other = no)?\n','s');                
                if isempty(replace_image)
                    calib_data.ima_proc=calib_data.ima_proc(find(calib_data.ima_proc~=i));
                else
                    ima_numbers(find(ima_numbers==i))=0;
                end
            end
        end
        ima_numbers= ima_numbers(find(ima_numbers~=0));
    else
        calib_data.ima_proc=[];
        ima_numbers=[];
        answer = input('\nType the images you want to process (e.g. [1 2 3], [] = all images) = ');
        if isempty(answer)
            ima_numbers = 1:calib_data.n_ima;
        else
            ima_numbers=answer;
        end
    end;
else
    answer=input('\nType the images you want to process (e.g. [1 2 3], [] = all images) = ');
    if isempty(answer)
        ima_numbers = 1:calib_data.n_ima;
    else
        ima_numbers=answer;
    end
end;


% TO DO!
% if ~dont_ask,
%     fprintf(1,'Do you want to use the automatic square counting mechanism (0=[]=default)\n');
%     manual_squares = input('  or do you always want to enter the number of squares manually (1,other)? ');
%     if isempty(manual_squares),
%         manual_squares = 0;
%     else
%         manual_squares = ~~manual_squares;
%     end;
% else
%     manual_squares = 0;
% end;
manual_squares=1;

if manual_squares,
    
    calib_data.n_sq_x = input(['Number of squares along the X direction ([]=' num2str(n_sq_x_default) ') = ']); %6
    if isempty(calib_data.n_sq_x), calib_data.n_sq_x = n_sq_x_default; end;
    calib_data.n_sq_y = input(['Number of squares along the Y direction ([]=' num2str(n_sq_y_default) ') = ']); %6
    if isempty(calib_data.n_sq_y), calib_data.n_sq_y = n_sq_y_default; end; 
    
end;

num_points=(calib_data.n_sq_x+1)*(calib_data.n_sq_y+1);

n_sq_x_default = calib_data.n_sq_x;
n_sq_y_default = calib_data.n_sq_y;


if (isempty(calib_data.dX))|(isempty(calib_data.dY)), % This question is now asked only once
    % Enter the size of each square
    
    calib_data.dX = input(['Size dX of each square along the X direction ([]=' num2str(dX_default) 'mm) = ']);
    calib_data.dY = input(['Size dY of each square along the Y direction ([]=' num2str(dY_default) 'mm) = ']);
    if isempty(calib_data.dX), calib_data.dX = dX_default; else dX_default = calib_data.dX; end;
    if isempty(calib_data.dY), calib_data.dY = dY_default; else dY_default = calib_data.dY; end;
    
else
    
    fprintf(1,['Size of each square along the X direction: dX=' num2str(calib_data.dX) 'mm\n']);
    fprintf(1,['Size of each square along the Y direction: dY=' num2str(calib_data.dY) 'mm   (Note: To reset the size of the squares, clear the variables dX and dY)\n']);
    %fprintf(1,'Note: To reset the size of the squares, clear the variables dX and dY\n');
    
end;

square_vert_side=calib_data.dX; %mm
square_horiz_side=calib_data.dY; %mm
num_vert_square=calib_data.n_sq_x;
num_horiz_square=calib_data.n_sq_y;

calib_data.ocam_model.xc=input(['X coordinate (along height) of the omnidirectional image center = ([]=' num2str(xc_default) ') = ']);    
calib_data.ocam_model.yc=input(['Y coordinate (along width) of the omnidirectional image center = ([]=' num2str(yc_default) ') = ']);    
if isempty(calib_data.ocam_model.xc), calib_data.ocam_model.xc = xc_default; else xc_default = calib_data.ocam_model.xc; end;
if isempty(calib_data.ocam_model.yc), calib_data.ocam_model.yc = yc_default; else yc_default = calib_data.ocam_model.yc; end;
% xc=385.48;
% yc=516.36;


fprintf(1,'\nEXTRACTION OF THE GRID CORNERS\n');
fprintf(1,'Do you want to use the automatic image selection\n');
answer=input('or do you want to process the images individually ( [] = automatic, other = individual )? ','s');

if isempty(answer)
    use_video_mode = 1;
    use_corner_find = 0;
else
    use_video_mode = 0;
    fprintf(1,'Do you want to use the automatic corner extraction\n');
    answer=input('or do you want to extract all the points manually ( [] = automatic, other = manual )? ','s');
    
    % If you opted for the AUTOMATIC extraction
    if isempty(answer)
        use_automatic = 1;
        use_corner_find=0;
    else
        use_automatic = 0;
    end
    
    fprintf(1,'\n');
    % If you opted for the MANUAL extraction
    if use_automatic == 0 %IF manual Extraction
        answer=input('Do you want your clicking to be assisted by a corner detector ( [] = yes, other = no )? ','s');
        if isempty(answer)
            use_corner_find=1;
            disp('Window size for corner finder (wintx and winty): ');
            calib_data.wintx = input(['wintx ([] = ' num2str(wintx_default) ') = ']);
            if isempty(calib_data.wintx), calib_data.wintx = wintx_default; end;
            calib_data.wintx = round(calib_data.wintx);
            calib_data.winty = input(['winty ([] = ' num2str(winty_default) ') = ']);
            if isempty(calib_data.winty), calib_data.winty = winty_default; end;
            winty = round(calib_data.winty);
            fprintf(1,'Window size = %dx%d\n',2*calib_data.wintx+1,2*calib_data.winty+1);
            
        else
            use_corner_find=0;
        end
    end
end



%Arranging the pixel of the world
calib_data.Xt=[];
calib_data.Yt=[];
for i=0:calib_data.n_sq_x
    for j=0:calib_data.n_sq_y
        calib_data.Yt=[calib_data.Yt;j*calib_data.dY];
        calib_data.Xt=[calib_data.Xt;i*calib_data.dX];
    end
end


if use_video_mode == 0
    for kk = ima_numbers,
        if ~isempty(calib_data.I{kk})
            if use_automatic == 0 %IF manual extraction
                click_ima_calib(kk,use_corner_find,calib_data);
            else %IF automatic extraction
                click_ima_calib_rufli(kk,use_corner_find,calib_data);
                %click_ima_calib_vladimir
            end
            calib_data.active_images(kk) = 1;
            calib_data.ima_proc= sort([calib_data.ima_proc, kk]);
        end;
    end;
else
    count = 0;
    for kk = ima_numbers
        
        [callBack, x, y]  = get_checkerboard_corners(kk,use_corner_find,calib_data);
        
        if callBack == 1
            count = count + 1;
            calib_data.Xp_abs(:,:,kk) = x;
            calib_data.Yp_abs(:,:,kk) = y;
            calib_data.active_images(kk) = 1;
            calib_data.ima_proc= sort([calib_data.ima_proc, kk]);
        end
    end
end

check_active_images(calib_data);

fprintf(1,'\nCorner extraction finished.\n');

end


