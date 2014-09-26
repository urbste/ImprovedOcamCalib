%FINDINVPOLY finds the inverse polynomial specified in the argument.
%   [POL, ERR, N] = FINDINVPOLY(SS, RADIUS, N) finds an approximation of the inverse polynomial specified in OCAM_MODEL.SS.
%   The returned polynomial POL is used in WORLD2CAM_FAST to compute the reprojected point very efficiently.
%   
%   SS is the polynomial which describe the mirrror/lens model.
%   RADIUS is the radius (pixels) of the omnidirectional picture.
%   ERR is the error (pixel) that you commit in using the returned
%   polynomial instead of the inverse SS. N is searched so that
%   that ERR is < 0.01 pixels.
%
%   Copyright (C) 2008 DAVIDE SCARAMUZZA, ETH Zurich
%   Author: Davide Scaramuzza - email: davide.scaramuzza@ieee.org

function [pol, err, N] = findinvpolyUrban(ss, I)

disp('choose about 10 points along the border of the visible image region! Press enter if finished')
figure
imshow(uint8(I));
[x, y] =ginput;
X=[x'
   y'];

[~, A, B, ~] = fitellipse(X);
radius = mean([A,B]);

if nargin < 3
    maxerr = inf;
    N = 1;
    while maxerr > 0.01 %Repeat until the reprojection error is smaller than 0.01 pixels
        N = N + 1;
        [pol, err,N] = findinvpoly2(ss, radius, N);
        maxerr = max(err);  
    end
else
    [pol, err, N] = findinvpoly2(ss, radius, N);
end

function [pol, err, N, r] = findinvpoly2(ss, radius, N)

theta = -pi/2:0.01:1.4;
r     = invFUN(ss, theta, radius);
ind   = find(r~=inf);
theta = theta(ind);
r     = r(ind);

pol = polyfit(theta,r,N);

err = abs( r - polyval(pol, theta)); %approximation error in pixels


function r=invFUN(ss, theta, radius)

m=tan(theta);

r=[];
poly_coef=ss(end:-1:1);
poly_coef_tmp=poly_coef;
for j=1:length(m)
    poly_coef_tmp(end-1)=poly_coef(end-1)-m(j);
    rhoTmp=roots(poly_coef_tmp);
    res=rhoTmp(find(imag(rhoTmp)==0 & rhoTmp>0 & rhoTmp<radius ));
    if isempty(res) | length(res)>1
        r(j)=inf;
    else
        r(j)=res;
    end
end