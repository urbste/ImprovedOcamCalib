function err=reprojectpoints_fun_adv(x,xc,yc,ss,RRfin, ima_proc,Xp_abs,Yp_abs,M, width, height)

a=x(1);
b=x(2);
c=x(3);
d=x(4);
e=x(5);

ssc=x(6:end);

M(:,3)=1;
Mc=[];
Xpp=[];
Ypp=[];
for i=ima_proc
    Mc=[Mc, RRfin(:,:,i)*M'];
    Xpp=[Xpp;Xp_abs(:,:,i)];
    Ypp=[Ypp;Yp_abs(:,:,i)];
end

[xp,yp]=omni3d2pixel(ss.*ssc',Mc, width, height);
xp=xp*c + yp*d + xc*a;
yp=xp*e + yp + yc*b;

err=sum( (Xpp-xp').^2+(Ypp-yp').^2 );