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

%CREATE_SIMULATION_POINTS
%   This script generates a simulation setup for calibrating a simulated
%   omnidirectional sensor, whose both intrinsic and extrinsic parameters
%   can be arbitrarily chosen by the user according to a real arrangement .
%   The following script must be executed before running the script
%   "find_RRfin", which computes all instrinsic and extrinsic parameters.
%   Copyright 2005 Davide Scaramuzza 


% Define Rotation and Translation matrices of your simulated
% calibration pattern (that is, define RRfin_sim(:,:,i))

%to be done

% Define intrinsic parameters of your simulated mirror:
% that is, define de shape of function "g" (that is, define ss)

%to be done

% Define the 3D coordinates of teh calibration points
% remember that the Z-coordinate of all these points has to be "zero"
% (that is, define X(:,:,i) and Y(:,:,i)

%to be done

%Inizialize variables

function create_simulation_points(calib_data)

if isempty(calib_data.n_ima) | calib_data.calibrated==0,
   fprintf(1,'\nNo calibration data available. You must first calibrate your camera.\nClick on "Calibration" or "Find center"\n\n');
   return;
end;


Mc=[];
ddX=16;
ddY=16;
calib_data.n_sq_x;
calib_data.n_sq_y;
colors = 'brgkcm';
BASE = 5*ddX*([0 1 0 0 0 0;0 0 0 1 0 0;0 0 0 0 0 1]);

% Settings
hhh = figure(2);
hold off;

% set(hhh,'MenuBar','figure','Renderer','OpenGL');
% set(hhh,'Name','Extrinsic parameters','NumberTitle','off');
% cameratoolbar(hhh,'Show');
% cameratoolbar(hhh,'SetMode','orbit');
% axis vis3d;
% view(3);
% set(gca,'Visible','On','Box','On','XGrid', 'Off','YGrid', 'Off','ZGrid', 'Off','Projection','perspective');

set(hhh,'MenuBar','figure');
set(hhh,'Name','Extrinsic parameters','NumberTitle','off');
view(3);
set(gca,'Visible','On','Box','On','XGrid', 'Off','YGrid', 'Off','ZGrid', 'Off','Projection','perspective');

plot3(BASE(1,:),BASE(2,:),BASE(3,:),'b-','linewidth',2);
hold on;
text(6*ddX,0,0,'X_c');
text(-ddX,5*ddX,0,'Y_c');
text(0,0,6*ddX,'Z_c');
text(-ddX,-ddX,ddX,'O_c');
[XM,YM]=meshgrid([-25:1:25],[-25:1:25]);
hold on; surfl(XM,YM,5/100*(XM.^2+YM.^2));
shading interp
colormap(gray);
grid; 



% visualize 3D recostructed points

for i=calib_data.ima_proc
    
    M=[calib_data.Xt';calib_data.Yt';ones(size(calib_data.Xt'))];
    Mc=calib_data.RRfin(:,:,i)*M;

    %Show extrinsic    
  	      uu = [-ddX;-ddY;1];
	      uu = calib_data.RRfin(:,:,i) * uu;
		  YYx = zeros(calib_data.n_sq_x+1,calib_data.n_sq_y+1);
		  YYy = zeros(calib_data.n_sq_x+1,calib_data.n_sq_y+1);
		  YYz = zeros(calib_data.n_sq_x+1,calib_data.n_sq_y+1);
		  
		  YYx=reshape(Mc(1,:),calib_data.n_sq_y+1,calib_data.n_sq_x+1)';
		  YYy=reshape(Mc(2,:),calib_data.n_sq_y+1,calib_data.n_sq_x+1)';
		  YYz=reshape(Mc(3,:),calib_data.n_sq_y+1,calib_data.n_sq_x+1)';
		  
		  %keyboard;
		  
          hold on;
		  hhh= mesh(YYx,YYy,YYz); axis equal;
		  set(hhh,'edgecolor',colors(rem(i-1,6)+1),'linewidth',1); %,'facecolor','none');
		  text(uu(1),uu(2),uu(3),num2str(i),'fontsize',14,'color',colors(rem(i-1,6)+1));          
end

hold off;

reprojectpoints_adv(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M');
ss = calib_data.ocam_model.ss;
ss