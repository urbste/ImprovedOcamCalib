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

function err=prova2(x,ss,RRfin, ima_proc,Xp_abs,Yp_abs,M, width, height)

c=x(1);
d=x(2);
e=x(3);
xc=x(4);
yc=x(5);

M(:,3)=1;
Mc=[];
Xpp=[];
Ypp=[];
for i=ima_proc
    Mc=[Mc, RRfin(:,:,i)*M'];
    Xpp=[Xpp;Xp_abs(:,:,i)];
    Ypp=[Ypp;Yp_abs(:,:,i)];
end

[xp1,yp1]=omni3d2pixel(ss, Mc, width, height);
xp=xp1*c + yp1*d + xc;
yp=xp1*e + yp1   + yc;

err=sqrt( ((Xpp-xp').^2+(Ypp-yp').^2)./((Xpp-xc).^2+(Ypp-yc).^2) );
