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
function optimizefunction_old(calib_data)

fprintf(1,'This function refines calibration parameters (both EXTRINSIC and INTRINSIC)\n');
fprintf(1,'by using a non linear minimization method \n');
fprintf(1,'Because of the computations involved this refinement can take some seconds\n');
fprintf(1,'Press ENTER to continue OR Crtl-C if you do not want\n\n');
pause;

fprintf(1,'Starting refinement of EXTRINSIC parameters, please wait ...\n\n');

options=optimset('Display','final',...
                 'LargeScale','off', ...
                 'TolX',1e-4,...
                 'TolFun',1e-4,...
                 'DerivativeCheck','off',...
                 'Diagnostics','off',...
                 'Jacobian','off',...
                 'JacobMult',[],... % JacobMult set to [] by default
                 'JacobPattern','sparse(ones(Jrows,Jcols))',...
                 'MaxFunEvals','100*numberOfVariables',...
                 'DiffMaxChange',1e-1,...
                 'DiffMinChange',1e-8,...
                 'PrecondBandWidth',0,...
                 'TypicalX','ones(numberOfVariables,1)',...
                 'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
                 'TolPCG',0.1,...
                 'MaxIter',10000,...
                 'LineSearchType','quadcubic',...
                 'LevenbergMarquardt','off'); 

if (isempty(calib_data.ocam_model.c) & isempty(calib_data.ocam_model.d) & isempty(calib_data.ocam_model.e))
    calib_data.ocam_model.c=1;
    calib_data.ocam_model.d=0;
    calib_data.ocam_model.e=0;
end
int_par=[calib_data.ocam_model.c,calib_data.ocam_model.d,calib_data.ocam_model.e,calib_data.ocam_model.xc,calib_data.ocam_model.yc];
M=[calib_data.Xt,calib_data.Yt,zeros(size(calib_data.Xt))]; %Coordinate assolute 3D dei punti di calibrazione nel riferimento della scacchiera
for i=ima_proc
    R=calib_data.RRfin(:,:,i);
    R(:,3)=cross(R(:,1),R(:,2));
    r=rodrigues(R);
    t=calib_data.RRfin(:,3,i);
    x0=[r(1),r(2),r(3),t(1),t(2),t(3)]; %condizione iniziale
    [x0,resnorm,residual,exitflag,output] =lsqnonlin(@prova,x0,-inf,inf,options,calib_data.ocam_model.ss,int_par,calib_data.Xp_abs(:,:,i), calib_data.Yp_abs(:,:,i),M, calib_data.ocam_model.width, calib_data.ocam_model.height);
    RRfinOpt(:,:,i)=rodrigues(x0(1:3));
    RRfinOpt(:,3,i)=x0(4:6)';
    fprintf(1,'Chessboard pose %d optimized\n',i);
end

calib_data.RRfin=RRfinOpt;

fprintf(1,'\nStarting refinement of INTRINSIC parameters, please wait ...\n\n');

ss0=calib_data.ocam_model.ss;


options=optimset('Display','final',...
                 'LargeScale','off', ...
                 'TolX',1e-4,...
                 'TolFun',1e-4,...
                 'DerivativeCheck','off',...
                 'Diagnostics','off',...
                 'Jacobian','off',...
                 'JacobMult',[],... % JacobMult set to [] by default
                 'JacobPattern','sparse(ones(Jrows,Jcols))',...
                 'MaxFunEvals','100*numberOfVariables',...
                 'DiffMaxChange',1e-1,...
                 'DiffMinChange',1e-8,...
                 'PrecondBandWidth',0,...
                 'TypicalX','ones(numberOfVariables,1)',...
                 'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
                 'TolPCG',0.1,...
                 'MaxIter',10000,...
                 'LineSearchType','quadcubic',...
                 'LevenbergMarquardt','on'); 

f0=[1,1,calib_data.ocam_model.c,calib_data.ocam_model.d,calib_data.ocam_model.e,ones(1,size(calib_data.ocam_model.ss,1))];
lb=[0,0,0,-1,-1,zeros(1,size(calib_data.ocam_model.ss,1))];
ub=[2,2,2,1,1,2*ones(1,size(calib_data.ocam_model.ss,1))];
[ssout,resnorm,residual,exitflag,output] =lsqnonlin(@prova3,f0,-inf,inf,options,calib_data.ocam_model.xc,calib_data.ocam_model.yc,calib_data.ocam_model.ss,calib_data.RRfin, calib_data.ima_proc,calib_data.Xp_abs,calib_data.Yp_abs,M, calib_data.ocam_model.width, calib_data.ocam_model.height);
fprintf(1,'Camera model optimized');
ss=ss0.*ssout(6:end)';
xc=calib_data.ocam_model.xc*ssout(1)
yc=calib_data.ocam_model.yc*ssout(2)
c=ssout(3)
d=ssout(4)
e=ssout(5)
ocam_model.ss=ss;
ocam_model.xc=xc;
ocam_model.yc=yc;
ocam_model.c=c;
ocam_model.d=d;
ocam_model.e=e;
%ocam_model.width=width;
%ocam_model.height=height;
reprojectpoints_adv(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);
ss


