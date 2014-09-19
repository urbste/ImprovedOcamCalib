function optimizefunction_all(calib_data)

fprintf(1,'\nThis function refines all calibration parameters (both EXTRINSIC and INTRINSIC)\n');
fprintf(1,'by using a non linear minimization method \n');
fprintf(1,'Because of the computations involved this refinement can take several minutes\n');
fprintf(1,'\nWARNING: Search space dimension increases linearly with number of calibration images\n\n');
fprintf(1,'Press Enter to continue or Ctrl+C to abort now\n');
pause;


options=optimset('Display','iter',...
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
    'Algorithm','trust-region-reflective');

M=[calib_data.Xt,calib_data.Yt,zeros(size(calib_data.Xt))]; %Coordinate assolute 3D dei punti di calibrazione nel riferimento della scacchiera
%costruisci vettore di stato
if ~isempty(calib_data.ocam_model.c) & ~isempty(calib_data.ocam_model.d) & ~isempty(calib_data.ocam_model.e)
    x0=[calib_data.ocam_model.c;calib_data.ocam_model.d;calib_data.ocam_model.e];
else
    x0=[1;1;1];
end
for i=calib_data.ima_proc
    r1=calib_data.RRfin(:,1,i);
    r2=calib_data.RRfin(:,2,i);
    rod=rodrigues( [r1,r2,cross(r1,r2)] );
    Tod=calib_data.RRfin(:,3,i);
    x0=[x0;rod;Tod];
end
ss0=calib_data.ocam_model.ss;
x0=[x0;calib_data.ocam_model.xc;calib_data.ocam_model.yc];
x0=[x0;ones(size(ss0))];
tic;
[allout,resnorm,residual,exitflag,output] =lsqnonlin(@prova_all,x0,[],[],options,ss0,calib_data.ima_proc,calib_data.Xp_abs,calib_data.Yp_abs,M,calib_data.ocam_model.width,calib_data.ocam_model.height);
toc;
xc=allout(end-length(calib_data.ocam_model.ss)-1);
yc=allout(end-length(calib_data.ocam_model.ss));
c=allout(1);
d=allout(2);
e=allout(3);
%costruisci vettore ssc
ssc=allout(end-length(ss0)+1:end);
ss=ss0.*ssc;
%costruisci RRfin
count=0;
for i=calib_data.ima_proc
    Rod=rodrigues( allout(6*count+4:6*count+6) );
    Tod= allout(6*count+7:6*count+9);
    RRfinOpt(:,:,i)=Rod;
    RRfinOpt(:,3,i)=Tod;
    count=count+1;
end

calib_data.RRfin=RRfinOpt;

calib_data.ocam_model.ss=ss;
calib_data.ocam_model.xc=xc;
calib_data.ocam_model.yc=yc;
calib_data.ocam_model.c=c;
calib_data.ocam_model.d=d;
calib_data.ocam_model.e=e;

reprojectpoints_adv(calib_data.ocam_model, calib_data.RRfin, calib_data.ima_proc, calib_data.Xp_abs, calib_data.Yp_abs, M);
ss
