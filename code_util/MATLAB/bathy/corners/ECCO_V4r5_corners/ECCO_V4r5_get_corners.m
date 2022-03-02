clear
close all;

gridDir = '/Users/carrolld/Documents/research/bathy/bin/grid/ECCO_V4r5/';

saveDir = '/Users/carrolld/Documents/research/bathy/mat/cell_corners/ECCO_V4r5/';

%% 

% define some constants
numFaces = 13;
nx = 90;
ny = 90 .* numFaces;

% input grid and landmask
XGsw = readbin([gridDir 'XG.data'],[nx ny]);
YGsw = readbin([gridDir 'YG.data'],[nx ny]);

% read tile00?.mitgdrid files
tile{1}.XG=readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tile{1}.YG=readbin([gridDir 'tile001.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tile{2}.XG=readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',5);
tile{2}.YG=readbin([gridDir 'tile002.mitgrid'],[(nx+1) (nx*3+1)],1,'real*8',6);
tile{3}.XG=readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',5);
tile{3}.YG=readbin([gridDir 'tile003.mitgrid'],[(nx+1) (nx+1)],1,'real*8',6);
tile{4}.XG=readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tile{4}.YG=readbin([gridDir 'tile004.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);
tile{5}.XG=readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',5);
tile{5}.YG=readbin([gridDir 'tile005.mitgrid'],[(nx*3+1) (nx+1)],1,'real*8',6);

% find the remaining 3 corners
XGsw=XGsw; XGse=XGsw; XGnw=XGsw; XGne=XGsw;
YGsw=YGsw; YGse=YGsw; YGnw=YGsw; YGne=XGsw;
for i=1:length(XGsw(:)), disp(i)
    for t=1:5
        [I J] = find( abs(XGsw(i)-tile{t}.XG(1:end-1,1:end-1))<1e-4 & ...
                      abs(YGsw(i)-tile{t}.YG(1:end-1,1:end-1))<1e-4 );
        if length(I)>0
            break
        end
    end
    
    I=I(1); J=J(1);
    XGse(i)=tile{t}.XG(I+1,J);
    XGnw(i)=tile{t}.XG(I,J+1);
    XGne(i)=tile{t}.XG(I+1,J+1);
    YGse(i)=tile{t}.YG(I+1,J);
    YGnw(i)=tile{t}.YG(I,J+1);
    YGne(i)=tile{t}.YG(I+1,J+1);
    
end

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
