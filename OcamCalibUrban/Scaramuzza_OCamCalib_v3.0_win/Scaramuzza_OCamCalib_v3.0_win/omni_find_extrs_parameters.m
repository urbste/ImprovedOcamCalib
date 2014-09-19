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

%Find the other parameters
function RRfin=omni_find_extrs_parameters(ss, xc, yc, ima_proc, Xp_abs, Yp_abs, Xt, Yt, RRfin)

Xp=Xp_abs-xc;
Yp=Yp_abs-yc;
M1=[];
M2=[];
M3=[];
Rt=[];
MM=[];
RRdef=[];
for i=ima_proc
    
    Xpt=Xp(:,:,i);
    Ypt=Yp(:,:,i);
    rhot=sqrt(Xpt.^2 + Ypt.^2);
    M1=[ zeros(size(Xt)) , zeros(size(Xt)) , -FUNrho(ss,rhot).*Xt , -FUNrho(ss,rhot).*Yt , ...
         Ypt.*Xt , Ypt.*Yt , zeros(size(Xt)) , -FUNrho(ss,rhot) , Ypt];

    M2=[ FUNrho(ss,rhot).*Xt , FUNrho(ss,rhot).*Yt , zeros(size(Xt)) , zeros(size(Xt)) , ...
         -Xpt.*Xt , -Xpt.*Yt , FUNrho(ss,rhot) , zeros(size(Xt)) , -Xpt];
 
    M3=[ -Ypt.*Xt , -Ypt.*Yt , Xpt.*Xt , Xpt.*Yt , ...
         zeros(size(Xt)) , zeros(size(Xt)) , -Ypt , Xpt , zeros(size(Xt))];
 
    MM=[M1;M2;M3];
    [U,S,V] = svd(MM);
    res=V(:,end);
    Rt=reshape(res(1:6),2,3)'; %find the first 2 rotation vectors: r1 , r2
    scalefact=sqrt(abs(norm(Rt(:,1))*norm(Rt(:,2))));
%    keyboard;
    Rt=[Rt , cross(Rt(:,1),Rt(:,2))]; %find r3 as r3=r1xr2
    [U2,S2,V2] = svd(Rt); %SVD to find the best rotation matrix in the Frobenius sense
    Rt=U2*V2';
    Rt(:,3)=res(7:end)/scalefact;
    Rt=Rt* sign(Rt(1,3)*RRfin(1,3,i));
    RRdef(:,:,i)=Rt;

%pause
end
RRtmp=RRfin;
RRfin=RRdef;


