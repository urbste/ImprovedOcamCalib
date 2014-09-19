function ss=omni_find_intrs_parameters(taylor_order, xc, yc, ima_proc, Xp_abs, Yp_abs, Xt, Yt, RRfin)
%Find the other parameters
Xp=Xp_abs-xc;
Yp=Yp_abs-yc;
PP=[];
QQ=[];

for i=ima_proc
    
    RRdef=RRfin(:,:,i);
    
    R11=RRdef(1,1);
    R21=RRdef(2,1);
    R31=RRdef(3,1);
    R12=RRdef(1,2);
    R22=RRdef(2,2);
    R32=RRdef(3,2);
    T1=RRdef(1,3);
    T2=RRdef(2,3);
    T3=RRdef(3,3);
    
    Xpt=Xp(:,:,i);
    Ypt=Yp(:,:,i);

    MA= R21.*Xt + R22.*Yt + T2;
    MB= Ypt.*( R31.*Xt + R32.*Yt + T3 );
    MC= R11.*Xt + R12.*Yt + T1;
    MD= Xpt.*( R31.*Xt + R32.*Yt + T3 );
    
    rho=[];
    for j=2:taylor_order
        rho(:,:,j)= (sqrt(Xpt.^2 + Ypt.^2)).^j;
    end
    
    PP1=[MA;MC];
    for j=2:taylor_order
        PP1=[ PP1, [MA.*rho(:,:,j);MC.*rho(:,:,j)] ];
    end
     
         
    
    PP=[PP;
        PP1];
    QQ=[QQ;
        MB; MD];
end

ss=pinv(PP)*QQ;
ss=[ss(1);0;ss(2:end)];
