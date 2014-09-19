%CAM2WORLD Project a give pixel point onto the unit sphere
%   M=CAM2WORLD=(m, ocam_model) returns the 3D coordinates of the vector
%   emanating from the single effective viewpoint on the unit sphere
%
%   m=[rows;cols] is a 2xN matrix containing the pixel coordinates of the image
%   points.
%
%   "ocam_model" contains the model of the calibrated camera.
%   
%   M=[X;Y;Z] is a 3xN matrix with the coordinates on the unit sphere:
%   thus, X^2 + Y^2 + Z^2 = 1
%   
%   Last update May 2009
%   Copyright (C) 2006 DAVIDE SCARAMUZZA   
%   Author: Davide Scaramuzza - email: davide.scaramuzza@ieee.org

function M = cam2world_edit(m, ocam_model)

n_points = size(m,2);

ss = ocam_model.ss;
xc = ocam_model.xc;
yc = ocam_model.yc;
width = ocam_model.width;
height = ocam_model.height;
c = ocam_model.c;
d = ocam_model.d;
e = ocam_model.e;

A = [c,d;
     e,1];
T = [xc;yc]*ones(1,n_points);

m = A^-1*(m-T);
M = getpoint(ss,m);
M = normc(M); %normalizes coordinates so that they have unit length (projection onto the unit sphere)

function w=getpoint(ss,m)

% Given an image point it returns the 3D coordinates of its correspondent optical
% ray

w = [m(1,:) ; m(2,:) ; polyval(-ss(end:-1:1),sqrt(m(1,:).^2+m(2,:).^2)) ];