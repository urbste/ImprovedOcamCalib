%IMUNWRAP Unwrap an omnidirectional image into a cylindrical panorama
%(cartesian to polar transformation).
%   uI = IMUNWRAP(I, center, Rmax, Rmin, bilinear)
%   I = input color image
%   center = coordinates of the circle center, center=[col;row]
%   Rmax = external radius of the omnidirectional image
%   Rmin = inner radius of the omnidirectional image
%
%   Copyright (C) 2006 DAVIDE SCARAMUZZA, ETH Zurich
%   Author: Davide Scaramuzza - email: davide.scaramuzza@ieee.org

function Iunwraped=imunwrap(I, center, Rmax, Rmin, bilinear, width)

if nargin==3
    Rmin=round(0.2*Rmax);
    bilinear=1;
    width = 360;
elseif nargin==4
    bilinear=1;
    width = 360;
end

    
Rmax=round(Rmax);
Rmin=round(Rmin);
I=double(I);
xc=center(2);
yc=center(1);

%c=round(2*pi*Rmax);
c=round(width);
cols=c;
rows=Rmax-Rmin;

Iunwraped=zeros(Rmax-Rmin,c, 3);
R=zeros(Rmax-Rmin,c);
G=zeros(Rmax-Rmin,c);
B=zeros(Rmax-Rmin,c);
RI=I(:,:,1);
GI=I(:,:,2);
BI=I(:,:,3);

U=zeros(size(Iunwraped));
V=zeros(size(Iunwraped));

r=Rmax;

[J,II]=meshgrid(1:cols,1:rows);
THETA=-(J-1)/width*2*pi;
RHO=Rmax+1-II;
X=xc+RHO.*cos(THETA);
Y=yc+RHO.*sin(THETA);
U=floor(Y);
V=floor(X);
IND=(U-1)*size(I,1)+V;

IND(find(~(U>1 & U<size(I,2) & V>1 & V<size(I,1)) ))=0;
fIND=find(IND);

if bilinear
    % if BILINEAR
    dX=Y-U; dY=X-V;
    A1=(1-dY).*(1-dX);
    A2=(1-dY).*dX;
    A3=dY.*(1-dX);
    A4=dY.*dX;
    indA1=IND;
    indA2=(U)*size(I,1)+V;
    indA3=(U-1)*size(I,1)+(V+1);
    indA4=U*size(I,1)+(V+1);
    
    R(fIND)=RI(indA1(fIND)).*A1(fIND) + RI(indA2(fIND)).*A2(fIND) + RI(indA3(fIND)).*A3(fIND) + RI(indA4(fIND)).*A4(fIND);
    G(fIND)=GI(indA1(fIND)).*A1(fIND) + GI(indA2(fIND)).*A2(fIND) + GI(indA3(fIND)).*A3(fIND) + GI(indA4(fIND)).*A4(fIND);
    B(fIND)=BI(indA1(fIND)).*A1(fIND) + BI(indA2(fIND)).*A2(fIND) + BI(indA3(fIND)).*A3(fIND) + BI(indA4(fIND)).*A4(fIND);
else
    %if NOT BILINEAR
    R(find(IND))=RI(IND(find(IND)));
    G(find(IND))=GI(IND(find(IND)));
    B(find(IND))=BI(IND(find(IND)));
    Iunwraped(:,:,1)=R;
    Iunwraped(:,:,2)=G;
    Iunwraped(:,:,3)=B;
end

Iunwraped(:,:,1)=R;
Iunwraped(:,:,2)=G;
Iunwraped(:,:,3)=B;

Iunwraped=uint8(Iunwraped);
