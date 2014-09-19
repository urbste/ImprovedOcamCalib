function MSE=reprojectPoints_fun(Xt, Yt, Xp_abs, Yp_abs, xc, yc, RRfin, ss, ima_proc, width, height)

m=[];
xx=[];
err=[];
stderr=[];
rhos=[];
MSE=0;
for i=ima_proc
    xx=RRfin(:,:,i)*[Xt';Yt';ones(size(Xt'))];
    [Xp_reprojected,Yp_reprojected]=omni3d2pixel(ss,xx, width, height); %convert 3D coordinates in 2D pixel coordinates
    if Xp_reprojected==NaN
        MSE=NaN;
        return;
    end        
    stt= sqrt( (Xp_abs(:,:,i)-xc-Xp_reprojected').^2 + (Yp_abs(:,:,i)-yc-Yp_reprojected').^2 ) ;
    err(i)=(mean(stt));
    stderr(i)=std(stt);
    MSE=MSE+sum( (  Xp_abs(:,:,i)-xc-Xp_reprojected').^2 + (Yp_abs(:,:,i)-yc-Yp_reprojected').^2 );
end
