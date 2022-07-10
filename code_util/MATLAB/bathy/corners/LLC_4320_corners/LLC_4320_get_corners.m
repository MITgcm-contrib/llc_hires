clear
close all;

gridDir = '/Users/carrolld/Documents/research/bathy/grid/LLC_4320/';
saveDir = '/Users/carrolld/Documents/research/bathy/mat/cell_corners/LLC_4320/';

% gridDir = '/Users/dmenemen/projects/llc/llc4320/grid/';
% saveDir = '/Users/dmenemen/projects/llc/llc4320/grid/';

%% 

% define some constants
numFaces = 13;
nx = 4320;
ny = 4320 .* numFaces;

% input arrays for storing corners
XGsw = zeros(nx,ny);
XGse = zeros(nx,ny);
XGnw = zeros(nx,ny);
XGne = zeros(nx,ny);
YGsw = zeros(nx,ny);
YGse = zeros(nx,ny);
YGnw = zeros(nx,ny);
YGne = zeros(nx,ny);

% find 4 corners for tile 1
ix=1:nx*nx*3;
TMP=readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tmp=TMP(1:end-1,1:end-1); XGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); XGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); XGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); XGne(ix)=tmp(:);
TMP=readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tmp=TMP(1:end-1,1:end-1); YGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); YGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); YGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); YGne(ix)=tmp(:);

% find 4 corners for tile 2
ix=nx*nx*3+1:nx*nx*6;
TMP=readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tmp=TMP(1:end-1,1:end-1); XGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); XGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); XGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); XGne(ix)=tmp(:);
TMP=readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tmp=TMP(1:end-1,1:end-1); YGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); YGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); YGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); YGne(ix)=tmp(:);

% find 4 corners for tile 3
ix=nx*nx*6+1:nx*nx*7;
TMP=readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',5);
tmp=TMP(1:end-1,1:end-1); XGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); XGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); XGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); XGne(ix)=tmp(:);
TMP=readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',6);
tmp=TMP(1:end-1,1:end-1); YGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); YGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); YGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); YGne(ix)=tmp(:);

% find 4 corners for tile 4
ix=nx*nx*7+1:nx*nx*10;
TMP=readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tmp=TMP(1:end-1,1:end-1); XGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); XGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); XGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); XGne(ix)=tmp(:);
TMP=readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);
tmp=TMP(1:end-1,1:end-1); YGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); YGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); YGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); YGne(ix)=tmp(:);

% find 4 corners for tile 5
ix=nx*nx*10+1:nx*nx*13;
TMP=readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tmp=TMP(1:end-1,1:end-1); XGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); XGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); XGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); XGne(ix)=tmp(:);
TMP=readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);
tmp=TMP(1:end-1,1:end-1); YGsw(ix)=tmp(:);
tmp=TMP(2:end  ,1:end-1); YGse(ix)=tmp(:);
tmp=TMP(1:end-1,2:end  ); YGnw(ix)=tmp(:);
tmp=TMP(2:end  ,2:end  ); YGne(ix)=tmp(:);

%% 

vars = {'XGsw';'XGse';'XGnw';'XGne'; ...
    'YGsw';'YGse';'YGnw';'YGne'};
    
for i = 1:length(vars)
    
    eval(['facet{1}.' vars{i} ' = reshape(' vars{i} '(1:nx*nx*3),[nx nx*3]);']);
    eval(['facet{2}.' vars{i} ' = reshape(' vars{i} '(nx*nx*3+1:nx*nx*6),[nx nx*3]);']);
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
