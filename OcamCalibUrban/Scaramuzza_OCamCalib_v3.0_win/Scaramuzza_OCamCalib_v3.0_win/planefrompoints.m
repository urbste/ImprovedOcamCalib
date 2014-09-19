function res=planefrompoints(xp,yp,zp)

A=[xp,yp,zp];
B=-ones(size(xp));
res=pinv(A)*B;

