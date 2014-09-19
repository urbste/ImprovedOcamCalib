function w=getpoint(ss,m)

% Given an image point it returns the 3D coordinates of its correspondent optical
% ray

w=[m(1,:);m(2,:); polyval(ss(end:-1:1),sqrt(m(1,:).^2+m(2,:).^2)) ];