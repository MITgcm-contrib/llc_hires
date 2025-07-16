clear
close all;

gridDir = '/Users/carrolld/Documents/research/LOAC/grid/LLC_1080/';

dataDir = '/Users/carrolld/Documents/research/LOAC/bin/bathy/';
saveDir = '/Users/carrolld/Documents/research/LOAC/mat/patch/';

%%

numFaces = 13;

nx = 1080;
ny = nx .* numFaces;

fileName = 'LLC1080_GEBCO24_depth_v1.2a.bin';

depth = readbin([dataDir fileName],[nx ny],1,'real*4');

depth(depth ~= 0) = 1;

field = depth;

global mygrid

mygrid = [];

grid_load(gridDir,5,'compact');

%%

%decompose in facets
facet1 = reshape(field(1:nx*nx*3),[nx nx*3]);
facet2 = reshape(field(nx*nx*3+1:nx*nx*6),[nx nx*3]);
facet3 = reshape(field(nx*nx*6+1:nx*nx*7),[nx nx]);
facet4 = reshape(field(nx*nx*7+1:nx*nx*10),[nx*3 nx]);
facet5 = reshape(field(nx*nx*10+1:nx*nx*13),[nx*3 nx]);

%useful definitions
ix1 = 1:nx;
ix2 = (nx+1):(2*nx);
ix3 = (2*nx+1):(3*nx);
ix4 = (3*nx+1):(4*nx);
ix5 = 1:(3*nx);
ix6 = (nx+1):(4*nx);
ix7 = (4*nx+1):(7*nx);

%patch facet 1
patch1 = zeros(nx*3,nx*4);
patch1(ix1,ix5) = rot90(facet5,3);
patch1(ix2,ix5) = facet1;
patch1(ix3,ix5) = facet2;
patch1(ix2,ix4) = rot90(facet3,1);

%patch facet 2
patch2 = zeros(nx*3,nx*4);
patch2(ix1,ix5) = facet1;
patch2(ix2,ix5) = facet2;
patch2(ix3,ix5) = rot90(facet4,3);
patch2(ix2,ix4) = facet3;

%patch facet 3
patch3 = zeros(nx*7,nx*7);
patch3(ix4,ix4) = facet3;
patch3(ix7,ix4) = facet4;
patch3(ix4,ix7) = rot90(facet5,1);
patch3(ix5,ix4) = rot90(facet1,3);
patch3(ix4,ix5) = facet2;

%patch facet 4
patch4 = zeros(nx*4,nx*3);
patch4(ix6,ix1)=rot90(facet2,-3);
patch4(ix6,ix2)=facet4;
patch4(ix6,ix3)=facet5;
patch4(ix1,ix2)=rot90(facet3,0);

%patch facet 5
patch5 = zeros(nx*4,nx*3);
patch5(ix6,ix1) = facet4;
patch5(ix6,ix2) = facet5;
patch5(ix6,ix3) = rot90(facet1,-3);
patch5(ix1,ix2) = rot90(facet3,-1);

%%

tempField1 = mygrid.hFacCsurf;

%%

patch.patch1.field = patch1;
patch.patch1.ix = ix2;
patch.patch1.iy = ix5;

facet1 = patch1(patch.patch1.ix,patch.patch1.iy);

figure

subplot(121);

pcolorcen(tempField1.f1);

subplot(122);

pcolorcen(facet1);

%%

patch.patch2.field = patch2;
patch.patch2.ix = ix2;
patch.patch2.iy = ix5;

facet2 = patch2(patch.patch2.ix,patch.patch2.iy);

figure

subplot(121);

hold on

pcolorcen(patch2);

subplot(122);

pcolorcen(facet2);

%%

patch.patch3.field = patch3;
patch.patch3.ix = ix4;
patch.patch3.iy = ix4;

facet3 = patch3(patch.patch3.ix,patch.patch3.iy);

figure

subplot(121);

pcolorcen(patch3);

subplot(122);

pcolorcen(facet3);

%%

patch.patch4.field = patch4;
patch.patch4.ix = ix6;
patch.patch4.iy = ix2;

facet4 = patch4(patch.patch4.ix,patch.patch4.iy);

figure

subplot(121);

pcolorcen(patch4);

subplot(122);

pcolorcen(facet4);

%%

patch.patch5.field = patch5;
patch.patch5.ix = ix6;
patch.patch5.iy = ix2;

facet5 = patch5(patch.patch5.ix,patch.patch5.iy);

figure

subplot(121);

pcolorcen(patch5);

subplot(122);

pcolorcen(facet5);

%%

tempField1.f1 = facet1;
tempField1.f2 = facet2;
tempField1.f3 = facet3;
tempField1.f4 = facet4;
tempField1.f5 = facet5;

tempField2 = convert2gcmfaces(tempField1);

figure

quikplot_llc(tempField2);

%%

save([saveDir 'LLC_1080_patch_new.mat'],'patch','-v7.3');

%%
