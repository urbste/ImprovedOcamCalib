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

function err=prova_all(x,ss,ima_proc,Xp_abs,Yp_abs,M, width, height)

%costruisci vettore ssc
c=x(1);
d=x(2);
e=x(3);
xc=x(end-length(ss)-1);
yc=x(end-length(ss));
ssc=x(end-length(ss)+1:end);
%costruisci RRfin
count=0;
for i=ima_proc
    R=rodrigues( x(6*count+4:6*count+6) );
    T= x(6*count+7:6*count+9);
    RRfin(:,:,i)=R;
    RRfin(:,3,i)=T;
    count=count+1;
end

M(:,3)=1;
Mc=[];
Xpp=[];
Ypp=[];
for i=ima_proc
    Mc=[Mc, RRfin(:,:,i)*M'];
    Xpp=[Xpp;Xp_abs(:,:,i)];
    Ypp=[Ypp;Yp_abs(:,:,i)];
end
[xp1,yp1]=omni3d2pixel(ss.*ssc,Mc,width,height);
xp=xp1*c + yp1*d + xc;
yp=xp1*e + yp1 + yc;

err=sqrt( (Xpp-xp').^2+(Ypp-yp').^2 );