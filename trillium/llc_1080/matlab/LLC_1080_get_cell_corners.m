clear
close all

gridDir = '/Users/carrolld/Documents/research/bathy/grid/LLC_1080/'


saveDir = '/Users/carrolld/Documents/research/bathy/mat/cell_corners/LLC_1080/';

%%

numFaces = 13;
nx = 1080;
ny = nx .* numFaces;

%%

% read tile00*.mitgdrid files
tile{1}.XG = readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tile{1}.YG = readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tile{2}.XG = readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tile{2}.YG = readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tile{3}.XG = readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',5);
tile{3}.YG = readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',6);
tile{4}.XG = readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tile{4}.YG = readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);
tile{5}.XG = readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tile{5}.YG = readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);

XGsw=zeros(nx,ny);
XGsw(:,1:nx*3)=tile{1}.XG(1:nx,1:nx*3);
XGsw(:,nx*3+1:nx*6)=tile{2}.XG(1:nx,1:nx*3);
XGsw(:,nx*6+1:nx*7)=tile{3}.XG(1:nx,1:nx);
tmp=tile{4}.XG(1:nx*3,1:nx);
XGsw(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.XG(1:nx*3,1:nx);
XGsw(nx*nx*10+1:nx*nx*13)=tmp(:);

XGse=zeros(nx,ny);
XGse(:,1:nx*3)=tile{1}.XG(2:nx+1,1:nx*3);
XGse(:,nx*3+1:nx*6)=tile{2}.XG(2:nx+1,1:nx*3);
XGse(:,nx*6+1:nx*7)=tile{3}.XG(2:nx+1,1:nx);
tmp=tile{4}.XG(2:nx*3+1,1:nx);
XGse(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.XG(2:nx*3+1,1:nx);
XGse(nx*nx*10+1:nx*nx*13)=tmp(:);

XGnw=zeros(nx,ny);
XGnw(:,1:nx*3)=tile{1}.XG(1:nx,2:nx*3+1);
XGnw(:,nx*3+1:nx*6)=tile{2}.XG(1:nx,2:nx*3+1);
XGnw(:,nx*6+1:nx*7)=tile{3}.XG(1:nx,2:nx+1);
tmp=tile{4}.XG(1:nx*3,2:nx+1);
XGnw(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.XG(1:nx*3,2:nx+1);
XGnw(nx*nx*10+1:nx*nx*13)=tmp(:);

XGne=zeros(nx,ny);
XGne(:,1:nx*3)=tile{1}.XG(2:nx+1,2:nx*3+1);
XGne(:,nx*3+1:nx*6)=tile{2}.XG(2:nx+1,2:nx*3+1);
XGne(:,nx*6+1:nx*7)=tile{3}.XG(2:nx+1,2:nx+1);
tmp=tile{4}.XG(2:nx*3+1,2:nx+1);
XGne(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.XG(2:nx*3+1,2:nx+1);
XGne(nx*nx*10+1:nx*nx*13)=tmp(:);

YGsw=zeros(nx,ny);
YGsw(:,1:nx*3)=tile{1}.YG(1:nx,1:nx*3);
YGsw(:,nx*3+1:nx*6)=tile{2}.YG(1:nx,1:nx*3);
YGsw(:,nx*6+1:nx*7)=tile{3}.YG(1:nx,1:nx);
tmp=tile{4}.YG(1:nx*3,1:nx);
YGsw(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.YG(1:nx*3,1:nx);
YGsw(nx*nx*10+1:nx*nx*13)=tmp(:);

YGse=zeros(nx,ny);
YGse(:,1:nx*3)=tile{1}.YG(2:nx+1,1:nx*3);
YGse(:,nx*3+1:nx*6)=tile{2}.YG(2:nx+1,1:nx*3);
YGse(:,nx*6+1:nx*7)=tile{3}.YG(2:nx+1,1:nx);
tmp=tile{4}.YG(2:nx*3+1,1:nx);
YGse(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.YG(2:nx*3+1,1:nx);
YGse(nx*nx*10+1:nx*nx*13)=tmp(:);

YGnw=zeros(nx,ny);
YGnw(:,1:nx*3)=tile{1}.YG(1:nx,2:nx*3+1);
YGnw(:,nx*3+1:nx*6)=tile{2}.YG(1:nx,2:nx*3+1);
YGnw(:,nx*6+1:nx*7)=tile{3}.YG(1:nx,2:nx+1);
tmp=tile{4}.YG(1:nx*3,2:nx+1);
YGnw(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.YG(1:nx*3,2:nx+1);
YGnw(nx*nx*10+1:nx*nx*13)=tmp(:);

YGne=zeros(nx,ny);
YGne(:,1:nx*3)=tile{1}.YG(2:nx+1,2:nx*3+1);
YGne(:,nx*3+1:nx*6)=tile{2}.YG(2:nx+1,2:nx*3+1);
YGne(:,nx*6+1:nx*7)=tile{3}.YG(2:nx+1,2:nx+1);
tmp=tile{4}.YG(2:nx*3+1,2:nx+1);
YGne(nx*nx*7+1:nx*nx*10)=tmp(:);
tmp=tile{5}.YG(2:nx*3+1,2:nx+1);
YGne(nx*nx*10+1:nx*nx*13)=tmp(:);

%%

vars = {'XGsw';'XGse';'XGnw';'XGne'; ...
    'YGsw';'YGse';'YGnw';'YGne'};

for i = 1:length(vars)
    
    eval(['facet{1}.' vars{i} ' = reshape(' vars{i} '(1:nx*nx*3),[nx nx*3]);']);
    eval(['facet{2}.' vars{i} ' = reshape(' vars{i}  '(nx*nx*3+1:nx*nx*6),[nx nx*3]);']);
    eval(['facet{3}.' vars{i} ' = reshape(' vars{i} '(nx*nx*6+1:nx*nx*7),[nx nx]);']);
    eval(['facet{4}.' vars{i} ' = reshape(' vars{i} '(nx*nx*7+1:nx*nx*10),[nx*3 nx]);']);
    eval(['facet{5}.' vars{i} ' = reshape(' vars{i} '(nx*nx*10+1:nx*nx*13),[nx*3 nx]);']);
    
end

%%

save([saveDir 'cell_corners_facets.mat'],'facet','-v7.3');

%%
% look @ fields

figure(1);
quikplot_llc(XGse-XGsw);
caxis([-1 1]);
colorbar('horiz');

figure(2);
quikplot_llc(XGne-XGnw);
caxis([-1 1]);
colorbar('horiz');

figure(3);
quikplot_llc(YGnw-YGsw);
colorbar('horiz');

figure(4);
quikplot_llc(YGne-YGse);
colorbar('horiz');

%%
