function ss_n=get_ocam_model(radius)
ss =[
   -1.405116937602191e+002;
                         0;
    2.716608082380784e-004;
    5.257341861497706e-006;
   -1.067888507955045e-009];
k=radius/498.0;
kk=ones(size(ss))*k;
kkk=kk.^([-1:length(ss)-2]');

ss_n=ss./kkk;

%theta_cam=rad2deg(atan2(polyval([ss_n(end:-1:1)],[0:floor(ny/2)]),[0:floor(ny/2)]));
