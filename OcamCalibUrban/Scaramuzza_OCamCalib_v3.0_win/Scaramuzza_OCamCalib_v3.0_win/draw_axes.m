function draw_axes(Xp_abs, Yp_abs,n_sq_y)

xo_X = Xp_abs(1:n_sq_y+1:end,:);
yo_X = Yp_abs(1:n_sq_y+1:end,:);
xo_Y = Xp_abs(1:n_sq_y+1,:);
yo_Y = Yp_abs(1:n_sq_y+1,:);

plot(yo_X, xo_X,'g-','linewidth',2);
plot(yo_Y, xo_Y,'g-','linewidth',2);

delta = 40;%abs((yo_X(2)-yo_X(1)))*4; %pixels

uX = [xo_X(2)-xo_X(1);yo_X(2)-yo_X(1);0];
uY = [xo_Y(2)-xo_Y(1);yo_Y(2)-yo_Y(1);0];

origin = [xo_X(1);yo_X(1);0];

Xloc = cross( uX, cross(uX,uY) ); Xloc=Xloc/abs(norm(Xloc)) + uX/abs(norm(uX)); Xloc=Xloc/abs(norm(Xloc))*delta + origin;
Yloc = cross( cross(uX,uY), uY ); Yloc=Yloc/abs(norm(Yloc)) + uY/abs(norm(uY)); Yloc=Yloc/abs(norm(Yloc))*delta + origin;
Oloc = (cross( cross(uX,uY), uY )/abs(norm(cross( cross(uX,uY), uY )))...
    + cross( uX, cross(uX,uY) )/abs(norm(cross( uX, cross(uX,uY) )))); Oloc=Oloc/abs(norm(Oloc))*delta + origin;

text(Xloc(2), Xloc(1), 'X','color','g','Fontsize',14, 'FontWeight', 'bold');
text(Yloc(2), Yloc(1),'Y','color','g','Fontsize',14,'HorizontalAlignment','center', 'FontWeight', 'bold');
text(Oloc(2), Oloc(1),'O','color','g','Fontsize',14, 'FontWeight', 'bold');