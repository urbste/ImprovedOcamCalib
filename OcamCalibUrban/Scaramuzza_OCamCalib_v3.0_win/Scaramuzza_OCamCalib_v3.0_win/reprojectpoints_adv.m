function [err,stderr,MSE]=reprojectpoints_adv(ocam_model, RRfin, ima_proc, Xp_abs, Yp_abs, M)

width=ocam_model.width;
height=ocam_model.height;
c=ocam_model.c;
d=ocam_model.d;
e=ocam_model.e;
ss=ocam_model.ss;
xc=ocam_model.xc;
yc=ocam_model.yc;

M(:,3)=1;
Mc=[];
Xpp=[];
Ypp=[];
count=0;
MSE=0;
for i=ima_proc
    count=count+1;
    Mc=RRfin(:,:,i)*M';
%     [xp,yp]=omni3d2pixel(ss,Mc, width, height);
%     xp=xp*c + yp*d + xc;
%     yp=xp*e + yp + yc;    
    m=world2cam(Mc, ocam_model);
    xp=m(1,:);
    yp=m(2,:);
    sqerr= (Xp_abs(:,:,i)-xp').^2+(Yp_abs(:,:,i)-yp').^2;
    err(count)=mean(sqrt(sqerr));
    stderr(count)=std(sqrt(sqerr));
    MSE=MSE+sum(sqerr);
end

fprintf(1,'\n Average reprojection error computed for each chessboard [pixels]:\n\n');
for i=1:length(err)
    fprintf(' %3.2f %c %3.2f\n',err(i),177,stderr(i));
end

fprintf(1,'\n Average error [pixels]\n\n %f\n',mean(err));
fprintf(1,'\n Sum of squared errors\n\n %f\n',MSE);