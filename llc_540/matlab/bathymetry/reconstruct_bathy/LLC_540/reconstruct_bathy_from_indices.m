clear
close all

gridDir = '/Users/carrolld/Documents/research/LLC_540/grid/';

dataDir1 = '/Users/carrolld/Documents/research/LLC_540/mat/cell_corners/';
dataDir2 = '/Users/carrolld/Documents/research/LLC_540/raw_data/gebco_2020/';
dataDir3 = '/Users/carrolld/Documents/research/LLC_540/mat/GEBCO_2020/';
dataDir4 = '/Users/carrolld/Documents/research/LLC_540/bin/';

%% 

load([dataDir1 'cell_corners_facets.mat']);

fileName = 'GEBCO_2020.nc';

elevation = -ncread([dataDir2 fileName],'elevation'); 
elevation(elevation <= 0) = 0;

%%

tic 

for i = 1:length(facet)
    
    eval(['load([dataDir3 ''GEBCO_LLC_540_indices_facet_' num2str(i) '.mat'']);']);
    
    [m n] = size(facet{i}.XGsw);

    facet{i}.bathy = zeros(m,n);
    
    for j = 1:length(bathy.LLC_540_ind)
        
        ix1 = bathy.LLC_540_ind{j};
        
        ix2 = bathy.GEBCO_indX{j};
        ix3 = bathy.GEBCO_indY{j};
        
        facet{i}.bathy(ix1(1),ix1(2)) = nanmean(nanmean(elevation(ix2,ix3)));
 
    end
    
    figure
    
    pcolorcen(facet{i}.bathy);
    drawnow
    
    pause
    
    disp(num2str(i));
    
end

toc 

pause

%% 

numFacets = 5;
numFaces = 13;

nx = 540;
ny = nx .* numFaces;
rawDepth = -readbin([dataDir4 'Bathy_compact_filled_llc540_540x7020_v1_gib.bin'],[nx ny],1,'real*4');

depth = zeros(nx,ny);

depth(1:nx*nx*3) = facet{1}.bathy;
depth(nx*nx*3+1:nx*nx*6) = facet{2}.bathy;
depth(nx*nx*6+1:nx*nx*7) = facet{3}.bathy;
depth(nx*nx*7+1:nx*nx*10) = facet{4}.bathy;
depth(nx*nx*10+1:nx*nx*13) = facet{5}.bathy;

rawDepth(rawDepth <= 0) = nan;
depth(depth == 0) = nan;

maxDepth = 5000;

bgColor = [0.5 0.5 0.5];

hFig1 = figure(1);
set(hFig1,'units','normalized','outerposition',[0 0 1 1]);
set(gcf,'color',[1 1 1]);

colors1 = cbrewer('div','Spectral',500);
colors2 = cbrewer('div','RdBu',500);

fs = 24;

cc1 = subplot(131);

hold on

set(gca,'color',bgColor);

quikplot_llc(rawDepth);

hcb1 = colorbar;
caxis([0 maxDepth]);

colormap(cc1,colors1);

axis tight

set(gca,'FontSize',fs);

title('LLC 540 Bathy (m)');

cc2 = subplot(132);

hold on

set(gca,'color',bgColor);

quikplot_llc(depth);

hcb2 = colorbar;
caxis([0 maxDepth]);

colormap(cc2,colors1);

axis tight

set(gca,'FontSize',fs);

title('GEBCO LLC 540 Bathy (m)');

cc3 = subplot(133);

hold on

set(gca,'color',bgColor);

quikplot_llc(rawDepth - depth);

hcb3 = colorbar;
caxis([-200 200]);

colormap(cc3,colors2);

axis tight

set(gca,'FontSize',fs);

title('Difference (m)');
