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
function [Xp_abs, Yp_abs]=generate_sim_points(RRfin_sim,ss,X,Y,xc,yc,num_vert_square, num_horiz_square )

%Inizialize variables
Mc=[];
Xp_abs=[];
Yp_abs=[];
n_sq_x=num_vert_square;
n_sq_y=num_horiz_square;

num_points=(n_sq_x+1)*(n_sq_y+1);
for i=1:size(RRfin_sim,3)
    M=[X(:,:,i)';Y(:,:,i)';ones(size(X(:,:,i)'))];
    Mc=RRfin_sim(:,:,i)*M;
    [Xp_reprojected,Yp_reprojected]=omni3d2pixel(ss,Mc); %convert 3D coordinates in 2D pixel coordinates
    Xp_abs(:,:,i)=Xp_reprojected'+xc;
    Yp_abs(:,:,i)=Yp_reprojected'+yc;
end