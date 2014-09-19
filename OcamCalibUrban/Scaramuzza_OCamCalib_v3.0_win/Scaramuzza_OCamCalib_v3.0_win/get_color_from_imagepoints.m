function [r,g,b] = get_color_from_imagepoints( im1, key1 )

height = size(im1,1);
width  = size(im1,2);

key1 = round(key1);

% Correct points which are outside image borders
indH = find( key1(:,1)<1 | key1(:,1)>height | isnan(key1(:,1)) );
key1(indH,1) = 1;
key1(indH,2) = 1;
indW = find( key1(:,2)<1 | key1(:,2)>width  | isnan(key1(:,2)) );
key1(indW,1) = 1;
key1(indW,2) = 1;

im1(1,1,1) = 0;
im1(1,1,2) = 0;
im1(1,1,3) = 0;

RI = im1(:,:,1);
GI = im1(:,:,2);
BI = im1(:,:,3);

r = RI(sub2ind( [height,width], key1(:,1), key1(:,2) ));
g = GI(sub2ind( [height,width], key1(:,1), key1(:,2) ));
b = BI(sub2ind( [height,width], key1(:,1), key1(:,2) ));

