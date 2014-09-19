function [x,y] = omni3d2pixel(ss, xx, width, height)


%convert 3D coordinates vector into 2D pixel coordinates

%These three lines overcome problem when xx = [0,0,+-1]
ind0 = find((xx(1,:)==0 & xx(2,:)==0));
xx(1,ind0) = eps;
xx(2,ind0) = eps;

m = xx(3,:)./sqrt(xx(1,:).^2+xx(2,:).^2);

rho=[];
poly_coef = ss(end:-1:1);
poly_coef_tmp = poly_coef;
for j = 1:length(m)
    poly_coef_tmp(end-1) = poly_coef(end-1)-m(j);
    rhoTmp = roots(poly_coef_tmp);
    res = rhoTmp(find(imag(rhoTmp)==0 & rhoTmp>0));% & rhoTmp<height ));    %obrand
    if isempty(res) %| length(res)>1    %obrand
        rho(j) = NaN;
    elseif length(res)>1    %obrand
        rho(j) = min(res);    %obrand
    else
        rho(j) = res;
    end
end
x = xx(1,:)./sqrt(xx(1,:).^2+xx(2,:).^2).*rho ;
y = xx(2,:)./sqrt(xx(1,:).^2+xx(2,:).^2).*rho ;
