%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%   Copyright (C) 2006 DAVIDE SCARAMUZZA
%   
%   Author: Davide Scaramuzza - email: davsca@tiscali.it
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

function ocam_calib_gui,

cell_list = {};


%-------- Begin editable region -------------%
%-------- Begin editable region -------------%


fig_number = 1;

title_figure = 'Omnidirectional Camera Calibration Toolbox';

cell_list{1,1} = {'Read names','data_calib(calib_data);'};
cell_list{1,2} = {'Extract grid corners','click_calib(calib_data);'};
cell_list{1,3} = {'Calibration','calibration(calib_data);'};
cell_list{2,1} = {'Find center','findcenter(calib_data);'};
cell_list{2,2} = {'Calibration Refinement','optimizefunction(calib_data);'};
cell_list{2,3} = {'Reproject on images','reproject_calib(calib_data);'};
cell_list{3,1} = {'Show Extrinsic','create_simulation_points(calib_data);'};
cell_list{3,2} = {'Analyse error','analyse_error(calib_data);'};
cell_list{3,3} = {'Recomp. corners','recomp_corner_calib(calib_data);'};
cell_list{4,1} = {'Show calib results','show_calib_results(calib_data);'};
cell_list{4,2} = {'Save','saving_calib(calib_data);'};
cell_list{4,3} = {'Load','loading_calib;'};
cell_list{5,1} = {'Export Data','exportData2TXT(calib_data);'};
cell_list{5,2} = {'Exit',['clear; disp(''Bye. To run again, type ocam_calib.''); close(' num2str(fig_number) ');']}; %{'Exit','calib_gui;'};




show_window(cell_list,fig_number,title_figure);



%-------- End editable region -------------%
%-------- End editable region -------------%






%------- DO NOT EDIT ANYTHING BELOW THIS LINE -----------%

function show_window(cell_list,fig_number,title_figure,x_size,y_size,gap_x,font_name,font_size)


if ~exist('cell_list'),
    error('No description of the functions');
end;

if ~exist('fig_number'),
    fig_number = 1;
end;
if ~exist('title_figure'),
    title_figure = '';
end;
if ~exist('x_size'),
    x_size = 120;
end;
if ~exist('y_size'),
    y_size = 16;
end;
if ~exist('gap_x'),
    gap_x = 0;
end;
if ~exist('font_name'),
    font_name = 'clean';
end;
if ~exist('font_size'),
    font_size = 10;
end;

figure(fig_number); clf;
pos = get(fig_number,'Position');

[n_row,n_col] = size(cell_list);

fig_size_x = x_size*n_col+(n_col+1)*gap_x;
fig_size_y = y_size*n_row+(n_row+1)*gap_x;

set(fig_number,'Units','points', ...
	'BackingStore','off', ...
	'Color',[0.8 0.8 0.8], ...
	'MenuBar','none', ...
	'Resize','off', ...
	'Name',title_figure, ...
'Position',[pos(1)-20 pos(2)-20 fig_size_x fig_size_y], ...
'NumberTitle','off'); %,'WindowButtonMotionFcn',['figure(' num2str(fig_number) ');']);

h_mat = zeros(n_row,n_col);

posx = zeros(n_row,n_col);
posy = zeros(n_row,n_col);

for i=n_row:-1:1,
   for j = n_col:-1:1,
      posx(i,j) = gap_x+(j-1)*(x_size+gap_x);
      posy(i,j) = fig_size_y - i*(gap_x+y_size);
   end;
end;

for i=n_row:-1:1,
    for j = n_col:-1:1,
        if ~isempty(cell_list{i,j}),
            if ~isempty(cell_list{i,j}{1}) & ~isempty(cell_list{i,j}{2}),
                h_mat(i,j) = uicontrol('Parent',fig_number, ...
                    'Units','points', ...
                    'Callback',cell_list{i,j}{2}, ...
                    'ListboxTop',0, ...
                    'Position',[posx(i,j)  posy(i,j)  x_size   y_size], ...
                    'String',cell_list{i,j}{1}, ...
                    'fontsize',font_size,...
                    'fontname',font_name,...
                    'Tag','Pushbutton1');
            end;
        end;
    end;
end;

%------ END PROTECTED REGION ----------------%
