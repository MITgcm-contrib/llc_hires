figure
% construct polygons
line([.3 .7 .6 .3],[.1 .6 .8 .1],'color',[0 0 0])
line([.2 .7 .4 .2],[.4 .2 .7 .4],'color',[0 0 0])
% create grid 
[x y] = meshgrid([0:0.001:1],[0:0.001:1]);
% find all point inside the polygon
in = inpolygon(x,y,[.3 .7 .6],[.1 .6 .8]);
h = plot([.3 .7 .6 .3],[.1 .6 .8 .1],x(in),y(in),'.r',x(~in),y(~in),'.b')
hold on
set(h,'Markersize',1)
% all points inside
x = x(in);
y = y(in);
% find all points inside both of the polygons
in = inpolygon(x,y,[.2 .7 .4],[.4 .2 .7]);
h = plot([.2 .7 .4 .2],[.4 .2 .7 .4],x(in),y(in),'.r',x(~in),y(~in),'.b')
set(h,'Markersize',1)
%
axis([0 1 0 1])
% Number of points of both polygons
% (1 point refers to the area of a defined grid resolution)
sum(in)
% Area of the defined grid(1001 x 1001) (e.g. 1 m^2)
A = sum(in)/(1001 x 1001);  (in m^2)


