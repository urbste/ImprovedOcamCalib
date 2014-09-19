%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%   Copyright (C) 2009 Davide Scaramuzza
%   
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%   
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%   USA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [callBack, Xp_abs, Yp_abs] = get_checkerboard_corners(kk,use_corner_find,calib_data)

fclose('all');
if exist('autoCornerFinder/cToMatlab/cornerInfo.txt','file')
    delete('autoCornerFinder/cToMatlab/cornerInfo.txt');
end
if exist('autoCornerFinder/cToMatlab/cornersX.txt','file')
    delete('autoCornerFinder/cToMatlab/cornersX.txt');
end
if exist('autoCornerFinder/cToMatlab/cornersY.txt','file')
    delete('autoCornerFinder/cToMatlab/cornersY.txt');
end
if exist('autoCornerFinder/cToMatlab/error.txt','file')
    delete('autoCornerFinder/cToMatlab/error.txt');
end

%INITIALIZATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\nProcessing image %s...',calib_data.L{kk});

I = imread(calib_data.L{kk});

Xp_abs = 0;
Yp_abs = 0;

%Tell the automatic corner extractor, which image file to process
fid = fopen('./autoCornerFinder/pictures.txt','w');
fprintf(fid,'../%s',calib_data.L{kk});
fclose(fid);

%Call the automatic corner extraction algorithm
%Width and height in the algorithm are defined differently than
%in this toolbox: Its the number of inernal corners instead of 
%internal quadrangles.
%-m specifies the number of corners the algorithm has to find, before it
%terminates
%If callback = -1   ->An error occured, automatic corner finding is aborted
%            =  0   ->Not enough corners have been found, add some manually
%            =  1   ->Enough corners have been found for calibration


%Visualization turned OFF
cd autoCornerFinder;

callString = (['FindCorners.exe -w ' num2str(calib_data.n_sq_x+1) ' -h ' num2str(calib_data.n_sq_y+1) ' -m ' num2str((calib_data.n_sq_x+1) * (calib_data.n_sq_y+1)) ' pictures.txt']);

if ~ispc %if not Windows
    callString = ['./' callString];
end
%Visualization turned ON
%callString = (['cd autoCornerFinder & FindCornersVisual.exe -w ' num2str(n_sq_x+1) ' -h ' num2str(n_sq_y+1) ' -m ' num2str((n_sq_x+1) * (n_sq_y+1)) ' pictures.txt']);

%Visualization turned ON and Saving of the images turned ON
%WARNING: Does somehow not work under Windows 2000...
%callString = (['cd autoCornerFinder & FindCornersVisualSave.exe -w ' num2str(n_sq_x+1) ' -h ' num2str(n_sq_y+1) ' -m ' num2str((n_sq_x+1) * (n_sq_y+1)) ' pictures.txt']);

callBack   = system(callString);
cd ..
%Do error checking
if callBack == 0
    %Display the error message
    fprintf(1,'Image omitted -- Not all corners found\n');
    return;
end

if callBack ~= 1
    %Display the error message
    filename = 'autoCornerFinder/cToMatlab/error.txt';
    fid = fopen(filename, 'r');
    line = fgetl(fid);
    fclose(fid);
    fprintf(1,'Image omitted -- During corner finding an error occured: %s \n',line);
    return;
end

%Open the corner size information file
filename = 'autoCornerFinder/cToMatlab/cornerInfo.txt';
fid = fopen(filename, 'r');
cornerInfo = fscanf(fid, '%g %g', [1 2]);   
fclose(fid);

%Open the files with the found corners
filename = 'autoCornerFinder/cToMatlab/cornersX.txt';
fid = fopen(filename, 'r');
cornersX = fscanf(fid, '%g %g', [cornerInfo(2) cornerInfo(1)]);
cornersX = cornersX';
fclose(fid);

filename = 'autoCornerFinder/cToMatlab/cornersY.txt';
fid = fopen(filename, 'r');
cornersY = fscanf(fid, '%g %g', [cornerInfo(2) cornerInfo(1)]);
cornersY = cornersY';
fclose(fid);

%VARIABLE DEFINITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numCorners = (calib_data.n_sq_x+1)*(calib_data.n_sq_y+1);
numCornerThreshold = (calib_data.n_sq_x+1)*(calib_data.n_sq_y+1);
numOfFoundCorners = 0;
cornerNumber = 0;
cornersNumbering = -1*ones(cornerInfo(1),cornerInfo(2));
startingCorner = [];
nextFoundCorner = [-1,-1];
deltaCols = 0;
startingCornerSet = false;
%Index of the corner with the smallest index
min_i = [];
min_j = [];
%Used for image zoom in
[size1, size2] = size(I);
min_x = max(size1, size2) + 1;
max_x = 0;
min_y = max(size1, size2) + 1;
max_y = 0;


%INPUT CORNER VALUE AND MATRIX SIZE ADAPTATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%If there are entire rows of zeros at the end of the file, this means that
%the cornerfinder is not entirely shure about the location of the board.
%Then eventually additional corners are needed in the front.
[iSave, dummy] = find(cornersX >= 0);
iSave = max(iSave);
%Add at least one row! This is because the columns are maybe ambiguous, 
%and then we don't know whether they belong to the current row or to the
%next one...
if (cornerInfo(1) - iSave >= 0)
    cornersX = [-1* ones(cornerInfo(1) - iSave + 1, cornerInfo(2)); cornersX];
    cornersY = [-1* ones(cornerInfo(1) - iSave + 1, cornerInfo(2)); cornersY];
end
[rows, cols] = size(cornersX); 

%Add one pixel to every non "-1" value, since Matlab starts numbering
%at one, whereas c++ starts at zero.
flagStart = true;
for i = 1:1:rows
    for j = 1:1:cols
        %Define the starting corner as the first found corner
        %which has a neighbor corner which was also found
        if j ~= cols && flagStart == true
            if cornersX(i,j) >= 0 && cornersX(i,j+1) >= 0
                startingCorner = [i,j];
                flagStart = false;
            end
        end
        if cornersX(i,j) >= 0
            cornersX(i,j) = cornersX(i,j) + 1;
            %Count the number of found corners
            numOfFoundCorners = numOfFoundCorners + 1;
            %Determine the minimal and maximal cordinates of all
            %found corners. ->Needed further down
            if cornersX(i,j) > max_x
                max_x = cornersX(i,j);
            end
            if cornersX(i,j) < min_x
                min_x = cornersX(i,j);
            end
        end
        if cornersY(i,j) >= 0
            cornersY(i,j) = cornersY(i,j) + 1;
            if cornersY(i,j) > max_y
                max_y = cornersY(i,j);
            end
            if cornersY(i,j) < min_y
                min_y = cornersY(i,j);
            end
        end
    end
end


%PREPARATIONS FOR PROPER PLOT ZOOM-IN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_x = min_x - (max_x - min_x)*(1 - numOfFoundCorners/numCorners + 0.2);
max_x = max_x + (max_x - min_x)*(1 - numOfFoundCorners/numCorners + 0.2);
min_y = min_y - (max_y - min_y)*(1 - numOfFoundCorners/numCorners + 0.2);
max_y = max_y + (max_y - min_y)*(1 - numOfFoundCorners/numCorners + 0.2);

min_x = max(min_x,0);
max_x = min(max_x,size2);
min_y = max(min_y,0);
max_y = min(max_y,size1);


% %ORIENTATION AMBIGUITY?
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Decide whether the position and orientation of the checkerboard
% %can be unambiguously determined
% if min((n_sq_y+1), (n_sq_x+1)) ~= min(cornerInfo(1),cornerInfo(2))
%     if flagStart == true
%         %DISPLAY AN ERROR AND RETURN
%     end
%     %There is some ambiguity, get rid of it
%     figure(2);
%     imagesc(I);
%     colormap(gray);
%     set(2,'color',[1 1 1]);
%     title({['Image ' num2str(kk)]});
%     h = get(gca, 'title');
%     set(h, 'FontWeight', 'bold')
%     axis([min_x max_x min_y max_y]);
%     
% 
%     figure(2); hold on;
%     i = startingCorner(1)
%     j = startingCorner(2)
%     %Plot the starting corner and its neighbor
%     plot( cornersX(i,j),cornersY(i,j),'+','color','red','linewidth',2);
%     plot( cornersX(i,j+1),cornersY(i,j+1),'+','color','red','linewidth',2);
%     text( cornersX(i,j)+3,cornersY(i,j)+3,num2str(0) )
%     text( cornersX(i,j+1)+3,cornersY(i,j+1)+3,num2str(1) )
%     set(findobj('type', 'text'), 'color', 'red'); 
%     hold off;
%       
%     %Get user input on behalf of the board orientation
%     numCornersDirZeroOne = input(['The automatic corner finder was not able to decide how the pattern is oriented. Please indicate the number of corners in direction of corners [0 -> 1]: ']);
%     %We look in row direction
%     deltaCols = cornerInfo(2) - numCornersDirZeroOne;                 
% end


%DRAW AND NUMBER FOUND CORNERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Draw the found corners onto the image and number them 
%Define the first encountered found corner as number "zero"
PlotXxiX = [];
PlotXxiY = [];
PlotCornersX = [];
PlotCornersY = [];
PlotCornerNumber = [];

for i = 1:1:rows
    for j = 1:1:(cols-deltaCols)
        if cornersX(i,j) ~= -1
            %Save for plotting later
            PlotCornersX = [PlotCornersX,cornersX(i,j)];
            PlotCornersY = [PlotCornersY,cornersY(i,j)];
            PlotCornerNumber = [PlotCornerNumber, cornerNumber];
            if use_corner_find
                %Apply the corner finder
                [xxi] = cornerfinder([cornersX(i,j);cornersY(i,j)],I,winty,wintx);
                %Save for plotting later
                PlotXxiX = [PlotXxiX,xxi(1)];
                PlotXxiY = [PlotXxiY,xxi(2)];
            end
            if cornerNumber == 0
                %Change starting corner to this one
                %Needed further down
                startingCorner = [i,j];
                startingCornerSet = true;
            end
        end
        if startingCornerSet == true
            cornerNumber = cornerNumber + 1;
        end
    end
end

if 0
    figure(2);
    imagesc(I);
    colormap(gray);
    set(2,'color',[1 1 1]);
    title({['Image ' num2str(kk)]; [num2str(numOfFoundCorners) ' / ' num2str(numCorners) ' corner have been found.']; ['Press ENTER to continue.']});
    h = get(gca, 'title');
    set(h, 'FontWeight', 'bold')
    axis([min_x max_x min_y max_y])
    
    
    %Plot the original corners
    figure(2); hold on;
    plot( PlotCornersX,PlotCornersY,'+','color','red','linewidth',2);
    if use_corner_find
        %Plot the "corner finder enhanced" corners
        plot( PlotXxiX,PlotXxiY,'+','color','blue','linewidth',2);
    end
    
    text( PlotCornersX'+3,PlotCornersY'+3,num2str(PlotCornerNumber') )
    set(findobj('type', 'text'), 'color', 'red');
    drawnow;
    hold off
end
%If no negative corners were designated, then "min_i" and "min_j"
%are still empty
if isempty(min_i)
    min_i = startingCorner(1);
    min_j = startingCorner(2);
end


%SAVE CORNER INFORMATION IN 2 VECTORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save all corners in two arrays for further processing
%by other functions
x = [];
y = [];

%Start with the smallest found corner and then append the larger ones
iteration = 0;
while true
    %Iterators
    i = min_i + floor(iteration/(cols-deltaCols));
    j = mod( (min_j - 1 + iteration),cols-deltaCols ) + 1;
    iteration = iteration + 1;
    
    x = [x,cornersX(i,j)];
    y = [y,cornersY(i,j)];
    
    if(iteration >= numCorners | i > rows)
        break
    end
end



%     %DOES NOT WORK RELIABLY!
%     %3. In case of a n x m board, where n is even and m is odd (or vice 
%     %versa) there still exists a 180 degree ambiguity. This could be get 
%     %rid off here.
%     %We define the starting corner as the corner where "a black checker is
%     %outernmost". Only proceed if one dimension is odd and the other even!
%     if (mod(n_cor_min,2) ~= 0 & mod(n_cor_max,2) == 0) | (mod(n_cor_min,2) == 0 & mod(n_cor_max,2) ~= 0)
%         %Determine the intensity at the given locations in the image
%         [dummy,lengthl] = size(x);
%         intens1 = I( floor((y(1,1)+y(1,n_cor_max+2))/2), floor((x(1,1)+x(1,n_cor_max+2))/2) )
%         intens2 = I( floor((y(1,lengthl)+y(1,lengthl-n_cor_max-1))/2), floor((x(1,lengthl)+x(1,lengthl-n_cor_max-2))/2) )
%         I(10,10)
%         if intens1 > intens2
%             %We need to reverse the numbering
%             xTemp = x;
%             yTemp = y;
%             for i = 1:1:lengthl
%                 x(i) = xTemp(lengthl+1 - i);
%                 y(i) = yTemp(lengthl+1 - i);
%             end
%         end
%     end



%REPOSITION CORNERS (IF NEEDED)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Allow the user (if needed) to reposition any of the corners
[dummy,sizex] = size(x);
iNumber = 1:1:sizex;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check, whether the numbering increases along the longer or the shorter pattern dimention:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_cor_min = min(calib_data.n_sq_x+1, calib_data.n_sq_y+1);
n_cor_max = max(calib_data.n_sq_x+1, calib_data.n_sq_y+1);

hmin = zeros(1,n_cor_max*n_cor_min-1); 
hmin(1:n_cor_min:end) = 1;
hmax = zeros(1,n_cor_max*n_cor_min-1); 
hmax(1:n_cor_max:end) = 1;

dxy = sqrt(diff(x).^2+diff(y).^2);

pmin = conv(hmin,dxy); 
pmin = max(pmin(:));
pmax=conv(hmax,dxy); 
pmax = max(pmax(:));
if pmin(1)>pmax(1)
    inc_dir = n_cor_min;
    oth_dir = n_cor_max;
else
    inc_dir = n_cor_max;
    oth_dir = n_cor_min;
end

% Rearrange numbering from starting point
xTemp = x;
yTemp = y;
area = [];
for i = 1:length(x)-1
   
    xborder = [xTemp(1,1:inc_dir-1),xTemp(1,inc_dir:inc_dir:end-inc_dir),xTemp(1,end:-1:end-inc_dir+2),xTemp(1,end-inc_dir+1:-inc_dir:1)];
    yborder = [yTemp(1,1:inc_dir-1),yTemp(1,inc_dir:inc_dir:end-inc_dir),yTemp(1,end:-1:end-inc_dir+2),yTemp(1,end-inc_dir+1:-inc_dir:1)];
    area(i) = abs(trapz(xborder,yborder));    
    xTemp = [xTemp(1,2:end),xTemp(1,1)]; %Shift points one step forward
    yTemp = [yTemp(1,2:end),yTemp(1,1)]; %Shift points one step forward    
end
shift = find( area == max(area) ) - 1;
if shift > 0
    x = [x(1,1+shift:end) , x(1,1:shift)];
    y = [y(1,1+shift:end) , y(1,1:shift)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    figure(2);
    imagesc(I);
    colormap(gray);
    hold on;
    %Plot the corners
    plot( x,y,'+','color','red','linewidth',2);
    %Plot the corresponding number
    text( x'+3,y'+3,num2str(iNumber') )
    set(findobj('type', 'text'), 'color', 'red');
    axis([min_x max_x min_y max_y]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ASSIGN STARTING CORNER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This algorithm was first designed to be used with square patterns only,
%where the starting corner is meaningless, since every orientation +n*90
%degrees is structurally equivalent.
%With the extension to non-square checker boards, this is no longer the
%case and, depending on the specific board, 2 or 4 orientations can be
%distinguished.
%1. Check, whether we are dealing with a non-square board:
if calib_data.n_sq_x ~= calib_data.n_sq_y
    %2. Check, whether the numbering increases along the longer pattern
    %dimention:
%     n_cor_min = min(n_sq_x+1, n_sq_y+1);
%     n_cor_max = max(n_sq_x+1, n_sq_y+1);
%     dist1 = (x(1,n_cor_min)-x(1,n_cor_min+1))^2 + (y(1,n_cor_min)-y(1,n_cor_min+1))^2;
%     dist2 = (x(1,n_cor_max)-x(1,n_cor_max+1))^2 + (y(1,n_cor_max)-y(1,n_cor_max+1))^2; 
    
    n_cor_x = calib_data.n_sq_x+1;
    n_cor_y = calib_data.n_sq_y+1;
    dist1 = (x(1,n_cor_x)-x(1,n_cor_x+1))^2 + (y(1,n_cor_x)-y(1,n_cor_x+1))^2;
    dist2 = (x(1,n_cor_y)-x(1,n_cor_y+1))^2 + (y(1,n_cor_y)-y(1,n_cor_y+1))^2; 

    if dist1 > dist2
       %We have it wrongly numbered, renumber
       xTemp = x;
       yTemp = y;
       [dummy,lengthl] = size(x);
       iterMult = n_cor_x;
       iterOffset = 0;
       for i = 1:1:lengthl
           j = mod(i-1,n_cor_y)+1;
           x(i) = xTemp(j*iterMult-iterOffset);
           y(i) = yTemp(j*iterMult-iterOffset);
           if j*iterMult > n_cor_x*(n_cor_y-1)
                iterOffset = iterOffset + 1;
           end
       end
    end
end

Yp_abs = x';
Xp_abs = y';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1
    figure(2);
    imagesc(I);
    colormap(gray);
    title(['Image ' num2str(kk)]);  
    h = get(gca, 'title');
    set(h, 'FontWeight', 'bold')
    hold on;
    %Plot the corners
    plot( x,y,'+','color','red','linewidth',2);
    %Plot the corresponding number
    text( x'+3,y'+3,num2str(iNumber') )
    set(findobj('type', 'text'), 'color', 'red');
    axis([min_x max_x min_y max_y]);
    draw_axes(Xp_abs, Yp_abs,calib_data.n_sq_y);
    drawnow;
    hold off;
%     close(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DELETE FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%We delete the interface files between Matlab and c++, in order to prevent
%reloading old data in case of some errors.
delete('autoCornerFinder/cToMatlab/cornerInfo.txt');
delete('autoCornerFinder/cToMatlab/cornersX.txt');
delete('autoCornerFinder/cToMatlab/cornersY.txt');
delete('autoCornerFinder/cToMatlab/error.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Display finished message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'Done\n');


